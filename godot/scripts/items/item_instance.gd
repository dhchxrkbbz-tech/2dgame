## ItemInstance - Egy konkrét item példány (affix-ekkel, gem-ekkel)
## ItemData + rolled affix-ek + socket-ek = teljes item
class_name ItemInstance
extends RefCounted

var uuid: String = ""
var base_item: ItemData = null
var item_level: int = 1
var rarity: int = Enums.Rarity.COMMON
var affixes: Array[Dictionary] = []  # [{"affix": AffixData, "value": float}]
var sockets: Array = []  # Gem-ek helye
var unique_property: Dictionary = {}  # {"name": "", "description": "", "effect": ""}
var set_id: String = ""  # Set tartozás
var enhancement_level: int = 0  # +0 → +10
var quantity: int = 1


func _init() -> void:
	uuid = _generate_uuid()


static func _generate_uuid() -> String:
	return "%x%x" % [randi(), Time.get_ticks_msec()]


## Generált item név
func get_display_name() -> String:
	if not base_item:
		return "Unknown Item"
	
	var prefix_name := ""
	var suffix_name := ""
	
	for affix_entry in affixes:
		var affix: AffixData = affix_entry.get("affix")
		if not affix:
			continue
		if affix.affix_type == AffixData.AffixType.PREFIX:
			prefix_name = affix.affix_name
		elif affix.affix_type == AffixData.AffixType.SUFFIX:
			if suffix_name.is_empty():
				suffix_name = affix.affix_name
	
	var name := ""
	if not prefix_name.is_empty():
		name += prefix_name + " "
	name += base_item.item_name
	if not suffix_name.is_empty():
		name += " " + suffix_name
	
	if enhancement_level > 0:
		name += " +%d" % enhancement_level
	
	return name


## Összes stat összegyűjtése
func get_total_stats() -> Dictionary:
	var stats: Dictionary = {}
	
	if not base_item:
		return stats
	
	# Base stats
	if base_item.base_damage > 0:
		stats["physical_damage"] = stats.get("physical_damage", 0.0) + base_item.base_damage
	if base_item.base_armor > 0:
		stats["armor"] = stats.get("armor", 0.0) + base_item.base_armor
	if base_item.base_hp > 0:
		stats["max_hp"] = stats.get("max_hp", 0.0) + base_item.base_hp
	if base_item.base_mana > 0:
		stats["max_mana"] = stats.get("max_mana", 0.0) + base_item.base_mana
	
	# Affix stats
	for affix_entry in affixes:
		var affix: AffixData = affix_entry.get("affix")
		var value: float = affix_entry.get("value", 0.0)
		if affix:
			stats[affix.stat_type] = stats.get(affix.stat_type, 0.0) + value
	
	# Gem stats (socket-ekből)
	for gem in sockets:
		if gem and gem.has_method("get_stats"):
			var gem_stats: Dictionary = gem.get_stats()
			for key in gem_stats:
				stats[key] = stats.get(key, 0.0) + gem_stats[key]
	
	# Enhancement bonus (+5% per level)
	if enhancement_level > 0:
		var mult := 1.0 + enhancement_level * 0.05
		for key in stats:
			stats[key] = stats[key] * mult
	
	return stats


## Rarity szín
func get_rarity_color() -> Color:
	return Constants.RARITY_COLORS.get(rarity, Color.WHITE)


## Eladási ár
func get_sell_price() -> int:
	if not base_item:
		return 1
	var base := base_item.sell_price
	var rarity_mult := [1.0, 2.0, 5.0, 15.0, 50.0]
	var mult := rarity_mult[rarity] if rarity < rarity_mult.size() else 1.0
	return int(base * mult * (1.0 + enhancement_level * 0.1))


## Item szöveg leírás (tooltip)
func get_tooltip_text() -> String:
	var text := get_display_name() + "\n"
	text += "[%s]\n" % _rarity_name()
	
	if base_item:
		text += "Level: %d" % item_level
		if base_item.required_level > 1:
			text += " (Req: %d)" % base_item.required_level
		text += "\n"
	
	var stats := get_total_stats()
	for key in stats:
		var value: float = stats[key]
		var is_pct := false
		for affix_entry in affixes:
			var affix: AffixData = affix_entry.get("affix")
			if affix and affix.stat_type == key:
				is_pct = affix.is_percent
				break
		
		if is_pct:
			text += "+ %.1f%% %s\n" % [value, _format_stat_name(key)]
		else:
			text += "+ %d %s\n" % [int(value), _format_stat_name(key)]
	
	if sockets.size() > 0:
		text += "\nSockets: %d/%d\n" % [sockets.filter(func(s): return s != null).size(), base_item.socket_count if base_item else 0]
	
	return text


func _rarity_name() -> String:
	match rarity:
		Enums.Rarity.COMMON: return "Common"
		Enums.Rarity.UNCOMMON: return "Uncommon"
		Enums.Rarity.RARE: return "Rare"
		Enums.Rarity.EPIC: return "Epic"
		Enums.Rarity.LEGENDARY: return "Legendary"
		_: return "Unknown"


func _format_stat_name(stat: String) -> String:
	return stat.replace("_", " ").capitalize()


## Serialize (save/load)
func serialize() -> Dictionary:
	var data: Dictionary = {
		"uuid": uuid,
		"base_item_id": base_item.item_id if base_item else "",
		"item_level": item_level,
		"rarity": rarity,
		"enhancement_level": enhancement_level,
		"quantity": quantity,
		"set_id": set_id,
		"unique_property": unique_property,
		"affixes": [],
		"sockets": [],
	}
	for affix_entry in affixes:
		var affix: AffixData = affix_entry.get("affix")
		if affix:
			data["affixes"].append({
				"name": affix.affix_name,
				"type": affix.affix_type,
				"stat": affix.stat_type,
				"value": affix_entry.get("value", 0.0),
				"is_percent": affix.is_percent,
			})
	for gem in sockets:
		data["sockets"].append(gem.serialize() if gem and gem.has_method("serialize") else null)
	return data


## Deserialize (load)
static func deserialize(data: Dictionary) -> ItemInstance:
	var instance := ItemInstance.new()
	instance.uuid = data.get("uuid", instance.uuid)
	instance.item_level = data.get("item_level", 1)
	instance.rarity = data.get("rarity", Enums.Rarity.COMMON)
	instance.enhancement_level = data.get("enhancement_level", 0)
	instance.quantity = data.get("quantity", 1)
	instance.set_id = data.get("set_id", "")
	instance.unique_property = data.get("unique_property", {})
	
	# Base item betöltés
	var base_id: String = data.get("base_item_id", "")
	if not base_id.is_empty():
		instance.base_item = ItemDatabase.get_item(base_id)
	
	# Affix-ek visszaállítása
	var affix_data_array: Array = data.get("affixes", [])
	for affix_dict in affix_data_array:
		var affix := AffixData.new()
		affix.affix_name = affix_dict.get("name", "")
		affix.affix_type = affix_dict.get("type", AffixData.AffixType.PREFIX)
		affix.stat_type = affix_dict.get("stat", "")
		affix.is_percent = affix_dict.get("is_percent", false)
		var value: float = affix_dict.get("value", 0.0)
		instance.affixes.append({"affix": affix, "value": value})
	
	return instance


## Összehasonlítás másik item-mel (DPS / armor / total stats)
func compare_to(other: ItemInstance) -> Dictionary:
	var result: Dictionary = {}
	if not other:
		return result
	var my_stats := get_total_stats()
	var other_stats := other.get_total_stats()
	var all_keys: Array = []
	for k in my_stats:
		if k not in all_keys:
			all_keys.append(k)
	for k in other_stats:
		if k not in all_keys:
			all_keys.append(k)
	for key in all_keys:
		var mine: float = my_stats.get(key, 0.0)
		var theirs: float = other_stats.get(key, 0.0)
		result[key] = mine - theirs
	return result

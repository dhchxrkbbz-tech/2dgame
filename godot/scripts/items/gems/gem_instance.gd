## GemInstance - Egy konkrét gem példány (típus + tier + opcionális legendary)
## Hasonlóan az ItemInstance-hez, de gem-specifikus
class_name GemInstance
extends RefCounted

var uuid: String = ""
var gem_type: Enums.GemType = Enums.GemType.RUBY
var gem_tier: Enums.GemTier = Enums.GemTier.CHIPPED
var is_legendary: bool = false
var legendary_id: String = ""  # Ha legendary, az egyedi ID


func _init() -> void:
	uuid = _generate_uuid()


static func _generate_uuid() -> String:
	return "gem_%x%x" % [randi(), Time.get_ticks_msec()]


## Inicializálás típus és tier alapján
func initialize(p_type: Enums.GemType = Enums.GemType.RUBY, p_tier: Enums.GemTier = Enums.GemTier.CHIPPED) -> void:
	gem_type = p_type
	gem_tier = p_tier
	is_legendary = (gem_type == Enums.GemType.LEGENDARY)


## Teljes megjelenítési név
func get_display_name() -> String:
	if is_legendary and not legendary_id.is_empty():
		var leg_data := LegendaryGemDatabase.get_gem(legendary_id)
		if leg_data:
			return leg_data.gem_name
		return "Unknown Legendary Gem"
	return GemData.get_full_name(gem_type, gem_tier)


## Stat-ok lekérése adott slot kategóriához
func get_stats_for_slot(slot_category: GemStatTable.SlotCategory) -> Dictionary:
	if is_legendary:
		return _get_legendary_stats()
	return GemStatTable.get_stat(gem_type, gem_tier, slot_category)


## Stat-ok lekérése equip slot alapján (kényelmi funkció)
func get_stats_for_equip_slot(equip_slot: int) -> Dictionary:
	if is_legendary:
		return _get_legendary_stats()
	var slot_cat := GemStatTable.get_slot_category(equip_slot)
	return GemStatTable.get_stat(gem_type, gem_tier, slot_cat)


## ItemInstance.get_total_stats() kompatibilis stat dictionary
## Az item equip_slot-ja alapján adja a megfelelő stat-ot
func get_stats(equip_slot: int = -1) -> Dictionary:
	var result: Dictionary = {}

	if is_legendary:
		var leg_stats := _get_legendary_stats()
		for key in leg_stats:
			result[key] = leg_stats[key]
		return result

	# Ha nincs equip_slot megadva, weapon stat-ot adunk default-ként
	var slot_cat := GemStatTable.SlotCategory.WEAPON
	if equip_slot >= 0:
		slot_cat = GemStatTable.get_slot_category(equip_slot)

	var stat_info := GemStatTable.get_stat(gem_type, gem_tier, slot_cat)
	if not stat_info.stat.is_empty():
		result[stat_info.stat] = stat_info.value
	return result


## Gem szín
func get_color() -> Color:
	return GemData.get_gem_color(gem_type)


## NPC eladási ár
func get_sell_price() -> int:
	if is_legendary:
		return 2000
	return GemData.get_sell_price(gem_tier)


## Tooltip szöveg generálás
func get_tooltip_text(equip_slot: int = -1) -> String:
	var text := get_display_name() + "\n"

	if is_legendary:
		var leg_data := LegendaryGemDatabase.get_gem(legendary_id)
		if leg_data:
			text += "[color=orange]Legendary Gem[/color]\n"
			text += leg_data.description + "\n"
			text += "\nOnly fits in Accessory sockets\n"
			text += "Max 1 per item\n"
		return text

	var tier_name: String = GemData.GEM_TIER_NAMES.get(gem_tier, "Unknown")
	text += "[%s]\n" % tier_name

	if equip_slot >= 0:
		var slot_cat := GemStatTable.get_slot_category(equip_slot)
		text += GemStatTable.get_stat_description(gem_type, gem_tier, slot_cat) + "\n"
	else:
		# Összes slot kategória mutatása
		var descs := GemStatTable.get_all_slot_descriptions(gem_type, gem_tier)
		text += "Weapon: %s\n" % descs.weapon
		text += "Armor: %s\n" % descs.armor
		text += "Accessory: %s\n" % descs.accessory

	text += "\nSell: %d gold" % get_sell_price()
	return text


## Legendary gem effekt stat-ok
func _get_legendary_stats() -> Dictionary:
	if not is_legendary or legendary_id.is_empty():
		return {}
	var leg_data := LegendaryGemDatabase.get_gem(legendary_id)
	if leg_data:
		return leg_data.get_stat_bonuses()
	return {}


## Serialize (save/load)
func serialize() -> Dictionary:
	return {
		"uuid": uuid,
		"gem_type": gem_type,
		"gem_tier": gem_tier,
		"is_legendary": is_legendary,
		"legendary_id": legendary_id,
	}


## Deserialize (load)
static func deserialize(data: Dictionary) -> GemInstance:
	if data == null or data.is_empty():
		return null
	var gem := GemInstance.new()
	gem.uuid = data.get("uuid", gem.uuid)
	gem.gem_type = data.get("gem_type", Enums.GemType.RUBY)
	gem.gem_tier = data.get("gem_tier", Enums.GemTier.CHIPPED)
	gem.is_legendary = data.get("is_legendary", false)
	gem.legendary_id = data.get("legendary_id", "")
	return gem


## Factory: normál gem létrehozás
static func create_normal(p_type: Enums.GemType, p_tier: Enums.GemTier) -> GemInstance:
	var gem := GemInstance.new()
	gem.initialize(p_type, p_tier)
	return gem


## Factory: legendary gem létrehozás
static func create_legendary(p_legendary_id: String) -> GemInstance:
	var gem := GemInstance.new()
	gem.gem_type = Enums.GemType.LEGENDARY
	gem.gem_tier = Enums.GemTier.RADIANT  # Legendary-k nem tier-ezhetők, de Radiant szintű
	gem.is_legendary = true
	gem.legendary_id = p_legendary_id
	return gem

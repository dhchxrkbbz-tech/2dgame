## ItemGenerator - Item generálás rarity és affix rendszerrel
## Véletlenszerű item-ek generálása loot drop-hoz
class_name ItemGenerator
extends RefCounted

# === Rarity esélyekk (base, módosítható magic find-dal) ===
const BASE_RARITY_WEIGHTS: Dictionary = {
	Enums.Rarity.COMMON: 60.0,
	Enums.Rarity.UNCOMMON: 25.0,
	Enums.Rarity.RARE: 10.0,
	Enums.Rarity.EPIC: 4.0,
	Enums.Rarity.LEGENDARY: 1.0,
}

# === Affix count per rarity ===
const AFFIX_COUNT: Dictionary = {
	Enums.Rarity.COMMON: Vector2i(0, 0),
	Enums.Rarity.UNCOMMON: Vector2i(1, 2),
	Enums.Rarity.RARE: Vector2i(2, 3),
	Enums.Rarity.EPIC: Vector2i(3, 4),
	Enums.Rarity.LEGENDARY: Vector2i(4, 6),
}

# === Socket count per rarity ===
const SOCKET_RANGE: Dictionary = {
	Enums.Rarity.COMMON: Vector2i(0, 0),
	Enums.Rarity.UNCOMMON: Vector2i(0, 1),
	Enums.Rarity.RARE: Vector2i(0, 2),
	Enums.Rarity.EPIC: Vector2i(1, 3),
	Enums.Rarity.LEGENDARY: Vector2i(2, 4),
}


## Teljes item generálás
static func generate_item(
	item_level: int,
	item_type: Enums.ItemType = Enums.ItemType.WEAPON,
	magic_find: float = 0.0,
	forced_rarity: int = -1
) -> Dictionary:
	# Rarity kiválasztása
	var rarity: Enums.Rarity
	if forced_rarity >= 0:
		rarity = forced_rarity as Enums.Rarity
	else:
		rarity = _roll_rarity(magic_find)
	
	# Base item kiválasztása
	var base_item: Dictionary = _select_base_item(item_type, item_level)
	
	# Affix generálás
	var affix_range: Vector2i = AFFIX_COUNT.get(rarity, Vector2i(0, 0))
	var affix_count: int = randi_range(affix_range.x, affix_range.y)
	var affixes: Array[Dictionary] = _generate_affixes(affix_count, item_level, item_type)
	
	# Socket generálás
	var socket_range: Vector2i = SOCKET_RANGE.get(rarity, Vector2i(0, 0))
	var socket_count: int = randi_range(socket_range.x, socket_range.y)
	
	# UUID
	var uuid: String = _generate_uuid()
	
	var item := {
		"uuid": uuid,
		"base_item": base_item,
		"item_type": item_type,
		"rarity": rarity,
		"item_level": item_level,
		"affixes": affixes,
		"socket_count": socket_count,
		"sockets": [],  # Array of gem instances
		"enhancement_level": 0,
		"is_identified": rarity <= Enums.Rarity.UNCOMMON,
	}
	
	return item


## Rarity roll magic find-dal
static func _roll_rarity(magic_find: float) -> Enums.Rarity:
	var weights: Dictionary = BASE_RARITY_WEIGHTS.duplicate()
	
	# Magic find növeli a ritka drop esélyét
	if magic_find > 0:
		weights[Enums.Rarity.UNCOMMON] *= (1.0 + magic_find * 0.5)
		weights[Enums.Rarity.RARE] *= (1.0 + magic_find)
		weights[Enums.Rarity.EPIC] *= (1.0 + magic_find * 1.5)
		weights[Enums.Rarity.LEGENDARY] *= (1.0 + magic_find * 2.0)
	
	var total_weight: float = 0.0
	for w in weights.values():
		total_weight += w
	
	var roll: float = randf() * total_weight
	var cumulative: float = 0.0
	
	for rarity in weights:
		cumulative += weights[rarity]
		if roll <= cumulative:
			return rarity
	
	return Enums.Rarity.COMMON


## Base item kiválasztása
static func _select_base_item(item_type: Enums.ItemType, item_level: int) -> Dictionary:
	# Placeholder - a tényleges implementáció az ItemDatabase-ből tölt
	var base := {
		"name": "Item",
		"item_type": item_type,
		"base_damage": 0,
		"base_armor": 0,
		"required_level": maxi(1, item_level - 5),
	}
	
	match item_type:
		Enums.ItemType.WEAPON:
			base["name"] = "Weapon"
			base["base_damage"] = 5 + item_level * 2
		Enums.ItemType.ARMOR:
			base["name"] = "Armor"
			base["base_armor"] = 3 + item_level
		Enums.ItemType.ACCESSORY:
			base["name"] = "Accessory"
	
	return base


## Affix generálás
static func _generate_affixes(count: int, item_level: int, item_type: Enums.ItemType) -> Array[Dictionary]:
	var affixes: Array[Dictionary] = []
	var used_types: Array[String] = []
	
	for i in range(count):
		var affix := _generate_single_affix(item_level, item_type, used_types)
		if not affix.is_empty():
			affixes.append(affix)
			used_types.append(affix.get("type", ""))
	
	return affixes


static func _generate_single_affix(item_level: int, _item_type: Enums.ItemType, exclude: Array[String]) -> Dictionary:
	var possible_affixes: Array[String] = [
		"flat_damage", "percent_damage", "flat_armor", "percent_armor",
		"flat_hp", "percent_hp", "crit_chance", "crit_damage",
		"attack_speed", "move_speed", "mana", "mana_regen",
		"lifesteal", "cooldown_reduction", "all_resist",
	]
	
	# Kiszűrjük a már használtakat
	possible_affixes = possible_affixes.filter(func(a): return a not in exclude)
	
	if possible_affixes.is_empty():
		return {}
	
	var affix_type: String = possible_affixes[randi() % possible_affixes.size()]
	var tier: int = clampi(item_level / 10 + 1, 1, 5)
	var value: float = _get_affix_value(affix_type, tier)
	
	return {
		"type": affix_type,
		"tier": tier,
		"value": value,
		"is_prefix": randf() > 0.5,
	}


static func _get_affix_value(affix_type: String, tier: int) -> float:
	var base_values: Dictionary = {
		"flat_damage": 3.0, "percent_damage": 5.0,
		"flat_armor": 5.0, "percent_armor": 3.0,
		"flat_hp": 10.0, "percent_hp": 3.0,
		"crit_chance": 1.0, "crit_damage": 5.0,
		"attack_speed": 3.0, "move_speed": 2.0,
		"mana": 8.0, "mana_regen": 0.5,
		"lifesteal": 1.0, "cooldown_reduction": 2.0,
		"all_resist": 3.0,
	}
	var base: float = base_values.get(affix_type, 1.0)
	return base * tier * (0.8 + randf() * 0.4)  # ±20% variáció


static func _generate_uuid() -> String:
	var chars := "abcdef0123456789"
	var uuid := ""
	for i in range(32):
		uuid += chars[randi() % chars.length()]
		if i in [7, 11, 15, 19]:
			uuid += "-"
	return uuid

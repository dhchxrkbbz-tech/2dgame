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
	
	# Legendary items get a unique power
	if rarity == Enums.Rarity.LEGENDARY:
		var legendary_power := _assign_legendary_power(item_type, item_level)
		item["legendary_power"] = legendary_power
		item["legendary_name"] = legendary_power.get("name", "")
		# Legendary mindig max socket
		item["socket_count"] = SOCKET_RANGE[Enums.Rarity.LEGENDARY].y
	
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


# ══════════════════════════════════════════════
# LEGENDARY UNIQUE POWER ASSIGNMENT
# ══════════════════════════════════════════════

## Unique legendary power pool (item_type → Array of powers)
const LEGENDARY_POWERS: Dictionary = {
	# Weapons
	"weapon": [
		{
			"name": "Soul Reaper",
			"description": "Kills have 15% chance to restore 10% max HP",
			"trigger": "on_kill",
			"effect": "heal_percent",
			"params": {"chance": 0.15, "heal_percent": 0.10},
		},
		{
			"name": "Thunderstrike",
			"description": "Attacks chain lightning to 2 nearby enemies for 30% damage",
			"trigger": "on_hit",
			"effect": "chain_damage",
			"params": {"chain_count": 2, "damage_percent": 0.30, "range": 80.0},
		},
		{
			"name": "Void Blade",
			"description": "20% chance to deal bonus True damage equal to 25% of damage dealt",
			"trigger": "on_hit",
			"effect": "bonus_true_damage",
			"params": {"chance": 0.20, "damage_percent": 0.25},
		},
		{
			"name": "Berserker's Fury",
			"description": "+2% damage for each 1% HP missing (max +50%)",
			"trigger": "passive",
			"effect": "low_hp_damage",
			"params": {"damage_per_percent": 2.0, "max_bonus": 50.0},
		},
		{
			"name": "The Executioner",
			"description": "Deal 30% bonus damage to enemies below 30% HP",
			"trigger": "passive",
			"effect": "execute_damage",
			"params": {"hp_threshold": 0.30, "bonus_damage": 0.30},
		},
	],
	# Armor
	"armor": [
		{
			"name": "Aegis of the Undying",
			"description": "Once per 180s, survive a killing blow with 1 HP",
			"trigger": "on_lethal",
			"effect": "cheat_death",
			"params": {"cooldown": 180.0},
		},
		{
			"name": "Thornmail",
			"description": "Reflect 20% of melee damage taken back to attacker",
			"trigger": "on_hit_received",
			"effect": "damage_reflect",
			"params": {"reflect_percent": 0.20},
		},
		{
			"name": "Living Fortress",
			"description": "+1% damage reduction for each enemy within 10 tiles (max 25%)",
			"trigger": "passive",
			"effect": "proximity_defense",
			"params": {"reduction_per_enemy": 0.01, "max_reduction": 0.25, "range": 160.0},
		},
		{
			"name": "Mana Barrier",
			"description": "30% of damage taken is absorbed by mana instead of HP",
			"trigger": "on_hit_received",
			"effect": "mana_absorb",
			"params": {"absorb_percent": 0.30},
		},
	],
	# Accessories
	"accessory": [
		{
			"name": "Ring of Fortune",
			"description": "+50% Magic Find, +25% Gold Find",
			"trigger": "passive",
			"effect": "magic_find",
			"params": {"magic_find": 0.50, "gold_find": 0.25},
		},
		{
			"name": "Amulet of Speed",
			"description": "+20% movement speed, +15% attack speed",
			"trigger": "passive",
			"effect": "speed_boost",
			"params": {"move_speed": 0.20, "attack_speed": 0.15},
		},
		{
			"name": "Phylactery of Souls",
			"description": "Killing enemies grants stacking +1% crit chance for 10s (max 15%)",
			"trigger": "on_kill",
			"effect": "kill_crit_stack",
			"params": {"crit_per_stack": 0.01, "max_stacks": 15, "duration": 10.0},
		},
	],
}


## Assign a unique legendary power based on item type
static func _assign_legendary_power(item_type: Enums.ItemType, _item_level: int) -> Dictionary:
	var type_key: String
	match item_type:
		Enums.ItemType.WEAPON:
			type_key = "weapon"
		Enums.ItemType.ARMOR:
			type_key = "armor"
		Enums.ItemType.ACCESSORY:
			type_key = "accessory"
		_:
			type_key = "weapon"  # Fallback
	
	var powers: Array = LEGENDARY_POWERS.get(type_key, [])
	if powers.is_empty():
		return {"name": "Unknown Power", "description": "A mysterious power", "trigger": "passive", "effect": "none", "params": {}}
	
	# Random power kiválasztása
	return powers[randi() % powers.size()].duplicate(true)

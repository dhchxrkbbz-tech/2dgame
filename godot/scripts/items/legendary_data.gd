## LegendaryData - Legendary/Unique item definíciók
## 30 legendary item fix stat-okkal és egyedi effektekkel
class_name LegendaryData
extends RefCounted

static var _legendaries: Dictionary = {}
static var _initialized: bool = false


static func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	_register_assassin_legendaries()
	_register_tank_legendaries()
	_register_mage_legendaries()
	_register_universal_legendaries()
	_register_boss_legendaries()


static func get_legendary(legendary_id: String) -> Dictionary:
	initialize()
	return _legendaries.get(legendary_id, {})


static func get_all_legendary_ids() -> Array[String]:
	initialize()
	var ids: Array[String] = []
	for key in _legendaries:
		ids.append(key)
	return ids


static func get_legendaries_for_class(player_class: int) -> Array[Dictionary]:
	initialize()
	var result: Array[Dictionary] = []
	for key in _legendaries:
		var leg: Dictionary = _legendaries[key]
		if leg.get("required_class", -1) == player_class or leg.get("required_class", -1) == -1:
			result.append(leg)
	return result


static func get_random_legendary(player_class: int = -1) -> Dictionary:
	initialize()
	var pool: Array[Dictionary] = []
	for key in _legendaries:
		var leg: Dictionary = _legendaries[key]
		if player_class < 0 or leg.get("required_class", -1) == player_class or leg.get("required_class", -1) == -1:
			pool.append(leg)
	if pool.is_empty():
		return {}
	return pool[randi() % pool.size()]


static func _reg(id: String, data: Dictionary) -> void:
	data["id"] = id
	_legendaries[id] = data


# =================== ASSASSIN LEGENDARIES ===================

static func _register_assassin_legendaries() -> void:
	_reg("nightfall_dagger", {
		"name": "Nightfall Dagger",
		"slot": Enums.EquipSlot.MAIN_HAND,
		"item_type": Enums.ItemType.WEAPON,
		"required_class": Enums.PlayerClass.ASSASSIN,
		"fixed_stats": {
			"physical_damage": 35,
			"attack_speed": 15,
			"crit_chance": 10,
		},
		"unique_property": {
			"name": "Nightfall",
			"description": "Critical hits have 20% chance to reset all cooldowns",
			"effect": "crit_reset_cooldowns",
			"value": 20.0,
		},
	})
	
	_reg("serpents_kiss", {
		"name": "Serpent's Kiss",
		"slot": Enums.EquipSlot.MAIN_HAND,
		"item_type": Enums.ItemType.WEAPON,
		"required_class": Enums.PlayerClass.ASSASSIN,
		"fixed_stats": {
			"physical_damage": 28,
			"poison_damage": 20,
			"attack_speed": 20,
		},
		"unique_property": {
			"name": "Venomous Strike",
			"description": "Every 3rd hit applies a stacking poison (max 5)",
			"effect": "stacking_poison",
			"value": 5.0,
		},
	})
	
	_reg("cloak_of_shadows", {
		"name": "Cloak of Shadows",
		"slot": Enums.EquipSlot.CAPE,
		"item_type": Enums.ItemType.ACCESSORY,
		"required_class": Enums.PlayerClass.ASSASSIN,
		"fixed_stats": {
			"dodge": 15,
			"move_speed": 10,
			"crit_chance": 5,
		},
		"unique_property": {
			"name": "Shadow Veil",
			"description": "After dodging, become invisible for 1.5s",
			"effect": "dodge_stealth",
			"value": 1.5,
		},
	})
	
	_reg("bloodthirst_ring", {
		"name": "Bloodthirst Ring",
		"slot": Enums.EquipSlot.RING_1,
		"item_type": Enums.ItemType.ACCESSORY,
		"required_class": Enums.PlayerClass.ASSASSIN,
		"fixed_stats": {
			"lifesteal": 8,
			"crit_damage": 25,
			"max_hp": 30,
		},
		"unique_property": {
			"name": "Bloodthirst",
			"description": "Kills restore 15% max HP",
			"effect": "kill_heal_percent",
			"value": 15.0,
		},
	})


# =================== TANK LEGENDARIES ===================

static func _register_tank_legendaries() -> void:
	_reg("aegis_of_the_fallen", {
		"name": "Aegis of the Fallen",
		"slot": Enums.EquipSlot.OFF_HAND,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": Enums.PlayerClass.TANK,
		"fixed_stats": {
			"armor": 50,
			"block_chance": 30,
			"max_hp": 200,
		},
		"unique_property": {
			"name": "Last Stand",
			"description": "When HP drops below 20%, become invulnerable for 3s (90s cd)",
			"effect": "low_hp_invulnerable",
			"value": 3.0,
		},
	})
	
	_reg("wrath_of_titans", {
		"name": "Wrath of Titans",
		"slot": Enums.EquipSlot.MAIN_HAND,
		"item_type": Enums.ItemType.WEAPON,
		"required_class": Enums.PlayerClass.TANK,
		"fixed_stats": {
			"physical_damage": 45,
			"max_hp": 100,
			"armor": 20,
		},
		"unique_property": {
			"name": "Titanic Blow",
			"description": "Every 5th attack deals 300% damage and stuns for 2s",
			"effect": "titanic_blow",
			"value": 300.0,
		},
	})
	
	_reg("heart_of_the_mountain", {
		"name": "Heart of the Mountain",
		"slot": Enums.EquipSlot.CHEST,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": Enums.PlayerClass.TANK,
		"fixed_stats": {
			"armor": 60,
			"max_hp": 300,
			"damage_reduction": 10,
		},
		"unique_property": {
			"name": "Stone Skin",
			"description": "Taking damage has 15% chance to grant a shield equal to 20% max HP",
			"effect": "damage_shield",
			"value": 20.0,
		},
	})
	
	_reg("crown_of_thorns", {
		"name": "Crown of Thorns",
		"slot": Enums.EquipSlot.HELMET,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": Enums.PlayerClass.TANK,
		"fixed_stats": {
			"armor": 30,
			"max_hp": 150,
			"hp_regen": 10,
		},
		"unique_property": {
			"name": "Thorns",
			"description": "Reflect 25% of melee damage taken back to attacker",
			"effect": "thorns_reflect",
			"value": 25.0,
		},
	})


# =================== MAGE LEGENDARIES ===================

static func _register_mage_legendaries() -> void:
	_reg("staff_of_eternity", {
		"name": "Staff of Eternity",
		"slot": Enums.EquipSlot.MAIN_HAND,
		"item_type": Enums.ItemType.WEAPON,
		"required_class": Enums.PlayerClass.MAGE,
		"fixed_stats": {
			"spell_damage": 40,
			"cooldown_reduction": 20,
			"max_mana": 100,
		},
		"unique_property": {
			"name": "Eternal Echo",
			"description": "Spells have 10% chance to cast twice at no mana cost",
			"effect": "double_cast",
			"value": 10.0,
		},
	})
	
	_reg("frostfire_orb", {
		"name": "Frostfire Orb",
		"slot": Enums.EquipSlot.OFF_HAND,
		"item_type": Enums.ItemType.ACCESSORY,
		"required_class": Enums.PlayerClass.MAGE,
		"fixed_stats": {
			"spell_damage": 25,
			"fire_damage": 15,
			"ice_damage": 15,
		},
		"unique_property": {
			"name": "Elemental Fusion",
			"description": "Fire spells have 20% chance to also freeze, Ice spells have 20% chance to also burn",
			"effect": "elemental_crossover",
			"value": 20.0,
		},
	})
	
	_reg("robes_of_the_archmage", {
		"name": "Robes of the Archmage",
		"slot": Enums.EquipSlot.CHEST,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": Enums.PlayerClass.MAGE,
		"fixed_stats": {
			"spell_damage": 20,
			"max_mana": 150,
			"mana_regen": 8,
			"cooldown_reduction": 10,
		},
		"unique_property": {
			"name": "Arcane Surge",
			"description": "Casting a spell grants +5% spell damage for 5s (stacks 5x)",
			"effect": "spell_damage_stack",
			"value": 5.0,
		},
	})
	
	_reg("crown_of_winter", {
		"name": "Crown of Winter",
		"slot": Enums.EquipSlot.HELMET,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": Enums.PlayerClass.MAGE,
		"fixed_stats": {
			"ice_damage": 25,
			"spell_damage": 15,
			"max_mana": 60,
		},
		"unique_property": {
			"name": "Permafrost",
			"description": "Enemies you freeze stay frozen 50% longer and shatter on death dealing AoE",
			"effect": "permafrost",
			"value": 50.0,
		},
	})


# =================== UNIVERSAL LEGENDARIES ===================

static func _register_universal_legendaries() -> void:
	_reg("ring_of_sacrifice", {
		"name": "Ring of Sacrifice",
		"slot": Enums.EquipSlot.RING_1,
		"item_type": Enums.ItemType.ACCESSORY,
		"required_class": -1,
		"fixed_stats": {
			"physical_damage": 10,
			"lifesteal": 5,
			"max_hp": 50,
		},
		"unique_property": {
			"name": "Blood Pact",
			"description": "Take 50% more damage but deal 50% more damage",
			"effect": "glass_cannon",
			"value": 50.0,
		},
	})
	
	_reg("boots_of_the_wind", {
		"name": "Boots of the Wind",
		"slot": Enums.EquipSlot.BOOTS,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": -1,
		"fixed_stats": {
			"move_speed": 20,
			"dodge": 10,
		},
		"unique_property": {
			"name": "Wind Walker",
			"description": "Dodging an attack grants +30% move speed for 2s",
			"effect": "dodge_speed_boost",
			"value": 30.0,
		},
	})
	
	_reg("amulet_of_greed", {
		"name": "Amulet of Greed",
		"slot": Enums.EquipSlot.AMULET,
		"item_type": Enums.ItemType.ACCESSORY,
		"required_class": -1,
		"fixed_stats": {
			"gold_find": 50,
			"magic_find": 25,
			"xp_gain": 15,
		},
		"unique_property": {
			"name": "Midas Touch",
			"description": "Enemies have 5% chance to drop double gold and an extra item",
			"effect": "double_loot_chance",
			"value": 5.0,
		},
	})
	
	_reg("belt_of_the_giant", {
		"name": "Belt of the Giant",
		"slot": Enums.EquipSlot.BELT,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": -1,
		"fixed_stats": {
			"max_hp": 100,
			"armor": 15,
			"hp_regen": 5,
		},
		"unique_property": {
			"name": "Giant's Endurance",
			"description": "Max HP increased by 25% of your total armor",
			"effect": "armor_to_hp",
			"value": 25.0,
		},
	})
	
	_reg("ring_of_echoes", {
		"name": "Ring of Echoes",
		"slot": Enums.EquipSlot.RING_2,
		"item_type": Enums.ItemType.ACCESSORY,
		"required_class": -1,
		"fixed_stats": {
			"cooldown_reduction": 15,
			"max_mana": 40,
			"spell_damage": 10,
		},
		"unique_property": {
			"name": "Echo",
			"description": "Skills used within 2s of another skill cost 30% less mana",
			"effect": "skill_chain_mana",
			"value": 30.0,
		},
	})
	
	_reg("cape_of_the_phantom", {
		"name": "Cape of the Phantom",
		"slot": Enums.EquipSlot.CAPE,
		"item_type": Enums.ItemType.ACCESSORY,
		"required_class": -1,
		"fixed_stats": {
			"dodge": 12,
			"move_speed": 8,
			"damage_reduction": 5,
		},
		"unique_property": {
			"name": "Phase Shift",
			"description": "10% chance to phase through attacks (full immunity for that hit)",
			"effect": "phase_immune",
			"value": 10.0,
		},
	})
	
	_reg("gloves_of_precision", {
		"name": "Gloves of Precision",
		"slot": Enums.EquipSlot.GLOVES,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": -1,
		"fixed_stats": {
			"crit_chance": 8,
			"crit_damage": 30,
			"attack_speed": 10,
		},
		"unique_property": {
			"name": "Deadly Precision",
			"description": "Consecutive critical hits increase crit damage by 10% (resets on non-crit)",
			"effect": "crit_chain",
			"value": 10.0,
		},
	})


# =================== BOSS LEGENDARIES ===================

static func _register_boss_legendaries() -> void:
	# Necromancer King (T2)
	_reg("necro_crown", {
		"name": "Necro Crown",
		"slot": Enums.EquipSlot.HELMET,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": -1,
		"boss_source": "necromancer_king",
		"fixed_stats": {
			"spell_damage": 20,
			"max_hp": 80,
			"damage_reduction": 8,
		},
		"unique_property": {
			"name": "Undying Command",
			"description": "+25% Summon Damage, Dark resistance +50%",
			"effect": "summon_damage_dark_resist",
			"value": 25.0,
		},
	})
	
	_reg("bone_staff", {
		"name": "Bone Staff",
		"slot": Enums.EquipSlot.MAIN_HAND,
		"item_type": Enums.ItemType.WEAPON,
		"required_class": Enums.PlayerClass.MAGE,
		"boss_source": "necromancer_king",
		"fixed_stats": {
			"spell_damage": 30,
			"crit_chance": 6,
		},
		"unique_property": {
			"name": "Death's Harvest",
			"description": "10% chance on kill to summon a skeleton ally for 15s",
			"effect": "summon_skeleton_on_kill",
			"value": 10.0,
		},
	})
	
	# Abyss Dragon (T3)
	_reg("dragon_scale_armor", {
		"name": "Dragon Scale Armor",
		"slot": Enums.EquipSlot.CHEST,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": -1,
		"boss_source": "abyss_dragon",
		"fixed_stats": {
			"armor": 80,
			"max_hp": 250,
			"fire_damage": 0,
		},
		"unique_property": {
			"name": "Dragonhide",
			"description": "Immune to fire damage. +30% armor",
			"effect": "fire_immune",
			"value": 30.0,
		},
	})
	
	_reg("dragon_fang", {
		"name": "Dragon Fang",
		"slot": Enums.EquipSlot.MAIN_HAND,
		"item_type": Enums.ItemType.WEAPON,
		"required_class": -1,
		"boss_source": "abyss_dragon",
		"fixed_stats": {
			"physical_damage": 50,
			"fire_damage": 25,
			"attack_speed": 10,
		},
		"unique_property": {
			"name": "Dragon's Breath",
			"description": "Attacks deal AoE fire damage in a cone",
			"effect": "fire_cleave",
			"value": 0.0,
		},
	})
	
	# Ashen God (T4 - Final Boss)
	_reg("ashen_crown", {
		"name": "Ashen Crown",
		"slot": Enums.EquipSlot.HELMET,
		"item_type": Enums.ItemType.ARMOR,
		"required_class": -1,
		"boss_source": "ashen_god",
		"fixed_stats": {
			"armor": 40,
			"max_hp": 200,
			"spell_damage": 25,
			"physical_damage": 25,
			"cooldown_reduction": 15,
		},
		"unique_property": {
			"name": "Ashen Authority",
			"description": "All stats +10%. Immune to stun and freeze",
			"effect": "all_stats_boost",
			"value": 10.0,
		},
	})
	
	_reg("god_slayer", {
		"name": "God Slayer",
		"slot": Enums.EquipSlot.MAIN_HAND,
		"item_type": Enums.ItemType.WEAPON,
		"required_class": -1,
		"boss_source": "ashen_god",
		"fixed_stats": {
			"physical_damage": 60,
			"crit_chance": 12,
			"crit_damage": 40,
			"attack_speed": 15,
		},
		"unique_property": {
			"name": "God Slayer",
			"description": "Every kill grants +2% damage for the rest of the dungeon (max 50%)",
			"effect": "kill_damage_stack",
			"value": 2.0,
		},
	})
	
	_reg("ashen_relic", {
		"name": "Ashen Relic",
		"slot": Enums.EquipSlot.AMULET,
		"item_type": Enums.ItemType.ACCESSORY,
		"required_class": -1,
		"boss_source": "ashen_god",
		"fixed_stats": {
			"max_hp": 100,
			"max_mana": 50,
			"magic_find": 30,
			"xp_gain": 20,
		},
		"unique_property": {
			"name": "Ashen Legacy",
			"description": "Endgame progression: unlock ascension levels (+1% all stats per ascension)",
			"effect": "ascension_unlock",
			"value": 1.0,
		},
	})

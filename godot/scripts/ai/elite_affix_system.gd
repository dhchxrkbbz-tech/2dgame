## EliteAffixSystem - Elite enemy módosítók
## Elite-ok extra képességeket kapnak (affix-ek) amik nehezebbé teszik őket
class_name EliteAffixSystem
extends RefCounted

enum EliteAffix {
	SHIELDED,     # Periodikus pajzs
	VAMPIRIC,     # HP drain támadásból
	THORNS,       # Visszatükrözi a damage egy részét
	ENRAGED,      # Periodikus berserk mode
	SUMMONER,     # Kis minion-okat idéz
	TELEPORTER,   # Rövid teleportok
	EXPLOSIVE,    # Halálkor robbanás
	FROZEN,       # Slow aura
	POISONOUS,    # Poison trail
	BERSERKER,    # Low HP = high damage
}

## Affix konfigurációk
static var AFFIX_CONFIG: Dictionary = {
	EliteAffix.SHIELDED: {
		"name": "Shielded",
		"color_tint": Color(0.3, 0.6, 1.0),
		"shield_amount": 50,  # % of max HP
		"shield_cooldown": 15.0,
	},
	EliteAffix.VAMPIRIC: {
		"name": "Vampiric",
		"color_tint": Color(0.8, 0.1, 0.2),
		"lifesteal_percent": 0.20,  # 20% damage → heal
	},
	EliteAffix.THORNS: {
		"name": "Thorns",
		"color_tint": Color(0.7, 0.5, 0.2),
		"reflect_percent": 0.15,  # 15% damage reflected
	},
	EliteAffix.ENRAGED: {
		"name": "Enraged",
		"color_tint": Color(1.0, 0.3, 0.1),
		"enrage_duration": 5.0,
		"enrage_cooldown": 20.0,
		"damage_mult": 1.5,
		"speed_mult": 1.3,
	},
	EliteAffix.SUMMONER: {
		"name": "Summoner",
		"color_tint": Color(0.6, 0.4, 0.8),
		"summon_cooldown": 12.0,
		"summon_count": 2,
		"summon_hp": 15,
		"summon_damage": 5,
		"max_summons": 4,
	},
	EliteAffix.TELEPORTER: {
		"name": "Teleporter",
		"color_tint": Color(0.5, 0.1, 0.8),
		"teleport_cooldown": 8.0,
		"teleport_range": 128.0,
	},
	EliteAffix.EXPLOSIVE: {
		"name": "Explosive",
		"color_tint": Color(1.0, 0.5, 0.0),
		"explosion_radius": 64.0,
		"explosion_damage_percent": 0.5,  # 50% of max HP as damage
	},
	EliteAffix.FROZEN: {
		"name": "Frozen",
		"color_tint": Color(0.4, 0.7, 1.0),
		"slow_aura_radius": 80.0,
		"slow_percent": 0.3,
	},
	EliteAffix.POISONOUS: {
		"name": "Poisonous",
		"color_tint": Color(0.3, 0.8, 0.2),
		"trail_damage": 5.0,
		"trail_duration": 3.0,
		"trail_interval": 1.0,
	},
	EliteAffix.BERSERKER: {
		"name": "Berserker",
		"color_tint": Color(0.9, 0.2, 0.2),
		"threshold": 0.3,  # 30% HP alatt
		"damage_mult": 2.0,
		"speed_mult": 1.5,
	},
}


## Roll random affix-eket egy enemy-hoz
static func roll_affixes(count: int = 1) -> Array[int]:
	var all_affixes: Array[int] = []
	for affix in EliteAffix.values():
		all_affixes.append(affix)
	
	all_affixes.shuffle()
	var result: Array[int] = []
	for i in mini(count, all_affixes.size()):
		result.append(all_affixes[i])
	return result


## Affix config lekérése
static func get_affix_config(affix: int) -> Dictionary:
	return AFFIX_CONFIG.get(affix, {})


## Affix név
static func get_affix_name(affix: int) -> String:
	var config := get_affix_config(affix)
	return config.get("name", "Unknown")


## Affix szín
static func get_affix_color(affix: int) -> Color:
	var config := get_affix_config(affix)
	return config.get("color_tint", Color.WHITE)


## Elite név generálás (pl. "Shielded Vampiric Skeleton")
static func get_elite_name(base_name: String, affixes: Array[int]) -> String:
	var prefix := ""
	for affix in affixes:
		prefix += get_affix_name(affix) + " "
	return prefix + base_name

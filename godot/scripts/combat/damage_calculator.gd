## DamageCalculator - Sebzés kalkuláció és combat math
## Kezelés: armor reduction, crit, resist, status effect damage
class_name DamageCalculator
extends RefCounted

## Sebzés kiszámítása
static func calculate_damage(
	base_damage: float,
	target_armor: float,
	damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL,
	crit_chance: float = 0.0,
	crit_multiplier: float = 1.5,
	bonus_multiplier: float = 1.0,
	elemental_resistance: float = 0.0
) -> Dictionary:
	var is_crit: bool = randf() < crit_chance
	var raw_damage: float = base_damage * bonus_multiplier
	
	if is_crit:
		raw_damage *= crit_multiplier
	
	# Armor reduction (fizikai és true damage kezelés)
	var final_damage: float
	if damage_type == Enums.DamageType.TRUE_DAMAGE:
		final_damage = raw_damage
	else:
		var armor_reduction: float = target_armor * Constants.ARMOR_EFFECTIVENESS
		final_damage = maxf(raw_damage - armor_reduction, Constants.MIN_DAMAGE)
	
	# Elemental resistance alkalmazása (nem fizikai és nem true damage esetén)
	if damage_type != Enums.DamageType.PHYSICAL and damage_type != Enums.DamageType.TRUE_DAMAGE:
		if elemental_resistance > 0.0:
			var resist_mult: float = 1.0 - clampf(elemental_resistance / 100.0, 0.0, 0.75)
			final_damage *= resist_mult
	
	return {
		"damage": int(final_damage),
		"is_crit": is_crit,
		"damage_type": damage_type,
		"raw_damage": int(raw_damage),
		"resisted": int(raw_damage - final_damage) if elemental_resistance > 0.0 else 0,
	}


## Enemy stat scaling szint alapján
static func scale_enemy_stat(base_value: float, enemy_level: int, growth_rate: float) -> float:
	return base_value * (1.0 + (enemy_level - 1) * growth_rate)


## Enemy HP scaling szint alapján
static func scale_hp(base_hp: int, enemy_level: int) -> int:
	return int(scale_enemy_stat(base_hp, enemy_level, 0.15))


## Enemy damage scaling szint alapján
static func scale_damage(base_damage: int, enemy_level: int) -> int:
	return int(scale_enemy_stat(base_damage, enemy_level, 0.12))


## Enemy armor scaling szint alapján
static func scale_armor(base_armor: int, enemy_level: int) -> int:
	return int(scale_enemy_stat(base_armor, enemy_level, 0.10))


## XP reward scaling
static func scale_xp(base_xp: int, enemy_level: int) -> int:
	return int(scale_enemy_stat(base_xp, enemy_level, 0.20))


## Boss HP multiplayer scaling
static func boss_hp_multiplier(player_count: int) -> float:
	match player_count:
		1: return 1.0
		2: return 1.8
		3: return 2.5
		4: return 3.2
		_: return 1.0

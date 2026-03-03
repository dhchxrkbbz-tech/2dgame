## MountainAI - Mountain enemy-k specifikus viselkedése
## Mountain Goat (charger), Rock Elemental (brute), Harpy (ranged), Yeti (brute frost)
class_name MountainAI
extends RefCounted


## Mountain Goat patterns (charger)
static func setup_goat_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Ram attack
	var ram := AttackPattern.create_charge_attack()
	ram.attack_name = "Ram Charge"
	ram.charge_distance = 96.0
	ram.charge_speed = 250.0
	patterns.append(ram)
	
	# Headbutt
	var butt := AttackPattern.create_melee_basic()
	butt.attack_name = "Headbutt"
	butt.damage_multiplier = 1.2
	butt.knockback_force = 60.0
	patterns.append(butt)
	
	return patterns


## Harpy patterns (ranged, wind)
static func setup_harpy_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Wind gust
	var gust := AttackPattern.new()
	gust.attack_name = "Wind Gust"
	gust.attack_id = "wind_gust"
	gust.damage_multiplier = 1.0
	gust.cooldown = 2.0
	gust.attack_range = 224.0
	gust.is_projectile = true
	gust.projectile_speed = 160.0
	gust.knockback_force = 40.0
	patterns.append(gust)
	
	# Dive bomb (charge from range)
	var dive := AttackPattern.new()
	dive.attack_name = "Dive Bomb"
	dive.attack_id = "dive_bomb"
	dive.damage_multiplier = 1.8
	dive.cooldown = 8.0
	dive.attack_range = 160.0
	dive.is_charge = true
	dive.charge_speed = 300.0
	dive.charge_distance = 160.0
	dive.knockback_force = 80.0
	dive.priority = 2
	patterns.append(dive)
	
	return patterns


## Yeti patterns (brute frost)
static func setup_yeti_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Frost smash
	var smash := AttackPattern.create_heavy_strike()
	smash.attack_name = "Frost Smash"
	smash.damage_type = Enums.DamageType.FROST
	smash.damage_multiplier = 2.0
	smash.applies_effect = true
	smash.effect_type = Enums.EffectType.SLOW
	smash.effect_duration = 2.0
	smash.effect_value = 40.0
	patterns.append(smash)
	
	# Ice breath (cone)
	var breath := AttackPattern.new()
	breath.attack_name = "Ice Breath"
	breath.attack_id = "ice_breath"
	breath.damage_multiplier = 1.0
	breath.damage_type = Enums.DamageType.FROST
	breath.cooldown = 8.0
	breath.attack_range = 80.0
	breath.telegraph_time = 0.8
	breath.area_type = AttackPattern.AreaType.CONE
	breath.area_size = Vector2(80, 60)
	breath.applies_effect = true
	breath.effect_type = Enums.EffectType.FREEZE
	breath.effect_duration = 1.0
	breath.priority = 3
	patterns.append(breath)
	
	return patterns


## Mountain Bandit patterns (sniper)
static func setup_bandit_sniper_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Sniper shot
	var sniper := AttackPattern.create_sniper_shot()
	patterns.append(sniper)
	
	# Quick shot (fallback)
	var quick := AttackPattern.create_arrow_shot()
	quick.attack_name = "Quick Shot"
	quick.damage_multiplier = 0.7
	quick.cooldown = 1.5
	patterns.append(quick)
	
	return patterns

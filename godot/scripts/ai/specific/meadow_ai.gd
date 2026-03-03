## MeadowAI - Starting Meadow enemy-k specifikus viselkedése
## Forest Slime (swarmer), Wild Boar (charger), Bandit, Bandit Archer, Rabid Wolf
class_name MeadowAI
extends RefCounted


## Forest Slime patterns (swarmer, egyszerű)
static func setup_slime_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Slime bump
	var bump := AttackPattern.new()
	bump.attack_name = "Slime Bump"
	bump.attack_id = "slime_bump"
	bump.damage_multiplier = 0.7
	bump.cooldown = 2.0
	bump.attack_range = 24.0
	patterns.append(bump)
	
	return patterns


## Wild Boar patterns (charger)
static func setup_boar_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Charge attack
	var charge := AttackPattern.create_charge_attack()
	charge.attack_name = "Boar Rush"
	charge.damage_multiplier = 1.3
	charge.charge_distance = 96.0
	charge.charge_speed = 250.0
	patterns.append(charge)
	
	# Gore
	var gore := AttackPattern.create_melee_basic()
	gore.attack_name = "Gore"
	gore.damage_multiplier = 1.0
	patterns.append(gore)
	
	return patterns


## Bandit patterns (melee daggers)
static func setup_bandit_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Dagger slash
	var slash := AttackPattern.create_melee_basic()
	slash.attack_name = "Dagger Slash"
	slash.damage_multiplier = 0.9
	slash.cooldown = 1.2
	patterns.append(slash)
	
	# Backstab (higher damage)
	var backstab := AttackPattern.new()
	backstab.attack_name = "Backstab"
	backstab.attack_id = "backstab"
	backstab.damage_multiplier = 1.8
	backstab.cooldown = 5.0
	backstab.attack_range = 28.0
	backstab.priority = 2
	patterns.append(backstab)
	
	return patterns


## Bandit Archer patterns (ranged)
static func setup_bandit_archer_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Arrow shot
	var arrow := AttackPattern.create_arrow_shot()
	arrow.attack_name = "Bandit Arrow"
	patterns.append(arrow)
	
	return patterns


## Rabid Wolf patterns (melee, poison bite)
static func setup_wolf_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Rabid bite
	var bite := AttackPattern.create_bite()
	bite.attack_name = "Rabid Bite"
	bite.effect_type = Enums.EffectType.POISON_DOT
	bite.effect_duration = 3.0
	bite.effect_value = 2.0
	patterns.append(bite)
	
	# Pounce
	var pounce := AttackPattern.new()
	pounce.attack_name = "Pounce"
	pounce.attack_id = "pounce"
	pounce.damage_multiplier = 1.3
	pounce.cooldown = 4.0
	pounce.attack_range = 48.0
	pounce.is_charge = true
	pounce.charge_speed = 200.0
	pounce.charge_distance = 48.0
	pounce.priority = 1
	patterns.append(pounce)
	
	return patterns

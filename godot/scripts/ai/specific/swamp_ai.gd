## SwampAI - Mocsári enemy-k specifikus viselkedése
## Swamp Lurker (grab), Toxic Frog (poison spit), Vine Creeper (root), Bog Witch (heal)
class_name SwampAI
extends RefCounted


## Swamp Lurker patterns (melee + grab)
static func setup_lurker_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Claw swipe
	var claw := AttackPattern.create_melee_basic()
	claw.attack_name = "Claw Swipe"
	claw.damage_multiplier = 1.1
	patterns.append(claw)
	
	# Grab (root + damage)
	var grab := AttackPattern.new()
	grab.attack_name = "Swamp Grab"
	grab.attack_id = "swamp_grab"
	grab.damage_multiplier = 0.8
	grab.cooldown = 6.0
	grab.attack_range = 48.0
	grab.applies_effect = true
	grab.effect_type = Enums.EffectType.ROOT
	grab.effect_duration = 1.5
	grab.priority = 2
	patterns.append(grab)
	
	return patterns


## Toxic Frog patterns (ranged poison)
static func setup_frog_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Poison spit
	var spit := AttackPattern.create_poison_spit()
	spit.attack_name = "Toxic Spit"
	patterns.append(spit)
	
	# Tongue lash (közelre kerülve)
	var tongue := AttackPattern.new()
	tongue.attack_name = "Tongue Lash"
	tongue.attack_id = "tongue_lash"
	tongue.damage_multiplier = 0.5
	tongue.cooldown = 3.0
	tongue.attack_range = 64.0
	tongue.applies_effect = true
	tongue.effect_type = Enums.EffectType.SLOW
	tongue.effect_duration = 1.0
	tongue.effect_value = 30.0
	patterns.append(tongue)
	
	return patterns


## Vine Creeper patterns (root specialist)
static func setup_vine_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Vine lash
	var lash := AttackPattern.new()
	lash.attack_name = "Vine Lash"
	lash.attack_id = "vine_lash"
	lash.damage_multiplier = 0.8
	lash.cooldown = 1.5
	lash.attack_range = 48.0
	patterns.append(lash)
	
	# Root entangle
	var root_atk := AttackPattern.new()
	root_atk.attack_name = "Entangle"
	root_atk.attack_id = "entangle"
	root_atk.damage_multiplier = 0.3
	root_atk.cooldown = 5.0
	root_atk.attack_range = 48.0
	root_atk.telegraph_time = 0.5
	root_atk.applies_effect = true
	root_atk.effect_type = Enums.EffectType.ROOT
	root_atk.effect_duration = 2.5
	root_atk.priority = 3
	patterns.append(root_atk)
	
	return patterns


## Bog Witch patterns (healer caster)
static func setup_bog_witch_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Heal beam
	var heal := AttackPattern.create_heal_beam()
	heal.attack_name = "Bog Mending"
	patterns.append(heal)
	
	# Poison bolt
	var bolt := AttackPattern.new()
	bolt.attack_name = "Swamp Bolt"
	bolt.attack_id = "swamp_bolt"
	bolt.damage_multiplier = 1.0
	bolt.damage_type = Enums.DamageType.POISON
	bolt.cooldown = 3.0
	bolt.attack_range = 256.0
	bolt.is_projectile = true
	bolt.projectile_speed = 110.0
	bolt.applies_effect = true
	bolt.effect_type = Enums.EffectType.POISON_DOT
	bolt.effect_duration = 3.0
	bolt.effect_value = 3.0
	patterns.append(bolt)
	
	return patterns

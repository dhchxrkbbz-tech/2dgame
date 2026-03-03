## PlagueAI - Plague Lands enemy-k specifikus viselkedése
## Plague Zombie (swarmer), Plague Rat (swarmer), Abomination (brute), Plague Doctor (caster)
class_name PlagueAI
extends RefCounted


## Plague Zombie patterns (swarmer, lassú, mérgező)
static func setup_zombie_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Infected bite
	var bite := AttackPattern.create_bite()
	bite.attack_name = "Infected Bite"
	bite.effect_type = Enums.EffectType.POISON_DOT
	bite.effect_duration = 5.0
	bite.effect_value = 4.0
	patterns.append(bite)
	
	return patterns


## Plague Rat patterns (swarmer, gyors, méreg)
static func setup_rat_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Plague bite
	var bite := AttackPattern.new()
	bite.attack_name = "Plague Bite"
	bite.attack_id = "plague_bite"
	bite.damage_multiplier = 0.6
	bite.cooldown = 1.0
	bite.attack_range = 24.0
	bite.applies_effect = true
	bite.effect_type = Enums.EffectType.POISON_DOT
	bite.effect_duration = 3.0
	bite.effect_value = 2.0
	patterns.append(bite)
	
	return patterns


## Abomination patterns (brute, AoE slam)
static func setup_abomination_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Smash
	var smash := AttackPattern.create_heavy_strike()
	smash.attack_name = "Abomination Smash"
	smash.damage_multiplier = 2.5
	smash.knockback_force = 150.0
	patterns.append(smash)
	
	# Ground slam AoE
	var slam := AttackPattern.new()
	slam.attack_name = "Plague Slam"
	slam.attack_id = "plague_slam"
	slam.damage_multiplier = 1.5
	slam.damage_type = Enums.DamageType.POISON
	slam.cooldown = 8.0
	slam.attack_range = 56.0
	slam.min_range = 0.0
	slam.telegraph_time = 1.2
	slam.area_type = AttackPattern.AreaType.CIRCLE
	slam.area_size = Vector2(56, 56)
	slam.applies_effect = true
	slam.effect_type = Enums.EffectType.POISON_DOT
	slam.effect_duration = 4.0
	slam.effect_value = 6.0
	slam.priority = 3
	patterns.append(slam)
	
	# Vomit (cone AoE)
	var vomit := AttackPattern.new()
	vomit.attack_name = "Plague Vomit"
	vomit.attack_id = "plague_vomit"
	vomit.damage_multiplier = 1.0
	vomit.damage_type = Enums.DamageType.POISON
	vomit.cooldown = 6.0
	vomit.attack_range = 64.0
	vomit.telegraph_time = 0.5
	vomit.area_type = AttackPattern.AreaType.CONE
	vomit.area_size = Vector2(64, 60)  # range, angle degrees
	vomit.applies_effect = true
	vomit.effect_type = Enums.EffectType.SLOW
	vomit.effect_duration = 2.0
	vomit.effect_value = 40.0
	vomit.priority = 2
	patterns.append(vomit)
	
	return patterns


## Plague Doctor patterns (healer + poison caster)
static func setup_doctor_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Heal
	var heal := AttackPattern.create_heal_beam()
	heal.attack_name = "Dark Medicine"
	heal.heal_percent = 0.20
	patterns.append(heal)
	
	# Plague bolt
	var bolt := AttackPattern.new()
	bolt.attack_name = "Plague Bolt"
	bolt.attack_id = "plague_bolt"
	bolt.damage_multiplier = 1.2
	bolt.damage_type = Enums.DamageType.POISON
	bolt.cooldown = 3.0
	bolt.attack_range = 256.0
	bolt.is_projectile = true
	bolt.projectile_speed = 120.0
	bolt.applies_effect = true
	bolt.effect_type = Enums.EffectType.POISON_DOT
	bolt.effect_duration = 5.0
	bolt.effect_value = 5.0
	patterns.append(bolt)
	
	# Plague cloud (AoE)
	var cloud := AttackPattern.new()
	cloud.attack_name = "Plague Cloud"
	cloud.attack_id = "plague_cloud"
	cloud.damage_multiplier = 0.5
	cloud.damage_type = Enums.DamageType.POISON
	cloud.cooldown = 12.0
	cloud.attack_range = 224.0
	cloud.telegraph_time = 1.0
	cloud.area_type = AttackPattern.AreaType.CIRCLE
	cloud.area_size = Vector2(80, 80)
	cloud.applies_effect = true
	cloud.effect_type = Enums.EffectType.POISON_DOT
	cloud.effect_duration = 6.0
	cloud.effect_value = 3.0
	cloud.priority = 2
	patterns.append(cloud)
	
	# Buff allies
	var buff := AttackPattern.create_buff_allies()
	buff.attack_name = "Dark Enhancement"
	patterns.append(buff)
	
	return patterns

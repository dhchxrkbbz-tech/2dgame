## AshlandsAI - Ashlands enemy-k specifikus viselkedése
## Flame Imp (swarmer), Fire Elemental (caster), Ash Golem (brute), Magma Worm (ranged), Infernal Knight
class_name AshlandsAI
extends RefCounted


## Flame Imp patterns (swarmer, tüzes)
static func setup_imp_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Fire scratch
	var scratch := AttackPattern.new()
	scratch.attack_name = "Fire Scratch"
	scratch.attack_id = "fire_scratch"
	scratch.damage_multiplier = 0.7
	scratch.damage_type = Enums.DamageType.ARCANE
	scratch.cooldown = 1.0
	scratch.attack_range = 24.0
	scratch.applies_effect = true
	scratch.effect_type = Enums.EffectType.BURN_DOT
	scratch.effect_duration = 2.0
	scratch.effect_value = 2.0
	patterns.append(scratch)
	
	return patterns


## Magma Worm patterns (ranged spitter)
static func setup_worm_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Lava spit
	var spit := AttackPattern.new()
	spit.attack_name = "Lava Spit"
	spit.attack_id = "lava_spit"
	spit.damage_multiplier = 1.0
	spit.damage_type = Enums.DamageType.ARCANE
	spit.cooldown = 2.5
	spit.attack_range = 224.0
	spit.is_projectile = true
	spit.projectile_speed = 100.0
	spit.projectile_aoe_radius = 40.0
	spit.applies_effect = true
	spit.effect_type = Enums.EffectType.BURN_DOT
	spit.effect_duration = 3.0
	spit.effect_value = 5.0
	patterns.append(spit)
	
	# Magma burst (AoE)
	var burst := AttackPattern.new()
	burst.attack_name = "Magma Burst"
	burst.attack_id = "magma_burst"
	burst.damage_multiplier = 1.5
	burst.damage_type = Enums.DamageType.ARCANE
	burst.cooldown = 8.0
	burst.attack_range = 192.0
	burst.telegraph_time = 1.0
	burst.area_type = AttackPattern.AreaType.CIRCLE
	burst.area_size = Vector2(56, 56)
	burst.applies_effect = true
	burst.effect_type = Enums.EffectType.BURN_DOT
	burst.effect_duration = 4.0
	burst.effect_value = 4.0
	burst.priority = 2
	patterns.append(burst)
	
	return patterns


## Ash Golem patterns (brute)
static func setup_ash_golem_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Ash slam
	var slam := AttackPattern.create_heavy_strike()
	slam.attack_name = "Ash Slam"
	slam.damage_multiplier = 2.2
	slam.knockback_force = 120.0
	patterns.append(slam)
	
	# Ember cloud (self AoE)
	var cloud := AttackPattern.new()
	cloud.attack_name = "Ember Cloud"
	cloud.attack_id = "ember_cloud"
	cloud.damage_multiplier = 0.8
	cloud.damage_type = Enums.DamageType.ARCANE
	cloud.cooldown = 10.0
	cloud.attack_range = 64.0
	cloud.min_range = 0.0
	cloud.telegraph_time = 0.8
	cloud.area_type = AttackPattern.AreaType.CIRCLE
	cloud.area_size = Vector2(64, 64)
	cloud.applies_effect = true
	cloud.effect_type = Enums.EffectType.BURN_DOT
	cloud.effect_duration = 3.0
	cloud.effect_value = 5.0
	cloud.priority = 2
	patterns.append(cloud)
	
	return patterns


## Infernal Knight patterns (melee + fire)
static func setup_infernal_knight_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Flame slash
	var slash := AttackPattern.new()
	slash.attack_name = "Flame Slash"
	slash.attack_id = "flame_slash"
	slash.damage_multiplier = 1.3
	slash.damage_type = Enums.DamageType.ARCANE
	slash.cooldown = 1.5
	slash.attack_range = 36.0
	slash.applies_effect = true
	slash.effect_type = Enums.EffectType.BURN_DOT
	slash.effect_duration = 3.0
	slash.effect_value = 3.0
	patterns.append(slash)
	
	# Flame cleave (telegraphed AoE)
	var cleave := AttackPattern.new()
	cleave.attack_name = "Flame Cleave"
	cleave.attack_id = "flame_cleave"
	cleave.damage_multiplier = 2.0
	cleave.damage_type = Enums.DamageType.ARCANE
	cleave.cooldown = 6.0
	cleave.attack_range = 48.0
	cleave.telegraph_time = 0.6
	cleave.area_type = AttackPattern.AreaType.CONE
	cleave.area_size = Vector2(48, 90)
	cleave.applies_effect = true
	cleave.effect_type = Enums.EffectType.BURN_DOT
	cleave.effect_duration = 4.0
	cleave.effect_value = 4.0
	cleave.priority = 2
	patterns.append(cleave)
	
	return patterns

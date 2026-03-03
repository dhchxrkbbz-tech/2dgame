## ElementalAI - Elementál enemy-k specifikus viselkedése
## Fire Elemental, Ice Golem, Rock Elemental, stb.
class_name ElementalAI
extends RefCounted


## Fire Elemental attack pattern-ek
static func setup_fire_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Fireball
	var fireball := AttackPattern.create_fireball()
	patterns.append(fireball)
	
	# Fire nova (self AoE)
	var nova := AttackPattern.new()
	nova.attack_name = "Fire Nova"
	nova.attack_id = "fire_nova"
	nova.damage_multiplier = 1.0
	nova.damage_type = Enums.DamageType.ARCANE
	nova.cooldown = 10.0
	nova.attack_range = 80.0
	nova.min_range = 0.0
	nova.telegraph_time = 0.8
	nova.area_type = AttackPattern.AreaType.CIRCLE
	nova.area_size = Vector2(80, 80)
	nova.applies_effect = true
	nova.effect_type = Enums.EffectType.BURN_DOT
	nova.effect_duration = 3.0
	nova.effect_value = 4.0
	nova.priority = 2
	patterns.append(nova)
	
	return patterns


## Frost Mage attack pattern-ek
static func setup_frost_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Ice bolt
	var ice_bolt := AttackPattern.new()
	ice_bolt.attack_name = "Ice Bolt"
	ice_bolt.attack_id = "ice_bolt"
	ice_bolt.damage_multiplier = 1.0
	ice_bolt.damage_type = Enums.DamageType.FROST
	ice_bolt.cooldown = 2.5
	ice_bolt.attack_range = 256.0
	ice_bolt.is_projectile = true
	ice_bolt.projectile_speed = 140.0
	ice_bolt.applies_effect = true
	ice_bolt.effect_type = Enums.EffectType.SLOW
	ice_bolt.effect_duration = 2.0
	ice_bolt.effect_value = 30.0
	patterns.append(ice_bolt)
	
	# Frost Nova
	var frost_nova := AttackPattern.create_frost_nova()
	patterns.append(frost_nova)
	
	# Blizzard AoE (target based)
	var blizzard := AttackPattern.new()
	blizzard.attack_name = "Blizzard"
	blizzard.attack_id = "blizzard"
	blizzard.damage_multiplier = 0.6
	blizzard.damage_type = Enums.DamageType.FROST
	blizzard.cooldown = 12.0
	blizzard.attack_range = 256.0
	blizzard.telegraph_time = 1.2
	blizzard.area_type = AttackPattern.AreaType.CIRCLE
	blizzard.area_size = Vector2(96, 96)
	blizzard.applies_effect = true
	blizzard.effect_type = Enums.EffectType.SLOW
	blizzard.effect_duration = 3.0
	blizzard.effect_value = 50.0
	blizzard.priority = 2
	patterns.append(blizzard)
	
	return patterns


## Rock Elemental attack pattern-ek
static func setup_rock_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Rock slam
	var slam := AttackPattern.create_heavy_strike()
	slam.attack_name = "Rock Slam"
	slam.damage_multiplier = 2.5
	slam.knockback_force = 120.0
	patterns.append(slam)
	
	# Ground Pound (AoE)
	var stomp := AttackPattern.new()
	stomp.attack_name = "Ground Pound"
	stomp.attack_id = "ground_pound"
	stomp.damage_multiplier = 1.5
	stomp.cooldown = 8.0
	stomp.attack_range = 64.0
	stomp.min_range = 0.0
	stomp.telegraph_time = 1.0
	stomp.area_type = AttackPattern.AreaType.CIRCLE
	stomp.area_size = Vector2(64, 64)
	stomp.applies_effect = true
	stomp.effect_type = Enums.EffectType.STUN
	stomp.effect_duration = 0.5
	stomp.priority = 2
	patterns.append(stomp)
	
	return patterns


## Ice Golem attack pattern-ek
static func setup_ice_golem_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Frozen slam
	var slam := AttackPattern.create_heavy_strike()
	slam.attack_name = "Frozen Slam"
	slam.damage_type = Enums.DamageType.FROST
	slam.damage_multiplier = 2.0
	slam.applies_effect = true
	slam.effect_type = Enums.EffectType.SLOW
	slam.effect_duration = 2.0
	slam.effect_value = 40.0
	patterns.append(slam)
	
	# Frost shockwave
	var shockwave := AttackPattern.new()
	shockwave.attack_name = "Frost Shockwave"
	shockwave.attack_id = "frost_shockwave"
	shockwave.damage_multiplier = 1.2
	shockwave.damage_type = Enums.DamageType.FROST
	shockwave.cooldown = 10.0
	shockwave.attack_range = 72.0
	shockwave.min_range = 0.0
	shockwave.telegraph_time = 1.5
	shockwave.area_type = AttackPattern.AreaType.CIRCLE
	shockwave.area_size = Vector2(72, 72)
	shockwave.applies_effect = true
	shockwave.effect_type = Enums.EffectType.FREEZE
	shockwave.effect_duration = 1.5
	shockwave.priority = 3
	patterns.append(shockwave)
	
	return patterns

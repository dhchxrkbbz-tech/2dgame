## FrozenAI - Frozen Wastes enemy-k specifikus viselkedése  
## Ice Wolf, Frost Mage, Ice Golem, Snow Wraith, Frozen Revenant
class_name FrozenAI
extends RefCounted


## Ice Wolf patterns (charger + frost)
static func setup_ice_wolf_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Frost bite
	var bite := AttackPattern.create_bite()
	bite.attack_name = "Frost Bite"
	bite.damage_type = Enums.DamageType.FROST
	bite.effect_type = Enums.EffectType.SLOW
	bite.effect_duration = 2.0
	bite.effect_value = 30.0
	patterns.append(bite)
	
	# Ice pounce
	var pounce := AttackPattern.create_charge_attack()
	pounce.attack_name = "Ice Pounce"
	pounce.damage_type = Enums.DamageType.FROST
	pounce.charge_speed = 260.0
	pounce.charge_distance = 80.0
	patterns.append(pounce)
	
	return patterns


## Snow Wraith patterns (caster - blizzard aura)
static func setup_snow_wraith_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Frost bolt
	var bolt := AttackPattern.new()
	bolt.attack_name = "Frost Bolt"
	bolt.attack_id = "frost_bolt"
	bolt.damage_multiplier = 1.0
	bolt.damage_type = Enums.DamageType.FROST
	bolt.cooldown = 2.5
	bolt.attack_range = 224.0
	bolt.is_projectile = true
	bolt.projectile_speed = 130.0
	bolt.applies_effect = true
	bolt.effect_type = Enums.EffectType.SLOW
	bolt.effect_duration = 2.0
	bolt.effect_value = 25.0
	patterns.append(bolt)
	
	# Blizzard aura (self AoE)
	var blizzard := AttackPattern.new()
	blizzard.attack_name = "Blizzard Aura"
	blizzard.attack_id = "blizzard_aura"
	blizzard.damage_multiplier = 0.4
	blizzard.damage_type = Enums.DamageType.FROST
	blizzard.cooldown = 10.0
	blizzard.attack_range = 80.0
	blizzard.min_range = 0.0
	blizzard.telegraph_time = 0.5
	blizzard.area_type = AttackPattern.AreaType.CIRCLE
	blizzard.area_size = Vector2(80, 80)
	blizzard.applies_effect = true
	blizzard.effect_type = Enums.EffectType.SLOW
	blizzard.effect_duration = 3.0
	blizzard.effect_value = 40.0
	blizzard.priority = 2
	patterns.append(blizzard)
	
	return patterns


## Frozen Revenant patterns (melee + slow)
static func setup_revenant_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Frozen slash
	var slash := AttackPattern.new()
	slash.attack_name = "Frozen Slash"
	slash.attack_id = "frozen_slash"
	slash.damage_multiplier = 1.1
	slash.damage_type = Enums.DamageType.FROST
	slash.cooldown = 1.8
	slash.attack_range = 32.0
	slash.applies_effect = true
	slash.effect_type = Enums.EffectType.SLOW
	slash.effect_duration = 1.5
	slash.effect_value = 20.0
	patterns.append(slash)
	
	# Frozen grip
	var grip := AttackPattern.new()
	grip.attack_name = "Frozen Grip"
	grip.attack_id = "frozen_grip"
	grip.damage_multiplier = 0.6
	grip.damage_type = Enums.DamageType.FROST
	grip.cooldown = 7.0
	grip.attack_range = 36.0
	grip.applies_effect = true
	grip.effect_type = Enums.EffectType.FREEZE
	grip.effect_duration = 1.0
	grip.priority = 2
	patterns.append(grip)
	
	return patterns

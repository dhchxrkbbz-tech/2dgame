## ForestAI - Cursed Forest enemy-k specifikus viselkedése
## Giant Spider, Poison Archer, Dark Witch, Shadow Wolf, Corrupted Treant
class_name ForestAI
extends RefCounted


## Poison Archer patterns (ranged, poison)
static func setup_poison_archer_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Poison arrow
	var arrow := AttackPattern.new()
	arrow.attack_name = "Poison Arrow"
	arrow.attack_id = "poison_arrow"
	arrow.damage_multiplier = 0.8
	arrow.cooldown = 2.0
	arrow.attack_range = 224.0
	arrow.is_projectile = true
	arrow.projectile_speed = 180.0
	arrow.applies_effect = true
	arrow.effect_type = Enums.EffectType.POISON_DOT
	arrow.effect_duration = 4.0
	arrow.effect_value = 3.0
	patterns.append(arrow)
	
	# Poison volley
	var volley := AttackPattern.new()
	volley.attack_name = "Poison Volley"
	volley.attack_id = "poison_volley"
	volley.damage_multiplier = 0.5
	volley.cooldown = 6.0
	volley.attack_range = 192.0
	volley.is_projectile = true
	volley.projectile_speed = 150.0
	volley.projectile_aoe_radius = 40.0
	volley.applies_effect = true
	volley.effect_type = Enums.EffectType.POISON_DOT
	volley.effect_duration = 5.0
	volley.effect_value = 4.0
	volley.priority = 2
	patterns.append(volley)
	
	return patterns


## Dark Witch patterns (caster - enchanter/debuff)
static func setup_dark_witch_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Curse
	var curse := AttackPattern.create_curse()
	patterns.append(curse)
	
	# Shadow bolt
	var bolt := AttackPattern.new()
	bolt.attack_name = "Shadow Bolt"
	bolt.attack_id = "shadow_bolt"
	bolt.damage_multiplier = 1.3
	bolt.damage_type = Enums.DamageType.SHADOW
	bolt.cooldown = 2.5
	bolt.attack_range = 256.0
	bolt.is_projectile = true
	bolt.projectile_speed = 130.0
	patterns.append(bolt)
	
	# Buff allies
	var buff := AttackPattern.create_buff_allies()
	buff.attack_name = "Dark Empowerment"
	patterns.append(buff)
	
	# Hex (slow + damage down)
	var hex := AttackPattern.new()
	hex.attack_name = "Hex"
	hex.attack_id = "hex"
	hex.damage_multiplier = 0.0
	hex.damage_type = Enums.DamageType.SHADOW
	hex.cooldown = 12.0
	hex.attack_range = 192.0
	hex.applies_effect = true
	hex.effect_type = Enums.EffectType.SLOW
	hex.effect_duration = 3.0
	hex.effect_value = 30.0
	hex.priority = 3
	patterns.append(hex)
	
	return patterns


## Shadow Wolf patterns (charger - fast + dark)
static func setup_shadow_wolf_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Shadow pounce
	var pounce := AttackPattern.create_charge_attack()
	pounce.attack_name = "Shadow Pounce"
	pounce.damage_type = Enums.DamageType.SHADOW
	pounce.charge_speed = 280.0
	pounce.charge_distance = 96.0
	patterns.append(pounce)
	
	# Dark bite
	var bite := AttackPattern.create_bite()
	bite.attack_name = "Dark Bite"
	bite.damage_type = Enums.DamageType.SHADOW
	bite.effect_type = Enums.EffectType.BLEED_DOT
	bite.effect_duration = 3.0
	bite.effect_value = 3.0
	patterns.append(bite)
	
	return patterns


## Corrupted Treant patterns (brute - tanky + AoE)
static func setup_treant_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Branch smash
	var smash := AttackPattern.create_heavy_strike()
	smash.attack_name = "Branch Smash"
	smash.damage_multiplier = 2.0
	smash.knockback_force = 100.0
	patterns.append(smash)
	
	# Root burst (AoE root)
	var roots := AttackPattern.new()
	roots.attack_name = "Root Burst"
	roots.attack_id = "root_burst"
	roots.damage_multiplier = 0.5
	roots.cooldown = 10.0
	roots.attack_range = 64.0
	roots.min_range = 0.0
	roots.telegraph_time = 1.0
	roots.area_type = AttackPattern.AreaType.CIRCLE
	roots.area_size = Vector2(64, 64)
	roots.applies_effect = true
	roots.effect_type = Enums.EffectType.ROOT
	roots.effect_duration = 2.0
	roots.priority = 3
	patterns.append(roots)
	
	return patterns

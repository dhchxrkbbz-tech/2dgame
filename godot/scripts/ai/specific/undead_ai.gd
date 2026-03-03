## UndeadAI - Undead enemy-k specifikus viselkedése
## Wraith (necromancer), Ghost (phase), Death Knight (curse)
class_name UndeadAI
extends RefCounted


## Wraith patterns (necromancer - summon + dark magic)
static func setup_wraith_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Summon skeleton
	var summon := AttackPattern.create_summon_minion()
	summon.attack_name = "Raise Dead"
	summon.summon_count = 2
	summon.summon_enemy_id = "skeleton_warrior"
	patterns.append(summon)
	
	# Dark bolt
	var bolt := AttackPattern.new()
	bolt.attack_name = "Dark Bolt"
	bolt.attack_id = "dark_bolt"
	bolt.damage_multiplier = 1.2
	bolt.damage_type = Enums.DamageType.SHADOW
	bolt.cooldown = 2.5
	bolt.attack_range = 256.0
	bolt.is_projectile = true
	bolt.projectile_speed = 120.0
	patterns.append(bolt)
	
	# Life drain (vampiric bolt)
	var drain := AttackPattern.new()
	drain.attack_name = "Life Drain"
	drain.attack_id = "life_drain"
	drain.damage_multiplier = 0.8
	drain.damage_type = Enums.DamageType.SHADOW
	drain.cooldown = 8.0
	drain.attack_range = 192.0
	drain.is_heal = true
	drain.heal_percent = 0.10
	drain.priority = 2
	patterns.append(drain)
	
	return patterns


## Ghost patterns (phase through walls, arcane damage)
static func setup_ghost_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Spectral touch
	var touch := AttackPattern.new()
	touch.attack_name = "Spectral Touch"
	touch.attack_id = "spectral_touch"
	touch.damage_multiplier = 1.3
	touch.damage_type = Enums.DamageType.SHADOW
	touch.cooldown = 2.0
	touch.attack_range = 32.0
	touch.applies_effect = true
	touch.effect_type = Enums.EffectType.SLOW
	touch.effect_duration = 1.5
	touch.effect_value = 20.0
	patterns.append(touch)
	
	# Terror (AoE fear/slow)
	var terror := AttackPattern.new()
	terror.attack_name = "Terror"
	terror.attack_id = "terror"
	terror.damage_multiplier = 0.5
	terror.damage_type = Enums.DamageType.SHADOW
	terror.cooldown = 10.0
	terror.attack_range = 64.0
	terror.min_range = 0.0
	terror.telegraph_time = 0.6
	terror.area_type = AttackPattern.AreaType.CIRCLE
	terror.area_size = Vector2(64, 64)
	terror.applies_effect = true
	terror.effect_type = Enums.EffectType.SLOW
	terror.effect_duration = 3.0
	terror.effect_value = 40.0
	terror.priority = 2
	patterns.append(terror)
	
	return patterns


## Death Knight patterns (strong melee + curse)
static func setup_death_knight_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Cursed strike
	var strike := AttackPattern.new()
	strike.attack_name = "Cursed Strike"
	strike.attack_id = "cursed_strike"
	strike.damage_multiplier = 1.5
	strike.damage_type = Enums.DamageType.SHADOW
	strike.cooldown = 1.8
	strike.attack_range = 36.0
	strike.applies_effect = true
	strike.effect_type = Enums.EffectType.DAMAGE_DOWN
	strike.effect_duration = 4.0
	strike.effect_value = 15.0
	patterns.append(strike)
	
	# Death's embrace (heavy + stun)
	var embrace := AttackPattern.create_heavy_strike()
	embrace.attack_name = "Death's Embrace"
	embrace.damage_type = Enums.DamageType.SHADOW
	embrace.damage_multiplier = 2.5
	embrace.cooldown = 8.0
	embrace.telegraph_time = 1.0
	embrace.priority = 3
	patterns.append(embrace)
	
	# Dark aura (self AoE curse)
	var aura := AttackPattern.create_curse()
	aura.attack_name = "Death Aura"
	aura.cooldown = 15.0
	aura.attack_range = 96.0
	aura.min_range = 0.0
	aura.area_type = AttackPattern.AreaType.CIRCLE
	aura.area_size = Vector2(96, 96)
	aura.priority = 1
	patterns.append(aura)
	
	return patterns


## Animated Armor (brute melee)
static func setup_armor_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Heavy sword swing
	var swing := AttackPattern.create_heavy_strike()
	swing.attack_name = "Heavy Swing"
	swing.damage_multiplier = 1.8
	patterns.append(swing)
	
	# Shield charge
	var charge := AttackPattern.create_charge_attack()
	charge.attack_name = "Shield Charge"
	charge.damage_multiplier = 1.2
	charge.charge_distance = 96.0
	charge.charge_speed = 200.0
	charge.cooldown = 8.0
	charge.priority = 2
	patterns.append(charge)
	
	return patterns

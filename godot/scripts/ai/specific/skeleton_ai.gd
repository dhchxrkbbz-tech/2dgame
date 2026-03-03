## SkeletonAI - Skeleton specifikus viselkedés
## Skeleton warrior (melee) és skeleton archer (ranged) AI
class_name SkeletonAI
extends RefCounted


## Skeleton Warrior attack pattern-ek
static func setup_warrior_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Sword slash
	var slash := AttackPattern.create_melee_basic()
	slash.attack_name = "Bone Slash"
	slash.damage_multiplier = 1.0
	patterns.append(slash)
	
	# Shield bash (stun)
	var bash := AttackPattern.new()
	bash.attack_name = "Shield Bash"
	bash.attack_id = "shield_bash"
	bash.damage_multiplier = 0.7
	bash.cooldown = 6.0
	bash.attack_range = 32.0
	bash.applies_effect = true
	bash.effect_type = Enums.EffectType.STUN
	bash.effect_duration = 1.0
	bash.knockback_force = 60.0
	bash.priority = 2
	patterns.append(bash)
	
	return patterns


## Skeleton Archer attack pattern-ek
static func setup_archer_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Arrow shot
	var arrow := AttackPattern.create_arrow_shot()
	arrow.attack_name = "Bone Arrow"
	patterns.append(arrow)
	
	# Multi-shot (3 nyíl szórva)
	var multi := AttackPattern.new()
	multi.attack_name = "Bone Volley"
	multi.attack_id = "bone_volley"
	multi.damage_multiplier = 0.6
	multi.cooldown = 5.0
	multi.attack_range = 224.0
	multi.is_projectile = true
	multi.projectile_speed = 180.0
	multi.priority = 1
	patterns.append(multi)
	
	return patterns

## SpiderAI - Giant Spider specifikus viselkedés
## Web shot (root), mérgezett harapás, wall-climbing illúzió
class_name SpiderAI
extends RefCounted

## Spider attack pattern-ek beállítása
static func setup_patterns(enemy: EnemyBase) -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	
	# Mérgezett harapás
	var bite := AttackPattern.create_bite()
	bite.attack_name = "Venomous Bite"
	bite.effect_value = 5.0  # Erősebb poison
	patterns.append(bite)
	
	# Web shot (root)
	var web := AttackPattern.create_web_shot()
	patterns.append(web)
	
	return patterns


## Spider-specifikus BT módosítások
static func customize_bt(enemy: EnemyBase, root: BehaviourTree.BTNode) -> void:
	# Spider extra: web shot -> melee combo
	pass  # Alap melee BT jó a spider-nek, a web shot pattern kezeli az extra logikát

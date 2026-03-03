## BTBuilder - Behaviour Tree felépítés enemy típus alapján
## Melee, Ranged, Caster, Swarmer, Brute, Charger specifikus BT struktúrák
class_name BTBuilder
extends RefCounted


## Teljes BT felépítés az enemy típus és sub-típus alapján
static func build_tree(enemy: EnemyBase) -> BehaviourTree.BTNode:
	var category: Enums.EnemyType = Enums.EnemyType.MELEE
	var sub_type: int = 0
	
	if enemy.enemy_data:
		category = enemy.enemy_data.enemy_category
		sub_type = enemy.enemy_data.sub_type
	
	match category:
		Enums.EnemyType.RANGED:
			return _build_ranged_tree(enemy, sub_type)
		Enums.EnemyType.CASTER:
			return _build_caster_tree(enemy, sub_type)
		_:
			# Melee + sub-típusok
			match sub_type:
				1:  # Charger
					return _build_charger_tree(enemy)
				2:  # Brute
					return _build_brute_tree(enemy)
				3:  # Swarmer
					return _build_swarmer_tree(enemy)
				_:
					return _build_melee_tree(enemy)


# ============================================================
#  MELEE BT
# ============================================================

static func _build_melee_tree(enemy: EnemyBase) -> BehaviourTree.BTNode:
	## ROOT (Selector)
	## ├── DEAD_CHECK
	## ├── LEASH
	## ├── RETREAT (hp < 20%, 50% esély)
	## ├── ATTACK (in range + cooldown ready)
	## ├── CHASE (target detected)
	## ├── PATROL
	## └── IDLE
	
	var root := BehaviourTree.BTSelector.new()
	
	# Dead check
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_is_dead))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_dead_action))
	)
	
	# Leash
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_should_leash))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_leash_action))
	)
	
	# Retreat
	var retreat_chance := BehaviourTree.BTRandomChance.new(0.5)
	retreat_chance.add_child_node(BehaviourTree.BTAction.new(enemy._bt_retreat_action))
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_should_retreat))
		.add_child_node(retreat_chance)
	)
	
	# Attack
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_attack))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_attack_action))
	)
	
	# Chase
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_has_target))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_chase_action))
	)
	
	# Patrol
	root.add_child_node(BehaviourTree.BTAction.new(enemy._bt_patrol_action))
	
	return root


# ============================================================
#  CHARGER BT
# ============================================================

static func _build_charger_tree(enemy: EnemyBase) -> BehaviourTree.BTNode:
	## ROOT (Selector)
	## ├── DEAD_CHECK
	## ├── LEASH
	## ├── CHARGE_ATTACK (target in charge range + cooldown)
	## ├── ATTACK (melee range)
	## ├── CHASE
	## ├── PATROL
	## └── IDLE
	
	var root := BehaviourTree.BTSelector.new()
	
	# Dead check
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_is_dead))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_dead_action))
	)
	
	# Leash
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_should_leash))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_leash_action))
	)
	
	# Charge attack (távolabbi range-ből)
	var charge_cd := BehaviourTree.BTCooldown.new(5.0)
	charge_cd.add_child_node(BehaviourTree.BTAction.new(enemy._bt_charge_attack_action))
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_charge))
		.add_child_node(charge_cd)
	)
	
	# Melee attack
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_attack))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_attack_action))
	)
	
	# Chase
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_has_target))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_chase_action))
	)
	
	# Patrol
	root.add_child_node(BehaviourTree.BTAction.new(enemy._bt_patrol_action))
	
	return root


# ============================================================
#  BRUTE BT
# ============================================================

static func _build_brute_tree(enemy: EnemyBase) -> BehaviourTree.BTNode:
	## ROOT (Selector)
	## ├── DEAD_CHECK
	## ├── LEASH
	## ├── HEAVY_ATTACK (közelben + cooldown ready)
	## ├── ATTACK (alap melee)
	## ├── CHASE (lassabb)
	## ├── PATROL
	## └── IDLE
	
	var root := BehaviourTree.BTSelector.new()
	
	# Dead check
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_is_dead))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_dead_action))
	)
	
	# Leash
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_should_leash))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_leash_action))
	)
	
	# Heavy attack (telegraphed)
	var heavy_cd := BehaviourTree.BTCooldown.new(3.0)
	heavy_cd.add_child_node(BehaviourTree.BTAction.new(enemy._bt_heavy_attack_action))
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_attack))
		.add_child_node(heavy_cd)
	)
	
	# Normal attack
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_attack))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_attack_action))
	)
	
	# Chase
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_has_target))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_chase_action))
	)
	
	# Patrol
	root.add_child_node(BehaviourTree.BTAction.new(enemy._bt_patrol_action))
	
	return root


# ============================================================
#  SWARMER BT
# ============================================================

static func _build_swarmer_tree(enemy: EnemyBase) -> BehaviourTree.BTNode:
	## ROOT (Selector)
	## ├── DEAD_CHECK
	## ├── LEASH
	## ├── ATTACK (agresszív, rövid cooldown)
	## ├── SWARM_CHASE (boids mozgás + pack)
	## ├── SWARM_IDLE
	## └── IDLE
	
	var root := BehaviourTree.BTSelector.new()
	
	# Dead check
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_is_dead))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_dead_action))
	)
	
	# Leash
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_should_leash))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_leash_action))
	)
	
	# Attack (gyors)
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_attack))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_attack_action))
	)
	
	# Swarm chase
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_has_target))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_swarm_chase_action))
	)
	
	# Patrol
	root.add_child_node(BehaviourTree.BTAction.new(enemy._bt_patrol_action))
	
	return root


# ============================================================
#  RANGED BT
# ============================================================

static func _build_ranged_tree(enemy: EnemyBase, sub_type: int) -> BehaviourTree.BTNode:
	## ROOT (Selector)
	## ├── DEAD_CHECK
	## ├── LEASH
	## ├── TOO_CLOSE_RETREAT (target < 3 tile → hátrálás)
	## ├── ATTACK (range-be + LOS + cooldown)
	## ├── REPOSITION (nincs LOS → pozíció keresés)
	## ├── CHASE (desired distance tartás)
	## ├── PATROL
	## └── IDLE
	
	var root := BehaviourTree.BTSelector.new()
	
	# Dead check
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_is_dead))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_dead_action))
	)
	
	# Leash
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_should_leash))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_leash_action))
	)
	
	# Too close retreat
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_target_too_close))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_retreat_from_target))
	)
	
	# Ranged attack (sniper needs telegraph)
	if sub_type == 4:  # Sniper
		var sniper_attack := BehaviourTree.BTCooldown.new(5.0)
		sniper_attack.add_child_node(BehaviourTree.BTAction.new(enemy._bt_sniper_attack_action))
		root.add_child_node(BehaviourTree.BTSequence.new()
			.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_ranged_attack))
			.add_child_node(sniper_attack)
		)
	else:
		root.add_child_node(BehaviourTree.BTSequence.new()
			.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_ranged_attack))
			.add_child_node(BehaviourTree.BTAction.new(enemy._bt_attack_action))
		)
	
	# Reposition (nincs LOS)
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_needs_reposition))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_reposition_action))
	)
	
	# Chase (desired distance-szel)
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_has_target))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_ranged_chase_action))
	)
	
	# Patrol
	root.add_child_node(BehaviourTree.BTAction.new(enemy._bt_patrol_action))
	
	return root


# ============================================================
#  CASTER BT
# ============================================================

static func _build_caster_tree(enemy: EnemyBase, sub_type: int) -> BehaviourTree.BTNode:
	## ROOT (Selector)
	## ├── DEAD_CHECK
	## ├── LEASH
	## ├── BUFF_ALLIES (ally in range + buff ready)
	## ├── HEAL_ALLIES (ally HP < 50% + heal ready) [healer only]
	## ├── SUMMON_MINIONS [necromancer only]
	## ├── CAST_SPELL (target in range + cooldown + telegraph)
	## ├── RETREAT_IF_CLOSE (target < 4 tile → blink/flee)
	## ├── FOLLOW_AT_DISTANCE
	## ├── PATROL
	## └── IDLE
	
	var root := BehaviourTree.BTSelector.new()
	
	# Dead check
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_is_dead))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_dead_action))
	)
	
	# Leash
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_should_leash))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_leash_action))
	)
	
	# Buff allies (enchanter típus prioritás)
	var buff_cd := BehaviourTree.BTCooldown.new(12.0)
	buff_cd.add_child_node(BehaviourTree.BTAction.new(enemy._bt_buff_allies_action))
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_buff_allies))
		.add_child_node(buff_cd)
	)
	
	# Heal allies (healer típus)
	var heal_cd := BehaviourTree.BTCooldown.new(8.0)
	heal_cd.add_child_node(BehaviourTree.BTAction.new(enemy._bt_heal_allies_action))
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_heal_allies))
		.add_child_node(heal_cd)
	)
	
	# Summon (necromancer típus)
	var summon_cd := BehaviourTree.BTCooldown.new(15.0)
	summon_cd.add_child_node(BehaviourTree.BTAction.new(enemy._bt_summon_action))
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_summon))
		.add_child_node(summon_cd)
	)
	
	# Cast spell
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_can_cast_spell))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_cast_spell_action))
	)
	
	# Retreat if close
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_target_too_close_caster))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_blink_away_action))
	)
	
	# Follow at distance
	root.add_child_node(BehaviourTree.BTSequence.new()
		.add_child_node(BehaviourTree.BTCondition.new(enemy._bt_has_target))
		.add_child_node(BehaviourTree.BTAction.new(enemy._bt_ranged_chase_action))
	)
	
	# Patrol
	root.add_child_node(BehaviourTree.BTAction.new(enemy._bt_patrol_action))
	
	return root

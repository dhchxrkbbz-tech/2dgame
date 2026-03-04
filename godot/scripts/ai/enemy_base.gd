## EnemyBase - Alap enemy osztály
## Minden enemy ebből származik: HP, mozgás, AI, combat
## Integrálja: DetectionSystem, AttackManager, BTBuilder
extends CharacterBody2D
class_name EnemyBase

# === Enemy adatok ===
var enemy_data: EnemyData
var enemy_level: int = 1

# === Aktuális statisztikák ===
var max_hp: int = 40
var current_hp: int = 40
var damage: int = 10
var armor: int = 3
var move_speed: float = 60.0
var attack_range: float = 32.0
var detection_range: float = 192.0

# === Állapot ===
var is_alive: bool = true
var is_attacking: bool = false
var can_act: bool = true
var spawn_position: Vector2 = Vector2.ZERO

# === AI state ===
enum AIState { IDLE, PATROL, ALERT, CHASE, ATTACK, RETREAT, LEASH, DEAD }
var ai_state: AIState = AIState.IDLE
var target: Node = null

# === Attack ===
var attack_cooldown: float = 0.0
var attack_timer: float = 0.0

# === Elite ===
var is_elite: bool = false
var elite_affixes: Array[String] = []

# === Patrol ===
var patrol_target: Vector2 = Vector2.ZERO
var patrol_timer: float = 0.0
const PATROL_INTERVAL: float = 4.0
const PATROL_RADIUS: float = 96.0

# === Ranged/Caster AI ===
var desired_distance: float = 128.0  # Kívánt tartási távolság ranged/caster-nek
var reposition_target: Vector2 = Vector2.ZERO
var _has_los: bool = true

# === Multiplayer scaling ===
var _player_count_modifier: float = 1.0

# === Node referenciák ===
var sprite: Sprite2D
var collision_shape: CollisionShape2D
var detection_area: Area2D
var nav_agent: NavigationAgent2D
var status_manager: StatusEffectManager
var health_bar: ProgressBar
var hitbox: HitboxComponent

# === Új rendszerek ===
var detection_system: DetectionSystem
var attack_mgr: AttackManager
var bt: BehaviourTree


func _ready() -> void:
	add_to_group("enemy")
	_create_nodes()
	_setup_stats()
	_setup_attack_patterns()
	_setup_bt()
	spawn_position = global_position
	
	# DetectionSystem inicializálás
	if detection_system:
		detection_system.setup(detection_range,
			enemy_data.leash_range if enemy_data else 960.0,
			global_position)
		detection_system.target_acquired.connect(_on_target_acquired)
		detection_system.target_lost.connect(_on_target_lost)


func _create_nodes() -> void:
	# Sprite
	sprite = Sprite2D.new()
	sprite.name = "Sprite"
	add_child(sprite)
	
	# Collision
	collision_shape = CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(20, 12)
	collision_shape.shape = shape
	collision_shape.position = Vector2(0, 4)
	add_child(collision_shape)
	
	# Collision layers: Enemy physics
	collision_layer = 1 << (Constants.LAYER_ENEMY_PHYSICS - 1)
	collision_mask = (1 << (Constants.LAYER_WALL - 1)) | (1 << (Constants.LAYER_PLAYER_PHYSICS - 1)) | (1 << (Constants.LAYER_ENEMY_PHYSICS - 1))
	
	# Detection Area
	detection_area = Area2D.new()
	detection_area.name = "DetectionArea"
	detection_area.collision_layer = 0
	detection_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	var detect_shape := CollisionShape2D.new()
	var detect_circle := CircleShape2D.new()
	detect_circle.radius = detection_range
	detect_shape.shape = detect_circle
	detection_area.add_child(detect_shape)
	add_child(detection_area)
	
	# DetectionSystem (Node-based)
	detection_system = DetectionSystem.new()
	detection_system.name = "DetectionSystem"
	add_child(detection_system)
	
	# Wire detection_area signals to detection_system
	detection_area.body_entered.connect(detection_system.on_body_entered)
	detection_area.body_exited.connect(detection_system.on_body_exited)
	
	# Hurtbox
	var hurtbox := Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.add_to_group("hurtbox")
	hurtbox.collision_layer = 1 << (Constants.LAYER_ENEMY_HURTBOX - 1)
	hurtbox.collision_mask = 1 << (Constants.LAYER_PLAYER_HITBOX - 1)
	var hurtbox_shape := CollisionShape2D.new()
	var hurtbox_rect := RectangleShape2D.new()
	hurtbox_rect.size = Vector2(24, 24)
	hurtbox_shape.shape = hurtbox_rect
	hurtbox.add_child(hurtbox_shape)
	add_child(hurtbox)
	
	# Hitbox
	hitbox = HitboxComponent.new()
	hitbox.name = "Hitbox"
	hitbox.collision_layer = 1 << (Constants.LAYER_ENEMY_HITBOX - 1)
	hitbox.collision_mask = 1 << (Constants.LAYER_PLAYER_HURTBOX - 1)
	var hitbox_shape := CollisionShape2D.new()
	var hitbox_rect := RectangleShape2D.new()
	hitbox_rect.size = Vector2(28, 28)
	hitbox_shape.shape = hitbox_rect
	hitbox_shape.position = Vector2(16, 0)
	hitbox.add_child(hitbox_shape)
	add_child(hitbox)
	
	# AttackManager (Node-based)
	attack_mgr = AttackManager.new()
	attack_mgr.name = "AttackManager"
	add_child(attack_mgr)
	attack_mgr.attack_started.connect(_on_attack_started)
	attack_mgr.attack_finished.connect(_on_attack_finished)
	
	# Status Effect Manager
	status_manager = StatusEffectManager.new()
	status_manager.name = "StatusEffectManager"
	add_child(status_manager)
	status_manager.dot_tick.connect(_on_dot_tick)
	
	# Health Bar (fejfölötti)
	var bar_container := Control.new()
	bar_container.name = "HealthBarContainer"
	bar_container.size = Vector2(32, 4)
	bar_container.position = Vector2(-16, -20)
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.size = Vector2(32, 4)
	health_bar.show_percentage = false
	health_bar.max_value = 100
	health_bar.value = 100
	var style_bg := StyleBoxFlat.new()
	style_bg.bg_color = Color(0.2, 0.2, 0.2)
	health_bar.add_theme_stylebox_override("background", style_bg)
	var style_fill := StyleBoxFlat.new()
	style_fill.bg_color = Color(0.8, 0.1, 0.1)
	health_bar.add_theme_stylebox_override("fill", style_fill)
	bar_container.add_child(health_bar)
	add_child(bar_container)
	
	# Navigation Agent
	nav_agent = NavigationAgent2D.new()
	nav_agent.name = "NavigationAgent"
	nav_agent.path_desired_distance = 4.0
	nav_agent.target_desired_distance = 4.0
	add_child(nav_agent)


func _setup_stats() -> void:
	if not enemy_data:
		return
	
	max_hp = enemy_data.get_scaled_hp(enemy_level)
	current_hp = max_hp
	damage = enemy_data.get_scaled_damage(enemy_level)
	armor = enemy_data.get_scaled_armor(enemy_level)
	move_speed = enemy_data.base_speed
	attack_range = enemy_data.attack_range
	detection_range = enemy_data.detection_range
	attack_cooldown = enemy_data.attack_speed
	
	# Desired distance ranged/caster
	if enemy_data.enemy_category == Enums.EnemyType.RANGED:
		desired_distance = attack_range * 0.7
	elif enemy_data.enemy_category == Enums.EnemyType.CASTER:
		desired_distance = attack_range * 0.6
	
	# Elite boosting
	if is_elite:
		max_hp = int(max_hp * 3.0)
		current_hp = max_hp
		damage = int(damage * 1.5)
		armor = int(armor * 2.0)
		move_speed *= 1.1
	
	# Multiplayer scaling
	_apply_multiplayer_scaling()
	
	# Hitbox damage
	hitbox.damage = damage
	
	# Health bar frissítés
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	
	# Sprite beállítás
	_setup_sprite()


func _setup_sprite() -> void:
	if enemy_data:
		sprite.texture = PlaceholderSprites.create_enemy_placeholder(
			enemy_data.enemy_category
		)
	else:
		var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
		img.fill(Color.RED)
		sprite.texture = ImageTexture.create_from_image(img)


## Attack pattern-ek betöltése az enemy_id alapján
func _setup_attack_patterns() -> void:
	if not enemy_data:
		return
	
	var patterns: Array[AttackPattern] = _get_patterns_for_enemy(enemy_data.enemy_id)
	if patterns.is_empty():
		# Fallback: alap pattern a kategória alapján
		patterns = _get_default_patterns()
	
	attack_mgr.setup_patterns(patterns)


## Enemy-specifikus pattern-ek lekérdezése
func _get_patterns_for_enemy(enemy_id: String) -> Array[AttackPattern]:
	match enemy_id:
		# === Starting Meadow ===
		"forest_slime": return MeadowAI.setup_slime_patterns()
		"wild_boar": return MeadowAI.setup_boar_patterns()
		"bandit": return MeadowAI.setup_bandit_patterns()
		"bandit_archer": return MeadowAI.setup_bandit_archer_patterns()
		"rabid_wolf": return MeadowAI.setup_wolf_patterns()
		# === Cursed Forest ===
		"poison_archer": return ForestAI.setup_poison_archer_patterns()
		"dark_witch": return ForestAI.setup_dark_witch_patterns()
		"shadow_wolf": return ForestAI.setup_shadow_wolf_patterns()
		"corrupted_treant": return ForestAI.setup_treant_patterns()
		"giant_spider": return SpiderAI.setup_spider_patterns()
		# === Dark Swamp ===
		"swamp_lurker": return SwampAI.setup_lurker_patterns()
		"toxic_frog": return SwampAI.setup_toxic_frog_patterns()
		"vine_creeper": return SwampAI.setup_vine_creeper_patterns()
		"bog_witch": return SwampAI.setup_bog_witch_patterns()
		# === Ruins ===
		"skeleton_warrior": return SkeletonAI.setup_warrior_patterns()
		"skeleton_archer": return SkeletonAI.setup_archer_patterns()
		"wraith": return UndeadAI.setup_wraith_patterns()
		"ghost": return UndeadAI.setup_ghost_patterns()
		"death_knight": return UndeadAI.setup_death_knight_patterns()
		"animated_armor": return UndeadAI.setup_animated_armor_patterns()
		# === Mountains ===
		"mountain_goat": return MountainAI.setup_mountain_goat_patterns()
		"harpy": return MountainAI.setup_harpy_patterns()
		"yeti": return MountainAI.setup_yeti_patterns()
		"mountain_bandit": return MountainAI.setup_mountain_bandit_patterns()
		# === Frozen Wastes ===
		"ice_wolf": return FrozenAI.setup_ice_wolf_patterns()
		"snow_wraith": return FrozenAI.setup_snow_wraith_patterns()
		"frozen_revenant": return FrozenAI.setup_frozen_revenant_patterns()
		# === Ashlands ===
		"flame_imp": return AshlandsAI.setup_flame_imp_patterns()
		"magma_worm": return AshlandsAI.setup_magma_worm_patterns()
		"ash_golem": return AshlandsAI.setup_ash_golem_patterns()
		"infernal_knight": return AshlandsAI.setup_infernal_knight_patterns()
		# === Plague Lands ===
		"plague_zombie": return PlagueAI.setup_plague_zombie_patterns()
		"plague_rat": return PlagueAI.setup_plague_rat_patterns()
		"abomination": return PlagueAI.setup_abomination_patterns()
		"plague_doctor": return PlagueAI.setup_plague_doctor_patterns()
		# === Elementals ===
		"fire_elemental": return ElementalAI.setup_fire_elemental_patterns()
		"frost_elemental": return ElementalAI.setup_frost_elemental_patterns()
		"rock_elemental": return ElementalAI.setup_rock_elemental_patterns()
		"ice_golem": return ElementalAI.setup_ice_golem_patterns()
	
	return []


## Default pattern-ek kategória alapján (fallback)
func _get_default_patterns() -> Array[AttackPattern]:
	var patterns: Array[AttackPattern] = []
	var category: Enums.EnemyType = enemy_data.enemy_category if enemy_data else Enums.EnemyType.MELEE
	
	match category:
		Enums.EnemyType.MELEE:
			patterns.append(AttackPattern.create_melee_basic())
		Enums.EnemyType.RANGED:
			patterns.append(AttackPattern.create_arrow_shot())
		Enums.EnemyType.CASTER:
			patterns.append(AttackPattern.create_fireball())
		_:
			patterns.append(AttackPattern.create_melee_basic())
	
	return patterns


## BT felépítés BTBuilder-en keresztül (típus-specifikus)
func _setup_bt() -> void:
	bt = BehaviourTree.new()
	bt.name = "BehaviourTree"
	add_child(bt)
	
	var root := BTBuilder.build_tree(self)
	bt.setup(root)


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# DetectionSystem frissítés
	if detection_system:
		detection_system.update(delta)
		target = detection_system.current_target
		
		# LOS cache
		if target and is_instance_valid(target):
			_has_los = detection_system.has_line_of_sight(target)
		else:
			_has_los = false
		
		# Sync AI state from detection state
		match detection_system.current_state:
			DetectionSystem.DetectionState.LEASH:
				ai_state = AIState.LEASH
			DetectionSystem.DetectionState.UNAWARE:
				if ai_state != AIState.PATROL:
					ai_state = AIState.IDLE
	
	# Status effect check
	if not status_manager.can_act():
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Speed modifier
	var speed_mod := 1.0 + status_manager.get_total_speed_modifier()
	if speed_mod <= 0:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Attack timer
	if attack_timer > 0:
		attack_timer -= delta
	
	# BT végrehajtás
	bt.execute(delta)
	
	# Sprite irány
	if velocity.x < -1:
		sprite.flip_h = true
	elif velocity.x > 1:
		sprite.flip_h = false
	
	move_and_slide()


# ============================================================
#  BT FELTÉTELEK (CONDITIONS) - Közös
# ============================================================

func _bt_is_dead(bb: Dictionary) -> bool:
	return not is_alive

func _bt_should_leash(bb: Dictionary) -> bool:
	if detection_system:
		return detection_system.current_state == DetectionSystem.DetectionState.LEASH
	return global_position.distance_to(spawn_position) > (enemy_data.leash_range if enemy_data else 960.0)

func _bt_should_retreat(bb: Dictionary) -> bool:
	return float(current_hp) / float(max_hp) < 0.2 and target != null

func _bt_can_attack(bb: Dictionary) -> bool:
	if not target or not is_instance_valid(target):
		return false
	if attack_mgr.is_attacking:
		return false
	var dist := global_position.distance_to(target.global_position)
	var pattern := attack_mgr.choose_attack(dist, _has_los)
	return pattern != null

func _bt_has_target(bb: Dictionary) -> bool:
	return target != null and is_instance_valid(target)

func _bt_can_charge(bb: Dictionary) -> bool:
	if not target or not is_instance_valid(target):
		return false
	var dist := global_position.distance_to(target.global_position)
	# Charge range: 3-6 tile távolság
	return dist >= 96.0 and dist <= 192.0 and not attack_mgr.is_attacking


# ============================================================
#  BT FELTÉTELEK - Ranged specifikus
# ============================================================

func _bt_target_too_close(bb: Dictionary) -> bool:
	if not target or not is_instance_valid(target):
		return false
	var dist := global_position.distance_to(target.global_position)
	return dist < 64.0  # 2 tile-nél közelebb

func _bt_can_ranged_attack(bb: Dictionary) -> bool:
	if not target or not is_instance_valid(target):
		return false
	if attack_mgr.is_attacking:
		return false
	if not _has_los:
		return false
	var dist := global_position.distance_to(target.global_position)
	return dist <= attack_range and attack_timer <= 0

func _bt_needs_reposition(bb: Dictionary) -> bool:
	if not target or not is_instance_valid(target):
		return false
	return not _has_los and ai_state == AIState.CHASE


# ============================================================
#  BT FELTÉTELEK - Caster specifikus
# ============================================================

func _bt_can_cast_spell(bb: Dictionary) -> bool:
	if not target or not is_instance_valid(target):
		return false
	if attack_mgr.is_attacking:
		return false
	var dist := global_position.distance_to(target.global_position)
	var pattern := attack_mgr.choose_attack(dist, _has_los)
	return pattern != null

func _bt_target_too_close_caster(bb: Dictionary) -> bool:
	if not target or not is_instance_valid(target):
		return false
	var dist := global_position.distance_to(target.global_position)
	return dist < 96.0  # 3 tile-nél közelebb

func _bt_can_buff_allies(bb: Dictionary) -> bool:
	if attack_mgr.is_attacking:
		return false
	# Van-e buff pattern és ally a közelben
	for pattern in attack_mgr.attack_patterns:
		if pattern.is_buff and pattern.is_ready():
			for enemy in get_tree().get_nodes_in_group("enemy"):
				if enemy != self and is_instance_valid(enemy) and enemy.is_alive:
					if global_position.distance_to(enemy.global_position) <= pattern.attack_range:
						return true
	return false

func _bt_can_heal_allies(bb: Dictionary) -> bool:
	if attack_mgr.is_attacking:
		return false
	for pattern in attack_mgr.attack_patterns:
		if pattern.is_heal and pattern.is_ready():
			for enemy in get_tree().get_nodes_in_group("enemy"):
				if enemy != self and is_instance_valid(enemy) and enemy.is_alive:
					if float(enemy.current_hp) / float(maxi(1, enemy.max_hp)) < 0.5:
						if global_position.distance_to(enemy.global_position) <= pattern.attack_range:
							return true
	return false

func _bt_can_summon(bb: Dictionary) -> bool:
	if attack_mgr.is_attacking:
		return false
	if attack_mgr.active_summons.size() >= attack_mgr.MAX_SUMMONS:
		return false
	for pattern in attack_mgr.attack_patterns:
		if pattern.is_summon and pattern.is_ready():
			return true
	return false


# ============================================================
#  BT AKCIÓK (ACTIONS) - Közös
# ============================================================

func _bt_dead_action(delta: float, bb: Dictionary) -> int:
	return BehaviourTree.BTStatus.SUCCESS

func _bt_leash_action(delta: float, bb: Dictionary) -> int:
	target = null
	if detection_system:
		detection_system.current_target = null
		detection_system.threat_table.clear()
	
	var dir := (spawn_position - global_position).normalized()
	velocity = dir * move_speed
	
	# HP regen leash közben
	current_hp = mini(current_hp + int(max_hp * 0.1 * delta), max_hp)
	_update_health_bar()
	
	if global_position.distance_to(spawn_position) < 16:
		ai_state = AIState.IDLE
		velocity = Vector2.ZERO
	return BehaviourTree.BTStatus.RUNNING

func _bt_retreat_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	var dir := (global_position - target.global_position).normalized()
	velocity = dir * move_speed
	ai_state = AIState.RETREAT
	return BehaviourTree.BTStatus.RUNNING

func _bt_attack_action(delta: float, bb: Dictionary) -> int:
	if attack_mgr.is_attacking:
		return BehaviourTree.BTStatus.RUNNING
	
	_perform_attack()
	return BehaviourTree.BTStatus.SUCCESS

func _bt_chase_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.CHASE
	var dir := (target.global_position - global_position).normalized()
	velocity = dir * move_speed * (1.0 + status_manager.get_total_speed_modifier())
	return BehaviourTree.BTStatus.RUNNING

func _bt_patrol_action(delta: float, bb: Dictionary) -> int:
	ai_state = AIState.PATROL
	patrol_timer -= delta
	
	if patrol_timer <= 0 or global_position.distance_to(patrol_target) < 8:
		patrol_timer = PATROL_INTERVAL + randf() * 2.0
		var angle := randf() * TAU
		patrol_target = spawn_position + Vector2(cos(angle), sin(angle)) * randf() * PATROL_RADIUS
	
	var dir := (patrol_target - global_position).normalized()
	velocity = dir * move_speed * 0.4
	return BehaviourTree.BTStatus.RUNNING


# ============================================================
#  BT AKCIÓK - Charger / Brute / Swarmer
# ============================================================

func _bt_charge_attack_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	# Charge pattern keresés
	var charge_pattern: AttackPattern = null
	for pattern in attack_mgr.attack_patterns:
		if pattern.is_charge and pattern.is_ready():
			charge_pattern = pattern
			break
	
	if not charge_pattern:
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.ATTACK
	attack_mgr.execute_attack(charge_pattern, target)
	return BehaviourTree.BTStatus.SUCCESS

func _bt_heavy_attack_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	# Nehéz ütés pattern (priority > 0 vagy is_charge nélküli, nagy damage)
	var heavy: AttackPattern = null
	for pattern in attack_mgr.attack_patterns:
		if not pattern.is_charge and not pattern.is_projectile and pattern.damage_multiplier >= 1.5 and pattern.is_ready():
			heavy = pattern
			break
	
	if not heavy:
		# Fallback: bármilyen attack
		return _bt_attack_action(delta, bb)
	
	ai_state = AIState.ATTACK
	attack_mgr.execute_attack(heavy, target)
	return BehaviourTree.BTStatus.SUCCESS

func _bt_swarm_chase_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.CHASE
	var dir := (target.global_position - global_position).normalized()
	
	# Boids-szerű mozgás: kis random offset + pack effect
	var jitter := Vector2(randf_range(-0.3, 0.3), randf_range(-0.3, 0.3))
	dir = (dir + jitter).normalized()
	
	# Más swarmer-ektől enyhe taszítás (ne rakódjanak egymásra)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy == self or not is_instance_valid(enemy) or not enemy.is_alive:
			continue
		var dist_to_ally := global_position.distance_to(enemy.global_position)
		if dist_to_ally < 20 and dist_to_ally > 0:
			var repel := (global_position - enemy.global_position).normalized()
			dir = (dir + repel * 0.3).normalized()
	
	# Swarmer-ek gyorsabbak chase közben
	velocity = dir * move_speed * 1.2 * (1.0 + status_manager.get_total_speed_modifier())
	return BehaviourTree.BTStatus.RUNNING


# ============================================================
#  BT AKCIÓK - Ranged specifikus
# ============================================================

func _bt_retreat_from_target(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.RETREAT
	var dir := (global_position - target.global_position).normalized()
	
	# Oldalra is mehet, ne csak hátra
	var side := Vector2(-dir.y, dir.x) * (1.0 if randf() > 0.5 else -1.0)
	dir = (dir + side * 0.4).normalized()
	
	velocity = dir * move_speed * (1.0 + status_manager.get_total_speed_modifier())
	return BehaviourTree.BTStatus.RUNNING

func _bt_sniper_attack_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	# Sniper: hosszabb telegraph + nagy damage
	var sniper_pattern: AttackPattern = null
	for pattern in attack_mgr.attack_patterns:
		if pattern.is_projectile and pattern.is_ready() and pattern.priority >= 2:
			sniper_pattern = pattern
			break
	
	if not sniper_pattern:
		# Fallback normál ranged
		return _bt_attack_action(delta, bb)
	
	ai_state = AIState.ATTACK
	velocity = Vector2.ZERO  # Sniper áll lövéskor
	attack_mgr.execute_attack(sniper_pattern, target)
	return BehaviourTree.BTStatus.SUCCESS

func _bt_reposition_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.CHASE
	
	# Keress pozíciót ahol van LOS
	if reposition_target == Vector2.ZERO or global_position.distance_to(reposition_target) < 16:
		# Próbálj 8 irányt - melyikben van LOS
		var best_pos := global_position
		var best_dist_to_target := INF
		
		for i in 8:
			var angle := float(i) * TAU / 8.0
			var test_pos := global_position + Vector2(cos(angle), sin(angle)) * 64.0
			
			# Egyszerű LOS check az új pozícióból
			var space := get_world_2d().direct_space_state
			if space:
				var query := PhysicsRayQueryParameters2D.create(test_pos, target.global_position)
				query.collision_mask = 1 << (Constants.LAYER_WALL - 1)
				var result := space.intersect_ray(query)
				if result.is_empty():
					var d := test_pos.distance_to(target.global_position)
					if abs(d - desired_distance) < abs(best_dist_to_target - desired_distance):
						best_pos = test_pos
						best_dist_to_target = d
		
		reposition_target = best_pos
	
	var dir := (reposition_target - global_position).normalized()
	velocity = dir * move_speed * (1.0 + status_manager.get_total_speed_modifier())
	return BehaviourTree.BTStatus.RUNNING

func _bt_ranged_chase_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.CHASE
	var dist := global_position.distance_to(target.global_position)
	var dir := (target.global_position - global_position).normalized()
	
	# Tartsd a kívánt távolságot
	if dist < desired_distance * 0.7:
		# Túl közel - hátrálj
		dir = -dir
	elif dist > desired_distance * 1.3:
		# Túl messze - közelíts
		pass  # dir marad target felé
	else:
		# Jó távolság - oldalra strafing
		dir = Vector2(-dir.y, dir.x) * (1.0 if randf() > 0.5 else -1.0)
	
	velocity = dir * move_speed * (1.0 + status_manager.get_total_speed_modifier())
	return BehaviourTree.BTStatus.RUNNING


# ============================================================
#  BT AKCIÓK - Caster specifikus
# ============================================================

func _bt_cast_spell_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	var dist := global_position.distance_to(target.global_position)
	var pattern := attack_mgr.choose_attack(dist, _has_los)
	
	if not pattern:
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.ATTACK
	velocity = Vector2.ZERO  # Caster áll kasztoláskor
	attack_mgr.execute_attack(pattern, target)
	return BehaviourTree.BTStatus.SUCCESS

func _bt_blink_away_action(delta: float, bb: Dictionary) -> int:
	if not target or not is_instance_valid(target):
		return BehaviourTree.BTStatus.FAILURE
	
	# Blink: teleportálás hátrébb
	var dir := (global_position - target.global_position).normalized()
	var blink_dist := 96.0 + randf() * 32.0
	var new_pos := global_position + dir * blink_dist
	
	# Falba ne teleportáljon
	var space := get_world_2d().direct_space_state
	if space:
		var query := PhysicsRayQueryParameters2D.create(global_position, new_pos)
		query.collision_mask = 1 << (Constants.LAYER_WALL - 1)
		var result := space.intersect_ray(query)
		if not result.is_empty():
			new_pos = result["position"] - dir * 16  # Fal előtt megáll
	
	# Visual: flash
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.1)
	tween.tween_callback(func(): global_position = new_pos)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	
	return BehaviourTree.BTStatus.SUCCESS

func _bt_buff_allies_action(delta: float, bb: Dictionary) -> int:
	# Buff pattern keresés
	var buff_pattern: AttackPattern = null
	for pattern in attack_mgr.attack_patterns:
		if pattern.is_buff and pattern.is_ready():
			buff_pattern = pattern
			break
	
	if not buff_pattern:
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.ATTACK
	velocity = Vector2.ZERO
	attack_mgr.execute_attack(buff_pattern, self)
	return BehaviourTree.BTStatus.SUCCESS

func _bt_heal_allies_action(delta: float, bb: Dictionary) -> int:
	var heal_pattern: AttackPattern = null
	for pattern in attack_mgr.attack_patterns:
		if pattern.is_heal and pattern.is_ready():
			heal_pattern = pattern
			break
	
	if not heal_pattern:
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.ATTACK
	velocity = Vector2.ZERO
	attack_mgr.execute_attack(heal_pattern, self)
	return BehaviourTree.BTStatus.SUCCESS

func _bt_summon_action(delta: float, bb: Dictionary) -> int:
	var summon_pattern: AttackPattern = null
	for pattern in attack_mgr.attack_patterns:
		if pattern.is_summon and pattern.is_ready():
			summon_pattern = pattern
			break
	
	if not summon_pattern:
		return BehaviourTree.BTStatus.FAILURE
	
	ai_state = AIState.ATTACK
	velocity = Vector2.ZERO
	attack_mgr.execute_attack(summon_pattern, self)
	return BehaviourTree.BTStatus.SUCCESS


# ============================================================
#  COMBAT
# ============================================================

func _perform_attack() -> void:
	if attack_mgr.is_attacking:
		return
	if not target or not is_instance_valid(target):
		return
	
	var dist := global_position.distance_to(target.global_position)
	var pattern := attack_mgr.choose_attack(dist, _has_los)
	
	if pattern:
		ai_state = AIState.ATTACK
		attack_mgr.execute_attack(pattern, target)
	else:
		# Fallback: régi melee hitbox
		is_attacking = true
		attack_timer = attack_cooldown
		var dmg_mod := 1.0 + status_manager.get_total_damage_modifier()
		hitbox.damage = int(damage * dmg_mod)
		if is_instance_valid(target):
			var dir := (target.global_position - global_position).normalized()
			if hitbox.get_child_count() > 0:
				hitbox.get_child(0).position = dir * 16
		hitbox.activate(0.2)
		var timer := get_tree().create_timer(0.3)
		timer.timeout.connect(func(): is_attacking = false)


func _on_attack_started(pattern: AttackPattern) -> void:
	is_attacking = true
	attack_timer = attack_cooldown


func _on_attack_finished(pattern: AttackPattern) -> void:
	is_attacking = false


# ============================================================
#  DAMAGE & HP
# ============================================================

func take_damage(amount: float, damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL) -> void:
	if not is_alive:
		return
	
	var total_armor := armor + int(status_manager.get_total_armor_modifier())
	var result := DamageCalculator.calculate_damage(amount, total_armor, damage_type)
	var final_damage: int = result["damage"]
	
	current_hp -= final_damage
	current_hp = maxi(current_hp, 0)
	
	# Damage number
	DamageNumber.spawn(self, global_position, final_damage, result["is_crit"], damage_type)
	
	# Aggro a támadóra (threat table)
	var attacker := _find_nearest_player()
	if attacker and detection_system:
		detection_system.add_threat(attacker, float(final_damage))
	elif attacker:
		target = attacker
		ai_state = AIState.CHASE
	
	_update_health_bar()
	
	# Flash effect
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.05)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	
	if current_hp <= 0:
		_die()


func apply_knockback(force: Vector2) -> void:
	velocity = force
	var timer := get_tree().create_timer(0.15)
	timer.timeout.connect(func(): velocity = Vector2.ZERO)


func heal(amount: int) -> void:
	if not is_alive:
		return
	current_hp = mini(current_hp + amount, max_hp)
	_update_health_bar()


func _on_dot_tick(dmg: float, effect_type: Enums.EffectType) -> void:
	var dtype := Enums.DamageType.PHYSICAL
	match effect_type:
		Enums.EffectType.POISON_DOT: dtype = Enums.DamageType.POISON
		Enums.EffectType.BURN_DOT: dtype = Enums.DamageType.ARCANE
		Enums.EffectType.BLEED_DOT: dtype = Enums.DamageType.BLOOD
	
	current_hp -= int(dmg)
	current_hp = maxi(current_hp, 0)
	DamageNumber.spawn(self, global_position, int(dmg), false, dtype)
	_update_health_bar()
	
	if current_hp <= 0:
		_die()


func _update_health_bar() -> void:
	if health_bar:
		health_bar.value = current_hp


func _die() -> void:
	is_alive = false
	can_act = false
	velocity = Vector2.ZERO
	ai_state = AIState.DEAD
	
	EventBus.entity_killed.emit(_find_nearest_player(), self)
	
	# XP reward
	if enemy_data:
		var xp := enemy_data.get_scaled_xp(enemy_level)
		if is_elite:
			xp *= 3
		for p in get_tree().get_nodes_in_group("player"):
			if p.has_method("gain_xp"):
				p.gain_xp(xp)
	
	# Loot drop
	_drop_loot()
	
	# Death animation (flash + shrink)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	tween.tween_property(self, "scale", Vector2(0.3, 0.3), 0.5)
	tween.tween_callback(queue_free)


func _drop_loot() -> void:
	if not enemy_data:
		return
	
	# Gold drop
	var gold := randi_range(enemy_data.gold_range.x, enemy_data.gold_range.y)
	if is_elite:
		gold *= 2
	
	if gold > 0:
		var gold_drop := DroppedItem.create_gold_drop(gold, global_position)
		if get_tree().current_scene:
			get_tree().current_scene.add_child(gold_drop)
	
	# Item drop: LootManager-en keresztül vagy alap generálás
	var drop_chance := 0.3  # 30% alap drop esély
	if is_elite:
		drop_chance = 0.8  # 80% elite drop esély
	
	if randf() < drop_chance:
		var item_data := ItemGenerator.generate_item(enemy_level, Enums.ItemType.WEAPON if randf() > 0.5 else Enums.ItemType.ARMOR, 0.0)
		if not item_data.is_empty():
			var item_instance := ItemInstance.new()
			item_instance.item_level = item_data.get("item_level", enemy_level)
			item_instance.rarity = item_data.get("rarity", Enums.Rarity.COMMON)
			item_instance.affixes = []
			for affix_dict in item_data.get("affixes", []):
				var affix := AffixData.new()
				affix.stat_type = affix_dict.get("type", "")
				affix.affix_name = affix_dict.get("type", "").capitalize()
				item_instance.affixes.append({"affix": affix, "value": affix_dict.get("value", 0.0)})
			
			var item_drop := DroppedItem.create_item_drop(item_instance, global_position)
			if get_tree().current_scene:
				get_tree().current_scene.add_child(item_drop)
	
	EventBus.item_dropped.emit({"type": "gold", "amount": gold}, global_position)


# ============================================================
#  DETECTION & ALERT
# ============================================================

func _on_target_acquired(new_target: Node) -> void:
	target = new_target
	ai_state = AIState.CHASE


func _on_target_lost() -> void:
	target = null
	ai_state = AIState.IDLE


## Alert hívás pack behavior-hez (más enemy hívhatja)
func alert(alert_position: Vector2) -> void:
	if not is_alive:
		return
	if detection_system and detection_system.current_state == DetectionSystem.DetectionState.UNAWARE:
		# Nézd meg van-e játékos arra
		var nearest := _find_nearest_player()
		if nearest and global_position.distance_to(nearest.global_position) <= detection_range * 1.5:
			detection_system._acquire_target(nearest)


func _find_nearest_player() -> Node:
	var nearest: Node = null
	var nearest_dist: float = INF
	for p in get_tree().get_nodes_in_group("player"):
		var dist := global_position.distance_to(p.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = p
	return nearest


# ============================================================
#  MULTIPLAYER SCALING
# ============================================================

func _apply_multiplayer_scaling() -> void:
	var player_count := get_tree().get_nodes_in_group("player").size()
	if player_count <= 1:
		_player_count_modifier = 1.0
		return
	
	# HP scaling: 1→1.0x, 2→1.5x, 3→2.0x, 4→2.5x
	var hp_mult := 1.0 + (player_count - 1) * 0.5
	max_hp = int(float(max_hp) * hp_mult)
	current_hp = max_hp
	_player_count_modifier = hp_mult


# ============================================================
#  INICIALIZÁLÁS
# ============================================================

func initialize(data: EnemyData, level: int, elite: bool = false) -> void:
	enemy_data = data
	enemy_level = level
	is_elite = elite
	if is_inside_tree():
		_setup_stats()
		_setup_attack_patterns()
		_setup_bt()
		if detection_system:
			detection_system.setup(detection_range,
				enemy_data.leash_range if enemy_data else 960.0,
				global_position)

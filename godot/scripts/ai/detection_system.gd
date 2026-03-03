## DetectionSystem - Enemy észlelés és aggro rendszer
## Line of sight, threat table, detection állapotok kezelése
class_name DetectionSystem
extends Node

signal target_acquired(target: Node)
signal target_lost()
signal state_changed(new_state: DetectionState)

enum DetectionState {
	UNAWARE,      # Nem lát játékost
	SUSPICIOUS,   # Játékos a határ szélén
	ALERT,        # Játékos detektálva
	CHASING,      # Üldözés
	LEASH,        # Túl messze a spawntól, visszatérés
}

var owner_entity: Node = null
var current_state: DetectionState = DetectionState.UNAWARE
var current_target: Node = null

# Config
var detection_range: float = 192.0  # 6 tile
var leash_range: float = 960.0  # 30 tile
var aggro_memory: float = 10.0
var suspicious_range_mult: float = 1.3  # detection_range * mult = suspicious range

# Timers
var aggro_timer: float = 0.0
var los_check_timer: float = 0.0
const LOS_CHECK_INTERVAL: float = 0.25

# Threat table (multiplayer aggro)
var threat_table: Dictionary = {}  # Node -> float

# Spawn point referencia
var spawn_position: Vector2 = Vector2.ZERO

# Wall collision layer
var wall_layer_mask: int = 1 << (Constants.LAYER_WALL - 1)


func _ready() -> void:
	owner_entity = get_parent()


func setup(p_detection_range: float, p_leash_range: float, p_spawn_pos: Vector2) -> void:
	detection_range = p_detection_range
	leash_range = p_leash_range
	spawn_position = p_spawn_pos


func update(delta: float) -> void:
	los_check_timer -= delta
	
	# Leash check
	if owner_entity.global_position.distance_to(spawn_position) > leash_range:
		_set_state(DetectionState.LEASH)
		current_target = null
		threat_table.clear()
		return
	
	# Aggro decay
	if current_target and not is_instance_valid(current_target):
		current_target = null
		threat_table.clear()
		_set_state(DetectionState.UNAWARE)
		return
	
	if current_target:
		aggro_timer -= delta
		
		# LOS check periódikusan
		if los_check_timer <= 0:
			los_check_timer = LOS_CHECK_INTERVAL
			if not has_line_of_sight(current_target):
				aggro_timer -= 2.0  # Gyorsabban felejt ha nincs LOS
		
		# Target távolság check
		var dist := owner_entity.global_position.distance_to(current_target.global_position)
		
		if dist <= detection_range:
			_set_state(DetectionState.ALERT)
			aggro_timer = aggro_memory
		elif dist <= detection_range * suspicious_range_mult:
			if current_state == DetectionState.ALERT:
				_set_state(DetectionState.CHASING)
		
		# Aggro lejárt - target elvesztése
		if aggro_timer <= 0:
			current_target = null
			threat_table.clear()
			_set_state(DetectionState.UNAWARE)
			target_lost.emit()
	else:
		# Játékosok keresése range-ben
		_scan_for_targets()


## Játékos detektálva (Detection Area callback)
func on_body_entered(body: Node) -> void:
	if not body.is_in_group("player"):
		return
	if not owner_entity.is_alive:
		return
	
	if has_line_of_sight(body):
		_acquire_target(body)
	else:
		# Nem lát rá közvetlenül, de gyanakszik
		if current_state == DetectionState.UNAWARE:
			_set_state(DetectionState.SUSPICIOUS)


func on_body_exited(body: Node) -> void:
	if body == current_target:
		aggro_timer = aggro_memory


## Line of sight check raycasting-gel
func has_line_of_sight(target_node: Node) -> bool:
	if not is_instance_valid(target_node) or not is_instance_valid(owner_entity):
		return false
	
	var space := owner_entity.get_world_2d().direct_space_state
	if not space:
		return false
	
	var query := PhysicsRayQueryParameters2D.create(
		owner_entity.global_position,
		target_node.global_position
	)
	query.exclude = [owner_entity.get_rid()]
	query.collision_mask = wall_layer_mask
	
	var result := space.intersect_ray(query)
	return result.is_empty()  # Nincs akadály = lát


## Threat hozzáadás (multiplayer aggro)
func add_threat(source: Node, amount: float) -> void:
	if not source.is_in_group("player"):
		return
	
	if source in threat_table:
		threat_table[source] += amount
	else:
		threat_table[source] = amount
	
	# Proximity bonus
	var dist := owner_entity.global_position.distance_to(source.global_position)
	if dist > 0:
		threat_table[source] += (1.0 / dist) * 10.0
	
	# Ha ez a legnagyobb threat → target switch
	_update_target_from_threat()


## Taunt (overwrite threat)
func taunt(source: Node) -> void:
	threat_table[source] = 1000.0
	_acquire_target(source)


func get_threat(source: Node) -> float:
	return threat_table.get(source, 0.0)


## Távolság a jelenlegi target-hoz
func get_target_distance() -> float:
	if current_target and is_instance_valid(current_target):
		return owner_entity.global_position.distance_to(current_target.global_position)
	return INF


## Távolság a spawn ponthoz
func get_spawn_distance() -> float:
	return owner_entity.global_position.distance_to(spawn_position)


# === Privát metódusok ===

func _scan_for_targets() -> void:
	var nearest: Node = null
	var nearest_dist: float = detection_range
	
	for player in owner_entity.get_tree().get_nodes_in_group("player"):
		if not is_instance_valid(player):
			continue
		
		var dist := owner_entity.global_position.distance_to(player.global_position)
		if dist <= detection_range and dist < nearest_dist:
			if has_line_of_sight(player):
				nearest = player
				nearest_dist = dist
	
	if nearest:
		_acquire_target(nearest)


func _acquire_target(new_target: Node) -> void:
	current_target = new_target
	aggro_timer = aggro_memory
	_set_state(DetectionState.ALERT)
	target_acquired.emit(new_target)
	
	# Alert nearby allies (pack behavior)
	for enemy in owner_entity.get_tree().get_nodes_in_group("enemy"):
		if enemy == owner_entity or not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(owner_entity.global_position) <= 160:
			if enemy.has_method("alert"):
				enemy.alert(new_target.global_position)
			elif "detection_system" in enemy and enemy.detection_system:
				if enemy.detection_system.current_state == DetectionState.UNAWARE:
					enemy.detection_system._acquire_target(new_target)


func _update_target_from_threat() -> void:
	# Clean invalid entries
	var to_remove: Array = []
	for source in threat_table:
		if not is_instance_valid(source):
			to_remove.append(source)
	for key in to_remove:
		threat_table.erase(key)
	
	# Highest threat = target
	var highest_threat: float = 0.0
	var best_target: Node = null
	
	for source in threat_table:
		if threat_table[source] > highest_threat:
			highest_threat = threat_table[source]
			best_target = source
	
	if best_target and best_target != current_target:
		current_target = best_target
		aggro_timer = aggro_memory


func _set_state(new_state: DetectionState) -> void:
	if current_state != new_state:
		current_state = new_state
		state_changed.emit(new_state)

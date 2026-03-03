## EnemySync - Enemy AI state szinkronizáció
## Host futtatja az AI-t, kliensek csak vizuális frissítést kapnak
extends Node

# --- Tracked enemies ---
var _synced_enemies: Dictionary = {}  # entity_id → { position, velocity, anim_state, hp_percent, target }
var _enemy_id_counter: int = 0

# --- Signals ---
signal enemy_spawned_remote(entity_id: int, enemy_type: Enums.EnemyType, position: Vector2, level: int)
signal enemy_position_updated(entity_id: int, position: Vector2, velocity: Vector2)
signal enemy_state_updated(entity_id: int, state: Dictionary)
signal enemy_died_remote(entity_id: int, position: Vector2)

func reset() -> void:
	_synced_enemies.clear()
	_enemy_id_counter = 0

# === Server Side ===

func server_register_enemy(enemy_node: Node, enemy_type: Enums.EnemyType, level: int) -> int:
	if not NetworkManager.is_server():
		return -1
	
	_enemy_id_counter += 1
	var entity_id = _enemy_id_counter
	
	_synced_enemies[entity_id] = {
		"node": enemy_node,
		"type": enemy_type,
		"level": level,
		"position": enemy_node.global_position,
		"velocity": Vector2.ZERO,
		"anim_state": "idle",
		"hp_percent": 1.0,
		"target_peer_id": -1,
	}
	
	enemy_node.set_meta("entity_id", entity_id)
	
	# Notify all clients about the new enemy
	_rpc_spawn_enemy.rpc(entity_id, enemy_type, enemy_node.global_position, level)
	
	return entity_id

func server_unregister_enemy(entity_id: int) -> void:
	if _synced_enemies.has(entity_id):
		var pos = _synced_enemies[entity_id]["position"]
		_synced_enemies.erase(entity_id)
		_rpc_enemy_died.rpc(entity_id, pos)

func server_broadcast_states() -> void:
	if not NetworkManager.is_server():
		return
	
	var batch: Dictionary = {}
	
	for entity_id in _synced_enemies:
		var data = _synced_enemies[entity_id]
		var node = data.get("node")
		
		if node == null or not is_instance_valid(node):
			continue
		
		# Update cached state from node
		data["position"] = node.global_position
		data["velocity"] = node.velocity if node is CharacterBody2D else Vector2.ZERO
		
		# Get animation state if available
		if node.has_method("get_animation_state"):
			data["anim_state"] = node.get_animation_state()
		
		# Get HP percent if available
		if node.has_method("get_hp_percent"):
			data["hp_percent"] = node.get_hp_percent()
		
		# Get target
		if node.has_method("get_target_peer_id"):
			data["target_peer_id"] = node.get_target_peer_id()
		
		batch[entity_id] = {
			"p": data["position"],
			"v": data["velocity"],
			"a": data["anim_state"],
			"h": data["hp_percent"],
			"t": data["target_peer_id"],
		}
	
	if batch.size() > 0:
		_rpc_enemy_batch_update.rpc(batch)

func server_enemy_hp_changed(entity_id: int, hp_percent: float) -> void:
	if _synced_enemies.has(entity_id):
		_synced_enemies[entity_id]["hp_percent"] = hp_percent
		_rpc_enemy_hp_update.rpc(entity_id, hp_percent)

func server_enemy_status_effect(entity_id: int, effects: Array) -> void:
	_rpc_enemy_status_effects.rpc(entity_id, effects)

# === RPCs ===

@rpc("authority", "reliable")
func _rpc_spawn_enemy(entity_id: int, enemy_type: Enums.EnemyType, position: Vector2, level: int) -> void:
	_synced_enemies[entity_id] = {
		"type": enemy_type,
		"level": level,
		"position": position,
		"velocity": Vector2.ZERO,
		"anim_state": "idle",
		"hp_percent": 1.0,
		"target_peer_id": -1,
		"snapshots": [],
	}
	enemy_spawned_remote.emit(entity_id, enemy_type, position, level)

@rpc("authority", "reliable")
func _rpc_enemy_died(entity_id: int, position: Vector2) -> void:
	enemy_died_remote.emit(entity_id, position)
	# Delay removal for death animation
	await get_tree().create_timer(1.0).timeout
	_synced_enemies.erase(entity_id)

@rpc("authority", "unreliable")
func _rpc_enemy_batch_update(batch: Dictionary) -> void:
	var current_time = Time.get_ticks_msec() / 1000.0
	
	for entity_id in batch:
		var data = batch[entity_id]
		
		if not _synced_enemies.has(entity_id):
			continue
		
		var enemy = _synced_enemies[entity_id]
		
		# Store snapshot for interpolation
		if not enemy.has("snapshots"):
			enemy["snapshots"] = []
		
		enemy["snapshots"].append({
			"timestamp": current_time,
			"position": data["p"],
			"velocity": data["v"],
		})
		
		# Keep last 10 snapshots
		while enemy["snapshots"].size() > 10:
			enemy["snapshots"].pop_front()
		
		enemy["anim_state"] = data["a"]
		enemy["hp_percent"] = data["h"]
		enemy["target_peer_id"] = data["t"]
		
		enemy_position_updated.emit(entity_id, data["p"], data["v"])
		enemy_state_updated.emit(entity_id, {
			"anim_state": data["a"],
			"hp_percent": data["h"],
			"target_peer_id": data["t"],
		})

@rpc("authority", "reliable")
func _rpc_enemy_hp_update(entity_id: int, hp_percent: float) -> void:
	if _synced_enemies.has(entity_id):
		_synced_enemies[entity_id]["hp_percent"] = hp_percent
		enemy_state_updated.emit(entity_id, {"hp_percent": hp_percent})

@rpc("authority", "reliable")
func _rpc_enemy_status_effects(entity_id: int, effects: Array) -> void:
	if _synced_enemies.has(entity_id):
		enemy_state_updated.emit(entity_id, {"status_effects": effects})

# === Interpolation ===

func get_interpolated_enemy_position(entity_id: int) -> Vector2:
	if not _synced_enemies.has(entity_id):
		return Vector2.ZERO
	
	var enemy = _synced_enemies[entity_id]
	var snapshots = enemy.get("snapshots", [])
	
	if snapshots.size() < 2:
		return enemy.get("position", Vector2.ZERO)
	
	var render_time = Time.get_ticks_msec() / 1000.0 - 0.1  # 100ms delay
	
	for i in range(snapshots.size() - 1, 0, -1):
		if snapshots[i - 1]["timestamp"] <= render_time and snapshots[i]["timestamp"] >= render_time:
			var t0 = snapshots[i - 1]["timestamp"]
			var t1 = snapshots[i]["timestamp"]
			var t = 0.0
			if t1 - t0 > 0:
				t = (render_time - t0) / (t1 - t0)
			return snapshots[i - 1]["position"].lerp(snapshots[i]["position"], t)
	
	return snapshots[-1]["position"]

func get_enemy_data(entity_id: int) -> Dictionary:
	return _synced_enemies.get(entity_id, {})

func get_all_synced_enemies() -> Dictionary:
	return _synced_enemies

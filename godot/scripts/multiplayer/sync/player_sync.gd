## PlayerSync - Player pozíció és state szinkronizáció
## Client prediction + Server authority
extends Node

# --- Tracked players ---
var _remote_players: Dictionary = {}  # peer_id → { position, velocity, facing, anim_state, snapshots }
var _local_input_buffer: Array[Dictionary] = []
var _input_sequence: int = 0

# --- Interpolation settings ---
const INTERPOLATION_DELAY: float = 0.1  # 100ms
const MAX_POSITION_ERROR: float = 5.0  # pixels before correction
const CORRECTION_LERP_SPEED: float = 10.0

# --- Signals ---
signal remote_player_position_updated(peer_id: int, position: Vector2)
signal remote_player_state_updated(peer_id: int, state: Dictionary)
signal position_corrected(server_pos: Vector2)

func _ready() -> void:
	pass

func reset() -> void:
	_remote_players.clear()
	_local_input_buffer.clear()
	_input_sequence = 0

# === Client Side ===

func client_send_input() -> void:
	if NetworkManager.is_server():
		return
	
	var input_vector = _get_input_vector()
	var timestamp = NetworkManager.get_server_time()
	
	# Store input for prediction reconciliation
	_input_sequence += 1
	_local_input_buffer.append({
		"sequence": _input_sequence,
		"input": input_vector,
		"timestamp": timestamp
	})
	
	# Keep buffer manageable (last 60 inputs = ~3 seconds)
	while _local_input_buffer.size() > 60:
		_local_input_buffer.pop_front()
	
	# Send to server
	_rpc_send_player_input.rpc_id(1, input_vector, _input_sequence, timestamp)

func apply_server_correction(server_pos: Vector2, server_sequence: int) -> void:
	# Remove acknowledged inputs
	while _local_input_buffer.size() > 0 and _local_input_buffer[0]["sequence"] <= server_sequence:
		_local_input_buffer.pop_front()
	
	# Check if correction needed
	var local_player = _get_local_player()
	if local_player == null:
		return
	
	var error = local_player.global_position.distance_to(server_pos)
	if error > MAX_POSITION_ERROR:
		# Snap to server position and replay unacknowledged inputs
		local_player.global_position = server_pos
		
		for input_data in _local_input_buffer:
			_apply_input_locally(local_player, input_data["input"])
		
		position_corrected.emit(server_pos)

# === Server Side ===

func server_broadcast_positions() -> void:
	if not NetworkManager.is_server():
		return
	
	var player_states: Dictionary = {}
	var players_node = get_tree().get_first_node_in_group("players_container")
	if players_node == null:
		return
	
	for player in players_node.get_children():
		if not player.has_meta("peer_id"):
			continue
		var peer_id = player.get_meta("peer_id")
		player_states[peer_id] = {
			"position": player.global_position,
			"velocity": player.velocity if player is CharacterBody2D else Vector2.ZERO,
			"facing": player.get("facing_direction") if player.get("facing_direction") != null else Vector2.DOWN,
		}
	
	if player_states.size() > 0:
		_rpc_broadcast_player_positions.rpc(player_states)

# === RPCs ===

@rpc("any_peer", "unreliable")
func _rpc_send_player_input(input_vector: Vector2, sequence: int, timestamp: float) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	var player = _get_player_by_peer_id(sender_id)
	if player == null:
		return
	
	# Server-side validation
	if input_vector.length() > 1.1:  # Allow small floating point error
		input_vector = input_vector.normalized()
	
	# Apply movement on server
	_apply_input_to_player(player, input_vector)
	
	# Send correction back to the sender
	_rpc_position_correction.rpc_id(sender_id, player.global_position, sequence)

@rpc("authority", "unreliable")
func _rpc_position_correction(server_pos: Vector2, sequence: int) -> void:
	apply_server_correction(server_pos, sequence)

@rpc("authority", "unreliable")
func _rpc_broadcast_player_positions(player_states: Dictionary) -> void:
	for peer_id in player_states:
		if peer_id == multiplayer.get_unique_id():
			continue  # Skip self
		
		var state = player_states[peer_id]
		
		# Store snapshot for interpolation
		if not _remote_players.has(peer_id):
			_remote_players[peer_id] = {"snapshots": []}
		
		_remote_players[peer_id]["snapshots"].append({
			"timestamp": Time.get_ticks_msec() / 1000.0,
			"position": state["position"],
			"velocity": state["velocity"],
			"facing": state["facing"],
		})
		
		# Keep last 20 snapshots
		while _remote_players[peer_id]["snapshots"].size() > 20:
			_remote_players[peer_id]["snapshots"].pop_front()
		
		remote_player_position_updated.emit(peer_id, state["position"])

# === Player Event RPCs ===

@rpc("authority", "reliable")
func _rpc_player_hp_update(peer_id: int, hp: int, max_hp: int) -> void:
	remote_player_state_updated.emit(peer_id, {"hp": hp, "max_hp": max_hp})

@rpc("authority", "reliable")
func _rpc_player_mana_update(peer_id: int, mana: int, max_mana: int) -> void:
	remote_player_state_updated.emit(peer_id, {"mana": mana, "max_mana": max_mana})

@rpc("authority", "reliable")
func _rpc_player_level_update(peer_id: int, level: int) -> void:
	remote_player_state_updated.emit(peer_id, {"level": level})

@rpc("authority", "reliable")
func _rpc_player_died(peer_id: int, position: Vector2) -> void:
	remote_player_state_updated.emit(peer_id, {"is_dead": true, "position": position})

@rpc("authority", "reliable")
func _rpc_player_respawned(peer_id: int, position: Vector2) -> void:
	remote_player_state_updated.emit(peer_id, {"is_dead": false, "position": position})

# === Interpolation ===

func get_interpolated_position(peer_id: int) -> Vector2:
	if not _remote_players.has(peer_id):
		return Vector2.ZERO
	
	var snapshots = _remote_players[peer_id]["snapshots"]
	if snapshots.size() < 2:
		if snapshots.size() == 1:
			return snapshots[0]["position"]
		return Vector2.ZERO
	
	var render_time = Time.get_ticks_msec() / 1000.0 - INTERPOLATION_DELAY
	
	# Find the two snapshots to interpolate between
	for i in range(snapshots.size() - 1, 0, -1):
		if snapshots[i - 1]["timestamp"] <= render_time and snapshots[i]["timestamp"] >= render_time:
			var t0 = snapshots[i - 1]["timestamp"]
			var t1 = snapshots[i]["timestamp"]
			var t = 0.0
			if t1 - t0 > 0:
				t = (render_time - t0) / (t1 - t0)
			return snapshots[i - 1]["position"].lerp(snapshots[i]["position"], t)
	
	# If no suitable pair found, return latest
	return snapshots[-1]["position"]

# === Helpers ===

func _get_input_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _get_local_player() -> Node:
	var players_group = get_tree().get_nodes_in_group("local_player")
	if players_group.size() > 0:
		return players_group[0]
	return null

func _get_player_by_peer_id(peer_id: int) -> Node:
	var players_node = get_tree().get_first_node_in_group("players_container")
	if players_node == null:
		return null
	
	for player in players_node.get_children():
		if player.has_meta("peer_id") and player.get_meta("peer_id") == peer_id:
			return player
	return null

func _apply_input_locally(player: Node, input_vector: Vector2) -> void:
	if player is CharacterBody2D:
		var speed = player.get("move_speed") if player.get("move_speed") != null else 100.0
		player.velocity = input_vector * speed
		player.move_and_slide()

func _apply_input_to_player(player: Node, input_vector: Vector2) -> void:
	_apply_input_locally(player, input_vector)

## ClientPrediction - Client-side mozgás predikció
## Azonnali mozgás feedback + szerver validáció reconciliation
extends Node

# --- Prediction state ---
var _prediction_enabled: bool = true
var _input_buffer: Array[Dictionary] = []
var _last_acknowledged_sequence: int = 0
var _max_buffer_size: int = 64

# --- Correction settings ---
const CORRECTION_THRESHOLD: float = 3.0  # pixels
const SMOOTH_CORRECTION_THRESHOLD: float = 20.0  # above this: snap, below: lerp
const CORRECTION_LERP_WEIGHT: float = 0.3

# --- Signals ---
signal prediction_corrected(error_distance: float)

func _ready() -> void:
	pass

# === Public API ===

## Record local input for later reconciliation
func record_input(sequence: int, input_vector: Vector2, position_before: Vector2) -> void:
	if not _prediction_enabled:
		return
	
	_input_buffer.append({
		"sequence": sequence,
		"input": input_vector,
		"position": position_before,
		"timestamp": Time.get_ticks_msec() / 1000.0,
	})
	
	# Trim buffer
	while _input_buffer.size() > _max_buffer_size:
		_input_buffer.pop_front()

## Called when server sends position correction
func reconcile(server_position: Vector2, server_sequence: int, player: CharacterBody2D) -> void:
	if not _prediction_enabled or player == null:
		return
	
	_last_acknowledged_sequence = server_sequence
	
	# Remove all acknowledged inputs
	while _input_buffer.size() > 0 and _input_buffer[0]["sequence"] <= server_sequence:
		_input_buffer.pop_front()
	
	# Calculate error
	var error = player.global_position.distance_to(server_position)
	
	if error < CORRECTION_THRESHOLD:
		return  # Close enough, no correction needed
	
	prediction_corrected.emit(error)
	
	if error > SMOOTH_CORRECTION_THRESHOLD:
		# Large error: snap to server position
		player.global_position = server_position
	else:
		# Small error: lerp towards server position
		player.global_position = player.global_position.lerp(server_position, CORRECTION_LERP_WEIGHT)
	
	# Replay remaining unacknowledged inputs
	for input_data in _input_buffer:
		_replay_input(player, input_data["input"])

func set_prediction_enabled(enabled: bool) -> void:
	_prediction_enabled = enabled
	if not enabled:
		_input_buffer.clear()

func get_buffer_size() -> int:
	return _input_buffer.size()

func get_last_acknowledged() -> int:
	return _last_acknowledged_sequence

# === Internal ===

func _replay_input(player: CharacterBody2D, input_vector: Vector2) -> void:
	var speed = player.get("move_speed") if player.get("move_speed") != null else 100.0
	var delta = NetworkManager.TICK_INTERVAL
	player.velocity = input_vector * speed
	player.move_and_slide()

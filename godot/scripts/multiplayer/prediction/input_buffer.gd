## InputBuffer - Input history tárolás client prediction-höz
## Timestamp-elt inputok replay-hez és reconciliation-höz
extends Node

# --- Buffer ---
var _buffer: Array[Dictionary] = []
var _sequence_counter: int = 0
var _max_size: int = 128

# === Public API ===

## Add new input to the buffer with auto-incrementing sequence
func push_input(input_vector: Vector2) -> int:
	_sequence_counter += 1
	
	var entry = {
		"sequence": _sequence_counter,
		"input": input_vector,
		"timestamp": Time.get_ticks_msec() / 1000.0,
	}
	
	_buffer.append(entry)
	
	# Trim old entries
	while _buffer.size() > _max_size:
		_buffer.pop_front()
	
	return _sequence_counter

## Remove all inputs up to and including the given sequence number
func acknowledge_up_to(sequence: int) -> void:
	while _buffer.size() > 0 and _buffer[0]["sequence"] <= sequence:
		_buffer.pop_front()

## Get all unacknowledged inputs (for replay after server correction)
func get_unacknowledged() -> Array[Dictionary]:
	return _buffer.duplicate()

## Get an input by sequence number
func get_input(sequence: int) -> Dictionary:
	for entry in _buffer:
		if entry["sequence"] == sequence:
			return entry
	return {}

## Get the current sequence number
func get_current_sequence() -> int:
	return _sequence_counter

## Get the oldest sequence in the buffer
func get_oldest_sequence() -> int:
	if _buffer.size() > 0:
		return _buffer[0]["sequence"]
	return _sequence_counter

## Get buffer size
func get_size() -> int:
	return _buffer.size()

## Clear the entire buffer
func clear() -> void:
	_buffer.clear()
	_sequence_counter = 0

## Reset sequence counter (for new game/session)
func reset() -> void:
	_buffer.clear()
	_sequence_counter = 0

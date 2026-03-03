## WorldSync - Világ és chunk szinkronizáció
## Seed-based determinisztikus generálás → csak módosítások (delta) szinkronizálása
extends Node

# --- World modifications ---
var _world_modifications: Array[Dictionary] = []  # All modifications since session start
var _modification_counter: int = 0

# --- Signals ---
signal world_initialized(seed_value: int)
signal world_modification_received(chunk_pos: Vector2i, tile_pos: Vector2i, new_state: int)
signal day_night_synced(is_night: bool, time_of_day: float)
signal dungeon_state_changed(dungeon_id: String, state: Dictionary)

func reset() -> void:
	_world_modifications.clear()
	_modification_counter = 0

# === Server Side ===

## Called when a world tile is modified (tree chopped, chest opened, etc.)
func server_register_modification(chunk_pos: Vector2i, tile_pos: Vector2i, new_state: int) -> void:
	if not NetworkManager.is_server():
		return
	
	_modification_counter += 1
	var mod = {
		"id": _modification_counter,
		"chunk_pos": chunk_pos,
		"tile_pos": tile_pos,
		"new_state": new_state,
		"timestamp": NetworkManager.get_server_time(),
	}
	_world_modifications.append(mod)
	
	# Broadcast to all clients
	_rpc_world_modification.rpc(chunk_pos, tile_pos, new_state)

## Send all modifications to a newly connected/reconnected client
func server_send_full_delta(peer_id: int) -> void:
	if not NetworkManager.is_server():
		return
	
	_rpc_receive_full_delta.rpc_id(peer_id, _world_modifications)

## Sync day/night cycle
func server_sync_day_night(is_night: bool, time_of_day: float) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_day_night_update.rpc(is_night, time_of_day)

## Sync dungeon state (room cleared, door opened, etc.)
func server_sync_dungeon_state(dungeon_id: String, state: Dictionary) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_dungeon_state_update.rpc(dungeon_id, state)

## Chest opened
func server_chest_opened(chunk_pos: Vector2i, tile_pos: Vector2i) -> void:
	server_register_modification(chunk_pos, tile_pos, 0)  # 0 = empty/opened

## Door state changed
func server_door_state(chunk_pos: Vector2i, tile_pos: Vector2i, is_open: bool) -> void:
	server_register_modification(chunk_pos, tile_pos, 1 if is_open else 2)

# === RPCs ===

@rpc("authority", "reliable")
func _rpc_init_world(seed_value: int) -> void:
	world_initialized.emit(seed_value)
	print("WorldSync: World initialized with seed %d" % seed_value)

@rpc("authority", "reliable")
func _rpc_world_modification(chunk_pos: Vector2i, tile_pos: Vector2i, new_state: int) -> void:
	world_modification_received.emit(chunk_pos, tile_pos, new_state)

@rpc("authority", "reliable")
func _rpc_receive_full_delta(modifications: Array) -> void:
	print("WorldSync: Received %d world modifications" % modifications.size())
	for mod in modifications:
		var cp = mod.get("chunk_pos", Vector2i.ZERO)
		var tp = mod.get("tile_pos", Vector2i.ZERO)
		var ns = mod.get("new_state", 0)
		world_modification_received.emit(cp, tp, ns)

@rpc("authority", "unreliable")
func _rpc_day_night_update(is_night: bool, time_of_day: float) -> void:
	day_night_synced.emit(is_night, time_of_day)

@rpc("authority", "reliable")
func _rpc_dungeon_state_update(dungeon_id: String, state: Dictionary) -> void:
	dungeon_state_changed.emit(dungeon_id, state)

# === Accessors ===

func get_modification_count() -> int:
	return _world_modifications.size()

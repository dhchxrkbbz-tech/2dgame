## LootSync - Személyes loot szinkronizáció
## Minden játékos saját loot-ot kap, más játékosok NEM látják
extends Node

# --- Tracked loot ---
var _loot_id_counter: int = 0
var _local_loot_items: Dictionary = {}  # loot_id → loot data (only items visible to local player)

# --- Signals ---
signal loot_spawned(loot_id: int, item_data: Dictionary, position: Vector2)
signal loot_picked_up(loot_id: int, item_data: Dictionary)
signal loot_despawned(loot_id: int)

func reset() -> void:
	_loot_id_counter = 0
	_local_loot_items.clear()

# === Server Side ===

## Called on host when an enemy dies - generates personal loot for each nearby player
func server_generate_loot(enemy_position: Vector2, loot_table: Array, eligible_peer_ids: Array[int]) -> void:
	if not NetworkManager.is_server():
		return
	
	for peer_id in eligible_peer_ids:
		# Roll loot for each player individually
		var rolled_items = _roll_loot(loot_table, peer_id)
		
		for item_data in rolled_items:
			_loot_id_counter += 1
			var loot_id = _loot_id_counter
			
			# Small random offset so items don't stack
			var offset = Vector2(randf_range(-16, 16), randf_range(-16, 16))
			var loot_pos = enemy_position + offset
			
			# Send only to the owner (personal loot)
			_rpc_spawn_loot.rpc_id(peer_id, loot_id, item_data, loot_pos)
			
			# If host is the owner, also handle locally
			if peer_id == 1:
				_on_loot_spawned_locally(loot_id, item_data, loot_pos)

## Called on host when a chest is opened
func server_generate_chest_loot(chest_position: Vector2, loot_table: Array, opener_peer_id: int) -> void:
	if not NetworkManager.is_server():
		return
	
	var rolled_items = _roll_loot(loot_table, opener_peer_id)
	
	for item_data in rolled_items:
		_loot_id_counter += 1
		var loot_id = _loot_id_counter
		
		var offset = Vector2(randf_range(-12, 12), randf_range(-12, 12))
		var loot_pos = chest_position + offset
		
		_rpc_spawn_loot.rpc_id(opener_peer_id, loot_id, item_data, loot_pos)
		
		if opener_peer_id == 1:
			_on_loot_spawned_locally(loot_id, item_data, loot_pos)

# === Client Side ===

func client_request_pickup(loot_id: int) -> void:
	_rpc_request_pickup.rpc_id(1, loot_id)

# === RPCs ===

@rpc("authority", "reliable")
func _rpc_spawn_loot(loot_id: int, item_data: Dictionary, position: Vector2) -> void:
	_on_loot_spawned_locally(loot_id, item_data, position)

@rpc("any_peer", "reliable")
func _rpc_request_pickup(loot_id: int) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	
	# Validate: does loot exist? Is sender the owner?
	# In a full implementation, server tracks all loot ownership
	# For now, trust client (personal loot = no conflict)
	
	_rpc_pickup_confirmed.rpc_id(sender_id, loot_id)

@rpc("authority", "reliable")
func _rpc_pickup_confirmed(loot_id: int) -> void:
	if _local_loot_items.has(loot_id):
		var item_data = _local_loot_items[loot_id]["item_data"]
		_local_loot_items.erase(loot_id)
		loot_picked_up.emit(loot_id, item_data)

@rpc("authority", "reliable")
func _rpc_loot_despawned(loot_id: int) -> void:
	if _local_loot_items.has(loot_id):
		_local_loot_items.erase(loot_id)
		loot_despawned.emit(loot_id)

# === Internal ===

func _on_loot_spawned_locally(loot_id: int, item_data: Dictionary, position: Vector2) -> void:
	_local_loot_items[loot_id] = {
		"item_data": item_data,
		"position": position,
		"spawn_time": Time.get_ticks_msec() / 1000.0,
	}
	loot_spawned.emit(loot_id, item_data, position)

func _roll_loot(loot_table: Array, _peer_id: int) -> Array:
	# Placeholder loot rolling - actual implementation should use LootSystem
	var results: Array = []
	for entry in loot_table:
		var roll = randf()
		if roll <= entry.get("drop_chance", 0.1):
			results.append(entry.get("item_data", {}))
	return results

func get_local_loot() -> Dictionary:
	return _local_loot_items

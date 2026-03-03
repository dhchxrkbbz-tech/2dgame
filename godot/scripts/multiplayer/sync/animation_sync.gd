## AnimationSync - Animáció state szinkronizáció
## Csak az animáció NEVÉT küldjük (nem frame-eket) → minimális bandwidth
extends Node

# --- Tracked animation states ---
var _player_anim_states: Dictionary = {}  # peer_id → { anim_state, facing_direction }
var _enemy_anim_states: Dictionary = {}   # entity_id → { anim_state }

# --- Signals ---
signal player_animation_changed(peer_id: int, anim_state: String, facing: Vector2)
signal enemy_animation_changed(entity_id: int, anim_state: String)
signal effect_spawned(effect_id: String, position: Vector2, direction: Vector2)

func reset() -> void:
	_player_anim_states.clear()
	_enemy_anim_states.clear()

# === Server Side ===

func server_broadcast_animations() -> void:
	if not NetworkManager.is_server():
		return
	
	# Collect player animation states
	var player_anims: Dictionary = {}
	var players_node = get_tree().get_first_node_in_group("players_container")
	if players_node:
		for player in players_node.get_children():
			if not player.has_meta("peer_id"):
				continue
			var peer_id = player.get_meta("peer_id")
			var anim_state = "idle"
			var facing = Vector2.DOWN
			
			if player.has_method("get_animation_state"):
				anim_state = player.get_animation_state()
			if player.get("facing_direction") != null:
				facing = player.facing_direction
			
			player_anims[peer_id] = {
				"a": anim_state,
				"f": facing,
			}
	
	if player_anims.size() > 0:
		_rpc_player_anim_batch.rpc(player_anims)

func server_update_player_anim(peer_id: int, anim_state: String, facing: Vector2) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_player_anim_update.rpc(peer_id, anim_state, facing)

func server_spawn_effect(effect_id: String, position: Vector2, direction: Vector2) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_spawn_effect.rpc(effect_id, position, direction)

## Boss animation sync (reliable for phase transitions)
func server_boss_anim(boss_id: String, anim_state: String, reliable: bool = false) -> void:
	if not NetworkManager.is_server():
		return
	if reliable:
		_rpc_boss_anim_reliable.rpc(boss_id, anim_state)
	else:
		_rpc_boss_anim_unreliable.rpc(boss_id, anim_state)

# === Client Side ===

func client_send_anim_state(anim_state: String, facing: Vector2) -> void:
	if NetworkManager.is_server():
		return
	_rpc_client_anim_update.rpc_id(1, anim_state, facing)

# === RPCs ===

@rpc("authority", "unreliable_ordered")
func _rpc_player_anim_batch(player_anims: Dictionary) -> void:
	for peer_id in player_anims:
		if peer_id == multiplayer.get_unique_id():
			continue  # Skip self
		
		var data = player_anims[peer_id]
		var anim_state: String = data["a"]
		var facing: Vector2 = data["f"]
		
		_player_anim_states[peer_id] = {
			"anim_state": anim_state,
			"facing": facing,
		}
		
		player_animation_changed.emit(peer_id, anim_state, facing)

@rpc("authority", "unreliable_ordered")
func _rpc_player_anim_update(peer_id: int, anim_state: String, facing: Vector2) -> void:
	if peer_id == multiplayer.get_unique_id():
		return
	
	_player_anim_states[peer_id] = {
		"anim_state": anim_state,
		"facing": facing,
	}
	player_animation_changed.emit(peer_id, anim_state, facing)

@rpc("any_peer", "unreliable_ordered")
func _rpc_client_anim_update(anim_state: String, facing: Vector2) -> void:
	if not multiplayer.is_server():
		return
	var sender_id = multiplayer.get_remote_sender_id()
	_player_anim_states[sender_id] = {
		"anim_state": anim_state,
		"facing": facing,
	}

@rpc("authority", "reliable")
func _rpc_spawn_effect(effect_id: String, position: Vector2, direction: Vector2) -> void:
	effect_spawned.emit(effect_id, position, direction)

@rpc("authority", "reliable")
func _rpc_boss_anim_reliable(boss_id: String, anim_state: String) -> void:
	# Phase transition, death - important animations
	pass  # Connect to boss animation system

@rpc("authority", "unreliable_ordered")
func _rpc_boss_anim_unreliable(boss_id: String, anim_state: String) -> void:
	# Idle, walk - standard animations
	pass  # Connect to boss animation system

# === Accessors ===

func get_player_anim_state(peer_id: int) -> Dictionary:
	return _player_anim_states.get(peer_id, {"anim_state": "idle", "facing": Vector2.DOWN})

func get_enemy_anim_state(entity_id: int) -> Dictionary:
	return _enemy_anim_states.get(entity_id, {"anim_state": "idle"})

## ProjectileSync - Projectile szinkronizáció
## Spawn pozíció + irány + speed küldése (kliensek lokálisan szimulálják a röptét)
## Hit detection CSAK host-on történik
extends Node

# --- Tracked projectiles ---
var _projectile_counter: int = 0
var _active_projectiles: Dictionary = {}  # projectile_id → data

# --- Signals ---
signal projectile_spawned_remote(proj_id: int, data: Dictionary)
signal projectile_hit_confirmed(proj_id: int, target_id: int, damage: float)
signal projectile_destroyed(proj_id: int)

func reset() -> void:
	_projectile_counter = 0
	_active_projectiles.clear()

# === Client Side ===

func client_request_projectile(skill_id: String, position: Vector2, direction: Vector2) -> void:
	var timestamp = NetworkManager.get_server_time()
	_rpc_request_projectile_spawn.rpc_id(1, skill_id, position, direction, timestamp)

# === Server Side ===

func server_spawn_projectile(owner_peer_id: int, skill_id: String, position: Vector2, direction: Vector2, speed: float, damage: float, lifetime: float = 5.0) -> int:
	if not NetworkManager.is_server():
		return -1
	
	_projectile_counter += 1
	var proj_id = owner_peer_id * 10000 + _projectile_counter
	
	var proj_data = {
		"id": proj_id,
		"owner_id": owner_peer_id,
		"skill_id": skill_id,
		"position": position,
		"direction": direction.normalized(),
		"speed": speed,
		"damage": damage,
		"lifetime": lifetime,
		"spawn_time": NetworkManager.get_server_time(),
	}
	
	_active_projectiles[proj_id] = proj_data
	
	# Broadcast to all clients (including self for visual)
	_rpc_spawn_projectile.rpc(proj_id, owner_peer_id, skill_id, position, direction, speed, lifetime)
	
	return proj_id

func server_confirm_hit(proj_id: int, target_id: int, damage: float) -> void:
	if not _active_projectiles.has(proj_id):
		return
	
	_rpc_hit_confirmed.rpc(proj_id, target_id, damage)
	_active_projectiles.erase(proj_id)

func server_destroy_projectile(proj_id: int) -> void:
	if _active_projectiles.has(proj_id):
		_active_projectiles.erase(proj_id)
		_rpc_projectile_destroyed.rpc(proj_id)

# === RPCs ===

@rpc("any_peer", "reliable")
func _rpc_request_projectile_spawn(skill_id: String, position: Vector2, direction: Vector2, timestamp: float) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	
	# Validate: does this player exist? Can they cast?
	# (Detailed validation would check cooldown, mana, etc.)
	var player = _get_player_by_peer_id(sender_id)
	if player == null:
		_rpc_projectile_denied.rpc_id(sender_id, skill_id, "Player not found")
		return
	
	# TODO: Get actual skill data for speed/damage/lifetime
	var speed = 200.0
	var damage = 10.0
	var lifetime = 5.0
	
	server_spawn_projectile(sender_id, skill_id, position, direction, speed, damage, lifetime)

@rpc("authority", "reliable")
func _rpc_spawn_projectile(proj_id: int, owner_id: int, skill_id: String, position: Vector2, direction: Vector2, speed: float, lifetime: float) -> void:
	var data = {
		"id": proj_id,
		"owner_id": owner_id,
		"skill_id": skill_id,
		"position": position,
		"direction": direction,
		"speed": speed,
		"lifetime": lifetime,
	}
	
	_active_projectiles[proj_id] = data
	projectile_spawned_remote.emit(proj_id, data)

@rpc("authority", "reliable")
func _rpc_hit_confirmed(proj_id: int, target_id: int, damage: float) -> void:
	projectile_hit_confirmed.emit(proj_id, target_id, damage)
	_active_projectiles.erase(proj_id)

@rpc("authority", "reliable")
func _rpc_projectile_destroyed(proj_id: int) -> void:
	projectile_destroyed.emit(proj_id)
	_active_projectiles.erase(proj_id)

@rpc("authority", "reliable")
func _rpc_projectile_denied(skill_id: String, reason: String) -> void:
	push_warning("ProjectileSync: Projectile denied for skill %s: %s" % [skill_id, reason])

# === Helpers ===

func _get_player_by_peer_id(peer_id: int) -> Node:
	var players_node = get_tree().get_first_node_in_group("players_container")
	if players_node == null:
		return null
	for player in players_node.get_children():
		if player.has_meta("peer_id") and player.get_meta("peer_id") == peer_id:
			return player
	return null

func get_active_projectiles() -> Dictionary:
	return _active_projectiles

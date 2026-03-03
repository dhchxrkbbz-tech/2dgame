## LobbyManager - Lobby rendszer és játékos kezelés
## Host-authoritative lobby: host validálja a csatlakozásokat
extends Node

# --- Lobby data ---
var players: Dictionary = {}  # peer_id → LobbyPlayerData
var max_players: int = 4
var _pending_player_name: String = ""

# --- Signals ---
signal lobby_player_joined(peer_id: int, player_data: Dictionary)
signal lobby_player_left(peer_id: int)
signal lobby_player_ready_changed(peer_id: int, is_ready: bool)
signal lobby_player_class_changed(peer_id: int, class_type: Enums.PlayerClass)
signal all_players_ready()
signal game_starting(world_seed: int, spawn_positions: Array)

# === Data Structures ===

static func create_player_data(peer_id: int, player_name: String, class_type: Enums.PlayerClass = Enums.PlayerClass.ASSASSIN) -> Dictionary:
	return {
		"peer_id": peer_id,
		"player_name": player_name,
		"selected_class": class_type,
		"is_ready": false,
		"color": _get_player_color(players.size() if Engine.get_main_loop() else 0)
	}

static func _get_player_color(index: int) -> Color:
	var colors = [
		Color(0.2, 0.6, 1.0),   # Blue - Host
		Color(0.2, 0.8, 0.2),   # Green
		Color(1.0, 0.4, 0.4),   # Red
		Color(1.0, 0.8, 0.2),   # Yellow
	]
	return colors[clampi(index, 0, colors.size() - 1)]

# === Host Functions ===

func initialize_lobby(host_name: String) -> void:
	players.clear()
	var host_data = create_player_data(
		multiplayer.get_unique_id(),
		host_name,
		Enums.PlayerClass.ASSASSIN
	)
	host_data["color"] = _get_player_color(0)
	players[multiplayer.get_unique_id()] = host_data
	_broadcast_lobby_state()
	print("LobbyManager: Lobby created by %s" % host_name)

func remove_player(peer_id: int) -> void:
	if players.has(peer_id):
		var player_name = players[peer_id]["player_name"]
		players.erase(peer_id)
		lobby_player_left.emit(peer_id)
		_broadcast_lobby_state()
		print("LobbyManager: %s left the lobby" % player_name)

func start_game_as_host() -> void:
	if not NetworkManager.is_server():
		push_warning("LobbyManager: Only host can start the game")
		return
	
	if not _all_players_ready():
		push_warning("LobbyManager: Not all players are ready")
		return
	
	# Generate world seed
	var seed_value = randi()
	NetworkManager.world_seed = seed_value
	
	# Generate spawn positions
	var spawn_positions: Array[Vector2] = _generate_spawn_positions()
	
	# Notify all clients
	_rpc_start_game.rpc(seed_value, spawn_positions)
	
	print("LobbyManager: Game starting with seed %d" % seed_value)

func get_player_count() -> int:
	return players.size()

func get_player_data(peer_id: int) -> Dictionary:
	return players.get(peer_id, {})

func get_all_players() -> Dictionary:
	return players.duplicate(true)

func clear_lobby() -> void:
	players.clear()

# === Client Functions ===

func request_join(player_name: String) -> void:
	_rpc_request_join.rpc_id(1, player_name, Enums.PlayerClass.ASSASSIN)

func set_ready(is_ready: bool) -> void:
	_rpc_set_ready.rpc_id(1, is_ready)

func set_class(class_type: Enums.PlayerClass) -> void:
	_rpc_set_class.rpc_id(1, class_type)

# === RPCs ===

@rpc("any_peer", "reliable")
func _rpc_request_join(player_name: String, class_type: Enums.PlayerClass) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	
	# Validate: is there room?
	if players.size() >= max_players:
		_rpc_join_denied.rpc_id(sender_id, "Lobby is full")
		return
	
	# Validate: not already in lobby?
	if players.has(sender_id):
		_rpc_join_denied.rpc_id(sender_id, "Already in lobby")
		return
	
	# Accept the player
	var player_data = create_player_data(sender_id, player_name, class_type)
	player_data["color"] = _get_player_color(players.size())
	players[sender_id] = player_data
	
	lobby_player_joined.emit(sender_id, player_data)
	_broadcast_lobby_state()
	
	print("LobbyManager: %s (peer %d) joined the lobby" % [player_name, sender_id])

@rpc("authority", "reliable")
func _rpc_join_denied(reason: String) -> void:
	push_warning("LobbyManager: Join denied - %s" % reason)
	NetworkManager.disconnect_from_game()

@rpc("any_peer", "reliable")
func _rpc_set_ready(is_ready: bool) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	if not players.has(sender_id):
		return
	
	players[sender_id]["is_ready"] = is_ready
	lobby_player_ready_changed.emit(sender_id, is_ready)
	_broadcast_lobby_state()
	
	if _all_players_ready() and players.size() >= 1:
		all_players_ready.emit()

@rpc("any_peer", "reliable")
func _rpc_set_class(class_type: Enums.PlayerClass) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	if not players.has(sender_id):
		return
	
	players[sender_id]["selected_class"] = class_type
	lobby_player_class_changed.emit(sender_id, class_type)
	_broadcast_lobby_state()

@rpc("authority", "reliable")
func _rpc_lobby_state_update(lobby_data: Dictionary) -> void:
	# Client receives full lobby state from host
	players = lobby_data.duplicate(true)
	EventBus.lobby_updated.emit(lobby_data)

@rpc("authority", "reliable", "call_local")
func _rpc_start_game(seed_value: int, spawn_positions: Array) -> void:
	NetworkManager.world_seed = seed_value
	game_starting.emit(seed_value, spawn_positions)
	print("LobbyManager: Game starting! Seed: %d" % seed_value)

# === Internal ===

func _broadcast_lobby_state() -> void:
	if not multiplayer.is_server():
		return
	_rpc_lobby_state_update.rpc(players)
	EventBus.lobby_updated.emit(players)

func _all_players_ready() -> bool:
	for peer_id in players:
		# Host is always considered ready
		if peer_id == 1:
			continue
		if not players[peer_id].get("is_ready", false):
			return false
	return true

func _generate_spawn_positions() -> Array[Vector2]:
	var positions: Array[Vector2] = []
	var base_pos = Vector2(100, 100)
	var offset = 48.0  # 1.5 tile spacing
	
	for i in players.size():
		positions.append(base_pos + Vector2(i * offset, 0))
	
	return positions

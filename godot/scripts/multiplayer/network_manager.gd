## NetworkManager - Fő multiplayer singleton (Autoload)
## Host-Authoritative modell, ENetMultiplayerPeer
## Max 4 játékos co-op
extends Node

# --- Constants ---
const DEFAULT_PORT: int = 7777
const MAX_CLIENTS: int = 3  # + host = 4 player
const TICK_RATE: int = 20  # 50ms update interval
const TICK_INTERVAL: float = 1.0 / TICK_RATE

# --- Connection state ---
enum ConnectionState {
	DISCONNECTED,
	CONNECTING,
	CONNECTED,
	HOST
}

# --- Sub-managers ---
var connection_manager: Node
var lobby_manager: Node
var sync_manager: Node
var session_manager: Node
var network_stats: Node

# --- State ---
var current_state: ConnectionState = ConnectionState.DISCONNECTED
var local_peer_id: int = -1
var is_host: bool = false
var world_seed: int = 0

# --- Tick timer ---
var _tick_timer: float = 0.0
var _current_tick: int = 0

# --- Signals ---
signal connection_state_changed(new_state: ConnectionState)
signal network_tick(tick_number: int)

func _ready() -> void:
	_setup_sub_managers()
	_connect_multiplayer_signals()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if current_state == ConnectionState.DISCONNECTED:
		return
	
	_tick_timer += delta
	if _tick_timer >= TICK_INTERVAL:
		_tick_timer -= TICK_INTERVAL
		_current_tick += 1
		network_tick.emit(_current_tick)

func _setup_sub_managers() -> void:
	# ConnectionManager
	connection_manager = preload("res://scripts/multiplayer/connection_manager.gd").new()
	connection_manager.name = "ConnectionManager"
	add_child(connection_manager)
	
	# LobbyManager
	lobby_manager = preload("res://scripts/multiplayer/lobby_manager.gd").new()
	lobby_manager.name = "LobbyManager"
	add_child(lobby_manager)
	
	# SyncManager
	sync_manager = preload("res://scripts/multiplayer/sync_manager.gd").new()
	sync_manager.name = "SyncManager"
	add_child(sync_manager)
	
	# SessionManager
	session_manager = preload("res://scripts/multiplayer/session_manager.gd").new()
	session_manager.name = "SessionManager"
	add_child(session_manager)
	
	# NetworkStats
	network_stats = preload("res://scripts/multiplayer/network_stats.gd").new()
	network_stats.name = "NetworkStats"
	add_child(network_stats)

func _connect_multiplayer_signals() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# === Public API ===

func host_game(port: int = DEFAULT_PORT, player_name: String = "Host") -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_CLIENTS)
	if error != OK:
		push_error("NetworkManager: Failed to create server on port %d: %s" % [port, error_string(error)])
		return error
	
	multiplayer.multiplayer_peer = peer
	local_peer_id = multiplayer.get_unique_id()
	is_host = true
	_set_state(ConnectionState.HOST)
	
	lobby_manager.initialize_lobby(player_name)
	session_manager.start_session()
	
	print("NetworkManager: Hosting game on port %d (peer_id: %d)" % [port, local_peer_id])
	return OK

func join_game(ip: String, port: int = DEFAULT_PORT, player_name: String = "Player") -> Error:
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, port)
	if error != OK:
		push_error("NetworkManager: Failed to connect to %s:%d: %s" % [ip, port, error_string(error)])
		return error
	
	multiplayer.multiplayer_peer = peer
	_set_state(ConnectionState.CONNECTING)
	
	# Store player name for lobby join request
	lobby_manager._pending_player_name = player_name
	
	print("NetworkManager: Connecting to %s:%d..." % [ip, port])
	return OK

func disconnect_from_game() -> void:
	if current_state == ConnectionState.DISCONNECTED:
		return
	
	session_manager.end_session()
	lobby_manager.clear_lobby()
	sync_manager.reset()
	
	multiplayer.multiplayer_peer = null
	local_peer_id = -1
	is_host = false
	_set_state(ConnectionState.DISCONNECTED)
	
	print("NetworkManager: Disconnected from game")

func is_server() -> bool:
	return is_host and multiplayer.is_server()

func get_peer_id() -> int:
	return local_peer_id

func get_player_count() -> int:
	return lobby_manager.get_player_count()

func get_server_time() -> float:
	return _current_tick * TICK_INTERVAL

# === State Management ===

func _set_state(new_state: ConnectionState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	connection_state_changed.emit(new_state)
	EventBus.emit_signal("show_notification", _state_to_string(new_state), Enums.NotificationType.INFO)

func _state_to_string(state: ConnectionState) -> String:
	match state:
		ConnectionState.DISCONNECTED: return "Disconnected"
		ConnectionState.CONNECTING: return "Connecting..."
		ConnectionState.CONNECTED: return "Connected"
		ConnectionState.HOST: return "Hosting"
	return "Unknown"

# === Multiplayer Callbacks ===

func _on_peer_connected(peer_id: int) -> void:
	print("NetworkManager: Peer connected: %d" % peer_id)
	EventBus.player_connected.emit(peer_id)
	network_stats.register_peer(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	print("NetworkManager: Peer disconnected: %d" % peer_id)
	EventBus.player_disconnected.emit(peer_id)
	lobby_manager.remove_player(peer_id)
	session_manager.handle_disconnect(peer_id)
	network_stats.unregister_peer(peer_id)

func _on_connected_to_server() -> void:
	local_peer_id = multiplayer.get_unique_id()
	_set_state(ConnectionState.CONNECTED)
	lobby_manager.request_join(lobby_manager._pending_player_name)
	print("NetworkManager: Connected to server (peer_id: %d)" % local_peer_id)

func _on_connection_failed() -> void:
	_set_state(ConnectionState.DISCONNECTED)
	multiplayer.multiplayer_peer = null
	push_warning("NetworkManager: Connection failed")

func _on_server_disconnected() -> void:
	print("NetworkManager: Server disconnected")
	disconnect_from_game()

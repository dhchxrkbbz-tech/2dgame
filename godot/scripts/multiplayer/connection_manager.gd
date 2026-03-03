## ConnectionManager - Host/Client létrehozás és kapcsolat kezelés
## A NetworkManager gyermekeként fut
extends Node

# --- Connection config ---
var server_ip: String = "127.0.0.1"
var server_port: int = NetworkManager.DEFAULT_PORT
var connection_timeout: float = 10.0
var max_reconnect_attempts: int = 3

# --- Internal state ---
var _reconnect_attempts: int = 0
var _connection_timer: Timer

# --- Signals ---
signal connection_timeout_reached()
signal reconnect_attempt(attempt: int)

func _ready() -> void:
	_setup_connection_timer()

func _setup_connection_timer() -> void:
	_connection_timer = Timer.new()
	_connection_timer.name = "ConnectionTimer"
	_connection_timer.one_shot = true
	_connection_timer.wait_time = connection_timeout
	_connection_timer.timeout.connect(_on_connection_timeout)
	add_child(_connection_timer)

# === Public API ===

func start_host(port: int = NetworkManager.DEFAULT_PORT) -> Error:
	server_port = port
	return NetworkManager.host_game(port)

func start_client(ip: String, port: int = NetworkManager.DEFAULT_PORT) -> Error:
	server_ip = ip
	server_port = port
	_reconnect_attempts = 0
	_connection_timer.start()
	return NetworkManager.join_game(ip, port)

func disconnect() -> void:
	_connection_timer.stop()
	_reconnect_attempts = 0
	NetworkManager.disconnect_from_game()

func attempt_reconnect() -> void:
	if _reconnect_attempts >= max_reconnect_attempts:
		push_warning("ConnectionManager: Max reconnect attempts reached")
		return
	
	_reconnect_attempts += 1
	reconnect_attempt.emit(_reconnect_attempts)
	print("ConnectionManager: Reconnect attempt %d/%d" % [_reconnect_attempts, max_reconnect_attempts])
	
	NetworkManager.join_game(server_ip, server_port)
	_connection_timer.start()

func get_connection_info() -> Dictionary:
	return {
		"ip": server_ip,
		"port": server_port,
		"state": NetworkManager.current_state,
		"is_host": NetworkManager.is_host,
		"peer_id": NetworkManager.local_peer_id,
		"reconnect_attempts": _reconnect_attempts
	}

# === Callbacks ===

func _on_connection_timeout() -> void:
	if NetworkManager.current_state == NetworkManager.ConnectionState.CONNECTING:
		push_warning("ConnectionManager: Connection timed out")
		connection_timeout_reached.emit()
		
		if _reconnect_attempts < max_reconnect_attempts:
			attempt_reconnect()
		else:
			NetworkManager.disconnect_from_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		disconnect()

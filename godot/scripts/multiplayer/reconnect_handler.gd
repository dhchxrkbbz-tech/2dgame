## ReconnectHandler - Reconnect flow kezelés
## Client oldalon kezeli a reconnect kísérleteket
extends Node

# --- State ---
var _is_reconnecting: bool = false
var _reconnect_attempts: int = 0
var _max_attempts: int = 5
var _reconnect_delay: float = 3.0  # seconds between attempts
var _last_server_ip: String = ""
var _last_server_port: int = 7777
var _last_player_name: String = ""

# --- Timer ---
var _reconnect_timer: Timer

# --- Signals ---
signal reconnect_started()
signal reconnect_attempt_made(attempt: int, max_attempts: int)
signal reconnect_succeeded()
signal reconnect_failed()

func _ready() -> void:
	_reconnect_timer = Timer.new()
	_reconnect_timer.name = "ReconnectDelayTimer"
	_reconnect_timer.one_shot = true
	_reconnect_timer.timeout.connect(_try_reconnect)
	add_child(_reconnect_timer)

# === Public API ===

func start_reconnect(ip: String, port: int, player_name: String) -> void:
	_last_server_ip = ip
	_last_server_port = port
	_last_player_name = player_name
	_reconnect_attempts = 0
	_is_reconnecting = true
	reconnect_started.emit()
	_try_reconnect()

func stop_reconnect() -> void:
	_is_reconnecting = false
	_reconnect_timer.stop()
	_reconnect_attempts = 0

func is_reconnecting() -> bool:
	return _is_reconnecting

# === Internal ===

func _try_reconnect() -> void:
	if not _is_reconnecting:
		return
	
	_reconnect_attempts += 1
	
	if _reconnect_attempts > _max_attempts:
		_is_reconnecting = false
		reconnect_failed.emit()
		print("ReconnectHandler: All reconnect attempts failed")
		return
	
	reconnect_attempt_made.emit(_reconnect_attempts, _max_attempts)
	print("ReconnectHandler: Attempt %d/%d - Connecting to %s:%d" % [_reconnect_attempts, _max_attempts, _last_server_ip, _last_server_port])
	
	var error = NetworkManager.join_game(_last_server_ip, _last_server_port, _last_player_name)
	
	if error != OK:
		# Schedule next attempt
		_reconnect_timer.wait_time = _reconnect_delay
		_reconnect_timer.start()
	else:
		# Connection initiated, wait for result via NetworkManager signals
		NetworkManager.connection_state_changed.connect(_on_connection_state_changed, CONNECT_ONE_SHOT)

func _on_connection_state_changed(new_state: NetworkManager.ConnectionState) -> void:
	if not _is_reconnecting:
		return
	
	if new_state == NetworkManager.ConnectionState.CONNECTED:
		_is_reconnecting = false
		reconnect_succeeded.emit()
		print("ReconnectHandler: Reconnected successfully!")
	elif new_state == NetworkManager.ConnectionState.DISCONNECTED:
		# Failed, try again after delay
		_reconnect_timer.wait_time = _reconnect_delay
		_reconnect_timer.start()

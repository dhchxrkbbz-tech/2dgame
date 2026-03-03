## SessionManager - Session lifecycle kezelés
## Auto-save, disconnect kezelés, session state management
extends Node

# --- Session state ---
var _session_active: bool = false
var _session_start_time: float = 0.0
var _disconnected_players: Dictionary = {}  # peer_id → { disconnect_time, player_data }

# --- Settings ---
const AUTO_SAVE_INTERVAL: float = 300.0  # 5 minutes
const RECONNECT_TIMEOUT: float = 300.0   # 5 minutes
const MAX_SESSION_TIME: float = 86400.0  # 24 hours (safety limit)

# --- Auto-save timer ---
var _auto_save_timer: Timer

# --- Reconnect cleanup timer ---
var _reconnect_timer: Timer

# --- Signals ---
signal session_started()
signal session_ended()
signal auto_save_triggered()
signal player_reconnected(peer_id: int)
signal player_timed_out(peer_id: int)

func _ready() -> void:
	_setup_timers()

func _setup_timers() -> void:
	# Auto-save timer
	_auto_save_timer = Timer.new()
	_auto_save_timer.name = "AutoSaveTimer"
	_auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	_auto_save_timer.autostart = false
	_auto_save_timer.timeout.connect(_on_auto_save)
	add_child(_auto_save_timer)
	
	# Reconnect cleanup timer (checks every 30 sec)
	_reconnect_timer = Timer.new()
	_reconnect_timer.name = "ReconnectCleanupTimer"
	_reconnect_timer.wait_time = 30.0
	_reconnect_timer.autostart = false
	_reconnect_timer.timeout.connect(_on_reconnect_cleanup)
	add_child(_reconnect_timer)

# === Public API ===

func start_session() -> void:
	_session_active = true
	_session_start_time = Time.get_ticks_msec() / 1000.0
	_disconnected_players.clear()
	
	_auto_save_timer.start()
	_reconnect_timer.start()
	
	session_started.emit()
	print("SessionManager: Session started")

func end_session() -> void:
	if not _session_active:
		return
	
	_session_active = false
	_auto_save_timer.stop()
	_reconnect_timer.stop()
	
	# Save before ending
	_perform_save()
	
	_disconnected_players.clear()
	session_ended.emit()
	print("SessionManager: Session ended")

func is_session_active() -> bool:
	return _session_active

func get_session_duration() -> float:
	if not _session_active:
		return 0.0
	return Time.get_ticks_msec() / 1000.0 - _session_start_time

func handle_disconnect(peer_id: int) -> void:
	if not _session_active or not NetworkManager.is_server():
		return
	
	# Store player data for potential reconnect
	var player_data = NetworkManager.lobby_manager.get_player_data(peer_id)
	if player_data.is_empty():
		return
	
	_disconnected_players[peer_id] = {
		"disconnect_time": Time.get_ticks_msec() / 1000.0,
		"player_data": player_data,
	}
	
	print("SessionManager: Player %d disconnected, waiting for reconnect (timeout: %ds)" % [peer_id, RECONNECT_TIMEOUT])

func handle_reconnect(peer_id: int, player_name: String) -> bool:
	if not _session_active or not NetworkManager.is_server():
		return false
	
	# Check if this player was recently disconnected
	# Match by player name (since peer_id may change)
	for old_peer_id in _disconnected_players:
		var data = _disconnected_players[old_peer_id]
		if data["player_data"].get("player_name", "") == player_name:
			var elapsed = Time.get_ticks_msec() / 1000.0 - data["disconnect_time"]
			if elapsed < RECONNECT_TIMEOUT:
				# Reconnect successful
				_disconnected_players.erase(old_peer_id)
				player_reconnected.emit(peer_id)
				
				# Send full world delta to reconnected player
				NetworkManager.sync_manager.world_sync.server_send_full_delta(peer_id)
				
				print("SessionManager: Player %s reconnected (was peer %d, now %d)" % [player_name, old_peer_id, peer_id])
				return true
	
	return false

func get_disconnected_players() -> Dictionary:
	return _disconnected_players.duplicate(true)

# === Auto-Save ===

func _on_auto_save() -> void:
	if not _session_active:
		return
	
	auto_save_triggered.emit()
	_perform_save()

func _perform_save() -> void:
	if not NetworkManager.is_server():
		return
	
	var save_data = {
		"session_time": get_session_duration(),
		"world_seed": NetworkManager.world_seed,
		"players": {},
		"world_modifications": [],
	}
	
	# Collect player data
	var lobby_players = NetworkManager.lobby_manager.get_all_players()
	for peer_id in lobby_players:
		save_data["players"][peer_id] = lobby_players[peer_id]
	
	# Collect world modifications
	save_data["world_modifications"] = NetworkManager.sync_manager.world_sync._world_modifications.duplicate()
	
	# Delegate to SaveManager (autoload)
	if Engine.has_singleton("SaveManager") or get_node_or_null("/root/SaveManager"):
		var save_mgr = get_node_or_null("/root/SaveManager")
		if save_mgr and save_mgr.has_method("save_multiplayer_session"):
			save_mgr.save_multiplayer_session(save_data)
	
	print("SessionManager: Auto-save performed (session time: %.0fs)" % get_session_duration())

# === Reconnect Cleanup ===

func _on_reconnect_cleanup() -> void:
	if not _session_active or not NetworkManager.is_server():
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	var timed_out: Array[int] = []
	
	for peer_id in _disconnected_players:
		var data = _disconnected_players[peer_id]
		var elapsed = current_time - data["disconnect_time"]
		
		if elapsed >= RECONNECT_TIMEOUT:
			timed_out.append(peer_id)
	
	for peer_id in timed_out:
		var player_name = _disconnected_players[peer_id]["player_data"].get("player_name", "Unknown")
		_disconnected_players.erase(peer_id)
		player_timed_out.emit(peer_id)
		print("SessionManager: Player %s (peer %d) timed out and was removed" % [player_name, peer_id])

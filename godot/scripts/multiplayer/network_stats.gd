## NetworkStats - Hálózati statisztika monitoring
## Ping, packet loss, bandwidth, entity count
## Debug overlay (F3)
extends Node

# --- Stats per peer ---
var _peer_stats: Dictionary = {}  # peer_id → stats dict
var _local_stats: Dictionary = {
	"ping_ms": 0,
	"packet_loss": 0.0,
	"bandwidth_up": 0.0,  # KB/s
	"bandwidth_down": 0.0,  # KB/s
	"synced_entities": 0,
	"actual_tick_rate": 0.0,
}

# --- Ping tracking ---
var _ping_timer: Timer
var _ping_send_time: float = 0.0
var _ping_history: Array[float] = []
const PING_INTERVAL: float = 1.0
const PING_HISTORY_SIZE: int = 10

# --- Tick rate tracking ---
var _tick_count_timer: Timer
var _ticks_this_second: int = 0

# --- Signals ---
signal stats_updated(stats: Dictionary)

func _ready() -> void:
	_setup_ping_timer()
	_setup_tick_rate_tracker()

func _setup_ping_timer() -> void:
	_ping_timer = Timer.new()
	_ping_timer.name = "PingTimer"
	_ping_timer.wait_time = PING_INTERVAL
	_ping_timer.autostart = false
	_ping_timer.timeout.connect(_send_ping)
	add_child(_ping_timer)

func _setup_tick_rate_tracker() -> void:
	_tick_count_timer = Timer.new()
	_tick_count_timer.name = "TickRateTimer"
	_tick_count_timer.wait_time = 1.0
	_tick_count_timer.autostart = false
	_tick_count_timer.timeout.connect(_calculate_tick_rate)
	add_child(_tick_count_timer)
	
	# Count ticks via NetworkManager signal
	if NetworkManager:
		NetworkManager.network_tick.connect(_on_network_tick)

# === Public API ===

func start_monitoring() -> void:
	_ping_timer.start()
	_tick_count_timer.start()

func stop_monitoring() -> void:
	_ping_timer.stop()
	_tick_count_timer.stop()

func register_peer(peer_id: int) -> void:
	_peer_stats[peer_id] = {
		"ping_ms": 0,
		"connected_time": Time.get_ticks_msec() / 1000.0,
	}
	
	if NetworkManager.current_state != NetworkManager.ConnectionState.DISCONNECTED:
		start_monitoring()

func unregister_peer(peer_id: int) -> void:
	_peer_stats.erase(peer_id)
	
	if _peer_stats.is_empty() and not NetworkManager.is_server():
		stop_monitoring()

func get_stats() -> Dictionary:
	return _local_stats.duplicate()

func get_ping() -> int:
	return _local_stats["ping_ms"]

func get_ping_color() -> Color:
	var ping = _local_stats["ping_ms"]
	if ping < 50:
		return Color.GREEN
	elif ping < 150:
		return Color.YELLOW
	else:
		return Color.RED

func get_connection_quality() -> String:
	var ping = _local_stats["ping_ms"]
	if ping < 50:
		return "Excellent"
	elif ping < 100:
		return "Good"
	elif ping < 150:
		return "Fair"
	elif ping < 300:
		return "Poor"
	else:
		return "Critical"

func get_synced_entity_count() -> int:
	return _local_stats["synced_entities"]

# === Ping RPCs ===

func _send_ping() -> void:
	if NetworkManager.current_state == NetworkManager.ConnectionState.DISCONNECTED:
		return
	
	_ping_send_time = Time.get_ticks_msec() / 1000.0
	
	if NetworkManager.is_server():
		# Host pings each client
		for peer_id in _peer_stats:
			if peer_id != 1:
				_rpc_ping.rpc_id(peer_id)
	else:
		# Client pings host
		_rpc_ping.rpc_id(1)

@rpc("any_peer", "unreliable")
func _rpc_ping() -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	_rpc_pong.rpc_id(sender_id)

@rpc("any_peer", "unreliable")
func _rpc_pong() -> void:
	var rtt = (Time.get_ticks_msec() / 1000.0 - _ping_send_time) * 1000.0  # ms
	
	_ping_history.append(rtt)
	while _ping_history.size() > PING_HISTORY_SIZE:
		_ping_history.pop_front()
	
	# Average ping
	var total = 0.0
	for p in _ping_history:
		total += p
	_local_stats["ping_ms"] = int(total / _ping_history.size())
	
	_emit_stats()

# === Tick Rate ===

func _on_network_tick(_tick: int) -> void:
	_ticks_this_second += 1

func _calculate_tick_rate() -> void:
	_local_stats["actual_tick_rate"] = float(_ticks_this_second)
	_ticks_this_second = 0
	
	# Count synced entities
	if NetworkManager.sync_manager:
		var enemy_count = NetworkManager.sync_manager.enemy_sync.get_all_synced_enemies().size()
		var proj_count = NetworkManager.sync_manager.projectile_sync.get_active_projectiles().size()
		_local_stats["synced_entities"] = enemy_count + proj_count + NetworkManager.get_player_count()
	
	_emit_stats()

func _emit_stats() -> void:
	stats_updated.emit(_local_stats)

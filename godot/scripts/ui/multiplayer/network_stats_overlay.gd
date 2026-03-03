## NetworkStatsOverlay - Debug hálózati statisztika kijelző (F3)
## Ping, packet loss, bandwidth, entity count, tick rate
extends CanvasLayer

@onready var panel: PanelContainer = $PanelContainer
@onready var stats_label: Label = $PanelContainer/MarginContainer/StatsLabel

var _visible: bool = false

func _ready() -> void:
	layer = 100  # On top of everything
	panel.visible = false
	
	if NetworkManager.network_stats:
		NetworkManager.network_stats.stats_updated.connect(_on_stats_updated)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		_visible = !_visible
		panel.visible = _visible

func _on_stats_updated(stats: Dictionary) -> void:
	if not _visible:
		return
	
	var ping = stats.get("ping_ms", 0)
	var ping_color = NetworkManager.network_stats.get_ping_color()
	var quality = NetworkManager.network_stats.get_connection_quality()
	var tick_rate = stats.get("actual_tick_rate", 0.0)
	var synced = stats.get("synced_entities", 0)
	var player_count = NetworkManager.get_player_count()
	var session_time = NetworkManager.session_manager.get_session_duration()
	
	var text = ""
	text += "=== NETWORK STATS ===\n"
	text += "Ping: %d ms (%s)\n" % [ping, quality]
	text += "Tick Rate: %.1f / %d\n" % [tick_rate, NetworkManager.TICK_RATE]
	text += "Synced Entities: %d\n" % synced
	text += "Players: %d / 4\n" % player_count
	text += "Session: %.0f sec\n" % session_time
	text += "Role: %s\n" % ("HOST" if NetworkManager.is_server() else "CLIENT")
	text += "Peer ID: %d\n" % NetworkManager.local_peer_id
	text += "State: %s" % NetworkManager._state_to_string(NetworkManager.current_state)
	
	stats_label.text = text

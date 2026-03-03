## ChatSystem - In-game chat rendszer
## RPC-alapú üzenetküldés, reliable channel
class_name ChatSystem
extends Node

signal message_received(sender_name: String, message: String, channel: ChatChannel)
signal system_message(message: String)

enum ChatChannel {
	GLOBAL,      # Mindenki látja
	PARTY,       # Csak a party
	WHISPER,     # Privát üzenet
	SYSTEM,      # Rendszer üzenetek
	TRADE,       # Kereskedési csatorna
}

# === Chat beállítások ===
const MAX_MESSAGE_LENGTH: int = 200
const MAX_MESSAGES: int = 100
const COOLDOWN_SECONDS: float = 0.5
const FLOOD_LIMIT: int = 5        # Max üzenet / 10 sec
const FLOOD_WINDOW: float = 10.0

# === Állapot ===
var chat_history: Array[Dictionary] = []  # {sender, message, channel, timestamp}
var current_channel: ChatChannel = ChatChannel.GLOBAL
var is_chat_open: bool = false
var last_message_time: float = 0.0
var recent_message_times: Array[float] = []

# === Cenzúra szűrő ===
var banned_words: Array[String] = []


func _ready() -> void:
	add_to_group("chat_system")


## Üzenet küldése
func send_message(message: String, channel: ChatChannel = ChatChannel.GLOBAL, target_peer: int = -1) -> void:
	# Validation
	message = message.strip_edges()
	if message.is_empty():
		return
	if message.length() > MAX_MESSAGE_LENGTH:
		message = message.substr(0, MAX_MESSAGE_LENGTH)
	
	# Cooldown check
	var now := Time.get_ticks_msec() / 1000.0
	if now - last_message_time < COOLDOWN_SECONDS:
		_add_system_message("Túl gyorsan írsz!")
		return
	
	# Flood protection
	recent_message_times = recent_message_times.filter(func(t): return now - t < FLOOD_WINDOW)
	if recent_message_times.size() >= FLOOD_LIMIT:
		_add_system_message("Flood protection - várj egy kicsit!")
		return
	
	# Cenzúra
	message = _filter_message(message)
	
	last_message_time = now
	recent_message_times.append(now)
	
	# Lokális player neve
	var sender_name: String = _get_local_player_name()
	
	if multiplayer.has_multiplayer_peer():
		match channel:
			ChatChannel.GLOBAL:
				_rpc_broadcast_message.rpc(sender_name, message, channel)
			ChatChannel.PARTY:
				_rpc_broadcast_message.rpc(sender_name, message, channel)
			ChatChannel.WHISPER:
				if target_peer > 0:
					_rpc_receive_message.rpc_id(target_peer, sender_name, message, channel)
					_add_message(sender_name, message, channel)  # Lokális megjelenítés
			ChatChannel.TRADE:
				_rpc_broadcast_message.rpc(sender_name, message, channel)
	else:
		_add_message(sender_name, message, channel)


## RPC: Üzenet broadcast (minden peer kapja)
@rpc("any_peer", "reliable")
func _rpc_broadcast_message(sender_name: String, message: String, channel: int) -> void:
	_add_message(sender_name, message, channel as ChatChannel)


## RPC: Direkt üzenet (whisper)
@rpc("any_peer", "reliable")
func _rpc_receive_message(sender_name: String, message: String, channel: int) -> void:
	_add_message(sender_name, message, channel as ChatChannel)


## Üzenet hozzáadása a history-hoz
func _add_message(sender_name: String, message: String, channel: ChatChannel) -> void:
	var entry := {
		"sender": sender_name,
		"message": message,
		"channel": channel,
		"timestamp": Time.get_ticks_msec() / 1000.0,
	}
	
	chat_history.append(entry)
	if chat_history.size() > MAX_MESSAGES:
		chat_history.pop_front()
	
	message_received.emit(sender_name, message, channel)


func _add_system_message(message: String) -> void:
	_add_message("System", message, ChatChannel.SYSTEM)
	system_message.emit(message)


## Szűrt üzenet
func _filter_message(message: String) -> String:
	var filtered := message
	for word in banned_words:
		var regex := RegEx.new()
		regex.compile("(?i)" + word)
		filtered = regex.sub(filtered, "***", true)
	return filtered


## Lokális player neve
func _get_local_player_name() -> String:
	if GameManager.has_method("get_player_name"):
		return GameManager.get_player_name()
	return "Player_%d" % multiplayer.get_unique_id()


## Chat history szűrése csatorna szerint
func get_messages_for_channel(channel: ChatChannel) -> Array[Dictionary]:
	return chat_history.filter(func(msg): return msg["channel"] == channel or channel == ChatChannel.GLOBAL)


## Csatorna váltás
func set_channel(channel: ChatChannel) -> void:
	current_channel = channel


## Chat megnyitása/bezárása
func toggle_chat() -> void:
	is_chat_open = not is_chat_open
	EventBus.chat_toggled.emit(is_chat_open)


## Rendszer üzenet küldése (host only)
func send_system_message(message: String) -> void:
	if multiplayer.is_server() or not multiplayer.has_multiplayer_peer():
		_rpc_broadcast_message.rpc("System", message, ChatChannel.SYSTEM)

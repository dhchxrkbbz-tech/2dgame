## QuestSync - Multiplayer quest szinkronizáció
## Közös quest progress megosztás co-op módban
class_name QuestSync
extends Node

# === Állapot ===
var _syncing: bool = false
var _sync_timer: float = 0.0
const SYNC_INTERVAL: float = 2.0  ## 2 másodpercenként sync


func _ready() -> void:
	if not multiplayer:
		return
	
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	# EventBus quest signal-ok
	EventBus.quest_accepted.connect(_on_local_quest_accepted)
	EventBus.quest_completed.connect(_on_local_quest_completed)
	EventBus.quest_turned_in.connect(_on_local_quest_turned_in)
	EventBus.quest_progress_updated.connect(_on_local_quest_progress)


func _process(delta: float) -> void:
	if not _syncing or not multiplayer.has_multiplayer_peer():
		return
	
	_sync_timer += delta
	if _sync_timer >= SYNC_INTERVAL:
		_sync_timer = 0.0
		_periodic_sync()


# ═══════════════════════════════════════════════════════════════
#  MULTIPLAYER LIFECYCLE
# ═══════════════════════════════════════════════════════════════

func start_sync() -> void:
	_syncing = true
	_sync_timer = 0.0
	print("QuestSync: Started syncing")


func stop_sync() -> void:
	_syncing = false
	print("QuestSync: Stopped syncing")


func _on_peer_connected(peer_id: int) -> void:
	if not _syncing:
		return
	# Új peer-nek elküldjük az aktív quest állapotunkat
	_send_full_state_to.rpc_id(peer_id, _get_serialized_quest_state())


func _on_peer_disconnected(_peer_id: int) -> void:
	pass  # Nem kell semmit csinálni


# ═══════════════════════════════════════════════════════════════
#  LOCAL EVENT HANDLERS → RPC BROADCAST
# ═══════════════════════════════════════════════════════════════

func _on_local_quest_accepted(quest_id: String) -> void:
	if not _syncing or not multiplayer.has_multiplayer_peer():
		return
	_notify_quest_accepted.rpc(quest_id)


func _on_local_quest_completed(quest_id: String) -> void:
	if not _syncing or not multiplayer.has_multiplayer_peer():
		return
	_notify_quest_completed.rpc(quest_id)


func _on_local_quest_turned_in(quest_id: String) -> void:
	if not _syncing or not multiplayer.has_multiplayer_peer():
		return
	_notify_quest_turned_in.rpc(quest_id)


func _on_local_quest_progress(quest_id: String, obj_idx: int, current: int, target: int) -> void:
	if not _syncing or not multiplayer.has_multiplayer_peer():
		return
	_sync_quest_progress.rpc(quest_id, obj_idx, current, target)


# ═══════════════════════════════════════════════════════════════
#  RPC HANDLERS (OTHER PEERS)
# ═══════════════════════════════════════════════════════════════

## Periodikus szinkronizáció
func _periodic_sync() -> void:
	if not multiplayer.has_multiplayer_peer():
		return
	
	# Csak az aktív quest-ek progress-ét küldjük
	var sync_data: Dictionary = {}
	for quest_id in QuestManager.active_quest_ids:
		if QuestManager.quest_database.has(quest_id):
			var quest: QuestData = QuestManager.quest_database[quest_id]
			var obj_data: Dictionary = {}
			for i in range(quest.objectives.size()):
				if quest.objectives[i] is QuestObjective:
					obj_data[i] = quest.objectives[i].current_count
			sync_data[quest_id] = obj_data
	
	if not sync_data.is_empty():
		_receive_periodic_sync.rpc(JSON.stringify(sync_data))


@rpc("any_peer", "reliable")
func _send_full_state_to(state_json: String) -> void:
	var state: Dictionary = JSON.parse_string(state_json)
	if state == null:
		return
	
	var active_ids: Array = state.get("active_quest_ids", [])
	var quest_progress_data: Dictionary = state.get("quest_progress", {})
	
	for quest_id in active_ids:
		# Ha a másik játékos is rendelkezik ezzel a quest-tel
		if quest_id in QuestManager.active_quest_ids and quest_progress_data.has(quest_id):
			_merge_quest_progress(quest_id, quest_progress_data[quest_id])


@rpc("any_peer", "reliable")
func _notify_quest_accepted(quest_id: String) -> void:
	# Értesítés: a másik játékos felvette ezt a quest-et
	var sender_id: int = multiplayer.get_remote_sender_id()
	if QuestManager.quest_database.has(quest_id):
		var quest: QuestData = QuestManager.quest_database[quest_id]
		EventBus.show_notification.emit(
			"Party member accepted: %s" % quest.quest_name,
			Enums.NotificationType.INFO
		)


@rpc("any_peer", "reliable")
func _notify_quest_completed(quest_id: String) -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	if QuestManager.quest_database.has(quest_id):
		var quest: QuestData = QuestManager.quest_database[quest_id]
		EventBus.show_notification.emit(
			"Party member completed: %s" % quest.quest_name,
			Enums.NotificationType.INFO
		)


@rpc("any_peer", "reliable")
func _notify_quest_turned_in(quest_id: String) -> void:
	# Ha mi is aktívan dolgozunk ezen a quest-en, automatikusan befejezzük
	if quest_id in QuestManager.active_quest_ids:
		var quest: QuestData = QuestManager.quest_database.get(quest_id)
		if quest and quest.quest_type != QuestData.QuestType.MAIN_STORY:
			# Shared quest-eknél (nem main story) szinkronban haladunk
			pass


@rpc("any_peer", "unreliable")
func _sync_quest_progress(quest_id: String, obj_idx: int, current: int, target: int) -> void:
	## Közös quest-eknél a magasabb progress-t vesszük
	if quest_id not in QuestManager.active_quest_ids:
		return
	
	if not QuestManager.quest_database.has(quest_id):
		return
	
	var quest: QuestData = QuestManager.quest_database[quest_id]
	if obj_idx < 0 or obj_idx >= quest.objectives.size():
		return
	
	var obj: QuestObjective = quest.objectives[obj_idx]
	if obj is QuestObjective:
		# A magasabb progress nyer (co-op friendly)
		if current > obj.current_count:
			obj.current_count = current
			QuestManager._check_quest_completion(quest_id)


@rpc("any_peer", "unreliable")
func _receive_periodic_sync(data_json: String) -> void:
	var data: Dictionary = JSON.parse_string(data_json)
	if data == null:
		return
	
	for quest_id in data:
		if quest_id in QuestManager.active_quest_ids:
			_merge_quest_progress(quest_id, data[quest_id])


func _merge_quest_progress(quest_id: String, progress_data: Dictionary) -> void:
	if not QuestManager.quest_database.has(quest_id):
		return
	
	var quest: QuestData = QuestManager.quest_database[quest_id]
	var changed: bool = false
	
	for idx_str in progress_data:
		var idx: int = int(idx_str)
		if idx < 0 or idx >= quest.objectives.size():
			continue
		
		var remote_count: int = int(progress_data[idx_str])
		var obj: QuestObjective = quest.objectives[idx]
		
		if obj is QuestObjective and remote_count > obj.current_count:
			obj.current_count = remote_count
			changed = true
	
	if changed:
		QuestManager._check_quest_completion(quest_id)


func _get_serialized_quest_state() -> String:
	var state: Dictionary = {
		"active_quest_ids": QuestManager.active_quest_ids.duplicate(),
		"quest_progress": {}
	}
	
	for quest_id in QuestManager.active_quest_ids:
		if QuestManager.quest_database.has(quest_id):
			var quest: QuestData = QuestManager.quest_database[quest_id]
			var obj_progress: Dictionary = {}
			for i in range(quest.objectives.size()):
				if quest.objectives[i] is QuestObjective:
					obj_progress[i] = quest.objectives[i].current_count
			state["quest_progress"][quest_id] = obj_progress
	
	return JSON.stringify(state)

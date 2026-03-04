## QuestLogUI - Quest lista megjelenítés
## Aktív és befejezett quest-ek, tracking
class_name QuestLogUI
extends Control

signal quest_tracked(quest_id: String)
signal quest_abandoned(quest_id: String)

# === UI elemek ===
var quest_list: VBoxContainer = null
var quest_detail: RichTextLabel = null
var tab_buttons: Array[Button] = []
var close_button: Button = null
var track_button: Button = null
var abandon_button: Button = null

# === Állapot ===
enum Tab { ACTIVE, COMPLETED, DAILY }
var current_tab: Tab = Tab.ACTIVE
var selected_quest_id: String = ""
var tracked_quest_id: String = ""

# === Quest adatok (QuestManager-ből) ===
var quests: Array[Dictionary] = []


func _ready() -> void:
	visible = false
	_build_ui()
	
	# EventBus-ra feliratkozás a frissítésekhez
	EventBus.quest_accepted.connect(func(_id): _refresh_from_manager())
	EventBus.quest_completed.connect(func(_id): _refresh_from_manager())
	EventBus.quest_turned_in.connect(func(_id): _refresh_from_manager())
	EventBus.quest_abandoned.connect(func(_id): _refresh_from_manager())
	EventBus.quest_failed.connect(func(_id): _refresh_from_manager())
	EventBus.quest_progress_updated.connect(func(_id, _oi, _c, _t): _refresh_from_manager())


func _build_ui() -> void:
	# Háttér
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 0.9)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	# Cím
	var title := Label.new()
	title.text = "QUEST LOG"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 10)
	title.size = Vector2(640, 30)
	add_child(title)
	
	# Tab gombok
	var tab_names := ["Active", "Completed", "Daily/Weekly"]
	for i in range(tab_names.size()):
		var btn := Button.new()
		btn.text = tab_names[i]
		btn.position = Vector2(10 + i * 100, 40)
		btn.size = Vector2(90, 25)
		btn.pressed.connect(_on_tab_pressed.bind(i))
		add_child(btn)
		tab_buttons.append(btn)
	
	# Quest lista (bal oldal)
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(10, 75)
	scroll.size = Vector2(250, 280)
	add_child(scroll)
	
	quest_list = VBoxContainer.new()
	quest_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(quest_list)
	
	# Quest részletek (jobb oldal)
	quest_detail = RichTextLabel.new()
	quest_detail.position = Vector2(270, 75)
	quest_detail.size = Vector2(360, 250)
	quest_detail.bbcode_enabled = true
	quest_detail.text = "Select a quest to view details."
	add_child(quest_detail)
	
	# Track gomb
	track_button = Button.new()
	track_button.text = "Track"
	track_button.position = Vector2(270, 330)
	track_button.size = Vector2(80, 25)
	track_button.pressed.connect(_on_track_pressed)
	track_button.visible = false
	add_child(track_button)
	
	# Abandon gomb
	abandon_button = Button.new()
	abandon_button.text = "Abandon"
	abandon_button.position = Vector2(360, 330)
	abandon_button.size = Vector2(80, 25)
	abandon_button.pressed.connect(_on_abandon_pressed)
	abandon_button.visible = false
	add_child(abandon_button)
	
	# Bezárás
	close_button = Button.new()
	close_button.text = "X"
	close_button.position = Vector2(600, 10)
	close_button.size = Vector2(30, 30)
	close_button.pressed.connect(func(): visible = false)
	add_child(close_button)


## Quest log megnyitása (QuestManager-ből automatikusan frissít)
func open(p_quests: Array[Dictionary] = []) -> void:
	if p_quests.is_empty():
		_refresh_from_manager()
	else:
		quests = p_quests
	visible = true
	tracked_quest_id = QuestManager.tracked_quest_id
	_refresh_list()


## QuestManager-ből adatokat húzni
func _refresh_from_manager() -> void:
	quests.clear()
	
	# Aktív quest-ek
	for quest_id in QuestManager.active_quest_ids:
		if QuestManager.quest_database.has(quest_id):
			var quest: QuestData = QuestManager.quest_database[quest_id]
			var state: int = QuestManager.quest_states.get(quest_id, 0)
			quests.append(_quest_to_dict(quest, quest_id, state))
	
	# Completed quest-ek
	for quest_id in QuestManager.completed_quests:
		if QuestManager.quest_database.has(quest_id):
			var quest: QuestData = QuestManager.quest_database[quest_id]
			quests.append(_quest_to_dict(quest, quest_id, QuestManager.QuestState.TURNED_IN))
	
	tracked_quest_id = QuestManager.tracked_quest_id
	
	if visible:
		_refresh_list()


func _quest_to_dict(quest: QuestData, quest_id: String, state: int) -> Dictionary:
	var status_str: String = "active"
	if state == QuestManager.QuestState.COMPLETE:
		status_str = "ready"
	elif state == QuestManager.QuestState.TURNED_IN:
		status_str = "completed"
	elif state == QuestManager.QuestState.FAILED:
		status_str = "failed"
	
	var is_daily: bool = quest.quest_type == QuestData.QuestType.DAILY
	var is_weekly: bool = quest.quest_type == QuestData.QuestType.WEEKLY
	
	var objectives: Array = []
	for obj in quest.objectives:
		if obj is QuestObjective:
			objectives.append({
				"text": obj.description,
				"current": obj.current_count,
				"target": obj.target_count,
				"completed": obj.is_completed()
			})
	
	var reward_texts: Array = []
	if quest.rewards:
		reward_texts = quest.rewards.get_reward_texts()
	
	var rewards: Array = []
	for rt in reward_texts:
		rewards.append({"text": rt})
	
	return {
		"id": quest_id,
		"name": quest.quest_name,
		"description": quest.description,
		"status": status_str,
		"is_daily": is_daily,
		"is_weekly": is_weekly,
		"objectives": objectives,
		"rewards": rewards,
		"recommended_level": quest.recommended_level,
	}


func close() -> void:
	visible = false


## Lista frissítése
func _refresh_list() -> void:
	for child in quest_list.get_children():
		child.queue_free()
	
	var filtered := quests.filter(func(q):
		match current_tab:
			Tab.ACTIVE:
				var status: String = q.get("status", "active")
				return (status == "active" or status == "ready") and not q.get("is_daily", false) and not q.get("is_weekly", false)
			Tab.COMPLETED:
				return q.get("status", "") == "completed"
			Tab.DAILY:
				return q.get("is_daily", false) or q.get("is_weekly", false)
			_: return true
	)
	
	for quest in filtered:
		var btn := Button.new()
		var quest_name: String = quest.get("name", "Unknown Quest")
		var is_tracked := quest.get("id", "") == tracked_quest_id
		btn.text = ("[T] " if is_tracked else "") + quest_name
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_quest_selected.bind(quest.get("id", "")))
		quest_list.add_child(btn)


func _on_tab_pressed(tab_idx: int) -> void:
	current_tab = tab_idx as Tab
	_refresh_list()


func _on_quest_selected(quest_id: String) -> void:
	selected_quest_id = quest_id
	_show_quest_detail(quest_id)
	
	# Gombok megjelenítése aktív quest-eknél
	var quest := _find_quest(quest_id)
	var status: String = quest.get("status", "")
	track_button.visible = (status == "active" or status == "ready")
	abandon_button.visible = (status == "active")


func _show_quest_detail(quest_id: String) -> void:
	var quest := _find_quest(quest_id)
	if quest.is_empty():
		quest_detail.text = "Quest not found."
		return
	
	var status: String = quest.get("status", "active")
	var status_color: String = "white"
	var status_text: String = "Active"
	match status:
		"active": status_color = "yellow"; status_text = "In Progress"
		"ready": status_color = "green"; status_text = "Ready to Turn In"
		"completed": status_color = "gray"; status_text = "Completed"
		"failed": status_color = "red"; status_text = "Failed"
	
	var text := "[b]%s[/b]\n" % quest.get("name", "?")
	text += "[color=%s]%s[/color]" % [status_color, status_text]
	
	var rec_level: int = quest.get("recommended_level", 0)
	if rec_level > 0:
		text += "  |  Lv. %d" % rec_level
	
	if quest.get("is_daily", false):
		text += "  |  [color=cyan]Daily[/color]"
	elif quest.get("is_weekly", false):
		text += "  |  [color=magenta]Weekly[/color]"
	
	text += "\n\n%s\n\n" % quest.get("description", "")
	text += "[b]Objectives:[/b]\n"
	
	var objectives: Array = quest.get("objectives", [])
	for obj in objectives:
		var completed: bool = obj.get("completed", false)
		var prefix := "[color=green]✓[/color]" if completed else "[color=gray]○[/color]"
		text += "  %s %s (%d/%d)\n" % [prefix, obj.get("text", ""), obj.get("current", 0), obj.get("target", 1)]
	
	text += "\n[b]Rewards:[/b]\n"
	var rewards: Array = quest.get("rewards", [])
	for reward in rewards:
		text += "  • %s\n" % reward.get("text", "?")
	
	quest_detail.text = text


func _find_quest(quest_id: String) -> Dictionary:
	for quest in quests:
		if quest.get("id", "") == quest_id:
			return quest
	return {}


## Tracking
func track_quest(quest_id: String) -> void:
	tracked_quest_id = quest_id
	QuestManager.tracked_quest_id = quest_id
	EventBus.quest_tracking_changed.emit(quest_id)
	quest_tracked.emit(quest_id)
	_refresh_list()


func _on_track_pressed() -> void:
	if not selected_quest_id.is_empty():
		track_quest(selected_quest_id)


func _on_abandon_pressed() -> void:
	if not selected_quest_id.is_empty():
		QuestManager.abandon_quest(selected_quest_id)
		quest_abandoned.emit(selected_quest_id)
		selected_quest_id = ""
		quest_detail.text = "Quest abandoned."
		track_button.visible = false
		abandon_button.visible = false
		_refresh_from_manager()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

## QuestTracker - HUD-ra rajzoló mini quest tracker
## Jobb oldalon mutatja a tracked quest nevét, objective-et, progress-t
class_name QuestTracker
extends Control

# === UI elemek ===
var _container: VBoxContainer = null
var _quest_entries: Array[Control] = []

# === Beállítások ===
const MAX_DISPLAYED_QUESTS: int = 3
const TRACKER_WIDTH: float = 180.0
const TRACKER_MARGIN: float = 8.0
const FADE_DURATION: float = 0.3


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_ui()
	
	# EventBus signals
	EventBus.quest_accepted.connect(_on_quest_changed)
	EventBus.quest_completed.connect(_on_quest_changed)
	EventBus.quest_progress_updated.connect(_on_quest_progress)
	EventBus.quest_turned_in.connect(_on_quest_changed)
	EventBus.quest_abandoned.connect(_on_quest_changed)
	EventBus.quest_failed.connect(_on_quest_changed)
	EventBus.quest_tracking_changed.connect(_on_quest_changed)
	
	# Késleltetett frissítés a _ready után
	call_deferred("refresh")


func _build_ui() -> void:
	# Pozíció: jobb felső sarok
	set_anchors_preset(PRESET_TOP_RIGHT)
	position = Vector2(-TRACKER_WIDTH - TRACKER_MARGIN, TRACKER_MARGIN + 30)
	size = Vector2(TRACKER_WIDTH, 200)
	
	# Háttér
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.4)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	
	# Quest lista
	_container = VBoxContainer.new()
	_container.position = Vector2(4, 4)
	_container.size = Vector2(TRACKER_WIDTH - 8, 192)
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_container.add_theme_constant_override("separation", 6)
	add_child(_container)


func refresh() -> void:
	# Régi elemek törlése
	for entry in _quest_entries:
		if is_instance_valid(entry):
			entry.queue_free()
	_quest_entries.clear()
	
	# Gyűjtjük a megjelenítendő quest-eket
	var display_quests: Array[Dictionary] = []
	
	# Tracked quest mindig az első
	if not QuestManager.tracked_quest_id.is_empty():
		var data := _get_quest_display_data(QuestManager.tracked_quest_id)
		if not data.is_empty():
			data["is_tracked"] = true
			display_quests.append(data)
	
	# Többi aktív quest (tracked-en kívül)
	for quest_id in QuestManager.active_quest_ids:
		if quest_id == QuestManager.tracked_quest_id:
			continue
		if display_quests.size() >= MAX_DISPLAYED_QUESTS:
			break
		var data := _get_quest_display_data(quest_id)
		if not data.is_empty():
			data["is_tracked"] = false
			display_quests.append(data)
	
	# UI elemek létrehozása
	for quest_data in display_quests:
		var entry := _create_quest_entry(quest_data)
		_container.add_child(entry)
		_quest_entries.append(entry)
	
	# Méret frissítés
	visible = not display_quests.is_empty()


func _get_quest_display_data(quest_id: String) -> Dictionary:
	if not QuestManager.quest_database.has(quest_id):
		return {}
	
	var quest: QuestData = QuestManager.quest_database[quest_id]
	var state: int = QuestManager.quest_states.get(quest_id, QuestManager.QuestState.NOT_AVAILABLE)
	
	if state != QuestManager.QuestState.ACTIVE and state != QuestManager.QuestState.COMPLETE:
		return {}
	
	# Aktuális (nem befejezett) objective keresése
	var current_obj_text: String = ""
	var current_progress: float = 0.0
	var current_count: int = 0
	var target_count: int = 1
	var all_done: bool = true
	
	for obj in quest.objectives:
		if obj is QuestObjective:
			if not obj.is_completed():
				current_obj_text = obj.get_display_text()
				current_progress = obj.get_progress_percent()
				current_count = obj.current_count
				target_count = obj.target_count
				all_done = false
				break
	
	if all_done and quest.objectives.size() > 0:
		current_obj_text = "Turn in quest"
		current_progress = 1.0
	
	return {
		"quest_id": quest_id,
		"name": quest.quest_name,
		"objective_text": current_obj_text,
		"progress": current_progress,
		"current": current_count,
		"target": target_count,
		"is_complete": state == QuestManager.QuestState.COMPLETE or all_done,
	}


func _create_quest_entry(data: Dictionary) -> Control:
	var entry := VBoxContainer.new()
	entry.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Quest név
	var name_label := Label.new()
	var quest_name: String = data.get("name", "Unknown")
	var is_tracked: bool = data.get("is_tracked", false)
	var is_complete: bool = data.get("is_complete", false)
	
	if is_tracked:
		name_label.text = "► " + quest_name
	else:
		name_label.text = quest_name
	
	if is_complete:
		name_label.add_theme_color_override("font_color", Color(0.4, 0.9, 0.4))
	elif is_tracked:
		name_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	else:
		name_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	entry.add_child(name_label)
	
	# Objective szöveg
	var obj_text: String = data.get("objective_text", "")
	if not obj_text.is_empty():
		var obj_label := Label.new()
		obj_label.text = "  " + obj_text
		obj_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		obj_label.add_theme_font_size_override("font_size", 8)
		obj_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		obj_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		entry.add_child(obj_label)
	
	# Progress bar
	var progress: float = data.get("progress", 0.0)
	if progress > 0.0 and progress < 1.0:
		var bar_bg := ColorRect.new()
		bar_bg.custom_minimum_size = Vector2(TRACKER_WIDTH - 16, 3)
		bar_bg.color = Color(0.15, 0.15, 0.15)
		bar_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
		entry.add_child(bar_bg)
		
		var bar_fill := ColorRect.new()
		bar_fill.custom_minimum_size = Vector2((TRACKER_WIDTH - 16) * progress, 3)
		bar_fill.color = Color(0.3, 0.7, 0.3) if not is_complete else Color(0.4, 0.9, 0.4)
		bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bar_bg.add_child(bar_fill)
	
	return entry


func _on_quest_changed(_quest_id: String) -> void:
	refresh()


func _on_quest_progress(_quest_id: String, _objective_idx: int, _current: int, _target: int) -> void:
	refresh()

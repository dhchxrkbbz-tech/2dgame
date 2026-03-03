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

# === Állapot ===
enum Tab { ACTIVE, COMPLETED, ALL }
var current_tab: Tab = Tab.ACTIVE
var selected_quest_id: String = ""
var tracked_quest_id: String = ""

# === Quest adatok ===
var quests: Array[Dictionary] = []


func _ready() -> void:
	visible = false
	_build_ui()


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
	var tab_names := ["Active", "Completed"]
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
	quest_detail.size = Vector2(360, 280)
	quest_detail.bbcode_enabled = true
	quest_detail.text = "Select a quest to view details."
	add_child(quest_detail)
	
	# Bezárás
	close_button = Button.new()
	close_button.text = "X"
	close_button.position = Vector2(600, 10)
	close_button.size = Vector2(30, 30)
	close_button.pressed.connect(func(): visible = false)
	add_child(close_button)


## Quest log megnyitása
func open(p_quests: Array[Dictionary]) -> void:
	quests = p_quests
	visible = true
	_refresh_list()


func close() -> void:
	visible = false


## Lista frissítése
func _refresh_list() -> void:
	for child in quest_list.get_children():
		child.queue_free()
	
	var filtered := quests.filter(func(q):
		match current_tab:
			Tab.ACTIVE: return q.get("status", "active") == "active"
			Tab.COMPLETED: return q.get("status", "") == "completed"
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


func _show_quest_detail(quest_id: String) -> void:
	var quest := _find_quest(quest_id)
	if quest.is_empty():
		quest_detail.text = "Quest not found."
		return
	
	var text := "[b]%s[/b]\n\n" % quest.get("name", "?")
	text += "%s\n\n" % quest.get("description", "")
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
	quest_tracked.emit(quest_id)
	_refresh_list()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

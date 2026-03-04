## DialogueManager - Párbeszéd kezelő (Autoload singleton)
## Párbeszédek betöltése, lejátszása, quest integráció
extends Node

# === Dialogue adatbázis ===
var dialogue_database: Dictionary = {}        ## dialogue_id → DialogueData

# === Aktív párbeszéd állapot ===
var current_dialogue: DialogueData = null
var current_line_index: int = 0
var is_dialogue_active: bool = false
var pending_quest_action: String = ""         ## "accept" / "turn_in"
var pending_quest_id: String = ""

# === Dialogue UI referencia ===
var dialogue_ui: Node = null

# === Lejátszott párbeszédek (save/load-hoz) ===
var played_dialogues: Array[String] = []


func _ready() -> void:
	_load_dialogue_database()
	
	# DialogueUI keresése
	call_deferred("_find_dialogue_ui")
	
	# EventBus quest dialogue signal
	if EventBus.has_signal("quest_dialogue_opened"):
		EventBus.quest_dialogue_opened.connect(_on_quest_dialogue_opened)
	
	print("DialogueManager: Initialized with %d dialogues" % dialogue_database.size())


func _find_dialogue_ui() -> void:
	# Keressük meg a DialogueUI-t a scene tree-ben
	var ui_nodes := get_tree().get_nodes_in_group("dialogue_ui")
	if not ui_nodes.is_empty():
		dialogue_ui = ui_nodes[0]
	else:
		# Fallback: keresés név alapján
		var root := get_tree().root
		dialogue_ui = root.find_child("DialogueUI", true, false)
	
	if dialogue_ui:
		_connect_ui_signals()


func _connect_ui_signals() -> void:
	if dialogue_ui == null:
		return
	
	if dialogue_ui.has_signal("dialogue_option_selected"):
		if not dialogue_ui.dialogue_option_selected.is_connected(_on_option_selected):
			dialogue_ui.dialogue_option_selected.connect(_on_option_selected)
	
	if dialogue_ui.has_signal("dialogue_closed"):
		if not dialogue_ui.dialogue_closed.is_connected(_on_dialogue_closed):
			dialogue_ui.dialogue_closed.connect(_on_dialogue_closed)


# ═══════════════════════════════════════════════════════════════
#  DIALOGUE LEJÁTSZÁS
# ═══════════════════════════════════════════════════════════════

## Párbeszéd indítása dialogue ID-vel
func start_dialogue(dialogue_id: String) -> void:
	if not dialogue_database.has(dialogue_id):
		push_warning("DialogueManager: Unknown dialogue '%s'" % dialogue_id)
		return
	
	current_dialogue = dialogue_database[dialogue_id]
	current_line_index = 0
	is_dialogue_active = true
	
	_show_current_line()


## Quest ajánlat párbeszéd
func start_quest_dialogue(quest: QuestData) -> void:
	pending_quest_action = "accept"
	pending_quest_id = quest.quest_id
	
	if not quest.dialogue_start.is_empty() and dialogue_database.has(quest.dialogue_start):
		start_dialogue(quest.dialogue_start)
	else:
		# Automatikus quest ajánlat párbeszéd generálás
		_show_auto_quest_offer(quest)


## Quest leadási párbeszéd
func start_turn_in_dialogue(quest: QuestData) -> void:
	pending_quest_action = "turn_in"
	pending_quest_id = quest.quest_id
	
	if not quest.dialogue_complete.is_empty() and dialogue_database.has(quest.dialogue_complete):
		start_dialogue(quest.dialogue_complete)
	else:
		# Automatikus leadási párbeszéd
		_show_auto_turn_in(quest)


## NPC idle párbeszéd (nem quest-specifikus)
func start_npc_idle_dialogue(npc_id: String, npc_name: String) -> void:
	var idle_dialogues := _get_npc_idle_dialogues(npc_id)
	if idle_dialogues.is_empty():
		return
	
	var dialogue: DialogueData = idle_dialogues[randi() % idle_dialogues.size()]
	current_dialogue = dialogue
	current_line_index = 0
	is_dialogue_active = true
	_show_current_line()


## Aktuális sor megjelenítése
func _show_current_line() -> void:
	if current_dialogue == null:
		return
	
	if current_line_index >= current_dialogue.lines.size():
		end_dialogue()
		return
	
	var line: DialogueLine = current_dialogue.lines[current_line_index] as DialogueLine
	if line == null:
		end_dialogue()
		return
	
	# UI frissítés
	if dialogue_ui and dialogue_ui.has_method("open_dialogue"):
		var options: Array[String] = []
		for resp in line.responses:
			if resp is DialogueResponse:
				options.append(resp.text)
		
		dialogue_ui.open_dialogue(
			"",
			current_dialogue.speaker_name,
			line.text,
			options
		)
	
	# Ha nincs response, akkor kattintásra következő sor
	if not line.has_responses():
		pass  # continue indicator jelenik meg az UI-ban


## Következő sor
func advance_dialogue() -> void:
	if not is_dialogue_active or current_dialogue == null:
		return
	
	current_line_index += 1
	
	if current_line_index >= current_dialogue.lines.size():
		end_dialogue()
	else:
		_show_current_line()


## Párbeszéd befejezése
func end_dialogue() -> void:
	is_dialogue_active = false
	
	# Lejátszott dialogue nyilvántartás
	if current_dialogue and current_dialogue.dialogue_id not in played_dialogues:
		played_dialogues.append(current_dialogue.dialogue_id)
	
	if dialogue_ui and dialogue_ui.has_method("close_dialogue"):
		dialogue_ui.close_dialogue()
	
	# Pending quest action végrehajtása
	if not pending_quest_action.is_empty() and not pending_quest_id.is_empty():
		_execute_pending_quest_action()
	
	if current_dialogue:
		EventBus.dialogue_ended.emit(current_dialogue.dialogue_id)
	
	current_dialogue = null
	current_line_index = 0


# ═══════════════════════════════════════════════════════════════
#  VÁLASZKEZELÉS
# ═══════════════════════════════════════════════════════════════

func _on_option_selected(option_idx: int) -> void:
	if not is_dialogue_active or current_dialogue == null:
		return
	
	if current_line_index >= current_dialogue.lines.size():
		return
	
	var line: DialogueLine = current_dialogue.lines[current_line_index] as DialogueLine
	if line == null or option_idx >= line.responses.size():
		return
	
	var response: DialogueResponse = line.responses[option_idx] as DialogueResponse
	if response == null:
		return
	
	# Akció végrehajtása
	_execute_response_action(response)
	
	# Következő párbeszéd navigáció
	if not response.next_dialogue_id.is_empty():
		if dialogue_database.has(response.next_dialogue_id):
			start_dialogue(response.next_dialogue_id)
		else:
			end_dialogue()
	else:
		advance_dialogue()


func _execute_response_action(response: DialogueResponse) -> void:
	match response.action:
		"accept_quest":
			var quest_id := response.action_param if not response.action_param.is_empty() else pending_quest_id
			if has_node("/root/QuestManager"):
				get_node("/root/QuestManager").accept_quest(quest_id)
			pending_quest_action = ""
			pending_quest_id = ""
		"decline":
			pending_quest_action = ""
			pending_quest_id = ""
		"turn_in":
			var quest_id := response.action_param if not response.action_param.is_empty() else pending_quest_id
			if has_node("/root/QuestManager"):
				get_node("/root/QuestManager").turn_in_quest(quest_id)
			pending_quest_action = ""
			pending_quest_id = ""
		"continue":
			pass  # Csak folytatjuk a párbeszédet


func _on_dialogue_closed() -> void:
	if is_dialogue_active:
		end_dialogue()


func _on_quest_dialogue_opened(npc_id: String) -> void:
	if has_node("/root/QuestManager"):
		get_node("/root/QuestManager").handle_quest_npc_interaction(npc_id)


# ═══════════════════════════════════════════════════════════════
#  AUTO-GENERÁLT PÁRBESZÉDEK
# ═══════════════════════════════════════════════════════════════

## Automatikus quest ajánlat (ha nincs egyedi dialogue)
func _show_auto_quest_offer(quest: QuestData) -> void:
	if dialogue_ui == null:
		_find_dialogue_ui()
	
	if dialogue_ui and dialogue_ui.has_method("open_dialogue"):
		var desc := quest.description if not quest.description.is_empty() else "A task awaits..."
		var npc_name := quest.giver_npc_id.replace("_", " ").capitalize()
		
		var reward_text := ""
		if quest.rewards is QuestRewards:
			var texts = (quest.rewards as QuestRewards).get_reward_texts()
			if not texts.is_empty():
				reward_text = "\n\nRewards: " + ", ".join(texts)
		
		dialogue_ui.open_dialogue(
			quest.giver_npc_id,
			npc_name,
			"[b]%s[/b]\n\n%s%s" % [quest.quest_name, desc, reward_text],
			["Accept Quest", "Decline"]
		)
		
		# Response handler-t beállítjuk
		pending_quest_action = "accept"
		pending_quest_id = quest.quest_id
		
		# Temporal connection for auto-dialogue
		if dialogue_ui.has_signal("dialogue_option_selected"):
			# Disconnect previous if exists
			if dialogue_ui.dialogue_option_selected.is_connected(_on_auto_quest_response):
				dialogue_ui.dialogue_option_selected.disconnect(_on_auto_quest_response)
			dialogue_ui.dialogue_option_selected.connect(_on_auto_quest_response, CONNECT_ONE_SHOT)


func _on_auto_quest_response(idx: int) -> void:
	if idx == 0:  # Accept
		if has_node("/root/QuestManager"):
			get_node("/root/QuestManager").accept_quest(pending_quest_id)
	# Decline = just close
	pending_quest_action = ""
	pending_quest_id = ""
	if dialogue_ui and dialogue_ui.has_method("close_dialogue"):
		dialogue_ui.close_dialogue()


## Automatikus quest leadás
func _show_auto_turn_in(quest: QuestData) -> void:
	if dialogue_ui == null:
		_find_dialogue_ui()
	
	if dialogue_ui and dialogue_ui.has_method("open_dialogue"):
		var npc_name := quest.turn_in_npc_id.replace("_", " ").capitalize()
		
		dialogue_ui.open_dialogue(
			quest.turn_in_npc_id,
			npc_name,
			"Well done! You've completed [b]%s[/b].\nHere is your reward." % quest.quest_name,
			["Collect Reward"]
		)
		
		if dialogue_ui.has_signal("dialogue_option_selected"):
			if dialogue_ui.dialogue_option_selected.is_connected(_on_auto_turn_in_response):
				dialogue_ui.dialogue_option_selected.disconnect(_on_auto_turn_in_response)
			dialogue_ui.dialogue_option_selected.connect(_on_auto_turn_in_response, CONNECT_ONE_SHOT)
		
		pending_quest_action = "turn_in"
		pending_quest_id = quest.quest_id


func _on_auto_turn_in_response(_idx: int) -> void:
	if has_node("/root/QuestManager"):
		get_node("/root/QuestManager").turn_in_quest(pending_quest_id)
	pending_quest_action = ""
	pending_quest_id = ""
	if dialogue_ui and dialogue_ui.has_method("close_dialogue"):
		dialogue_ui.close_dialogue()


# ═══════════════════════════════════════════════════════════════
#  DIALOGUE DATABASE BETÖLTÉS
# ═══════════════════════════════════════════════════════════════

func _load_dialogue_database() -> void:
	_load_dialogues_from_json("res://data/dialogues/main_dialogues.json")
	_load_dialogues_from_json("res://data/dialogues/side_dialogues.json")
	_load_dialogues_from_json("res://data/dialogues/npc_idle_dialogues.json")


func _load_dialogues_from_json(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_warning("DialogueManager: Dialogue file not found: %s" % path)
		return
	
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("DialogueManager: Cannot read %s" % path)
		return
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("DialogueManager: JSON parse error in %s: %s" % [path, json.get_error_message()])
		return
	
	var data: Array = json.data if json.data is Array else []
	for dlg_dict in data:
		if dlg_dict is Dictionary:
			var dlg := DialogueData.from_dict(dlg_dict)
			dialogue_database[dlg.dialogue_id] = dlg
	
	print("DialogueManager: Loaded %d dialogues from %s" % [data.size(), path])


func _get_npc_idle_dialogues(npc_id: String) -> Array[DialogueData]:
	var result: Array[DialogueData] = []
	for dlg_id in dialogue_database:
		if dlg_id.begins_with("idle_%s" % npc_id):
			result.append(dialogue_database[dlg_id])
	return result


## Párbeszéd egyedi végrehajtása
func _execute_pending_quest_action() -> void:
	match pending_quest_action:
		"accept":
			if has_node("/root/QuestManager"):
				get_node("/root/QuestManager").accept_quest(pending_quest_id)
		"turn_in":
			if has_node("/root/QuestManager"):
				get_node("/root/QuestManager").turn_in_quest(pending_quest_id)
	
	pending_quest_action = ""
	pending_quest_id = ""


## Serialize - csak a lejátszott dialogue ID-kat mentjük
func serialize() -> Dictionary:
	return {
		"played_dialogues": played_dialogues.duplicate()
	}


## Deserialize
func deserialize(data: Dictionary) -> void:
	played_dialogues.clear()
	var ids: Array = data.get("played_dialogues", [])
	for id in ids:
		played_dialogues.append(str(id))

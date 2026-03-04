## DialogueUI - NPC párbeszéd megjelenítés
## Typewriter effekt, válaszopciók, portrait
## DialogueManager-rel integrált
class_name DialogueUI
extends CanvasLayer

signal dialogue_option_selected(option_idx: int)
signal dialogue_closed()

# === UI elemek ===
var panel: PanelContainer = null
var npc_name_label: Label = null
var dialogue_text: RichTextLabel = null
var options_container: VBoxContainer = null
var portrait_rect: TextureRect = null
var continue_indicator: Label = null

# === Typewriter effekt ===
var full_text: String = ""
var displayed_chars: int = 0
var typewriter_speed: float = 30.0  # Karakter / sec
var typewriter_timer: float = 0.0
var typewriter_done: bool = true

# === Állapot ===
var is_open: bool = false
var current_npc_id: String = ""
var can_advance: bool = false
var _managed_by_dialogue_manager: bool = false


func _ready() -> void:
	layer = 50
	_build_ui()
	_set_visible(false)
	
	# DialogueManager integráció
	if has_node("/root/DialogueManager"):
		DialogueManager.dialogue_ui = self
		_managed_by_dialogue_manager = true


func _build_ui() -> void:
	# Panel
	panel = PanelContainer.new()
	panel.position = Vector2(40, 260)
	panel.size = Vector2(560, 100)
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.06, 0.1, 0.95)
	style.border_color = Color(0.5, 0.4, 0.3)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	panel.add_child(vbox)
	
	# NPC név
	npc_name_label = Label.new()
	npc_name_label.text = "NPC Name"
	npc_name_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.4))
	vbox.add_child(npc_name_label)
	
	# Dialogue szöveg
	dialogue_text = RichTextLabel.new()
	dialogue_text.bbcode_enabled = true
	dialogue_text.custom_minimum_size = Vector2(0, 50)
	dialogue_text.fit_content = true
	dialogue_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(dialogue_text)
	
	# Opciók
	options_container = VBoxContainer.new()
	vbox.add_child(options_container)
	
	# "Continue" jelző
	continue_indicator = Label.new()
	continue_indicator.text = "▼"
	continue_indicator.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	continue_indicator.visible = false
	vbox.add_child(continue_indicator)
	
	# Portrait (bal oldalon)
	portrait_rect = TextureRect.new()
	portrait_rect.position = Vector2(-60, 0)
	portrait_rect.size = Vector2(48, 48)
	portrait_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.add_child(portrait_rect)
	
	add_child(panel)


func _process(delta: float) -> void:
	if not is_open:
		return
	
	# Typewriter animáció
	if not typewriter_done:
		typewriter_timer += delta * typewriter_speed
		var new_chars := int(typewriter_timer)
		if new_chars > displayed_chars:
			displayed_chars = mini(new_chars, full_text.length())
			dialogue_text.text = full_text.substr(0, displayed_chars)
			if displayed_chars >= full_text.length():
				typewriter_done = true
				can_advance = true
				continue_indicator.visible = options_container.get_child_count() == 0
	
	# Continue indicator villogás
	if continue_indicator.visible:
		continue_indicator.modulate.a = 0.5 + sin(Time.get_ticks_msec() / 300.0) * 0.5


## Dialogue megnyitása
func open_dialogue(npc_id: String, npc_name: String, text: String, options: Array[String] = []) -> void:
	current_npc_id = npc_id
	npc_name_label.text = npc_name
	_set_text_with_typewriter(text)
	_set_options(options)
	is_open = true
	_set_visible(true)


## Typewriter-rel szöveg beállítása
func _set_text_with_typewriter(text: String) -> void:
	full_text = text
	displayed_chars = 0
	typewriter_timer = 0.0
	typewriter_done = false
	can_advance = false
	continue_indicator.visible = false
	dialogue_text.text = ""


## Opciók beállítása
func _set_options(options: Array[String]) -> void:
	for child in options_container.get_children():
		child.queue_free()
	
	for i in range(options.size()):
		var btn := Button.new()
		btn.text = "%d. %s" % [i + 1, options[i]]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_option_pressed.bind(i))
		options_container.add_child(btn)


func _on_option_pressed(idx: int) -> void:
	dialogue_option_selected.emit(idx)


## Bezárás
func close_dialogue() -> void:
	is_open = false
	current_npc_id = ""
	_set_visible(false)
	dialogue_closed.emit()


func _set_visible(vis: bool) -> void:
	if panel:
		panel.visible = vis


## Input kezelés
func _input(event: InputEvent) -> void:
	if not is_open:
		return
	
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not typewriter_done:
			# Skip typewriter
			displayed_chars = full_text.length()
			dialogue_text.text = full_text
			typewriter_done = true
			can_advance = true
			continue_indicator.visible = options_container.get_child_count() == 0
		elif can_advance and options_container.get_child_count() == 0:
			# DialogueManager-en keresztül advance
			if _managed_by_dialogue_manager and has_node("/root/DialogueManager"):
				DialogueManager.advance_dialogue()
			else:
				close_dialogue()
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_cancel"):
		if _managed_by_dialogue_manager and has_node("/root/DialogueManager"):
			DialogueManager.end_dialogue()
		else:
			close_dialogue()
		get_viewport().set_input_as_handled()

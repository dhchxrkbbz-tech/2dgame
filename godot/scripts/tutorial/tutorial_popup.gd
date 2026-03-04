## TutorialPopup - Tutorial popup UI elem
## Slide-in animáció, auto-dismiss, billentyű hint megjelenítés
## Programmatikusan épül (nincs .tscn szükség)
class_name TutorialPopup
extends Control

signal popup_dismissed()

# =============================================================================
#  BELSŐ REFERENCIÁK
# =============================================================================
var _bg_panel: PanelContainer
var _title_label: Label
var _text_label: RichTextLabel
var _key_hint_label: Label
var _close_button: Button
var _auto_dismiss_timer: Timer
var _trigger_id: String = ""

# Animáció
var _slide_tween: Tween = null
var _is_dismissing: bool = false

# Design konstansok
const POPUP_WIDTH: float = 320.0
const POPUP_MIN_HEIGHT: float = 80.0
const POPUP_MARGIN: float = 16.0
const SLIDE_DURATION: float = 0.3
const FADE_DURATION: float = 0.5

# Szín séma (dark fantasy)
const BG_COLOR := Color(0.08, 0.06, 0.12, 0.92)
const BORDER_COLOR := Color(0.6, 0.5, 0.2, 0.8)  # Arany keret
const TITLE_COLOR := Color(1.0, 0.85, 0.4)  # Arany cím
const TEXT_COLOR := Color(0.85, 0.82, 0.75)  # Halvány pergamen
const KEY_HINT_COLOR := Color(0.4, 0.8, 1.0)  # Kék billentyű hint
const CLOSE_COLOR := Color(0.6, 0.5, 0.5)


# =============================================================================
#  SETUP
# =============================================================================
func setup(trigger_id: String, content: Dictionary) -> void:
	_trigger_id = trigger_id
	_build_ui(content)
	
	# Auto-dismiss timer
	var duration: float = content.get("duration", 8.0)
	if duration > 0.0:
		_auto_dismiss_timer = Timer.new()
		_auto_dismiss_timer.wait_time = duration
		_auto_dismiss_timer.one_shot = true
		_auto_dismiss_timer.timeout.connect(dismiss)
		add_child(_auto_dismiss_timer)
	
	# Pozícionálás
	var position_str: String = content.get("position", "top")
	_set_position(position_str)


func _ready() -> void:
	# Slide-in animáció indítás
	_animate_slide_in()
	
	# Auto-dismiss timer indítás
	if _auto_dismiss_timer:
		_auto_dismiss_timer.start()


func _build_ui(content: Dictionary) -> void:
	# === Root Control setup ===
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_preset(PRESET_FULL_RECT)
	
	# === Háttér panel ===
	_bg_panel = PanelContainer.new()
	_bg_panel.mouse_filter = MOUSE_FILTER_STOP
	
	# StyleBox
	var style := StyleBoxFlat.new()
	style.bg_color = BG_COLOR
	style.border_color = BORDER_COLOR
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(12)
	# Kis árnyék hatás
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	_bg_panel.add_theme_stylebox_override("panel", style)
	
	# Panel méretezés
	_bg_panel.custom_minimum_size = Vector2(POPUP_WIDTH, POPUP_MIN_HEIGHT)
	add_child(_bg_panel)
	
	# === Tartalom VBox ===
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_bg_panel.add_child(vbox)
	
	# === Header (cím + X gomb) ===
	var header := HBoxContainer.new()
	vbox.add_child(header)
	
	# Ikon placeholder (kis színes négyzet)
	var icon_rect := ColorRect.new()
	icon_rect.custom_minimum_size = Vector2(16, 16)
	icon_rect.color = TITLE_COLOR
	header.add_child(icon_rect)
	
	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(6, 0)
	header.add_child(spacer)
	
	# Cím
	_title_label = Label.new()
	_title_label.text = content.get("title", "TUTORIAL")
	_title_label.add_theme_color_override("font_color", TITLE_COLOR)
	_title_label.size_flags_horizontal = SIZE_EXPAND_FILL
	header.add_child(_title_label)
	
	# Bezárás gomb
	_close_button = Button.new()
	_close_button.text = "X"
	_close_button.custom_minimum_size = Vector2(24, 24)
	_close_button.flat = true
	_close_button.add_theme_color_override("font_color", CLOSE_COLOR)
	_close_button.add_theme_color_override("font_hover_color", Color.WHITE)
	_close_button.pressed.connect(dismiss)
	header.add_child(_close_button)
	
	# === Szeparátor vonal ===
	var separator := HSeparator.new()
	separator.add_theme_color_override("separator", BORDER_COLOR * 0.5)
	vbox.add_child(separator)
	
	# === Szöveg ===
	_text_label = RichTextLabel.new()
	_text_label.bbcode_enabled = true
	_text_label.fit_content = true
	_text_label.scroll_active = false
	_text_label.mouse_filter = MOUSE_FILTER_IGNORE
	_text_label.add_theme_color_override("default_color", TEXT_COLOR)
	
	# Szöveg formázás: [GOMB] jelölések kiemelése
	var raw_text: String = content.get("text", "")
	var formatted_text := _format_key_hints(raw_text)
	_text_label.text = formatted_text
	vbox.add_child(_text_label)
	
	# === Billentyű hint (ha van) ===
	var key_hint: String = content.get("key_hint", "")
	if not key_hint.is_empty():
		_key_hint_label = Label.new()
		_key_hint_label.text = "  [%s]" % key_hint
		_key_hint_label.add_theme_color_override("font_color", KEY_HINT_COLOR)
		_key_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		vbox.add_child(_key_hint_label)


## [GOMB] jelölések BBCode-ra konvertálása
func _format_key_hints(text: String) -> String:
	# [WASD] → [color=#66ccff][WASD][/color]
	var regex := RegEx.new()
	regex.compile("\\[([A-Za-z0-9_ ]+)\\]")
	var result := text
	var matches := regex.search_all(text)
	# Fordított sorrendben cseréljük, hogy az indexek ne csússzanak el
	matches.reverse()
	for match_res in matches:
		var full_match: String = match_res.get_string()
		var key_name: String = match_res.get_string(1)
		var replacement := "[color=#66ccff]%s[/color]" % full_match
		result = result.substr(0, match_res.get_start()) + replacement + result.substr(match_res.get_end())
	return result


# =============================================================================
#  POZÍCIONÁLÁS
# =============================================================================
func _set_position(position_str: String) -> void:
	# A panel pozíciója a viewport méretéhez képest
	# A slide-in animáció a képernyőn kívülről indul
	match position_str:
		"top":
			_bg_panel.position = Vector2(
				(640.0 - POPUP_WIDTH) / 2.0,  # Középre (viewport width)
				-200  # Képernyőn kívül felül (slide-in célja: POPUP_MARGIN)
			)
		"bottom":
			_bg_panel.position = Vector2(
				(640.0 - POPUP_WIDTH) / 2.0,
				360.0 + 50  # Képernyőn kívül alul
			)
		"center":
			_bg_panel.position = Vector2(
				(640.0 - POPUP_WIDTH) / 2.0,
				-200  # Felülről slide-in a közepére
			)
		_:
			_bg_panel.position = Vector2(
				(640.0 - POPUP_WIDTH) / 2.0,
				-200
			)


# =============================================================================
#  ANIMÁCIÓ
# =============================================================================
func _animate_slide_in() -> void:
	if _slide_tween and _slide_tween.is_valid():
		_slide_tween.kill()
	
	_bg_panel.modulate.a = 0.0
	
	# Cél pozíció
	var target_y: float
	var pos_meta: String = ""
	var content := TutorialData.get_tutorial(_trigger_id)
	var position_str: String = content.get("position", "top")
	
	match position_str:
		"top":
			target_y = POPUP_MARGIN
		"bottom":
			target_y = 360.0 - POPUP_MIN_HEIGHT - POPUP_MARGIN
		"center":
			target_y = (360.0 - POPUP_MIN_HEIGHT) / 2.0
		_:
			target_y = POPUP_MARGIN
	
	_slide_tween = create_tween()
	_slide_tween.set_parallel(true)
	_slide_tween.set_ease(Tween.EASE_OUT)
	_slide_tween.set_trans(Tween.TRANS_BACK)
	_slide_tween.tween_property(_bg_panel, "position:y", target_y, SLIDE_DURATION)
	_slide_tween.tween_property(_bg_panel, "modulate:a", 1.0, SLIDE_DURATION * 0.8)


func _animate_slide_out() -> void:
	if _slide_tween and _slide_tween.is_valid():
		_slide_tween.kill()
	
	_slide_tween = create_tween()
	_slide_tween.set_parallel(true)
	_slide_tween.set_ease(Tween.EASE_IN)
	_slide_tween.set_trans(Tween.TRANS_QUAD)
	_slide_tween.tween_property(_bg_panel, "modulate:a", 0.0, FADE_DURATION)
	_slide_tween.tween_property(_bg_panel, "position:y", _bg_panel.position.y - 30, FADE_DURATION)
	_slide_tween.finished.connect(_on_slide_out_finished)


func _on_slide_out_finished() -> void:
	popup_dismissed.emit()
	queue_free()


# =============================================================================
#  DISMISS
# =============================================================================
func dismiss() -> void:
	if _is_dismissing:
		return
	_is_dismissing = true
	
	if _auto_dismiss_timer:
		_auto_dismiss_timer.stop()
	
	_animate_slide_out()


# =============================================================================
#  INPUT
# =============================================================================
func _input(event: InputEvent) -> void:
	# Space vagy Enter = elfogadás / bezárás
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("dodge"):
		dismiss()
		get_viewport().set_input_as_handled()

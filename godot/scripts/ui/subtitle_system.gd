## SubtitleSystem - Felirat és hangfelirat rendszer
## NPC dialógus feliratok és környezeti hang captions
class_name SubtitleSystem
extends CanvasLayer

# === Caption megjelenítés ===
var caption_label: RichTextLabel = null
var caption_bg: ColorRect = null
var caption_timer: Timer = null
var caption_queue: Array[Dictionary] = []
var is_showing: bool = false

# Beállítások
var caption_duration: float = 3.0  # másodperc
var max_visible_captions: int = 3


func _ready() -> void:
	layer = 90  # UI fölött, de colorblind alatt
	_build_caption_ui()


func _build_caption_ui() -> void:
	# Caption háttér (alsó harmad)
	caption_bg = ColorRect.new()
	caption_bg.color = Color(0.0, 0.0, 0.0, 0.6)
	caption_bg.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	caption_bg.anchor_top = 0.82
	caption_bg.visible = false
	add_child(caption_bg)
	
	# Caption szöveg
	caption_label = RichTextLabel.new()
	caption_label.bbcode_enabled = true
	caption_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	caption_label.anchor_top = 0.82
	caption_label.scroll_active = false
	caption_label.fit_content = true
	caption_label.add_theme_color_override("default_color", Color.WHITE)
	caption_label.visible = false
	add_child(caption_label)
	
	# Timer
	caption_timer = Timer.new()
	caption_timer.one_shot = true
	caption_timer.timeout.connect(_on_caption_timeout)
	add_child(caption_timer)


# === Dialógus feliratok ===
func show_dialogue_subtitle(speaker_name: String, text: String, duration: float = -1.0) -> void:
	## NPC dialógus felirat megjelenítése
	var formatted := "[b]%s:[/b] %s" % [speaker_name, text]
	_show_caption(formatted, duration if duration > 0 else caption_duration)


# === Környezeti hang captions ===
func show_sound_caption(caption_key: String, duration: float = -1.0) -> void:
	## Környezeti hang felirat (caption) megjelenítése
	## Csak ha a sound_captions_enabled be van kapcsolva
	if not AccessibilityManager.sound_captions_enabled:
		return
	
	var text := tr(caption_key)
	_show_caption("[color=#aaaaaa][i]%s[/i][/color]" % text, duration if duration > 0 else 2.5)


func show_directional_sound_caption(caption_key: String, direction: Vector2, duration: float = -1.0) -> void:
	## Irányjelzős hangfelirat (pl. "← [Csatazaj a közelben]")
	if not AccessibilityManager.sound_captions_enabled:
		return
	
	var dir_indicator := _get_direction_indicator(direction)
	var text := tr(caption_key)
	_show_caption("[color=#aaaaaa][i]%s %s[/i][/color]" % [dir_indicator, text], duration if duration > 0 else 2.5)


func _get_direction_indicator(direction: Vector2) -> String:
	## Irány nyíl szimbólum a hang irányának jelzésére
	if direction == Vector2.ZERO:
		return ""
	
	var angle := direction.angle()
	# 8 irányra kerekítés
	var segment := int(round(angle / (PI / 4.0))) % 8
	if segment < 0:
		segment += 8
	
	match segment:
		0: return "→"
		1: return "↘"
		2: return "↓"
		3: return "↙"
		4: return "←"
		5: return "↖"
		6: return "↑"
		7: return "↗"
		_: return ""


func _show_caption(formatted_text: String, duration: float) -> void:
	caption_label.clear()
	caption_label.append_text(formatted_text)
	
	caption_bg.visible = true
	caption_label.visible = true
	is_showing = true
	
	# Szövegméret alkalmazás
	var font_size := AccessibilityManager.get_scaled_font_size(12)
	caption_label.add_theme_font_size_override("normal_font_size", font_size)
	caption_label.add_theme_font_size_override("bold_font_size", font_size + 2)
	caption_label.add_theme_font_size_override("italics_font_size", font_size)
	
	caption_timer.start(duration)


func _on_caption_timeout() -> void:
	_hide_caption()


func _hide_caption() -> void:
	caption_bg.visible = false
	caption_label.visible = false
	is_showing = false


func hide_all() -> void:
	_hide_caption()
	caption_queue.clear()

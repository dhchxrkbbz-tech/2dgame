## ManaBar - Mana bar UI komponens
## Kék szín, mana regen vizualizáció
class_name ManaBar
extends Control

@export var show_text: bool = true
@export var bar_width: float = 100.0
@export var bar_height: float = 8.0
@export var lerp_speed: float = 8.0

var current_mana: float = 100.0
var max_mana: float = 100.0
var display_mana: float = 100.0

const COLOR_MANA: Color = Color(0.2, 0.3, 0.9)
const COLOR_MANA_LOW: Color = Color(0.5, 0.2, 0.8)
const COLOR_BG: Color = Color(0.1, 0.1, 0.15, 0.8)
const COLOR_REGEN: Color = Color(0.4, 0.5, 1.0, 0.3)

var regen_pulse: float = 0.0  # Regen vizuális pulse


func _ready() -> void:
	custom_minimum_size = Vector2(bar_width, bar_height)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	display_mana = lerpf(display_mana, current_mana, lerp_speed * delta)
	regen_pulse = fmod(regen_pulse + delta * 2.0, TAU)
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, Vector2(bar_width, bar_height))
	
	# Háttér
	draw_rect(rect, COLOR_BG)
	
	# Mana bar
	var mana_ratio := display_mana / max_mana if max_mana > 0 else 0.0
	var mana_rect := Rect2(Vector2.ZERO, Vector2(bar_width * mana_ratio, bar_height))
	var color := COLOR_MANA if mana_ratio > 0.3 else COLOR_MANA.lerp(COLOR_MANA_LOW, (0.3 - mana_ratio) / 0.3)
	draw_rect(mana_rect, color)
	
	# Regen pulse
	if current_mana < max_mana:
		var pulse_alpha := (sin(regen_pulse) + 1.0) * 0.5 * 0.3
		var regen_color := COLOR_REGEN
		regen_color.a = pulse_alpha
		draw_rect(mana_rect, regen_color)
	
	# Keret
	draw_rect(rect, Color(0.2, 0.2, 0.3), false, 1.0)
	
	# Szöveg
	if show_text:
		var text := "%d / %d" % [int(current_mana), int(max_mana)]
		var font := ThemeDB.fallback_font
		var font_size := ThemeDB.fallback_font_size
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos := Vector2(
			(bar_width - text_size.x) / 2.0,
			(bar_height + text_size.y * 0.5) / 2.0
		)
		draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)


## Mana frissítése
func update_mana(mana: float, mana_max: float) -> void:
	current_mana = mana
	max_mana = mana_max


func set_mana_immediate(mana: float, mana_max: float) -> void:
	current_mana = mana
	max_mana = mana_max
	display_mana = mana
	queue_redraw()

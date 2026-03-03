## XPBar - Experience bar UI komponens
## Level kijelzéssel, XP gain animációval
class_name XPBar
extends Control

signal level_up_displayed(level: int)

@export var bar_width: float = 200.0
@export var bar_height: float = 6.0
@export var lerp_speed: float = 4.0
@export var show_level: bool = true

var current_xp: float = 0.0
var xp_to_next: float = 100.0
var current_level: int = 1
var display_xp: float = 0.0

const COLOR_XP: Color = Color(0.9, 0.8, 0.1)
const COLOR_XP_GLOW: Color = Color(1.0, 0.95, 0.5, 0.4)
const COLOR_BG: Color = Color(0.1, 0.1, 0.1, 0.7)

# Level up animáció
var level_up_anim_timer: float = 0.0
var level_up_animating: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(bar_width, bar_height + (16 if show_level else 0))
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	display_xp = lerpf(display_xp, current_xp, lerp_speed * delta)
	
	if level_up_animating:
		level_up_anim_timer -= delta
		if level_up_anim_timer <= 0:
			level_up_animating = false
	
	queue_redraw()


func _draw() -> void:
	var y_offset: float = 16.0 if show_level else 0.0
	var rect := Rect2(Vector2(0, y_offset), Vector2(bar_width, bar_height))
	
	# Háttér
	draw_rect(rect, COLOR_BG)
	
	# XP bar
	var xp_ratio := display_xp / xp_to_next if xp_to_next > 0 else 0.0
	var xp_rect := Rect2(Vector2(0, y_offset), Vector2(bar_width * xp_ratio, bar_height))
	draw_rect(xp_rect, COLOR_XP)
	
	# Glow a tetején
	var glow_rect := Rect2(Vector2(0, y_offset), Vector2(bar_width * xp_ratio, bar_height * 0.4))
	draw_rect(glow_rect, COLOR_XP_GLOW)
	
	# Keret
	draw_rect(rect, Color(0.3, 0.3, 0.2), false, 1.0)
	
	# Level szöveg
	if show_level:
		var font := ThemeDB.fallback_font
		var font_size := ThemeDB.fallback_font_size
		var level_text := "Lv. %d" % current_level
		var level_color := Color.WHITE
		
		if level_up_animating:
			level_color = Color(1.0, 0.9, 0.3)
			var scale := 1.0 + sin(level_up_anim_timer * 10.0) * 0.1
			level_text = "LEVEL UP! %d" % current_level
		
		draw_string(font, Vector2(0, 12), level_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, level_color)
		
		# XP számok (jobb oldalon)
		var xp_text := "%d / %d" % [int(current_xp), int(xp_to_next)]
		var text_size := font.get_string_size(xp_text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size)
		draw_string(font, Vector2(bar_width - text_size.x, 12), xp_text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, Color(0.7, 0.7, 0.7))


## XP frissítése
func update_xp(xp: float, xp_next: float, level: int) -> void:
	if level > current_level:
		_trigger_level_up(level)
	current_xp = xp
	xp_to_next = xp_next
	current_level = level


func _trigger_level_up(new_level: int) -> void:
	level_up_animating = true
	level_up_anim_timer = 2.0
	level_up_displayed.emit(new_level)

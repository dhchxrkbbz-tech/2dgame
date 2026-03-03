## HealthBar - HP bar UI komponens (Player + Enemy)
## Csusztatható, szín alapú, opcionális shield kijelzés
class_name HealthBar
extends Control

@export var show_text: bool = true
@export var show_shield: bool = true
@export var bar_width: float = 100.0
@export var bar_height: float = 10.0
@export var lerp_speed: float = 5.0

# === Aktuális értékek ===
var current_hp: float = 100.0
var max_hp: float = 100.0
var shield_amount: float = 0.0
var display_hp: float = 100.0  # Animált kijelzés

# === Szín beállítások ===
const COLOR_HIGH: Color = Color(0.2, 0.8, 0.2)     # Zöld (>60%)
const COLOR_MID: Color = Color(0.9, 0.8, 0.1)      # Sárga (30-60%)
const COLOR_LOW: Color = Color(0.9, 0.2, 0.2)       # Piros (<30%)
const COLOR_BG: Color = Color(0.15, 0.15, 0.15, 0.8)
const COLOR_SHIELD: Color = Color(0.3, 0.6, 0.9, 0.7)
const COLOR_DAMAGE: Color = Color(0.9, 0.3, 0.1, 0.5)  # Damage trail

var damage_display: float = 0.0  # Csúszó trail


func _ready() -> void:
	custom_minimum_size = Vector2(bar_width, bar_height)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	# Simított kijelzés
	display_hp = lerpf(display_hp, current_hp, lerp_speed * delta)
	damage_display = lerpf(damage_display, current_hp, lerp_speed * 0.5 * delta)
	queue_redraw()


func _draw() -> void:
	var rect := Rect2(Vector2.ZERO, Vector2(bar_width, bar_height))
	
	# Háttér
	draw_rect(rect, COLOR_BG)
	
	# Damage trail
	if damage_display > display_hp:
		var trail_ratio := damage_display / max_hp
		var trail_rect := Rect2(Vector2.ZERO, Vector2(bar_width * trail_ratio, bar_height))
		draw_rect(trail_rect, COLOR_DAMAGE)
	
	# HP bar
	var hp_ratio := display_hp / max_hp if max_hp > 0 else 0.0
	var hp_rect := Rect2(Vector2.ZERO, Vector2(bar_width * hp_ratio, bar_height))
	var hp_color := _get_hp_color(hp_ratio)
	draw_rect(hp_rect, hp_color)
	
	# Shield overlay
	if show_shield and shield_amount > 0:
		var shield_ratio := minf(shield_amount / max_hp, 1.0 - hp_ratio)
		var shield_rect := Rect2(
			Vector2(bar_width * hp_ratio, 0),
			Vector2(bar_width * shield_ratio, bar_height)
		)
		draw_rect(shield_rect, COLOR_SHIELD)
	
	# Keret
	draw_rect(rect, Color(0.3, 0.3, 0.3), false, 1.0)
	
	# Szöveg
	if show_text:
		var text := "%d / %d" % [int(current_hp), int(max_hp)]
		var font := ThemeDB.fallback_font
		var font_size := ThemeDB.fallback_font_size
		var text_size := font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		var text_pos := Vector2(
			(bar_width - text_size.x) / 2.0,
			(bar_height + text_size.y * 0.5) / 2.0
		)
		draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color.WHITE)


func _get_hp_color(ratio: float) -> Color:
	if ratio > 0.6:
		return COLOR_HIGH
	elif ratio > 0.3:
		return COLOR_HIGH.lerp(COLOR_MID, (0.6 - ratio) / 0.3)
	else:
		return COLOR_MID.lerp(COLOR_LOW, (0.3 - ratio) / 0.3)


## HP frissítése kívüröl
func update_health(hp: float, hp_max: float, p_shield: float = 0.0) -> void:
	if hp < current_hp:
		damage_display = current_hp / max_hp * max_hp  # Trail indítása
	current_hp = hp
	max_hp = hp_max
	shield_amount = p_shield


## Közvetlen beállítás (animáció nélkül)
func set_health_immediate(hp: float, hp_max: float) -> void:
	current_hp = hp
	max_hp = hp_max
	display_hp = hp
	damage_display = hp
	queue_redraw()

## TutorialHighlight - UI elem kiemelés rendszer
## Arany keret villogás, nyíl mutatás, háttér sötétítés
## Tutorial popup mellé használható a figyelem irányítására
class_name TutorialHighlight
extends Control

# =============================================================================
#  REFERENCIÁK
# =============================================================================
var _dim_overlay: ColorRect           # Háttér sötétítés (20%)
var _highlight_frame: NinePatchRect   # Arany keret (programmatic)
var _arrow_indicator: Control         # Nyíl ami mutat
var _pulse_tween: Tween = null
var _target_control: Control = null
var _is_active: bool = false

# Design konstansok
const DIM_COLOR := Color(0, 0, 0, 0.2)          # 20% fekete háttér
const FRAME_COLOR := Color(1.0, 0.85, 0.3, 0.9)  # Arany keret
const FRAME_GLOW := Color(1.0, 0.7, 0.1, 0.4)   # Arany glow
const PULSE_MIN_ALPHA: float = 0.5
const PULSE_MAX_ALPHA: float = 1.0
const PULSE_DURATION: float = 0.8
const FRAME_PADDING: float = 6.0
const FADE_DURATION: float = 0.3
const ARROW_SIZE: float = 16.0


# =============================================================================
#  INICIALIZÁLÁS
# =============================================================================
func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	set_anchors_preset(PRESET_FULL_RECT)
	visible = false
	
	_build_overlay()
	_build_highlight_frame()
	_build_arrow()


func _build_overlay() -> void:
	_dim_overlay = ColorRect.new()
	_dim_overlay.set_anchors_preset(PRESET_FULL_RECT)
	_dim_overlay.color = DIM_COLOR
	_dim_overlay.color.a = 0.0  # Kezdetben láthatatlan
	_dim_overlay.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_dim_overlay)


func _build_highlight_frame() -> void:
	# Egyszerű ColorRect alapú keret (4 vékony téglalap)
	_highlight_frame = NinePatchRect.new()
	_highlight_frame.visible = false
	_highlight_frame.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_highlight_frame)


func _build_arrow() -> void:
	_arrow_indicator = Control.new()
	_arrow_indicator.custom_minimum_size = Vector2(ARROW_SIZE, ARROW_SIZE)
	_arrow_indicator.visible = false
	_arrow_indicator.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(_arrow_indicator)


# =============================================================================
#  KIEMELÉS API
# =============================================================================

## Kiemeli a megadott Control-t arany kerettel
func highlight_control(target: Control, show_arrow: bool = true) -> void:
	if not is_instance_valid(target):
		return
	
	_target_control = target
	_is_active = true
	visible = true
	
	# Háttér fade-in
	_fade_overlay(DIM_COLOR.a)
	
	# Keret pozícionálás
	_update_frame_position()
	_highlight_frame.visible = true
	
	# Nyíl
	if show_arrow:
		_update_arrow_position()
		_arrow_indicator.visible = true
	
	# Pulzáló animáció
	_start_pulse()


## Kiemeli a megadott Rect2 területet (nem Control alapú)
func highlight_rect(rect: Rect2, show_arrow: bool = false) -> void:
	_is_active = true
	visible = true
	_target_control = null
	
	_fade_overlay(DIM_COLOR.a)
	_position_frame_at_rect(rect)
	_highlight_frame.visible = true
	
	if show_arrow:
		_arrow_indicator.position = Vector2(
			rect.position.x + rect.size.x / 2.0 - ARROW_SIZE / 2.0,
			rect.position.y - ARROW_SIZE - 4
		)
		_arrow_indicator.visible = true
	
	_start_pulse()


## Kiemelés eltávolítása
func clear_highlight() -> void:
	if not _is_active:
		return
	
	_is_active = false
	_target_control = null
	
	# Animációk leállítása
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
		_pulse_tween = null
	
	# Fade-out
	_fade_overlay(0.0)
	_highlight_frame.visible = false
	_arrow_indicator.visible = false
	
	# Kis késleltetés után eltüntetjük teljesen
	var hide_timer := get_tree().create_timer(FADE_DURATION + 0.1)
	hide_timer.timeout.connect(func():
		if not _is_active:
			visible = false
	)


# =============================================================================
#  FRAME POZÍCIONÁLÁS
# =============================================================================
func _update_frame_position() -> void:
	if not is_instance_valid(_target_control):
		return
	
	var target_rect := _target_control.get_global_rect()
	_position_frame_at_rect(target_rect)


func _position_frame_at_rect(rect: Rect2) -> void:
	_highlight_frame.position = Vector2(
		rect.position.x - FRAME_PADDING,
		rect.position.y - FRAME_PADDING
	)
	_highlight_frame.size = Vector2(
		rect.size.x + FRAME_PADDING * 2,
		rect.size.y + FRAME_PADDING * 2
	)
	
	# Keret rajzolás style-al
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0, 0, 0, 0)  # Átlátszó háttér
	frame_style.border_color = FRAME_COLOR
	frame_style.set_border_width_all(3)
	frame_style.set_corner_radius_all(4)
	frame_style.shadow_color = FRAME_GLOW
	frame_style.shadow_size = 6
	
	# NinePatchRect helyett PanelContainer-t használunk a stílushoz
	# De egyszerűbben: a _highlight_frame-ot rajzoljuk draw()-ban
	queue_redraw()


func _update_arrow_position() -> void:
	if not is_instance_valid(_target_control):
		return
	
	var target_rect := _target_control.get_global_rect()
	# Nyíl a célpont felett, középen
	_arrow_indicator.position = Vector2(
		target_rect.position.x + target_rect.size.x / 2.0 - ARROW_SIZE / 2.0,
		target_rect.position.y - ARROW_SIZE - FRAME_PADDING - 4
	)


# =============================================================================
#  RAJZOLÁS
# =============================================================================
func _draw() -> void:
	if not _is_active:
		return
	
	# Arany keret rajzolás
	if _highlight_frame.visible:
		var frame_rect := Rect2(
			_highlight_frame.position,
			_highlight_frame.size
		)
		
		# Glow (külső fény)
		var glow_rect := frame_rect.grow(4)
		draw_rect(glow_rect, FRAME_GLOW, false, 2.0)
		
		# Fő keret
		draw_rect(frame_rect, FRAME_COLOR * Color(1, 1, 1, _highlight_frame.modulate.a), false, 3.0)
		
		# Belső vékony keret
		var inner_rect := frame_rect.grow(-2)
		draw_rect(inner_rect, FRAME_COLOR * Color(1, 1, 1, 0.3 * _highlight_frame.modulate.a), false, 1.0)
	
	# Nyíl rajzolás (lefelé mutató háromszög)
	if _arrow_indicator.visible:
		var arrow_pos := _arrow_indicator.position
		var arrow_points := PackedVector2Array([
			Vector2(arrow_pos.x, arrow_pos.y),
			Vector2(arrow_pos.x + ARROW_SIZE, arrow_pos.y),
			Vector2(arrow_pos.x + ARROW_SIZE / 2.0, arrow_pos.y + ARROW_SIZE * 0.7)
		])
		draw_colored_polygon(arrow_points, FRAME_COLOR)


# =============================================================================
#  ANIMÁCIÓK
# =============================================================================
func _start_pulse() -> void:
	if _pulse_tween and _pulse_tween.is_valid():
		_pulse_tween.kill()
	
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()  # Végtelen loop
	_pulse_tween.tween_property(
		_highlight_frame, "modulate:a",
		PULSE_MIN_ALPHA, PULSE_DURATION
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_pulse_tween.tween_property(
		_highlight_frame, "modulate:a",
		PULSE_MAX_ALPHA, PULSE_DURATION
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	# Redraw frissítés a pulzáláshoz
	_pulse_tween.tween_callback(queue_redraw).set_delay(0)


func _fade_overlay(target_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(_dim_overlay, "color:a", target_alpha, FADE_DURATION)


# =============================================================================
#  PROCESS - Követés
# =============================================================================
func _process(_delta: float) -> void:
	if _is_active and is_instance_valid(_target_control):
		# Ha a target mozog, követjük
		_update_frame_position()
		_update_arrow_position()
		queue_redraw()

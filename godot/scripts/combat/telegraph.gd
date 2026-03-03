## Telegraph - AoE telegraph jelzés (vizuális figyelmeztetés)
## Mutatja az ellenség támadásának területét a becsapódás előtt
class_name Telegraph
extends Node2D

signal telegraph_finished()

@export var duration: float = 1.0
@export var radius: float = 64.0
@export var color: Color = Color(1.0, 0.2, 0.2, 0.3)
@export var border_color: Color = Color(1.0, 0.0, 0.0, 0.6)
@export var shape_type: ShapeType = ShapeType.CIRCLE

enum ShapeType { CIRCLE, RECTANGLE, LINE, CONE }

var timer: float = 0.0
var is_active: bool = false
var rect_size: Vector2 = Vector2(64, 64)
var line_width: float = 32.0
var cone_angle: float = 45.0
var fill_progress: float = 0.0

# Pulse effect
var pulse_timer: float = 0.0
var pulse_speed: float = 4.0


func _ready() -> void:
	z_index = -1
	visible = false


func _process(delta: float) -> void:
	if not is_active:
		return
	
	timer += delta
	fill_progress = timer / duration
	pulse_timer += delta * pulse_speed
	
	if timer >= duration:
		is_active = false
		visible = false
		telegraph_finished.emit()
		queue_free()
		return
	
	queue_redraw()


func _draw() -> void:
	if not is_active:
		return
	
	var alpha_pulse: float = 0.3 + sin(pulse_timer) * 0.1
	var fill_color := Color(color.r, color.g, color.b, alpha_pulse * fill_progress)
	var border_alpha := border_color.a + sin(pulse_timer * 2.0) * 0.2
	var draw_border := Color(border_color.r, border_color.g, border_color.b, border_alpha)
	
	match shape_type:
		ShapeType.CIRCLE:
			draw_circle(Vector2.ZERO, radius * fill_progress, fill_color)
			draw_arc(Vector2.ZERO, radius, 0, TAU, 64, draw_border, 2.0)
		
		ShapeType.RECTANGLE:
			var r := Rect2(-rect_size / 2.0, rect_size)
			var fill_rect := Rect2(
				r.position,
				Vector2(r.size.x, r.size.y * fill_progress)
			)
			draw_rect(fill_rect, fill_color)
			draw_rect(r, draw_border, false, 2.0)
		
		ShapeType.LINE:
			var end_pos := Vector2(0, -radius)
			var current_end := end_pos * fill_progress
			draw_line(Vector2.ZERO, current_end, fill_color, line_width)
			draw_line(Vector2.ZERO, end_pos, draw_border, 2.0)
		
		ShapeType.CONE:
			var points: PackedVector2Array = []
			points.append(Vector2.ZERO)
			var segments: int = 16
			var half_angle: float = deg_to_rad(cone_angle / 2.0)
			for i in range(segments + 1):
				var angle: float = -half_angle + (float(i) / float(segments)) * cone_angle * (PI / 180.0) * 2.0
				angle = -half_angle + float(i) / float(segments) * half_angle * 2.0
				points.append(Vector2(sin(angle), -cos(angle)) * radius * fill_progress)
			if points.size() >= 3:
				draw_colored_polygon(points, fill_color)


## Telegraph aktiválás (kör alakú)
static func create_circle(parent: Node2D, pos: Vector2, p_radius: float, p_duration: float) -> Telegraph:
	var telegraph := Telegraph.new()
	telegraph.shape_type = ShapeType.CIRCLE
	telegraph.radius = p_radius
	telegraph.duration = p_duration
	telegraph.global_position = pos
	telegraph.is_active = true
	telegraph.visible = true
	parent.add_child(telegraph)
	return telegraph


## Telegraph aktiválás (téglalap alakú)
static func create_rectangle(parent: Node2D, pos: Vector2, size: Vector2, p_duration: float) -> Telegraph:
	var telegraph := Telegraph.new()
	telegraph.shape_type = ShapeType.RECTANGLE
	telegraph.rect_size = size
	telegraph.duration = p_duration
	telegraph.global_position = pos
	telegraph.is_active = true
	telegraph.visible = true
	parent.add_child(telegraph)
	return telegraph


## Telegraph aktiválás (vonalszeru)
static func create_line(parent: Node2D, pos: Vector2, length: float, direction: Vector2, p_duration: float) -> Telegraph:
	var telegraph := Telegraph.new()
	telegraph.shape_type = ShapeType.LINE
	telegraph.radius = length
	telegraph.line_width = 24.0
	telegraph.duration = p_duration
	telegraph.global_position = pos
	telegraph.rotation = direction.angle() + PI / 2.0
	telegraph.is_active = true
	telegraph.visible = true
	parent.add_child(telegraph)
	return telegraph

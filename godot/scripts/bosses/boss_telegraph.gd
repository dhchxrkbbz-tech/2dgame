## BossTelegraph - Boss attack telegraph vizuál rendszer
## Piros/narancs terület jelzés a támadás előtt
class_name BossTelegraph
extends Node2D

var active_telegraphs: Array[Dictionary] = []


func show_circle(center: Vector2, radius: float, duration: float, color: Color = Color(1, 0, 0, 0.3)) -> void:
	var telegraph := _create_telegraph_node(center, duration)
	telegraph["type"] = "circle"
	telegraph["radius"] = radius
	telegraph["color"] = color
	active_telegraphs.append(telegraph)


func show_line(start: Vector2, end: Vector2, width: float, duration: float, color: Color = Color(1, 0, 0, 0.3)) -> void:
	var telegraph := _create_telegraph_node(start, duration)
	telegraph["type"] = "line"
	telegraph["end"] = end
	telegraph["width"] = width
	telegraph["color"] = color
	active_telegraphs.append(telegraph)


func show_cone(origin: Vector2, direction: Vector2, angle_deg: float, length: float, duration: float, color: Color = Color(1, 0.5, 0, 0.3)) -> void:
	var telegraph := _create_telegraph_node(origin, duration)
	telegraph["type"] = "cone"
	telegraph["direction"] = direction
	telegraph["angle"] = deg_to_rad(angle_deg)
	telegraph["length"] = length
	telegraph["color"] = color
	active_telegraphs.append(telegraph)


func show_rect_area(center: Vector2, size: Vector2, duration: float, color: Color = Color(1, 0, 0, 0.3)) -> void:
	var telegraph := _create_telegraph_node(center, duration)
	telegraph["type"] = "rect"
	telegraph["size"] = size
	telegraph["color"] = color
	active_telegraphs.append(telegraph)


func show_multi_circle(positions: Array[Vector2], radius: float, duration: float, color: Color = Color(1, 0, 0, 0.3)) -> void:
	for pos in positions:
		show_circle(pos, radius, duration, color)


func _create_telegraph_node(pos: Vector2, duration: float) -> Dictionary:
	return {
		"position": pos,
		"duration": duration,
		"max_duration": duration,
		"elapsed": 0.0,
		"node": null,
	}


func _process(delta: float) -> void:
	var to_remove: Array[int] = []
	
	for i in active_telegraphs.size():
		active_telegraphs[i]["elapsed"] += delta
		if active_telegraphs[i]["elapsed"] >= active_telegraphs[i]["duration"]:
			to_remove.append(i)
	
	# Törlés visszafelé
	for i in range(to_remove.size() - 1, -1, -1):
		active_telegraphs.remove_at(to_remove[i])
	
	queue_redraw()


func _draw() -> void:
	for telegraph in active_telegraphs:
		var progress: float = telegraph["elapsed"] / telegraph["max_duration"]
		var alpha := lerpf(0.15, 0.5, progress)  # Egyre erősebb a jelölés
		var base_color: Color = telegraph.get("color", Color(1, 0, 0, 0.3))
		var draw_color := Color(base_color.r, base_color.g, base_color.b, alpha)
		var border_color := Color(base_color.r, base_color.g, base_color.b, alpha + 0.3)
		
		# Pulzáló hatás
		var pulse := sin(telegraph["elapsed"] * 6.0) * 0.1 + 1.0
		
		var local_pos: Vector2 = telegraph["position"] - global_position
		
		match telegraph.get("type", "circle"):
			"circle":
				var radius: float = telegraph["radius"] * pulse
				draw_circle(local_pos, radius, draw_color)
				draw_arc(local_pos, radius, 0, TAU, 32, border_color, 2.0)
			
			"line":
				var end_pos: Vector2 = telegraph["end"] - global_position
				var width: float = telegraph["width"] * pulse
				var dir := (end_pos - local_pos).normalized()
				var perp := dir.rotated(PI / 2.0) * width * 0.5
				var points := PackedVector2Array([
					local_pos - perp,
					local_pos + perp,
					end_pos + perp,
					end_pos - perp,
				])
				draw_colored_polygon(points, draw_color)
			
			"cone":
				var direction: Vector2 = telegraph["direction"]
				var angle: float = telegraph["angle"]
				var length: float = telegraph["length"] * pulse
				var base_angle := direction.angle()
				var segments := 16
				var points := PackedVector2Array()
				points.append(local_pos)
				for s in segments + 1:
					var a := base_angle - angle / 2.0 + angle * float(s) / float(segments)
					points.append(local_pos + Vector2.from_angle(a) * length)
				draw_colored_polygon(points, draw_color)
			
			"rect":
				var size: Vector2 = telegraph["size"] * pulse
				var rect_pos := local_pos - size / 2.0
				draw_rect(Rect2(rect_pos, size), draw_color, true)
				draw_rect(Rect2(rect_pos, size), border_color, false, 2.0)


func clear_all() -> void:
	active_telegraphs.clear()
	queue_redraw()

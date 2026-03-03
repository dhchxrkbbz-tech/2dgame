## InputManager - Input kezelés (Autoload singleton)
## WASD mozgás, egér, skill gombok
extends Node

# Mozgás irány (normalizált)
var move_direction: Vector2 = Vector2.ZERO

# Egér pozíció a világban
var mouse_world_position: Vector2 = Vector2.ZERO

# Irány az egér felé (karakter nézési irány)
var facing_direction: Vector2 = Vector2.DOWN

# Aktuális animációs irány (4 vagy 8 irány)
var anim_direction: Enums.Direction = Enums.Direction.SOUTH

# Input engedélyezés (UI megnyitáskor, cutscene stb. letiltható)
var input_enabled: bool = true

# Utolsó aktív input eszköz
var using_gamepad: bool = false


func _process(_delta: float) -> void:
	if not input_enabled:
		move_direction = Vector2.ZERO
		return
	
	_update_movement()
	_update_mouse_position()
	_update_facing_direction()


func _update_movement() -> void:
	move_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		move_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		move_direction.y += 1
	if Input.is_action_pressed("move_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		move_direction.x += 1
	
	if move_direction != Vector2.ZERO:
		move_direction = move_direction.normalized()


func _update_mouse_position() -> void:
	var viewport := get_viewport()
	if viewport:
		mouse_world_position = viewport.get_mouse_position()
		# Ha van kamera, konvertálás világ koordinátákra
		var canvas_transform := viewport.get_canvas_transform()
		mouse_world_position = canvas_transform.affine_inverse() * viewport.get_mouse_position()


func _update_facing_direction() -> void:
	if not GameManager.player:
		return
	
	var player_pos: Vector2 = GameManager.player.global_position
	facing_direction = (mouse_world_position - player_pos).normalized()
	
	if facing_direction != Vector2.ZERO:
		anim_direction = _vector_to_direction(facing_direction)


func _vector_to_direction(vec: Vector2) -> Enums.Direction:
	## Konvertál egy irányvektort 8 irányos enum értékre
	var angle := vec.angle()
	# Angle to 8 directions
	# 0 = jobb (EAST), PI/2 = le (SOUTH), PI = bal (WEST), -PI/2 = fel (NORTH)
	var segment := int(round(angle / (PI / 4.0))) % 8
	if segment < 0:
		segment += 8
	
	match segment:
		0: return Enums.Direction.EAST
		1: return Enums.Direction.SOUTHEAST
		2: return Enums.Direction.SOUTH
		3: return Enums.Direction.SOUTHWEST
		4: return Enums.Direction.WEST
		5: return Enums.Direction.NORTHWEST
		6: return Enums.Direction.NORTH
		7: return Enums.Direction.NORTHEAST
		_: return Enums.Direction.SOUTH


func get_direction_string(dir: Enums.Direction) -> String:
	## Irány enumot string-re konvertál (animáció nevekhez)
	match dir:
		Enums.Direction.NORTH: return "north"
		Enums.Direction.NORTHEAST: return "northeast"
		Enums.Direction.EAST: return "east"
		Enums.Direction.SOUTHEAST: return "southeast"
		Enums.Direction.SOUTH: return "south"
		Enums.Direction.SOUTHWEST: return "southwest"
		Enums.Direction.WEST: return "west"
		Enums.Direction.NORTHWEST: return "northwest"
		_: return "south"


func get_4dir_string() -> String:
	## 4 irányos string (sprite flip-el dolgozó animációkhoz)
	match anim_direction:
		Enums.Direction.NORTH, Enums.Direction.NORTHEAST, Enums.Direction.NORTHWEST:
			return "north"
		Enums.Direction.SOUTH, Enums.Direction.SOUTHEAST, Enums.Direction.SOUTHWEST:
			return "south"
		Enums.Direction.EAST:
			return "east"
		Enums.Direction.WEST:
			return "west"
		_:
			return "south"


func is_moving() -> bool:
	return move_direction != Vector2.ZERO


func disable_input() -> void:
	input_enabled = false
	move_direction = Vector2.ZERO


func enable_input() -> void:
	input_enabled = true

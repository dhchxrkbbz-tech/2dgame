## DoorController - Ajtó rendszer kezelése
## Normál, locked, combat, boss, hidden ajtó állapotok
class_name DoorController
extends Node

signal door_state_changed(door_index: int, new_state: int)
signal boss_door_unlocked()

## Ajtó állapotok
enum DoorState { OPEN, CLOSED, LOCKED, SEALED }

## Aktív ajtók
var doors: Array[Dictionary] = []
var door_nodes: Dictionary = {}  # door_index -> Node2D


## Ajtó létrehozása
func create_door(door_data: Dictionary, parent: Node2D) -> Node2D:
	var door_index: int = doors.size()
	var pos: Vector2i = door_data.get("pos", Vector2i.ZERO)
	var door_type: String = door_data.get("type", "normal")
	
	var door_node := StaticBody2D.new()
	door_node.name = "Door_%d_%s" % [door_index, door_type]
	door_node.position = Vector2(pos.x * Constants.TILE_SIZE, pos.y * Constants.TILE_SIZE)
	
	# Collision
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	col.shape = shape
	door_node.add_child(col)
	
	# Visual
	var sprite := Sprite2D.new()
	var img := Image.create(Constants.TILE_SIZE, Constants.TILE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(_get_door_color(door_type))
	sprite.texture = ImageTexture.create_from_image(img)
	door_node.add_child(sprite)
	
	# Interaction area (player detection)
	var area := Area2D.new()
	area.collision_layer = 0
	area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	var area_shape := CollisionShape2D.new()
	var area_rect := RectangleShape2D.new()
	area_rect.size = Vector2(Constants.TILE_SIZE + 8, Constants.TILE_SIZE + 8)
	area_shape.shape = area_rect
	area.add_child(area_shape)
	door_node.add_child(area)
	
	# Ajtó adatok
	var initial_state: DoorState
	match door_type:
		"normal": initial_state = DoorState.OPEN
		"combat": initial_state = DoorState.OPEN
		"locked": initial_state = DoorState.LOCKED
		"boss": initial_state = DoorState.LOCKED
		"hidden": initial_state = DoorState.CLOSED
		_: initial_state = DoorState.OPEN
	
	var full_data := door_data.duplicate()
	full_data["index"] = door_index
	full_data["state"] = initial_state
	full_data["node"] = door_node
	full_data["collision"] = col
	full_data["sprite"] = sprite
	doors.append(full_data)
	door_nodes[door_index] = door_node
	
	# Nyitott ajtóknál collision kikapcsolás
	if initial_state == DoorState.OPEN:
		_set_door_passable(door_node, col, true)
	
	parent.add_child(door_node)
	return door_node


## Ajtó megnyitása
func open_door(door_index: int) -> void:
	if door_index < 0 or door_index >= doors.size():
		return
	
	var door := doors[door_index]
	if door["state"] == DoorState.SEALED:
		return  # Sealed ajtó nem nyitható (boss fight közben)
	
	door["state"] = DoorState.OPEN
	_set_door_passable(door["node"], door["collision"], true)
	_update_door_visual(door)
	door_state_changed.emit(door_index, DoorState.OPEN)


## Ajtó bezárása
func close_door(door_index: int) -> void:
	if door_index < 0 or door_index >= doors.size():
		return
	
	doors[door_index]["state"] = DoorState.CLOSED
	_set_door_passable(doors[door_index]["node"], doors[door_index]["collision"], false)
	_update_door_visual(doors[door_index])
	door_state_changed.emit(door_index, DoorState.CLOSED)


## Ajtó zárolása
func lock_door(door_index: int) -> void:
	if door_index < 0 or door_index >= doors.size():
		return
	
	doors[door_index]["state"] = DoorState.LOCKED
	_set_door_passable(doors[door_index]["node"], doors[door_index]["collision"], false)
	_update_door_visual(doors[door_index])
	door_state_changed.emit(door_index, DoorState.LOCKED)


## Ajtó lezárása (boss fight)
func seal_door(door_index: int) -> void:
	if door_index < 0 or door_index >= doors.size():
		return
	
	doors[door_index]["state"] = DoorState.SEALED
	_set_door_passable(doors[door_index]["node"], doors[door_index]["collision"], false)
	_update_door_visual(doors[door_index])
	door_state_changed.emit(door_index, DoorState.SEALED)


## Szoba összes ajtajának lezárása (combat room belépéskor)
func seal_room_doors(room_index: int) -> void:
	for door in doors:
		if door.get("room_a", -1) == room_index or door.get("connected_room", -1) == room_index:
			seal_door(door["index"])


## Szoba összes ajtajának megnyitása (combat room cleared)
func unseal_room_doors(room_index: int) -> void:
	for door in doors:
		if door.get("room_a", -1) == room_index or door.get("connected_room", -1) == room_index:
			if door["state"] == DoorState.SEALED:
				open_door(door["index"])


## Boss ajtó feloldása (minden szoba cleared)
func unlock_boss_door() -> void:
	for door in doors:
		if door.get("type", "") == "boss" and door["state"] == DoorState.LOCKED:
			open_door(door["index"])
			boss_door_unlocked.emit()


## Kulcs használata locked ajtóhoz
func try_unlock(door_index: int, has_key: bool = true) -> bool:
	if door_index < 0 or door_index >= doors.size():
		return false
	
	var door := doors[door_index]
	if door["state"] != DoorState.LOCKED:
		return false
	
	if has_key or door.get("type", "") != "locked":
		open_door(door_index)
		return true
	
	return false


## Játékoshoz legközelebbi interaktálható ajtó keresése
func find_nearest_door(player_pos: Vector2, max_distance: float = 48.0) -> int:
	var nearest_dist := max_distance
	var nearest_idx := -1
	
	for door in doors:
		var door_pos := Vector2(door["pos"].x * Constants.TILE_SIZE, 
								door["pos"].y * Constants.TILE_SIZE)
		var dist := player_pos.distance_to(door_pos)
		if dist < nearest_dist and door["state"] != DoorState.OPEN:
			nearest_dist = dist
			nearest_idx = door["index"]
	
	return nearest_idx


func _set_door_passable(node: StaticBody2D, collision: CollisionShape2D, passable: bool) -> void:
	if is_instance_valid(collision):
		collision.disabled = passable
	if is_instance_valid(node):
		node.visible = not passable


func _update_door_visual(door: Dictionary) -> void:
	if not is_instance_valid(door.get("sprite")):
		return
	
	var sprite: Sprite2D = door["sprite"]
	var state: DoorState = door["state"]
	
	match state:
		DoorState.OPEN:
			sprite.modulate = Color(1, 1, 1, 0.2)
		DoorState.CLOSED:
			sprite.modulate = Color(0.6, 0.5, 0.3, 0.9)
		DoorState.LOCKED:
			sprite.modulate = Color(0.8, 0.2, 0.2, 0.9)
		DoorState.SEALED:
			sprite.modulate = Color(0.9, 0.1, 0.1, 1.0)


func _get_door_color(door_type: String) -> Color:
	match door_type:
		"normal": return Color(0.6, 0.5, 0.3, 0.9)
		"combat": return Color(0.6, 0.5, 0.3, 0.9)
		"locked": return Color(0.7, 0.5, 0.1, 0.9)
		"boss": return Color(0.5, 0.1, 0.1, 0.95)
		"hidden": return Color(0.35, 0.35, 0.38, 0.3)  # Alig látható
		_: return Color(0.6, 0.5, 0.3, 0.9)


## Multiplayer sync: ajtó állapot broadcast
func get_sync_data() -> Array[Dictionary]:
	var sync: Array[Dictionary] = []
	for door in doors:
		sync.append({
			"index": door["index"],
			"state": door["state"],
			"pos": door["pos"],
		})
	return sync


## Multiplayer sync: ajtó állapot alkalmazás
func apply_sync_data(sync_data: Array[Dictionary]) -> void:
	for data in sync_data:
		var idx: int = data.get("index", -1)
		var state: int = data.get("state", DoorState.OPEN)
		if idx >= 0 and idx < doors.size():
			doors[idx]["state"] = state
			match state:
				DoorState.OPEN: open_door(idx)
				DoorState.CLOSED: close_door(idx)
				DoorState.LOCKED: lock_door(idx)
				DoorState.SEALED: seal_door(idx)


## Cleanup
func clear_all() -> void:
	for door in doors:
		if is_instance_valid(door.get("node")):
			door["node"].queue_free()
	doors.clear()
	door_nodes.clear()

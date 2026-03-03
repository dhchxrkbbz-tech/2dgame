## BSPGenerator - Binary Space Partitioning dungeon generátor
## Rekurzív tér felosztás szobák és folyosók generálásához
class_name BSPGenerator
extends RefCounted

const MIN_ROOM_SIZE: int = 8
const MAX_ROOM_SIZE: int = 20
const MAX_DEPTH: int = 5
const PADDING: int = 2

var rng: RandomNumberGenerator


class BSPNode:
	var rect: Rect2i
	var left: BSPNode = null
	var right: BSPNode = null
	var room: Rect2i = Rect2i()
	var is_leaf: bool = false
	var split_horizontal: bool = false
	
	func get_room() -> Rect2i:
		## Rekurzívan megkeresi a legközelebbi szobát
		if is_leaf:
			return room
		if left:
			return left.get_room()
		if right:
			return right.get_room()
		return Rect2i()
	
	func get_all_rooms() -> Array[Rect2i]:
		var rooms: Array[Rect2i] = []
		if is_leaf and room.size.x > 0:
			rooms.append(room)
		else:
			if left:
				rooms.append_array(left.get_all_rooms())
			if right:
				rooms.append_array(right.get_all_rooms())
		return rooms
	
	func get_all_leaves() -> Array[BSPNode]:
		var leaves: Array[BSPNode] = []
		if is_leaf:
			leaves.append(self)
		else:
			if left:
				leaves.append_array(left.get_all_leaves())
			if right:
				leaves.append_array(right.get_all_leaves())
		return leaves


func _init(seed_value: int = -1) -> void:
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value if seed_value >= 0 else randi()


func generate(area: Rect2i, target_rooms: int = 10) -> BSPNode:
	## Fő generáló metódus
	var depth := _calculate_depth(target_rooms)
	return _split(area, 0, depth)


func _calculate_depth(target_rooms: int) -> int:
	# 2^depth ~ room count
	var depth := 0
	var count := 1
	while count < target_rooms:
		depth += 1
		count *= 2
	return mini(depth, MAX_DEPTH)


func _split(area: Rect2i, depth: int, max_depth: int) -> BSPNode:
	var node := BSPNode.new()
	node.rect = area
	
	# Túl kicsi vagy elég mély → levél
	if area.size.x < MIN_ROOM_SIZE * 2 + PADDING * 2 or \
	   area.size.y < MIN_ROOM_SIZE * 2 + PADDING * 2 or \
	   depth >= max_depth:
		node.is_leaf = true
		node.room = _create_room_in_area(area)
		return node
	
	# Vágási irány: a hosszabb tengely mentén
	var split_horizontal: bool
	if area.size.x > area.size.y * 1.25:
		split_horizontal = false  # Függőleges vágás
	elif area.size.y > area.size.x * 1.25:
		split_horizontal = true   # Vízszintes vágás
	else:
		split_horizontal = rng.randf() > 0.5
	
	node.split_horizontal = split_horizontal
	
	# Vágási pozíció (35-65% tartomány)
	var min_split: int
	var max_split: int
	
	if split_horizontal:
		min_split = int(area.size.y * 0.35)
		max_split = int(area.size.y * 0.65)
		min_split = maxi(min_split, MIN_ROOM_SIZE + PADDING)
		max_split = mini(max_split, area.size.y - MIN_ROOM_SIZE - PADDING)
		
		if min_split >= max_split:
			node.is_leaf = true
			node.room = _create_room_in_area(area)
			return node
		
		var split_pos: int = rng.randi_range(min_split, max_split)
		
		node.left = _split(
			Rect2i(area.position.x, area.position.y, area.size.x, split_pos),
			depth + 1, max_depth
		)
		node.right = _split(
			Rect2i(area.position.x, area.position.y + split_pos, area.size.x, area.size.y - split_pos),
			depth + 1, max_depth
		)
	else:
		min_split = int(area.size.x * 0.35)
		max_split = int(area.size.x * 0.65)
		min_split = maxi(min_split, MIN_ROOM_SIZE + PADDING)
		max_split = mini(max_split, area.size.x - MIN_ROOM_SIZE - PADDING)
		
		if min_split >= max_split:
			node.is_leaf = true
			node.room = _create_room_in_area(area)
			return node
		
		var split_pos: int = rng.randi_range(min_split, max_split)
		
		node.left = _split(
			Rect2i(area.position.x, area.position.y, split_pos, area.size.y),
			depth + 1, max_depth
		)
		node.right = _split(
			Rect2i(area.position.x + split_pos, area.position.y, area.size.x - split_pos, area.size.y),
			depth + 1, max_depth
		)
	
	return node


func _create_room_in_area(area: Rect2i) -> Rect2i:
	var room_w: int = rng.randi_range(MIN_ROOM_SIZE, mini(MAX_ROOM_SIZE, area.size.x - PADDING * 2))
	var room_h: int = rng.randi_range(MIN_ROOM_SIZE, mini(MAX_ROOM_SIZE, area.size.y - PADDING * 2))
	
	room_w = maxi(room_w, MIN_ROOM_SIZE)
	room_h = maxi(room_h, MIN_ROOM_SIZE)
	
	var max_x: int = area.position.x + area.size.x - room_w - PADDING
	var max_y: int = area.position.y + area.size.y - room_h - PADDING
	var min_x: int = area.position.x + PADDING
	var min_y: int = area.position.y + PADDING
	
	var room_x: int = rng.randi_range(min_x, maxi(min_x, max_x))
	var room_y: int = rng.randi_range(min_y, maxi(min_y, max_y))
	
	return Rect2i(room_x, room_y, room_w, room_h)


## Folyosók generálása BSP testvér node-ok között
func generate_corridors(node: BSPNode) -> Array[Dictionary]:
	var corridors: Array[Dictionary] = []
	_connect_bsp_nodes(node, corridors)
	return corridors


func _connect_bsp_nodes(node: BSPNode, corridors: Array[Dictionary]) -> void:
	if node.is_leaf:
		return
	
	if node.left and node.right:
		var room_a := node.left.get_room()
		var room_b := node.right.get_room()
		
		if room_a.size.x > 0 and room_b.size.x > 0:
			corridors.append(_create_corridor(room_a, room_b))
		
		_connect_bsp_nodes(node.left, corridors)
		_connect_bsp_nodes(node.right, corridors)


func _create_corridor(room_a: Rect2i, room_b: Rect2i) -> Dictionary:
	var center_a := Vector2i(
		room_a.position.x + room_a.size.x / 2,
		room_a.position.y + room_a.size.y / 2
	)
	var center_b := Vector2i(
		room_b.position.x + room_b.size.x / 2,
		room_b.position.y + room_b.size.y / 2
	)
	
	var width: int = rng.randi_range(2, 3)
	
	# L-alakú folyosó
	var horizontal_first: bool = rng.randf() > 0.5
	
	return {
		"start": center_a,
		"end": center_b,
		"width": width,
		"horizontal_first": horizontal_first,
	}

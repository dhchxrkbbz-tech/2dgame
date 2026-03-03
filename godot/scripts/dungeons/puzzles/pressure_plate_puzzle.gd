## PressurePlatePuzzle - Nyomólapok + mozgatható kövek
## Minden nyomólapot le kell nyomni egyszerre
class_name PressurePlatePuzzle
extends PuzzleBase

var plates: Array[Dictionary] = []
var movable_blocks: Array[Dictionary] = []
var plate_count: int = 3


func _build_puzzle() -> void:
	puzzle_type = "pressure_plate"
	
	if not room:
		return
	
	plate_count = randi_range(2, 4)
	plates.clear()
	movable_blocks.clear()
	
	var tiles := room.get_tiles()
	var used_positions: Array[Vector2i] = []
	
	# Nyomólapok
	for i in plate_count:
		var pos: Vector2i
		var attempts := 0
		while attempts < 20:
			pos = tiles[randi() % tiles.size()]
			if pos not in used_positions:
				used_positions.append(pos)
				break
			attempts += 1
		
		var world_pos := Vector2(pos.x * Constants.TILE_SIZE, pos.y * Constants.TILE_SIZE)
		var plate := _create_plate_node(i, world_pos)
		plates.append(plate)
	
	# Mozgatható kövek (annyi mint a plate-ek száma)
	for i in plate_count:
		var pos: Vector2i
		var attempts := 0
		while attempts < 20:
			pos = tiles[randi() % tiles.size()]
			if pos not in used_positions:
				used_positions.append(pos)
				break
			attempts += 1
		
		var world_pos := Vector2(pos.x * Constants.TILE_SIZE, pos.y * Constants.TILE_SIZE)
		var block := _create_block_node(i, world_pos)
		movable_blocks.append(block)


func _create_plate_node(index: int, world_pos: Vector2) -> Dictionary:
	var plate_area := Area2D.new()
	plate_area.name = "Plate_%d" % index
	plate_area.global_position = world_pos
	plate_area.collision_layer = 0
	plate_area.collision_mask = (1 << (Constants.LAYER_PLAYER_PHYSICS - 1)) | (1 << 9)  # player + block
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(28, 28)
	shape.shape = rect
	plate_area.add_child(shape)
	
	var sprite := Sprite2D.new()
	var img := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.6, 0.5, 0.2, 0.6))
	sprite.texture = ImageTexture.create_from_image(img)
	plate_area.add_child(sprite)
	
	plate_area.body_entered.connect(_on_plate_body_entered.bind(index))
	plate_area.body_exited.connect(_on_plate_body_exited.bind(index))
	
	add_child(plate_area)
	
	return {
		"index": index,
		"node": plate_area,
		"sprite": sprite,
		"pressed": false,
		"world_pos": world_pos,
	}


func _create_block_node(index: int, world_pos: Vector2) -> Dictionary:
	var block := CharacterBody2D.new()
	block.name = "Block_%d" % index
	block.global_position = world_pos
	block.collision_layer = 1 << 9  # Block layer
	block.collision_mask = 1 << 2  # Wall layer
	block.add_to_group("pushable_block")
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(28, 28)
	shape.shape = rect
	block.add_child(shape)
	
	var sprite := Sprite2D.new()
	var img := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.45, 0.4, 0.35, 0.9))
	sprite.texture = ImageTexture.create_from_image(img)
	block.add_child(sprite)
	
	add_child(block)
	
	return {
		"index": index,
		"node": block,
		"world_pos": world_pos,
	}


func _on_plate_body_entered(_body: Node, plate_index: int) -> void:
	plates[plate_index]["pressed"] = true
	plates[plate_index]["sprite"].modulate = Color.GREEN
	_check_all_plates()


func _on_plate_body_exited(_body: Node, plate_index: int) -> void:
	# Ellenőrzés: van-e még test a plate-en
	var area: Area2D = plates[plate_index]["node"]
	if area.get_overlapping_bodies().is_empty():
		plates[plate_index]["pressed"] = false
		plates[plate_index]["sprite"].modulate = Color.WHITE


func _check_all_plates() -> void:
	var all_pressed := true
	for plate in plates:
		if not plate["pressed"]:
			all_pressed = false
			break
	
	if all_pressed:
		solve()


func _on_solved() -> void:
	if room:
		spawn_reward_chest(room.get_world_center())


func _on_reset() -> void:
	for plate in plates:
		plate["pressed"] = false
		plate["sprite"].modulate = Color.WHITE

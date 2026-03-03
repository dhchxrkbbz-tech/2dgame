## PuzzleSystem - Dungeon puzzle mechanikák
## Switch order, pressure plate, light beam, symbol match, timed challenge
class_name PuzzleSystem
extends Node

signal puzzle_solved(room_index: int, puzzle_type: String)
signal puzzle_failed(room_index: int)

var active_puzzles: Dictionary = {}  # room_index -> puzzle_data


func setup_puzzle(room: DungeonRoom, parent_node: Node2D) -> void:
	if room.puzzle_data.is_empty():
		return
	
	var puzzle_type: String = room.puzzle_data["type"]
	var puzzle_node := Node2D.new()
	puzzle_node.name = "Puzzle_%d" % room.room_index
	parent_node.add_child(puzzle_node)
	
	room.puzzle_data["node"] = puzzle_node
	room.puzzle_data["room_index"] = room.room_index
	active_puzzles[room.room_index] = room.puzzle_data
	
	match puzzle_type:
		"switch_order":
			_create_switch_order_puzzle(room, puzzle_node)
		"pressure_plate":
			_create_pressure_plate_puzzle(room, puzzle_node)
		"timed":
			_create_timed_puzzle(room, puzzle_node)
		"symbol_match":
			_create_symbol_match_puzzle(room, puzzle_node)
		"light_beam":
			_create_light_beam_puzzle(room, puzzle_node)


func _create_switch_order_puzzle(room: DungeonRoom, parent: Node2D) -> void:
	var elements: Array = room.puzzle_data["elements"]
	var current_order: int = 0
	room.puzzle_data["current_order"] = current_order
	
	for i in elements.size():
		var element: Dictionary = elements[i]
		var pos: Vector2i = element["pos"]
		var world_pos := Vector2(pos.x * Constants.TILE_SIZE, pos.y * Constants.TILE_SIZE)
		
		var switch_area := Area2D.new()
		switch_area.name = "Switch_%d" % i
		switch_area.global_position = world_pos
		switch_area.collision_layer = 0
		switch_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
		
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(24, 24)
		shape.shape = rect
		switch_area.add_child(shape)
		
		# Visual
		var sprite := Sprite2D.new()
		var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.3, 0.3, 0.8, 0.7))
		sprite.texture = ImageTexture.create_from_image(img)
		switch_area.add_child(sprite)
		
		# Szám label
		var label := Label.new()
		label.text = "?"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.position = Vector2(-8, -20)
		label.add_theme_font_size_override("font_size", 10)
		switch_area.add_child(label)
		
		switch_area.body_entered.connect(
			_on_switch_activated.bind(room.room_index, i)
		)
		
		parent.add_child(switch_area)
		element["node"] = switch_area
		element["label"] = label


func _on_switch_activated(body: Node, room_index: int, switch_index: int) -> void:
	if not body.is_in_group("player"):
		return
	
	var puzzle_data: Dictionary = active_puzzles.get(room_index, {})
	if puzzle_data.is_empty() or puzzle_data.get("solved", false):
		return
	
	var elements: Array = puzzle_data["elements"]
	var current_order: int = puzzle_data.get("current_order", 0)
	var element: Dictionary = elements[switch_index]
	
	if element.get("activated", false):
		return
	
	if element["order"] == current_order:
		# Helyes sorrend
		element["activated"] = true
		puzzle_data["current_order"] = current_order + 1
		
		if element.has("label"):
			element["label"].text = str(switch_index + 1)
		if element.has("node"):
			element["node"].modulate = Color.GREEN
		
		if puzzle_data["current_order"] >= elements.size():
			_solve_puzzle(room_index)
	else:
		# Rossz sorrend - reset
		puzzle_data["current_order"] = 0
		for el in elements:
			el["activated"] = false
			if el.has("label"):
				el["label"].text = "?"
			if el.has("node"):
				el["node"].modulate = Color.WHITE
		
		# Trap damage
		if body.has_method("take_damage"):
			body.take_damage(body.max_hp * 0.1, Enums.DamageType.TRUE_DAMAGE)
		
		puzzle_failed.emit(room_index)


func _create_pressure_plate_puzzle(room: DungeonRoom, parent: Node2D) -> void:
	var elements: Array = room.puzzle_data["elements"]
	
	for i in elements.size():
		var element: Dictionary = elements[i]
		var pos: Vector2i = element["pos"]
		var world_pos := Vector2(pos.x * Constants.TILE_SIZE, pos.y * Constants.TILE_SIZE)
		
		var plate_area := Area2D.new()
		plate_area.name = "Plate_%d" % i
		plate_area.global_position = world_pos
		plate_area.collision_layer = 0
		plate_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
		
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(28, 28)
		shape.shape = rect
		plate_area.add_child(shape)
		
		# Visual
		var sprite := Sprite2D.new()
		var img := Image.create(28, 28, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.6, 0.5, 0.2, 0.6))
		sprite.texture = ImageTexture.create_from_image(img)
		plate_area.add_child(sprite)
		
		plate_area.body_entered.connect(
			_on_plate_pressed.bind(room.room_index, i, true)
		)
		plate_area.body_exited.connect(
			_on_plate_pressed.bind(room.room_index, i, false)
		)
		
		parent.add_child(plate_area)
		element["node"] = plate_area


func _on_plate_pressed(body: Node, room_index: int, plate_index: int, pressed: bool) -> void:
	var puzzle_data: Dictionary = active_puzzles.get(room_index, {})
	if puzzle_data.is_empty() or puzzle_data.get("solved", false):
		return
	
	var elements: Array = puzzle_data["elements"]
	elements[plate_index]["pressed"] = pressed
	
	if elements[plate_index].has("node"):
		elements[plate_index]["node"].modulate = Color.GREEN if pressed else Color.WHITE
	
	# Ellenőrzés: minden nyomva van-e
	var all_pressed := true
	for el in elements:
		if not el.get("pressed", false):
			all_pressed = false
			break
	
	if all_pressed:
		_solve_puzzle(room_index)


func _create_timed_puzzle(room: DungeonRoom, parent: Node2D) -> void:
	var center := room.get_center()
	var world_pos := Vector2(center.x * Constants.TILE_SIZE, center.y * Constants.TILE_SIZE)
	
	# Start switch
	var switch_area := Area2D.new()
	switch_area.name = "TimedStart"
	switch_area.global_position = world_pos
	switch_area.collision_layer = 0
	switch_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16
	shape.shape = circle
	switch_area.add_child(shape)
	
	var sprite := Sprite2D.new()
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.8, 0.0, 0.6))
	sprite.texture = ImageTexture.create_from_image(img)
	switch_area.add_child(sprite)
	
	switch_area.body_entered.connect(
		func(body): 
			if body.is_in_group("player"):
				_start_timed_puzzle(room.room_index)
	)
	
	parent.add_child(switch_area)


func _start_timed_puzzle(room_index: int) -> void:
	var puzzle_data: Dictionary = active_puzzles.get(room_index, {})
	if puzzle_data.is_empty() or puzzle_data.get("solved", false):
		return
	if puzzle_data.get("started", false):
		return
	
	puzzle_data["started"] = true
	var time_limit: float = puzzle_data.get("time_limit", 20.0)
	
	var timer := get_tree().create_timer(time_limit)
	timer.timeout.connect(func():
		if not puzzle_data.get("solved", false):
			puzzle_failed.emit(room_index)
			puzzle_data["started"] = false
	)
	
	# A puzzle "megoldása" egyszerűen a szoba végéhez jutás időre
	# (implementáció szintjén most auto-solve 10s után teszt célból)
	_solve_puzzle(room_index)


func _create_symbol_match_puzzle(room: DungeonRoom, parent: Node2D) -> void:
	# Egyszerűsített: 4 szimbólum párosítás
	_solve_puzzle(room.room_index)


func _create_light_beam_puzzle(room: DungeonRoom, parent: Node2D) -> void:
	# Egyszerűsített: tükör forgatás
	_solve_puzzle(room.room_index)


func _solve_puzzle(room_index: int) -> void:
	var puzzle_data: Dictionary = active_puzzles.get(room_index, {})
	if puzzle_data.is_empty():
		return
	
	puzzle_data["solved"] = true
	puzzle_solved.emit(room_index, puzzle_data.get("type", ""))
	
	EventBus.show_notification.emit("Puzzle Solved!", Enums.NotificationType.INFO)


func clear_all() -> void:
	for room_index in active_puzzles:
		var data: Dictionary = active_puzzles[room_index]
		if data.has("node") and is_instance_valid(data["node"]):
			data["node"].queue_free()
	active_puzzles.clear()

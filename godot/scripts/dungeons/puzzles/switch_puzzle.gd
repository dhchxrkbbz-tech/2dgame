## SwitchPuzzle - Kapcsolók helyes sorrendben nyomása
## N db kapcsoló (3-5), helyes sorrend szükséges
class_name SwitchPuzzle
extends PuzzleBase

var switches: Array[Dictionary] = []
var correct_order: Array[int] = []
var current_step: int = 0
var switch_count: int = 3


func _build_puzzle() -> void:
	puzzle_type = "switch_order"
	
	if not room:
		return
	
	switch_count = randi_range(3, 5)
	correct_order.clear()
	switches.clear()
	current_step = 0
	
	# Random helyes sorrend generálás
	var indices: Array[int] = []
	for i in switch_count:
		indices.append(i)
	indices.shuffle()
	correct_order = indices
	
	# Switch-ek létrehozása
	var tiles := room.get_tiles()
	var used_positions: Array[Vector2i] = []
	
	for i in switch_count:
		var pos: Vector2i
		var attempts := 0
		while attempts < 20:
			pos = tiles[randi() % tiles.size()]
			if pos not in used_positions:
				used_positions.append(pos)
				break
			attempts += 1
		
		var world_pos := Vector2(pos.x * Constants.TILE_SIZE, pos.y * Constants.TILE_SIZE)
		var switch_data := _create_switch_node(i, world_pos)
		switches.append(switch_data)


func _create_switch_node(index: int, world_pos: Vector2) -> Dictionary:
	var switch_area := Area2D.new()
	switch_area.name = "Switch_%d" % index
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
	
	# Szimbólum (hint) label
	var label := Label.new()
	label.text = "?"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-8, -20)
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color.WHITE)
	switch_area.add_child(label)
	
	switch_area.body_entered.connect(_on_switch_touched.bind(index))
	add_child(switch_area)
	
	return {
		"index": index,
		"node": switch_area,
		"sprite": sprite,
		"label": label,
		"activated": false,
		"world_pos": world_pos,
	}


func _on_switch_touched(body: Node, switch_index: int) -> void:
	if not body.is_in_group("player"):
		return
	if is_solved or not is_active:
		return
	if switches[switch_index]["activated"]:
		return
	
	# Helyes sorrend ellenőrzés
	if correct_order[current_step] == switch_index:
		# Helyes!
		switches[switch_index]["activated"] = true
		switches[switch_index]["label"].text = str(current_step + 1)
		switches[switch_index]["sprite"].modulate = Color.GREEN
		current_step += 1
		
		if current_step >= switch_count:
			solve()
	else:
		# Rossz sorrend → reset + damage
		if body.has_method("take_damage"):
			var max_hp: int = body.get("max_hp") if body.get("max_hp") else 100
			body.take_damage(int(max_hp * 0.1), Enums.DamageType.TRUE_DAMAGE)
		
		fail()
		_reset_switches()


func _reset_switches() -> void:
	current_step = 0
	for sw in switches:
		sw["activated"] = false
		sw["label"].text = "?"
		sw["sprite"].modulate = Color.WHITE


func _on_solved() -> void:
	# Fal/ajtó nyílik → loot chest
	if room:
		spawn_reward_chest(room.get_world_center())


func _on_reset() -> void:
	_reset_switches()

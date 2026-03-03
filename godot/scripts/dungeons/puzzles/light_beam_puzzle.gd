## LightBeamPuzzle - Fénysugár + tükrök
## Fényforrás → forgatható tükrök → célpont
class_name LightBeamPuzzle
extends PuzzleBase

## Irányok (4-irányú: 0=jobb, 1=le, 2=bal, 3=fel)
const DIRECTIONS: Array[Vector2i] = [
	Vector2i(1, 0),   # Jobb
	Vector2i(0, 1),   # Le
	Vector2i(-1, 0),  # Bal
	Vector2i(0, -1),  # Fel
]

var light_source_pos: Vector2i = Vector2i.ZERO
var target_pos: Vector2i = Vector2i.ZERO
var mirrors: Array[Dictionary] = []
var beam_line: Line2D = null
var mirror_count: int = 3


func _build_puzzle() -> void:
	puzzle_type = "light_beam"
	
	if not room:
		return
	
	mirror_count = randi_range(2, 4)
	mirrors.clear()
	
	var tiles := room.get_tiles()
	var used_positions: Array[Vector2i] = []
	
	# Fényforrás (bal felső sarok közelében)
	light_source_pos = Vector2i(room.rect.position.x + 1, room.rect.position.y + 1)
	used_positions.append(light_source_pos)
	_create_light_source()
	
	# Célpont (jobb alsó sarok közelében)
	target_pos = Vector2i(room.rect.end.x - 2, room.rect.end.y - 2)
	used_positions.append(target_pos)
	_create_target()
	
	# Tükrök
	for i in mirror_count:
		var pos: Vector2i
		var attempts := 0
		while attempts < 20:
			pos = tiles[randi() % tiles.size()]
			if pos not in used_positions:
				used_positions.append(pos)
				break
			attempts += 1
		
		var mirror := _create_mirror(i, pos)
		mirrors.append(mirror)
	
	# Fénysugár vonal
	beam_line = Line2D.new()
	beam_line.name = "LightBeam"
	beam_line.default_color = Color(1.0, 1.0, 0.5, 0.6)
	beam_line.width = 2.0
	add_child(beam_line)
	
	_update_beam()


func _create_light_source() -> void:
	var sprite := Sprite2D.new()
	sprite.name = "LightSource"
	sprite.position = Vector2(light_source_pos.x * Constants.TILE_SIZE, 
							light_source_pos.y * Constants.TILE_SIZE)
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 1.0, 0.3, 0.9))
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)
	
	# Fényforrás glow
	var light := PointLight2D.new()
	light.position = sprite.position
	light.color = Color(1.0, 1.0, 0.5, 0.5)
	light.energy = 0.5
	var light_img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	for x in 32:
		for y in 32:
			var dx := float(x - 16) / 16.0
			var dy := float(y - 16) / 16.0
			var alpha := clampf(1.0 - sqrt(dx * dx + dy * dy), 0.0, 1.0)
			light_img.set_pixel(x, y, Color(1, 1, 1, alpha))
	light.texture = ImageTexture.create_from_image(light_img)
	add_child(light)


func _create_target() -> void:
	var target_area := Area2D.new()
	target_area.name = "Target"
	target_area.position = Vector2(target_pos.x * Constants.TILE_SIZE, 
								target_pos.y * Constants.TILE_SIZE)
	
	var sprite := Sprite2D.new()
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.5, 0.5, 0.8, 0.7))
	sprite.texture = ImageTexture.create_from_image(img)
	target_area.add_child(sprite)
	
	add_child(target_area)


func _create_mirror(index: int, tile_pos: Vector2i) -> Dictionary:
	var world_pos := Vector2(tile_pos.x * Constants.TILE_SIZE, tile_pos.y * Constants.TILE_SIZE)
	
	var mirror_area := Area2D.new()
	mirror_area.name = "Mirror_%d" % index
	mirror_area.global_position = world_pos
	mirror_area.collision_layer = 0
	mirror_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(20, 20)
	shape.shape = rect
	mirror_area.add_child(shape)
	
	var sprite := Sprite2D.new()
	var img := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.6, 0.8, 1.0, 0.7))
	sprite.texture = ImageTexture.create_from_image(img)
	mirror_area.add_child(sprite)
	
	# Irány jelző label
	var label := Label.new()
	label.text = "→"  # Irány jelzés
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-8, -16)
	label.add_theme_font_size_override("font_size", 12)
	mirror_area.add_child(label)
	
	# Kattintásra forgatás
	mirror_area.body_entered.connect(
		func(body):
			if body.is_in_group("player"):
				_start_interaction(index)
	)
	
	add_child(mirror_area)
	
	return {
		"index": index,
		"node": mirror_area,
		"label": label,
		"tile_pos": tile_pos,
		"direction": randi() % 4,  # Random induló irány
	}


func _start_interaction(mirror_index: int) -> void:
	if is_solved or not is_active:
		return
	_rotate_mirror(mirror_index)


func _rotate_mirror(mirror_index: int) -> void:
	mirrors[mirror_index]["direction"] = (mirrors[mirror_index]["direction"] + 1) % 4
	
	var dir_labels := ["→", "↓", "←", "↑"]
	mirrors[mirror_index]["label"].text = dir_labels[mirrors[mirror_index]["direction"]]
	
	_update_beam()


## Fénysugár újraszámolás
func _update_beam() -> void:
	if not beam_line:
		return
	
	beam_line.clear_points()
	
	var current_pos := light_source_pos
	var current_dir := 0  # Jobbra indul
	
	var start_world := Vector2(current_pos.x * Constants.TILE_SIZE, 
							current_pos.y * Constants.TILE_SIZE)
	beam_line.add_point(start_world)
	
	# Raycasting a fénysugárnak
	for _step in 100:
		var next_pos := current_pos + DIRECTIONS[current_dir]
		
		# Célpont elérve?
		if next_pos == target_pos:
			var target_world := Vector2(target_pos.x * Constants.TILE_SIZE, 
									target_pos.y * Constants.TILE_SIZE)
			beam_line.add_point(target_world)
			solve()
			return
		
		# Tükör-e?
		var hit_mirror := false
		for mirror in mirrors:
			if mirror["tile_pos"] == next_pos:
				var mirror_world := Vector2(next_pos.x * Constants.TILE_SIZE, 
										next_pos.y * Constants.TILE_SIZE)
				beam_line.add_point(mirror_world)
				current_pos = next_pos
				current_dir = mirror["direction"]
				hit_mirror = true
				break
		
		if hit_mirror:
			continue
		
		# Room-on kívül vagy fal → megáll
		if not room.contains_tile(next_pos):
			var end_world := Vector2(next_pos.x * Constants.TILE_SIZE, 
								next_pos.y * Constants.TILE_SIZE)
			beam_line.add_point(end_world)
			return
		
		current_pos = next_pos
	
	# Max lépés elérve
	var final_world := Vector2(current_pos.x * Constants.TILE_SIZE, 
							current_pos.y * Constants.TILE_SIZE)
	beam_line.add_point(final_world)


func _on_solved() -> void:
	if beam_line:
		beam_line.default_color = Color(0.3, 1.0, 0.3, 0.8)
	if room:
		spawn_reward_chest(room.get_world_center())

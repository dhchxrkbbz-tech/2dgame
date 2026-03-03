## SymbolMatchPuzzle - Szimbólumok párosítása (memory game)
## 2D grid szimbólumok, párosítsd az azonosakat
class_name SymbolMatchPuzzle
extends PuzzleBase

var symbols: Array[Dictionary] = []
var first_selected: int = -1
var second_selected: int = -1
var matched_pairs: int = 0
var total_pairs: int = 3
var is_checking: bool = false

## Szimbólum típusok (egyszerű jelzések)
const SYMBOL_CHARS: Array[String] = ["★", "◆", "▲", "●", "■", "♦"]
const SYMBOL_COLORS: Array[Color] = [
	Color(1.0, 0.3, 0.3),  # Piros
	Color(0.3, 0.8, 1.0),  # Kék
	Color(0.3, 1.0, 0.3),  # Zöld
	Color(1.0, 1.0, 0.3),  # Sárga
	Color(0.8, 0.3, 1.0),  # Lila
	Color(1.0, 0.6, 0.2),  # Narancs
]


func _build_puzzle() -> void:
	puzzle_type = "symbol_match"
	
	if not room:
		return
	
	total_pairs = randi_range(3, mini(5, SYMBOL_CHARS.size()))
	symbols.clear()
	matched_pairs = 0
	first_selected = -1
	second_selected = -1
	
	# Pár szimbólumok generálása (mindegyikből 2 db)
	var symbol_list: Array[int] = []
	for i in total_pairs:
		symbol_list.append(i)
		symbol_list.append(i)
	symbol_list.shuffle()
	
	# Elhelyezés grid-ben
	var tiles := room.get_tiles()
	var center := room.get_center()
	
	# Grid layout a szoba közepén
	var grid_cols: int = total_pairs
	var grid_rows: int = 2
	var start_x: int = center.x - grid_cols / 2
	var start_y: int = center.y - 1
	
	for i in symbol_list.size():
		var col: int = i % grid_cols
		var row: int = i / grid_cols
		var tile_pos := Vector2i(start_x + col, start_y + row)
		var world_pos := Vector2(tile_pos.x * Constants.TILE_SIZE, 
								tile_pos.y * Constants.TILE_SIZE)
		
		var symbol := _create_symbol_node(i, symbol_list[i], world_pos)
		symbols.append(symbol)


func _create_symbol_node(index: int, symbol_type: int, world_pos: Vector2) -> Dictionary:
	var symbol_area := Area2D.new()
	symbol_area.name = "Symbol_%d" % index
	symbol_area.global_position = world_pos
	symbol_area.collision_layer = 0
	symbol_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(28, 28)
	shape.shape = rect
	symbol_area.add_child(shape)
	
	# Háttér sprite (rejtett szimbólum)
	var bg_sprite := Sprite2D.new()
	var bg_img := Image.create(28, 28, false, Image.FORMAT_RGBA8)
	bg_img.fill(Color(0.3, 0.3, 0.4, 0.8))
	bg_sprite.texture = ImageTexture.create_from_image(bg_img)
	symbol_area.add_child(bg_sprite)
	
	# Szimbólum label (kezdetben rejtett)
	var label := Label.new()
	label.text = SYMBOL_CHARS[symbol_type]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-10, -10)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", SYMBOL_COLORS[symbol_type])
	label.visible = false  # Kezdetben rejtett
	symbol_area.add_child(label)
	
	symbol_area.body_entered.connect(
		func(body):
			if body.is_in_group("player"):
				_on_symbol_touched(index)
	)
	
	add_child(symbol_area)
	
	return {
		"index": index,
		"type": symbol_type,
		"node": symbol_area,
		"label": label,
		"bg_sprite": bg_sprite,
		"revealed": false,
		"matched": false,
	}


func _on_symbol_touched(index: int) -> void:
	if is_solved or not is_active or is_checking:
		return
	if symbols[index]["matched"] or symbols[index]["revealed"]:
		return
	
	# Szimbólum felmutatása
	symbols[index]["revealed"] = true
	symbols[index]["label"].visible = true
	symbols[index]["bg_sprite"].modulate = Color(0.5, 0.5, 0.6, 0.9)
	
	if first_selected == -1:
		first_selected = index
	elif second_selected == -1:
		second_selected = index
		is_checking = true
		# Kis késleltetés az ellenőrzés előtt
		_check_match()


func _check_match() -> void:
	await get_tree().create_timer(0.8).timeout
	
	if first_selected < 0 or second_selected < 0:
		is_checking = false
		return
	
	if symbols[first_selected]["type"] == symbols[second_selected]["type"]:
		# Pár!
		symbols[first_selected]["matched"] = true
		symbols[second_selected]["matched"] = true
		symbols[first_selected]["bg_sprite"].modulate = Color(0.2, 0.8, 0.2, 0.6)
		symbols[second_selected]["bg_sprite"].modulate = Color(0.2, 0.8, 0.2, 0.6)
		matched_pairs += 1
		
		if matched_pairs >= total_pairs:
			solve()
	else:
		# Nem pár → visszaforgatás
		symbols[first_selected]["revealed"] = false
		symbols[first_selected]["label"].visible = false
		symbols[first_selected]["bg_sprite"].modulate = Color.WHITE
		symbols[second_selected]["revealed"] = false
		symbols[second_selected]["label"].visible = false
		symbols[second_selected]["bg_sprite"].modulate = Color.WHITE
	
	first_selected = -1
	second_selected = -1
	is_checking = false


func _on_solved() -> void:
	# Összes szimbólum eltűnik → reward chest
	for symbol in symbols:
		if is_instance_valid(symbol["node"]):
			var tween := create_tween()
			tween.tween_property(symbol["node"], "modulate:a", 0.0, 0.5)
	
	if room:
		spawn_reward_chest(room.get_world_center())


func _on_reset() -> void:
	matched_pairs = 0
	first_selected = -1
	second_selected = -1
	for symbol in symbols:
		symbol["revealed"] = false
		symbol["matched"] = false
		symbol["label"].visible = false
		symbol["bg_sprite"].modulate = Color.WHITE

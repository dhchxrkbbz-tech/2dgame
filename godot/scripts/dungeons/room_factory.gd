## RoomFactory - Dungeon szobák scene/node felépítése
## DungeonRoom adatokból kész node struktúrát épít
class_name RoomFactory
extends RefCounted

var rng: RandomNumberGenerator
var tile_size: int = Constants.TILE_SIZE


func _init(p_rng: RandomNumberGenerator = null) -> void:
	rng = p_rng if p_rng else RandomNumberGenerator.new()


## Szoba node felépítés a DungeonRoom adatokból
func build_room_node(room: DungeonRoom, parent: Node2D) -> Node2D:
	var room_node := Node2D.new()
	room_node.name = "Room_%d_%s" % [room.room_index, DungeonRoom.RoomType.keys()[room.room_type]]
	room_node.position = Vector2(room.rect.position.x * tile_size, room.rect.position.y * tile_size)
	
	# Cover elemek
	_build_cover_elements(room, room_node)
	
	parent.add_child(room_node)
	return room_node


## Cover/obstacle elemek felépítése combat room-okhoz
func _build_cover_elements(room: DungeonRoom, parent: Node2D) -> void:
	for cover in room.cover_elements:
		var cover_node := _create_cover_node(cover)
		if cover_node:
			parent.add_child(cover_node)


func _create_cover_node(cover_data: Dictionary) -> StaticBody2D:
	var cover_type: String = cover_data.get("type", "pillar")
	var pos: Vector2i = cover_data.get("pos", Vector2i.ZERO)
	
	var body := StaticBody2D.new()
	body.name = "Cover_%s" % cover_type
	body.position = Vector2(pos.x * tile_size, pos.y * tile_size)
	body.collision_layer = Constants.COLLISION_LAYERS.get("wall", 1 << 2)
	body.collision_mask = 0
	
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	
	# Visual placeholder
	var sprite := Sprite2D.new()
	var img: Image
	
	match cover_type:
		"pillar":
			shape.size = Vector2(16, 16)
			img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
			img.fill(Color(0.4, 0.4, 0.45, 0.9))
		"low_wall":
			shape.size = Vector2(32, 12)
			img = Image.create(32, 12, false, Image.FORMAT_RGBA8)
			img.fill(Color(0.35, 0.35, 0.4, 0.8))
		"barrel":
			shape.size = Vector2(14, 14)
			img = Image.create(14, 14, false, Image.FORMAT_RGBA8)
			img.fill(Color(0.5, 0.35, 0.2, 0.85))
		_:
			shape.size = Vector2(16, 16)
			img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
			img.fill(Color(0.4, 0.4, 0.4, 0.9))
	
	col.shape = shape
	body.add_child(col)
	
	sprite.texture = ImageTexture.create_from_image(img)
	body.add_child(sprite)
	
	return body


## Boss room arena layout generálás
func build_boss_arena(room: DungeonRoom, layout_type: String, parent: Node2D) -> void:
	var center := room.get_center()
	var room_w: int = room.rect.size.x
	var room_h: int = room.rect.size.y
	
	match layout_type:
		"OPEN_ARENA":
			# Oszlopok a széleken
			var pillar_positions: Array[Vector2i] = [
				Vector2i(room.rect.position.x + 2, room.rect.position.y + 2),
				Vector2i(room.rect.end.x - 3, room.rect.position.y + 2),
				Vector2i(room.rect.position.x + 2, room.rect.end.y - 3),
				Vector2i(room.rect.end.x - 3, room.rect.end.y - 3),
			]
			for ppos in pillar_positions:
				var cover_data := {"type": "pillar", "pos": ppos}
				room.cover_elements.append(cover_data)
				var node := _create_cover_node(cover_data)
				if node:
					parent.add_child(node)
		
		"PILLAR_MAZE":
			# Oszlopok a közepén rács-szerűen
			for x in range(room.rect.position.x + 3, room.rect.end.x - 3, 4):
				for y in range(room.rect.position.y + 3, room.rect.end.y - 3, 4):
					var cover_data := {"type": "pillar", "pos": Vector2i(x, y)}
					room.cover_elements.append(cover_data)
					var node := _create_cover_node(cover_data)
					if node:
						parent.add_child(node)
		
		"HAZARD_ARENA":
			# Széleken alacsony falak (lava/poison határ)
			for x in range(room.rect.position.x + 1, room.rect.end.x - 1, 3):
				var wall_top := {"type": "low_wall", "pos": Vector2i(x, room.rect.position.y + 1)}
				var wall_bottom := {"type": "low_wall", "pos": Vector2i(x, room.rect.end.y - 2)}
				room.cover_elements.append(wall_top)
				room.cover_elements.append(wall_bottom)
				var n1 := _create_cover_node(wall_top)
				var n2 := _create_cover_node(wall_bottom)
				if n1: parent.add_child(n1)
				if n2: parent.add_child(n2)


## Combat room altípus felépítés
func build_combat_subtype(room: DungeonRoom, subtype: String, parent: Node2D) -> void:
	match subtype:
		"ARENA":
			# Nyílt tér, nem kell extra cover
			pass
		"CORRIDOR":
			# Hosszú, keskeny - falak a széleken
			var mid_y: int = room.rect.position.y + room.rect.size.y / 2
			for x in range(room.rect.position.x + 2, room.rect.end.x - 2, 3):
				if rng.randf() < 0.4:
					var wall := {"type": "low_wall", "pos": Vector2i(x, mid_y - 2)}
					room.cover_elements.append(wall)
					var n := _create_cover_node(wall)
					if n: parent.add_child(n)
				if rng.randf() < 0.4:
					var wall := {"type": "low_wall", "pos": Vector2i(x, mid_y + 2)}
					room.cover_elements.append(wall)
					var n := _create_cover_node(wall)
					if n: parent.add_child(n)
		"AMBUSH":
			# Barrel-ök és oszlopok mindenhol (cover az enemy-knek)
			var tiles := room.get_tiles()
			var count := rng.randi_range(4, 6)
			for i in count:
				var pos: Vector2i = tiles[rng.randi() % tiles.size()]
				var cover_type := "barrel" if rng.randf() < 0.5 else "pillar"
				var cover := {"type": cover_type, "pos": pos}
				room.cover_elements.append(cover)
				var n := _create_cover_node(cover)
				if n: parent.add_child(n)
		"HORDE":
			# Minimális cover
			pass


## Secret room bejárat vizuális hint
func build_secret_entrance(pos: Vector2i, parent: Node2D) -> Node2D:
	var hint := Sprite2D.new()
	hint.name = "SecretHint"
	hint.position = Vector2(pos.x * tile_size, pos.y * tile_size)
	var img := Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.3, 0.35, 0.15))  # Nagyon halvány repedés jelzés
	hint.texture = ImageTexture.create_from_image(img)
	parent.add_child(hint)
	return hint

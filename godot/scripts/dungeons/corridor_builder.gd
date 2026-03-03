## CorridorBuilder - Folyosó generálás és dekoráció
## BSP node-ok közötti L-alakú folyosók építése
class_name CorridorBuilder
extends RefCounted

const CORRIDOR_MIN_WIDTH: int = 2
const CORRIDOR_MAX_WIDTH: int = 3
const TORCH_INTERVAL: int = 5  # Fáklya 5 tile-onként
const CORRIDOR_TRAP_CHANCE: float = 0.10  # 10% esély csapdára tile-onként
const CORRIDOR_CHEST_CHANCE: float = 0.05  # 5% esély chest-re

var rng: RandomNumberGenerator
var tile_size: int = Constants.TILE_SIZE

## Folyosó szegmens adatok
var corridor_tiles: Array[Vector2i] = []
var corridor_wall_tiles: Array[Vector2i] = []
var torch_positions: Array[Vector2i] = []
var decoration_positions: Array[Dictionary] = []
var trap_positions: Array[Dictionary] = []
var chest_positions: Array[Dictionary] = []


func _init(p_rng: RandomNumberGenerator = null) -> void:
	rng = p_rng if p_rng else RandomNumberGenerator.new()


## Összes folyosó felépítése a BSP corridor adatokból
func build_all_corridors(corridors: Array[Dictionary], tile_data: Dictionary, 
		dungeon_width: int, dungeon_height: int) -> Dictionary:
	corridor_tiles.clear()
	corridor_wall_tiles.clear()
	torch_positions.clear()
	decoration_positions.clear()
	trap_positions.clear()
	chest_positions.clear()
	
	for corridor in corridors:
		_carve_corridor(corridor, tile_data, dungeon_width, dungeon_height)
	
	# Dekoráció generálás
	_generate_decorations()
	
	return {
		"corridor_tiles": corridor_tiles,
		"wall_tiles": corridor_wall_tiles,
		"torch_positions": torch_positions,
		"decorations": decoration_positions,
		"traps": trap_positions,
		"chests": chest_positions,
	}


## Egyedi folyosó kivésése L-alakban
func _carve_corridor(corridor: Dictionary, tile_data: Dictionary, 
		width: int, height: int) -> void:
	var start: Vector2i = corridor["start"]
	var end: Vector2i = corridor["end"]
	var cor_width: int = corridor.get("width", rng.randi_range(CORRIDOR_MIN_WIDTH, CORRIDOR_MAX_WIDTH))
	var horizontal_first: bool = corridor.get("horizontal_first", rng.randf() > 0.5)
	
	if horizontal_first:
		_carve_horizontal_segment(start.x, end.x, start.y, cor_width, tile_data, width, height)
		_carve_vertical_segment(start.y, end.y, end.x, cor_width, tile_data, width, height)
	else:
		_carve_vertical_segment(start.y, end.y, start.x, cor_width, tile_data, width, height)
		_carve_horizontal_segment(start.x, end.x, end.y, cor_width, tile_data, width, height)


## Vízszintes folyosó szegmens
func _carve_horizontal_segment(x1: int, x2: int, y: int, cor_width: int,
		tile_data: Dictionary, dw: int, dh: int) -> void:
	var min_x := mini(x1, x2)
	var max_x := maxi(x1, x2)
	var half_w := cor_width / 2
	
	for x in range(min_x, max_x + 1):
		for w in range(-half_w, half_w + 1):
			var pos := Vector2i(x, y + w)
			if _in_bounds(pos, dw, dh):
				var current: int = tile_data.get(pos, 0)
				if current == 0 or current == 2:  # EMPTY or WALL
					tile_data[pos] = 4  # CORRIDOR
					corridor_tiles.append(pos)
	
	# Falak a folyosó mentén
	for x in range(min_x - 1, max_x + 2):
		for w in range(-half_w - 1, half_w + 2):
			var pos := Vector2i(x, y + w)
			if _in_bounds(pos, dw, dh):
				if tile_data.get(pos, 0) == 0:  # EMPTY
					tile_data[pos] = 2  # WALL
					corridor_wall_tiles.append(pos)


## Függőleges folyosó szegmens
func _carve_vertical_segment(y1: int, y2: int, x: int, cor_width: int,
		tile_data: Dictionary, dw: int, dh: int) -> void:
	var min_y := mini(y1, y2)
	var max_y := maxi(y1, y2)
	var half_w := cor_width / 2
	
	for y in range(min_y, max_y + 1):
		for w in range(-half_w, half_w + 1):
			var pos := Vector2i(x + w, y)
			if _in_bounds(pos, dw, dh):
				var current: int = tile_data.get(pos, 0)
				if current == 0 or current == 2:
					tile_data[pos] = 4
					corridor_tiles.append(pos)
	
	for y in range(min_y - 1, max_y + 2):
		for w in range(-half_w - 1, half_w + 2):
			var pos := Vector2i(x + w, y)
			if _in_bounds(pos, dw, dh):
				if tile_data.get(pos, 0) == 0:
					tile_data[pos] = 2
					corridor_wall_tiles.append(pos)


## Dekoráció generálás a folyosók mentén
func _generate_decorations() -> void:
	var tile_count := 0
	
	for pos in corridor_tiles:
		tile_count += 1
		
		# Fáklya minden TORCH_INTERVAL tile-onként
		if tile_count % TORCH_INTERVAL == 0:
			torch_positions.append(pos)
		
		# Random padló dekoráció
		if rng.randf() < 0.08:
			var dekor_types := ["bones", "rocks", "crack", "moss", "rubble"]
			decoration_positions.append({
				"pos": pos,
				"type": dekor_types[rng.randi() % dekor_types.size()],
			})
		
		# Csapdák a folyosón
		if rng.randf() < CORRIDOR_TRAP_CHANCE:
			var trap_types := ["spike", "arrow", "poison_gas"]
			trap_positions.append({
				"pos": pos,
				"type": trap_types[rng.randi() % trap_types.size()],
			})
		
		# Ritka chest
		if rng.randf() < CORRIDOR_CHEST_CHANCE:
			chest_positions.append({
				"pos": pos,
				"rarity": Enums.Rarity.COMMON,
			})


func _in_bounds(pos: Vector2i, width: int, height: int) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height


## Ajtó pozíciók keresése a szoba és folyosó találkozásánál
func find_door_positions(rooms: Array, corridors_data: Array[Dictionary]) -> Array[Dictionary]:
	var doors: Array[Dictionary] = []
	
	for corridor in corridors_data:
		var start: Vector2i = corridor["start"]
		var end: Vector2i = corridor["end"]
		
		# Start pont szobájának szélén ajtó
		var start_room := _find_room_containing(start, rooms)
		var end_room := _find_room_containing(end, rooms)
		
		if start_room != null and end_room != null:
			var door_start := _find_edge_point(start_room, start, end)
			var door_end := _find_edge_point(end_room, end, start)
			
			if door_start != Vector2i(-1, -1):
				doors.append({
					"pos": door_start,
					"room_a": start_room.room_index,
					"room_b": end_room.room_index,
					"type": _determine_door_type(end_room),
				})
			
			if door_end != Vector2i(-1, -1):
				doors.append({
					"pos": door_end,
					"room_a": end_room.room_index,
					"room_b": start_room.room_index,
					"type": "normal",
				})
	
	return doors


func _find_room_containing(pos: Vector2i, rooms: Array) -> DungeonRoom:
	for room in rooms:
		if room is DungeonRoom and room.contains_tile(pos):
			return room
	return null


func _find_edge_point(room: DungeonRoom, from: Vector2i, toward: Vector2i) -> Vector2i:
	var dir := Vector2i(signi(toward.x - from.x), signi(toward.y - from.y))
	var check := from
	for i in 30:
		check = check + dir
		if not room.contains_tile(check):
			return check - dir
	return Vector2i(-1, -1)


func _determine_door_type(target_room: DungeonRoom) -> String:
	match target_room.room_type:
		DungeonRoom.RoomType.BOSS:
			return "boss"
		DungeonRoom.RoomType.SECRET:
			return "hidden"
		DungeonRoom.RoomType.COMBAT:
			return "combat"
		_:
			return "normal"

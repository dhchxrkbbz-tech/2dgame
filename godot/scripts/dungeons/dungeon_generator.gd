## DungeonGenerator - Teljes dungeon generáló rendszer
## BSP alapú szoba elrendezés, folyosók, ajtók, tartalom
class_name DungeonGenerator
extends Node

signal dungeon_generated(dungeon_data: Dictionary)
signal room_cleared_signal(room_index: int)

# === Dungeon tiers ===
const TIER_CONFIG: Dictionary = {
	1: {"rooms": Vector2i(8, 10), "floors": 1, "has_boss": true, "boss_tier": 1},
	2: {"rooms": Vector2i(12, 16), "floors": 1, "has_boss": true, "boss_tier": 2},
	3: {"rooms": Vector2i(16, 20), "floors": 2, "has_boss": true, "boss_tier": 2},
	4: {"rooms": Vector2i(20, 25), "floors": 3, "has_boss": true, "boss_tier": 4},
}

# === Generált adat ===
var rooms: Array[DungeonRoom] = []
var corridors: Array[Dictionary] = []
var tile_data: Dictionary = {}  # Vector2i -> tile_type
var dungeon_seed: int = 0
var dungeon_tier: int = 1
var biome: Enums.BiomeType = Enums.BiomeType.CURSED_FOREST
var dungeon_difficulty: int = 1
var current_room_index: int = 0

# Tile típusok
enum TileType { EMPTY, FLOOR, WALL, DOOR, CORRIDOR, TRAP, WATER, LAVA }

# Dungeon méretek
const DUNGEON_WIDTH: int = 80
const DUNGEON_HEIGHT: int = 60

var rng: RandomNumberGenerator
var bsp: BSPGenerator

# TileMap referencia
var tile_map: TileMapLayer = null

# Aktív dungeon állapot
var is_active: bool = false
var player_current_room: int = -1


func generate_dungeon(seed_value: int, tier: int, p_biome: Enums.BiomeType) -> Dictionary:
	dungeon_seed = seed_value
	dungeon_tier = tier
	biome = p_biome
	dungeon_difficulty = _calculate_difficulty()
	
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value
	bsp = BSPGenerator.new(seed_value)
	
	rooms.clear()
	corridors.clear()
	tile_data.clear()
	
	var config: Dictionary = TIER_CONFIG.get(tier, TIER_CONFIG[1])
	var room_count: int = rng.randi_range(config["rooms"].x, config["rooms"].y)
	
	# 1. BSP generálás
	var area := Rect2i(0, 0, DUNGEON_WIDTH, DUNGEON_HEIGHT)
	var root_node := bsp.generate(area, room_count)
	
	# 2. Szobák kinyerése
	var bsp_rooms := root_node.get_all_rooms()
	
	# 3. Szoba típus hozzárendelés
	for i in bsp_rooms.size():
		var room := DungeonRoom.new()
		room.rect = bsp_rooms[i]
		room.room_index = i
		room.room_type = DungeonRoom.assign_room_type(rng, i, bsp_rooms.size(), config["has_boss"])
		room.room_shape = DungeonRoom.assign_room_shape(rng) if room.room_type != DungeonRoom.RoomType.BOSS else DungeonRoom.RoomShape.RECTANGLE
		rooms.append(room)
	
	# 4. Folyosók generálása
	corridors = bsp.generate_corridors(root_node)
	
	# 5. Tile data felépítés
	_build_tile_data()
	
	# 6. Szobák tartalmának generálása
	for room in rooms:
		_populate_room(room)
	
	# 7. Ajtók elhelyezése
	_place_doors()
	
	is_active = true
	
	var result := {
		"seed": dungeon_seed,
		"tier": dungeon_tier,
		"biome": biome,
		"difficulty": dungeon_difficulty,
		"rooms": rooms,
		"corridors": corridors,
		"tile_data": tile_data,
		"width": DUNGEON_WIDTH,
		"height": DUNGEON_HEIGHT,
	}
	
	dungeon_generated.emit(result)
	return result


func _calculate_difficulty() -> int:
	var base: int
	match biome:
		Enums.BiomeType.STARTING_MEADOW: base = 1
		Enums.BiomeType.CURSED_FOREST: base = 3
		Enums.BiomeType.DARK_SWAMP: base = 4
		Enums.BiomeType.RUINS: base = 5
		Enums.BiomeType.MOUNTAINS: base = 6
		Enums.BiomeType.FROZEN_WASTES: base = 7
		Enums.BiomeType.ASHLANDS: base = 8
		Enums.BiomeType.PLAGUE_LANDS: base = 9
		_: base = 1
	return mini(base + dungeon_tier - 1, 10)


func _build_tile_data() -> void:
	# Alap: minden EMPTY
	for x in DUNGEON_WIDTH:
		for y in DUNGEON_HEIGHT:
			tile_data[Vector2i(x, y)] = TileType.EMPTY
	
	# Szoba tile-ok
	for room in rooms:
		var tiles := room.get_tiles()
		for tile in tiles:
			tile_data[tile] = TileType.FLOOR
		
		# Falak a szoba körül
		_add_walls_around(room.rect)
	
	# Folyosó tile-ok
	for corridor in corridors:
		_carve_corridor(corridor)


func _add_walls_around(rect: Rect2i) -> void:
	for x in range(rect.position.x - 1, rect.end.x + 1):
		for y in range(rect.position.y - 1, rect.end.y + 1):
			var pos := Vector2i(x, y)
			if pos.x < 0 or pos.y < 0 or pos.x >= DUNGEON_WIDTH or pos.y >= DUNGEON_HEIGHT:
				continue
			if tile_data.get(pos, TileType.EMPTY) == TileType.EMPTY:
				tile_data[pos] = TileType.WALL


func _carve_corridor(corridor: Dictionary) -> void:
	var start: Vector2i = corridor["start"]
	var end: Vector2i = corridor["end"]
	var width: int = corridor["width"]
	var horizontal_first: bool = corridor["horizontal_first"]
	
	if horizontal_first:
		_carve_horizontal(start.x, end.x, start.y, width)
		_carve_vertical(start.y, end.y, end.x, width)
	else:
		_carve_vertical(start.y, end.y, start.x, width)
		_carve_horizontal(start.x, end.x, end.y, width)


func _carve_horizontal(x1: int, x2: int, y: int, width: int) -> void:
	var min_x := mini(x1, x2)
	var max_x := maxi(x1, x2)
	for x in range(min_x, max_x + 1):
		for w in range(-width / 2, width / 2 + 1):
			var pos := Vector2i(x, y + w)
			if pos.x >= 0 and pos.x < DUNGEON_WIDTH and pos.y >= 0 and pos.y < DUNGEON_HEIGHT:
				if tile_data[pos] == TileType.EMPTY or tile_data[pos] == TileType.WALL:
					tile_data[pos] = TileType.CORRIDOR
	
	# Falak a folyosó mentén
	for x in range(min_x - 1, max_x + 2):
		for w in range(-width / 2 - 1, width / 2 + 2):
			var pos := Vector2i(x, y + w)
			if pos.x >= 0 and pos.x < DUNGEON_WIDTH and pos.y >= 0 and pos.y < DUNGEON_HEIGHT:
				if tile_data[pos] == TileType.EMPTY:
					tile_data[pos] = TileType.WALL


func _carve_vertical(y1: int, y2: int, x: int, width: int) -> void:
	var min_y := mini(y1, y2)
	var max_y := maxi(y1, y2)
	for y in range(min_y, max_y + 1):
		for w in range(-width / 2, width / 2 + 1):
			var pos := Vector2i(x + w, y)
			if pos.x >= 0 and pos.x < DUNGEON_WIDTH and pos.y >= 0 and pos.y < DUNGEON_HEIGHT:
				if tile_data[pos] == TileType.EMPTY or tile_data[pos] == TileType.WALL:
					tile_data[pos] = TileType.CORRIDOR
	
	for y in range(min_y - 1, max_y + 2):
		for w in range(-width / 2 - 1, width / 2 + 2):
			var pos := Vector2i(x + w, y)
			if pos.x >= 0 and pos.x < DUNGEON_WIDTH and pos.y >= 0 and pos.y < DUNGEON_HEIGHT:
				if tile_data[pos] == TileType.EMPTY:
					tile_data[pos] = TileType.WALL


func _populate_room(room: DungeonRoom) -> void:
	match room.room_type:
		DungeonRoom.RoomType.COMBAT:
			_populate_combat_room(room)
		DungeonRoom.RoomType.TREASURE:
			_populate_treasure_room(room)
		DungeonRoom.RoomType.PUZZLE:
			_populate_puzzle_room(room)
		DungeonRoom.RoomType.TRAP:
			_populate_trap_room(room)
		DungeonRoom.RoomType.SAFE:
			_populate_safe_room(room)
		DungeonRoom.RoomType.BOSS:
			_populate_boss_room(room)
		DungeonRoom.RoomType.ENTRANCE:
			room.is_discovered = true
			room.is_cleared = true


func _populate_combat_room(room: DungeonRoom) -> void:
	# Ellenségek száma nehézség alapján
	var enemy_count: int
	if dungeon_difficulty <= 3:
		enemy_count = rng.randi_range(3, 4)
	elif dungeon_difficulty <= 6:
		enemy_count = rng.randi_range(4, 5)
	elif dungeon_difficulty <= 8:
		enemy_count = rng.randi_range(6, 7)
	else:
		enemy_count = 8
	
	# Wave szám
	if dungeon_difficulty <= 3:
		room.total_waves = 1
	elif dungeon_difficulty <= 6:
		room.total_waves = 2
	elif dungeon_difficulty <= 8:
		room.total_waves = rng.randi_range(2, 3)
	else:
		room.total_waves = 3
	
	var tiles := room.get_tiles()
	var center := room.get_center()
	
	for i in enemy_count:
		# Random pozíció a szobán belül (center-től távol)
		var pos: Vector2i
		var attempts := 0
		while attempts < 10:
			pos = tiles[rng.randi() % tiles.size()]
			if pos.distance_to(center) > 2:
				break
			attempts += 1
		
		var is_elite := rng.randf() < 0.15  # 15% elite esély dungeon-ben
		if room.total_waves == 3 and i == enemy_count - 1:
			is_elite = true  # Utolsó wave utolsó enemy mindig elite
		
		room.enemies.append({
			"pos": pos,
			"level": _get_enemy_level(),
			"is_elite": is_elite,
			"wave": i % room.total_waves,
		})
	
	# Cover elements
	var cover_count := rng.randi_range(1, 3)
	for i in cover_count:
		var pos: Vector2i = tiles[rng.randi() % tiles.size()]
		var cover_type := ["pillar", "low_wall", "barrel"][rng.randi_range(0, 2)]
		room.cover_elements.append({"type": cover_type, "pos": pos})


func _populate_treasure_room(room: DungeonRoom) -> void:
	var center := room.get_center()
	
	# Fő chest (jobb rarity)
	room.chests.append({
		"pos": center,
		"rarity": _get_chest_rarity(true),
		"is_mimic": rng.randf() < 0.2,  # 20% mimic
	})
	
	# Side chests
	var side_count := rng.randi_range(0, 2)
	var tiles := room.get_tiles()
	for i in side_count:
		var pos: Vector2i = tiles[rng.randi() % tiles.size()]
		room.chests.append({
			"pos": pos,
			"rarity": _get_chest_rarity(false),
			"is_mimic": false,
		})
	
	# Csapdák a bejáratnál
	if rng.randf() < 0.5:
		var trap_count := rng.randi_range(2, 3)
		for i in trap_count:
			var pos: Vector2i = tiles[rng.randi() % tiles.size()]
			room.traps.append({
				"type": _random_trap_type(),
				"pos": pos,
			})


func _populate_puzzle_room(room: DungeonRoom) -> void:
	var puzzle_types := ["switch_order", "pressure_plate", "light_beam", "symbol_match", "timed"]
	room.puzzle_data = {
		"type": puzzle_types[rng.randi() % puzzle_types.size()],
		"solved": false,
		"elements": [],
	}
	
	var tiles := room.get_tiles()
	var center := room.get_center()
	
	match room.puzzle_data["type"]:
		"switch_order":
			var switch_count := rng.randi_range(3, 5)
			for i in switch_count:
				var pos: Vector2i = tiles[rng.randi() % tiles.size()]
				room.puzzle_data["elements"].append({
					"pos": pos, "order": i, "activated": false,
				})
		
		"pressure_plate":
			var plate_count := rng.randi_range(2, 4)
			for i in plate_count:
				var pos: Vector2i = tiles[rng.randi() % tiles.size()]
				room.puzzle_data["elements"].append({
					"pos": pos, "pressed": false,
				})
		
		"timed":
			room.puzzle_data["time_limit"] = 20.0
			room.puzzle_data["elements"].append({
				"pos": center, "type": "start_switch",
			})


func _populate_trap_room(room: DungeonRoom) -> void:
	var tiles := room.get_tiles()
	var trap_count := rng.randi_range(4, 8)
	
	for i in trap_count:
		var pos: Vector2i = tiles[rng.randi() % tiles.size()]
		room.traps.append({
			"type": _random_trap_type(),
			"pos": pos,
		})


func _populate_safe_room(room: DungeonRoom) -> void:
	room.is_cleared = true
	# Heal fountain a közepén
	var center := room.get_center()
	room.chests.append({
		"pos": center,
		"type": "heal_fountain",
		"used": false,
	})


func _populate_boss_room(room: DungeonRoom) -> void:
	room.is_locked = true
	room.loot_multiplier = 3.0
	room.enemies.append({
		"pos": room.get_center(),
		"level": _get_enemy_level() + 5,
		"is_boss": true,
		"boss_tier": TIER_CONFIG.get(dungeon_tier, {}).get("boss_tier", 1),
	})


func _place_doors() -> void:
	# Ajtók a szobák és folyosók találkozásánál
	for corridor in corridors:
		var start: Vector2i = corridor["start"]
		var end: Vector2i = corridor["end"]
		
		# Start room-ban ajtó
		var start_room := _find_room_at(start)
		var end_room := _find_room_at(end)
		
		if start_room and end_room:
			# Ajtó pozíciója: a szoba szélén a folyosó irányába
			var door_pos_start := _find_door_position(start_room, start, end)
			var door_pos_end := _find_door_position(end_room, end, start)
			
			if door_pos_start != Vector2i(-1, -1):
				var door_type := "normal"
				if end_room.room_type == DungeonRoom.RoomType.BOSS:
					door_type = "boss"
				elif end_room.room_type == DungeonRoom.RoomType.SECRET:
					door_type = "hidden"
				
				tile_data[door_pos_start] = TileType.DOOR
				start_room.doors.append({
					"pos": door_pos_start,
					"door_type": door_type,
					"connected_room": end_room.room_index,
					"is_open": door_type == "normal",
				})
			
			if door_pos_end != Vector2i(-1, -1):
				tile_data[door_pos_end] = TileType.DOOR
				end_room.doors.append({
					"pos": door_pos_end,
					"door_type": "normal",
					"connected_room": start_room.room_index,
					"is_open": true,
				})


func _find_room_at(pos: Vector2i) -> DungeonRoom:
	for room in rooms:
		if room.contains_tile(pos):
			return room
	return null


func _find_door_position(room: DungeonRoom, from: Vector2i, to: Vector2i) -> Vector2i:
	var dir := Vector2i(signi(to.x - from.x), signi(to.y - from.y))
	# A szoba szélén keresünk ajtó pozíciót
	var test_pos := from
	for i in 20:
		test_pos = test_pos + dir
		if not room.contains_tile(test_pos):
			return test_pos - dir
	return Vector2i(-1, -1)


func _get_enemy_level() -> int:
	var level_range := EnemyDatabase._get_biome_level_range(biome)
	return rng.randi_range(level_range.x, level_range.y) + dungeon_tier


func _get_chest_rarity(is_main: bool) -> int:
	if is_main:
		var roll := rng.randf()
		if dungeon_difficulty <= 3:
			return Enums.Rarity.UNCOMMON if roll < 0.6 else Enums.Rarity.RARE
		elif dungeon_difficulty <= 6:
			return Enums.Rarity.RARE if roll < 0.6 else Enums.Rarity.EPIC
		else:
			return Enums.Rarity.EPIC if roll < 0.7 else Enums.Rarity.LEGENDARY
	else:
		return Enums.Rarity.COMMON if rng.randf() < 0.5 else Enums.Rarity.UNCOMMON


func _random_trap_type() -> String:
	var types := ["spike", "poison_gas", "fire_jet", "arrow", "falling_rocks", "pit", "curse_totem"]
	return types[rng.randi() % types.size()]


# === Runtime funkciók ===

func enter_room(room_index: int) -> void:
	if room_index < 0 or room_index >= rooms.size():
		return
	
	var room := rooms[room_index]
	room.is_discovered = true
	player_current_room = room_index
	
	# Combat room: seal doors
	if room.room_type == DungeonRoom.RoomType.COMBAT and not room.is_cleared:
		room.is_sealed = true
		EventBus.dungeon_entered.emit({"room_index": room_index, "room_type": "combat"})


func clear_room(room_index: int) -> void:
	if room_index < 0 or room_index >= rooms.size():
		return
	
	var room := rooms[room_index]
	room.is_cleared = true
	room.is_sealed = false
	
	EventBus.room_cleared.emit(room_index)
	room_cleared_signal.emit(room_index)


func render_to_tilemap(p_tile_map: TileMapLayer) -> void:
	tile_map = p_tile_map
	
	for pos in tile_data:
		var tile_type: int = tile_data[pos]
		var atlas_coords := Vector2i(0, 0)
		
		match tile_type:
			TileType.FLOOR:
				atlas_coords = Vector2i(_biome_to_atlas(), 0)
			TileType.WALL:
				atlas_coords = Vector2i(_biome_to_atlas(), 6)
			TileType.CORRIDOR:
				atlas_coords = Vector2i(_biome_to_atlas(), 1)
			TileType.DOOR:
				atlas_coords = Vector2i(_biome_to_atlas(), 3)
			TileType.TRAP:
				atlas_coords = Vector2i(_biome_to_atlas(), 0)  # Csapda tile is padló
		
		if tile_type != TileType.EMPTY:
			tile_map.set_cell(pos, 0, atlas_coords)


func _biome_to_atlas() -> int:
	match biome:
		Enums.BiomeType.CURSED_FOREST: return 1
		Enums.BiomeType.DARK_SWAMP: return 2
		Enums.BiomeType.RUINS: return 3
		Enums.BiomeType.MOUNTAINS: return 4
		Enums.BiomeType.FROZEN_WASTES: return 5
		Enums.BiomeType.ASHLANDS: return 6
		Enums.BiomeType.PLAGUE_LANDS: return 7
		_: return 0

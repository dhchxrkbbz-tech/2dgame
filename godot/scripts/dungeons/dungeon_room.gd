## DungeonRoom - Szoba adatok és típusok
## Tartalmazza a szoba geometriáját, típusát, és tartalmát
class_name DungeonRoom
extends RefCounted

enum RoomType {
	COMBAT,
	TREASURE,
	PUZZLE,
	TRAP,
	SAFE,
	BOSS,
	SECRET,
	ENTRANCE,
}

enum RoomShape {
	RECTANGLE,
	L_SHAPE,
	CROSS,
	CIRCULAR,
}

# Szoba geometria
var rect: Rect2i
var room_type: RoomType = RoomType.COMBAT
var room_shape: RoomShape = RoomShape.RECTANGLE
var room_index: int = 0

# Tartalom
var enemies: Array[Dictionary] = []  # [{type, level, pos}]
var traps: Array[Dictionary] = []     # [{trap_type, pos}]
var chests: Array[Dictionary] = []    # [{rarity, pos, is_mimic}]
var puzzle_data: Dictionary = {}
var cover_elements: Array[Dictionary] = []  # [{type, pos}]

# Ajtók
var doors: Array[Dictionary] = []  # [{pos, direction, door_type, connected_room}]

# Állapot
var is_cleared: bool = false
var is_discovered: bool = false
var is_locked: bool = false
var is_sealed: bool = false  # Boss fight közben

# Wave rendszer
var total_waves: int = 1
var current_wave: int = 0
var wave_enemies: Array[Array] = []  # [[enemy_indices per wave]]

# Loot
var loot_multiplier: float = 1.0


func get_center() -> Vector2i:
	return Vector2i(
		rect.position.x + rect.size.x / 2,
		rect.position.y + rect.size.y / 2
	)


func get_world_center() -> Vector2:
	var c := get_center()
	return Vector2(c.x * Constants.TILE_SIZE, c.y * Constants.TILE_SIZE)


func get_tiles() -> Array[Vector2i]:
	## Visszaadja az összes tile pozíciót ami a szobához tartozik
	var tiles: Array[Vector2i] = []
	
	match room_shape:
		RoomShape.RECTANGLE:
			for x in range(rect.position.x, rect.end.x):
				for y in range(rect.position.y, rect.end.y):
					tiles.append(Vector2i(x, y))
		
		RoomShape.L_SHAPE:
			# L-alak: felső rész teljes + alsó bal fél
			var mid_x := rect.position.x + rect.size.x / 2
			var mid_y := rect.position.y + rect.size.y / 2
			for x in range(rect.position.x, rect.end.x):
				for y in range(rect.position.y, mid_y):
					tiles.append(Vector2i(x, y))
			for x in range(rect.position.x, mid_x):
				for y in range(mid_y, rect.end.y):
					tiles.append(Vector2i(x, y))
		
		RoomShape.CROSS:
			# Kereszt: középső sáv vízszintesen + középső sáv függőlegesen
			var cx := rect.position.x + rect.size.x / 2
			var cy := rect.position.y + rect.size.y / 2
			var arm_w := rect.size.x / 4
			var arm_h := rect.size.y / 4
			for x in range(rect.position.x, rect.end.x):
				for y in range(cy - arm_h, cy + arm_h):
					tiles.append(Vector2i(x, y))
			for x in range(cx - arm_w, cx + arm_w):
				for y in range(rect.position.y, rect.end.y):
					if Vector2i(x, y) not in tiles:
						tiles.append(Vector2i(x, y))
		
		RoomShape.CIRCULAR:
			var cx := float(rect.position.x + rect.size.x / 2)
			var cy := float(rect.position.y + rect.size.y / 2)
			var rx := float(rect.size.x) / 2.0
			var ry := float(rect.size.y) / 2.0
			for x in range(rect.position.x, rect.end.x):
				for y in range(rect.position.y, rect.end.y):
					var dx := (float(x) - cx) / rx
					var dy := (float(y) - cy) / ry
					if dx * dx + dy * dy <= 1.0:
						tiles.append(Vector2i(x, y))
	
	return tiles


func contains_tile(tile: Vector2i) -> bool:
	return rect.has_point(tile)


static func assign_room_type(rng: RandomNumberGenerator, index: int, total_rooms: int, has_boss: bool) -> RoomType:
	## Szoba típus hozzárendelés szabályok alapján
	# Első szoba mindig entrance
	if index == 0:
		return RoomType.ENTRANCE
	
	# Utolsó szoba boss-nál boss szoba
	if index == total_rooms - 1 and has_boss:
		return RoomType.BOSS
	
	# Többi random rátio alapján
	var roll := rng.randf()
	if roll < 0.55:
		return RoomType.COMBAT
	elif roll < 0.67:
		return RoomType.TREASURE
	elif roll < 0.79:
		return RoomType.PUZZLE
	elif roll < 0.89:
		return RoomType.TRAP
	elif roll < 0.94:
		return RoomType.SAFE
	else:
		return RoomType.SECRET


static func assign_room_shape(rng: RandomNumberGenerator) -> RoomShape:
	var roll := rng.randf()
	if roll < 0.30:
		return RoomShape.RECTANGLE
	elif roll < 0.55:
		return RoomShape.L_SHAPE
	elif roll < 0.70:
		return RoomShape.CROSS
	else:
		return RoomShape.CIRCULAR

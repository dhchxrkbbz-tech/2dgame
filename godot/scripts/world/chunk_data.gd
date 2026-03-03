## ChunkData - Egy chunk adatstruktúrája
## 16x16 tile méretű chunk minden információja
class_name ChunkData
extends RefCounted

var chunk_pos: Vector2i = Vector2i.ZERO  # Chunk koordináta (világ koordinátában)
var tiles: Array = []  # 16x16 tile biome ID-k
var biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW  # Domináns biome
var decorations: Array[Dictionary] = []  # {type, pos, variant}
var enemies: Array[Dictionary] = []  # {type, pos, level}
var pois: Array[Dictionary] = []  # {type, pos, data}
var modified: bool = false  # Módosítva lett-e a generálás óta
var generated: bool = false  # Le lett-e generálva

# Tile biome map - gyors kereséshez
var tile_biomes: Array = []  # 16x16 biome type per tile

# Collision adatok
var walkable: Array = []  # 16x16 bool (járható-e)


func _init(pos: Vector2i = Vector2i.ZERO) -> void:
	chunk_pos = pos
	_init_arrays()


func _init_arrays() -> void:
	tiles.resize(Constants.CHUNK_SIZE)
	tile_biomes.resize(Constants.CHUNK_SIZE)
	walkable.resize(Constants.CHUNK_SIZE)

	for x in Constants.CHUNK_SIZE:
		tiles[x] = []
		tiles[x].resize(Constants.CHUNK_SIZE)
		tile_biomes[x] = []
		tile_biomes[x].resize(Constants.CHUNK_SIZE)
		walkable[x] = []
		walkable[x].resize(Constants.CHUNK_SIZE)

		for y in Constants.CHUNK_SIZE:
			tiles[x][y] = 0
			tile_biomes[x][y] = Enums.BiomeType.STARTING_MEADOW
			walkable[x][y] = true


## Tile beállítása chunk-lokális koordinátákon
func set_tile(local_x: int, local_y: int, tile_id: int) -> void:
	if _is_valid_local(local_x, local_y):
		tiles[local_x][local_y] = tile_id
		modified = true


## Tile lekérdezése
func get_tile(local_x: int, local_y: int) -> int:
	if _is_valid_local(local_x, local_y):
		return tiles[local_x][local_y]
	return -1


## Biome beállítása tile-ra
func set_tile_biome(local_x: int, local_y: int, biome_type: Enums.BiomeType) -> void:
	if _is_valid_local(local_x, local_y):
		tile_biomes[local_x][local_y] = biome_type


## Biome lekérdezése tile-ról
func get_tile_biome(local_x: int, local_y: int) -> Enums.BiomeType:
	if _is_valid_local(local_x, local_y):
		return tile_biomes[local_x][local_y]
	return Enums.BiomeType.STARTING_MEADOW


## Járhatóság beállítása
func set_walkable(local_x: int, local_y: int, is_walkable: bool) -> void:
	if _is_valid_local(local_x, local_y):
		walkable[local_x][local_y] = is_walkable


## Járhatóság lekérdezése
func is_walkable(local_x: int, local_y: int) -> bool:
	if _is_valid_local(local_x, local_y):
		return walkable[local_x][local_y]
	return false


## Lokális koordináta érvényességének ellenőrzése
func _is_valid_local(x: int, y: int) -> bool:
	return x >= 0 and x < Constants.CHUNK_SIZE and y >= 0 and y < Constants.CHUNK_SIZE


## Chunk-lokális koordináta → világ tile koordináta
func local_to_world(local_x: int, local_y: int) -> Vector2i:
	return Vector2i(
		chunk_pos.x * Constants.CHUNK_SIZE + local_x,
		chunk_pos.y * Constants.CHUNK_SIZE + local_y
	)


## Világ tile koordináta → chunk-lokális koordináta
static func world_to_local(world_x: int, world_y: int) -> Vector2i:
	var local_x: int = world_x % Constants.CHUNK_SIZE
	var local_y: int = world_y % Constants.CHUNK_SIZE
	if local_x < 0:
		local_x += Constants.CHUNK_SIZE
	if local_y < 0:
		local_y += Constants.CHUNK_SIZE
	return Vector2i(local_x, local_y)


## Domináns biome kiszámítása a tile biome-ok alapján
func calculate_dominant_biome() -> void:
	var biome_count: Dictionary = {}

	for x in Constants.CHUNK_SIZE:
		for y in Constants.CHUNK_SIZE:
			var b: Enums.BiomeType = tile_biomes[x][y]
			if b in biome_count:
				biome_count[b] += 1
			else:
				biome_count[b] = 1

	var max_count: int = 0
	for b in biome_count:
		if biome_count[b] > max_count:
			max_count = biome_count[b]
			biome = b


## Dekoráció hozzáadása
func add_decoration(local_pos: Vector2i, type: String, variant: int = 0) -> void:
	decorations.append({
		"pos": local_pos,
		"type": type,
		"variant": variant,
	})
	modified = true


## Enemy spawn adat hozzáadása
func add_enemy_spawn(local_pos: Vector2i, enemy_type: Enums.EnemyType, level: int) -> void:
	enemies.append({
		"pos": local_pos,
		"type": enemy_type,
		"level": level,
	})


## POI hozzáadása
func add_poi(local_pos: Vector2i, poi_type: String, poi_data: Dictionary = {}) -> void:
	pois.append({
		"pos": local_pos,
		"type": poi_type,
		"data": poi_data,
	})


## Szerializálás mentéshez
func serialize() -> Dictionary:
	return {
		"chunk_pos": {"x": chunk_pos.x, "y": chunk_pos.y},
		"biome": biome,
		"tiles": tiles,
		"tile_biomes": tile_biomes,
		"walkable": walkable,
		"decorations": decorations,
		"enemies": enemies,
		"pois": pois,
		"modified": modified,
		"generated": generated,
	}


## Deszerializálás betöltéshez
static func deserialize(data: Dictionary) -> ChunkData:
	var chunk := ChunkData.new(
		Vector2i(data["chunk_pos"]["x"], data["chunk_pos"]["y"])
	)
	chunk.biome = data.get("biome", Enums.BiomeType.STARTING_MEADOW)
	chunk.tiles = data.get("tiles", [])
	chunk.tile_biomes = data.get("tile_biomes", [])
	chunk.walkable = data.get("walkable", [])
	chunk.decorations = data.get("decorations", [])
	chunk.enemies = data.get("enemies", [])
	chunk.pois = data.get("pois", [])
	chunk.modified = data.get("modified", false)
	chunk.generated = data.get("generated", false)
	return chunk

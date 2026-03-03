## ChunkManager - Chunk lifecycle kezelés
## Betöltés, generálás, cache-elés, unload
class_name ChunkManager
extends Node

signal chunk_ready(chunk_pos: Vector2i)

# Betöltött chunk-ok cache-e
var loaded_chunks: Dictionary = {}  # Vector2i -> ChunkData

# Referenciák
var noise_manager: NoiseManager
var biome_resolver: BiomeResolver

# Betöltési sugarak (chunk-okban)
const LOAD_RADIUS: int = 3  # Megjelenítés: 3x3 + buffer
const SIMULATION_RADIUS: int = 5  # Szimulálás: 5x5
const UNLOAD_RADIUS: int = 7  # Ezen túl unload

# Utolsó ismert chunk pozíció
var last_player_chunk: Vector2i = Vector2i(999999, 999999)

# Generálási queue (háttér generálás)
var generation_queue: Array[Vector2i] = []
var is_generating: bool = false
var max_chunks_per_frame: int = 2  # Max ennyi chunk generálás frame-enként

# Cache fájl útvonal
const CHUNK_CACHE_DIR: String = "user://chunk_cache/"

# World seed
var world_seed: int = 0

# RNG a dekoráció/enemy generáláshoz
var rng: RandomNumberGenerator


func initialize(
	p_noise_manager: NoiseManager,
	p_biome_resolver: BiomeResolver,
	seed_value: int
) -> void:
	noise_manager = p_noise_manager
	biome_resolver = p_biome_resolver
	world_seed = seed_value
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value


## Játékos pozíciójából chunk koordináta
static func world_pos_to_chunk(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		floori(world_pos.x / Constants.CHUNK_PIXEL_SIZE),
		floori(world_pos.y / Constants.CHUNK_PIXEL_SIZE)
	)


## Tile világ koordináta → chunk koordináta
static func tile_to_chunk(tile_pos: Vector2i) -> Vector2i:
	return Vector2i(
		floori(float(tile_pos.x) / Constants.CHUNK_SIZE),
		floori(float(tile_pos.y) / Constants.CHUNK_SIZE)
	)


## Frame-enkénti frissítés
func update_chunks(player_world_pos: Vector2) -> void:
	var current_chunk: Vector2i = world_pos_to_chunk(player_world_pos)

	if current_chunk != last_player_chunk:
		last_player_chunk = current_chunk
		_update_loaded_chunks(current_chunk)

	# Generálási queue feldolgozása
	_process_generation_queue()


## Chunkok frissítése a játékos aktuális pozíciója körül
func _update_loaded_chunks(center: Vector2i) -> void:
	var needed: Array[Vector2i] = _get_chunks_in_radius(center, LOAD_RADIUS)

	# Betöltés / generálás
	for chunk_pos in needed:
		if chunk_pos not in loaded_chunks:
			if chunk_pos not in generation_queue:
				generation_queue.append(chunk_pos)

	# Kidobás (UNLOAD_RADIUS-on túl)
	var to_unload: Array[Vector2i] = []
	for chunk_pos_key in loaded_chunks:
		var chunk_pos: Vector2i = chunk_pos_key as Vector2i
		var dist: int = maxi(absi(chunk_pos.x - center.x), absi(chunk_pos.y - center.y))
		if dist > UNLOAD_RADIUS:
			to_unload.append(chunk_pos)

	for chunk_pos in to_unload:
		_unload_chunk(chunk_pos)


## Sugáron belüli chunk pozíciók lekérése
func _get_chunks_in_radius(center: Vector2i, radius: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			result.append(Vector2i(center.x + dx, center.y + dy))
	return result


## Generálási queue feldolgozása (frame-enként max N chunk)
func _process_generation_queue() -> void:
	if generation_queue.is_empty():
		return

	var count: int = 0
	while not generation_queue.is_empty() and count < max_chunks_per_frame:
		var chunk_pos: Vector2i = generation_queue.pop_front()
		if chunk_pos not in loaded_chunks:
			_generate_chunk(chunk_pos)
			count += 1


## Chunk generálása
func _generate_chunk(chunk_pos: Vector2i) -> void:
	var chunk := ChunkData.new(chunk_pos)

	# Seed a chunk pozícióból (determinisztikus)
	rng.seed = world_seed + chunk_pos.x * 73856093 + chunk_pos.y * 19349663

	# Tile-ok és biome-ok generálása
	for local_x in Constants.CHUNK_SIZE:
		for local_y in Constants.CHUNK_SIZE:
			var world_tile: Vector2i = chunk.local_to_world(local_x, local_y)
			var biome_type: Enums.BiomeType = biome_resolver.get_biome(
				world_tile.x, world_tile.y, noise_manager
			)
			var height: float = noise_manager.get_height(world_tile.x, world_tile.y)

			chunk.set_tile_biome(local_x, local_y, biome_type)

			# Járhatóság: mély víz és hegycsúcs nem járható
			var is_walk: bool = height >= 0.25 and height < 0.85
			chunk.set_walkable(local_x, local_y, is_walk)

			# Tile ID beállítása (biome + variáns)
			var detail: float = noise_manager.get_detail(world_tile.x, world_tile.y)
			var tile_variant: int = int(detail * 4.0) % 4
			chunk.set_tile(local_x, local_y, tile_variant)

	# Domináns biome számítás
	chunk.calculate_dominant_biome()

	# Dekorációk generálása
	_generate_decorations(chunk)

	# Enemy spawn pontok generálása
	_generate_enemy_spawns(chunk)

	chunk.generated = true
	loaded_chunks[chunk_pos] = chunk

	EventBus.chunk_loaded.emit(chunk_pos)
	chunk_ready.emit(chunk_pos)


## Dekorációk generálása a chunk-ban
func _generate_decorations(chunk: ChunkData) -> void:
	var biome_data: BiomeData = biome_resolver.get_biome_data(chunk.biome)
	if not biome_data:
		return

	for local_x in Constants.CHUNK_SIZE:
		for local_y in Constants.CHUNK_SIZE:
			if not chunk.is_walkable(local_x, local_y):
				continue

			var world_tile: Vector2i = chunk.local_to_world(local_x, local_y)
			var detail: float = noise_manager.get_detail(world_tile.x, world_tile.y)

			# Fa generálás
			if detail < biome_data.tree_density * 0.3:
				if rng.randf() < biome_data.tree_density:
					chunk.add_decoration(Vector2i(local_x, local_y), "tree", rng.randi_range(0, 2))
					chunk.set_walkable(local_x, local_y, false)  # Fák nem járhatóak
					continue

			# Szikla generálás
			if detail > 0.7 and detail < 0.7 + biome_data.rock_density * 0.3:
				if rng.randf() < biome_data.rock_density:
					chunk.add_decoration(Vector2i(local_x, local_y), "rock", rng.randi_range(0, 1))
					chunk.set_walkable(local_x, local_y, false)
					continue

			# Fű / virág generálás
			if rng.randf() < biome_data.grass_density * 0.2:
				chunk.add_decoration(Vector2i(local_x, local_y), "grass", rng.randi_range(0, 3))

			# Speciális dekoráció
			if rng.randf() < biome_data.decoration_density * 0.05:
				chunk.add_decoration(Vector2i(local_x, local_y), "special", rng.randi_range(0, 2))


## Enemy spawn pontok generálása
func _generate_enemy_spawns(chunk: ChunkData) -> void:
	var biome_data: BiomeData = biome_resolver.get_biome_data(chunk.biome)
	if not biome_data:
		return

	# Spawn sűrűség a nehézség alapján
	var spawn_count: int = rng.randi_range(1, 3 + biome_data.difficulty_level)

	for i in spawn_count:
		var local_x: int = rng.randi_range(2, Constants.CHUNK_SIZE - 3)
		var local_y: int = rng.randi_range(2, Constants.CHUNK_SIZE - 3)

		if not chunk.is_walkable(local_x, local_y):
			continue

		var enemy_types: Array = [
			Enums.EnemyType.MELEE,
			Enums.EnemyType.RANGED,
			Enums.EnemyType.CASTER,
		]
		var enemy_type: Enums.EnemyType = enemy_types[rng.randi_range(0, 2)]

		# Elite esély nehézség alapján
		if rng.randf() < 0.05 * biome_data.difficulty_level:
			enemy_type = Enums.EnemyType.ELITE

		var level: int = rng.randi_range(biome_data.enemy_level_min, biome_data.enemy_level_max)
		chunk.add_enemy_spawn(Vector2i(local_x, local_y), enemy_type, level)


## Chunk unload
func _unload_chunk(chunk_pos: Vector2i) -> void:
	if chunk_pos in loaded_chunks:
		var chunk: ChunkData = loaded_chunks[chunk_pos]
		# Módosított chunk mentése
		if chunk.modified:
			_save_chunk(chunk)

		loaded_chunks.erase(chunk_pos)
		EventBus.chunk_unloaded.emit(chunk_pos)


## Chunk mentése fájlba
func _save_chunk(chunk: ChunkData) -> void:
	var dir := DirAccess.open("user://")
	if dir and not dir.dir_exists("chunk_cache"):
		dir.make_dir("chunk_cache")

	var file_path: String = CHUNK_CACHE_DIR + "chunk_%d_%d.json" % [chunk.chunk_pos.x, chunk.chunk_pos.y]
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json_str: String = JSON.stringify(chunk.serialize())
		file.store_string(json_str)
		file.close()


## Chunk betöltése fájlból (ha létezik)
func _load_cached_chunk(chunk_pos: Vector2i) -> ChunkData:
	var file_path: String = CHUNK_CACHE_DIR + "chunk_%d_%d.json" % [chunk_pos.x, chunk_pos.y]
	if not FileAccess.file_exists(file_path):
		return null

	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		return null

	var json_str: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	if json.parse(json_str) != OK:
		return null

	return ChunkData.deserialize(json.data)


## Chunk lekérdezése (ha be van töltve)
func get_chunk(chunk_pos: Vector2i) -> ChunkData:
	return loaded_chunks.get(chunk_pos, null)


## Biome lekérdezése világ tile pozícióból
func get_biome_at_tile(tile_pos: Vector2i) -> Enums.BiomeType:
	var chunk_pos: Vector2i = tile_to_chunk(tile_pos)
	var chunk: ChunkData = get_chunk(chunk_pos)
	if chunk:
		var local: Vector2i = ChunkData.world_to_local(tile_pos.x, tile_pos.y)
		return chunk.get_tile_biome(local.x, local.y)
	# Ha nincs betöltve, közvetlenül kiszámoljuk
	return biome_resolver.get_biome(tile_pos.x, tile_pos.y, noise_manager)


## Járhatóság ellenőrzése világ tile pozícióból
func is_tile_walkable(tile_pos: Vector2i) -> bool:
	var chunk_pos: Vector2i = tile_to_chunk(tile_pos)
	var chunk: ChunkData = get_chunk(chunk_pos)
	if chunk:
		var local: Vector2i = ChunkData.world_to_local(tile_pos.x, tile_pos.y)
		return chunk.is_walkable(local.x, local.y)
	return true


## Összes betöltött chunk törlése
func clear_all() -> void:
	for chunk_pos in loaded_chunks.keys():
		_unload_chunk(chunk_pos)
	loaded_chunks.clear()
	generation_queue.clear()
	last_player_chunk = Vector2i(999999, 999999)

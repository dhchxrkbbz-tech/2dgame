## WorldGenerator - Teljes világ generálás pipeline
## Összefogja a noise, biome, POI, road, dungeon generálást
class_name WorldGenerator
extends Node

signal generation_started()
signal generation_progress(step: String, percent: float)
signal generation_completed(spawn_point: Vector2)

var noise_manager: NoiseManager
var biome_resolver: BiomeResolver
var poi_generator: POIGenerator
var road_generator: RoadGenerator
var dungeon_placer: DungeonPlacer

var world_seed: int = 0
var world_size: int = 512  # Chunk-okban (közepes világ)
var spawn_point: Vector2 = Vector2.ZERO

# Generálás állapota
var is_generated: bool = false


func initialize(
	p_noise_manager: NoiseManager,
	p_biome_resolver: BiomeResolver,
	p_poi_generator: POIGenerator,
	p_road_generator: RoadGenerator,
	p_dungeon_placer: DungeonPlacer
) -> void:
	noise_manager = p_noise_manager
	biome_resolver = p_biome_resolver
	poi_generator = p_poi_generator
	road_generator = p_road_generator
	dungeon_placer = p_dungeon_placer


## Teljes világ generálás
func generate_world(seed_value: int, size: int = 512) -> void:
	world_seed = seed_value
	world_size = size

	generation_started.emit()
	print("WorldGenerator: Starting world generation with seed %d, size %d" % [seed_value, size])

	# 1. Noise setup
	generation_progress.emit("Noise layers inicializálás...", 0.0)
	noise_manager.initialize(seed_value)
	print("  Step 1/7: Noise layers ready")

	# 2. Spawn pont keresés
	generation_progress.emit("Spawn pont keresés...", 0.15)
	spawn_point = _find_spawn_point()
	biome_resolver.set_spawn_point(spawn_point)
	print("  Step 2/7: Spawn point at %s" % str(spawn_point))

	# 3. Corruption forráspontok
	generation_progress.emit("Corruption források...", 0.25)
	_setup_corruption_sources()
	print("  Step 3/7: Corruption sources set")

	# 4. POI generálás
	generation_progress.emit("POI-k elhelyezése...", 0.35)
	poi_generator.initialize(noise_manager, biome_resolver, seed_value, world_size)
	var all_pois: Array = poi_generator.generate_all_pois(spawn_point)
	print("  Step 4/7: %d POIs generated" % all_pois.size())

	# 5. Úthálózat
	generation_progress.emit("Úthálózat generálás...", 0.55)
	road_generator.initialize(noise_manager, seed_value)
	road_generator.generate_roads(poi_generator.towns, poi_generator.dungeons)
	print("  Step 5/7: Roads generated")

	# 6. Dungeon bejáratok feldolgozása
	generation_progress.emit("Dungeon-ök feldolgozása...", 0.75)
	dungeon_placer.initialize(noise_manager, biome_resolver, seed_value)
	var dungeon_pois: Array[Dictionary] = poi_generator.get_pois_by_type("dungeon")
	dungeon_placer.process_dungeon_pois(dungeon_pois)
	print("  Step 6/7: Dungeons processed")

	# 7. Kész
	generation_progress.emit("Világ kész!", 1.0)
	is_generated = true
	print("WorldGenerator: World generation complete!")

	generation_completed.emit(spawn_point)


## Spawn pont keresése (alacsony corruption, járható, meadow biome)
func _find_spawn_point() -> Vector2:
	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed

	# Első próba: világ közepe körül keresünk
	for _attempt in 200:
		var x: int = rng.randi_range(-50, 50)
		var y: int = rng.randi_range(-50, 50)

		var height: float = noise_manager.get_height(x, y)
		var corruption: float = noise_manager.get_corruption(x, y)
		var temp: float = noise_manager.get_temperature(x, y)

		# Járható, alacsony corruption, kellemes hőmérséklet
		if height >= 0.35 and height <= 0.55 and corruption < 0.2 and temp > 0.3 and temp < 0.7:
			return Vector2(x, y)

	# Fallback: egyszerűen (0, 0)
	return Vector2.ZERO


## Corruption forráspontok beállítása
func _setup_corruption_sources() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = world_seed + 99999

	var tile_size: int = world_size * Constants.CHUNK_SIZE
	var half: int = tile_size / 4

	# 3-5 corruption forrás
	var count: int = rng.randi_range(3, 5)
	for i in count:
		var pos := Vector2(
			rng.randf_range(-half, half),
			rng.randf_range(-half, half)
		)
		# Ne legyen túl közel a spawn-hoz
		if pos.distance_to(spawn_point) > 80:
			noise_manager.add_corruption_source(pos)


## World seed lekérdezése
func get_world_seed() -> int:
	return world_seed


## Spawn pont lekérdezése
func get_spawn_point() -> Vector2:
	return spawn_point

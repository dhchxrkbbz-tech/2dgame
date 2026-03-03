## WorldManager - Fő világ kezelő singleton (Autoload)
## Összefogja az összes világ alrendszert: generálás, chunk, biome, POI, road, environment
##
## Node struktúra:
##   WorldManager (Autoload)
##   ├── WorldGenerator
##   ├── NoiseManager
##   ├── BiomeResolver
##   ├── ChunkManager
##   ├── POIGenerator
##   ├── RoadGenerator
##   ├── DungeonPlacer
##   ├── TileRules
##   ├── EnvironmentManager
##   └── MinimapManager
extends Node

# === Alrendszerek ===
var world_generator: WorldGenerator
var noise_manager: NoiseManager
var biome_resolver: BiomeResolver
var chunk_manager: ChunkManager
var poi_generator: POIGenerator
var road_generator: RoadGenerator
var dungeon_placer: DungeonPlacer
var tile_rules: TileRules
var environment_manager: EnvironmentManager
var minimap_manager: MinimapManager

# === TileMap referenciák (WorldRenderer-ből állítjuk be) ===
var tile_map_ground: TileMapLayer = null
var tile_map_decoration: TileMapLayer = null
var tile_map_overlay: TileMapLayer = null

# === Világ állapot ===
var world_seed: int = 0
var world_size: int = 512  # Chunk-okban
var is_world_ready: bool = false
var spawn_point: Vector2 = Vector2.ZERO

# === Játékos követés ===
var player_ref: CharacterBody2D = null
var current_player_biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW

# Signalok
signal world_ready(spawn_point: Vector2)
signal world_generation_progress(step: String, percent: float)


func _ready() -> void:
	_create_subsystems()


func _create_subsystems() -> void:
	# Node-ok létrehozása
	noise_manager = NoiseManager.new()
	noise_manager.name = "NoiseManager"
	add_child(noise_manager)

	biome_resolver = BiomeResolver.new()
	biome_resolver.name = "BiomeResolver"
	add_child(biome_resolver)

	chunk_manager = ChunkManager.new()
	chunk_manager.name = "ChunkManager"
	add_child(chunk_manager)

	poi_generator = POIGenerator.new()
	poi_generator.name = "POIGenerator"
	add_child(poi_generator)

	road_generator = RoadGenerator.new()
	road_generator.name = "RoadGenerator"
	add_child(road_generator)

	dungeon_placer = DungeonPlacer.new()
	dungeon_placer.name = "DungeonPlacer"
	add_child(dungeon_placer)

	tile_rules = TileRules.new()
	tile_rules.name = "TileRules"
	add_child(tile_rules)

	environment_manager = EnvironmentManager.new()
	environment_manager.name = "EnvironmentManager"
	add_child(environment_manager)

	minimap_manager = MinimapManager.new()
	minimap_manager.name = "MinimapManager"
	add_child(minimap_manager)

	world_generator = WorldGenerator.new()
	world_generator.name = "WorldGenerator"
	add_child(world_generator)

	# WorldGenerator signal-ok
	world_generator.generation_progress.connect(_on_generation_progress)
	world_generator.generation_completed.connect(_on_generation_completed)

	# ChunkManager signal
	chunk_manager.chunk_ready.connect(_on_chunk_ready)


## Világ generálása adott seed-del
func generate_world(seed_value: int = -1, size: int = 512) -> void:
	if seed_value < 0:
		seed_value = randi()

	world_seed = seed_value
	world_size = size
	is_world_ready = false

	print("WorldManager: Generating world with seed %d" % world_seed)

	# Alrendszerek inicializálása
	world_generator.initialize(
		noise_manager, biome_resolver, poi_generator,
		road_generator, dungeon_placer
	)

	# Generálás indítása
	world_generator.generate_world(world_seed, world_size)


func _on_generation_progress(step: String, percent: float) -> void:
	world_generation_progress.emit(step, percent)


func _on_generation_completed(p_spawn_point: Vector2) -> void:
	spawn_point = p_spawn_point

	# Chunk manager inicializálás
	chunk_manager.initialize(noise_manager, biome_resolver, world_seed)

	# Environment manager
	environment_manager.initialize(biome_resolver)

	# Minimap manager
	minimap_manager.initialize(
		chunk_manager, biome_resolver, noise_manager,
		poi_generator, road_generator, tile_rules
	)

	is_world_ready = true
	world_ready.emit(spawn_point)
	print("WorldManager: World ready! Spawn at %s" % str(spawn_point))


## Játékos pozíció frissítés - minden frame hívandó
func update_player_position(world_pos: Vector2) -> void:
	if not is_world_ready:
		return

	# Chunk betöltés/unload
	chunk_manager.update_chunks(world_pos)

	# Minimap frissítés
	minimap_manager.update_player_position(world_pos)

	# Biome ellenőrzés
	var tile_pos := Vector2i(
		int(world_pos.x / Constants.TILE_SIZE),
		int(world_pos.y / Constants.TILE_SIZE)
	)
	var new_biome: Enums.BiomeType = chunk_manager.get_biome_at_tile(tile_pos)
	if new_biome != current_player_biome:
		current_player_biome = new_biome
		environment_manager.on_biome_changed(new_biome)


## Chunk kész - tile-ok renderelése
func _on_chunk_ready(chunk_pos: Vector2i) -> void:
	_render_chunk(chunk_pos)


## Chunk renderelése a TileMap-okra
func _render_chunk(chunk_pos: Vector2i) -> void:
	var chunk: ChunkData = chunk_manager.get_chunk(chunk_pos)
	if not chunk:
		return

	for local_x in Constants.CHUNK_SIZE:
		for local_y in Constants.CHUNK_SIZE:
			var world_tile: Vector2i = chunk.local_to_world(local_x, local_y)
			var biome_type: Enums.BiomeType = chunk.get_tile_biome(local_x, local_y)
			var height: float = noise_manager.get_height(world_tile.x, world_tile.y)
			var tile_variant: int = chunk.get_tile(local_x, local_y)

			# Tile típus meghatározása
			var atlas_x: int = 0
			var atlas_y: int = 0

			if height < 0.25:
				# Mély víz
				atlas_x = _biome_to_atlas_row(biome_type)
				atlas_y = 4  # Víz sor
			elif height < 0.35:
				# Sekély víz
				atlas_x = _biome_to_atlas_row(biome_type)
				atlas_y = 5
			elif height > 0.85:
				# Hegycsúcs
				atlas_x = 0
				atlas_y = 6
			else:
				# Út ellenőrzés
				if road_generator.is_road_tile(world_tile):
					var road_type: int = road_generator.get_road_type(world_tile)
					atlas_x = _biome_to_atlas_row(biome_type)
					atlas_y = 2 if road_type == 0 else 3  # Fő / mellékút
				else:
					# Normál ground
					atlas_x = _biome_to_atlas_row(biome_type)
					atlas_y = tile_variant % 2

			# Ground layer beállítás
			if tile_map_ground:
				tile_map_ground.set_cell(world_tile, 0, Vector2i(atlas_x, atlas_y))

	# Dekorációk renderelése
	_render_chunk_decorations(chunk)


## Chunk dekorációinak renderelése
func _render_chunk_decorations(chunk: ChunkData) -> void:
	if not tile_map_decoration:
		return

	for deco in chunk.decorations:
		var local_pos: Vector2i = deco["pos"]
		var world_tile: Vector2i = chunk.local_to_world(local_pos.x, local_pos.y)
		var deco_type: String = deco["type"]
		var variant: int = deco.get("variant", 0)

		# Dekoráció atlas koordináták
		var atlas_x: int = 0
		var atlas_y: int = 0

		match deco_type:
			"tree":
				atlas_x = variant
				atlas_y = 0
			"rock":
				atlas_x = variant
				atlas_y = 1
			"grass":
				atlas_x = variant
				atlas_y = 2
			"special":
				atlas_x = variant
				atlas_y = 3

		tile_map_decoration.set_cell(world_tile, 0, Vector2i(atlas_x, atlas_y))


## Biome → atlas sor mapping
func _biome_to_atlas_row(biome: Enums.BiomeType) -> int:
	match biome:
		Enums.BiomeType.STARTING_MEADOW: return 0
		Enums.BiomeType.CURSED_FOREST: return 1
		Enums.BiomeType.DARK_SWAMP: return 2
		Enums.BiomeType.RUINS: return 3
		Enums.BiomeType.MOUNTAINS: return 4
		Enums.BiomeType.FROZEN_WASTES: return 5
		Enums.BiomeType.ASHLANDS: return 6
		Enums.BiomeType.PLAGUE_LANDS: return 7
		_: return 0


## TileMap-ok beállítása (a GameWorld scene-ből hívandó)
func setup_tilemaps(
	ground: TileMapLayer,
	decoration: TileMapLayer,
	overlay: TileMapLayer
) -> void:
	tile_map_ground = ground
	tile_map_decoration = decoration
	tile_map_overlay = overlay


## Environment manager CanvasModulate beállítás
func setup_environment(canvas_mod: CanvasModulate, particles: GPUParticles2D = null) -> void:
	environment_manager.setup_nodes(canvas_mod, particles)


## Játékos referencia regisztrálás
func register_player(player: CharacterBody2D) -> void:
	player_ref = player


## Chunk tile-ok törlése unload-nál
func _clear_chunk_tiles(chunk_pos: Vector2i) -> void:
	for local_x in Constants.CHUNK_SIZE:
		for local_y in Constants.CHUNK_SIZE:
			var world_tile := Vector2i(
				chunk_pos.x * Constants.CHUNK_SIZE + local_x,
				chunk_pos.y * Constants.CHUNK_SIZE + local_y
			)
			if tile_map_ground:
				tile_map_ground.erase_cell(world_tile)
			if tile_map_decoration:
				tile_map_decoration.erase_cell(world_tile)
			if tile_map_overlay:
				tile_map_overlay.erase_cell(world_tile)


## Aktuális biome adat
func get_current_biome_data() -> BiomeData:
	return biome_resolver.get_biome_data(current_player_biome)


## Világ mentési adatok
func get_save_data() -> Dictionary:
	return {
		"world_seed": world_seed,
		"world_size": world_size,
		"spawn_point": {"x": spawn_point.x, "y": spawn_point.y},
		"dungeon_entries": dungeon_placer.serialize(),
	}


## Világ betöltése mentésből
func load_from_save(data: Dictionary) -> void:
	world_seed = data.get("world_seed", randi())
	world_size = data.get("world_size", 512)
	var sp: Dictionary = data.get("spawn_point", {"x": 0, "y": 0})
	spawn_point = Vector2(sp["x"], sp["y"])

	# Újra-generálás ugyan azzal a seed-del
	generate_world(world_seed, world_size)

	# Dungeon állapot visszaállítása
	if "dungeon_entries" in data:
		dungeon_placer.deserialize(data["dungeon_entries"])

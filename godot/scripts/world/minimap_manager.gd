## MinimapManager - Minimap adatok generálása és frissítése
## Biome-ok, POI-k, játékos pozíció kirajzolása
class_name MinimapManager
extends Node

# Minimap texture mérete
const MINIMAP_SIZE: int = 200
const MINIMAP_ZOOM: float = 1.0  # Tile-ok / pixel

# Minimap image
var minimap_image: Image
var minimap_texture: ImageTexture

# Referenciák
var chunk_manager: ChunkManager
var biome_resolver: BiomeResolver
var noise_manager: NoiseManager
var poi_generator: POIGenerator
var road_generator: RoadGenerator
var tile_rules: TileRules

# Felfedezett területek
var explored_tiles: Dictionary = {}  # Vector2i -> bool
var fog_of_war_enabled: bool = true

# Frissítési sebesség
var update_timer: float = 0.0
const UPDATE_INTERVAL: float = 0.5  # Fél másodpercenként frissít

# Játékos pozíció
var player_tile_pos: Vector2i = Vector2i.ZERO


func initialize(
	p_chunk_manager: ChunkManager,
	p_biome_resolver: BiomeResolver,
	p_noise_manager: NoiseManager,
	p_poi_generator: POIGenerator,
	p_road_generator: RoadGenerator,
	p_tile_rules: TileRules
) -> void:
	chunk_manager = p_chunk_manager
	biome_resolver = p_biome_resolver
	noise_manager = p_noise_manager
	poi_generator = p_poi_generator
	road_generator = p_road_generator
	tile_rules = p_tile_rules

	minimap_image = Image.create(MINIMAP_SIZE, MINIMAP_SIZE, false, Image.FORMAT_RGBA8)
	minimap_image.fill(Color(0, 0, 0, 0.8))
	minimap_texture = ImageTexture.create_from_image(minimap_image)


func _process(delta: float) -> void:
	update_timer += delta
	if update_timer >= UPDATE_INTERVAL:
		update_timer = 0.0
		_update_minimap()


## Játékos pozíció frissítése
func update_player_position(world_pos: Vector2) -> void:
	player_tile_pos = Vector2i(
		int(world_pos.x / Constants.TILE_SIZE),
		int(world_pos.y / Constants.TILE_SIZE)
	)

	# Felfedezés: sugáron belüli tile-ok
	var explore_radius: int = 10
	for dx in range(-explore_radius, explore_radius + 1):
		for dy in range(-explore_radius, explore_radius + 1):
			if Vector2(dx, dy).length() <= explore_radius:
				var tile := Vector2i(player_tile_pos.x + dx, player_tile_pos.y + dy)
				explored_tiles[tile] = true


## Minimap frissítése
func _update_minimap() -> void:
	if not minimap_image:
		return

	var half_size: int = MINIMAP_SIZE / 2

	for px in MINIMAP_SIZE:
		for py in MINIMAP_SIZE:
			var tile_x: int = player_tile_pos.x + int((px - half_size) * MINIMAP_ZOOM)
			var tile_y: int = player_tile_pos.y + int((py - half_size) * MINIMAP_ZOOM)
			var tile_pos := Vector2i(tile_x, tile_y)

			# Fog of war
			if fog_of_war_enabled and tile_pos not in explored_tiles:
				minimap_image.set_pixel(px, py, Color(0.1, 0.1, 0.1, 0.9))
				continue

			# Alap szín a biome-ból
			var height: float = noise_manager.get_height(tile_x, tile_y)
			var color: Color

			if height < 0.25:
				color = Color(0.1, 0.15, 0.35)  # Mély víz
			elif height < 0.35:
				color = Color(0.2, 0.3, 0.5)  # Sekély víz
			elif height > 0.85:
				color = Color(0.4, 0.38, 0.35)  # Hegycsúcs
			else:
				var biome: Enums.BiomeType = biome_resolver.get_biome(
					tile_x, tile_y, noise_manager
				)
				color = tile_rules.get_ground_color(biome, 0)

			# Út overlay
			if road_generator and road_generator.is_road_tile(tile_pos):
				var road_type: int = road_generator.get_road_type(tile_pos)
				color = color.lerp(Color(0.65, 0.55, 0.35), 0.7 if road_type == 0 else 0.5)

			minimap_image.set_pixel(px, py, color)

	# Játékos pozíció jelölő (piros pont a közepén)
	_draw_player_marker(half_size, half_size)

	# POI jelölők
	_draw_poi_markers(half_size)

	minimap_texture = ImageTexture.create_from_image(minimap_image)


## Játékos jelölő rajzolása
func _draw_player_marker(cx: int, cy: int) -> void:
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			var px: int = cx + dx
			var py: int = cy + dy
			if px >= 0 and px < MINIMAP_SIZE and py >= 0 and py < MINIMAP_SIZE:
				if abs(dx) + abs(dy) <= 2:
					minimap_image.set_pixel(px, py, Color.RED)


## POI jelölők rajzolása
func _draw_poi_markers(half_size: int) -> void:
	if not poi_generator:
		return

	for poi in poi_generator.all_pois:
		var poi_tile := Vector2i(int(poi["pos"].x), int(poi["pos"].y))

		# Minimap pixel koordináta
		var px: int = half_size + int((poi_tile.x - player_tile_pos.x) / MINIMAP_ZOOM)
		var py: int = half_size + int((poi_tile.y - player_tile_pos.y) / MINIMAP_ZOOM)

		if px < 2 or px >= MINIMAP_SIZE - 2 or py < 2 or py >= MINIMAP_SIZE - 2:
			continue

		# Fog of war ellenőrzés
		if fog_of_war_enabled and poi_tile not in explored_tiles:
			continue

		# POI szín a típus alapján
		var color: Color = _get_poi_color(poi["type"])

		# 3x3 négyzet rajzolása
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				minimap_image.set_pixel(px + dx, py + dy, color)


## POI szín
func _get_poi_color(poi_type: String) -> Color:
	match poi_type:
		"town": return Color(1.0, 1.0, 0.3)    # Sárga
		"village": return Color(0.8, 0.7, 0.3)  # Halvány sárga
		"trader": return Color(0.2, 0.8, 0.2)   # Zöld
		"ruin": return Color(0.6, 0.5, 0.3)     # Barna
		"shrine": return Color(0.3, 0.7, 1.0)   # Világoskék
		"dungeon": return Color(0.8, 0.2, 0.2)  # Piros
		"boss_arena": return Color(1.0, 0.0, 0.0)  # Élénk piros
		"cave": return Color(0.5, 0.4, 0.3)     # Sötétbarna
		"teleport": return Color(0.5, 0.2, 0.8) # Lila
		_: return Color.WHITE


## Minimap textúra lekérdezése
func get_minimap_texture() -> ImageTexture:
	return minimap_texture


## Fog of war ki/be kapcsolás
func set_fog_of_war(enabled: bool) -> void:
	fog_of_war_enabled = enabled


## Felfedezett területek törlése
func clear_explored() -> void:
	explored_tiles.clear()

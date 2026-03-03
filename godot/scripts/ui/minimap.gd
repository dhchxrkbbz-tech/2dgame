## Minimap - World minimap UI
## Player pozíció, enemy dot-ok, POI-k, biome színek
class_name Minimap
extends Control

@export var map_size: float = 150.0
@export var zoom_level: float = 4.0  # Pixel per map pixel
@export var show_enemies: bool = true
@export var show_pois: bool = true
@export var show_players: bool = true

# === Szín definíciók ===
const COLOR_PLAYER: Color = Color(0.2, 0.8, 0.2)
const COLOR_PARTY: Color = Color(0.3, 0.5, 1.0)
const COLOR_ENEMY: Color = Color(0.9, 0.2, 0.2)
const COLOR_BOSS: Color = Color(1.0, 0.1, 0.1)
const COLOR_NPC: Color = Color(0.9, 0.9, 0.2)
const COLOR_POI: Color = Color(0.8, 0.6, 0.1)
const COLOR_DUNGEON: Color = Color(0.6, 0.1, 0.8)
const COLOR_BG: Color = Color(0.05, 0.05, 0.1, 0.7)
const COLOR_BORDER: Color = Color(0.3, 0.3, 0.3, 0.8)

# === Biome szinek a minimap-on ===
const BIOME_COLORS: Dictionary = {
	0: Color(0.3, 0.6, 0.2),   # Starting Meadow - zöld
	1: Color(0.15, 0.3, 0.1),  # Cursed Forest - sötétzöld
	2: Color(0.2, 0.25, 0.15), # Dark Swamp - mocsár
	3: Color(0.4, 0.35, 0.25), # Ancient Ruins - barna
	4: Color(0.5, 0.45, 0.4),  # Mountains - szürke
	5: Color(0.7, 0.75, 0.85), # Frozen Wastes - fehéres
	6: Color(0.5, 0.25, 0.1),  # Ashlands - narancsos
	7: Color(0.35, 0.2, 0.3),  # Plague Lands - lila
}

# Tracked entities
var player_pos: Vector2 = Vector2.ZERO
var tracked_entities: Array[Dictionary] = []  # {pos, type, color}
var revealed_chunks: Dictionary = {}  # chunk_pos -> biome_type

# Interakció
var is_expanded: bool = false


func _ready() -> void:
	custom_minimum_size = Vector2(map_size, map_size)
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Anchors: jobb felső sarok
	anchor_left = 1.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 0.0
	offset_left = -map_size - 10
	offset_top = 10
	offset_right = -10
	offset_bottom = map_size + 10


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var center := Vector2(map_size / 2.0, map_size / 2.0)
	
	# Háttér (kör alakú)
	draw_circle(center, map_size / 2.0, COLOR_BG)
	
	# Biome tiles rajzolás
	_draw_biome_tiles(center)
	
	# Tracked entities
	for entity in tracked_entities:
		var relative_pos: Vector2 = (entity["pos"] - player_pos) / zoom_level
		var map_pos := center + relative_pos
		
		# Csak a minimap-on belül
		if map_pos.distance_to(center) < map_size / 2.0 - 4:
			var dot_size: float = 2.0
			var color: Color = entity.get("color", COLOR_ENEMY)
			if entity.get("type", "") == "boss":
				dot_size = 4.0
			draw_circle(map_pos, dot_size, color)
	
	# Player pozíció (középen, mindig)
	draw_circle(center, 3.0, COLOR_PLAYER)
	
	# Forgó háromszög a player irányához
	var arrow_points := PackedVector2Array([
		center + Vector2(0, -5),
		center + Vector2(-3, 3),
		center + Vector2(3, 3),
	])
	draw_colored_polygon(arrow_points, COLOR_PLAYER)
	
	# Keret
	draw_arc(center, map_size / 2.0, 0, TAU, 64, COLOR_BORDER, 2.0)


func _draw_biome_tiles(center: Vector2) -> void:
	for chunk_pos_key in revealed_chunks:
		var chunk_pos: Vector2i = chunk_pos_key
		var biome: int = revealed_chunks[chunk_pos_key]
		var color: Color = BIOME_COLORS.get(biome, Color(0.2, 0.2, 0.2))
		
		var world_pos := Vector2(
			chunk_pos.x * Constants.CHUNK_SIZE * Constants.TILE_SIZE,
			chunk_pos.y * Constants.CHUNK_SIZE * Constants.TILE_SIZE
		)
		var relative := (world_pos - player_pos) / zoom_level
		var map_pos := center + relative
		var tile_size := Constants.CHUNK_SIZE * Constants.TILE_SIZE / zoom_level
		
		if map_pos.distance_to(center) < map_size:
			draw_rect(Rect2(map_pos, Vector2(tile_size, tile_size)), color)


## Player pozíció frissítése
func update_player_position(pos: Vector2) -> void:
	player_pos = pos


## Entity hozzáadása
func add_tracked_entity(pos: Vector2, entity_type: String, color: Color = COLOR_ENEMY) -> void:
	tracked_entities.append({"pos": pos, "type": entity_type, "color": color})


## Tracked entities törlése (frame-enként újratöltjük)
func clear_tracked_entities() -> void:
	tracked_entities.clear()


## Chunk felfedése
func reveal_chunk(chunk_pos: Vector2i, biome: int) -> void:
	revealed_chunks[chunk_pos] = biome


## Zoom beállítása
func set_zoom(level: float) -> void:
	zoom_level = clampf(level, 1.0, 16.0)


## Minimap nagyítás/kicsinyítés toggle
func toggle_expanded() -> void:
	is_expanded = not is_expanded
	if is_expanded:
		map_size = 300.0
	else:
		map_size = 150.0
	custom_minimum_size = Vector2(map_size, map_size)

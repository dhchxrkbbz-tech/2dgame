## DungeonMinimap - Dungeon minimap rajzolás
## Szobák, folyosók, ajtók, játékos pozíció megjelenítés
class_name DungeonMinimap
extends Control

## Konfiguráció
@export var minimap_size: Vector2 = Vector2(160, 120)
@export var tile_pixel_size: int = 2  # Egy tile mérete a minimap-on
@export var show_unexplored: bool = false  # Debug: mutasd az ismeretlen területet is

## Színek
const COLOR_FLOOR := Color(0.3, 0.3, 0.35, 0.8)
const COLOR_WALL := Color(0.15, 0.15, 0.2, 0.9)
const COLOR_CORRIDOR := Color(0.25, 0.25, 0.3, 0.7)
const COLOR_DOOR := Color(0.5, 0.4, 0.2, 0.9)
const COLOR_PLAYER := Color(0.2, 0.8, 0.2, 1.0)
const COLOR_BOSS := Color(0.9, 0.1, 0.1, 1.0)
const COLOR_CLEARED := Color(0.2, 0.5, 0.2, 0.6)
const COLOR_SECRET := Color(0.7, 0.5, 0.9, 0.8)
const COLOR_SAFE := Color(0.3, 0.7, 0.9, 0.8)
const COLOR_TREASURE := Color(0.9, 0.7, 0.1, 0.8)
const COLOR_UNEXPLORED := Color(0.05, 0.05, 0.08, 0.5)
const COLOR_BACKGROUND := Color(0.02, 0.02, 0.05, 0.7)

## State
var dungeon_tile_data: Dictionary = {}
var dungeon_rooms: Array = []
var fog_of_war: FogOfWar = null
var player_tile_pos: Vector2i = Vector2i.ZERO
var dungeon_width: int = 80
var dungeon_height: int = 60

## Offset (centering)
var view_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	custom_minimum_size = minimap_size
	size = minimap_size
	mouse_filter = MOUSE_FILTER_IGNORE


func _draw() -> void:
	# Háttér
	draw_rect(Rect2(Vector2.ZERO, minimap_size), COLOR_BACKGROUND)
	
	# Border
	draw_rect(Rect2(Vector2.ZERO, minimap_size), Color(0.3, 0.3, 0.35, 0.5), false, 1.0)
	
	# Centering offset: player a középre kerüljön
	view_offset = minimap_size / 2.0 - Vector2(player_tile_pos) * tile_pixel_size
	
	# Tile-ok rajzolása
	for pos in dungeon_tile_data:
		var tile_type: int = dungeon_tile_data[pos]
		if tile_type == 0:  # EMPTY
			continue
		
		# Fog of War ellenőrzés
		if fog_of_war and not show_unexplored:
			if fog_of_war.is_tile_hidden(pos):
				continue
		
		var screen_pos := Vector2(pos) * tile_pixel_size + view_offset
		
		# Boundary check
		if screen_pos.x < -tile_pixel_size or screen_pos.x > minimap_size.x:
			continue
		if screen_pos.y < -tile_pixel_size or screen_pos.y > minimap_size.y:
			continue
		
		var color := _get_tile_color(pos, tile_type)
		draw_rect(Rect2(screen_pos, Vector2(tile_pixel_size, tile_pixel_size)), color)
	
	# Szoba ikonok (cleared, boss, stb.)
	for room in dungeon_rooms:
		if not room is DungeonRoom:
			continue
		
		# Fog check
		if fog_of_war and not show_unexplored:
			if not fog_of_war.is_tile_explored(room.get_center()):
				continue
		
		var center := Vector2(room.get_center()) * tile_pixel_size + view_offset
		var icon_color := _get_room_icon_color(room)
		if icon_color.a > 0:
			draw_circle(center, tile_pixel_size * 1.5, icon_color)
	
	# Játékos pozíció
	var player_screen := Vector2(player_tile_pos) * tile_pixel_size + view_offset
	draw_circle(player_screen, tile_pixel_size * 2, COLOR_PLAYER)


func _get_tile_color(pos: Vector2i, tile_type: int) -> Color:
	# Explored de nem visible → halványabb
	var alpha_mult := 1.0
	if fog_of_war and fog_of_war.is_tile_explored(pos) and not fog_of_war.is_tile_visible(pos):
		alpha_mult = 0.5
	
	var color: Color
	match tile_type:
		1: color = COLOR_FLOOR        # FLOOR
		2: color = COLOR_WALL          # WALL
		3: color = COLOR_DOOR          # DOOR
		4: color = COLOR_CORRIDOR      # CORRIDOR
		_: color = COLOR_FLOOR
	
	color.a *= alpha_mult
	return color


func _get_room_icon_color(room: DungeonRoom) -> Color:
	if room.is_cleared:
		return COLOR_CLEARED
	
	match room.room_type:
		DungeonRoom.RoomType.BOSS: return COLOR_BOSS
		DungeonRoom.RoomType.SAFE: return COLOR_SAFE
		DungeonRoom.RoomType.TREASURE: return COLOR_TREASURE
		DungeonRoom.RoomType.SECRET: return COLOR_SECRET if room.is_discovered else Color(0, 0, 0, 0)
		_: return Color(0, 0, 0, 0)  # Nincs speciális ikon


## Frissítés
func update_minimap(p_player_tile_pos: Vector2i) -> void:
	player_tile_pos = p_player_tile_pos
	queue_redraw()


## Dungeon adatok betöltés
func load_dungeon_data(tile_data: Dictionary, rooms: Array, 
		p_fog: FogOfWar = null, width: int = 80, height: int = 60) -> void:
	dungeon_tile_data = tile_data
	dungeon_rooms = rooms
	fog_of_war = p_fog
	dungeon_width = width
	dungeon_height = height
	queue_redraw()


## Szoba felfedezés jelzése
func mark_room_discovered(room_index: int) -> void:
	if room_index >= 0 and room_index < dungeon_rooms.size():
		if dungeon_rooms[room_index] is DungeonRoom:
			dungeon_rooms[room_index].is_discovered = true
			queue_redraw()


## Szoba cleared jelzése
func mark_room_cleared(room_index: int) -> void:
	if room_index >= 0 and room_index < dungeon_rooms.size():
		if dungeon_rooms[room_index] is DungeonRoom:
			dungeon_rooms[room_index].is_cleared = true
			queue_redraw()

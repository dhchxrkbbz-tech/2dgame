## TestMap - Egyszerű teszt térkép a fejlesztéshez
## 20x20 tile-os terület placeholder sprite-okkal
extends Node2D

const MAP_SIZE: int = 20  # tile-okban
const WALL_BORDER: int = 1  # fal vastagság a széleken

@onready var tile_map: TileMapLayer = $TileMapLayer


func _ready() -> void:
	_generate_test_map()


func _generate_test_map() -> void:
	if not tile_map:
		push_warning("TestMap: No TileMapLayer found, skipping generation")
		return
	
	# A TileMap-ot a Godot editorban kell konfigurálni tileset-tel
	# Ez a script csak a tile placement logikát definiálja
	# Placeholder esetben programatikusan generálunk színes textúrát
	
	# Alap fű terep generálása
	for x in range(-MAP_SIZE / 2, MAP_SIZE / 2):
		for y in range(-MAP_SIZE / 2, MAP_SIZE / 2):
			var is_wall := (x == -MAP_SIZE / 2 or x == MAP_SIZE / 2 - 1 or 
							y == -MAP_SIZE / 2 or y == MAP_SIZE / 2 - 1)
			
			if is_wall:
				# Atlas coords: (1, 0) = wall tile
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(1, 0))
			else:
				# Atlas coords: (0, 0) = grass tile
				tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
	
	print("TestMap: Generated %dx%d test map" % [MAP_SIZE, MAP_SIZE])

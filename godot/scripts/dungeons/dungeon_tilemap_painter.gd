## DungeonTilemapPainter - TileMap kitöltés a generált dungeon adatok alapján
## Layer 0: Floor, Layer 1: Wall, Layer 2: Decoration, Layer 3: Overlay
class_name DungeonTilemapPainter
extends RefCounted

## TileMap layer indexek
const LAYER_FLOOR: int = 0
const LAYER_WALL: int = 1
const LAYER_DECORATION: int = 2
const LAYER_OVERLAY: int = 3

## Tile típus → TileType enum (DungeonGenerator-ből)
const TILE_EMPTY: int = 0
const TILE_FLOOR: int = 1
const TILE_WALL: int = 2
const TILE_DOOR: int = 3
const TILE_CORRIDOR: int = 4
const TILE_TRAP: int = 5
const TILE_WATER: int = 6
const TILE_LAVA: int = 7

var biome: Enums.BiomeType = Enums.BiomeType.CURSED_FOREST


func _init(p_biome: Enums.BiomeType = Enums.BiomeType.CURSED_FOREST) -> void:
	biome = p_biome


## Fő rendering: teljes dungeon tile data → TileMapLayer-ekre
func paint_dungeon(tile_data: Dictionary, floor_layer: TileMapLayer,
		wall_layer: TileMapLayer = null, deco_layer: TileMapLayer = null,
		overlay_layer: TileMapLayer = null) -> void:
	
	# Ha nincs külön layer, mindent az elsőre rajzolunk
	var use_wall_layer := wall_layer if wall_layer else floor_layer
	var use_deco_layer := deco_layer if deco_layer else floor_layer
	
	for pos in tile_data:
		var tile_type: int = tile_data[pos]
		_paint_tile(pos, tile_type, floor_layer, use_wall_layer, use_deco_layer)


## Egyedi tile festése
func _paint_tile(pos: Vector2i, tile_type: int, floor_layer: TileMapLayer,
		wall_layer: TileMapLayer, deco_layer: TileMapLayer) -> void:
	
	var biome_col := _get_biome_column()
	
	match tile_type:
		TILE_FLOOR:
			floor_layer.set_cell(pos, 0, Vector2i(biome_col, 0))
		TILE_WALL:
			wall_layer.set_cell(pos, 0, Vector2i(biome_col, 1))
		TILE_CORRIDOR:
			floor_layer.set_cell(pos, 0, Vector2i(biome_col, 2))
		TILE_DOOR:
			floor_layer.set_cell(pos, 0, Vector2i(biome_col, 3))
		TILE_TRAP:
			# Trap tile = padló tile (vizuálisan alig különbözik)
			floor_layer.set_cell(pos, 0, Vector2i(biome_col, 0))
		TILE_WATER:
			floor_layer.set_cell(pos, 0, Vector2i(biome_col, 4))
		TILE_LAVA:
			floor_layer.set_cell(pos, 0, Vector2i(biome_col, 5))


## Biome → atlas oszlop mapping
func _get_biome_column() -> int:
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


## Dekoráció festése (csontok, mohák, repedések stb.)
func paint_decorations(decorations: Array[Dictionary], deco_layer: TileMapLayer) -> void:
	for deco in decorations:
		var pos: Vector2i = deco.get("pos", Vector2i.ZERO)
		var deco_type: String = deco.get("type", "crack")
		var atlas_y := _deco_type_to_atlas(deco_type)
		deco_layer.set_cell(pos, 0, Vector2i(_get_biome_column(), atlas_y))


func _deco_type_to_atlas(deco_type: String) -> int:
	match deco_type:
		"bones": return 6
		"rocks": return 7
		"crack": return 8
		"moss": return 9
		"rubble": return 10
		"cobweb": return 11
		_: return 8


## Torch node-ok létrehozása
func create_torch_nodes(torch_positions: Array[Vector2i], parent: Node2D) -> void:
	for pos in torch_positions:
		var torch := PointLight2D.new()
		torch.name = "Torch_%d_%d" % [pos.x, pos.y]
		torch.position = Vector2(pos.x * Constants.TILE_SIZE + Constants.TILE_SIZE / 2,
								pos.y * Constants.TILE_SIZE + Constants.TILE_SIZE / 2)
		torch.color = _get_biome_torch_color()
		torch.energy = 0.8
		torch.texture_scale = 2.0
		
		# Placeholder texture (kör alakú fényforrás)
		var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
		for x in 64:
			for y in 64:
				var dx := float(x - 32) / 32.0
				var dy := float(y - 32) / 32.0
				var dist := sqrt(dx * dx + dy * dy)
				var alpha := clampf(1.0 - dist, 0.0, 1.0)
				img.set_pixel(x, y, Color(1, 1, 1, alpha))
		torch.texture = ImageTexture.create_from_image(img)
		
		parent.add_child(torch)


## Biome-specifikus fáklya szín
func _get_biome_torch_color() -> Color:
	match biome:
		Enums.BiomeType.CURSED_FOREST: return Color(0.3, 0.8, 0.3, 0.7)  # Zöld
		Enums.BiomeType.DARK_SWAMP: return Color(0.3, 0.5, 0.8, 0.7)  # Kék
		Enums.BiomeType.RUINS: return Color(0.9, 0.7, 0.3, 0.8)  # Meleg
		Enums.BiomeType.MOUNTAINS: return Color(0.7, 0.8, 1.0, 0.7)  # Kristály
		Enums.BiomeType.FROZEN_WASTES: return Color(0.5, 0.7, 1.0, 0.8)  # Jégkék
		Enums.BiomeType.ASHLANDS: return Color(1.0, 0.5, 0.2, 0.9)  # Narancs
		Enums.BiomeType.PLAGUE_LANDS: return Color(0.6, 0.8, 0.2, 0.7)  # Méregzöld
		_: return Color(0.9, 0.7, 0.4, 0.8)  # Alapértelmezett meleg


## Hazard tile-ok festése (lava, ice, swamp stb.)
func paint_hazard_tiles(room: DungeonRoom, tile_data: Dictionary, 
		hazard_type: String, density: float) -> void:
	var tiles := room.get_tiles()
	var center := room.get_center()
	var rng_local := RandomNumberGenerator.new()
	rng_local.seed = room.room_index * 31337
	
	for tile in tiles:
		# Szélekhez közelebb = nagyobb esély hazard-ra
		var dist_to_edge_x := mini(tile.x - room.rect.position.x, room.rect.end.x - tile.x - 1)
		var dist_to_edge_y := mini(tile.y - room.rect.position.y, room.rect.end.y - tile.y - 1)
		var min_dist := mini(dist_to_edge_x, dist_to_edge_y)
		
		var chance := density * (1.0 - float(min_dist) / 4.0)
		if rng_local.randf() < chance and min_dist <= 2:
			match hazard_type:
				"lava": tile_data[tile] = TILE_LAVA
				"water", "swamp": tile_data[tile] = TILE_WATER
				_: pass

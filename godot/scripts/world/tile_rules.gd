## TileRules - Tile kiválasztás és auto-tile szabályok
## Biome-specifikus tile mapping és transition kezelés
class_name TileRules
extends Node

# Biome ground tile színek (placeholder-ek amíg nincs végleges tileset)
# Biome -> Array of Color variánsok
var biome_ground_colors: Dictionary = {}
var biome_road_colors: Dictionary = {}

# Speciális tile típusok
const TILE_GROUND: int = 0
const TILE_ROAD_MAIN: int = 1
const TILE_ROAD_SIDE: int = 2
const TILE_WATER_DEEP: int = 3
const TILE_WATER_SHALLOW: int = 4
const TILE_MOUNTAIN: int = 5
const TILE_DECORATION: int = 10  # 10+ = dekoráció


func _ready() -> void:
	_setup_biome_colors()


func _setup_biome_colors() -> void:
	# Ground tile variánsok biome-onként (4 variáns)
	biome_ground_colors = {
		Enums.BiomeType.STARTING_MEADOW: [
			Color(0.30, 0.70, 0.20),
			Color(0.32, 0.68, 0.22),
			Color(0.28, 0.72, 0.18),
			Color(0.34, 0.66, 0.24),
		],
		Enums.BiomeType.CURSED_FOREST: [
			Color(0.15, 0.35, 0.10),
			Color(0.18, 0.32, 0.12),
			Color(0.12, 0.30, 0.08),
			Color(0.20, 0.28, 0.14),
		],
		Enums.BiomeType.DARK_SWAMP: [
			Color(0.25, 0.35, 0.15),
			Color(0.28, 0.32, 0.18),
			Color(0.22, 0.38, 0.12),
			Color(0.30, 0.30, 0.20),
		],
		Enums.BiomeType.RUINS: [
			Color(0.50, 0.45, 0.35),
			Color(0.48, 0.43, 0.33),
			Color(0.52, 0.47, 0.37),
			Color(0.46, 0.42, 0.32),
		],
		Enums.BiomeType.MOUNTAINS: [
			Color(0.55, 0.50, 0.50),
			Color(0.52, 0.48, 0.48),
			Color(0.58, 0.53, 0.52),
			Color(0.50, 0.46, 0.46),
		],
		Enums.BiomeType.FROZEN_WASTES: [
			Color(0.80, 0.85, 0.90),
			Color(0.78, 0.83, 0.88),
			Color(0.82, 0.87, 0.92),
			Color(0.76, 0.82, 0.86),
		],
		Enums.BiomeType.ASHLANDS: [
			Color(0.40, 0.25, 0.15),
			Color(0.38, 0.23, 0.13),
			Color(0.42, 0.27, 0.17),
			Color(0.36, 0.22, 0.12),
		],
		Enums.BiomeType.PLAGUE_LANDS: [
			Color(0.35, 0.40, 0.15),
			Color(0.33, 0.38, 0.13),
			Color(0.37, 0.42, 0.17),
			Color(0.32, 0.36, 0.12),
		],
	}

	# Biome-specifikus út színek
	biome_road_colors = {
		Enums.BiomeType.STARTING_MEADOW: Color(0.65, 0.55, 0.35),  # Homokszínű földút
		Enums.BiomeType.CURSED_FOREST: Color(0.30, 0.28, 0.25),    # Sötét repedezett kő
		Enums.BiomeType.DARK_SWAMP: Color(0.45, 0.35, 0.20),       # Fa pallók
		Enums.BiomeType.RUINS: Color(0.50, 0.48, 0.42),            # Régi kő
		Enums.BiomeType.MOUNTAINS: Color(0.45, 0.42, 0.40),        # Sziklás ösvény
		Enums.BiomeType.FROZEN_WASTES: Color(0.60, 0.62, 0.65),    # Jeges út
		Enums.BiomeType.ASHLANDS: Color(0.30, 0.20, 0.15),         # Hamu ösvény
		Enums.BiomeType.PLAGUE_LANDS: Color(0.40, 0.35, 0.25),     # Csonttal szegélyezett
	}


## Ground tile szín lekérdezése biome + variáns alapján
func get_ground_color(biome: Enums.BiomeType, variant: int) -> Color:
	if biome in biome_ground_colors:
		var colors: Array = biome_ground_colors[biome]
		return colors[variant % colors.size()]
	return Color(0.3, 0.7, 0.2)


## Út szín lekérdezése
func get_road_color(biome: Enums.BiomeType, is_main_road: bool) -> Color:
	var base_color: Color = biome_road_colors.get(biome, Color(0.5, 0.4, 0.3))
	if not is_main_road:
		return base_color.darkened(0.15)
	return base_color


## Víz szín
func get_water_color(is_deep: bool) -> Color:
	if is_deep:
		return Color(0.1, 0.15, 0.35)
	return Color(0.2, 0.3, 0.5)


## Hegy szín
func get_mountain_color() -> Color:
	return Color(0.4, 0.38, 0.35)


## Dekoráció szín (fa, szikla, fű stb.)
func get_decoration_color(biome: Enums.BiomeType, deco_type: String) -> Color:
	match deco_type:
		"tree":
			match biome:
				Enums.BiomeType.STARTING_MEADOW: return Color(0.15, 0.5, 0.1)
				Enums.BiomeType.CURSED_FOREST: return Color(0.2, 0.25, 0.15)
				Enums.BiomeType.DARK_SWAMP: return Color(0.2, 0.3, 0.1)
				Enums.BiomeType.MOUNTAINS: return Color(0.1, 0.35, 0.1)
				Enums.BiomeType.FROZEN_WASTES: return Color(0.15, 0.4, 0.15)
				Enums.BiomeType.PLAGUE_LANDS: return Color(0.3, 0.25, 0.1)
				_: return Color(0.15, 0.4, 0.1)
		"rock":
			return Color(0.45, 0.42, 0.38)
		"grass":
			match biome:
				Enums.BiomeType.STARTING_MEADOW: return Color(0.35, 0.75, 0.25)
				Enums.BiomeType.FROZEN_WASTES: return Color(0.7, 0.75, 0.8)
				_: return Color(0.3, 0.55, 0.2)
		"special":
			match biome:
				Enums.BiomeType.CURSED_FOREST: return Color(0.5, 0.2, 0.6)  # Gomba
				Enums.BiomeType.PLAGUE_LANDS: return Color(0.6, 0.5, 0.1)   # Mérgező
				Enums.BiomeType.ASHLANDS: return Color(0.7, 0.3, 0.1)       # Parázs
				_: return Color(0.7, 0.6, 0.2)
		_:
			return Color(0.5, 0.5, 0.5)


## Placeholder tile textúra generálás (biome + típus alapján)
func create_tile_texture(biome: Enums.BiomeType, tile_type: int, variant: int = 0) -> ImageTexture:
	var color: Color

	match tile_type:
		TILE_GROUND:
			color = get_ground_color(biome, variant)
		TILE_ROAD_MAIN:
			color = get_road_color(biome, true)
		TILE_ROAD_SIDE:
			color = get_road_color(biome, false)
		TILE_WATER_DEEP:
			color = get_water_color(true)
		TILE_WATER_SHALLOW:
			color = get_water_color(false)
		TILE_MOUNTAIN:
			color = get_mountain_color()
		_:
			color = get_ground_color(biome, variant)

	return PlaceholderSprites.create_rect_texture(Constants.TILE_SIZE, Constants.TILE_SIZE, color)

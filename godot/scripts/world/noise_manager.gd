## NoiseManager - FastNoiseLite wrapper a világ generáláshoz
## Több noise layer kezelése: height, temperature, corruption, moisture, detail
class_name NoiseManager
extends Node

var world_seed: int = 0

# Noise layer-ek
var height_noise: FastNoiseLite
var temperature_noise: FastNoiseLite
var corruption_noise: FastNoiseLite
var moisture_noise: FastNoiseLite
var detail_noise: FastNoiseLite

# Seed offset-ek a különböző layer-ekhez
const TEMP_SEED_OFFSET: int = 1000
const CORRUPTION_SEED_OFFSET: int = 2000
const MOISTURE_SEED_OFFSET: int = 3000
const DETAIL_SEED_OFFSET: int = 4000


func initialize(seed_value: int) -> void:
	world_seed = seed_value
	_setup_noise_layers()


func _setup_noise_layers() -> void:
	# Heightmap - kontinens forma, hegyek, völgyek
	height_noise = _create_noise(world_seed, 0.008, 6, FastNoiseLite.FRACTAL_FBM, 2.0, 0.5)

	# Temperature - hőmérsékleti zónák (nagymértékű változás)
	temperature_noise = _create_noise(
		world_seed + TEMP_SEED_OFFSET, 0.004, 3, FastNoiseLite.FRACTAL_FBM, 2.0, 0.5
	)

	# Corruption - corruption intenzitás
	corruption_noise = _create_noise(
		world_seed + CORRUPTION_SEED_OFFSET, 0.006, 4, FastNoiseLite.FRACTAL_FBM, 2.0, 0.5
	)

	# Moisture - nedvesség (mocsár/sivatag határozás)
	moisture_noise = _create_noise(
		world_seed + MOISTURE_SEED_OFFSET, 0.005, 4, FastNoiseLite.FRACTAL_FBM, 2.0, 0.5
	)

	# Detail - mikro részletek (dekoráció sűrűség, tile variáns)
	detail_noise = _create_noise(
		world_seed + DETAIL_SEED_OFFSET, 0.05, 2, FastNoiseLite.FRACTAL_FBM, 2.0, 0.5
	)


func _create_noise(
	seed_val: int,
	frequency: float,
	octaves: int,
	fractal_type: int,
	lacunarity: float,
	gain: float
) -> FastNoiseLite:
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = seed_val
	noise.frequency = frequency
	noise.fractal_type = fractal_type
	noise.fractal_octaves = octaves
	noise.fractal_lacunarity = lacunarity
	noise.fractal_gain = gain
	return noise


## Normalizált érték (0.0 - 1.0) lekérés egy noise layer-ből
func get_normalized(noise: FastNoiseLite, x: float, y: float) -> float:
	var value: float = noise.get_noise_2d(x, y)
	return (value + 1.0) / 2.0


## Heightmap érték (0.0 - 1.0)
func get_height(x: float, y: float) -> float:
	return get_normalized(height_noise, x, y)


## Temperature érték (0.0 - 1.0)
func get_temperature(x: float, y: float) -> float:
	return get_normalized(temperature_noise, x, y)


## Corruption érték (0.0 - 1.0)
func get_corruption(x: float, y: float) -> float:
	var base: float = get_normalized(corruption_noise, x, y)
	# Radiális gradient a corruption forráspontoktól
	var corruption_boost: float = _get_corruption_source_influence(x, y)
	return clampf(base + corruption_boost, 0.0, 1.0)


## Moisture érték (0.0 - 1.0)
func get_moisture(x: float, y: float) -> float:
	return get_normalized(moisture_noise, x, y)


## Detail érték (0.0 - 1.0)
func get_detail(x: float, y: float) -> float:
	return get_normalized(detail_noise, x, y)


## Corruption forráspontok hatása
var corruption_sources: Array[Vector2] = []


func add_corruption_source(pos: Vector2) -> void:
	corruption_sources.append(pos)


func _get_corruption_source_influence(x: float, y: float) -> float:
	var max_influence: float = 0.0
	var pos := Vector2(x, y)
	for source in corruption_sources:
		var dist: float = pos.distance_to(source)
		# 200 tile sugarú hatás, távolsággal csökkenő
		var influence: float = maxf(0.0, 1.0 - dist / 200.0)
		max_influence = maxf(max_influence, influence * 0.5)
	return max_influence


## Összes noise érték egy ponthoz (optimalizáláshoz)
func get_all_values(x: float, y: float) -> Dictionary:
	return {
		"height": get_height(x, y),
		"temperature": get_temperature(x, y),
		"corruption": get_corruption(x, y),
		"moisture": get_moisture(x, y),
		"detail": get_detail(x, y),
	}

## BiomeResolver - Biome kiválasztás noise értékek alapján
## Szabály-alapú döntési fa a 02_procedural_world_plan.txt szerint
class_name BiomeResolver
extends Node

# Biome adatok (BiomeData resource-ok)
var biome_registry: Dictionary = {}  # BiomeType -> BiomeData

# Spawn pont (starting area protection)
var spawn_point: Vector2 = Vector2.ZERO
const SPAWN_PROTECTION_RADIUS: float = 50.0

# Víz és hegy küszöbök
const DEEP_WATER_THRESHOLD: float = 0.25
const SHALLOW_WATER_THRESHOLD: float = 0.35
const MOUNTAIN_THRESHOLD: float = 0.70
const MOUNTAIN_PEAK_THRESHOLD: float = 0.85


func _ready() -> void:
	_register_default_biomes()


func set_spawn_point(pos: Vector2) -> void:
	spawn_point = pos


func _register_default_biomes() -> void:
	# Starting Meadow
	_register_biome(Enums.BiomeType.STARTING_MEADOW, {
		"display_name": "Starting Meadow",
		"height_min": 0.35, "height_max": 0.50,
		"temperature_min": 0.4, "temperature_max": 0.6,
		"corruption_min": 0.0, "corruption_max": 0.2,
		"moisture_min": 0.3, "moisture_max": 0.6,
		"difficulty_level": 0, "difficulty_multiplier": 1.0,
		"loot_bonus_multiplier": 1.0,
		"enemy_level_min": 1, "enemy_level_max": 5,
		"tint_color": Color(1.0, 1.0, 1.0),
		"ground_color": Color(0.3, 0.7, 0.2),
		"tree_density": 0.2, "rock_density": 0.05,
		"grass_density": 0.6, "decoration_density": 0.3,
	})

	# Cursed Forest
	_register_biome(Enums.BiomeType.CURSED_FOREST, {
		"display_name": "Cursed Forest",
		"height_min": 0.35, "height_max": 0.60,
		"temperature_min": 0.3, "temperature_max": 0.6,
		"corruption_min": 0.4, "corruption_max": 0.7,
		"moisture_min": 0.4, "moisture_max": 0.7,
		"difficulty_level": 1, "difficulty_multiplier": 1.2,
		"loot_bonus_multiplier": 1.1,
		"enemy_level_min": 5, "enemy_level_max": 15,
		"tint_color": Color(0.7, 0.8, 0.6),
		"ground_color": Color(0.15, 0.35, 0.1),
		"tree_density": 0.7, "rock_density": 0.1,
		"grass_density": 0.2, "decoration_density": 0.5,
	})

	# Dark Swamp
	_register_biome(Enums.BiomeType.DARK_SWAMP, {
		"display_name": "Dark Swamp",
		"height_min": 0.30, "height_max": 0.40,
		"temperature_min": 0.5, "temperature_max": 0.8,
		"corruption_min": 0.3, "corruption_max": 0.8,
		"moisture_min": 0.7, "moisture_max": 1.0,
		"difficulty_level": 1, "difficulty_multiplier": 1.3,
		"loot_bonus_multiplier": 1.15,
		"enemy_level_min": 8, "enemy_level_max": 18,
		"tint_color": Color(0.7, 0.75, 0.6),
		"ground_color": Color(0.3, 0.35, 0.2),
		"tree_density": 0.4, "rock_density": 0.05,
		"grass_density": 0.1, "decoration_density": 0.4,
		"fog_chance": 0.4,
	})

	# Ruins
	_register_biome(Enums.BiomeType.RUINS, {
		"display_name": "Ruins",
		"height_min": 0.40, "height_max": 0.60,
		"temperature_min": 0.3, "temperature_max": 0.6,
		"corruption_min": 0.3, "corruption_max": 0.6,
		"moisture_min": 0.2, "moisture_max": 0.4,
		"difficulty_level": 2, "difficulty_multiplier": 1.4,
		"loot_bonus_multiplier": 1.2,
		"enemy_level_min": 12, "enemy_level_max": 25,
		"tint_color": Color(0.85, 0.8, 0.7),
		"ground_color": Color(0.5, 0.45, 0.35),
		"tree_density": 0.05, "rock_density": 0.3,
		"grass_density": 0.1, "decoration_density": 0.4,
	})

	# Mountains
	_register_biome(Enums.BiomeType.MOUNTAINS, {
		"display_name": "Mountains",
		"height_min": 0.70, "height_max": 0.85,
		"temperature_min": 0.0, "temperature_max": 0.4,
		"corruption_min": 0.0, "corruption_max": 1.0,
		"moisture_min": 0.0, "moisture_max": 1.0,
		"difficulty_level": 2, "difficulty_multiplier": 1.5,
		"loot_bonus_multiplier": 1.25,
		"enemy_level_min": 15, "enemy_level_max": 30,
		"tint_color": Color(0.85, 0.85, 0.9),
		"ground_color": Color(0.55, 0.5, 0.5),
		"tree_density": 0.15, "rock_density": 0.5,
		"grass_density": 0.05, "decoration_density": 0.2,
		"snow_chance": 0.3,
	})

	# Frozen Wastes
	_register_biome(Enums.BiomeType.FROZEN_WASTES, {
		"display_name": "Frozen Wastes",
		"height_min": 0.40, "height_max": 0.70,
		"temperature_min": 0.0, "temperature_max": 0.2,
		"corruption_min": 0.2, "corruption_max": 0.6,
		"moisture_min": 0.3, "moisture_max": 0.6,
		"difficulty_level": 2, "difficulty_multiplier": 1.5,
		"loot_bonus_multiplier": 1.3,
		"enemy_level_min": 18, "enemy_level_max": 35,
		"tint_color": Color(0.8, 0.85, 1.0),
		"ground_color": Color(0.8, 0.85, 0.9),
		"tree_density": 0.1, "rock_density": 0.2,
		"grass_density": 0.0, "decoration_density": 0.15,
		"has_cold_damage": true, "cold_dps": 2.0,
		"snow_chance": 0.6,
	})

	# Ashlands
	_register_biome(Enums.BiomeType.ASHLANDS, {
		"display_name": "Ashlands",
		"height_min": 0.40, "height_max": 0.60,
		"temperature_min": 0.8, "temperature_max": 1.0,
		"corruption_min": 0.5, "corruption_max": 0.9,
		"moisture_min": 0.0, "moisture_max": 0.2,
		"difficulty_level": 3, "difficulty_multiplier": 1.8,
		"loot_bonus_multiplier": 1.4,
		"enemy_level_min": 25, "enemy_level_max": 40,
		"tint_color": Color(0.9, 0.7, 0.5),
		"ground_color": Color(0.4, 0.25, 0.15),
		"tree_density": 0.0, "rock_density": 0.3,
		"grass_density": 0.0, "decoration_density": 0.2,
		"has_heat_damage": true, "heat_dps": 3.0,
	})

	# Plague Lands
	_register_biome(Enums.BiomeType.PLAGUE_LANDS, {
		"display_name": "Plague Lands",
		"height_min": 0.35, "height_max": 0.50,
		"temperature_min": 0.4, "temperature_max": 0.7,
		"corruption_min": 0.7, "corruption_max": 1.0,
		"moisture_min": 0.2, "moisture_max": 0.5,
		"difficulty_level": 3, "difficulty_multiplier": 2.0,
		"loot_bonus_multiplier": 1.5,
		"enemy_level_min": 30, "enemy_level_max": 50,
		"tint_color": Color(0.7, 0.8, 0.5),
		"ground_color": Color(0.35, 0.4, 0.15),
		"tree_density": 0.05, "rock_density": 0.15,
		"grass_density": 0.0, "decoration_density": 0.3,
		"corruption_dps": 1.0,
		"fog_chance": 0.3,
	})


func _register_biome(biome_type: Enums.BiomeType, data: Dictionary) -> void:
	var biome := BiomeData.new()
	biome.biome_type = biome_type
	biome.display_name = data.get("display_name", "")
	biome.height_min = data.get("height_min", 0.0)
	biome.height_max = data.get("height_max", 1.0)
	biome.temperature_min = data.get("temperature_min", 0.0)
	biome.temperature_max = data.get("temperature_max", 1.0)
	biome.corruption_min = data.get("corruption_min", 0.0)
	biome.corruption_max = data.get("corruption_max", 1.0)
	biome.moisture_min = data.get("moisture_min", 0.0)
	biome.moisture_max = data.get("moisture_max", 1.0)
	biome.difficulty_level = data.get("difficulty_level", 0)
	biome.difficulty_multiplier = data.get("difficulty_multiplier", 1.0)
	biome.loot_bonus_multiplier = data.get("loot_bonus_multiplier", 1.0)
	biome.enemy_level_min = data.get("enemy_level_min", 1)
	biome.enemy_level_max = data.get("enemy_level_max", 10)
	biome.tint_color = data.get("tint_color", Color.WHITE)
	biome.ground_color = data.get("ground_color", Color(0.3, 0.7, 0.2))
	biome.tree_density = data.get("tree_density", 0.3)
	biome.rock_density = data.get("rock_density", 0.1)
	biome.grass_density = data.get("grass_density", 0.5)
	biome.decoration_density = data.get("decoration_density", 0.2)
	biome.fog_chance = data.get("fog_chance", 0.0)
	biome.snow_chance = data.get("snow_chance", 0.0)
	biome.has_cold_damage = data.get("has_cold_damage", false)
	biome.has_heat_damage = data.get("has_heat_damage", false)
	biome.cold_dps = data.get("cold_dps", 0.0)
	biome.heat_dps = data.get("heat_dps", 0.0)
	biome.corruption_dps = data.get("corruption_dps", 0.0)
	biome_registry[biome_type] = biome


## Fő biome kiválasztás - a plan 4.2 szekció algoritmusa
func get_biome(x: int, y: int, noise_mgr: NoiseManager) -> Enums.BiomeType:
	var h: float = noise_mgr.get_height(x, y)
	var t: float = noise_mgr.get_temperature(x, y)
	var c: float = noise_mgr.get_corruption(x, y)
	var m: float = noise_mgr.get_moisture(x, y)

	# Víz és hegy ellenőrzés
	if h < DEEP_WATER_THRESHOLD:
		return Enums.BiomeType.STARTING_MEADOW  # Deep water placeholder
	if h < SHALLOW_WATER_THRESHOLD:
		return Enums.BiomeType.DARK_SWAMP  # Shallow water → swamp-like
	if h > MOUNTAIN_PEAK_THRESHOLD:
		return Enums.BiomeType.MOUNTAINS  # Mountain peak
	if h > MOUNTAIN_THRESHOLD:
		return Enums.BiomeType.MOUNTAINS

	# Starting area protection (spawn pont körül)
	var dist_from_spawn: float = Vector2(x, y).distance_to(spawn_point)
	if dist_from_spawn < SPAWN_PROTECTION_RADIUS and c < 0.3:
		return Enums.BiomeType.STARTING_MEADOW

	# Corruption-based biomes
	if c > 0.7:
		return Enums.BiomeType.PLAGUE_LANDS
	if c > 0.4 and m > 0.4 and h < 0.6:
		return Enums.BiomeType.CURSED_FOREST

	# Temperature-based
	if t < 0.2:
		return Enums.BiomeType.FROZEN_WASTES
	if t > 0.8 and m < 0.2:
		return Enums.BiomeType.ASHLANDS

	# Moisture-based
	if m > 0.7 and h < 0.45:
		return Enums.BiomeType.DARK_SWAMP

	# Default
	if c > 0.3:
		return Enums.BiomeType.RUINS
	return Enums.BiomeType.STARTING_MEADOW


## Biome adat lekérdezés
func get_biome_data(biome_type: Enums.BiomeType) -> BiomeData:
	if biome_type in biome_registry:
		return biome_registry[biome_type]
	return biome_registry.get(Enums.BiomeType.STARTING_MEADOW, null)


## Biome átmenet számítás (transition zone)
## Visszaad egy Dictionary-t a szomszédos biome-ok súlyaival
func get_biome_blend(x: int, y: int, noise_mgr: NoiseManager, radius: int = 2) -> Dictionary:
	var biome_weights: Dictionary = {}
	var total_weight: float = 0.0

	for dx in range(-radius, radius + 1):
		for dy in range(-radius, radius + 1):
			var sample_biome: Enums.BiomeType = get_biome(x + dx, y + dy, noise_mgr)
			var dist: float = Vector2(dx, dy).length()
			var weight: float = maxf(0.0, 1.0 - dist / (radius + 1.0))

			if sample_biome in biome_weights:
				biome_weights[sample_biome] += weight
			else:
				biome_weights[sample_biome] = weight
			total_weight += weight

	# Normalizálás
	if total_weight > 0.0:
		for biome_key in biome_weights:
			biome_weights[biome_key] /= total_weight

	return biome_weights


## Domináns biome a blend-ből
func get_dominant_biome(biome_weights: Dictionary) -> Enums.BiomeType:
	var best_biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW
	var best_weight: float = 0.0

	for biome_key in biome_weights:
		if biome_weights[biome_key] > best_weight:
			best_weight = biome_weights[biome_key]
			best_biome = biome_key

	return best_biome

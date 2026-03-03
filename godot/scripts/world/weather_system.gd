## WeatherSystem - Időjárás rendszer
## Biome-specifikus időjárás, particle effektek, gameplay módosítók
class_name WeatherSystem
extends Node

signal weather_changed(old_weather: Enums.WeatherType, new_weather: Enums.WeatherType)
signal weather_intensity_changed(intensity: float)

# === Aktuális állapot ===
var current_weather: Enums.WeatherType = Enums.WeatherType.CLEAR
var target_weather: Enums.WeatherType = Enums.WeatherType.CLEAR
var weather_intensity: float = 0.0  # 0.0 - 1.0
var transition_speed: float = 0.5  # Mennyi idő alatt vált

# === Timing ===
var weather_timer: float = 0.0
var weather_duration: float = 0.0
var min_weather_duration: float = 60.0
var max_weather_duration: float = 300.0

# === Biome-specifikus időjárás esélyek ===
const BIOME_WEATHER_CHANCES: Dictionary = {
	Enums.BiomeType.STARTING_MEADOW: {
		Enums.WeatherType.CLEAR: 50.0,
		Enums.WeatherType.CLOUDY: 25.0,
		Enums.WeatherType.RAIN: 20.0,
		Enums.WeatherType.FOG: 5.0,
	},
	Enums.BiomeType.CURSED_FOREST: {
		Enums.WeatherType.CLEAR: 20.0,
		Enums.WeatherType.CLOUDY: 20.0,
		Enums.WeatherType.RAIN: 25.0,
		Enums.WeatherType.FOG: 30.0,
		Enums.WeatherType.STORM: 5.0,
	},
	Enums.BiomeType.DARK_SWAMP: {
		Enums.WeatherType.CLEAR: 10.0,
		Enums.WeatherType.FOG: 45.0,
		Enums.WeatherType.RAIN: 30.0,
		Enums.WeatherType.STORM: 15.0,
	},
	Enums.BiomeType.ANCIENT_RUINS: {
		Enums.WeatherType.CLEAR: 35.0,
		Enums.WeatherType.CLOUDY: 30.0,
		Enums.WeatherType.RAIN: 15.0,
		Enums.WeatherType.FOG: 15.0,
		Enums.WeatherType.STORM: 5.0,
	},
	Enums.BiomeType.HAUNTED_MOUNTAINS: {
		Enums.WeatherType.CLEAR: 20.0,
		Enums.WeatherType.CLOUDY: 15.0,
		Enums.WeatherType.SNOW: 30.0,
		Enums.WeatherType.STORM: 20.0,
		Enums.WeatherType.FOG: 15.0,
	},
	Enums.BiomeType.FROZEN_WASTES: {
		Enums.WeatherType.CLEAR: 15.0,
		Enums.WeatherType.SNOW: 50.0,
		Enums.WeatherType.STORM: 25.0,
		Enums.WeatherType.FOG: 10.0,
	},
	Enums.BiomeType.ASHLANDS: {
		Enums.WeatherType.CLEAR: 25.0,
		Enums.WeatherType.ASH_STORM: 40.0,
		Enums.WeatherType.FOG: 20.0,
		Enums.WeatherType.STORM: 15.0,
	},
	Enums.BiomeType.PLAGUE_LANDS: {
		Enums.WeatherType.CLEAR: 10.0,
		Enums.WeatherType.FOG: 35.0,
		Enums.WeatherType.RAIN: 25.0,
		Enums.WeatherType.STORM: 20.0,
		Enums.WeatherType.ASH_STORM: 10.0,
	},
}

# === Gameplay módosítók időjárás szerint ===
const WEATHER_MODIFIERS: Dictionary = {
	Enums.WeatherType.CLEAR: {"move_speed": 1.0, "visibility": 1.0, "damage": 1.0},
	Enums.WeatherType.CLOUDY: {"move_speed": 1.0, "visibility": 0.9, "damage": 1.0},
	Enums.WeatherType.RAIN: {"move_speed": 0.95, "visibility": 0.75, "damage": 1.0},
	Enums.WeatherType.FOG: {"move_speed": 1.0, "visibility": 0.5, "damage": 1.0},
	Enums.WeatherType.STORM: {"move_speed": 0.85, "visibility": 0.6, "damage": 1.1},
	Enums.WeatherType.SNOW: {"move_speed": 0.9, "visibility": 0.7, "damage": 1.0},
	Enums.WeatherType.ASH_STORM: {"move_speed": 0.8, "visibility": 0.4, "damage": 1.15},
}

var current_biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW
var particle_node: GPUParticles2D = null


func _ready() -> void:
	_roll_new_weather()


func _process(delta: float) -> void:
	# Weather duration
	weather_timer += delta
	if weather_timer >= weather_duration:
		weather_timer = 0.0
		_roll_new_weather()
	
	# Intensity transition
	if current_weather != target_weather:
		weather_intensity -= delta * transition_speed
		if weather_intensity <= 0.0:
			var old := current_weather
			current_weather = target_weather
			weather_intensity = 0.0
			weather_changed.emit(old, current_weather)
	
	if current_weather == target_weather and weather_intensity < 1.0:
		weather_intensity = minf(weather_intensity + delta * transition_speed, 1.0)
		weather_intensity_changed.emit(weather_intensity)
	
	_update_particles()


## Biome változásnál hívandó
func set_biome(biome: Enums.BiomeType) -> void:
	if biome != current_biome:
		current_biome = biome
		_roll_new_weather()


## Új időjárás kiválasztása
func _roll_new_weather() -> void:
	var chances: Dictionary = BIOME_WEATHER_CHANCES.get(
		current_biome,
		{Enums.WeatherType.CLEAR: 100.0}
	)
	
	var total: float = 0.0
	for w in chances.values():
		total += w
	
	var roll := randf() * total
	var cumulative: float = 0.0
	
	for weather_type in chances:
		cumulative += chances[weather_type]
		if roll <= cumulative:
			target_weather = weather_type
			break
	
	weather_duration = randf_range(min_weather_duration, max_weather_duration)
	weather_timer = 0.0


## Particle frissítés
func _update_particles() -> void:
	if not particle_node:
		return
	
	particle_node.emitting = weather_intensity > 0.1 and current_weather != Enums.WeatherType.CLEAR
	
	# Particle szám az intenzitás alapján
	if particle_node.emitting:
		particle_node.amount = int(50 * weather_intensity)


## Aktuális gameplay módosítók
func get_modifiers() -> Dictionary:
	return WEATHER_MODIFIERS.get(
		current_weather,
		{"move_speed": 1.0, "visibility": 1.0, "damage": 1.0}
	)


## Move speed modifier
func get_move_speed_modifier() -> float:
	var mods := get_modifiers()
	return lerpf(1.0, mods.get("move_speed", 1.0), weather_intensity)


## Visibility modifier
func get_visibility_modifier() -> float:
	var mods := get_modifiers()
	return lerpf(1.0, mods.get("visibility", 1.0), weather_intensity)


## Multiplayer szinkronizáció
func sync_weather(weather: Enums.WeatherType, intensity: float) -> void:
	current_weather = weather
	target_weather = weather
	weather_intensity = intensity

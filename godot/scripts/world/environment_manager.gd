## EnvironmentManager - Biome-specifikus ambient, időjárás, nap/éjszaka ciklus
## CanvasModulate tint, particle-ök, időjárás rendszer
class_name EnvironmentManager
extends Node

# Referenciák (futásidőben beállítva)
var canvas_modulate: CanvasModulate = null
var ambient_particles: GPUParticles2D = null

# Aktuális biome
var current_biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW
var current_weather: Enums.WeatherType = Enums.WeatherType.CLEAR

# === Nap/éjszaka ciklus ===
var day_night_enabled: bool = true
var game_time: float = 480.0  # Játék percekben (8:00 = reggel)
var time_speed: float = 1.0  # Valós mp → játék perc szorzó
const FULL_DAY_MINUTES: float = 1440.0  # 24 óra percben
const REAL_SECONDS_PER_DAY: float = 1200.0  # 20 perc valós idő = 1 nap

# Nap/éjszaka fázis színek
const DAWN_COLOR: Color = Color(0.8, 0.7, 0.5)      # 05:00
const DAY_COLOR: Color = Color(1.0, 1.0, 1.0)        # 08:00
const DUSK_COLOR: Color = Color(0.9, 0.6, 0.4)       # 18:00
const NIGHT_COLOR: Color = Color(0.3, 0.3, 0.5)      # 21:00
const MIDNIGHT_COLOR: Color = Color(0.15, 0.15, 0.3)  # 00:00

var is_night: bool = false
var previous_is_night: bool = false

# === Időjárás ===
var weather_timer: float = 0.0
var weather_duration: float = 120.0  # Másodpercben
var weather_change_chance: float = 0.1  # Esélye, hogy változik

# Biome tint override
var biome_tint: Color = Color.WHITE

# Biome resolver referencia
var biome_resolver: BiomeResolver


func initialize(p_biome_resolver: BiomeResolver) -> void:
	biome_resolver = p_biome_resolver
	time_speed = FULL_DAY_MINUTES / REAL_SECONDS_PER_DAY  # ~1.2 game min / real sec


func setup_nodes(p_canvas_modulate: CanvasModulate, p_particles: GPUParticles2D = null) -> void:
	canvas_modulate = p_canvas_modulate
	ambient_particles = p_particles


func _process(delta: float) -> void:
	if day_night_enabled:
		_update_day_night(delta)

	_update_weather(delta)
	_apply_environment()


## Nap/éjszaka ciklus frissítése
func _update_day_night(delta: float) -> void:
	game_time += delta * time_speed
	if game_time >= FULL_DAY_MINUTES:
		game_time -= FULL_DAY_MINUTES

	# Éjszaka állapot frissítés
	previous_is_night = is_night
	is_night = game_time < 300.0 or game_time > 1260.0  # 21:00 - 05:00

	if is_night != previous_is_night:
		EventBus.day_night_changed.emit(is_night)


## Aktuális nap szín kiszámítása
func _get_day_night_color() -> Color:
	var hour: float = game_time / 60.0  # 0-24

	if hour < 5.0:
		# Éjfél → hajnal
		return MIDNIGHT_COLOR.lerp(DAWN_COLOR, hour / 5.0)
	elif hour < 8.0:
		# Hajnal → nappal
		return DAWN_COLOR.lerp(DAY_COLOR, (hour - 5.0) / 3.0)
	elif hour < 18.0:
		# Nappal
		return DAY_COLOR
	elif hour < 21.0:
		# Nappal → alkony → éjszaka
		var t: float = (hour - 18.0) / 3.0
		if t < 0.5:
			return DAY_COLOR.lerp(DUSK_COLOR, t * 2.0)
		else:
			return DUSK_COLOR.lerp(NIGHT_COLOR, (t - 0.5) * 2.0)
	else:
		# Éjszaka → éjfél
		return NIGHT_COLOR.lerp(MIDNIGHT_COLOR, (hour - 21.0) / 3.0)


## Időjárás frissítés
func _update_weather(delta: float) -> void:
	weather_timer += delta
	if weather_timer >= weather_duration:
		weather_timer = 0.0
		_try_change_weather()


## Időjárás változtatás
func _try_change_weather() -> void:
	var biome_data: BiomeData = null
	if biome_resolver:
		biome_data = biome_resolver.get_biome_data(current_biome)

	if not biome_data:
		return

	var roll: float = randf()

	if roll < biome_data.snow_chance:
		_set_weather(Enums.WeatherType.SNOW)
	elif roll < biome_data.snow_chance + biome_data.fog_chance:
		_set_weather(Enums.WeatherType.FOG)
	elif roll < biome_data.snow_chance + biome_data.fog_chance + biome_data.rain_chance:
		_set_weather(Enums.WeatherType.RAIN)
	else:
		_set_weather(Enums.WeatherType.CLEAR)


func _set_weather(weather: Enums.WeatherType) -> void:
	if weather == current_weather:
		return
	current_weather = weather
	weather_duration = randf_range(60.0, 180.0)
	EventBus.weather_changed.emit(weather)


## Környezet alkalmazása (szín + particle)
func _apply_environment() -> void:
	if not canvas_modulate:
		return

	# Alap nap/éjszaka szín
	var day_color: Color = _get_day_night_color()

	# Biome tint alkalmazása
	var final_color: Color = Color(
		day_color.r * biome_tint.r,
		day_color.g * biome_tint.g,
		day_color.b * biome_tint.b,
	)

	# Időjárás hatás
	match current_weather:
		Enums.WeatherType.RAIN:
			final_color = final_color.darkened(0.15)
		Enums.WeatherType.STORM:
			final_color = final_color.darkened(0.25)
		Enums.WeatherType.FOG:
			final_color = final_color.lerp(Color(0.7, 0.7, 0.7), 0.3)
		Enums.WeatherType.SNOW:
			final_color = final_color.lerp(Color(0.9, 0.9, 1.0), 0.2)

	canvas_modulate.color = final_color


## Biome változásnál hívandó
func on_biome_changed(new_biome: Enums.BiomeType) -> void:
	if new_biome == current_biome:
		return

	current_biome = new_biome

	var biome_data: BiomeData = null
	if biome_resolver:
		biome_data = biome_resolver.get_biome_data(new_biome)

	if biome_data:
		biome_tint = biome_data.tint_color
	else:
		biome_tint = Color.WHITE

	EventBus.biome_entered.emit(null, new_biome)

	# Időjárás alapértelmezés a biome-hoz
	_try_change_weather()


## Játék idő formázás (HH:MM)
func get_time_string() -> String:
	var hours: int = int(game_time / 60.0) % 24
	var minutes: int = int(game_time) % 60
	return "%02d:%02d" % [hours, minutes]


## Aktuális óra (0-23)
func get_hour() -> int:
	return int(game_time / 60.0) % 24


## Éjszaka-e
func get_is_night() -> bool:
	return is_night

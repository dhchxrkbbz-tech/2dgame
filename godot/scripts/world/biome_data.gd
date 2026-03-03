## BiomeData - Resource: biome tulajdonságok definíció
## Minden biome-hoz tartozó adatokat tartalmazza
class_name BiomeData
extends Resource

@export var biome_type: Enums.BiomeType
@export var display_name: String = ""
@export var description: String = ""

# === Noise tartományok ===
@export_group("Noise Ranges")
@export var height_min: float = 0.0
@export var height_max: float = 1.0
@export var temperature_min: float = 0.0
@export var temperature_max: float = 1.0
@export var corruption_min: float = 0.0
@export var corruption_max: float = 1.0
@export var moisture_min: float = 0.0
@export var moisture_max: float = 1.0

# === Nehézség és loot ===
@export_group("Difficulty")
@export var difficulty_level: int = 0  # 0-3
@export var difficulty_multiplier: float = 1.0
@export var loot_bonus_multiplier: float = 1.0
@export var enemy_level_min: int = 1
@export var enemy_level_max: int = 10

# === Vizuális ===
@export_group("Visuals")
@export var tint_color: Color = Color(1, 1, 1, 1)
@export var ground_color: Color = Color(0.3, 0.7, 0.2)
@export var fog_color: Color = Color(0.5, 0.5, 0.5, 0.0)
@export var ambient_light_energy: float = 1.0

# === Dekoráció sűrűség ===
@export_group("Decoration")
@export var tree_density: float = 0.3  # 0.0-1.0
@export var rock_density: float = 0.1
@export var grass_density: float = 0.5
@export var decoration_density: float = 0.2

# === Időjárás ===
@export_group("Weather")
@export var default_weather: Enums.WeatherType = Enums.WeatherType.CLEAR
@export var rain_chance: float = 0.1
@export var fog_chance: float = 0.0
@export var snow_chance: float = 0.0

# === Környezeti hatások ===
@export_group("Environment Effects")
@export var has_cold_damage: bool = false
@export var has_heat_damage: bool = false
@export var cold_dps: float = 0.0
@export var heat_dps: float = 0.0
@export var corruption_dps: float = 0.0

# === Audio ===
@export_group("Audio")
@export var music_track: String = ""
@export var ambient_sounds: PackedStringArray = []


## Ellenőrzi, hogy a noise értékek megfelelnek-e ennek a biome-nak
func matches(height: float, temp: float, corruption: float, moisture: float) -> bool:
	return (
		height >= height_min and height <= height_max
		and temp >= temperature_min and temp <= temperature_max
		and corruption >= corruption_min and corruption <= corruption_max
		and moisture >= moisture_min and moisture <= moisture_max
	)


## Match pontosság számítás (mennyire jól passzol a biome)
func get_match_score(height: float, temp: float, corruption: float, moisture: float) -> float:
	if not matches(height, temp, corruption, moisture):
		return -1.0

	# Mennyire van az értékek közepén (jobb = magasabb score)
	var h_center: float = (height_min + height_max) / 2.0
	var t_center: float = (temperature_min + temperature_max) / 2.0
	var c_center: float = (corruption_min + corruption_max) / 2.0
	var m_center: float = (moisture_min + moisture_max) / 2.0

	var h_score: float = 1.0 - absf(height - h_center) / maxf((height_max - height_min) / 2.0, 0.01)
	var t_score: float = 1.0 - absf(temp - t_center) / maxf((temperature_max - temperature_min) / 2.0, 0.01)
	var c_score: float = 1.0 - absf(corruption - c_center) / maxf((corruption_max - corruption_min) / 2.0, 0.01)
	var m_score: float = 1.0 - absf(moisture - m_center) / maxf((moisture_max - moisture_min) / 2.0, 0.01)

	return (h_score + t_score + c_score + m_score) / 4.0

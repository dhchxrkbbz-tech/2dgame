## WorldEventData - Egy world event adatszerkezete
## Tartalmazza az event típust, paramétereit és állapotát
class_name WorldEventData
extends RefCounted


## Event típus
var event_type: Enums.WorldEventType = Enums.WorldEventType.CORRUPTION_SURGE

## Egyedi event ID (runtime generált)
var event_id: String = ""

## Event pozíció (világ koordináták)
var position: Vector2 = Vector2.ZERO

## Érintett terület sugara (tile-okban)
var radius: float = 64.0

## Event időtartam (másodperc)
var duration: float = 600.0  # 10 perc alapértelmezett

## Hátralévő idő
var time_remaining: float = 0.0

## Event állapot
var is_active: bool = false
var is_announced: bool = false
var is_completed: bool = false

## Résztvevő játékosok
var participants: Array[int] = []  # peer_id-k

## Event-specifikus adatok
var event_params: Dictionary = {}


## Event típus konfiguráció
const EVENT_CONFIG: Dictionary = {
	Enums.WorldEventType.CORRUPTION_SURGE: {
		"name": "Corruption Surge",
		"description": "Kijelölt területen megnőtt a korrupció! Több elite enemy, jobb loot.",
		"duration": 600.0,  # 10 perc
		"radius": 80.0,
		"reward_de_min": 20,
		"reward_de_max": 30,
		"reward_gold_min": 100,
		"reward_gold_max": 300,
		"corruption_bonus": 0.50,
		"elite_spawn_bonus": 2.0,
		"loot_bonus": 0.30,
		"announcement_time": 30.0,  # 30s figyelmeztetés
		"color": Color(0.6, 0.0, 0.8),
	},
	Enums.WorldEventType.INVASION: {
		"name": "Invasion",
		"description": "Enemy hullám támadja meg a falut! Védd meg!",
		"duration": 900.0,  # 15 perc
		"radius": 48.0,
		"reward_de_min": 15,
		"reward_de_max": 25,
		"reward_gold_min": 200,
		"reward_gold_max": 500,
		"wave_count": 5,
		"enemies_per_wave": 10,
		"wave_interval": 60.0,
		"announcement_time": 60.0,
		"color": Color(0.9, 0.2, 0.1),
	},
	Enums.WorldEventType.WORLD_BOSS_SPAWN: {
		"name": "World Boss",
		"description": "Egy hatalmas szörny jelent meg a világon!",
		"duration": 900.0,  # 15 perc
		"radius": 64.0,
		"reward_de_min": 30,
		"reward_de_max": 50,
		"reward_gold_min": 500,
		"reward_gold_max": 1000,
		"boss_level_bonus": 5,
		"announcement_time": 60.0,
		"color": Color(1.0, 0.3, 0.0),
	},
	Enums.WorldEventType.TREASURE_HUNT: {
		"name": "Treasure Hunt",
		"description": "3 rejtett kincsesláda jelent meg a világon!",
		"duration": 1200.0,  # 20 perc
		"radius": 0.0,  # Global
		"reward_gold_min": 300,
		"reward_gold_max": 800,
		"chest_count": 3,
		"minimap_hint_radius": 100.0,
		"announcement_time": 15.0,
		"color": Color(0.9, 0.8, 0.1),
	},
	Enums.WorldEventType.GATHERING_BLESSING: {
		"name": "Gathering Blessing",
		"description": "Egy biome-ban dupla resource yield 15 percig!",
		"duration": 900.0,
		"radius": 128.0,
		"yield_multiplier": 2.0,
		"announcement_time": 15.0,
		"color": Color(0.2, 0.9, 0.3),
	},
	Enums.WorldEventType.BLOOD_MOON: {
		"name": "Blood Moon",
		"description": "Tartós sötétség! +100% enemy spawn, +50% enemy damage, de +100% XP és +50% magic find!",
		"duration": 1800.0,  # 30 perc
		"radius": 0.0,  # Global
		"reward_de_min": 15,
		"reward_de_max": 20,
		"enemy_spawn_bonus": 1.0,
		"enemy_damage_bonus": 0.50,
		"xp_bonus": 1.0,
		"magic_find_bonus": 0.50,
		"announcement_time": 30.0,
		"color": Color(0.8, 0.1, 0.1),
	},
}


## Factory: létrehozás típus alapján
static func create(type: Enums.WorldEventType, pos: Vector2 = Vector2.ZERO) -> WorldEventData:
	var event := WorldEventData.new()
	event.event_type = type
	event.event_id = "%d_%d" % [type, Time.get_ticks_msec()]
	event.position = pos
	
	var config: Dictionary = EVENT_CONFIG.get(type, {})
	event.duration = config.get("duration", 600.0)
	event.time_remaining = event.duration
	event.radius = config.get("radius", 64.0)
	event.event_params = config.duplicate()
	
	return event


## Konfig lekérdezés
func get_config() -> Dictionary:
	return EVENT_CONFIG.get(event_type, {})


## Név lekérdezés
func get_name() -> String:
	var config := get_config()
	return config.get("name", "Unknown Event")


## Leírás lekérdezés
func get_description() -> String:
	var config := get_config()
	return config.get("description", "")


## Szín lekérdezés (UI/minimap)
func get_color() -> Color:
	var config := get_config()
	return config.get("color", Color.WHITE)


## Hátralévő idő százalékban
func get_time_ratio() -> float:
	if duration <= 0:
		return 0.0
	return clampf(time_remaining / duration, 0.0, 1.0)


## Participant hozzáadás
func add_participant(peer_id: int) -> void:
	if peer_id not in participants:
		participants.append(peer_id)


## Jutalom kiszámítása részvétel alapján
func calculate_rewards() -> Dictionary:
	var config := get_config()
	var rewards: Dictionary = {
		"dark_essence": randi_range(
			config.get("reward_de_min", 0),
			config.get("reward_de_max", 0)
		),
		"gold": randi_range(
			config.get("reward_gold_min", 0),
			config.get("reward_gold_max", 0)
		),
		"xp_bonus": config.get("xp_bonus", 0.0),
	}
	return rewards


## Serializálás (multiplayer sync)
func serialize_for_network() -> Dictionary:
	return {
		"event_id": event_id,
		"event_type": event_type,
		"position_x": position.x,
		"position_y": position.y,
		"time_remaining": time_remaining,
		"duration": duration,
		"is_active": is_active,
		"participants": participants,
	}


## Deserializálás (multiplayer sync)
static func from_network(data: Dictionary) -> WorldEventData:
	var event := WorldEventData.new()
	event.event_id = data.get("event_id", "")
	event.event_type = data.get("event_type", 0) as Enums.WorldEventType
	event.position = Vector2(data.get("position_x", 0), data.get("position_y", 0))
	event.time_remaining = data.get("time_remaining", 0)
	event.duration = data.get("duration", 600)
	event.is_active = data.get("is_active", false)
	event.participants = data.get("participants", [])
	
	var config: Dictionary = EVENT_CONFIG.get(event.event_type, {})
	event.radius = config.get("radius", 64.0)
	event.event_params = config.duplicate()
	
	return event

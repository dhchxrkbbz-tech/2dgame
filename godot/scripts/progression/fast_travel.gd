## FastTravel - Waypoint management és teleport logika (Autoload singleton)
## Waypoint-ok felfedezése, célpont kiválasztás, teleportálás
extends Node

# === Felfedezett waypoint-ok ===
# id → {name, position, biome, is_dungeon, is_boss_arena}
var _waypoints: Dictionary = {}

# === Cooldown ===
var _cooldown_remaining: float = 0.0
var _is_traveling: bool = false

# === Teleport animáció timer ===
var _teleport_timer: Timer = null


func _ready() -> void:
	_teleport_timer = Timer.new()
	_teleport_timer.one_shot = true
	_teleport_timer.timeout.connect(_complete_teleport)
	add_child(_teleport_timer)
	
	# Signal-ok
	EventBus.waypoint_discovered.connect(_on_waypoint_discovered_external)
	
	print("FastTravel: Inicializálva")


func _process(delta: float) -> void:
	if _cooldown_remaining > 0:
		_cooldown_remaining -= delta
		if _cooldown_remaining < 0:
			_cooldown_remaining = 0


# ==========================================================================
#  WAYPOINT KEZELÉS
# ==========================================================================

## Waypoint regisztrálás (world generator hívja)
func register_waypoint(wp_id: String, data: Dictionary) -> void:
	if _waypoints.has(wp_id):
		return  # Már regisztrálva
	
	_waypoints[wp_id] = {
		"name": data.get("name", "Unknown Waypoint"),
		"position": data.get("position", Vector2.ZERO),
		"biome": data.get("biome", Enums.BiomeType.STARTING_MEADOW),
		"is_dungeon": data.get("is_dungeon", false),
		"is_boss_arena": data.get("is_boss_arena", false),
		"discovered": data.get("discovered", false),
	}


## Waypoint felfedezése (játékos interakcióval)
func discover_waypoint(wp_id: String) -> bool:
	if not _waypoints.has(wp_id):
		push_warning("FastTravel: Ismeretlen waypoint: " + wp_id)
		return false
	
	if _waypoints[wp_id]["discovered"]:
		return false  # Már felfedezve
	
	_waypoints[wp_id]["discovered"] = true
	
	var wp_name: String = _waypoints[wp_id]["name"]
	
	EventBus.waypoint_discovered.emit(wp_id, wp_name)
	EventBus.show_notification.emit(
		"Waypoint felfedezve: %s" % wp_name,
		Enums.NotificationType.INFO
	)
	
	print("FastTravel: Waypoint felfedezve – '%s'" % wp_name)
	return true


## Felfedezett waypoint-ok listája
func get_discovered_waypoints() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for wp_id in _waypoints:
		var wp: Dictionary = _waypoints[wp_id]
		if wp["discovered"]:
			var entry := wp.duplicate()
			entry["id"] = wp_id
			result.append(entry)
	return result


## Összes waypoint (térkép UI-hoz)
func get_all_waypoints() -> Dictionary:
	return _waypoints


## Waypoint lekérdezés ID alapján
func get_waypoint(wp_id: String) -> Dictionary:
	return _waypoints.get(wp_id, {})


# ==========================================================================
#  TELEPORTÁLÁS
# ==========================================================================

## Fast travel indítása célpontra
func travel_to(destination_id: String) -> bool:
	# Előfeltételek ellenőrzése
	if not _can_travel():
		return false
	
	if not _waypoints.has(destination_id):
		EventBus.show_notification.emit(
			"Ismeretlen célpont!",
			Enums.NotificationType.ERROR
		)
		return false
	
	var wp: Dictionary = _waypoints[destination_id]
	if not wp.get("discovered", false):
		EventBus.show_notification.emit(
			"Waypoint nem felfedezve!",
			Enums.NotificationType.WARNING
		)
		return false
	
	# Költség kiszámítása
	var cost := _calculate_travel_cost(destination_id)
	
	# Gold ellenőrzés
	# TODO: Integrálni az EconomyManager-rel
	# if EconomyManager.get_gold() < cost:
	#     EventBus.show_notification.emit("Nincs elég gold! (%d szükséges)" % cost, ...)
	#     return false
	
	# Utazás indítása
	_is_traveling = true
	EventBus.fast_travel_started.emit(destination_id)
	
	EventBus.show_notification.emit(
		"Teleportálás: %s... (%d gold)" % [wp["name"], cost],
		Enums.NotificationType.INFO
	)
	
	# Teleport timer indítása
	_teleport_timer.start(Constants.FAST_TRAVEL_TELEPORT_DURATION)
	
	# Eltároljuk a célt
	set_meta("_travel_destination", destination_id)
	set_meta("_travel_cost", cost)
	
	print("FastTravel: Utazás indítva → '%s' (%d gold)" % [wp["name"], cost])
	return true


## Teleport befejezése
func _complete_teleport() -> void:
	if not _is_traveling:
		return
	
	var destination_id: String = get_meta("_travel_destination", "")
	var cost: int = get_meta("_travel_cost", 0)
	
	if not _waypoints.has(destination_id):
		_cancel_travel()
		return
	
	var wp: Dictionary = _waypoints[destination_id]
	var target_pos: Vector2 = wp.get("position", Vector2.ZERO)
	
	# Gold levonás
	# TODO: EconomyManager.spend_gold(cost)
	
	# Játékos teleportálása
	var player := GameManager.player
	if player:
		player.global_position = target_pos
	
	_is_traveling = false
	_cooldown_remaining = Constants.FAST_TRAVEL_COOLDOWN
	
	EventBus.fast_travel_completed.emit(destination_id)
	
	EventBus.show_notification.emit(
		"Megérkeztél: %s" % wp["name"],
		Enums.NotificationType.INFO
	)
	
	print("FastTravel: Megérkezés → '%s'" % wp["name"])


## Utazás megszakítása
func cancel_travel() -> void:
	_cancel_travel()


func _cancel_travel() -> void:
	_is_traveling = false
	_teleport_timer.stop()
	EventBus.fast_travel_cancelled.emit()
	
	EventBus.show_notification.emit(
		"Teleportálás megszakítva!",
		Enums.NotificationType.WARNING
	)


# ==========================================================================
#  ELLENŐRZÉSEK
# ==========================================================================

## Lehet-e jelenleg utazni?
func _can_travel() -> bool:
	# Cooldown ellenőrzés
	if _cooldown_remaining > 0:
		EventBus.show_notification.emit(
			"Fast Travel cooldown: %.0fs" % _cooldown_remaining,
			Enums.NotificationType.WARNING
		)
		return false
	
	# Már utazás közben
	if _is_traveling:
		EventBus.show_notification.emit(
			"Már folyamatban van egy teleportálás!",
			Enums.NotificationType.WARNING
		)
		return false
	
	# Nem combat közben
	# TODO: Combat state ellenőrzés
	# if CombatManager.is_in_combat():
	#     return false
	
	# Nem dungeon belsejében
	# TODO: Dungeon state ellenőrzés
	
	# Játék fut?
	if not GameManager.is_playing():
		return false
	
	return true


## Utazási költség kiszámítása (távolság alapú)
func _calculate_travel_cost(destination_id: String) -> int:
	var wp: Dictionary = _waypoints.get(destination_id, {})
	var target_pos: Vector2 = wp.get("position", Vector2.ZERO)
	
	var player := GameManager.player
	if not player:
		return Constants.FAST_TRAVEL_BASE_COST
	
	var distance := player.global_position.distance_to(target_pos)
	var chunks := int(distance / Constants.CHUNK_PIXEL_SIZE)
	
	return Constants.FAST_TRAVEL_BASE_COST + (chunks * Constants.FAST_TRAVEL_COST_PER_CHUNK)


## Cooldown hátralévő idő
func get_cooldown_remaining() -> float:
	return maxf(0.0, _cooldown_remaining)


## Utazás közben?
func is_traveling() -> bool:
	return _is_traveling


# ==========================================================================
#  EXTERNAL SIGNAL HANDLER
# ==========================================================================

func _on_waypoint_discovered_external(wp_id: String, _wp_name: String) -> void:
	# Ha a waypoint register-elve van de nem discovered, frissítjük
	if _waypoints.has(wp_id) and not _waypoints[wp_id]["discovered"]:
		_waypoints[wp_id]["discovered"] = true


# ==========================================================================
#  MENTÉS / BETÖLTÉS
# ==========================================================================

func serialize() -> Dictionary:
	var save_data: Dictionary = {}
	for wp_id in _waypoints:
		save_data[wp_id] = {
			"name": _waypoints[wp_id]["name"],
			"position_x": _waypoints[wp_id]["position"].x,
			"position_y": _waypoints[wp_id]["position"].y,
			"biome": _waypoints[wp_id]["biome"],
			"is_dungeon": _waypoints[wp_id]["is_dungeon"],
			"is_boss_arena": _waypoints[wp_id]["is_boss_arena"],
			"discovered": _waypoints[wp_id]["discovered"],
		}
	return save_data


func deserialize(data: Dictionary) -> void:
	for wp_id in data:
		var entry: Dictionary = data[wp_id]
		_waypoints[wp_id] = {
			"name": entry.get("name", "Unknown"),
			"position": Vector2(entry.get("position_x", 0), entry.get("position_y", 0)),
			"biome": entry.get("biome", Enums.BiomeType.STARTING_MEADOW),
			"is_dungeon": entry.get("is_dungeon", false),
			"is_boss_arena": entry.get("is_boss_arena", false),
			"discovered": entry.get("discovered", false),
		}
	
	var discovered_count: int = 0
	for wp_id in _waypoints:
		if _waypoints[wp_id]["discovered"]:
			discovered_count += 1
	
	print("FastTravel: %d waypoint betöltve (%d felfedezve)" % [
		_waypoints.size(), discovered_count
	])

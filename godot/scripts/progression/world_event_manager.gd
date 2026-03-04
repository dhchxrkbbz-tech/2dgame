## WorldEventManager - World event generálás és kezelés (Autoload singleton)
## Random világesemények kezelése: spawn, lifecycle, jutalom kiosztás
extends Node

# === Aktív event ===
var _active_event: WorldEventData = null

# === Event timer ===
var _next_event_timer: Timer = null
var _event_duration_timer: Timer = null
var _announcement_timer: Timer = null

# === Cooldown-ok típusonként ===
var _type_cooldowns: Dictionary = {}  # WorldEventType → float (remaining)

# === Event történelem ===
var _event_history: Array[Dictionary] = []

# === Invasion hullám kezelés ===
var _current_wave: int = 0
var _wave_timer: Timer = null

# === Aktív-e a rendszer ===
var _enabled: bool = false


func _ready() -> void:
	# Event generálás timer
	_next_event_timer = Timer.new()
	_next_event_timer.one_shot = true
	_next_event_timer.timeout.connect(_on_event_trigger)
	add_child(_next_event_timer)
	
	# Event duration timer
	_event_duration_timer = Timer.new()
	_event_duration_timer.one_shot = true
	_event_duration_timer.timeout.connect(_end_event)
	add_child(_event_duration_timer)
	
	# Announcement timer
	_announcement_timer = Timer.new()
	_announcement_timer.one_shot = true
	_announcement_timer.timeout.connect(_start_event_after_announcement)
	add_child(_announcement_timer)
	
	# Invasion wave timer
	_wave_timer = Timer.new()
	_wave_timer.one_shot = true
	_wave_timer.timeout.connect(_spawn_next_wave)
	add_child(_wave_timer)
	
	print("WorldEventManager: Inicializálva")


func _process(delta: float) -> void:
	# Cooldown-ok frissítése
	var expired: Array[int] = []
	for event_type in _type_cooldowns:
		_type_cooldowns[event_type] -= delta
		if _type_cooldowns[event_type] <= 0:
			expired.append(event_type)
	for et in expired:
		_type_cooldowns.erase(et)
	
	# Aktív event hátralévő idő
	if _active_event and _active_event.is_active:
		_active_event.time_remaining -= delta
		if fmod(_active_event.time_remaining, 5.0) < delta:  # 5 másodpercenként
			EventBus.world_event_progress.emit(
				_active_event.event_type,
				_active_event.get_time_ratio()
			)
		
		# Participant tracking: ha a player közelben van
		_update_participants()


# ==========================================================================
#  RENDSZER KONTROL
# ==========================================================================

## Rendszer bekapcsolása (játék indításakor)
func enable() -> void:
	_enabled = true
	_schedule_next_event()
	print("WorldEventManager: Event rendszer AKTÍV")


## Rendszer kikapcsolása
func disable() -> void:
	_enabled = false
	_next_event_timer.stop()
	if _active_event and _active_event.is_active:
		_end_event()
	print("WorldEventManager: Event rendszer LEÁLLÍTVA")


## Következő event ütemezése
func _schedule_next_event() -> void:
	if not _enabled:
		return
	
	var wait_time := randf_range(
		Constants.WORLD_EVENT_MIN_INTERVAL,
		Constants.WORLD_EVENT_MAX_INTERVAL
	)
	_next_event_timer.start(wait_time)
	print("WorldEventManager: Következő event %.0f másodperc múlva" % wait_time)


# ==========================================================================
#  EVENT GENERÁLÁS
# ==========================================================================

func _on_event_trigger() -> void:
	if not _enabled:
		return
	
	# Ha már van aktív event, ütemezzük újra
	if _active_event and _active_event.is_active:
		_schedule_next_event()
		return
	
	# Elérhető event típusok (cooldown alapján)
	var available_types: Array[int] = []
	for event_type in Enums.WorldEventType.values():
		if not _type_cooldowns.has(event_type):
			available_types.append(event_type)
	
	if available_types.is_empty():
		_schedule_next_event()
		return
	
	# Random event típus kiválasztása
	var chosen_type: int = available_types[randi() % available_types.size()]
	
	# Pozíció meghatározása
	var event_pos := _find_event_position(chosen_type as Enums.WorldEventType)
	
	# Event létrehozása
	_active_event = WorldEventData.create(chosen_type as Enums.WorldEventType, event_pos)
	
	# Announcement
	_announce_event()


## Event pozíció keresése
func _find_event_position(event_type: Enums.WorldEventType) -> Vector2:
	var player := GameManager.player
	if not player:
		return Vector2.ZERO
	
	var player_pos := player.global_position
	
	match event_type:
		Enums.WorldEventType.BLOOD_MOON, \
		Enums.WorldEventType.TREASURE_HUNT:
			# Globális event - pozíció nem számít
			return player_pos
		
		Enums.WorldEventType.INVASION:
			# Egy POI (falu) közelében
			# Fallback: random offset a player körül
			var offset := Vector2(
				randf_range(-2000, 2000),
				randf_range(-2000, 2000)
			)
			return player_pos + offset
		
		_:
			# Random terület a player körül (1000-3000 pixel)
			var angle := randf() * TAU
			var distance := randf_range(1000, 3000)
			return player_pos + Vector2.from_angle(angle) * distance


# ==========================================================================
#  EVENT LIFECYCLE
# ==========================================================================

## Event bejelentés
func _announce_event() -> void:
	if not _active_event:
		return
	
	_active_event.is_announced = true
	var config := _active_event.get_config()
	var announcement_time: float = config.get("announcement_time", 30.0)
	
	# Broadcast
	EventBus.world_event_announced.emit(
		_active_event.event_type,
		{
			"name": _active_event.get_name(),
			"description": _active_event.get_description(),
			"position": _active_event.position,
			"time_until_start": announcement_time,
			"color": _active_event.get_color(),
		}
	)
	
	# Notification
	EventBus.show_notification.emit(
		"WORLD EVENT: %s – %d másodperc múlva!" % [
			_active_event.get_name(), int(announcement_time)
		],
		Enums.NotificationType.WARNING
	)
	
	# Timer az event indításhoz
	_announcement_timer.start(announcement_time)
	
	print("WorldEventManager: '%s' bejelentve – indul %.0fs múlva" % [
		_active_event.get_name(), announcement_time
	])


## Event indítása az announcement után
func _start_event_after_announcement() -> void:
	if not _active_event:
		return
	
	_active_event.is_active = true
	_active_event.time_remaining = _active_event.duration
	
	# Duration timer
	_event_duration_timer.start(_active_event.duration)
	
	# Signal
	EventBus.world_event_started.emit(
		_active_event.event_type,
		{
			"event_id": _active_event.event_id,
			"name": _active_event.get_name(),
			"position": _active_event.position,
			"duration": _active_event.duration,
			"radius": _active_event.radius,
			"params": _active_event.event_params,
		}
	)
	
	# Notification
	EventBus.show_notification.emit(
		"EVENT AKTÍV: %s" % _active_event.get_name(),
		Enums.NotificationType.INFO
	)
	
	# Invasion: első hullám indítása
	if _active_event.event_type == Enums.WorldEventType.INVASION:
		_current_wave = 0
		_spawn_next_wave()
	
	print("WorldEventManager: '%s' ELINDULT – %.0fs időtartam" % [
		_active_event.get_name(), _active_event.duration
	])


## Event befejezése
func _end_event() -> void:
	if not _active_event:
		return
	
	_active_event.is_active = false
	_active_event.is_completed = true
	
	_event_duration_timer.stop()
	_wave_timer.stop()
	
	# Jutalmak kiszámítása
	var rewards := _active_event.calculate_rewards()
	
	# Cooldown beállítása
	_type_cooldowns[_active_event.event_type] = Constants.WORLD_EVENT_COOLDOWN_PER_TYPE
	
	# Történelem
	_event_history.append({
		"event_id": _active_event.event_id,
		"event_type": _active_event.event_type,
		"name": _active_event.get_name(),
		"participants": _active_event.participants.duplicate(),
		"rewards": rewards,
		"timestamp": Time.get_unix_time_from_system(),
	})
	
	# Signal – jutalom kiosztás
	EventBus.world_event_ended.emit(_active_event.event_type, rewards)
	
	# Notification
	EventBus.show_notification.emit(
		"EVENT VÉGE: %s – +%d DE, +%d Gold" % [
			_active_event.get_name(),
			rewards.get("dark_essence", 0),
			rewards.get("gold", 0),
		],
		Enums.NotificationType.INFO
	)
	
	# Jutalom alkalmazása
	if rewards.get("dark_essence", 0) > 0:
		EventBus.dark_essence_changed.emit(rewards["dark_essence"])
	if rewards.get("gold", 0) > 0:
		EventBus.gold_collected.emit(rewards["gold"])
	
	print("WorldEventManager: '%s' VÉGET ÉRT" % _active_event.get_name())
	
	_active_event = null
	
	# Következő event ütemezése
	_schedule_next_event()


# ==========================================================================
#  INVASION HULLÁMOK
# ==========================================================================

func _spawn_next_wave() -> void:
	if not _active_event or _active_event.event_type != Enums.WorldEventType.INVASION:
		return
	
	_current_wave += 1
	var config := _active_event.get_config()
	var max_waves: int = config.get("wave_count", 5)
	
	if _current_wave > max_waves:
		# Minden hullám legyőzve – event idő előtt vége
		_end_event()
		return
	
	var enemies_count: int = config.get("enemies_per_wave", 10) + (_current_wave * 2)
	
	EventBus.show_notification.emit(
		"INVASION – %d. hullám! (%d ellenség)" % [_current_wave, enemies_count],
		Enums.NotificationType.WARNING
	)
	
	# Wave interval a következő hullámhoz
	var wave_interval: float = config.get("wave_interval", 60.0)
	_wave_timer.start(wave_interval)
	
	print("WorldEventManager: Invasion hullám %d/%d – %d enemy" % [
		_current_wave, max_waves, enemies_count
	])


# ==========================================================================
#  PARTICIPANT TRACKING
# ==========================================================================

func _update_participants() -> void:
	if not _active_event or not _active_event.is_active:
		return
	
	var player := GameManager.player
	if not player:
		return
	
	# Globális event-eknél mindenki részt vesz
	if _active_event.radius <= 0:
		_active_event.add_participant(1)  # Host peer_id
		return
	
	# Pozíció alapú
	var dist := player.global_position.distance_to(_active_event.position)
	if dist <= _active_event.radius * Constants.TILE_SIZE:
		_active_event.add_participant(1)


# ==========================================================================
#  LEKÉRDEZÉSEK
# ==========================================================================

## Van-e aktív event?
func has_active_event() -> bool:
	return _active_event != null and _active_event.is_active


## Aktív event lekérdezése
func get_active_event() -> WorldEventData:
	return _active_event


## Aktív event típusa
func get_active_event_type() -> int:
	if _active_event:
		return _active_event.event_type
	return -1


## Blood Moon aktív?
func is_blood_moon_active() -> bool:
	return has_active_event() and \
		_active_event.event_type == Enums.WorldEventType.BLOOD_MOON


## Gathering Blessing aktív és a pozíció a területen belül?
func is_gathering_blessed(world_pos: Vector2) -> bool:
	if not has_active_event():
		return false
	if _active_event.event_type != Enums.WorldEventType.GATHERING_BLESSING:
		return false
	var dist := world_pos.distance_to(_active_event.position)
	return dist <= _active_event.radius * Constants.TILE_SIZE


## Corruption Surge aktív és a pozíció a területen belül?
func is_corruption_surged(world_pos: Vector2) -> bool:
	if not has_active_event():
		return false
	if _active_event.event_type != Enums.WorldEventType.CORRUPTION_SURGE:
		return false
	var dist := world_pos.distance_to(_active_event.position)
	return dist <= _active_event.radius * Constants.TILE_SIZE


## Event történelem
func get_event_history() -> Array[Dictionary]:
	return _event_history


# ==========================================================================
#  MANUÁLIS EVENT TRIGGER (DEBUG / ADMIN)
# ==========================================================================

## Manuálisan indíthat egy event-et (debug vagy admin parancshoz)
func force_event(event_type: Enums.WorldEventType, pos: Vector2 = Vector2.ZERO) -> void:
	if _active_event and _active_event.is_active:
		_end_event()
	
	if pos == Vector2.ZERO and GameManager.player:
		pos = GameManager.player.global_position
	
	_active_event = WorldEventData.create(event_type, pos)
	_announce_event()
	print("WorldEventManager: Force event '%s'" % _active_event.get_name())


# ==========================================================================
#  MULTIPLAYER SYNC
# ==========================================================================

## Host → client: event állapot küldése
func get_sync_data() -> Dictionary:
	if _active_event:
		return _active_event.serialize_for_network()
	return {}


## Client: event állapot fogadása host-tól
func apply_sync_data(data: Dictionary) -> void:
	if data.is_empty():
		if _active_event and _active_event.is_active:
			_end_event()
		return
	
	if not _active_event or _active_event.event_id != data.get("event_id", ""):
		_active_event = WorldEventData.from_network(data)
		if _active_event.is_active:
			EventBus.world_event_started.emit(
				_active_event.event_type,
				{
					"event_id": _active_event.event_id,
					"name": _active_event.get_name(),
					"position": _active_event.position,
					"duration": _active_event.duration,
					"radius": _active_event.radius,
				}
			)
	else:
		_active_event.time_remaining = data.get("time_remaining", 0)
		_active_event.is_active = data.get("is_active", false)

## DayNightCycle - Nap/éjszaka ciklus komponens
## Önálló komponens, EnvironmentManager-ral együtt használható
class_name DayNightCycle
extends Node

signal time_changed(hour: float, minute: float)
signal phase_changed(phase: Enums.DayPhase)
signal night_started()
signal day_started()

# === Idő beállítások ===
@export var enabled: bool = true
@export var real_seconds_per_day: float = 1200.0  # 20 perc = 1 játék nap
@export var start_hour: float = 8.0  # Kezdő óra

var game_time_minutes: float = 0.0  # Aktuális játék percek (0-1440)
var current_phase: Enums.DayPhase = Enums.DayPhase.DAY
var time_speed_multiplier: float = 1.0
var paused: bool = false

# === Fázis határok (órában) ===
const DAWN_START: float = 5.0
const DAY_START: float = 7.0
const DUSK_START: float = 18.0
const NIGHT_START: float = 21.0

# === Fázis színek ===
const PHASE_COLORS: Dictionary = {
	Enums.DayPhase.DAWN: Color(0.8, 0.7, 0.5, 1.0),
	Enums.DayPhase.DAY: Color(1.0, 1.0, 1.0, 1.0),
	Enums.DayPhase.DUSK: Color(0.9, 0.6, 0.4, 1.0),
	Enums.DayPhase.NIGHT: Color(0.2, 0.2, 0.4, 1.0),
}

# === Light intensity per phase ===
const PHASE_LIGHT_INTENSITY: Dictionary = {
	Enums.DayPhase.DAWN: 0.6,
	Enums.DayPhase.DAY: 1.0,
	Enums.DayPhase.DUSK: 0.5,
	Enums.DayPhase.NIGHT: 0.2,
}


func _ready() -> void:
	game_time_minutes = start_hour * 60.0


func _process(delta: float) -> void:
	if not enabled or paused:
		return
	
	var minutes_per_second: float = 1440.0 / real_seconds_per_day
	game_time_minutes += delta * minutes_per_second * time_speed_multiplier
	
	if game_time_minutes >= 1440.0:
		game_time_minutes -= 1440.0
	
	var hour := get_current_hour()
	var minute := get_current_minute()
	time_changed.emit(hour, minute)
	
	_update_phase()


func _update_phase() -> void:
	var hour := get_current_hour()
	var new_phase: Enums.DayPhase
	
	if hour >= NIGHT_START or hour < DAWN_START:
		new_phase = Enums.DayPhase.NIGHT
	elif hour < DAY_START:
		new_phase = Enums.DayPhase.DAWN
	elif hour < DUSK_START:
		new_phase = Enums.DayPhase.DAY
	else:
		new_phase = Enums.DayPhase.DUSK
	
	if new_phase != current_phase:
		var was_night := current_phase == Enums.DayPhase.NIGHT
		current_phase = new_phase
		phase_changed.emit(current_phase)
		
		if current_phase == Enums.DayPhase.NIGHT and not was_night:
			night_started.emit()
			EventBus.day_night_changed.emit(true)
		elif was_night and current_phase != Enums.DayPhase.NIGHT:
			day_started.emit()
			EventBus.day_night_changed.emit(false)


## Aktuális szín kiszámítása interpolációval
func get_current_color() -> Color:
	var hour := get_current_hour()
	
	# Interpoláció fázisok között
	if hour >= DAWN_START and hour < DAY_START:
		var t := (hour - DAWN_START) / (DAY_START - DAWN_START)
		return PHASE_COLORS[Enums.DayPhase.DAWN].lerp(PHASE_COLORS[Enums.DayPhase.DAY], t)
	elif hour >= DAY_START and hour < DUSK_START:
		return PHASE_COLORS[Enums.DayPhase.DAY]
	elif hour >= DUSK_START and hour < NIGHT_START:
		var t := (hour - DUSK_START) / (NIGHT_START - DUSK_START)
		return PHASE_COLORS[Enums.DayPhase.DUSK].lerp(PHASE_COLORS[Enums.DayPhase.NIGHT], t)
	else:
		return PHASE_COLORS[Enums.DayPhase.NIGHT]


func get_current_hour() -> float:
	return game_time_minutes / 60.0


func get_current_minute() -> float:
	return fmod(game_time_minutes, 60.0)


func get_time_string() -> String:
	var h := int(get_current_hour())
	var m := int(get_current_minute())
	return "%02d:%02d" % [h, m]


func is_night() -> bool:
	return current_phase == Enums.DayPhase.NIGHT


func set_time(hour: float, minute: float = 0.0) -> void:
	game_time_minutes = hour * 60.0 + minute
	_update_phase()


## Multiplayer sync - host küld időt
func sync_time(time_minutes: float) -> void:
	game_time_minutes = time_minutes
	_update_phase()

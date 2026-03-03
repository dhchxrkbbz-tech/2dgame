## AntiCheat - Alapszintű anti-cheat rendszer
## Host-side validáció: sebesség, range, cooldown, pozíció
## Nem teljes anti-cheat (indie co-op), csak nyilvánvaló exploit blokkolás
class_name AntiCheat
extends Node

signal violation_detected(peer_id: int, violation_type: String, details: String)
signal player_kicked(peer_id: int, reason: String)

# === Violation tracking ===
var violation_counts: Dictionary = {}  # peer_id -> {type -> count}
const MAX_VIOLATIONS: int = 10  # Ennyi után kick
const VIOLATION_DECAY_TIME: float = 60.0  # Ennyi idő alatt le violation resetelődik

# === Speed hack detection ===
const MAX_MOVE_SPEED: float = 300.0  # Pixel/sec maximum (buff-olt állapotban is)
const TELEPORT_THRESHOLD: float = 200.0  # Ha ennyi pixel-nél többet ugrik → gyanús
const SPEED_CHECK_INTERVAL: float = 0.5  # Milyen gyakran ellenőrizzünk

# === Cooldown hack detection ===
var player_cooldowns: Dictionary = {}  # peer_id -> {skill_id -> last_cast_time}
const MIN_COOLDOWN_TOLERANCE: float = 0.1  # 100ms tolerancia (latency)

# === Range hack detection ===
const MAX_MELEE_RANGE: float = 64.0  # Max melee range (pixel)
const MAX_RANGED_RANGE: float = 400.0  # Max ranged range

# === Position tracking ===
var last_positions: Dictionary = {}  # peer_id -> {pos: Vector2, time: float}
var speed_violation_timer: float = 0.0


func _ready() -> void:
	if not multiplayer.is_server():
		set_process(false)
		return


func _process(delta: float) -> void:
	speed_violation_timer += delta
	if speed_violation_timer >= SPEED_CHECK_INTERVAL:
		speed_violation_timer = 0.0
		_check_all_speeds()
	
	_decay_violations(delta)


## === SPEED VALIDATION ===

## Player pozíció frissítése (network_manager hívja input fogadásnál)
func update_player_position(peer_id: int, new_pos: Vector2) -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	
	if peer_id in last_positions:
		var last: Dictionary = last_positions[peer_id]
		var last_pos: Vector2 = last["pos"]
		var last_time: float = last["time"]
		var dt := now - last_time
		
		if dt > 0.01:  # Ne osszunk 0-val
			var distance := last_pos.distance_to(new_pos)
			var speed := distance / dt
			
			# Teleport check
			if distance > TELEPORT_THRESHOLD:
				_report_violation(peer_id, "teleport",
					"Distance: %.1f px in %.3f sec" % [distance, dt])
				last_positions[peer_id] = {"pos": last_pos, "time": now}  # Reject
				return false
			
			# Speed check
			if speed > MAX_MOVE_SPEED * 1.5:  # 50% tolerancia latency miatt
				_report_violation(peer_id, "speed",
					"Speed: %.1f px/s (max: %.1f)" % [speed, MAX_MOVE_SPEED])
				# Nem utasítjuk el rögtön, de logoljuk
	
	last_positions[peer_id] = {"pos": new_pos, "time": now}
	return true


## Összes player sebesség ellenőrzése
func _check_all_speeds() -> void:
	# A tényleges ellenőrzés update_player_position-ben történik
	pass


## === COOLDOWN VALIDATION ===

## Skill cast validálás
func validate_skill_cast(peer_id: int, skill_id: String, expected_cooldown: float) -> bool:
	var now := Time.get_ticks_msec() / 1000.0
	
	if peer_id not in player_cooldowns:
		player_cooldowns[peer_id] = {}
	
	var cooldowns: Dictionary = player_cooldowns[peer_id]
	
	if skill_id in cooldowns:
		var last_cast: float = cooldowns[skill_id]
		var elapsed := now - last_cast
		
		if elapsed < expected_cooldown - MIN_COOLDOWN_TOLERANCE:
			_report_violation(peer_id, "cooldown",
				"Skill %s: %.2f sec (min: %.2f)" % [skill_id, elapsed, expected_cooldown])
			return false
	
	cooldowns[skill_id] = now
	return true


## === RANGE VALIDATION ===

## Attack range validálás
func validate_attack_range(peer_id: int, attacker_pos: Vector2, target_pos: Vector2, is_melee: bool) -> bool:
	var distance := attacker_pos.distance_to(target_pos)
	var max_range := MAX_MELEE_RANGE if is_melee else MAX_RANGED_RANGE
	
	if distance > max_range * 1.3:  # 30% tolerancia
		_report_violation(peer_id, "range",
			"Distance: %.1f (max: %.1f)" % [distance, max_range])
		return false
	
	return true


## === DAMAGE VALIDATION ===

## Damage validálás (host oldalon)
func validate_damage(peer_id: int, claimed_damage: float, expected_max: float) -> bool:
	if claimed_damage > expected_max * 2.0:  # Dupla tolerancia crit stb. miatt
		_report_violation(peer_id, "damage",
			"Claimed: %.1f (expected max: %.1f)" % [claimed_damage, expected_max])
		return false
	return true


## === VIOLATION MANAGEMENT ===

func _report_violation(peer_id: int, violation_type: String, details: String) -> void:
	if peer_id not in violation_counts:
		violation_counts[peer_id] = {}
	
	var counts: Dictionary = violation_counts[peer_id]
	counts[violation_type] = counts.get(violation_type, 0) + 1
	
	var total: int = 0
	for v in counts.values():
		total += v
	
	violation_detected.emit(peer_id, violation_type, details)
	print("[AntiCheat] Peer %d: %s - %s (total: %d)" % [peer_id, violation_type, details, total])
	
	if total >= MAX_VIOLATIONS:
		_kick_player(peer_id, "Túl sok violation: %d" % total)


func _kick_player(peer_id: int, reason: String) -> void:
	print("[AntiCheat] KICK peer %d: %s" % [peer_id, reason])
	player_kicked.emit(peer_id, reason)
	
	# Network disconnect
	if multiplayer.is_server():
		multiplayer.multiplayer_peer.disconnect_peer(peer_id)
	
	_cleanup_peer(peer_id)


func _decay_violations(delta: float) -> void:
	# Egyszerű decay: idővel csökkennek a violation-ök
	# A tényleges implementáció timer-alapú lenne
	pass


func _cleanup_peer(peer_id: int) -> void:
	violation_counts.erase(peer_id)
	player_cooldowns.erase(peer_id)
	last_positions.erase(peer_id)


## Peer disconnect kezelés
func on_peer_disconnected(peer_id: int) -> void:
	_cleanup_peer(peer_id)

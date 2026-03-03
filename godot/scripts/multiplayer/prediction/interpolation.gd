## Interpolation - Remote entity interpoláció
## 2 snapshot közötti lerp, 100ms késleltetéssel (smooth mozgás)
extends Node

# --- Settings ---
var interpolation_delay: float = 0.1  # 100ms
var max_extrapolation: float = 0.2    # 200ms max extrapolation

# --- Snapshot storage ---
# Stores snapshots per entity: entity_key → Array of { timestamp, position, velocity, rotation }
var _snapshots: Dictionary = {}
var _max_snapshots_per_entity: int = 20

# === Public API ===

## Add a new position snapshot for an entity
func add_snapshot(entity_key: String, position: Vector2, velocity: Vector2 = Vector2.ZERO, rotation: float = 0.0) -> void:
	if not _snapshots.has(entity_key):
		_snapshots[entity_key] = []
	
	_snapshots[entity_key].append({
		"timestamp": Time.get_ticks_msec() / 1000.0,
		"position": position,
		"velocity": velocity,
		"rotation": rotation,
	})
	
	# Trim old snapshots
	while _snapshots[entity_key].size() > _max_snapshots_per_entity:
		_snapshots[entity_key].pop_front()

## Get interpolated position for an entity at the current render time
func get_interpolated_position(entity_key: String) -> Vector2:
	if not _snapshots.has(entity_key) or _snapshots[entity_key].size() == 0:
		return Vector2.ZERO
	
	var snaps = _snapshots[entity_key]
	
	if snaps.size() < 2:
		return snaps[0]["position"]
	
	var render_time = Time.get_ticks_msec() / 1000.0 - interpolation_delay
	
	# Find the two snapshots surrounding render_time
	for i in range(snaps.size() - 1, 0, -1):
		var prev = snaps[i - 1]
		var next = snaps[i]
		
		if prev["timestamp"] <= render_time and next["timestamp"] >= render_time:
			var dt = next["timestamp"] - prev["timestamp"]
			if dt <= 0:
				return next["position"]
			var t = clampf((render_time - prev["timestamp"]) / dt, 0.0, 1.0)
			return prev["position"].lerp(next["position"], t)
	
	# If render_time is beyond all snapshots, extrapolate slightly
	var latest = snaps[-1]
	var time_since = Time.get_ticks_msec() / 1000.0 - latest["timestamp"]
	
	if time_since < max_extrapolation and latest["velocity"].length() > 0:
		return latest["position"] + latest["velocity"] * time_since
	
	return latest["position"]

## Get interpolated rotation for an entity
func get_interpolated_rotation(entity_key: String) -> float:
	if not _snapshots.has(entity_key) or _snapshots[entity_key].size() == 0:
		return 0.0
	
	var snaps = _snapshots[entity_key]
	
	if snaps.size() < 2:
		return snaps[0]["rotation"]
	
	var render_time = Time.get_ticks_msec() / 1000.0 - interpolation_delay
	
	for i in range(snaps.size() - 1, 0, -1):
		var prev = snaps[i - 1]
		var next = snaps[i]
		
		if prev["timestamp"] <= render_time and next["timestamp"] >= render_time:
			var dt = next["timestamp"] - prev["timestamp"]
			if dt <= 0:
				return next["rotation"]
			var t = clampf((render_time - prev["timestamp"]) / dt, 0.0, 1.0)
			return lerp_angle(prev["rotation"], next["rotation"], t)
	
	return snaps[-1]["rotation"]

## Check if we have recent data for an entity
func has_recent_data(entity_key: String, max_age: float = 1.0) -> bool:
	if not _snapshots.has(entity_key) or _snapshots[entity_key].size() == 0:
		return false
	
	var latest = _snapshots[entity_key][-1]
	var age = Time.get_ticks_msec() / 1000.0 - latest["timestamp"]
	return age < max_age

## Remove snapshots for an entity (when despawned)
func remove_entity(entity_key: String) -> void:
	_snapshots.erase(entity_key)

## Clear all snapshots
func clear() -> void:
	_snapshots.clear()

## Get snapshot count for an entity
func get_snapshot_count(entity_key: String) -> int:
	if _snapshots.has(entity_key):
		return _snapshots[entity_key].size()
	return 0

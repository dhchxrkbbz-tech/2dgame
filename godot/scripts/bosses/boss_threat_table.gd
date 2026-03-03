## BossThreatTable - Aggro/threat rendszer boss-okhoz
## Multiplayer-ben kinek támadjon a boss
class_name BossThreatTable
extends RefCounted

var threat_map: Dictionary = {}  # player_id -> threat_value
var taunt_target: Node = null
var taunt_duration: float = 0.0


func add_threat(player: Node, amount: float) -> void:
	var id := player.get_instance_id()
	if id not in threat_map:
		threat_map[id] = {"player": player, "threat": 0.0}
	threat_map[id]["threat"] += amount


func get_top_threat() -> Node:
	# Taunt felülír mindent
	if taunt_target and is_instance_valid(taunt_target) and taunt_duration > 0:
		return taunt_target
	
	var top_player: Node = null
	var top_threat: float = -1.0
	
	for id in threat_map:
		var data: Dictionary = threat_map[id]
		if not is_instance_valid(data["player"]):
			continue
		if data["player"].current_hp <= 0:
			continue
		if data["threat"] > top_threat:
			top_threat = data["threat"]
			top_player = data["player"]
	
	return top_player


func get_random_target() -> Node:
	var valid: Array[Node] = []
	for id in threat_map:
		var data: Dictionary = threat_map[id]
		if is_instance_valid(data["player"]) and data["player"].current_hp > 0:
			valid.append(data["player"])
	
	if valid.is_empty():
		return null
	return valid[randi() % valid.size()]


func get_secondary_target() -> Node:
	var top := get_top_threat()
	var second_player: Node = null
	var second_threat: float = -1.0
	
	for id in threat_map:
		var data: Dictionary = threat_map[id]
		if not is_instance_valid(data["player"]):
			continue
		if data["player"] == top:
			continue
		if data["player"].current_hp <= 0:
			continue
		if data["threat"] > second_threat:
			second_threat = data["threat"]
			second_player = data["player"]
	
	return second_player


func set_taunt(player: Node, duration: float) -> void:
	taunt_target = player
	taunt_duration = duration


func update(delta: float) -> void:
	if taunt_duration > 0:
		taunt_duration -= delta
		if taunt_duration <= 0:
			taunt_target = null
	
	# Slow threat decay
	for id in threat_map:
		threat_map[id]["threat"] *= 0.999


func get_player_count() -> int:
	var count := 0
	for id in threat_map:
		var data: Dictionary = threat_map[id]
		if is_instance_valid(data["player"]) and data["player"].current_hp > 0:
			count += 1
	return count


func clear() -> void:
	threat_map.clear()
	taunt_target = null
	taunt_duration = 0.0

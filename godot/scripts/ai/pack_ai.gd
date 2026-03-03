## PackAI - Csapat/csorda viselkedés enemy-khez
## Leader/Flanker/Support szerepek, boids swarm, koordinált támadás
class_name PackAI
extends RefCounted

enum PackRole { LEADER, FLANKER, SUPPORT, SWARM }

var pack_members: Array[Node] = []
var pack_leader: Node = null
var target: Node = null
var _formation_spread: float = 48.0


## Pack létrehozása member-ekből
static func create_pack(members: Array[Node]) -> PackAI:
	var pack := PackAI.new()
	pack.pack_members = members
	
	if members.is_empty():
		return pack
	
	# Leader kiválasztása (legtöbb HP)
	var best_hp := 0
	for member in members:
		var hp := 0
		if member.has_method("get_max_hp"):
			hp = member.get_max_hp()
		elif "enemy_data" in member and member.enemy_data:
			hp = member.enemy_data.base_hp
		
		if hp > best_hp:
			best_hp = hp
			pack.pack_leader = member
		
		member.set_meta("pack", pack)
	
	# Szerepek kiosztása
	pack._assign_roles()
	
	return pack


func _assign_roles() -> void:
	for member in pack_members:
		if member == pack_leader:
			member.set_meta("pack_role", PackRole.LEADER)
		elif _is_ranged(member):
			member.set_meta("pack_role", PackRole.SUPPORT)
		elif _is_swarm(member):
			member.set_meta("pack_role", PackRole.SWARM)
		else:
			member.set_meta("pack_role", PackRole.FLANKER)


func _is_ranged(member: Node) -> bool:
	if "enemy_data" in member and member.enemy_data:
		return member.enemy_data.enemy_category == Enums.EnemyType.RANGED or \
			   member.enemy_data.enemy_category == Enums.EnemyType.CASTER
	return false


func _is_swarm(member: Node) -> bool:
	if "enemy_data" in member and member.enemy_data:
		return member.enemy_data.enemy_category == Enums.EnemyType.SWARM
	return false


## Pack update - hívandó frame-enként
func update(delta: float) -> void:
	# Clean dead members
	pack_members = pack_members.filter(func(m): return is_instance_valid(m) and m.current_hp > 0)
	
	if pack_members.is_empty():
		return
	
	# Leader update
	if pack_leader == null or not is_instance_valid(pack_leader) or pack_leader.current_hp <= 0:
		# Új leader
		if not pack_members.is_empty():
			pack_leader = pack_members[0]
			pack_leader.set_meta("pack_role", PackRole.LEADER)
	
	# Target megosztás
	if pack_leader and is_instance_valid(pack_leader) and "current_target" in pack_leader:
		target = pack_leader.current_target


## Pozíció számítás pack role alapján
func get_desired_position(member: Node, target_pos: Vector2) -> Vector2:
	if not is_instance_valid(member):
		return member.global_position
	
	var role: int = member.get_meta("pack_role", PackRole.SWARM)
	var member_pos: Vector2 = member.global_position
	
	match role:
		PackRole.LEADER:
			# Leader egyenesen a target felé
			return target_pos
		
		PackRole.FLANKER:
			# Oldalról közelít
			var index := pack_members.find(member)
			var angle := PI / 4.0 * (1 if index % 2 == 0 else -1)
			var dir := (target_pos - member_pos).normalized().rotated(angle)
			return target_pos - dir * _formation_spread
		
		PackRole.SUPPORT:
			# Hátul marad
			if pack_leader and is_instance_valid(pack_leader):
				var dir := (target_pos - pack_leader.global_position).normalized()
				return pack_leader.global_position - dir * _formation_spread * 2
			return member_pos
		
		PackRole.SWARM:
			# Boids-szerű mozgás
			return _calculate_swarm_position(member, target_pos)
	
	return target_pos


func _calculate_swarm_position(member: Node, target_pos: Vector2) -> Vector2:
	var separation := Vector2.ZERO
	var cohesion := Vector2.ZERO
	var alignment := Vector2.ZERO
	var neighbor_count := 0
	
	for other in pack_members:
		if other == member or not is_instance_valid(other):
			continue
		
		var dist := member.global_position.distance_to(other.global_position)
		
		# Separation: ne legyenek túl közel
		if dist < 24:
			separation += (member.global_position - other.global_position).normalized() / max(dist, 1.0)
		
		# Cohesion: tartsd a csoportot
		if dist < 96:
			cohesion += other.global_position
			neighbor_count += 1
		
		# Alignment: hasonló irányba
		if "velocity" in other:
			alignment += other.velocity
	
	var result := target_pos
	
	if neighbor_count > 0:
		cohesion = cohesion / float(neighbor_count)
		result = result.lerp(cohesion, 0.3)
	
	result += separation * 20.0
	
	return result


func get_member_count() -> int:
	return pack_members.size()


func is_leader(member: Node) -> bool:
	return member == pack_leader


func alert_pack(threat_pos: Vector2) -> void:
	## Riasztja a pack összes tagját
	for member in pack_members:
		if is_instance_valid(member) and member.has_method("alert"):
			member.alert(threat_pos)

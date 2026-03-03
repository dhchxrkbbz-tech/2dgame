## CombatSync - Damage, skill cast, buff/debuff szinkronizáció
## Host-authoritative: host validálja és hajtja végre a combat logikát
extends Node

# --- Signals ---
signal skill_cast_received(caster_id: int, skill_id: String, target_pos: Vector2)
signal skill_denied(skill_id: String, reason: String)
signal damage_received(target_id: int, amount: float, damage_type: Enums.DamageType, is_crit: bool)
signal heal_received(target_id: int, amount: float)
signal buff_applied(target_id: int, effect_type: Enums.EffectType, duration: float)
signal buff_removed(target_id: int, effect_type: Enums.EffectType)
signal entity_killed_remote(killer_id: int, victim_id: int)

func reset() -> void:
	pass

# === Client Side ===

## Client requests a skill cast - sent to host for validation
func client_request_skill_cast(skill_id: String, target_pos: Vector2) -> void:
	var timestamp = NetworkManager.get_server_time()
	_rpc_request_skill_cast.rpc_id(1, skill_id, target_pos, timestamp)

## Client requests a melee attack
func client_request_attack(target_pos: Vector2) -> void:
	var timestamp = NetworkManager.get_server_time()
	_rpc_request_attack.rpc_id(1, target_pos, timestamp)

# === Server Side ===

## Host broadcasts a confirmed skill cast to all clients
func server_broadcast_skill_cast(caster_peer_id: int, skill_id: String, target_pos: Vector2) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_skill_casted.rpc(caster_peer_id, skill_id, target_pos)

## Host broadcasts damage event to relevant clients
func server_broadcast_damage(target_id: int, amount: float, damage_type: Enums.DamageType, is_crit: bool) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_damage_dealt.rpc(target_id, amount, damage_type, is_crit)

## Host broadcasts heal event
func server_broadcast_heal(target_id: int, amount: float) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_heal_applied.rpc(target_id, amount)

## Host broadcasts buff/debuff application
func server_broadcast_buff(target_id: int, effect_type: Enums.EffectType, duration: float) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_buff_applied.rpc(target_id, effect_type, duration)

## Host broadcasts buff/debuff removal
func server_broadcast_buff_removed(target_id: int, effect_type: Enums.EffectType) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_buff_removed.rpc(target_id, effect_type)

## Host broadcasts entity kill event
func server_broadcast_kill(killer_id: int, victim_id: int) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_entity_killed.rpc(killer_id, victim_id)

# === Boss Combat ===

## Host broadcasts boss phase change
func server_broadcast_boss_phase(boss_id: String, phase: int) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_boss_phase_changed.rpc(boss_id, phase)

## Host broadcasts boss ability telegraph
func server_broadcast_boss_telegraph(boss_id: String, ability_id: String, position: Vector2, radius: float, delay: float) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_boss_telegraph.rpc(boss_id, ability_id, position, radius, delay)

## Host broadcasts boss ability execution
func server_broadcast_boss_ability(boss_id: String, ability_id: String, position: Vector2, direction: Vector2) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_boss_ability.rpc(boss_id, ability_id, position, direction)

## Host broadcasts boss HP update
func server_broadcast_boss_hp(boss_id: String, hp_percent: float) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_boss_hp_update.rpc(boss_id, hp_percent)

## Host broadcasts boss enrage
func server_broadcast_boss_enrage(boss_id: String) -> void:
	if not NetworkManager.is_server():
		return
	_rpc_boss_enraged.rpc(boss_id)

# === RPCs - Skill Cast ===

@rpc("any_peer", "reliable")
func _rpc_request_skill_cast(skill_id: String, target_pos: Vector2, timestamp: float) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	
	# Server-side validation
	# 1. Check: does player exist?
	var player = _get_player_by_peer_id(sender_id)
	if player == null:
		_rpc_skill_denied.rpc_id(sender_id, skill_id, "Player not found")
		return
	
	# 2. Check: cooldown, mana, range (delegated to actual skill system)
	if player.has_method("can_cast_skill"):
		if not player.can_cast_skill(skill_id):
			_rpc_skill_denied.rpc_id(sender_id, skill_id, "Cannot cast")
			return
	
	# 3. Execute skill on server
	if player.has_method("execute_skill"):
		player.execute_skill(skill_id, target_pos)
	
	# 4. Broadcast to all clients
	server_broadcast_skill_cast(sender_id, skill_id, target_pos)

@rpc("any_peer", "reliable")
func _rpc_request_attack(target_pos: Vector2, timestamp: float) -> void:
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	var player = _get_player_by_peer_id(sender_id)
	if player == null:
		return
	
	# Execute attack on server
	if player.has_method("execute_attack"):
		player.execute_attack(target_pos)

@rpc("authority", "reliable")
func _rpc_skill_casted(caster_id: int, skill_id: String, target_pos: Vector2) -> void:
	skill_cast_received.emit(caster_id, skill_id, target_pos)

@rpc("authority", "reliable")
func _rpc_skill_denied(skill_id: String, reason: String) -> void:
	skill_denied.emit(skill_id, reason)
	push_warning("CombatSync: Skill %s denied: %s" % [skill_id, reason])

# === RPCs - Damage & Heal ===

@rpc("authority", "reliable")
func _rpc_damage_dealt(target_id: int, amount: float, damage_type: Enums.DamageType, is_crit: bool) -> void:
	damage_received.emit(target_id, amount, damage_type, is_crit)

@rpc("authority", "reliable")
func _rpc_heal_applied(target_id: int, amount: float) -> void:
	heal_received.emit(target_id, amount)

# === RPCs - Buffs ===

@rpc("authority", "reliable")
func _rpc_buff_applied(target_id: int, effect_type: Enums.EffectType, duration: float) -> void:
	buff_applied.emit(target_id, effect_type, duration)

@rpc("authority", "reliable")
func _rpc_buff_removed(target_id: int, effect_type: Enums.EffectType) -> void:
	buff_removed.emit(target_id, effect_type)

# === RPCs - Kill ===

@rpc("authority", "reliable")
func _rpc_entity_killed(killer_id: int, victim_id: int) -> void:
	entity_killed_remote.emit(killer_id, victim_id)

# === RPCs - Boss ===

@rpc("authority", "reliable")
func _rpc_boss_phase_changed(boss_id: String, phase: int) -> void:
	EventBus.boss_phase_changed.emit(boss_id, phase)

@rpc("authority", "reliable")
func _rpc_boss_telegraph(boss_id: String, ability_id: String, position: Vector2, radius: float, delay: float) -> void:
	# Clients show telegraph visual at position
	pass  # Actual implementation connects to boss telegraph system

@rpc("authority", "reliable")
func _rpc_boss_ability(boss_id: String, ability_id: String, position: Vector2, direction: Vector2) -> void:
	# Clients play ability visual/animation
	pass  # Actual implementation connects to boss ability system

@rpc("authority", "reliable")
func _rpc_boss_hp_update(boss_id: String, hp_percent: float) -> void:
	# Update boss HP bar on all clients
	pass  # Actual implementation connects to boss_health_bar

@rpc("authority", "reliable")
func _rpc_boss_enraged(boss_id: String) -> void:
	EventBus.boss_enraged.emit(boss_id)

# === Helpers ===

func _get_player_by_peer_id(peer_id: int) -> Node:
	var players_node = get_tree().get_first_node_in_group("players_container")
	if players_node == null:
		return null
	for player in players_node.get_children():
		if player.has_meta("peer_id") and player.get_meta("peer_id") == peer_id:
			return player
	return null

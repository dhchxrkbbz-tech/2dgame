## CombatManager - Combat flow vezérlés
## Felelős: combat állapot, threat, combat zene, kill tracking
class_name CombatManager
extends Node

signal combat_started()
signal combat_ended()
signal kill_registered(killer: Node, victim: Node)
signal combo_updated(combo_count: int)

# === Combat állapot ===
var is_in_combat: bool = false
var combat_timer: float = 0.0

# === Kill tracking ===
var total_kills: int = 0
var session_kills: int = 0
var combo_count: int = 0
var combo_timer: float = 0.0

# === Aktív ellenségek ===
var engaged_enemies: Array[Node] = []


func _ready() -> void:
	EventBus.entity_killed.connect(_on_entity_killed)
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.player_died.connect(_on_player_died)


func _process(delta: float) -> void:
	if is_in_combat:
		combat_timer -= delta
		if combat_timer <= 0:
			_end_combat()
	
	if combo_count > 0:
		combo_timer -= delta
		if combo_timer <= 0:
			combo_count = 0
			combo_updated.emit(0)


func _on_damage_dealt(source: Node, target: Node, amount: float, _damage_type) -> void:
	if not is_in_combat:
		_start_combat()
	combat_timer = Constants.COMBAT_TIMEOUT
	
	# Engaged enemy tracking
	if target and is_instance_valid(target) and target.is_in_group("enemy"):
		if target not in engaged_enemies:
			engaged_enemies.append(target)


func _on_entity_killed(killer: Node, victim: Node) -> void:
	if victim and victim.is_in_group("enemy"):
		total_kills += 1
		session_kills += 1
		combo_count += 1
		combo_timer = Constants.COMBO_TIMEOUT
		combo_updated.emit(combo_count)
		kill_registered.emit(killer, victim)
		engaged_enemies.erase(victim)
	
	# Ha nincs több aktív enemy
	_cleanup_engaged()
	if engaged_enemies.is_empty():
		combat_timer = minf(combat_timer, 2.0)


func _on_player_died(player: Node) -> void:
	# Combat vége ha player meghal
	if is_in_combat:
		_end_combat()
	combo_count = 0
	combo_updated.emit(0)
	engaged_enemies.clear()


func _start_combat() -> void:
	is_in_combat = true
	combat_timer = Constants.COMBAT_TIMEOUT
	combat_started.emit()
	# Dinamikus zene: combat theme
	if has_node("/root/AudioManager"):
		AudioManager.notify_combat_started()


func _end_combat() -> void:
	is_in_combat = false
	engaged_enemies.clear()
	combat_ended.emit()
	# Dinamikus zene: visszatérés exploration-re
	if has_node("/root/AudioManager"):
		AudioManager.notify_combat_ended()


func _cleanup_engaged() -> void:
	engaged_enemies = engaged_enemies.filter(func(e): return is_instance_valid(e) and e.is_alive if e.has_method("is_alive") else is_instance_valid(e))


## XP bonus combo-ért (Plan 21 §2.7 - Constants-ból)
func get_combo_xp_multiplier() -> float:
	if combo_count < 3:
		return 1.0
	elif combo_count < 5:
		return Constants.COMBO_XP_MULT_3
	elif combo_count < 10:
		return Constants.COMBO_XP_MULT_5
	else:
		return Constants.COMBO_XP_MULT_10
		return 1.5

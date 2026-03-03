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
const COMBAT_TIMEOUT: float = 5.0  # 5 mp combat nélkül → peace

# === Kill tracking ===
var total_kills: int = 0
var session_kills: int = 0
var combo_count: int = 0
var combo_timer: float = 0.0
const COMBO_TIMEOUT: float = 3.0

# === Aktív ellenségek ===
var engaged_enemies: Array[Node] = []


func _ready() -> void:
	EventBus.entity_killed.connect(_on_entity_killed)
	EventBus.damage_dealt.connect(_on_damage_dealt)


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
	combat_timer = COMBAT_TIMEOUT
	
	# Engaged enemy tracking
	if target and is_instance_valid(target) and target.is_in_group("enemy"):
		if target not in engaged_enemies:
			engaged_enemies.append(target)


func _on_entity_killed(killer: Node, victim: Node) -> void:
	if victim and victim.is_in_group("enemy"):
		total_kills += 1
		session_kills += 1
		combo_count += 1
		combo_timer = COMBO_TIMEOUT
		combo_updated.emit(combo_count)
		kill_registered.emit(killer, victim)
		engaged_enemies.erase(victim)
	
	# Ha nincs több aktív enemy
	_cleanup_engaged()
	if engaged_enemies.is_empty():
		combat_timer = minf(combat_timer, 2.0)


func _start_combat() -> void:
	is_in_combat = true
	combat_timer = COMBAT_TIMEOUT
	combat_started.emit()


func _end_combat() -> void:
	is_in_combat = false
	engaged_enemies.clear()
	combat_ended.emit()


func _cleanup_engaged() -> void:
	engaged_enemies = engaged_enemies.filter(func(e): return is_instance_valid(e) and e.is_alive if e.has_method("is_alive") else is_instance_valid(e))


## XP bonus combo-ért
func get_combo_xp_multiplier() -> float:
	if combo_count < 3:
		return 1.0
	elif combo_count < 5:
		return 1.1
	elif combo_count < 10:
		return 1.25
	else:
		return 1.5

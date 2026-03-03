## HealthComponent - HP kezelés component
## Újrafelhasználható HP rendszer player-hez és enemy-hez
class_name HealthComponent
extends Node

signal health_changed(current_hp: int, max_hp: int)
signal died()
signal healed(amount: int)
signal damage_taken(amount: int, damage_type: Enums.DamageType)

@export var max_hp: int = 100
var current_hp: int = 100

@export var hp_regen_rate: float = 0.0  # HP/sec
var regen_timer: float = 0.0

var is_alive: bool = true
var parent_entity: Node = null

# === Shield (absorb) ===
var shield_amount: int = 0
var shield_duration: float = 0.0


func _ready() -> void:
	parent_entity = get_parent()
	current_hp = max_hp


func _process(delta: float) -> void:
	# HP regen
	if is_alive and hp_regen_rate > 0 and current_hp < max_hp:
		regen_timer += delta
		if regen_timer >= 1.0:
			regen_timer -= 1.0
			heal(int(hp_regen_rate))
	
	# Shield duration
	if shield_amount > 0 and shield_duration > 0:
		shield_duration -= delta
		if shield_duration <= 0:
			shield_amount = 0


## Sebzés fogadása
func take_damage(amount: int, damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL) -> int:
	if not is_alive:
		return 0
	
	var remaining_damage: int = amount
	
	# Shield absorb
	if shield_amount > 0:
		if shield_amount >= remaining_damage:
			shield_amount -= remaining_damage
			return 0
		else:
			remaining_damage -= shield_amount
			shield_amount = 0
	
	current_hp -= remaining_damage
	current_hp = maxi(current_hp, 0)
	
	damage_taken.emit(remaining_damage, damage_type)
	health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		_die()
	
	return remaining_damage


## Gyógyítás
func heal(amount: int) -> void:
	if not is_alive:
		return
	var actual_heal := mini(amount, max_hp - current_hp)
	if actual_heal <= 0:
		return
	current_hp += actual_heal
	healed.emit(actual_heal)
	health_changed.emit(current_hp, max_hp)


## Shield alkalmazása
func apply_shield(amount: int, duration: float = 10.0) -> void:
	shield_amount = amount
	shield_duration = duration


## Max HP módosítás (level up, buff)
func set_max_hp(new_max: int, heal_to_full: bool = false) -> void:
	max_hp = new_max
	if heal_to_full:
		current_hp = max_hp
	else:
		current_hp = mini(current_hp, max_hp)
	health_changed.emit(current_hp, max_hp)


## HP százalék
func get_hp_percent() -> float:
	if max_hp <= 0:
		return 0.0
	return float(current_hp) / float(max_hp)


## Feltámasztás
func revive(hp_percent: float = 1.0) -> void:
	is_alive = true
	current_hp = int(max_hp * hp_percent)
	health_changed.emit(current_hp, max_hp)


func _die() -> void:
	is_alive = false
	died.emit()

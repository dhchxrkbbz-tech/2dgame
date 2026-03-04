## HealthComponent - HP kezelés component
## Újrafelhasználható HP rendszer player-hez és enemy-hez
class_name HealthComponent
extends Node

signal health_changed(current_hp: int, max_hp: int)
signal died()
signal healed(amount: int)
signal damage_taken(amount: int, damage_type: Enums.DamageType)
signal shield_changed(shield_amount: int, max_shield: int)
signal shield_broken()

@export var max_hp: int = 100
var current_hp: int = 100

@export var hp_regen_rate: float = 0.0  # HP/sec
var regen_timer: float = 0.0

var is_alive: bool = true
var parent_entity: Node = null

# === Shield (absorb) ===
var shield_amount: int = 0
var shield_max: int = 0
var shield_duration: float = 0.0
var shield_type: String = ""  # "mana_shield", "shield_wall", "buff", etc.
var shield_mana_drain: float = 0.0  # Mana cost per second for mana shields


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
			_remove_shield()
	
	# Mana shield drain (Mage Mana Shield skill)
	if shield_amount > 0 and shield_mana_drain > 0 and parent_entity:
		if "current_mana" in parent_entity:
			var drain := shield_mana_drain * delta
			if parent_entity.current_mana >= drain:
				parent_entity.current_mana -= drain
			else:
				# Mana kifogyott - shield törik
				_remove_shield()


## Sebzés fogadása
func take_damage(amount: int, damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL) -> int:
	if not is_alive:
		return 0
	
	var remaining_damage: int = amount
	
	# Shield absorb
	if shield_amount > 0:
		if shield_amount >= remaining_damage:
			shield_amount -= remaining_damage
			shield_changed.emit(shield_amount, shield_max)
			return 0
		else:
			remaining_damage -= shield_amount
			_remove_shield()
	
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
func apply_shield(amount: int, duration: float = 10.0, type: String = "buff", mana_drain: float = 0.0) -> void:
	shield_amount = amount
	shield_max = amount
	shield_duration = duration
	shield_type = type
	shield_mana_drain = mana_drain
	shield_changed.emit(shield_amount, shield_max)


## Mana Shield (Mage): mana-t fogyaszt, damage-t mana-ra konvertálja
func apply_mana_shield(mana_cost_per_sec: float = 5.0, duration: float = 15.0) -> void:
	if not parent_entity or not "current_mana" in parent_entity:
		return
	var mana_available: float = parent_entity.current_mana
	var shield_hp := int(mana_available * 2.0)  # 1 mana = 2 shield HP
	apply_shield(shield_hp, duration, "mana_shield", mana_cost_per_sec)


## Shield Wall (Tank): fix összeg, duration alapú
func apply_shield_wall(amount: int, duration: float = 8.0) -> void:
	apply_shield(amount, duration, "shield_wall")


## Shield eltávolítása
func _remove_shield() -> void:
	var had_shield := shield_amount > 0
	shield_amount = 0
	shield_max = 0
	shield_duration = 0.0
	shield_mana_drain = 0.0
	shield_type = ""
	if had_shield:
		shield_broken.emit()
		shield_changed.emit(0, 0)


## Shield százalék
func get_shield_percent() -> float:
	if shield_max <= 0:
		return 0.0
	return float(shield_amount) / float(shield_max)


## Effektív HP (HP + Shield)
func get_effective_hp() -> int:
	return current_hp + shield_amount


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

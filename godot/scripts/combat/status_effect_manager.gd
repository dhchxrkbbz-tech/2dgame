## StatusEffectManager - Status effect-ek kezelése egy entity-n
## DOT tick, CC ellenőrzés, buff/debuff aggregálás
class_name StatusEffectManager
extends Node

signal effect_applied(effect_type: Enums.EffectType)
signal effect_removed(effect_type: Enums.EffectType)
signal dot_tick(damage: float, effect_type: Enums.EffectType)

var active_effects: Array[StatusEffect] = []
var parent_entity: Node = null


func _ready() -> void:
	parent_entity = get_parent()


func _process(delta: float) -> void:
	var expired_effects: Array[StatusEffect] = []
	
	for effect in active_effects:
		var result := effect.update(delta)
		
		if result["tick_damage"] > 0.0:
			dot_tick.emit(result["tick_damage"], effect.effect_type)
		
		if result["expired"]:
			expired_effects.append(effect)
	
	for effect in expired_effects:
		_remove_effect(effect)


func apply_effect(effect: StatusEffect) -> void:
	# Ellenőrzés: van-e már ilyen típusú effect
	var existing := get_effect(effect.effect_type)
	
	if existing:
		# Stack hozzáadás ha lehetséges
		if existing.stacks < existing.max_stacks:
			existing.stacks += 1
		# Idő frissítés (a hosszabb marad)
		existing.remaining_time = maxf(existing.remaining_time, effect.duration)
	else:
		active_effects.append(effect)
		effect_applied.emit(effect.effect_type)
		EventBus.status_effect_applied.emit(parent_entity, effect.effect_type, effect.duration)


func remove_effect_type(effect_type: Enums.EffectType) -> void:
	var to_remove: StatusEffect = null
	for effect in active_effects:
		if effect.effect_type == effect_type:
			to_remove = effect
			break
	if to_remove:
		_remove_effect(to_remove)


func _remove_effect(effect: StatusEffect) -> void:
	active_effects.erase(effect)
	effect_removed.emit(effect.effect_type)
	EventBus.status_effect_removed.emit(parent_entity, effect.effect_type)


func get_effect(effect_type: Enums.EffectType) -> StatusEffect:
	for effect in active_effects:
		if effect.effect_type == effect_type:
			return effect
	return null


func has_effect(effect_type: Enums.EffectType) -> bool:
	return get_effect(effect_type) != null


func clear_all() -> void:
	for effect in active_effects.duplicate():
		_remove_effect(effect)


func clear_debuffs() -> void:
	for effect in active_effects.duplicate():
		if effect.is_cc() or not effect.is_buff():
			_remove_effect(effect)


## Összesített speed modifier (összes aktív effect-ből)
func get_total_speed_modifier() -> float:
	var total: float = 0.0
	for effect in active_effects:
		var mod := effect.get_speed_modifier()
		if mod <= -1.0:
			return -1.0  # Root/Stun/Freeze → teljes stop
		total += mod
	return clampf(total, -0.9, 1.0)


## Összesített damage modifier
func get_total_damage_modifier() -> float:
	var total: float = 0.0
	for effect in active_effects:
		total += effect.get_damage_modifier()
	return total


## Összesített armor modifier
func get_total_armor_modifier() -> float:
	var total: float = 0.0
	for effect in active_effects:
		total += effect.get_armor_modifier()
	return total


## Tud-e cselekedni az entity (stun/freeze ellenőrzés)
func can_act() -> bool:
	for effect in active_effects:
		if not effect.can_act():
			return false
	return true


## Tud-e mozogni (root/stun/freeze)
func can_move() -> bool:
	for effect in active_effects:
		if effect.get_speed_modifier() <= -1.0:
			return false
	return true

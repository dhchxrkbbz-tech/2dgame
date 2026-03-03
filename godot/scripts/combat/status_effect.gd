## StatusEffect - Egyedi status effect instance
## DOT, CC, buff, debuff kezelés
class_name StatusEffect
extends RefCounted

var effect_type: Enums.EffectType
var duration: float
var remaining_time: float
var tick_interval: float = 1.0
var tick_timer: float = 0.0
var value: float = 0.0  # DOT damage / buff amount / slow %
var source: Node = null
var stacks: int = 1
var max_stacks: int = 1


static func create(
	type: Enums.EffectType,
	dur: float,
	val: float = 0.0,
	src: Node = null,
	max_st: int = 1
) -> StatusEffect:
	var effect := StatusEffect.new()
	effect.effect_type = type
	effect.duration = dur
	effect.remaining_time = dur
	effect.value = val
	effect.source = src
	effect.max_stacks = max_st
	return effect


func is_dot() -> bool:
	return effect_type in [
		Enums.EffectType.POISON_DOT,
		Enums.EffectType.BURN_DOT,
		Enums.EffectType.BLEED_DOT,
	]


func is_cc() -> bool:
	return effect_type in [
		Enums.EffectType.SLOW,
		Enums.EffectType.ROOT,
		Enums.EffectType.STUN,
		Enums.EffectType.FREEZE,
		Enums.EffectType.BLIND,
	]


func is_buff() -> bool:
	return effect_type in [
		Enums.EffectType.ATTACK_SPEED_UP,
		Enums.EffectType.DAMAGE_UP,
		Enums.EffectType.ARMOR_UP,
		Enums.EffectType.SPEED_UP,
		Enums.EffectType.LIFESTEAL,
		Enums.EffectType.SHIELD,
		Enums.EffectType.HP_REGEN,
		Enums.EffectType.MANA_REGEN,
	]


func update(delta: float) -> Dictionary:
	## Visszatérés: {"expired": bool, "tick_damage": float}
	remaining_time -= delta
	var result := {"expired": remaining_time <= 0.0, "tick_damage": 0.0}
	
	if is_dot():
		tick_timer += delta
		if tick_timer >= tick_interval:
			tick_timer -= tick_interval
			result["tick_damage"] = value * stacks
	
	return result


func get_speed_modifier() -> float:
	match effect_type:
		Enums.EffectType.SLOW:
			return -value / 100.0  # value = slow százalék
		Enums.EffectType.SPEED_UP:
			return value / 100.0
		Enums.EffectType.ROOT, Enums.EffectType.STUN, Enums.EffectType.FREEZE:
			return -1.0  # Teljes mozgásképtelenség
		_:
			return 0.0


func get_damage_modifier() -> float:
	match effect_type:
		Enums.EffectType.DAMAGE_UP:
			return value / 100.0
		Enums.EffectType.DAMAGE_DOWN:
			return -value / 100.0
		_:
			return 0.0


func get_armor_modifier() -> float:
	match effect_type:
		Enums.EffectType.ARMOR_UP:
			return value
		Enums.EffectType.ARMOR_DOWN:
			return -value
		_:
			return 0.0


func can_act() -> bool:
	return effect_type != Enums.EffectType.STUN and effect_type != Enums.EffectType.FREEZE

## HitboxComponent - Sebzést okozó terület
## Melee attack, AoE, és egyéb damage zone-ok
class_name HitboxComponent
extends Area2D

@export var damage: float = 10.0
@export var damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL
@export var knockback_force: float = 0.0
@export var one_shot: bool = true  # Csak egyszer sebez-e

signal hit_landed(target: Node2D)

var source: Node = null
var is_active: bool = false
var already_hit: Array[Node] = []

# Status effect alkalmazandó
var apply_effect_type: Enums.EffectType = -1
var apply_effect_duration: float = 0.0
var apply_effect_value: float = 0.0


func _ready() -> void:
	source = get_parent()
	monitoring = false
	area_entered.connect(_on_area_entered)
	add_to_group("hitbox")


func activate(duration: float = 0.3, override_damage: float = -1.0) -> void:
	is_active = true
	monitoring = true
	already_hit.clear()
	
	if override_damage >= 0:
		damage = override_damage
	
	if duration > 0:
		var timer := get_tree().create_timer(duration)
		timer.timeout.connect(deactivate)


func deactivate() -> void:
	is_active = false
	monitoring = false
	already_hit.clear()


func set_effect(effect_type: Enums.EffectType, duration: float, value: float = 0.0) -> void:
	apply_effect_type = effect_type
	apply_effect_duration = duration
	apply_effect_value = value


func _on_area_entered(area: Area2D) -> void:
	if not is_active:
		return
	
	if not area.is_in_group("hurtbox"):
		return
	
	var target := area.get_parent()
	if target == source:
		return
	if target in already_hit:
		return
	
	already_hit.append(target)
	
	# Signal for custom damage handling
	hit_landed.emit(target)
	
	# Damage alkalmazás
	if target.has_method("take_damage"):
		target.take_damage(damage, damage_type)
		EventBus.damage_dealt.emit(source, target, damage, damage_type)
	
	# Knockback
	if knockback_force > 0 and target is CharacterBody2D:
		var knockback_dir := (target.global_position - source.global_position).normalized()
		if target.has_method("apply_knockback"):
			target.apply_knockback(knockback_dir * knockback_force)
	
	# Status effect
	if apply_effect_type >= 0 and target.has_node("StatusEffectManager"):
		var effect := StatusEffect.create(
			apply_effect_type, apply_effect_duration, apply_effect_value, source
		)
		target.get_node("StatusEffectManager").apply_effect(effect)
	
	if one_shot:
		deactivate()

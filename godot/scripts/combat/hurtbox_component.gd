## HurtboxComponent - Sebzést kapó terület
## Area2D ami jelzi, hogy az entity "üthet"-ő
class_name HurtboxComponent
extends Area2D

signal damage_received(amount: float, damage_type: Enums.DamageType, source: Node)

@export var is_invincible: bool = false

var parent_entity: Node = null


func _ready() -> void:
	parent_entity = get_parent()
	add_to_group("hurtbox")
	
	# Hurtbox csak fogadja a hitbox-ot
	monitoring = false
	monitorable = true


## Invincibility be/ki
func set_invincible(value: bool) -> void:
	is_invincible = value


## Damage fogadása (hitbox hívja)
func receive_damage(amount: float, damage_type: Enums.DamageType, source: Node) -> void:
	if is_invincible:
		return
	damage_received.emit(amount, damage_type, source)
	if parent_entity and parent_entity.has_method("take_damage"):
		parent_entity.take_damage(amount, damage_type)

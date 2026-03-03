## Projectile - Alap lövedék rendszer
## Egyenes vonalú, tracking, és AoE lövedékek
extends Area2D
class_name Projectile

@export var speed: float = 200.0
@export var damage: float = 10.0
@export var damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL
@export var lifetime: float = 5.0
@export var pierce_count: int = 0  # 0 = ütközésnél megsemmisül
@export var aoe_radius: float = 0.0  # 0 = nincs AoE impact
@export var tracking_strength: float = 0.0  # 0 = egyenes vonal

var direction: Vector2 = Vector2.RIGHT
var source: Node = null
var target: Node = null
var hits_remaining: int = 0
var already_hit: Array[Node] = []

# Status effect a lövedéken
var apply_effect: StatusEffect = null


func _ready() -> void:
	hits_remaining = pierce_count + 1
	
	# Lifetime timer
	var timer := Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_expired)
	add_child(timer)
	timer.start()
	
	# Collision setup
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	# Tracking
	if tracking_strength > 0.0 and is_instance_valid(target):
		var to_target := (target.global_position - global_position).normalized()
		direction = direction.lerp(to_target, tracking_strength * delta).normalized()
	
	# Mozgás
	global_position += direction * speed * delta
	rotation = direction.angle()


func setup(
	p_source: Node,
	p_direction: Vector2,
	p_damage: float,
	p_damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL,
	p_target: Node = null,
	p_effect: StatusEffect = null
) -> void:
	source = p_source
	direction = p_direction.normalized()
	damage = p_damage
	damage_type = p_damage_type
	target = p_target
	apply_effect = p_effect
	rotation = direction.angle()


func _on_body_entered(body: Node) -> void:
	if body == source:
		return
	if body in already_hit:
		return
	
	# Fal ütközés
	if body.collision_layer & (1 << (Constants.LAYER_WALL - 1)):
		_impact()
		return
	
	_hit_target(body)


func _on_area_entered(area: Area2D) -> void:
	var parent := area.get_parent()
	if parent == source:
		return
	if parent in already_hit:
		return
	
	# Hurtbox check
	if area.is_in_group("hurtbox"):
		_hit_target(parent)


func _hit_target(target_node: Node) -> void:
	already_hit.append(target_node)
	
	if target_node.has_method("take_damage"):
		target_node.take_damage(damage, damage_type)
		EventBus.damage_dealt.emit(source, target_node, damage, damage_type)
	
	# Status effect alkalmazás
	if apply_effect and target_node.has_node("StatusEffectManager"):
		var effect_copy := StatusEffect.create(
			apply_effect.effect_type,
			apply_effect.duration,
			apply_effect.value,
			source
		)
		target_node.get_node("StatusEffectManager").apply_effect(effect_copy)
	
	hits_remaining -= 1
	if hits_remaining <= 0:
		_impact()


func _impact() -> void:
	# AoE robbanás
	if aoe_radius > 0.0:
		_do_aoe_damage()
	
	queue_free()


func _do_aoe_damage() -> void:
	var space_state := get_world_2d().direct_space_state
	var targets := get_tree().get_nodes_in_group("enemy") if source.is_in_group("player") else get_tree().get_nodes_in_group("player")
	
	for t in targets:
		if t in already_hit:
			continue
		var dist := global_position.distance_to(t.global_position)
		if dist <= aoe_radius:
			if t.has_method("take_damage"):
				var aoe_damage := damage * (1.0 - dist / aoe_radius * 0.5)  # Falloff
				t.take_damage(aoe_damage, damage_type)


func _on_lifetime_expired() -> void:
	queue_free()

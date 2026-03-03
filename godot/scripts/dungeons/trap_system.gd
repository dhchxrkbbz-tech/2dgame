## TrapSystem - Csapda rendszer a dungeon-ökben
## Spike, poison, fire, arrow, falling rocks, pit, curse totem
class_name TrapSystem
extends Node

signal trap_triggered(trap_data: Dictionary, target: Node)

# Csapda konfiguráció
const TRAP_CONFIG: Dictionary = {
	"spike": {
		"damage_percent": 0.15,  # max HP 15%-a
		"trigger": "pressure",
		"cooldown": 3.0,
		"telegraph_time": 0.3,
		"effect": null,
	},
	"poison_gas": {
		"damage_percent": 0.05,  # /sec
		"trigger": "proximity",
		"radius": 48.0,
		"duration": 3.0,
		"effect": Enums.EffectType.POISON_DOT,
		"effect_duration": 3.0,
	},
	"fire_jet": {
		"damage_percent": 0.20,
		"trigger": "timed",
		"interval": 3.0,
		"active_time": 1.0,
		"effect": Enums.EffectType.BURN_DOT,
		"effect_duration": 3.0,
	},
	"arrow": {
		"damage_percent": 0.10,
		"trigger": "tripwire",
		"speed": 200.0,
	},
	"falling_rocks": {
		"damage_percent": 0.25,
		"trigger": "proximity",
		"radius": 32.0,
		"telegraph_time": 1.0,
		"effect": Enums.EffectType.STUN,
		"effect_duration": 1.5,
	},
	"pit": {
		"damage_percent": 0.30,
		"trigger": "step",
		"visible": false,
	},
	"curse_totem": {
		"damage_percent": 0.0,
		"trigger": "aura",
		"radius": 64.0,
		"effect": Enums.EffectType.DAMAGE_DOWN,
		"effect_value": 20.0,
		"effect_duration": 5.0,
		"hp": 100,
	},
}

var active_traps: Array[Dictionary] = []
var trap_nodes: Dictionary = {}  # trap_id -> Node2D


func create_trap(trap_type: String, world_pos: Vector2, trap_id: int = -1) -> Node2D:
	var config: Dictionary = TRAP_CONFIG.get(trap_type, {})
	if config.is_empty():
		return null
	
	var trap_node := Area2D.new()
	trap_node.name = "Trap_%s_%d" % [trap_type, trap_id]
	trap_node.global_position = world_pos
	
	# Collision shape
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = config.get("radius", 16.0)
	shape.shape = circle
	trap_node.add_child(shape)
	
	trap_node.collision_layer = 0
	trap_node.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	
	# Visual
	var sprite := Sprite2D.new()
	var size := int(config.get("radius", 16.0) * 2)
	size = maxi(size, 16)
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var color: Color
	match trap_type:
		"spike": color = Color(0.5, 0.5, 0.5, 0.5)
		"poison_gas": color = Color(0.2, 0.8, 0.2, 0.3)
		"fire_jet": color = Color(1.0, 0.3, 0.0, 0.4)
		"arrow": color = Color(0.6, 0.4, 0.2, 0.5)
		"falling_rocks": color = Color(0.4, 0.3, 0.2, 0.4)
		"pit": color = Color(0.1, 0.1, 0.1, 0.2)
		"curse_totem": color = Color(0.5, 0.0, 0.5, 0.5)
		_: color = Color(0.5, 0.5, 0.5, 0.5)
	img.fill(color)
	sprite.texture = ImageTexture.create_from_image(img)
	trap_node.add_child(sprite)
	
	# Trap data
	var trap_data := {
		"type": trap_type,
		"config": config,
		"id": trap_id,
		"node": trap_node,
		"cooldown_timer": 0.0,
		"is_active": true,
	}
	
	active_traps.append(trap_data)
	trap_nodes[trap_id] = trap_node
	
	# Trigger setup
	match config.get("trigger", ""):
		"pressure", "step", "proximity", "aura":
			trap_node.body_entered.connect(_on_trap_triggered.bind(trap_data))
		"timed":
			_setup_timed_trap(trap_data)
	
	return trap_node


func _on_trap_triggered(body: Node, trap_data: Dictionary) -> void:
	if not body.is_in_group("player"):
		return
	if trap_data["cooldown_timer"] > 0:
		return
	if not trap_data["is_active"]:
		return
	
	_apply_trap_damage(body, trap_data)
	trap_data["cooldown_timer"] = trap_data["config"].get("cooldown", 3.0)
	trap_triggered.emit(trap_data, body)


func _setup_timed_trap(trap_data: Dictionary) -> void:
	var config: Dictionary = trap_data["config"]
	var interval: float = config.get("interval", 3.0)
	
	var timer := Timer.new()
	timer.wait_time = interval
	timer.one_shot = false
	timer.timeout.connect(_on_timed_trap_tick.bind(trap_data))
	trap_data["node"].add_child(timer)
	timer.start()


func _on_timed_trap_tick(trap_data: Dictionary) -> void:
	if not trap_data["is_active"]:
		return
	
	var node: Area2D = trap_data["node"]
	var bodies := node.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			_apply_trap_damage(body, trap_data)


func _apply_trap_damage(target: Node, trap_data: Dictionary) -> void:
	var config: Dictionary = trap_data["config"]
	var damage_percent: float = config.get("damage_percent", 0.1)
	
	# Max HP alapú sebzés
	var max_hp: int = target.get("max_hp") if target.get("max_hp") else 100
	var trap_damage: int = int(max_hp * damage_percent)
	trap_damage = maxi(trap_damage, 1)
	
	if target.has_method("take_damage"):
		target.take_damage(trap_damage, Enums.DamageType.TRUE_DAMAGE)
	
	# Status effect
	var effect_type = config.get("effect", null)
	if effect_type != null and target.has_node("StatusEffectManager"):
		var effect := StatusEffect.create(
			effect_type,
			config.get("effect_duration", 3.0),
			config.get("effect_value", 0.0)
		)
		target.get_node("StatusEffectManager").apply_effect(effect)


func _process(delta: float) -> void:
	for trap_data in active_traps:
		if trap_data["cooldown_timer"] > 0:
			trap_data["cooldown_timer"] -= delta


func disable_trap(trap_id: int) -> void:
	for trap_data in active_traps:
		if trap_data["id"] == trap_id:
			trap_data["is_active"] = false
			if is_instance_valid(trap_data["node"]):
				trap_data["node"].modulate.a = 0.3
			break


func clear_all() -> void:
	for trap_data in active_traps:
		if is_instance_valid(trap_data["node"]):
			trap_data["node"].queue_free()
	active_traps.clear()
	trap_nodes.clear()

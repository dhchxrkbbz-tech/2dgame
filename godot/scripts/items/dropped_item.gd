## DroppedItem - Világban megjelenő loot pickup
## Area2D-alapú interakció, rarity színezés, auto-pickup
class_name DroppedItem
extends Node2D

@export var item_instance: ItemInstance
@export var gold_amount: int = 0

var _velocity := Vector2.ZERO
var _grounded := false
var _bob_time := 0.0
var _auto_pickup_range := 48.0
var _interaction_range := 32.0
var _label_visible := false
var _owner_id: int = -1  # Multiplayer: personal loot
var _lifetime := 120.0  # 2 perc

@onready var _sprite: Sprite2D
@onready var _area: Area2D
@onready var _collision: CollisionShape2D
@onready var _label: Label


func _ready() -> void:
	add_to_group("dropped_items")
	_create_nodes()
	_setup_visuals()
	
	# Pop-out physics
	var angle := randf() * TAU
	_velocity = Vector2(cos(angle), sin(angle)) * randf_range(30, 60)


func _create_nodes() -> void:
	# Sprite
	_sprite = Sprite2D.new()
	add_child(_sprite)
	
	# Interaction area
	_area = Area2D.new()
	_area.collision_layer = 0
	_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	add_child(_area)
	
	_collision = CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = _interaction_range
	_collision.shape = shape
	_area.add_child(_collision)
	
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)
	
	# Label (item neve)
	_label = Label.new()
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-40, -24)
	_label.size = Vector2(80, 16)
	_label.visible = false
	_label.add_theme_font_size_override("font_size", 8)
	add_child(_label)


func _setup_visuals() -> void:
	# Placeholder sprite
	var tex := PlaceholderTexture2D.new()
	
	if gold_amount > 0:
		tex.size = Vector2(8, 8)
		_sprite.modulate = Color(1.0, 0.85, 0.2)
		_label.text = "%d Gold" % gold_amount
		_auto_pickup_range = 64.0
	elif item_instance:
		var rarity_size := {0: 8, 1: 10, 2: 10, 3: 12, 4: 14}
		var s: int = rarity_size.get(item_instance.rarity, 8)
		tex.size = Vector2(s, s)
		_sprite.modulate = _get_rarity_color(item_instance.rarity)
		_label.text = item_instance.get_display_name()
		_label.modulate = _sprite.modulate
		
		# Rarity effektek (glow, particle)
		DropDisplay.add_glow(self, item_instance.rarity)
		DropDisplay.add_particles(self, item_instance.rarity)
	else:
		tex.size = Vector2(8, 8)
		_sprite.modulate = Color.WHITE
	
	_sprite.texture = tex


func _get_rarity_color(rarity: int) -> Color:
	return Constants.RARITY_COLORS.get(rarity, Color.WHITE)


func _process(delta: float) -> void:
	# Pop-out mozgás
	if not _grounded:
		_velocity *= 0.92
		position += _velocity * delta
		if _velocity.length() < 2.0:
			_grounded = true
	
	# Lebegtetés
	_bob_time += delta * 3.0
	_sprite.position.y = sin(_bob_time) * 2.0
	
	# Lifetime
	_lifetime -= delta
	if _lifetime <= 0:
		queue_free()
		return
	
	# Villogás ha hamarosan eltűnik
	if _lifetime < 10.0:
		_sprite.visible = fmod(_lifetime, 0.3) > 0.15
	
	# Auto-pickup check
	if _grounded:
		_check_auto_pickup()


func _check_auto_pickup() -> void:
	var players := get_tree().get_nodes_in_group("player")
	for player in players:
		if not player is CharacterBody2D:
			continue
		var dist := global_position.distance_to(player.global_position)
		
		# Gold auto-pickup
		if gold_amount > 0 and dist < _auto_pickup_range:
			_pickup(player)
			return
		
		# Material/consumable auto-pickup (LootFilter alapján)
		if item_instance and dist < _auto_pickup_range:
			if LootManager and LootManager.filter.should_auto_pickup(item_instance):
				_pickup(player)
				return
			return


func _on_body_entered(_body: Node2D) -> void:
	_label.visible = true


func _on_body_exited(_body: Node2D) -> void:
	_label.visible = false


func pickup_requested(player: Node) -> void:
	if not _grounded:
		return
	var dist := global_position.distance_to(player.global_position)
	if dist > _interaction_range * 1.5:
		return
	_pickup(player)


func _pickup(player: Node) -> void:
	if gold_amount > 0:
		EventBus.emit_signal("gold_collected", gold_amount)
	elif item_instance:
		EventBus.emit_signal("item_picked_up", item_instance)
	
	# Pickup effect
	var tween := create_tween()
	tween.tween_property(self, "position", player.global_position, 0.15)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.1)
	tween.tween_callback(queue_free)


## Factory: item drop létrehozás
static func create_item_drop(item: ItemInstance, pos: Vector2) -> DroppedItem:
	var drop := DroppedItem.new()
	drop.item_instance = item
	drop.position = pos
	return drop


## Factory: gold drop létrehozás
static func create_gold_drop(amount: int, pos: Vector2) -> DroppedItem:
	var drop := DroppedItem.new()
	drop.gold_amount = amount
	drop.position = pos
	return drop

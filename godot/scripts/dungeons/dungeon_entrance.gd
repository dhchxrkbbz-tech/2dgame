## DungeonEntrance - Dungeon belépési pont a világban
## POI-ként generálva, interakcióval belépés
class_name DungeonEntrance
extends Node2D

@export var dungeon_tier: int = 1
@export var dungeon_biome: int = 0
@export var dungeon_level: int = 1
@export var dungeon_name: String = "Dungeon"

var _area: Area2D
var _label: Label
var _sprite: Sprite2D
var _player_nearby: bool = false


func _ready() -> void:
	add_to_group("dungeon_entrance")
	_create_nodes()


func _create_nodes() -> void:
	# Vizuális megjelenítés
	_sprite = Sprite2D.new()
	var tex := PlaceholderTexture2D.new()
	tex.size = Vector2(24, 32)
	_sprite.texture = tex
	_sprite.modulate = Color(0.3, 0.25, 0.3)
	add_child(_sprite)
	
	# Interaction area
	_area = Area2D.new()
	_area.collision_layer = 0
	_area.collision_mask = Constants.COLLISION_LAYERS["player_hitbox"]
	add_child(_area)
	
	var col := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 32.0
	col.shape = shape
	_area.add_child(col)
	
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)
	
	# Név label
	_label = Label.new()
	_label.text = dungeon_name
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-40, -30)
	_label.size = Vector2(80, 16)
	_label.visible = false
	_label.add_theme_font_size_override("font_size", 8)
	_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	add_child(_label)


func _unhandled_input(event: InputEvent) -> void:
	if _player_nearby and event.is_action_pressed("interact"):
		_enter_dungeon()


func _on_body_entered(_body: Node2D) -> void:
	_player_nearby = true
	_label.visible = true
	_label.text = "%s (E)" % dungeon_name


func _on_body_exited(_body: Node2D) -> void:
	_player_nearby = false
	_label.visible = false


func _enter_dungeon() -> void:
	var game_world = get_tree().current_scene
	if game_world and game_world.has_method("enter_dungeon"):
		game_world.enter_dungeon(dungeon_tier, dungeon_biome, dungeon_level)


## Factory: dungeon entrance létrehozás
static func create(pos: Vector2, tier: int, biome: int, level: int, dname: String = "") -> DungeonEntrance:
	var entrance := DungeonEntrance.new()
	entrance.global_position = pos
	entrance.dungeon_tier = tier
	entrance.dungeon_biome = biome
	entrance.dungeon_level = level
	entrance.dungeon_name = dname if dname != "" else "Tier %d Dungeon" % tier
	return entrance

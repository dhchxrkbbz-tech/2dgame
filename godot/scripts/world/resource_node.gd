## ResourceNode - Gyűjthető erőforrás node a világban
## Interakció alapú, profession rendszerrel összekötve
class_name ResourceNode
extends StaticBody2D

signal gathered(player: Node, drops: Array[Dictionary])
signal depleted()

# === Beállítások ===
@export var resource_type: String = "stone"  # stone, ore, crystal, herb, wood, bone
@export var resource_tier: int = 1           # 1-4 (biome progression)
@export var required_profession: String = "" # mining, herbalism, woodcutting, skinning
@export var required_level: int = 1          # Minimum profession level
@export var gather_time: float = 2.0         # Gyűjtési idő másodpercben
@export var uses: int = 3                    # Hányszor gyűjthető
@export var respawn_time: float = 60.0       # Respawn idő

var current_uses: int = 0
var is_depleted: bool = false
var respawn_timer: float = 0.0
var biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW

# === Visual ===
var sprite: Sprite2D
var interaction_area: Area2D
var collision_shape: CollisionShape2D

# === Gyűjtés állapot ===
var is_being_gathered: bool = false
var gatherer: Node = null
var gather_progress: float = 0.0

# === Drop table ===
const RESOURCE_DROPS: Dictionary = {
	"stone": {"base_item": "stone", "amount_range": Vector2i(1, 3)},
	"ore": {"base_item": "iron_ore", "amount_range": Vector2i(1, 2)},
	"crystal": {"base_item": "ember_coal", "amount_range": Vector2i(1, 1)},
	"herb": {"base_item": "herb", "amount_range": Vector2i(1, 3)},
	"dark_root": {"base_item": "dark_root", "amount_range": Vector2i(1, 2)},
	"wood": {"base_item": "wood", "amount_range": Vector2i(2, 4)},
	"bone": {"base_item": "bone_fragment", "amount_range": Vector2i(1, 3)},
}

# Profession mapping
const PROFESSION_MAP: Dictionary = {
	"stone": "mining",
	"ore": "mining",
	"crystal": "mining",
	"herb": "herbalism",
	"dark_root": "herbalism",
	"wood": "woodcutting",
	"bone": "skinning",
}


func _ready() -> void:
	add_to_group("resource_nodes")
	current_uses = uses
	
	# Required profession automatikus beállítása
	if required_profession.is_empty():
		required_profession = PROFESSION_MAP.get(resource_type, "")
	
	_create_visual()
	_create_interaction_area()


func _process(delta: float) -> void:
	# Respawn
	if is_depleted:
		respawn_timer -= delta
		if respawn_timer <= 0.0:
			_respawn()
		return
	
	# Gyűjtés progress
	if is_being_gathered and gatherer:
		gather_progress += delta
		if gather_progress >= gather_time:
			_complete_gather()


func _create_visual() -> void:
	sprite = Sprite2D.new()
	sprite.name = "Sprite"
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	var color: Color
	match resource_type:
		"stone", "ore", "crystal": color = Color(0.5, 0.5, 0.6)
		"herb", "dark_root": color = Color(0.2, 0.7, 0.3)
		"wood": color = Color(0.6, 0.4, 0.2)
		"bone": color = Color(0.9, 0.9, 0.8)
		_: color = Color(0.7, 0.7, 0.7)
	img.fill(color)
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)


func _create_interaction_area() -> void:
	interaction_area = Area2D.new()
	interaction_area.name = "InteractionArea"
	interaction_area.collision_layer = 0
	interaction_area.collision_mask = 1  # Player layer
	
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 24.0
	shape.shape = circle
	interaction_area.add_child(shape)
	add_child(interaction_area)
	
	# Saját collision
	collision_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(14, 14)
	collision_shape.shape = rect
	add_child(collision_shape)


## Gyűjtés indítása
func start_gather(player: Node) -> bool:
	if is_depleted or is_being_gathered:
		return false
	
	# Profession check
	if not required_profession.is_empty():
		if player.has_method("get_profession_level"):
			var level: int = player.get_profession_level(required_profession)
			if level < required_level:
				EventBus.notification_requested.emit(
					"Szükséges: %s Level %d" % [required_profession.capitalize(), required_level]
				)
				return false
	
	is_being_gathered = true
	gatherer = player
	gather_progress = 0.0
	return true


## Gyűjtés megszakítása
func cancel_gather() -> void:
	is_being_gathered = false
	gatherer = null
	gather_progress = 0.0


## Gyűjtés befejezése
func _complete_gather() -> void:
	if not gatherer:
		return
	
	var drops := _generate_drops()
	gathered.emit(gatherer, drops)
	
	# XP a profession-höz
	if gatherer.has_method("add_profession_xp"):
		gatherer.add_profession_xp(required_profession, 10 * resource_tier)
	
	# Drop-ok hozzáadása
	for drop in drops:
		EventBus.item_picked_up.emit(drop)
	
	current_uses -= 1
	is_being_gathered = false
	gatherer = null
	gather_progress = 0.0
	
	if current_uses <= 0:
		_deplete()


func _generate_drops() -> Array[Dictionary]:
	var drops: Array[Dictionary] = []
	var drop_info: Dictionary = RESOURCE_DROPS.get(resource_type, {})
	
	if drop_info.is_empty():
		return drops
	
	var amount_range: Vector2i = drop_info.get("amount_range", Vector2i(1, 1))
	var amount: int = randi_range(amount_range.x, amount_range.y)
	
	# Tier bónusz
	amount += resource_tier - 1
	
	drops.append({
		"item_id": drop_info.get("base_item", "unknown"),
		"amount": amount,
		"tier": resource_tier,
	})
	
	# Ritka drop esély (profession szint alapján)
	var rare_chance: float = 0.05 * resource_tier
	if randf() < rare_chance:
		drops.append({
			"item_id": "rare_" + resource_type,
			"amount": 1,
			"tier": resource_tier + 1,
		})
	
	return drops


func _deplete() -> void:
	is_depleted = true
	respawn_timer = respawn_time
	if sprite:
		sprite.modulate = Color(0.3, 0.3, 0.3, 0.5)
	depleted.emit()


func _respawn() -> void:
	is_depleted = false
	current_uses = uses
	respawn_timer = 0.0
	if sprite:
		sprite.modulate = Color.WHITE

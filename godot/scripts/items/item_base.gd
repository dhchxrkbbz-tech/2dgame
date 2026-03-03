## ItemBase - Alap item osztály (scene script)
## Fizikai item a játékvilágban (felszedhtő, interakcióra reagáló)
class_name ItemBase
extends Node2D

signal picked_up(by_player: Node)
signal expired()

@export var item_data: Resource  # ItemData típusú
@export var auto_pickup: bool = false
@export var pickup_delay: float = 0.5
@export var lifetime: float = 300.0  # 5 perc

var item_instance: RefCounted = null  # ItemInstance
var is_pickupable: bool = false
var pickup_timer: float = 0.0
var life_timer: float = 0.0
var owner_peer_id: int = -1  # Multiplayer: ki látja

# === Visual ===
var sprite: Sprite2D
var rarity_glow: bool = false
var bob_timer: float = 0.0
const BOB_SPEED: float = 2.0
const BOB_AMOUNT: float = 3.0


func _ready() -> void:
	add_to_group("dropped_items")
	_create_visual()
	pickup_timer = pickup_delay


func _process(delta: float) -> void:
	# Pickup delay
	if not is_pickupable:
		pickup_timer -= delta
		if pickup_timer <= 0:
			is_pickupable = true
	
	# Lifetime
	life_timer += delta
	if life_timer >= lifetime:
		expired.emit()
		queue_free()
		return
	
	# Bob effect
	bob_timer += delta * BOB_SPEED
	if sprite:
		sprite.offset.y = sin(bob_timer) * BOB_AMOUNT


func _create_visual() -> void:
	sprite = Sprite2D.new()
	sprite.name = "Sprite"
	# Placeholder visual
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.8, 0.2))
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)


## Felszedés kérelem (player hívja)
func pickup_requested(player: Node) -> bool:
	if not is_pickupable:
		return false
	
	# Multiplayer: csak a tulajdonos szedheti fel
	if owner_peer_id >= 0:
		var peer_id: int = player.get_multiplayer_authority() if player.has_method("get_multiplayer_authority") else 1
		if peer_id != owner_peer_id:
			return false
	
	picked_up.emit(player)
	EventBus.item_picked_up.emit(item_instance)
	queue_free()
	return true


## Item setup (spawner hívja)
func setup(p_item_instance: RefCounted, p_owner: int = -1) -> void:
	item_instance = p_item_instance
	owner_peer_id = p_owner
	_update_visual()


func _update_visual() -> void:
	if not item_instance or not sprite:
		return
	# Rarity-alapú szín
	if item_instance.has_method("get_rarity"):
		var rarity = item_instance.get_rarity()
		var color: Color = Constants.RARITY_COLORS.get(rarity, Color.WHITE)
		sprite.modulate = color

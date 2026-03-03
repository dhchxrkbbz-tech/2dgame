## GatheringNode - Világ resource node component
## Fa, kő, érc, herb stb. összegyűjtése channeling-gel
extends Area2D
class_name GatheringNode

@export var node_type: Enums.GatheringNodeType = Enums.GatheringNodeType.WOOD
@export var override_material_id: String = ""  # Ha üres, a node_type alapján generáljuk

## Állapot
var _is_depleted: bool = false
var _respawn_timer: Timer = null
var _is_being_gathered: bool = false
var _gather_progress: float = 0.0
var _gatherer: Node = null

## Vizuális
var _sprite: Sprite2D = null
var _progress_bar: Node = null


func _ready() -> void:
	# Collision setup (Interaction layer)
	collision_layer = 0
	collision_mask = 0
	set_collision_layer_value(Constants.LAYER_INTERACTION, true)
	
	# Respawn timer
	_respawn_timer = Timer.new()
	_respawn_timer.one_shot = true
	_respawn_timer.timeout.connect(_on_respawn)
	add_child(_respawn_timer)
	
	# Vizuális placeholder
	_setup_placeholder_sprite()
	
	# Interaction jelzés
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


## Gathering indítása
func start_gathering(gatherer: Node) -> bool:
	if _is_depleted or _is_being_gathered:
		return false
	
	_is_being_gathered = true
	_gatherer = gatherer
	_gather_progress = 0.0
	
	EventBus.gathering_started.emit(node_type)
	return true


## Gathering megszakítása
func cancel_gathering() -> void:
	if not _is_being_gathered:
		return
	_is_being_gathered = false
	_gatherer = null
	_gather_progress = 0.0
	EventBus.gathering_interrupted.emit()


func _process(delta: float) -> void:
	if not _is_being_gathered or _is_depleted:
		return
	
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var channel_time: float = node_data.get("channel_time", 2.0)
	
	# Tool tier szorzó alkalmazás
	var speed_mult := _get_tool_speed_multiplier()
	_gather_progress += delta * speed_mult
	
	if _gather_progress >= channel_time:
		_complete_gathering()


## Gathering befejezése
func _complete_gathering() -> void:
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var yield_min: int = node_data.get("yield_min", 1)
	var yield_max: int = node_data.get("yield_max", 3)
	var respawn_time: float = node_data.get("respawn", 300.0)
	
	# Yield szorzó tool tier-ből
	var yield_mult := _get_tool_yield_multiplier()
	var base_yield := randi_range(yield_min, yield_max)
	var final_yield := int(base_yield * yield_mult)
	final_yield = maxi(1, final_yield)
	
	# Material item létrehozása és inventory-ba rakás
	var material_id := _get_material_id()
	_give_material_to_player(material_id, final_yield)
	
	# Profession XP
	_grant_profession_xp()
	
	# Node kimerítése
	_is_depleted = true
	_is_being_gathered = false
	_gatherer = null
	_gather_progress = 0.0
	
	# Vizuális frissítés
	_update_depleted_visual(true)
	
	# Respawn timer
	_respawn_timer.wait_time = respawn_time
	_respawn_timer.start()
	
	EventBus.gathering_completed.emit(node_type, final_yield)


## Respawn
func _on_respawn() -> void:
	_is_depleted = false
	_update_depleted_visual(false)


## Material ID meghatározás node type alapján
func _get_material_id() -> String:
	if not override_material_id.is_empty():
		return override_material_id
	
	match node_type:
		Enums.GatheringNodeType.WOOD: return "wood"
		Enums.GatheringNodeType.STONE: return "stone"
		Enums.GatheringNodeType.ORE: return "iron_ore"
		Enums.GatheringNodeType.HERB: return "red_herb"
		Enums.GatheringNodeType.CRYSTAL: return "crystal"
		Enums.GatheringNodeType.DARK_ROOT: return "dark_root"
		Enums.GatheringNodeType.BONE: return "bone"
		Enums.GatheringNodeType.EMBER_COAL: return "ember_coal"
		_: return "unknown_material"


## Material átadás a játékosnak
func _give_material_to_player(material_id: String, amount: int) -> void:
	var economy = get_node_or_null("/root/EconomyManager")
	if not economy:
		return
	
	var inv_mgr: InventoryManager = economy.inventory_manager
	if not inv_mgr:
		return
	
	# Material item keresése az adatbázisban, vagy generálás
	var base_item: ItemData = ItemDatabase.get_item(material_id)
	if not base_item:
		base_item = ItemData.new()
		base_item.item_id = material_id
		base_item.item_name = material_id.replace("_", " ").capitalize()
		base_item.item_type = Enums.ItemType.MATERIAL
		base_item.stackable = true
		base_item.max_stack = Constants.STACK_LIMIT_MATERIAL
		base_item.sell_price = 1
	
	var instance := ItemInstance.new()
	instance.base_item = base_item
	instance.item_level = 1
	instance.rarity = Enums.Rarity.COMMON
	instance.quantity = amount
	
	inv_mgr.add_item(instance)


## Profession XP adás
func _grant_profession_xp() -> void:
	var economy = get_node_or_null("/root/EconomyManager")
	if not economy or not economy.profession_manager:
		return
	
	var profession_type := ProfessionManager.get_profession_for_node(node_type)
	if profession_type >= 0:
		var xp := 10 + randi_range(0, 5)
		economy.profession_manager.add_xp(profession_type, xp)


## Tool tier szorzók (TODO: a player aktuális tool-ja alapján)
func _get_tool_speed_multiplier() -> float:
	# Placeholder: alap tool
	var tier := Enums.ToolTier.BASIC
	return Constants.TOOL_TIER_MULTIPLIERS[tier]["speed"]


func _get_tool_yield_multiplier() -> float:
	var tier := Enums.ToolTier.BASIC
	return Constants.TOOL_TIER_MULTIPLIERS[tier]["yield"]


## Gathering állapot lekérdezések
func is_depleted() -> bool:
	return _is_depleted


func is_being_gathered() -> bool:
	return _is_being_gathered


func get_gather_progress() -> float:
	if not _is_being_gathered:
		return 0.0
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var channel_time: float = node_data.get("channel_time", 2.0)
	if channel_time <= 0:
		return 1.0
	return clampf(_gather_progress / channel_time, 0.0, 1.0)


func get_node_type_name() -> String:
	match node_type:
		Enums.GatheringNodeType.WOOD: return "Tree"
		Enums.GatheringNodeType.STONE: return "Stone"
		Enums.GatheringNodeType.ORE: return "Ore Vein"
		Enums.GatheringNodeType.HERB: return "Herb"
		Enums.GatheringNodeType.CRYSTAL: return "Crystal"
		Enums.GatheringNodeType.DARK_ROOT: return "Dark Root"
		Enums.GatheringNodeType.BONE: return "Bone Pile"
		Enums.GatheringNodeType.EMBER_COAL: return "Ember Coal"
		_: return "Resource"


# ============================================================
#  VIZUÁLIS
# ============================================================

func _setup_placeholder_sprite() -> void:
	_sprite = Sprite2D.new()
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(_get_node_color())
	_sprite.texture = ImageTexture.create_from_image(img)
	add_child(_sprite)
	
	# Collision shape
	var collision := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16.0
	collision.shape = shape
	add_child(collision)


func _get_node_color() -> Color:
	match node_type:
		Enums.GatheringNodeType.WOOD: return Color(0.4, 0.25, 0.1)
		Enums.GatheringNodeType.STONE: return Color(0.5, 0.5, 0.5)
		Enums.GatheringNodeType.ORE: return Color(0.6, 0.4, 0.2)
		Enums.GatheringNodeType.HERB: return Color(0.2, 0.7, 0.2)
		Enums.GatheringNodeType.CRYSTAL: return Color(0.5, 0.7, 0.9)
		Enums.GatheringNodeType.DARK_ROOT: return Color(0.3, 0.1, 0.3)
		Enums.GatheringNodeType.BONE: return Color(0.9, 0.85, 0.7)
		Enums.GatheringNodeType.EMBER_COAL: return Color(0.8, 0.3, 0.1)
		_: return Color.WHITE


func _update_depleted_visual(depleted: bool) -> void:
	if _sprite:
		_sprite.modulate = Color(0.3, 0.3, 0.3, 0.5) if depleted else Color.WHITE


func _on_body_entered(_body: Node2D) -> void:
	# Interaction jelzés (TODO: "E" ikon megjelenítés)
	pass


func _on_body_exited(_body: Node2D) -> void:
	if _body == _gatherer:
		cancel_gathering()

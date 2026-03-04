## DungeonLootSpawner - Chest elhelyezés és loot generálás
## Chest típusok, rarity, mimic, loot table integráció
class_name DungeonLootSpawner
extends Node

signal chest_placed(chest_data: Dictionary)
signal loot_dropped(items: Array, position: Vector2)

## Chest típus konfiguráció
const CHEST_CONFIG: Dictionary = {
	"common": {
		"rarity": 0,  # Enums.Rarity.COMMON
		"item_count": Vector2i(1, 3),
		"gold_range": Vector2i(5, 25),
		"color": Color(0.6, 0.5, 0.3, 0.8),
	},
	"uncommon": {
		"rarity": 1,  # Enums.Rarity.UNCOMMON
		"item_count": Vector2i(1, 2),
		"gold_range": Vector2i(15, 45),
		"has_crafting_mat": true,
		"color": Color(0.2, 0.7, 0.2, 0.8),
	},
	"rare": {
		"rarity": 2,  # Enums.Rarity.RARE
		"item_count": Vector2i(1, 2),
		"gold_range": Vector2i(30, 80),
		"has_dark_essence": true,
		"color": Color(0.2, 0.4, 0.9, 0.8),
	},
	"boss": {
		"rarity": 3,  # Enums.Rarity.EPIC
		"item_count": Vector2i(2, 3),
		"gold_range": Vector2i(80, 200),
		"has_dark_essence": true,
		"color": Color(0.8, 0.5, 0.0, 0.9),
	},
}

## Loot rarity esélyek difficulty alapján
const LOOT_RARITY_WEIGHTS: Dictionary = {
	# [Common, Uncommon, Rare, Epic] (0-100%)
	1: [60, 30, 9, 1],
	2: [60, 30, 9, 1],
	3: [60, 30, 9, 1],
	4: [40, 40, 17, 3],
	5: [40, 40, 17, 3],
	6: [40, 40, 17, 3],
	7: [20, 40, 30, 10],
	8: [20, 40, 30, 10],
	9: [10, 30, 40, 20],
	10: [10, 30, 40, 20],
}

## Mimic esély
const MIMIC_CHANCE: float = 0.20

var rng: RandomNumberGenerator
var dungeon_difficulty: int = 1
var chest_system: ChestSystem = null
var placed_chests: Array[Dictionary] = []


func _init() -> void:
	rng = RandomNumberGenerator.new()


func initialize(difficulty: int, p_chest_system: ChestSystem = null, seed_val: int = -1) -> void:
	dungeon_difficulty = difficulty
	chest_system = p_chest_system
	if seed_val >= 0:
		rng.seed = seed_val


## Szoba chest-jeinek elhelyezése
func place_room_chests(room: DungeonRoom, parent: Node2D) -> Array[Node2D]:
	var chest_nodes: Array[Node2D] = []
	
	match room.room_type:
		DungeonRoom.RoomType.COMBAT:
			# 30% esély bonus chest-re
			if rng.randf() < 0.3:
				var pos := room.get_world_center() + Vector2(rng.randf_range(-32, 32), rng.randf_range(-32, 32))
				var node := _create_chest("common", pos, false, parent)
				if node:
					chest_nodes.append(node)
		
		DungeonRoom.RoomType.TREASURE:
			# Fő chest (jobb rarity)
			var main_chest_type := _get_treasure_chest_type()
			var center := room.get_world_center()
			var is_mimic := rng.randf() < MIMIC_CHANCE
			var main := _create_chest(main_chest_type, center, is_mimic, parent)
			if main:
				chest_nodes.append(main)
			
			# Side chests
			var side_count := rng.randi_range(0, 2)
			for i in side_count:
				var offset := Vector2(rng.randf_range(-48, 48), rng.randf_range(-32, 32))
				var side := _create_chest("common", center + offset, false, parent)
				if side:
					chest_nodes.append(side)
		
		DungeonRoom.RoomType.BOSS:
			# Garantált boss chest
			var center := room.get_world_center()
			var boss_chest := _create_chest("boss", center, false, parent)
			if boss_chest:
				chest_nodes.append(boss_chest)
		
		DungeonRoom.RoomType.SECRET:
			# Kiváló loot
			var center := room.get_world_center()
			var secret := _create_chest("rare", center, false, parent)
			if secret:
				chest_nodes.append(secret)
		
		DungeonRoom.RoomType.SAFE:
			# Heal fountain
			var center := room.get_world_center()
			var fountain := _create_heal_fountain(center, parent)
			if fountain:
				chest_nodes.append(fountain)
	
	return chest_nodes


## Folyosó chest elhelyezés
func place_corridor_chests(corridor_chest_data: Array[Dictionary], parent: Node2D) -> Array[Node2D]:
	var nodes: Array[Node2D] = []
	
	for data in corridor_chest_data:
		var pos: Vector2i = data.get("pos", Vector2i.ZERO)
		var world_pos := Vector2(pos.x * Constants.TILE_SIZE, pos.y * Constants.TILE_SIZE)
		var node := _create_chest("common", world_pos, false, parent)
		if node:
			nodes.append(node)
	
	return nodes


## Chest node létrehozás
func _create_chest(chest_type: String, world_pos: Vector2, is_mimic: bool, parent: Node2D) -> Node2D:
	var config: Dictionary = CHEST_CONFIG.get(chest_type, CHEST_CONFIG["common"])
	
	var chest_data := {
		"chest_type": chest_type,
		"rarity": config["rarity"],
		"is_mimic": is_mimic,
		"world_pos": world_pos,
	}
	
	# ChestSystem használata ha elérhető
	if chest_system:
		return chest_system.create_chest(chest_data, world_pos, parent)
	
	# Fallback: egyszerű chest node
	var chest_node := Area2D.new()
	chest_node.name = "Chest_%s_%d" % [chest_type, placed_chests.size()]
	chest_node.global_position = world_pos
	chest_node.collision_layer = 1 << (Constants.LAYER_INTERACTION - 1)
	chest_node.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 20)
	shape.shape = rect
	chest_node.add_child(shape)
	
	var sprite := Sprite2D.new()
	var img := Image.create(24, 20, false, Image.FORMAT_RGBA8)
	img.fill(config["color"])
	sprite.texture = ImageTexture.create_from_image(img)
	chest_node.add_child(sprite)
	
	chest_data["node"] = chest_node
	placed_chests.append(chest_data)
	chest_placed.emit(chest_data)
	
	parent.add_child(chest_node)
	return chest_node


## Heal fountain létrehozás
func _create_heal_fountain(world_pos: Vector2, parent: Node2D) -> Node2D:
	var fountain_data := {
		"type": "heal_fountain",
		"used": false,
		"world_pos": world_pos,
	}
	
	if chest_system:
		return chest_system.create_chest(fountain_data, world_pos, parent)
	
	var fountain := Area2D.new()
	fountain.name = "HealFountain"
	fountain.global_position = world_pos
	
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	fountain.add_child(shape)
	
	var sprite := Sprite2D.new()
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.6, 1.0, 0.8))
	sprite.texture = ImageTexture.create_from_image(img)
	fountain.add_child(sprite)
	
	parent.add_child(fountain)
	return fountain


## Treasure room chest típus (difficulty alapján)
func _get_treasure_chest_type() -> String:
	if dungeon_difficulty <= 3:
		return "uncommon" if rng.randf() < 0.6 else "rare"
	elif dungeon_difficulty <= 6:
		return "rare" if rng.randf() < 0.6 else "uncommon"
	else:
		return "rare" if rng.randf() < 0.7 else "boss"


## Loot generálás chest-ből
func generate_chest_loot(chest_type: String) -> Array[Dictionary]:
	var config: Dictionary = CHEST_CONFIG.get(chest_type, CHEST_CONFIG["common"])
	var items: Array[Dictionary] = []
	
	var item_count: int = rng.randi_range(config["item_count"].x, config["item_count"].y)
	var weights: Array = LOOT_RARITY_WEIGHTS.get(dungeon_difficulty, LOOT_RARITY_WEIGHTS[1])
	
	for i in item_count:
		var rarity := _roll_rarity(weights)
		items.append({
			"type": "item",
			"item_type": _random_item_type(),
			"rarity": rarity,
			"level": dungeon_difficulty,
		})
	
	# Gold
	var gold: int = rng.randi_range(config["gold_range"].x, config["gold_range"].y)
	items.append({"type": "gold", "amount": gold})
	
	# Extra crafting material
	if config.get("has_crafting_mat", false):
		items.append({"type": "material", "rarity": Enums.Rarity.UNCOMMON})
	
	# Dark essence
	if config.get("has_dark_essence", false):
		items.append({"type": "dark_essence", "amount": rng.randi_range(1, 3)})
	
	return items


func _roll_rarity(weights: Array) -> int:
	var total: int = 0
	for w in weights:
		total += w
	
	var roll := rng.randi_range(0, total - 1)
	var cumulative := 0
	for i in weights.size():
		cumulative += weights[i]
		if roll < cumulative:
			return i
	
	return 0  # COMMON fallback


func _random_item_type() -> String:
	var types := ["weapon", "armor", "accessory", "material"]
	return types[rng.randi() % types.size()]


## Cleanup
func clear_all() -> void:
	for chest in placed_chests:
		if is_instance_valid(chest.get("node")):
			chest["node"].queue_free()
	placed_chests.clear()


## DungeonManager által hívott: szoba loot elhelyezése
func spawn_room_loot(room: DungeonRoom, difficulty: int, parent: Node2D) -> void:
	dungeon_difficulty = difficulty
	var chest_nodes := place_room_chests(room, parent)
	
	# Chest-ekhez loot generálás és hozzárendelés
	for node in chest_nodes:
		if not is_instance_valid(node):
			continue
		var chest_type := "common"
		if node.name.contains("rare") or node.name.contains("Rare"):
			chest_type = "rare"
		elif node.name.contains("uncommon") or node.name.contains("Uncommon"):
			chest_type = "uncommon"
		elif node.name.contains("boss") or node.name.contains("Boss"):
			chest_type = "boss"
		
		var loot := generate_chest_loot(chest_type)
		if loot.size() > 0:
			# Loot adat hozzárendelés a chest node-hoz
			node.set_meta("loot_data", loot)
			node.set_meta("chest_type", chest_type)
			loot_dropped.emit(loot, node.global_position)


## DungeonManager által hívott: heal fountain elhelyezése
func spawn_heal_fountain(world_pos: Vector2, parent: Node2D) -> void:
	_create_heal_fountain(world_pos, parent)

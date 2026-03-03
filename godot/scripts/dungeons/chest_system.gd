## ChestSystem - Chest és loot drop kezelés dungeon-ökben
## Chest típusok, mimic, heal fountain
class_name ChestSystem
extends Node

signal chest_opened(chest_data: Dictionary, position: Vector2)
signal mimic_triggered(position: Vector2)

var active_chests: Array[Dictionary] = []


func create_chest(chest_data: Dictionary, world_pos: Vector2, parent: Node2D) -> Node2D:
	var chest_node := Area2D.new()
	chest_node.name = "Chest_%d" % active_chests.size()
	chest_node.global_position = world_pos
	
	# Interaction area
	chest_node.collision_layer = 1 << (Constants.LAYER_INTERACTION - 1)
	chest_node.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(24, 20)
	shape.shape = rect
	chest_node.add_child(shape)
	
	# Visual
	var sprite := Sprite2D.new()
	var is_fountain := chest_data.get("type", "") == "heal_fountain"
	var img := Image.create(24, 20, false, Image.FORMAT_RGBA8)
	
	if is_fountain:
		img.fill(Color(0.3, 0.6, 1.0, 0.8))
	else:
		var rarity: int = chest_data.get("rarity", Enums.Rarity.COMMON)
		img.fill(_get_chest_color(rarity))
	
	sprite.texture = ImageTexture.create_from_image(img)
	chest_node.add_child(sprite)
	
	# Label
	var label := Label.new()
	if is_fountain:
		label.text = "Heal"
	else:
		label.text = "Chest"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.position = Vector2(-16, -24)
	label.add_theme_font_size_override("font_size", 8)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 1)
	label.visible = false
	chest_node.add_child(label)
	
	# Hover effect
	chest_node.body_entered.connect(func(body):
		if body.is_in_group("player"):
			label.visible = true
	)
	chest_node.body_exited.connect(func(body):
		if body.is_in_group("player"):
			label.visible = false
	)
	
	# Store data
	var full_data := chest_data.duplicate()
	full_data["node"] = chest_node
	full_data["opened"] = false
	full_data["world_pos"] = world_pos
	active_chests.append(full_data)
	
	parent.add_child(chest_node)
	return chest_node


func interact_with_nearest(player_pos: Vector2) -> void:
	var nearest_dist: float = Constants.ITEM_PICKUP_RANGE
	var nearest_chest: Dictionary = {}
	
	for chest_data in active_chests:
		if chest_data.get("opened", false):
			continue
		var pos: Vector2 = chest_data.get("world_pos", Vector2.ZERO)
		var dist := player_pos.distance_to(pos)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_chest = chest_data
	
	if nearest_chest.is_empty():
		return
	
	_open_chest(nearest_chest)


func _open_chest(chest_data: Dictionary) -> void:
	if chest_data.get("opened", false):
		return
	
	chest_data["opened"] = true
	
	# Heal fountain
	if chest_data.get("type", "") == "heal_fountain":
		if chest_data.get("used", false):
			EventBus.show_notification.emit("Already used", Enums.NotificationType.WARNING)
			return
		chest_data["used"] = true
		# Full heal minden player-t
		for p in get_tree().get_nodes_in_group("player"):
			if p.has_method("heal"):
				p.heal(p.max_hp)
		EventBus.show_notification.emit("Fully Healed!", Enums.NotificationType.INFO)
		if is_instance_valid(chest_data.get("node")):
			chest_data["node"].modulate = Color(0.5, 0.5, 0.5)
		return
	
	# Mimic ellenőrzés
	if chest_data.get("is_mimic", false):
		mimic_triggered.emit(chest_data.get("world_pos", Vector2.ZERO))
		EventBus.show_notification.emit("It's a Mimic!", Enums.NotificationType.WARNING)
		# Mimic enemy spawn
		_spawn_mimic(chest_data)
		return
	
	# Normál chest: loot drop
	var rarity: int = chest_data.get("rarity", Enums.Rarity.COMMON)
	var loot_count := _get_loot_count(rarity)
	
	for i in loot_count:
		var item := _generate_chest_loot(rarity)
		EventBus.item_dropped.emit(item, chest_data.get("world_pos", Vector2.ZERO) + Vector2(randf_range(-16, 16), randf_range(-16, 16)))
	
	# Gold
	var gold_amount := _get_gold_for_rarity(rarity)
	EventBus.item_dropped.emit({"type": "gold", "amount": gold_amount}, chest_data.get("world_pos", Vector2.ZERO))
	
	chest_opened.emit(chest_data, chest_data.get("world_pos", Vector2.ZERO))
	
	# Visual: nyitott chest
	if is_instance_valid(chest_data.get("node")):
		chest_data["node"].modulate = Color(0.5, 0.5, 0.5)
	
	EventBus.show_notification.emit("Chest Opened!", Enums.NotificationType.LOOT)


func _spawn_mimic(chest_data: Dictionary) -> void:
	var pos: Vector2 = chest_data.get("world_pos", Vector2.ZERO)
	# Mimic-et enemy-ként kezeljük → erős melee enemy
	var mimic_data := EnemyData.new()
	mimic_data.enemy_name = "Mimic"
	mimic_data.enemy_id = "mimic"
	mimic_data.enemy_category = Enums.EnemyType.MELEE
	mimic_data.base_hp = 120
	mimic_data.base_damage = 25
	mimic_data.base_armor = 8
	mimic_data.base_speed = 60.0
	mimic_data.attack_range = 32.0
	mimic_data.detection_range = 128.0
	mimic_data.attack_speed = 1.5
	mimic_data.base_xp = 40
	mimic_data.gold_range = Vector2i(20, 50)
	mimic_data.sprite_color = Color(0.6, 0.4, 0.1)
	
	var mimic := EnemyBase.new()
	mimic.enemy_data = mimic_data
	mimic.enemy_level = 10  # Szint a dungeon-nek megfelelően
	mimic.global_position = pos
	
	var enemy_layer := get_tree().current_scene.get_node_or_null("EntityLayer/Enemies")
	if enemy_layer:
		enemy_layer.add_child(mimic)
	
	# Delete the chest node
	if is_instance_valid(chest_data.get("node")):
		chest_data["node"].queue_free()


func _get_loot_count(rarity: int) -> int:
	match rarity:
		Enums.Rarity.COMMON: return randi_range(1, 2)
		Enums.Rarity.UNCOMMON: return randi_range(1, 3)
		Enums.Rarity.RARE: return randi_range(2, 3)
		Enums.Rarity.EPIC: return randi_range(2, 4)
		Enums.Rarity.LEGENDARY: return randi_range(3, 5)
		_: return 1


func _get_gold_for_rarity(rarity: int) -> int:
	match rarity:
		Enums.Rarity.COMMON: return randi_range(5, 15)
		Enums.Rarity.UNCOMMON: return randi_range(10, 30)
		Enums.Rarity.RARE: return randi_range(25, 60)
		Enums.Rarity.EPIC: return randi_range(50, 120)
		Enums.Rarity.LEGENDARY: return randi_range(100, 250)
		_: return 5


func _get_chest_color(rarity: int) -> Color:
	match rarity:
		Enums.Rarity.COMMON: return Color(0.6, 0.5, 0.3, 0.8)
		Enums.Rarity.UNCOMMON: return Color(0.2, 0.7, 0.2, 0.8)
		Enums.Rarity.RARE: return Color(0.2, 0.4, 0.9, 0.8)
		Enums.Rarity.EPIC: return Color(0.6, 0.2, 0.8, 0.8)
		Enums.Rarity.LEGENDARY: return Color(1.0, 0.6, 0.0, 0.8)
		_: return Color(0.5, 0.5, 0.5, 0.8)


func _generate_chest_loot(rarity: int) -> Dictionary:
	# Egyszerűsített loot generálás (ItemSystem integráció később)
	var item_types := ["weapon", "armor", "accessory", "material"]
	return {
		"type": "item",
		"item_type": item_types[randi() % item_types.size()],
		"rarity": rarity,
		"level": 1,
	}


func clear_all() -> void:
	for chest in active_chests:
		if is_instance_valid(chest.get("node")):
			chest["node"].queue_free()
	active_chests.clear()

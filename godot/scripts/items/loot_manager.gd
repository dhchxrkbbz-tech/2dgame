## LootManager - Globális loot management autoload
## Loot filter, pickup kezelés, drop megjelenítés
extends Node

## Loot filter beállítások
var filter := LootFilter.new()

## Aktív drop-ok nyilvántartása
var _active_drops: Array[DroppedItem] = []


func _ready() -> void:
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.item_dropped.connect(_on_item_dropped)
	EventBus.gold_collected.connect(_on_gold_collected)


## Ellenőrzi, hogy egy drop megjelenhessen-e (loot filter alapján)
func should_show_drop(item: ItemInstance) -> bool:
	return filter.should_show(item)


## Földre loot szórás (enemy halálából)
func spawn_enemy_loot(enemy_level: int, enemy_tier: String, pos: Vector2, magic_find: float = 0.0) -> void:
	# Items
	var items := LootGenerator.generate_enemy_loot(enemy_level, enemy_tier, magic_find)
	for item in items:
		if should_show_drop(item):
			var drop := DroppedItem.create_item_drop(item, pos)
			_add_drop(drop)
			EventBus.emit_signal("item_dropped", item, pos)
	
	# Gold
	var gold := LootGenerator.generate_gold(enemy_level, enemy_tier)
	if gold > 0:
		var gold_drop := DroppedItem.create_gold_drop(gold, pos)
		_add_drop(gold_drop)
	
	# Materials
	var mats := LootGenerator.generate_material_drop(enemy_level, enemy_tier)
	for mat in mats:
		if should_show_drop(mat):
			var drop := DroppedItem.create_item_drop(mat, pos)
			_add_drop(drop)


## Chest loot szórás
func spawn_chest_loot(chest_type: String, dungeon_level: int, pos: Vector2, magic_find: float = 0.0) -> void:
	var loot := LootGenerator.generate_chest_loot(chest_type, dungeon_level, magic_find)
	
	var items: Array = loot.get("items", [])
	for item in items:
		if should_show_drop(item):
			var drop := DroppedItem.create_item_drop(item, pos)
			_add_drop(drop)
	
	var gold: int = loot.get("gold", 0)
	if gold > 0:
		var gold_drop := DroppedItem.create_gold_drop(gold, pos)
		_add_drop(gold_drop)


## Boss loot szórás
func spawn_boss_loot(boss_id: String, boss_level: int, boss_tier: String, pos: Vector2, magic_find: float = 0.0, first_kill: bool = false) -> void:
	# Alap loot table-ből
	var items := LootGenerator.generate_enemy_loot(boss_level, boss_tier, magic_find)
	
	# First kill bonus: extra legendary chance
	if first_kill:
		var bonus_roll := randf()
		if bonus_roll < 0.10:  # +10% legendary
			var legendary := LootGenerator.generate_legendary(boss_level)
			items.append(legendary)
	
	# Boss-specifikus drop-ok
	var boss_legendaries := _get_boss_legendaries(boss_id)
	for leg_id in boss_legendaries:
		var chance := _get_boss_specific_chance(boss_tier)
		if randf() < chance:
			var legendary := LootGenerator.generate_legendary(boss_level, leg_id)
			items.append(legendary)
	
	# Spawn
	for item in items:
		if should_show_drop(item):
			var drop := DroppedItem.create_item_drop(item, pos)
			_add_drop(drop)
	
	# Gold
	var gold := LootGenerator.generate_gold(boss_level, boss_tier)
	if gold > 0:
		var gold_drop := DroppedItem.create_gold_drop(gold, pos)
		_add_drop(gold_drop)
	
	# Dark Essence
	var essence := _get_boss_essence(boss_tier)
	if essence > 0:
		EventBus.emit_signal("currency_changed", Enums.CurrencyType.DARK_ESSENCE, essence)


## Boss-specifikus legendary lista
func _get_boss_legendaries(boss_id: String) -> Array[String]:
	var boss_drops: Dictionary = {
		"necromancer_king": ["necro_crown", "bone_staff"],
		"abyss_dragon": ["dragon_scale_armor", "dragon_fang"],
		"ashen_god": ["ashen_crown", "god_slayer", "ashen_relic"],
	}
	var result: Array[String] = []
	var drops: Array = boss_drops.get(boss_id, [])
	for d in drops:
		result.append(d)
	return result


func _get_boss_specific_chance(boss_tier: String) -> float:
	match boss_tier:
		"mini_boss": return 0.05
		"dungeon_boss": return 0.10
		"world_boss": return 0.20
		"raid_boss": return 0.30
		_: return 0.05


func _get_boss_essence(boss_tier: String) -> int:
	match boss_tier:
		"mini_boss": return randi_range(5, 15)
		"dungeon_boss": return randi_range(15, 30)
		"world_boss": return randi_range(25, 50)
		"raid_boss": return randi_range(40, 80)
		_: return 0


func _add_drop(drop: Node2D) -> void:
	var world := get_tree().current_scene
	if world:
		world.call_deferred("add_child", drop)
	if drop is DroppedItem:
		_active_drops.append(drop)


## Callback-ek
func _on_item_picked_up(item: ItemInstance) -> void:
	if not item:
		return
	
	# Rarity-alapú notification
	if item.rarity >= Enums.Rarity.RARE:
		var rarity_name := _get_rarity_name(item.rarity)
		EventBus.emit_signal("show_notification",
			"%s item: %s" % [rarity_name, item.get_display_name()],
			Enums.NotificationType.LOOT)
	
	# Legendary hangeffekt
	if item.rarity == Enums.Rarity.LEGENDARY:
		# AudioManager.play_sfx("legendary_drop")  # TODO: implementáld
		pass


func _on_item_dropped(_item_data, _position: Vector2) -> void:
	pass  # Tracking


func _on_gold_collected(amount: int) -> void:
	if amount >= 100:
		EventBus.emit_signal("show_notification",
			"+%d Gold" % amount,
			Enums.NotificationType.INFO)


func _get_rarity_name(rarity: int) -> String:
	match rarity:
		Enums.Rarity.COMMON: return "Common"
		Enums.Rarity.UNCOMMON: return "Uncommon"
		Enums.Rarity.RARE: return "Rare"
		Enums.Rarity.EPIC: return "Epic"
		Enums.Rarity.LEGENDARY: return "Legendary"
		_: return "Unknown"


## Cleanup
func _process(_delta: float) -> void:
	_active_drops = _active_drops.filter(func(d): return is_instance_valid(d))

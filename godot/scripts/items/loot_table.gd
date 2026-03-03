## LootTable - Loot table definíció és feldolgozás
## Konfigurálható drop pool-ok enemy/chest/boss-hoz
class_name LootTable
extends RefCounted

## Egy loot bejegyzés
class LootEntry:
	var item_pool: String = "weapon"  # "weapon", "armor", "accessory", "consumable", "material", "gem", "set", "legendary"
	var weight: float = 1.0
	var min_rarity: int = Enums.Rarity.COMMON
	var quantity_range: Vector2i = Vector2i(1, 1)
	var class_filter: int = -1  # -1 = bárki
	var specific_item_id: String = ""  # Ha konkrét item kell
	
	func _init(p_pool: String = "weapon", p_weight: float = 1.0, p_min_rarity: int = 0) -> void:
		item_pool = p_pool
		weight = p_weight
		min_rarity = p_min_rarity

## Loot table adatok
var entries: Array[LootEntry] = []
var guaranteed_drops: Array[LootEntry] = []
var drop_count_range: Vector2i = Vector2i(0, 3)
var gold_range: Vector2i = Vector2i(5, 20)
var material_chance: float = 0.3
var dark_essence_range: Vector2i = Vector2i(0, 0)


## Loot generálás a table alapján
func roll_loot(enemy_level: int, magic_find: float = 0.0) -> Dictionary:
	var result: Dictionary = {
		"items": [] as Array[ItemInstance],
		"gold": randi_range(gold_range.x, gold_range.y),
		"dark_essence": randi_range(dark_essence_range.x, dark_essence_range.y) if dark_essence_range.y > 0 else 0,
	}
	
	# Garantált drop-ok
	for entry in guaranteed_drops:
		var item := _roll_entry(entry, enemy_level, magic_find)
		if item:
			result["items"].append(item)
	
	# Random drop-ok
	var count := randi_range(drop_count_range.x, drop_count_range.y)
	for i in count:
		var entry := _pick_weighted_entry()
		if entry:
			var item := _roll_entry(entry, enemy_level, magic_find)
			if item:
				result["items"].append(item)
	
	# Material drop
	if randf() < material_chance:
		var mats := LootGenerator.generate_material_drop(enemy_level)
		for mat in mats:
			result["items"].append(mat)
	
	return result


## Súlyozott entry kiválasztás
func _pick_weighted_entry() -> LootEntry:
	if entries.is_empty():
		return null
	
	var total_weight: float = 0.0
	for entry in entries:
		total_weight += entry.weight
	
	var roll := randf() * total_weight
	var cumulative: float = 0.0
	for entry in entries:
		cumulative += entry.weight
		if roll <= cumulative:
			return entry
	
	return entries.back()


## Entry-ből item generálás
func _roll_entry(entry: LootEntry, level: int, magic_find: float) -> ItemInstance:
	# Specifikus item
	if not entry.specific_item_id.is_empty():
		var base := ItemDatabase.get_item(entry.specific_item_id)
		if base:
			var instance := ItemInstance.new()
			instance.base_item = base
			instance.item_level = level
			instance.rarity = maxi(entry.min_rarity, Enums.Rarity.COMMON)
			instance.quantity = randi_range(entry.quantity_range.x, entry.quantity_range.y)
			return instance
		return null
	
	match entry.item_pool:
		"weapon", "armor", "accessory":
			var item := LootGenerator.generate_item(level, -1, magic_find)
			if item and item.rarity < entry.min_rarity:
				item.rarity = entry.min_rarity
			return item
		"consumable":
			return _roll_consumable(level, entry)
		"material":
			var mats := LootGenerator.generate_material_drop(level)
			return mats[0] if not mats.is_empty() else null
		"set":
			var set_ids := SetItemData.get_all_set_ids()
			if not set_ids.is_empty():
				var set_id: String = set_ids[randi() % set_ids.size()]
				return LootGenerator.generate_set_item(set_id, "", level)
			return LootGenerator.generate_item(level, Enums.Rarity.EPIC, magic_find)
		"legendary":
			return LootGenerator.generate_legendary(level)
		_:
			return LootGenerator.generate_item(level, -1, magic_find)


func _roll_consumable(level: int, entry: LootEntry) -> ItemInstance:
	var consumables := ItemDatabase.get_items_by_type(Enums.ItemType.CONSUMABLE)
	var valid: Array[ItemData] = []
	for c in consumables:
		if c.required_level <= level + 5:
			valid.append(c)
	if valid.is_empty():
		return null
	
	var chosen: ItemData = valid[randi() % valid.size()]
	var instance := ItemInstance.new()
	instance.base_item = chosen
	instance.item_level = chosen.item_level
	instance.rarity = Enums.Rarity.COMMON
	instance.quantity = randi_range(entry.quantity_range.x, entry.quantity_range.y)
	return instance


# =========================
# PRESET LOOT TABLE-ÖK
# =========================

## Normál enemy loot table
static func create_normal_enemy() -> LootTable:
	var lt := LootTable.new()
	lt.drop_count_range = Vector2i(0, 1)
	lt.gold_range = Vector2i(1, 10)
	lt.material_chance = 0.40
	
	lt.entries.append(LootEntry.new("weapon", 30.0))
	lt.entries.append(LootEntry.new("armor", 30.0))
	lt.entries.append(LootEntry.new("accessory", 15.0))
	lt.entries.append(LootEntry.new("consumable", 20.0))
	lt.entries.append(LootEntry.new("material", 5.0))
	
	return lt


## Elite enemy loot table
static func create_elite_enemy() -> LootTable:
	var lt := LootTable.new()
	lt.drop_count_range = Vector2i(1, 2)
	lt.gold_range = Vector2i(10, 30)
	lt.material_chance = 0.30
	
	var guaranteed := LootEntry.new("weapon", 1.0, Enums.Rarity.UNCOMMON)
	lt.guaranteed_drops.append(guaranteed)
	
	lt.entries.append(LootEntry.new("weapon", 25.0, Enums.Rarity.UNCOMMON))
	lt.entries.append(LootEntry.new("armor", 30.0, Enums.Rarity.UNCOMMON))
	lt.entries.append(LootEntry.new("accessory", 15.0))
	lt.entries.append(LootEntry.new("consumable", 20.0))
	lt.entries.append(LootEntry.new("material", 10.0))
	
	return lt


## Mini boss (T1) loot table
static func create_mini_boss() -> LootTable:
	var lt := LootTable.new()
	lt.drop_count_range = Vector2i(2, 4)
	lt.gold_range = Vector2i(50, 200)
	lt.dark_essence_range = Vector2i(5, 15)
	lt.material_chance = 0.50
	
	var g1 := LootEntry.new("weapon", 1.0, Enums.Rarity.RARE)
	lt.guaranteed_drops.append(g1)
	
	lt.entries.append(LootEntry.new("weapon", 25.0, Enums.Rarity.UNCOMMON))
	lt.entries.append(LootEntry.new("armor", 25.0, Enums.Rarity.UNCOMMON))
	lt.entries.append(LootEntry.new("accessory", 15.0, Enums.Rarity.UNCOMMON))
	lt.entries.append(LootEntry.new("consumable", 15.0))
	lt.entries.append(LootEntry.new("material", 10.0))
	lt.entries.append(LootEntry.new("set", 5.0, Enums.Rarity.EPIC))
	lt.entries.append(LootEntry.new("legendary", 5.0, Enums.Rarity.LEGENDARY))
	
	return lt


## Dungeon boss (T2) loot table
static func create_dungeon_boss() -> LootTable:
	var lt := LootTable.new()
	lt.drop_count_range = Vector2i(3, 5)
	lt.gold_range = Vector2i(200, 500)
	lt.dark_essence_range = Vector2i(15, 30)
	lt.material_chance = 0.60
	
	var g1 := LootEntry.new("weapon", 1.0, Enums.Rarity.RARE)
	lt.guaranteed_drops.append(g1)
	var g2 := LootEntry.new("armor", 1.0, Enums.Rarity.RARE)
	lt.guaranteed_drops.append(g2)
	
	lt.entries.append(LootEntry.new("weapon", 20.0, Enums.Rarity.RARE))
	lt.entries.append(LootEntry.new("armor", 20.0, Enums.Rarity.RARE))
	lt.entries.append(LootEntry.new("accessory", 15.0, Enums.Rarity.UNCOMMON))
	lt.entries.append(LootEntry.new("consumable", 10.0))
	lt.entries.append(LootEntry.new("material", 10.0))
	lt.entries.append(LootEntry.new("set", 15.0, Enums.Rarity.EPIC))
	lt.entries.append(LootEntry.new("legendary", 10.0, Enums.Rarity.LEGENDARY))
	
	return lt


## World boss (T3) loot table
static func create_world_boss() -> LootTable:
	var lt := LootTable.new()
	lt.drop_count_range = Vector2i(4, 6)
	lt.gold_range = Vector2i(500, 1000)
	lt.dark_essence_range = Vector2i(25, 50)
	lt.material_chance = 0.70
	
	var g1 := LootEntry.new("weapon", 1.0, Enums.Rarity.EPIC)
	lt.guaranteed_drops.append(g1)
	var g2 := LootEntry.new("armor", 1.0, Enums.Rarity.EPIC)
	lt.guaranteed_drops.append(g2)
	
	lt.entries.append(LootEntry.new("weapon", 15.0, Enums.Rarity.RARE))
	lt.entries.append(LootEntry.new("armor", 15.0, Enums.Rarity.RARE))
	lt.entries.append(LootEntry.new("accessory", 15.0, Enums.Rarity.RARE))
	lt.entries.append(LootEntry.new("material", 10.0))
	lt.entries.append(LootEntry.new("set", 25.0, Enums.Rarity.EPIC))
	lt.entries.append(LootEntry.new("legendary", 20.0, Enums.Rarity.LEGENDARY))
	
	return lt


## Raid boss (T4) loot table
static func create_raid_boss() -> LootTable:
	var lt := LootTable.new()
	lt.drop_count_range = Vector2i(5, 8)
	lt.gold_range = Vector2i(1000, 2000)
	lt.dark_essence_range = Vector2i(40, 80)
	lt.material_chance = 0.80
	
	var g1 := LootEntry.new("weapon", 1.0, Enums.Rarity.EPIC)
	lt.guaranteed_drops.append(g1)
	var g2 := LootEntry.new("armor", 1.0, Enums.Rarity.EPIC)
	lt.guaranteed_drops.append(g2)
	var g3 := LootEntry.new("legendary", 1.0, Enums.Rarity.LEGENDARY)
	lt.guaranteed_drops.append(g3)
	
	lt.entries.append(LootEntry.new("weapon", 10.0, Enums.Rarity.EPIC))
	lt.entries.append(LootEntry.new("armor", 10.0, Enums.Rarity.EPIC))
	lt.entries.append(LootEntry.new("accessory", 10.0, Enums.Rarity.RARE))
	lt.entries.append(LootEntry.new("set", 35.0, Enums.Rarity.EPIC))
	lt.entries.append(LootEntry.new("legendary", 30.0, Enums.Rarity.LEGENDARY))
	lt.entries.append(LootEntry.new("material", 5.0))
	
	return lt


## Chest loot table factory
static func create_chest(chest_type: String) -> LootTable:
	var lt := LootTable.new()
	
	match chest_type:
		"common":
			lt.drop_count_range = Vector2i(1, 3)
			lt.gold_range = Vector2i(10, 30)
			lt.entries.append(LootEntry.new("weapon", 25.0))
			lt.entries.append(LootEntry.new("armor", 25.0))
			lt.entries.append(LootEntry.new("consumable", 30.0))
			lt.entries.append(LootEntry.new("material", 20.0))
		"uncommon":
			lt.drop_count_range = Vector2i(1, 2)
			lt.gold_range = Vector2i(20, 50)
			lt.entries.append(LootEntry.new("weapon", 25.0, Enums.Rarity.UNCOMMON))
			lt.entries.append(LootEntry.new("armor", 25.0, Enums.Rarity.UNCOMMON))
			lt.entries.append(LootEntry.new("accessory", 15.0))
			lt.entries.append(LootEntry.new("consumable", 20.0))
			lt.entries.append(LootEntry.new("material", 15.0))
		"rare":
			lt.drop_count_range = Vector2i(1, 1)
			lt.gold_range = Vector2i(50, 100)
			lt.entries.append(LootEntry.new("weapon", 25.0, Enums.Rarity.RARE))
			lt.entries.append(LootEntry.new("armor", 25.0, Enums.Rarity.RARE))
			lt.entries.append(LootEntry.new("accessory", 20.0, Enums.Rarity.UNCOMMON))
			lt.entries.append(LootEntry.new("set", 15.0, Enums.Rarity.EPIC))
			lt.entries.append(LootEntry.new("legendary", 15.0, Enums.Rarity.LEGENDARY))
		"boss":
			lt.drop_count_range = Vector2i(2, 3)
			lt.gold_range = Vector2i(100, 300)
			lt.entries.append(LootEntry.new("weapon", 20.0, Enums.Rarity.RARE))
			lt.entries.append(LootEntry.new("armor", 20.0, Enums.Rarity.RARE))
			lt.entries.append(LootEntry.new("accessory", 15.0, Enums.Rarity.RARE))
			lt.entries.append(LootEntry.new("set", 25.0, Enums.Rarity.EPIC))
			lt.entries.append(LootEntry.new("legendary", 20.0, Enums.Rarity.LEGENDARY))
		"secret":
			lt.drop_count_range = Vector2i(1, 2)
			lt.gold_range = Vector2i(50, 150)
			lt.entries.append(LootEntry.new("weapon", 15.0, Enums.Rarity.RARE))
			lt.entries.append(LootEntry.new("armor", 15.0, Enums.Rarity.RARE))
			lt.entries.append(LootEntry.new("accessory", 15.0, Enums.Rarity.RARE))
			lt.entries.append(LootEntry.new("set", 25.0, Enums.Rarity.EPIC))
			lt.entries.append(LootEntry.new("legendary", 15.0, Enums.Rarity.LEGENDARY))
			lt.entries.append(LootEntry.new("material", 15.0))
	
	return lt

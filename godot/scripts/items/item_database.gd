## ItemDatabase - Alap item regiszter
## Tartalmazza az összes base weapon, armor, accessory, consumable, material definíciót
class_name ItemDatabase
extends RefCounted

static var _items: Dictionary = {}
static var _initialized := false

## Összes regisztrált item betöltése
static func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	_register_weapons()
	_register_armor()
	_register_accessories()
	_register_consumables()
	_register_materials()


static func get_item(item_id: String) -> ItemData:
	initialize()
	if _items.has(item_id):
		return _items[item_id].duplicate()
	return null


static func get_items_by_type(item_type: int) -> Array[ItemData]:
	initialize()
	var result: Array[ItemData] = []
	for item in _items.values():
		if item.item_type == item_type:
			result.append(item.duplicate())
	return result


static func get_items_by_slot(slot: int) -> Array[ItemData]:
	initialize()
	var result: Array[ItemData] = []
	for item in _items.values():
		if item.equip_slot == slot:
			result.append(item.duplicate())
	return result


## Adott level-hez és slot-hoz megfelelő item
static func get_random_item_for_level(level: int, slot: int = -1) -> ItemData:
	initialize()
	var candidates: Array[ItemData] = []
	for item in _items.values():
		if item.item_type == Enums.ItemType.CONSUMABLE or item.item_type == Enums.ItemType.MATERIAL:
			continue
		if slot >= 0 and item.equip_slot != slot:
			continue
		if item.required_level <= level:
			candidates.append(item)
	if candidates.is_empty():
		return null
	return candidates[randi() % candidates.size()].duplicate()


static func _reg(item: ItemData) -> void:
	_items[item.item_id] = item


# =================== WEAPONS ===================

static func _register_weapons() -> void:
	# === SWORDS – 10 Tier (Assassin + Tank) ===
	_reg(_weapon("sword_t1", "Rusty Sword", 1, 7, -1, Color(0.55, 0.45, 0.35)))
	_reg(_weapon("sword_t2", "Iron Sword", 5, 13, -1, Color(0.7, 0.7, 0.7)))
	_reg(_weapon("sword_t3", "Steel Sword", 10, 22, -1, Color(0.8, 0.8, 0.85)))
	_reg(_weapon("sword_t4", "Mithril Sword", 15, 33, -1, Color(0.6, 0.8, 1.0)))
	_reg(_weapon("sword_t5", "Shadow Sword", 20, 48, -1, Color(0.3, 0.2, 0.5)))
	_reg(_weapon("sword_t6", "Dragon Sword", 25, 65, -1, Color(0.8, 0.3, 0.1)))
	_reg(_weapon("sword_t7", "Demon Blade", 30, 83, -1, Color(0.6, 0.15, 0.15)))
	_reg(_weapon("sword_t8", "Ethereal Sword", 35, 105, -1, Color(0.5, 0.7, 0.9)))
	_reg(_weapon("sword_t9", "Nexus Blade", 40, 135, -1, Color(0.4, 0.1, 0.6)))
	_reg(_weapon("sword_t10", "Blade of Doom", 45, 170, -1, Color(0.9, 0.6, 0.0)))

	# === DAGGERS – 10 Tier (Assassin) ===
	_reg(_weapon("dagger_t1", "Rusty Dagger", 1, 4, Enums.PlayerClass.ASSASSIN, Color(0.55, 0.45, 0.35)))
	_reg(_weapon("dagger_t2", "Iron Dagger", 5, 9, Enums.PlayerClass.ASSASSIN, Color(0.7, 0.7, 0.7)))
	_reg(_weapon("dagger_t3", "Steel Dagger", 10, 15, Enums.PlayerClass.ASSASSIN, Color(0.8, 0.8, 0.85)))
	_reg(_weapon("dagger_t4", "Mithril Dagger", 15, 24, Enums.PlayerClass.ASSASSIN, Color(0.6, 0.8, 1.0)))
	_reg(_weapon("dagger_t5", "Shadow Dagger", 20, 34, Enums.PlayerClass.ASSASSIN, Color(0.3, 0.2, 0.5)))
	_reg(_weapon("dagger_t6", "Dragon Dagger", 25, 47, Enums.PlayerClass.ASSASSIN, Color(0.8, 0.3, 0.1)))
	_reg(_weapon("dagger_t7", "Demon Stiletto", 30, 60, Enums.PlayerClass.ASSASSIN, Color(0.6, 0.15, 0.15)))
	_reg(_weapon("dagger_t8", "Ethereal Dagger", 35, 78, Enums.PlayerClass.ASSASSIN, Color(0.5, 0.7, 0.9)))
	_reg(_weapon("dagger_t9", "Nexus Dagger", 40, 99, Enums.PlayerClass.ASSASSIN, Color(0.4, 0.1, 0.6)))
	_reg(_weapon("dagger_t10", "Dagger of Doom", 45, 125, Enums.PlayerClass.ASSASSIN, Color(0.9, 0.6, 0.0)))

	# === AXES – 10 Tier (Tank) ===
	_reg(_weapon("axe_t1", "Rusty Axe", 1, 10, Enums.PlayerClass.TANK, Color(0.55, 0.45, 0.35)))
	_reg(_weapon("axe_t2", "Iron Axe", 5, 18, Enums.PlayerClass.TANK, Color(0.7, 0.7, 0.7)))
	_reg(_weapon("axe_t3", "Steel Axe", 10, 30, Enums.PlayerClass.TANK, Color(0.8, 0.8, 0.85)))
	_reg(_weapon("axe_t4", "Mithril Axe", 15, 43, Enums.PlayerClass.TANK, Color(0.6, 0.8, 1.0)))
	_reg(_weapon("axe_t5", "Shadow Axe", 20, 61, Enums.PlayerClass.TANK, Color(0.3, 0.2, 0.5)))
	_reg(_weapon("axe_t6", "Dragon Axe", 25, 83, Enums.PlayerClass.TANK, Color(0.8, 0.3, 0.1)))
	_reg(_weapon("axe_t7", "Demon Axe", 30, 109, Enums.PlayerClass.TANK, Color(0.6, 0.15, 0.15)))
	_reg(_weapon("axe_t8", "Ethereal Axe", 35, 138, Enums.PlayerClass.TANK, Color(0.5, 0.7, 0.9)))
	_reg(_weapon("axe_t9", "Nexus Axe", 40, 174, Enums.PlayerClass.TANK, Color(0.4, 0.1, 0.6)))
	_reg(_weapon("axe_t10", "Doom Cleaver", 45, 218, Enums.PlayerClass.TANK, Color(0.9, 0.6, 0.0)))

	# === STAVES – 10 Tier (Mage) ===
	_reg(_weapon("staff_t1", "Wooden Staff", 1, 5, Enums.PlayerClass.MAGE, Color(0.55, 0.35, 0.2)))
	_reg(_weapon("staff_t2", "Iron Staff", 5, 10, Enums.PlayerClass.MAGE, Color(0.7, 0.7, 0.7)))
	_reg(_weapon("staff_t3", "Crystal Staff", 10, 17, Enums.PlayerClass.MAGE, Color(0.5, 0.7, 0.9)))
	_reg(_weapon("staff_t4", "Mithril Staff", 15, 27, Enums.PlayerClass.MAGE, Color(0.6, 0.8, 1.0)))
	_reg(_weapon("staff_t5", "Shadow Staff", 20, 39, Enums.PlayerClass.MAGE, Color(0.3, 0.2, 0.5)))
	_reg(_weapon("staff_t6", "Dragon Staff", 25, 54, Enums.PlayerClass.MAGE, Color(0.8, 0.3, 0.1)))
	_reg(_weapon("staff_t7", "Demon Staff", 30, 71, Enums.PlayerClass.MAGE, Color(0.6, 0.15, 0.15)))
	_reg(_weapon("staff_t8", "Ethereal Staff", 35, 92, Enums.PlayerClass.MAGE, Color(0.5, 0.7, 0.9)))
	_reg(_weapon("staff_t9", "Nexus Staff", 40, 118, Enums.PlayerClass.MAGE, Color(0.4, 0.1, 0.6)))
	_reg(_weapon("staff_t10", "Staff of Doom", 45, 150, Enums.PlayerClass.MAGE, Color(0.9, 0.6, 0.0)))

	# === WANDS – 10 Tier (Mage) ===
	_reg(_weapon("wand_t1", "Wooden Wand", 1, 4, Enums.PlayerClass.MAGE, Color(0.55, 0.35, 0.2)))
	_reg(_weapon("wand_t2", "Iron Wand", 5, 8, Enums.PlayerClass.MAGE, Color(0.7, 0.7, 0.7)))
	_reg(_weapon("wand_t3", "Crystal Wand", 10, 13, Enums.PlayerClass.MAGE, Color(0.5, 0.7, 0.9)))
	_reg(_weapon("wand_t4", "Mithril Wand", 15, 20, Enums.PlayerClass.MAGE, Color(0.6, 0.8, 1.0)))
	_reg(_weapon("wand_t5", "Shadow Wand", 20, 30, Enums.PlayerClass.MAGE, Color(0.3, 0.2, 0.5)))
	_reg(_weapon("wand_t6", "Dragon Wand", 25, 41, Enums.PlayerClass.MAGE, Color(0.8, 0.3, 0.1)))
	_reg(_weapon("wand_t7", "Demon Wand", 30, 55, Enums.PlayerClass.MAGE, Color(0.6, 0.15, 0.15)))
	_reg(_weapon("wand_t8", "Ethereal Wand", 35, 71, Enums.PlayerClass.MAGE, Color(0.5, 0.7, 0.9)))
	_reg(_weapon("wand_t9", "Nexus Wand", 40, 92, Enums.PlayerClass.MAGE, Color(0.4, 0.1, 0.6)))
	_reg(_weapon("wand_t10", "Wand of Doom", 45, 118, Enums.PlayerClass.MAGE, Color(0.9, 0.6, 0.0)))


static func _weapon(id: String, wname: String, req_lvl: int, base_dmg: int, req_class: int = -1, color: Color = Color.WHITE) -> ItemData:
	var item := ItemData.new()
	item.item_id = id
	item.item_name = wname
	item.item_type = Enums.ItemType.WEAPON
	item.equip_slot = Enums.EquipSlot.MAIN_HAND
	item.required_level = req_lvl
	item.item_level = req_lvl
	item.base_damage = base_dmg
	item.required_class = req_class
	item.rarity = Enums.Rarity.COMMON
	item.sell_price = req_lvl * 2
	item.icon_color = color
	return item


# =================== ARMOR ===================

static func _register_armor() -> void:
	# === Helmets – 10 Tier ===
	_reg(_armor("helm_t1", "Cloth Hood", 1, Enums.EquipSlot.HELMET, 3, 5, Color(0.55, 0.35, 0.2)))
	_reg(_armor("helm_t2", "Leather Cap", 5, Enums.EquipSlot.HELMET, 7, 12, Color(0.6, 0.45, 0.3)))
	_reg(_armor("helm_t3", "Chain Helm", 10, Enums.EquipSlot.HELMET, 12, 20, Color(0.6, 0.6, 0.65)))
	_reg(_armor("helm_t4", "Iron Helm", 15, Enums.EquipSlot.HELMET, 18, 30, Color(0.7, 0.7, 0.7)))
	_reg(_armor("helm_t5", "Steel Helm", 20, Enums.EquipSlot.HELMET, 25, 42, Color(0.75, 0.75, 0.8)))
	_reg(_armor("helm_t6", "Mithril Helm", 25, Enums.EquipSlot.HELMET, 33, 55, Color(0.6, 0.8, 1.0)))
	_reg(_armor("helm_t7", "Shadow Helm", 30, Enums.EquipSlot.HELMET, 42, 70, Color(0.3, 0.2, 0.5)))
	_reg(_armor("helm_t8", "Demon Helm", 35, Enums.EquipSlot.HELMET, 52, 88, Color(0.6, 0.15, 0.15)))
	_reg(_armor("helm_t9", "Ethereal Crown", 40, Enums.EquipSlot.HELMET, 64, 105, Color(0.5, 0.7, 0.9)))
	_reg(_armor("helm_t10", "Crown of Doom", 45, Enums.EquipSlot.HELMET, 78, 120, Color(0.9, 0.6, 0.0)))

	# === Chest Armor – 10 Tier ===
	_reg(_armor("chest_t1", "Cloth Tunic", 1, Enums.EquipSlot.CHEST, 8, 10, Color(0.55, 0.35, 0.2)))
	_reg(_armor("chest_t2", "Leather Vest", 5, Enums.EquipSlot.CHEST, 16, 25, Color(0.6, 0.45, 0.3)))
	_reg(_armor("chest_t3", "Chainmail", 10, Enums.EquipSlot.CHEST, 28, 45, Color(0.6, 0.6, 0.65)))
	_reg(_armor("chest_t4", "Iron Breastplate", 15, Enums.EquipSlot.CHEST, 42, 68, Color(0.7, 0.7, 0.7)))
	_reg(_armor("chest_t5", "Steel Plate", 20, Enums.EquipSlot.CHEST, 58, 95, Color(0.75, 0.75, 0.8)))
	_reg(_armor("chest_t6", "Mithril Plate", 25, Enums.EquipSlot.CHEST, 76, 125, Color(0.6, 0.8, 1.0)))
	_reg(_armor("chest_t7", "Shadow Plate", 30, Enums.EquipSlot.CHEST, 96, 160, Color(0.3, 0.2, 0.5)))
	_reg(_armor("chest_t8", "Demon Plate", 35, Enums.EquipSlot.CHEST, 120, 195, Color(0.6, 0.15, 0.15)))
	_reg(_armor("chest_t9", "Ethereal Cuirass", 40, Enums.EquipSlot.CHEST, 148, 225, Color(0.5, 0.7, 0.9)))
	_reg(_armor("chest_t10", "Armor of Doom", 45, Enums.EquipSlot.CHEST, 180, 250, Color(0.9, 0.6, 0.0)))

	# === Gloves – 10 Tier ===
	_reg(_armor("gloves_t1", "Cloth Wraps", 1, Enums.EquipSlot.GLOVES, 2, 3, Color(0.55, 0.35, 0.2)))
	_reg(_armor("gloves_t2", "Leather Gloves", 5, Enums.EquipSlot.GLOVES, 5, 6, Color(0.6, 0.45, 0.3)))
	_reg(_armor("gloves_t3", "Chain Gauntlets", 10, Enums.EquipSlot.GLOVES, 9, 10, Color(0.6, 0.6, 0.65)))
	_reg(_armor("gloves_t4", "Iron Gauntlets", 15, Enums.EquipSlot.GLOVES, 14, 15, Color(0.7, 0.7, 0.7)))
	_reg(_armor("gloves_t5", "Steel Gauntlets", 20, Enums.EquipSlot.GLOVES, 20, 22, Color(0.75, 0.75, 0.8)))
	_reg(_armor("gloves_t6", "Mithril Gauntlets", 25, Enums.EquipSlot.GLOVES, 27, 30, Color(0.6, 0.8, 1.0)))
	_reg(_armor("gloves_t7", "Shadow Grips", 30, Enums.EquipSlot.GLOVES, 35, 40, Color(0.3, 0.2, 0.5)))
	_reg(_armor("gloves_t8", "Demon Grips", 35, Enums.EquipSlot.GLOVES, 44, 50, Color(0.6, 0.15, 0.15)))
	_reg(_armor("gloves_t9", "Ethereal Gloves", 40, Enums.EquipSlot.GLOVES, 54, 60, Color(0.5, 0.7, 0.9)))
	_reg(_armor("gloves_t10", "Gloves of Doom", 45, Enums.EquipSlot.GLOVES, 66, 72, Color(0.9, 0.6, 0.0)))

	# === Boots – 10 Tier ===
	_reg(_armor("boots_t1", "Cloth Sandals", 1, Enums.EquipSlot.BOOTS, 3, 3, Color(0.55, 0.35, 0.2)))
	_reg(_armor("boots_t2", "Leather Boots", 5, Enums.EquipSlot.BOOTS, 7, 7, Color(0.6, 0.45, 0.3)))
	_reg(_armor("boots_t3", "Chain Boots", 10, Enums.EquipSlot.BOOTS, 12, 12, Color(0.6, 0.6, 0.65)))
	_reg(_armor("boots_t4", "Iron Boots", 15, Enums.EquipSlot.BOOTS, 18, 18, Color(0.7, 0.7, 0.7)))
	_reg(_armor("boots_t5", "Steel Greaves", 20, Enums.EquipSlot.BOOTS, 25, 25, Color(0.75, 0.75, 0.8)))
	_reg(_armor("boots_t6", "Mithril Greaves", 25, Enums.EquipSlot.BOOTS, 33, 33, Color(0.6, 0.8, 1.0)))
	_reg(_armor("boots_t7", "Shadow Boots", 30, Enums.EquipSlot.BOOTS, 42, 42, Color(0.3, 0.2, 0.5)))
	_reg(_armor("boots_t8", "Demon Boots", 35, Enums.EquipSlot.BOOTS, 52, 52, Color(0.6, 0.15, 0.15)))
	_reg(_armor("boots_t9", "Ethereal Boots", 40, Enums.EquipSlot.BOOTS, 64, 64, Color(0.5, 0.7, 0.9)))
	_reg(_armor("boots_t10", "Boots of Doom", 45, Enums.EquipSlot.BOOTS, 78, 78, Color(0.9, 0.6, 0.0)))

	# === Shoulders – 10 Tier ===
	_reg(_armor("shoulders_t1", "Cloth Pads", 1, Enums.EquipSlot.SHOULDERS, 4, 4, Color(0.55, 0.35, 0.2)))
	_reg(_armor("shoulders_t2", "Leather Pauldrons", 5, Enums.EquipSlot.SHOULDERS, 9, 9, Color(0.6, 0.45, 0.3)))
	_reg(_armor("shoulders_t3", "Chain Spaulders", 10, Enums.EquipSlot.SHOULDERS, 15, 15, Color(0.6, 0.6, 0.65)))
	_reg(_armor("shoulders_t4", "Iron Pauldrons", 15, Enums.EquipSlot.SHOULDERS, 22, 22, Color(0.7, 0.7, 0.7)))
	_reg(_armor("shoulders_t5", "Steel Spaulders", 20, Enums.EquipSlot.SHOULDERS, 30, 30, Color(0.75, 0.75, 0.8)))
	_reg(_armor("shoulders_t6", "Mithril Pauldrons", 25, Enums.EquipSlot.SHOULDERS, 40, 40, Color(0.6, 0.8, 1.0)))
	_reg(_armor("shoulders_t7", "Shadow Spaulders", 30, Enums.EquipSlot.SHOULDERS, 52, 52, Color(0.3, 0.2, 0.5)))
	_reg(_armor("shoulders_t8", "Demon Pauldrons", 35, Enums.EquipSlot.SHOULDERS, 65, 65, Color(0.6, 0.15, 0.15)))
	_reg(_armor("shoulders_t9", "Ethereal Mantle", 40, Enums.EquipSlot.SHOULDERS, 80, 80, Color(0.5, 0.7, 0.9)))
	_reg(_armor("shoulders_t10", "Mantle of Doom", 45, Enums.EquipSlot.SHOULDERS, 98, 98, Color(0.9, 0.6, 0.0)))

	# === Belts – 10 Tier ===
	_reg(_armor("belt_t1", "Cloth Sash", 1, Enums.EquipSlot.BELT, 2, 2, Color(0.55, 0.35, 0.2)))
	_reg(_armor("belt_t2", "Leather Belt", 5, Enums.EquipSlot.BELT, 4, 5, Color(0.6, 0.45, 0.3)))
	_reg(_armor("belt_t3", "Chain Belt", 10, Enums.EquipSlot.BELT, 8, 10, Color(0.6, 0.6, 0.65)))
	_reg(_armor("belt_t4", "Iron Belt", 15, Enums.EquipSlot.BELT, 12, 15, Color(0.7, 0.7, 0.7)))
	_reg(_armor("belt_t5", "Steel Girdle", 20, Enums.EquipSlot.BELT, 17, 22, Color(0.75, 0.75, 0.8)))
	_reg(_armor("belt_t6", "Mithril Girdle", 25, Enums.EquipSlot.BELT, 23, 30, Color(0.6, 0.8, 1.0)))
	_reg(_armor("belt_t7", "Shadow Belt", 30, Enums.EquipSlot.BELT, 30, 40, Color(0.3, 0.2, 0.5)))
	_reg(_armor("belt_t8", "Demon Belt", 35, Enums.EquipSlot.BELT, 38, 50, Color(0.6, 0.15, 0.15)))
	_reg(_armor("belt_t9", "Ethereal Belt", 40, Enums.EquipSlot.BELT, 47, 60, Color(0.5, 0.7, 0.9)))
	_reg(_armor("belt_t10", "Belt of Doom", 45, Enums.EquipSlot.BELT, 58, 72, Color(0.9, 0.6, 0.0)))


static func _armor(id: String, aname: String, req_lvl: int, slot: int, base_armor: int, base_hp: int, color: Color = Color.WHITE) -> ItemData:
	var item := ItemData.new()
	item.item_id = id
	item.item_name = aname
	item.item_type = Enums.ItemType.ARMOR
	item.equip_slot = slot
	item.required_level = req_lvl
	item.item_level = req_lvl
	item.base_armor = base_armor
	item.base_hp = base_hp
	item.rarity = Enums.Rarity.COMMON
	item.sell_price = req_lvl * 2
	item.icon_color = color
	return item


# =================== ACCESSORIES ===================

static func _register_accessories() -> void:
	# Amulets – 5 Tier
	_reg(_accessory("amulet_t1", "Copper Amulet", 1, Enums.EquipSlot.AMULET, 5, 0, Color(0.7, 0.4, 0.2)))
	_reg(_accessory("amulet_t2", "Silver Pendant", 10, Enums.EquipSlot.AMULET, 15, 0, Color(0.8, 0.8, 0.85)))
	_reg(_accessory("amulet_t3", "Gold Talisman", 20, Enums.EquipSlot.AMULET, 30, 5, Color(0.9, 0.75, 0.2)))
	_reg(_accessory("amulet_t4", "Mithril Amulet", 30, Enums.EquipSlot.AMULET, 50, 10, Color(0.6, 0.8, 1.0)))
	_reg(_accessory("amulet_t5", "Arcane Locket", 40, Enums.EquipSlot.AMULET, 75, 15, Color(0.6, 0.3, 0.9)))

	# Rings – 5 Tier
	_reg(_accessory("ring_t1", "Copper Ring", 1, Enums.EquipSlot.RING_1, 3, 0, Color(0.7, 0.4, 0.2)))
	_reg(_accessory("ring_t2", "Silver Band", 10, Enums.EquipSlot.RING_1, 10, 0, Color(0.8, 0.8, 0.85)))
	_reg(_accessory("ring_t3", "Gold Signet", 20, Enums.EquipSlot.RING_1, 20, 3, Color(0.9, 0.75, 0.2)))
	_reg(_accessory("ring_t4", "Mithril Ring", 30, Enums.EquipSlot.RING_1, 35, 5, Color(0.6, 0.8, 1.0)))
	_reg(_accessory("ring_t5", "Arcane Band", 40, Enums.EquipSlot.RING_1, 50, 8, Color(0.6, 0.3, 0.9)))

	# Capes – 5 Tier
	_reg(_accessory("cape_t1", "Cloth Cape", 1, Enums.EquipSlot.CAPE, 3, 0, Color(0.5, 0.2, 0.2)))
	_reg(_accessory("cape_t2", "Leather Cloak", 10, Enums.EquipSlot.CAPE, 10, 2, Color(0.6, 0.45, 0.3)))
	_reg(_accessory("cape_t3", "Silk Cloak", 20, Enums.EquipSlot.CAPE, 20, 5, Color(0.4, 0.15, 0.5)))
	_reg(_accessory("cape_t4", "Shadow Mantle", 30, Enums.EquipSlot.CAPE, 35, 8, Color(0.2, 0.1, 0.3)))
	_reg(_accessory("cape_t5", "Ethereal Cape", 40, Enums.EquipSlot.CAPE, 50, 12, Color(0.5, 0.7, 0.9)))


static func _accessory(id: String, aname: String, req_lvl: int, slot: int, base_hp: int, base_mana: int, color: Color = Color.WHITE) -> ItemData:
	var item := ItemData.new()
	item.item_id = id
	item.item_name = aname
	item.item_type = Enums.ItemType.ACCESSORY
	item.equip_slot = slot
	item.required_level = req_lvl
	item.item_level = req_lvl
	item.base_hp = base_hp
	item.base_mana = base_mana
	item.rarity = Enums.Rarity.COMMON
	item.sell_price = req_lvl * 3
	item.icon_color = color
	return item


# =================== CONSUMABLES ===================

static func _register_consumables() -> void:
	# Health Potions
	_reg(_consumable("potion_hp_small", "Small Health Potion", 1, "heal_hp", 50, 5))
	_reg(_consumable("potion_hp_medium", "Health Potion", 10, "heal_hp", 150, 15))
	_reg(_consumable("potion_hp_large", "Greater Health Potion", 25, "heal_hp", 400, 40))
	_reg(_consumable("potion_hp_super", "Superior Health Potion", 40, "heal_hp", 800, 80))
	# Mana Potions
	_reg(_consumable("potion_mp_small", "Small Mana Potion", 1, "heal_mana", 30, 5))
	_reg(_consumable("potion_mp_medium", "Mana Potion", 10, "heal_mana", 80, 15))
	_reg(_consumable("potion_mp_large", "Greater Mana Potion", 25, "heal_mana", 200, 40))
	_reg(_consumable("potion_mp_super", "Superior Mana Potion", 40, "heal_mana", 400, 80))
	# Scrolls
	_reg(_consumable("scroll_town", "Town Portal Scroll", 1, "teleport_town", 0, 10))
	_reg(_consumable("scroll_identify", "Scroll of Identify", 1, "identify", 0, 8))
	# Elixirs
	_reg(_consumable("elixir_str", "Elixir of Strength", 15, "buff_damage", 20, 50))
	_reg(_consumable("elixir_def", "Elixir of Iron Skin", 15, "buff_armor", 15, 50))
	_reg(_consumable("elixir_speed", "Elixir of Haste", 15, "buff_speed", 25, 50))
	# Resist / Utility Potions
	_reg(_consumable("potion_fire_resist", "Fire Resistance Potion", 15, "buff_fire_resist", 30, 35))
	_reg(_consumable("potion_ice_resist", "Ice Resistance Potion", 15, "buff_ice_resist", 30, 35))
	_reg(_consumable("potion_poison_resist", "Poison Resistance Potion", 15, "buff_poison_resist", 30, 35))
	_reg(_consumable("potion_antidote", "Antidote", 5, "cure_poison", 0, 15))
	_reg(_consumable("potion_xp_boost", "Experience Potion", 20, "buff_xp", 25, 100))


static func _consumable(id: String, cname: String, req_lvl: int, effect: String, effect_value: int, price: int) -> ItemData:
	var item := ItemData.new()
	item.item_id = id
	item.item_name = cname
	item.item_type = Enums.ItemType.CONSUMABLE
	item.required_level = req_lvl
	item.item_level = req_lvl
	item.stackable = true
	item.sell_price = price
	item.rarity = Enums.Rarity.COMMON
	# Store effect in metadata
	item.set_meta("effect_type", effect)
	item.set_meta("effect_value", effect_value)
	item.icon_color = Color(0.2, 0.8, 0.2) if "hp" in effect else Color(0.2, 0.4, 0.9)
	return item


# =================== MATERIALS ===================

static func _register_materials() -> void:
	_reg(_material("mat_iron_ore", "Iron Ore", 1, 2))
	_reg(_material("mat_copper_ore", "Copper Ore", 1, 1))
	_reg(_material("mat_silver_ore", "Silver Ore", 10, 5))
	_reg(_material("mat_gold_ore", "Gold Ore", 20, 12))
	_reg(_material("mat_mythril_ore", "Mythril Ore", 35, 30))
	_reg(_material("mat_darksteel", "Darksteel Ingot", 30, 25))
	_reg(_material("mat_leather", "Leather Scrap", 1, 1))
	_reg(_material("mat_silk", "Silk Thread", 15, 6))
	_reg(_material("mat_monster_bone", "Monster Bone", 5, 3))
	_reg(_material("mat_demon_shard", "Demon Shard", 25, 15))
	_reg(_material("mat_soul_gem", "Soul Gem", 40, 50))
	_reg(_material("mat_enchant_dust", "Enchantment Dust", 10, 8))
	
	# Biome-specifikus anyagok
	_reg(_material("mat_cursed_wood", "Cursed Wood", 5, 4))
	_reg(_material("mat_shadow_silk", "Shadow Silk", 10, 8))
	_reg(_material("mat_swamp_moss", "Swamp Moss", 8, 3))
	_reg(_material("mat_poison_gland", "Poison Gland", 12, 10))
	_reg(_material("mat_ancient_stone", "Ancient Stone", 15, 12))
	_reg(_material("mat_soul_fragment", "Soul Fragment", 20, 20))
	_reg(_material("mat_mountain_crystal", "Mountain Crystal", 25, 18))
	_reg(_material("mat_raw_ore", "Raw Ore", 5, 2))
	_reg(_material("mat_frost_shard", "Frost Shard", 30, 22))
	_reg(_material("mat_yeti_fur", "Yeti Fur", 28, 20))
	_reg(_material("mat_obsidian_chunk", "Obsidian Chunk", 35, 28))
	_reg(_material("mat_ember_core", "Ember Core", 35, 30))
	_reg(_material("mat_plague_sample", "Plague Sample", 38, 32))
	_reg(_material("mat_death_bone", "Death Bone", 40, 35))
	
	# Crafting alapanyagok (plan 11 – tiered recipes)
	_reg(_material("mat_wood", "Wood", 1, 1))
	_reg(_material("mat_stone", "Stone", 1, 1))
	_reg(_material("mat_water", "Water Flask", 1, 1))
	_reg(_material("mat_steel_ingot", "Steel Ingot", 10, 8))
	_reg(_material("mat_hard_wood", "Hard Wood", 10, 6))
	_reg(_material("mat_crystal_water", "Crystal Water", 10, 5))
	_reg(_material("mat_red_herb", "Red Herb", 1, 2))
	_reg(_material("mat_blue_mushroom", "Blue Mushroom", 1, 2))
	_reg(_material("mat_green_herb", "Green Herb", 1, 2))
	_reg(_material("mat_fire_flower", "Fire Flower", 12, 8))
	_reg(_material("mat_ice_crystal", "Ice Crystal", 12, 8))
	_reg(_material("mat_purification_salt", "Purification Salt", 8, 5))
	_reg(_material("mat_life_essence", "Life Essence", 20, 15))
	_reg(_material("mat_mana_crystal", "Mana Crystal", 20, 15))
	_reg(_material("mat_enchanted_wood", "Enchanted Wood", 20, 12))
	_reg(_material("mat_magic_essence", "Magic Essence", 20, 18))
	_reg(_material("mat_demon_steel", "Demon Steel", 30, 35))
	_reg(_material("mat_shadow_wood", "Shadow Wood", 30, 25))
	_reg(_material("mat_rare_essence", "Rare Essence", 30, 40))
	_reg(_material("mat_void_metal", "Void Metal", 42, 70))
	_reg(_material("mat_nexus_crystal", "Nexus Crystal", 42, 75))
	_reg(_material("mat_legendary_essence", "Legendary Essence", 42, 80))
	_reg(_material("mat_aetherium_shard", "Aetherium Shard", 45, 120))
	_reg(_material("mat_magic_dust", "Magic Dust", 8, 6))
	_reg(_material("mat_enchant_crystal", "Enchant Crystal", 20, 20))
	_reg(_material("mat_legendary_dust", "Legendary Dust", 40, 60))
	_reg(_material("mat_crystal_vial", "Crystal Vial", 1, 3))
	
	# Ritka crafting alapanyagok
	_reg(_material("mat_dragonscale", "Dragonscale", 40, 60))
	_reg(_material("mat_moonstone", "Moonstone", 35, 45))
	_reg(_material("mat_void_crystal", "Void Crystal", 45, 80))
	_reg(_material("mat_phoenix_feather", "Phoenix Feather", 45, 90))
	_reg(_material("mat_titan_ore", "Titan Ore", 48, 100))
	_reg(_material("mat_god_essence", "God Essence", 50, 200))
	_reg(_material("mat_primordial_fragment", "Primordial Fragment", 50, 250))


static func _material(id: String, mname: String, req_lvl: int, price: int) -> ItemData:
	var item := ItemData.new()
	item.item_id = id
	item.item_name = mname
	item.item_type = Enums.ItemType.MATERIAL
	item.required_level = req_lvl
	item.item_level = req_lvl
	item.stackable = true
	item.sell_price = price
	item.rarity = Enums.Rarity.COMMON
	item.icon_color = Color(0.6, 0.5, 0.3)
	return item

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
	# === Assassin Weapons ===
	_reg(_weapon("dagger_iron", "Iron Dagger", 1, 6, Enums.PlayerClass.ASSASSIN, Color(0.7, 0.7, 0.7)))
	_reg(_weapon("dagger_steel", "Steel Dagger", 8, 12, Enums.PlayerClass.ASSASSIN, Color(0.8, 0.8, 0.85)))
	_reg(_weapon("dagger_shadow", "Shadow Blade", 16, 20, Enums.PlayerClass.ASSASSIN, Color(0.3, 0.2, 0.5)))
	_reg(_weapon("dagger_venom", "Venomfang", 24, 28, Enums.PlayerClass.ASSASSIN, Color(0.2, 0.7, 0.3)))
	_reg(_weapon("dagger_obsidian", "Obsidian Stiletto", 35, 38, Enums.PlayerClass.ASSASSIN, Color(0.2, 0.15, 0.1)))
	_reg(_weapon("dagger_mythril", "Mythril Kris", 45, 50, Enums.PlayerClass.ASSASSIN, Color(0.6, 0.8, 1.0)))
	
	# === Tank Weapons ===
	_reg(_weapon("sword_iron", "Iron Sword", 1, 8, Enums.PlayerClass.TANK, Color(0.7, 0.7, 0.7)))
	_reg(_weapon("sword_steel", "Steel Broadsword", 8, 15, Enums.PlayerClass.TANK, Color(0.8, 0.8, 0.85)))
	_reg(_weapon("axe_war", "War Axe", 16, 22, Enums.PlayerClass.TANK, Color(0.6, 0.4, 0.3)))
	_reg(_weapon("mace_iron", "Iron Mace", 24, 26, Enums.PlayerClass.TANK, Color(0.65, 0.65, 0.65)))
	_reg(_weapon("sword_flame", "Flamebrand", 35, 42, Enums.PlayerClass.TANK, Color(0.9, 0.4, 0.1)))
	_reg(_weapon("axe_titan", "Titan Cleaver", 45, 55, Enums.PlayerClass.TANK, Color(0.7, 0.5, 0.2)))
	
	# === Mage Weapons ===
	_reg(_weapon("staff_wood", "Wooden Staff", 1, 5, Enums.PlayerClass.MAGE, Color(0.55, 0.35, 0.2)))
	_reg(_weapon("wand_crystal", "Crystal Wand", 8, 10, Enums.PlayerClass.MAGE, Color(0.5, 0.7, 0.9)))
	_reg(_weapon("staff_ember", "Ember Staff", 16, 18, Enums.PlayerClass.MAGE, Color(0.9, 0.3, 0.1)))
	_reg(_weapon("staff_frost", "Frostweave Staff", 24, 24, Enums.PlayerClass.MAGE, Color(0.3, 0.5, 0.9)))
	_reg(_weapon("wand_void", "Void Scepter", 35, 35, Enums.PlayerClass.MAGE, Color(0.4, 0.1, 0.6)))
	_reg(_weapon("staff_arcane", "Arcane Focus", 45, 48, Enums.PlayerClass.MAGE, Color(0.7, 0.3, 0.9)))


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
	# Helmets
	_reg(_armor("helm_leather", "Leather Cap", 1, Enums.EquipSlot.HELMET, 2, 5, Color(0.55, 0.35, 0.2)))
	_reg(_armor("helm_chain", "Chain Helm", 10, Enums.EquipSlot.HELMET, 5, 10, Color(0.6, 0.6, 0.65)))
	_reg(_armor("helm_plate", "Plate Helm", 20, Enums.EquipSlot.HELMET, 10, 20, Color(0.7, 0.7, 0.7)))
	_reg(_armor("helm_dark", "Darksteel Helm", 35, Enums.EquipSlot.HELMET, 16, 35, Color(0.3, 0.3, 0.35)))
	_reg(_armor("helm_mythril", "Mythril Crown", 45, Enums.EquipSlot.HELMET, 22, 50, Color(0.6, 0.8, 1.0)))
	
	# Chest
	_reg(_armor("chest_leather", "Leather Vest", 1, Enums.EquipSlot.CHEST, 4, 8, Color(0.55, 0.35, 0.2)))
	_reg(_armor("chest_chain", "Chainmail", 10, Enums.EquipSlot.CHEST, 10, 20, Color(0.6, 0.6, 0.65)))
	_reg(_armor("chest_plate", "Plate Armor", 20, Enums.EquipSlot.CHEST, 18, 35, Color(0.7, 0.7, 0.7)))
	_reg(_armor("chest_dark", "Darksteel Plate", 35, Enums.EquipSlot.CHEST, 28, 60, Color(0.3, 0.3, 0.35)))
	_reg(_armor("chest_mythril", "Mythril Cuirass", 45, Enums.EquipSlot.CHEST, 38, 80, Color(0.6, 0.8, 1.0)))
	
	# Gloves
	_reg(_armor("gloves_leather", "Leather Gloves", 1, Enums.EquipSlot.GLOVES, 1, 3, Color(0.55, 0.35, 0.2)))
	_reg(_armor("gloves_chain", "Chain Gauntlets", 10, Enums.EquipSlot.GLOVES, 3, 8, Color(0.6, 0.6, 0.65)))
	_reg(_armor("gloves_plate", "Plate Gauntlets", 20, Enums.EquipSlot.GLOVES, 6, 12, Color(0.7, 0.7, 0.7)))
	_reg(_armor("gloves_dark", "Darksteel Grips", 35, Enums.EquipSlot.GLOVES, 10, 20, Color(0.3, 0.3, 0.35)))
	
	# Boots
	_reg(_armor("boots_leather", "Leather Boots", 1, Enums.EquipSlot.BOOTS, 1, 3, Color(0.55, 0.35, 0.2)))
	_reg(_armor("boots_chain", "Chain Boots", 10, Enums.EquipSlot.BOOTS, 3, 8, Color(0.6, 0.6, 0.65)))
	_reg(_armor("boots_plate", "Plate Greaves", 20, Enums.EquipSlot.BOOTS, 6, 12, Color(0.7, 0.7, 0.7)))
	_reg(_armor("boots_dark", "Darksteel Sabatons", 35, Enums.EquipSlot.BOOTS, 10, 20, Color(0.3, 0.3, 0.35)))
	
	# Belt
	_reg(_armor("belt_leather", "Leather Belt", 1, Enums.EquipSlot.BELT, 1, 2, Color(0.55, 0.35, 0.2)))
	_reg(_armor("belt_chain", "Chain Belt", 10, Enums.EquipSlot.BELT, 2, 5, Color(0.6, 0.6, 0.65)))
	_reg(_armor("belt_plate", "Plate Girdle", 25, Enums.EquipSlot.BELT, 5, 10, Color(0.7, 0.7, 0.7)))


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
	# Amulets
	_reg(_accessory("amulet_copper", "Copper Amulet", 1, Enums.EquipSlot.AMULET, 5, 0, Color(0.7, 0.4, 0.2)))
	_reg(_accessory("amulet_silver", "Silver Pendant", 15, Enums.EquipSlot.AMULET, 15, 0, Color(0.8, 0.8, 0.85)))
	_reg(_accessory("amulet_gold", "Gold Talisman", 30, Enums.EquipSlot.AMULET, 30, 0, Color(0.9, 0.75, 0.2)))
	_reg(_accessory("amulet_arcane", "Arcane Locket", 40, Enums.EquipSlot.AMULET, 50, 10, Color(0.6, 0.3, 0.9)))
	
	# Rings
	_reg(_accessory("ring_copper", "Copper Ring", 1, Enums.EquipSlot.RING_1, 3, 0, Color(0.7, 0.4, 0.2)))
	_reg(_accessory("ring_silver", "Silver Band", 15, Enums.EquipSlot.RING_1, 10, 0, Color(0.8, 0.8, 0.85)))
	_reg(_accessory("ring_gold", "Gold Signet", 30, Enums.EquipSlot.RING_1, 20, 0, Color(0.9, 0.75, 0.2)))
	
	# Capes
	_reg(_accessory("cape_cloth", "Cloth Cape", 1, Enums.EquipSlot.CAPE, 3, 0, Color(0.5, 0.2, 0.2)))
	_reg(_accessory("cape_silk", "Silk Cloak", 15, Enums.EquipSlot.CAPE, 10, 3, Color(0.4, 0.15, 0.5)))
	_reg(_accessory("cape_shadow", "Shadow Mantle", 30, Enums.EquipSlot.CAPE, 20, 5, Color(0.2, 0.1, 0.3)))


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
	_reg(_consumable("potion_hp_small", "Small Health Potion", 1, "heal_hp", 30, 5))
	_reg(_consumable("potion_hp_medium", "Health Potion", 10, "heal_hp", 80, 15))
	_reg(_consumable("potion_hp_large", "Greater Health Potion", 25, "heal_hp", 200, 40))
	_reg(_consumable("potion_mp_small", "Small Mana Potion", 1, "heal_mana", 20, 5))
	_reg(_consumable("potion_mp_medium", "Mana Potion", 10, "heal_mana", 60, 15))
	_reg(_consumable("scroll_town", "Town Portal Scroll", 1, "teleport_town", 0, 10))
	_reg(_consumable("scroll_identify", "Scroll of Identify", 1, "identify", 0, 8))
	_reg(_consumable("elixir_str", "Elixir of Strength", 15, "buff_damage", 20, 50))
	_reg(_consumable("elixir_def", "Elixir of Iron Skin", 15, "buff_armor", 15, 50))
	_reg(_consumable("elixir_speed", "Elixir of Haste", 15, "buff_speed", 25, 50))


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

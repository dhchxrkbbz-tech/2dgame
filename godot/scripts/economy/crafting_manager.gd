## CraftingManager - Crafting logika és recept kezelés
## Recept adatbázis, feltétel ellenőrzés, sikeres/sikertelen craft
class_name CraftingManager
extends Node

## Recept adatbázis: recipe_id → CraftingRecipe
var _recipes: Dictionary = {}

## Aktív crafting állapot
var _is_crafting: bool = false
var _current_recipe: CraftingRecipe = null
var _craft_timer: Timer = null

## Referenciák (az EconomyManager állítja be)
var currency_manager: CurrencyManager = null
var inventory_manager: InventoryManager = null
var profession_manager = null  # ProfessionManager (forward reference)


func _ready() -> void:
	_craft_timer = Timer.new()
	_craft_timer.one_shot = true
	_craft_timer.timeout.connect(_on_craft_timer_timeout)
	add_child(_craft_timer)
	_init_recipes()


## Recept adatbázis feltöltése
func _init_recipes() -> void:
	_init_weapon_recipes()
	_init_armor_recipes()
	_init_alchemy_recipes()
	_init_enchanting_recipes()
	_init_workbench_recipes()
	_init_rune_altar_recipes()


# === WEAPON CRAFTING (Plan 11.1 – Weaponsmithing) ===
func _init_weapon_recipes() -> void:
	# Tier 1 fegyver: 3× Iron Ore + 1× Wood + 50 Gold
	_add_recipe(CraftingRecipe.create(
		"weapon_t1_sword", "Iron Sword", "sword_t1",
		[{"item_id": "mat_iron_ore", "count": 3}, {"item_id": "mat_wood", "count": 1}],
		50, Enums.StationType.ANVIL, 3.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 1
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t1_dagger", "Iron Dagger", "dagger_t1",
		[{"item_id": "mat_iron_ore", "count": 3}, {"item_id": "mat_wood", "count": 1}],
		50, Enums.StationType.ANVIL, 3.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 1
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t1_axe", "Iron Axe", "axe_t1",
		[{"item_id": "mat_iron_ore", "count": 3}, {"item_id": "mat_wood", "count": 1}],
		50, Enums.StationType.ANVIL, 3.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 1
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t1_staff", "Wooden Staff", "staff_t1",
		[{"item_id": "mat_wood", "count": 4}, {"item_id": "mat_stone", "count": 1}],
		50, Enums.StationType.ANVIL, 3.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 1
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t1_wand", "Wooden Wand", "wand_t1",
		[{"item_id": "mat_wood", "count": 3}, {"item_id": "mat_stone", "count": 1}],
		50, Enums.StationType.ANVIL, 3.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 1
	))
	
	# Tier 3 fegyver: 5× Steel Ingot + 3× Hard Wood + 2× Leather + 500 Gold
	_add_recipe(CraftingRecipe.create(
		"weapon_t3_sword", "Steel Sword", "sword_t3",
		[{"item_id": "mat_steel_ingot", "count": 5}, {"item_id": "mat_hard_wood", "count": 3}, {"item_id": "mat_leather", "count": 2}],
		500, Enums.StationType.ANVIL, 5.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 3
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t3_dagger", "Steel Dagger", "dagger_t3",
		[{"item_id": "mat_steel_ingot", "count": 5}, {"item_id": "mat_hard_wood", "count": 3}, {"item_id": "mat_leather", "count": 2}],
		500, Enums.StationType.ANVIL, 5.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 3
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t3_axe", "Steel Axe", "axe_t3",
		[{"item_id": "mat_steel_ingot", "count": 5}, {"item_id": "mat_hard_wood", "count": 3}, {"item_id": "mat_leather", "count": 2}],
		500, Enums.StationType.ANVIL, 5.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 3
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t3_staff", "Crystal Staff", "staff_t3",
		[{"item_id": "mat_steel_ingot", "count": 3}, {"item_id": "mat_hard_wood", "count": 5}, {"item_id": "mat_magic_dust", "count": 2}],
		500, Enums.StationType.ANVIL, 5.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 3
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t3_wand", "Crystal Wand", "wand_t3",
		[{"item_id": "mat_steel_ingot", "count": 3}, {"item_id": "mat_hard_wood", "count": 3}, {"item_id": "mat_magic_dust", "count": 2}],
		500, Enums.StationType.ANVIL, 5.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 3
	))
	
	# Tier 5 fegyver: 8× Mithril + 5× Enchanted Wood + 3× Magic Essence + 2000 Gold
	_add_recipe(CraftingRecipe.create(
		"weapon_t5_sword", "Mythril Sword", "sword_t5",
		[{"item_id": "mat_mythril_ore", "count": 8}, {"item_id": "mat_enchanted_wood", "count": 5}, {"item_id": "mat_magic_essence", "count": 3}],
		2000, Enums.StationType.ANVIL, 8.0, 0.95,
		Enums.ProfessionType.BLACKSMITHING, 5
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t5_dagger", "Mythril Dagger", "dagger_t5",
		[{"item_id": "mat_mythril_ore", "count": 8}, {"item_id": "mat_enchanted_wood", "count": 5}, {"item_id": "mat_magic_essence", "count": 3}],
		2000, Enums.StationType.ANVIL, 8.0, 0.95,
		Enums.ProfessionType.BLACKSMITHING, 5
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t5_axe", "Mythril Axe", "axe_t5",
		[{"item_id": "mat_mythril_ore", "count": 8}, {"item_id": "mat_enchanted_wood", "count": 5}, {"item_id": "mat_magic_essence", "count": 3}],
		2000, Enums.StationType.ANVIL, 8.0, 0.95,
		Enums.ProfessionType.BLACKSMITHING, 5
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t5_staff", "Enchanted Staff", "staff_t5",
		[{"item_id": "mat_enchanted_wood", "count": 8}, {"item_id": "mat_magic_essence", "count": 5}, {"item_id": "mat_mythril_ore", "count": 3}],
		2000, Enums.StationType.ANVIL, 8.0, 0.95,
		Enums.ProfessionType.BLACKSMITHING, 5
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t5_wand", "Enchanted Wand", "wand_t5",
		[{"item_id": "mat_enchanted_wood", "count": 6}, {"item_id": "mat_magic_essence", "count": 4}, {"item_id": "mat_mythril_ore", "count": 3}],
		2000, Enums.StationType.ANVIL, 8.0, 0.95,
		Enums.ProfessionType.BLACKSMITHING, 5
	))
	
	# Tier 7 fegyver: 12× Demon Steel + 8× Shadow Wood + 5× Rare Essence + 10000 Gold
	_add_recipe(CraftingRecipe.create(
		"weapon_t7_sword", "Demon Sword", "sword_t7",
		[{"item_id": "mat_demon_steel", "count": 12}, {"item_id": "mat_shadow_wood", "count": 8}, {"item_id": "mat_rare_essence", "count": 5}],
		10000, Enums.StationType.ANVIL, 12.0, 0.85,
		Enums.ProfessionType.BLACKSMITHING, 7
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t7_dagger", "Demon Dagger", "dagger_t7",
		[{"item_id": "mat_demon_steel", "count": 12}, {"item_id": "mat_shadow_wood", "count": 8}, {"item_id": "mat_rare_essence", "count": 5}],
		10000, Enums.StationType.ANVIL, 12.0, 0.85,
		Enums.ProfessionType.BLACKSMITHING, 7
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t7_axe", "Demon Axe", "axe_t7",
		[{"item_id": "mat_demon_steel", "count": 12}, {"item_id": "mat_shadow_wood", "count": 8}, {"item_id": "mat_rare_essence", "count": 5}],
		10000, Enums.StationType.ANVIL, 12.0, 0.85,
		Enums.ProfessionType.BLACKSMITHING, 7
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t7_staff", "Demonbone Staff", "staff_t7",
		[{"item_id": "mat_shadow_wood", "count": 12}, {"item_id": "mat_rare_essence", "count": 8}, {"item_id": "mat_demon_steel", "count": 5}],
		10000, Enums.StationType.ANVIL, 12.0, 0.85,
		Enums.ProfessionType.BLACKSMITHING, 7
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t7_wand", "Demonbone Wand", "wand_t7",
		[{"item_id": "mat_shadow_wood", "count": 10}, {"item_id": "mat_rare_essence", "count": 6}, {"item_id": "mat_demon_steel", "count": 5}],
		10000, Enums.StationType.ANVIL, 12.0, 0.85,
		Enums.ProfessionType.BLACKSMITHING, 7
	))
	
	# Tier 9 fegyver: 18× Void Metal + 12× Nexus Crystal + 8× Legendary Essence + 3× Aetherium + 50000 Gold
	_add_recipe(CraftingRecipe.create(
		"weapon_t9_sword", "Void Blade", "sword_t9",
		[{"item_id": "mat_void_metal", "count": 18}, {"item_id": "mat_nexus_crystal", "count": 12}, {"item_id": "mat_legendary_essence", "count": 8}, {"item_id": "mat_aetherium_shard", "count": 3}],
		50000, Enums.StationType.ANVIL, 18.0, 0.70,
		Enums.ProfessionType.BLACKSMITHING, 9
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t9_dagger", "Void Stiletto", "dagger_t9",
		[{"item_id": "mat_void_metal", "count": 18}, {"item_id": "mat_nexus_crystal", "count": 12}, {"item_id": "mat_legendary_essence", "count": 8}, {"item_id": "mat_aetherium_shard", "count": 3}],
		50000, Enums.StationType.ANVIL, 18.0, 0.70,
		Enums.ProfessionType.BLACKSMITHING, 9
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t9_axe", "Void Cleaver", "axe_t9",
		[{"item_id": "mat_void_metal", "count": 18}, {"item_id": "mat_nexus_crystal", "count": 12}, {"item_id": "mat_legendary_essence", "count": 8}, {"item_id": "mat_aetherium_shard", "count": 3}],
		50000, Enums.StationType.ANVIL, 18.0, 0.70,
		Enums.ProfessionType.BLACKSMITHING, 9
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t9_staff", "Void Staff", "staff_t9",
		[{"item_id": "mat_nexus_crystal", "count": 18}, {"item_id": "mat_legendary_essence", "count": 12}, {"item_id": "mat_void_metal", "count": 8}, {"item_id": "mat_aetherium_shard", "count": 3}],
		50000, Enums.StationType.ANVIL, 18.0, 0.70,
		Enums.ProfessionType.BLACKSMITHING, 9
	))
	_add_recipe(CraftingRecipe.create(
		"weapon_t9_wand", "Void Wand", "wand_t9",
		[{"item_id": "mat_nexus_crystal", "count": 15}, {"item_id": "mat_legendary_essence", "count": 10}, {"item_id": "mat_void_metal", "count": 8}, {"item_id": "mat_aetherium_shard", "count": 3}],
		50000, Enums.StationType.ANVIL, 18.0, 0.70,
		Enums.ProfessionType.BLACKSMITHING, 9
	))


# === ARMOR CRAFTING (Plan 11.2 – Armorsmithing, gold ×1.2) ===
func _init_armor_recipes() -> void:
	# Tier 1 armor: 4× Iron Ore + 2× Leather + 60 Gold
	for slot_data in [
		["helm", "helm_t1", "Iron Helm"],
		["chest", "chest_t1", "Iron Chestplate"],
		["gloves", "gloves_t1", "Iron Gloves"],
		["boots", "boots_t1", "Iron Boots"],
		["shoulders", "shoulders_t1", "Iron Pauldrons"],
		["belt", "belt_t1", "Iron Belt"],
	]:
		_add_recipe(CraftingRecipe.create(
			"armor_t1_%s" % slot_data[0], slot_data[2], slot_data[1],
			[{"item_id": "mat_iron_ore", "count": 4}, {"item_id": "mat_leather", "count": 2}],
			60, Enums.StationType.ANVIL, 4.0, 1.0,
			Enums.ProfessionType.BLACKSMITHING, 1
		))
	
	# Tier 3 armor: 6× Steel Ingot + 4× Leather + 3× Hard Wood + 600 Gold
	for slot_data in [
		["helm", "helm_t3", "Steel Helm"],
		["chest", "chest_t3", "Steel Chestplate"],
		["gloves", "gloves_t3", "Steel Gloves"],
		["boots", "boots_t3", "Steel Boots"],
		["shoulders", "shoulders_t3", "Steel Pauldrons"],
		["belt", "belt_t3", "Steel Belt"],
	]:
		_add_recipe(CraftingRecipe.create(
			"armor_t3_%s" % slot_data[0], slot_data[2], slot_data[1],
			[{"item_id": "mat_steel_ingot", "count": 6}, {"item_id": "mat_leather", "count": 4}, {"item_id": "mat_hard_wood", "count": 3}],
			600, Enums.StationType.ANVIL, 6.0, 1.0,
			Enums.ProfessionType.BLACKSMITHING, 3
		))
	
	# Tier 5 armor: 10× Mythril + 6× Silk + 4× Magic Essence + 2400 Gold
	for slot_data in [
		["helm", "helm_t5", "Mythril Helm"],
		["chest", "chest_t5", "Mythril Chestplate"],
		["gloves", "gloves_t5", "Mythril Gloves"],
		["boots", "boots_t5", "Mythril Boots"],
		["shoulders", "shoulders_t5", "Mythril Pauldrons"],
		["belt", "belt_t5", "Mythril Belt"],
	]:
		_add_recipe(CraftingRecipe.create(
			"armor_t5_%s" % slot_data[0], slot_data[2], slot_data[1],
			[{"item_id": "mat_mythril_ore", "count": 10}, {"item_id": "mat_silk", "count": 6}, {"item_id": "mat_magic_essence", "count": 4}],
			2400, Enums.StationType.ANVIL, 10.0, 0.95,
			Enums.ProfessionType.BLACKSMITHING, 5
		))
	
	# Tier 7 armor: 15× Demon Steel + 10× Shadow Silk + 6× Rare Essence + 12000 Gold
	for slot_data in [
		["helm", "helm_t7", "Demon Helm"],
		["chest", "chest_t7", "Demon Chestplate"],
		["gloves", "gloves_t7", "Demon Gloves"],
		["boots", "boots_t7", "Demon Boots"],
		["shoulders", "shoulders_t7", "Demon Pauldrons"],
		["belt", "belt_t7", "Demon Belt"],
	]:
		_add_recipe(CraftingRecipe.create(
			"armor_t7_%s" % slot_data[0], slot_data[2], slot_data[1],
			[{"item_id": "mat_demon_steel", "count": 15}, {"item_id": "mat_shadow_silk", "count": 10}, {"item_id": "mat_rare_essence", "count": 6}],
			12000, Enums.StationType.ANVIL, 14.0, 0.85,
			Enums.ProfessionType.BLACKSMITHING, 7
		))
	
	# Tier 9 armor: 20× Void Metal + 15× Nexus Crystal + 10× Legendary Essence + 4× Aetherium + 60000 Gold
	for slot_data in [
		["helm", "helm_t9", "Void Helm"],
		["chest", "chest_t9", "Void Chestplate"],
		["gloves", "gloves_t9", "Void Gloves"],
		["boots", "boots_t9", "Void Boots"],
		["shoulders", "shoulders_t9", "Void Pauldrons"],
		["belt", "belt_t9", "Void Belt"],
	]:
		_add_recipe(CraftingRecipe.create(
			"armor_t9_%s" % slot_data[0], slot_data[2], slot_data[1],
			[{"item_id": "mat_void_metal", "count": 20}, {"item_id": "mat_nexus_crystal", "count": 15}, {"item_id": "mat_legendary_essence", "count": 10}, {"item_id": "mat_aetherium_shard", "count": 4}],
			60000, Enums.StationType.ANVIL, 20.0, 0.70,
			Enums.ProfessionType.BLACKSMITHING, 9
		))


# === ALCHEMY RECIPES (Plan 11.3) ===
func _init_alchemy_recipes() -> void:
	# Health Potion Small: 2× Red Herb + 1× Water → Heal 50 HP
	_add_recipe(CraftingRecipe.create(
		"craft_hp_small", "Small Health Potion", "potion_hp_small",
		[{"item_id": "mat_red_herb", "count": 2}, {"item_id": "mat_water", "count": 1}],
		10, Enums.StationType.ALCHEMY_TABLE, 1.5, 1.0,
		Enums.ProfessionType.ALCHEMY, 1
	))
	# Health Potion Medium: 3× Red Herb + 1× Crystal Water → Heal 150 HP
	_add_recipe(CraftingRecipe.create(
		"craft_hp_medium", "Medium Health Potion", "potion_hp_medium",
		[{"item_id": "mat_red_herb", "count": 3}, {"item_id": "mat_crystal_water", "count": 1}],
		30, Enums.StationType.ALCHEMY_TABLE, 2.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 3
	))
	# Health Potion Large: 5× Red Herb + 2× Crystal Water + 1× Life Essence → Heal 400 HP
	_add_recipe(CraftingRecipe.create(
		"craft_hp_large", "Large Health Potion", "potion_hp_large",
		[{"item_id": "mat_red_herb", "count": 5}, {"item_id": "mat_crystal_water", "count": 2}, {"item_id": "mat_life_essence", "count": 1}],
		80, Enums.StationType.ALCHEMY_TABLE, 3.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 5
	))
	# Mana Potion Small: 2× Blue Mushroom + 1× Water → Restore 30 Mana
	_add_recipe(CraftingRecipe.create(
		"craft_mp_small", "Small Mana Potion", "potion_mp_small",
		[{"item_id": "mat_blue_mushroom", "count": 2}, {"item_id": "mat_water", "count": 1}],
		10, Enums.StationType.ALCHEMY_TABLE, 1.5, 1.0,
		Enums.ProfessionType.ALCHEMY, 1
	))
	# Mana Potion Medium: 3× Blue Mushroom + 1× Crystal Water → Restore 80 Mana
	_add_recipe(CraftingRecipe.create(
		"craft_mp_medium", "Medium Mana Potion", "potion_mp_medium",
		[{"item_id": "mat_blue_mushroom", "count": 3}, {"item_id": "mat_crystal_water", "count": 1}],
		30, Enums.StationType.ALCHEMY_TABLE, 2.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 3
	))
	# Mana Potion Large: 5× Blue Mushroom + 2× Crystal Water + 1× Mana Crystal → Restore 200 Mana
	_add_recipe(CraftingRecipe.create(
		"craft_mp_large", "Large Mana Potion", "potion_mp_large",
		[{"item_id": "mat_blue_mushroom", "count": 5}, {"item_id": "mat_crystal_water", "count": 2}, {"item_id": "mat_mana_crystal", "count": 1}],
		80, Enums.StationType.ALCHEMY_TABLE, 3.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 5
	))
	# Super HP Potion
	_add_recipe(CraftingRecipe.create(
		"craft_hp_super", "Super Health Potion", "potion_hp_super",
		[{"item_id": "mat_red_herb", "count": 10}, {"item_id": "mat_life_essence", "count": 3}, {"item_id": "mat_crystal_water", "count": 5}],
		200, Enums.StationType.ALCHEMY_TABLE, 5.0, 0.90,
		Enums.ProfessionType.ALCHEMY, 7
	))
	# Super MP Potion
	_add_recipe(CraftingRecipe.create(
		"craft_mp_super", "Super Mana Potion", "potion_mp_super",
		[{"item_id": "mat_blue_mushroom", "count": 10}, {"item_id": "mat_mana_crystal", "count": 3}, {"item_id": "mat_crystal_water", "count": 5}],
		200, Enums.StationType.ALCHEMY_TABLE, 5.0, 0.90,
		Enums.ProfessionType.ALCHEMY, 7
	))
	# Fire Resist Potion: 3× Fire Flower + 2× Ice Crystal → +30% Fire Resist 120s
	_add_recipe(CraftingRecipe.create(
		"craft_fire_resist", "Fire Resistance Potion", "potion_fire_resist",
		[{"item_id": "mat_fire_flower", "count": 3}, {"item_id": "mat_ice_crystal", "count": 2}],
		60, Enums.StationType.ALCHEMY_TABLE, 3.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 4
	))
	# Ice Resist Potion
	_add_recipe(CraftingRecipe.create(
		"craft_ice_resist", "Ice Resistance Potion", "potion_ice_resist",
		[{"item_id": "mat_ice_crystal", "count": 3}, {"item_id": "mat_fire_flower", "count": 2}],
		60, Enums.StationType.ALCHEMY_TABLE, 3.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 4
	))
	# Poison Resist Potion
	_add_recipe(CraftingRecipe.create(
		"craft_poison_resist", "Poison Resistance Potion", "potion_poison_resist",
		[{"item_id": "mat_green_herb", "count": 3}, {"item_id": "mat_poison_gland", "count": 2}],
		60, Enums.StationType.ALCHEMY_TABLE, 3.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 4
	))
	# Antidote: 3× Green Herb + 1× Purification Salt → Cure poison, +10min immunity
	_add_recipe(CraftingRecipe.create(
		"craft_antidote", "Antidote", "potion_antidote",
		[{"item_id": "mat_green_herb", "count": 3}, {"item_id": "mat_purification_salt", "count": 1}],
		25, Enums.StationType.ALCHEMY_TABLE, 2.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 2
	))
	# XP Boost Potion
	_add_recipe(CraftingRecipe.create(
		"craft_xp_boost", "XP Boost Elixir", "potion_xp_boost",
		[{"item_id": "mat_life_essence", "count": 2}, {"item_id": "mat_mana_crystal", "count": 2}, {"item_id": "mat_crystal_water", "count": 3}],
		150, Enums.StationType.ALCHEMY_TABLE, 5.0, 0.85,
		Enums.ProfessionType.ALCHEMY, 6
	))


# === ENCHANTING RECIPES (Plan 11.4) ===
func _init_enchanting_recipes() -> void:
	# Basic Enchant: 1× Magic Dust → +1 random affix
	_add_recipe(CraftingRecipe.create(
		"enchant_basic", "Basic Enchantment", "enchant_basic",
		[{"item_id": "mat_magic_dust", "count": 1}],
		100, Enums.StationType.ENCHANTING_TABLE, 4.0, 0.90,
		Enums.ProfessionType.ENCHANTING, 1
	))
	# Advanced Enchant: 3× Enchant Crystal → Reroll 1 affix
	_add_recipe(CraftingRecipe.create(
		"enchant_advanced", "Advanced Enchantment", "enchant_advanced",
		[{"item_id": "mat_enchant_crystal", "count": 3}],
		500, Enums.StationType.ENCHANTING_TABLE, 6.0, 0.80,
		Enums.ProfessionType.ENCHANTING, 5
	))
	# Masterwork: 5× Legendary Dust + 2× Aetherium → Add socket
	_add_recipe(CraftingRecipe.create(
		"enchant_masterwork", "Masterwork Enchantment", "enchant_masterwork",
		[{"item_id": "mat_legendary_dust", "count": 5}, {"item_id": "mat_aetherium_shard", "count": 2}],
		5000, Enums.StationType.ENCHANTING_TABLE, 12.0, 0.65,
		Enums.ProfessionType.ENCHANTING, 8
	))
	# Enchant: Critical Strike
	_add_recipe(CraftingRecipe.create(
		"enchant_crit", "Enchant: Critical Strike", "enchant_crit",
		[{"item_id": "mat_enchant_crystal", "count": 5}, {"item_id": "mat_demon_shard", "count": 3}],
		300, Enums.StationType.ENCHANTING_TABLE, 5.0, 0.85,
		Enums.ProfessionType.ENCHANTING, 4
	))
	# Enchant: Lifesteal
	_add_recipe(CraftingRecipe.create(
		"enchant_lifesteal", "Enchant: Lifesteal", "enchant_lifesteal",
		[{"item_id": "mat_enchant_crystal", "count": 5}, {"item_id": "mat_monster_bone", "count": 5}],
		350, Enums.StationType.ENCHANTING_TABLE, 5.0, 0.80,
		Enums.ProfessionType.ENCHANTING, 5
	))


# === WORKBENCH RECIPES (tools & refinement) ===
func _init_workbench_recipes() -> void:
	_add_recipe(CraftingRecipe.create(
		"refine_steel_ingot", "Steel Ingot", "mat_steel_ingot",
		[{"item_id": "mat_iron_ore", "count": 3}, {"item_id": "mat_ember_core", "count": 1}],
		30, Enums.StationType.WORKBENCH, 2.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 2
	))
	_add_recipe(CraftingRecipe.create(
		"refine_crystal_vial", "Crystal Vial", "mat_crystal_vial",
		[{"item_id": "mat_mountain_crystal", "count": 1}, {"item_id": "mat_stone", "count": 2}],
		15, Enums.StationType.WORKBENCH, 1.5, 1.0,
		Enums.ProfessionType.ENGINEERING, 1
	))
	_add_recipe(CraftingRecipe.create(
		"refine_crystal_water", "Crystal Water", "mat_crystal_water",
		[{"item_id": "mat_water", "count": 2}, {"item_id": "mat_mountain_crystal", "count": 1}],
		20, Enums.StationType.WORKBENCH, 2.0, 1.0,
		Enums.ProfessionType.ENGINEERING, 2
	))
	_add_recipe(CraftingRecipe.create(
		"basic_tool", "Basic Gathering Tool", "basic_tool",
		[{"item_id": "mat_wood", "count": 5}, {"item_id": "mat_stone", "count": 3}],
		20, Enums.StationType.WORKBENCH, 2.0, 1.0
	))
	_add_recipe(CraftingRecipe.create(
		"iron_tool", "Iron Gathering Tool", "iron_tool",
		[{"item_id": "mat_iron_ore", "count": 5}, {"item_id": "mat_wood", "count": 3}],
		100, Enums.StationType.WORKBENCH, 3.0, 1.0,
		Enums.ProfessionType.ENGINEERING, 3
	))
	_add_recipe(CraftingRecipe.create(
		"steel_tool", "Steel Gathering Tool", "steel_tool",
		[{"item_id": "mat_steel_ingot", "count": 8}, {"item_id": "mat_wood", "count": 5}],
		300, Enums.StationType.WORKBENCH, 4.0, 1.0,
		Enums.ProfessionType.ENGINEERING, 6
	))


# === RUNE ALTAR RECIPES (endgame) ===
func _init_rune_altar_recipes() -> void:
	var ashen_armor := CraftingRecipe.create(
		"ashen_armor", "Legendary Ashen Armor", "ashen_armor",
		[{"item_id": "mat_dragonscale", "count": 5}, {"item_id": "mat_ember_core", "count": 3}, {"item_id": "mat_god_essence", "count": 1}],
		5000, Enums.StationType.RUNE_ALTAR, 15.0, 0.60,
		Enums.ProfessionType.BLACKSMITHING, 9
	)
	ashen_armor.dark_essence_cost = 50
	ashen_armor.relic_fragment_cost = 10
	ashen_armor.result_rarity = Enums.Rarity.LEGENDARY
	_add_recipe(ashen_armor)
	
	var void_blade := CraftingRecipe.create(
		"legendary_void_blade", "Legendary Void Blade", "void_blade",
		[{"item_id": "mat_void_crystal", "count": 8}, {"item_id": "mat_void_metal", "count": 15}, {"item_id": "mat_primordial_fragment", "count": 2}],
		25000, Enums.StationType.RUNE_ALTAR, 20.0, 0.50,
		Enums.ProfessionType.BLACKSMITHING, 10
	)
	void_blade.dark_essence_cost = 100
	void_blade.relic_fragment_cost = 25
	void_blade.result_rarity = Enums.Rarity.LEGENDARY
	_add_recipe(void_blade)
	
	var titan_plate := CraftingRecipe.create(
		"legendary_titan_plate", "Legendary Titan Plate", "titan_plate",
		[{"item_id": "mat_titan_ore", "count": 10}, {"item_id": "mat_dragonscale", "count": 5}, {"item_id": "mat_god_essence", "count": 2}],
		30000, Enums.StationType.RUNE_ALTAR, 20.0, 0.50,
		Enums.ProfessionType.BLACKSMITHING, 10
	)
	titan_plate.dark_essence_cost = 100
	titan_plate.relic_fragment_cost = 25
	titan_plate.result_rarity = Enums.Rarity.LEGENDARY
	_add_recipe(titan_plate)


func _add_recipe(recipe: CraftingRecipe) -> void:
	_recipes[recipe.recipe_id] = recipe


## Recept lekérdezés
func get_recipe(recipe_id: String) -> CraftingRecipe:
	return _recipes.get(recipe_id)


## Összes recept
func get_all_recipes() -> Array[CraftingRecipe]:
	var result: Array[CraftingRecipe] = []
	for key in _recipes:
		result.append(_recipes[key])
	return result


## Elérhető receptek (station + profession szint alapján)
func get_available_recipes(station: int, profession_levels: Dictionary = {}) -> Array[CraftingRecipe]:
	var result: Array[CraftingRecipe] = []
	for key in _recipes:
		var recipe: CraftingRecipe = _recipes[key]
		if recipe.required_station != station:
			continue
		# Profession level check
		if recipe.required_profession >= 0:
			var current_level: int = profession_levels.get(recipe.required_profession, 0)
			if current_level < recipe.required_profession_level:
				continue
		result.append(recipe)
	return result


## Ellenőrzi, hogy craftolható-e egy recept
func can_craft(recipe_id: String) -> bool:
	var recipe := get_recipe(recipe_id)
	if not recipe:
		return false
	if _is_crafting:
		return false
	if not inventory_manager or not currency_manager:
		return false
	
	# Gold ellenőrzés
	if not currency_manager.can_afford_gold(recipe.gold_cost):
		return false
	
	# Dark Essence ellenőrzés
	if recipe.dark_essence_cost > 0:
		if not currency_manager.can_afford(Enums.CurrencyType.DARK_ESSENCE, recipe.dark_essence_cost):
			return false
	
	# Relic Fragment ellenőrzés
	if recipe.relic_fragment_cost > 0:
		if not currency_manager.can_afford(Enums.CurrencyType.RELIC_FRAGMENT, recipe.relic_fragment_cost):
			return false
	
	# Ingredient ellenőrzés
	for ingredient in recipe.ingredients:
		var item_id: String = ingredient.get("item_id", "")
		var count: int = ingredient.get("count", 1)
		if inventory_manager.count_item(item_id) < count:
			return false
	
	# Szabad hely ellenőrzés
	if not inventory_manager.has_free_slot():
		return false
	
	return true


## Crafting indítása
func start_craft(recipe_id: String) -> bool:
	if not can_craft(recipe_id):
		return false
	
	var recipe := get_recipe(recipe_id)
	_current_recipe = recipe
	_is_crafting = true
	
	# Költségek elvétele
	currency_manager.spend_gold(recipe.gold_cost)
	if recipe.dark_essence_cost > 0:
		currency_manager.spend_dark_essence(recipe.dark_essence_cost)
	if recipe.relic_fragment_cost > 0:
		currency_manager.spend_relic_fragments(recipe.relic_fragment_cost)
	
	# Ingredientek felhasználása
	for ingredient in recipe.ingredients:
		inventory_manager.consume_item(ingredient["item_id"], ingredient["count"])
	
	# Timer indítás
	_craft_timer.wait_time = recipe.crafting_time
	_craft_timer.start()
	
	EventBus.crafting_started.emit(recipe_id)
	return true


## Crafting timer lejárt
func _on_craft_timer_timeout() -> void:
	if not _current_recipe:
		_is_crafting = false
		return
	
	var recipe := _current_recipe
	var success := randf() <= recipe.success_rate
	
	if success:
		# Eredmény item létrehozása
		var result_item := _create_result_item(recipe)
		if result_item:
			inventory_manager.add_item(result_item)
		EventBus.crafting_completed.emit(recipe.recipe_id, true)
		
		# Profession XP
		if profession_manager and recipe.required_profession >= 0:
			var xp_amount := _calc_craft_xp(recipe)
			profession_manager.add_xp(recipe.required_profession, xp_amount)
	else:
		# Fail - material elvész, de item nem készül
		EventBus.crafting_failed.emit(recipe.recipe_id)
		EventBus.crafting_completed.emit(recipe.recipe_id, false)
	
	_current_recipe = null
	_is_crafting = false


## Eredmény item létrehozása
func _create_result_item(recipe: CraftingRecipe) -> ItemInstance:
	var base_item: ItemData = ItemDatabase.get_item(recipe.result_item_id)
	if not base_item:
		# Ha nincs az adatbázisban, generálunk egyet
		var item := LootGenerator.generate_item(
			maxi(1, recipe.required_profession_level),
			recipe.result_rarity
		)
		return item
	
	var instance := ItemInstance.new()
	instance.base_item = base_item
	instance.item_level = base_item.item_level
	instance.rarity = recipe.result_rarity
	instance.quantity = recipe.result_quantity
	return instance


## Craft XP kalkuláció
func _calc_craft_xp(recipe: CraftingRecipe) -> int:
	var base_xp := 10
	base_xp += recipe.required_profession_level * 2
	if recipe.success_rate < 1.0:
		base_xp = int(base_xp * 1.5)  # Nehezebb craft = több XP
	return base_xp


## Aktív crafting állapot
func is_crafting() -> bool:
	return _is_crafting


func get_craft_progress() -> float:
	if not _is_crafting or not _current_recipe:
		return 0.0
	var remaining := _craft_timer.time_left
	var total := _current_recipe.crafting_time
	if total <= 0:
		return 1.0
	return 1.0 - (remaining / total)

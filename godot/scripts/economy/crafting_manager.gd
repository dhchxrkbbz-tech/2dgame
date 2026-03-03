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
	# === ANVIL RECEPTEK (Blacksmithing) ===
	_add_recipe(CraftingRecipe.create(
		"iron_sword", "Iron Sword", "iron_sword",
		[{"item_id": "iron_ore", "count": 5}, {"item_id": "wood", "count": 2}],
		50, Enums.StationType.ANVIL, 3.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 1
	))
	
	_add_recipe(CraftingRecipe.create(
		"steel_sword", "Steel Sword", "steel_sword",
		[{"item_id": "steel_ingot", "count": 8}, {"item_id": "leather", "count": 3}],
		200, Enums.StationType.ANVIL, 5.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 10
	))
	
	_add_recipe(CraftingRecipe.create(
		"iron_chestplate", "Iron Chestplate", "iron_chestplate",
		[{"item_id": "iron_ore", "count": 8}, {"item_id": "leather", "count": 4}],
		80, Enums.StationType.ANVIL, 4.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 5
	))
	
	_add_recipe(CraftingRecipe.create(
		"dark_steel_blade", "Dark Steel Blade", "dark_steel_blade",
		[{"item_id": "dark_steel", "count": 10}, {"item_id": "dark_root", "count": 5}, {"item_id": "shadow_gem", "count": 1}],
		500, Enums.StationType.ANVIL, 8.0, 0.75,
		Enums.ProfessionType.BLACKSMITHING, 30
	))
	
	# === ALCHEMY TABLE RECEPTEK ===
	_add_recipe(CraftingRecipe.create(
		"health_potion_small", "Small Health Potion", "health_potion_small",
		[{"item_id": "red_herb", "count": 2}, {"item_id": "crystal_vial", "count": 1}],
		10, Enums.StationType.ALCHEMY_TABLE, 1.5, 1.0,
		Enums.ProfessionType.ALCHEMY, 1
	))
	
	_add_recipe(CraftingRecipe.create(
		"health_potion_medium", "Medium Health Potion", "health_potion_medium",
		[{"item_id": "red_herb", "count": 5}, {"item_id": "crystal_vial", "count": 1}],
		30, Enums.StationType.ALCHEMY_TABLE, 2.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 10
	))
	
	_add_recipe(CraftingRecipe.create(
		"health_potion_large", "Large Health Potion", "health_potion_large",
		[{"item_id": "red_herb", "count": 10}, {"item_id": "crystal", "count": 2}, {"item_id": "crystal_vial", "count": 1}],
		80, Enums.StationType.ALCHEMY_TABLE, 3.0, 1.0,
		Enums.ProfessionType.ALCHEMY, 20
	))
	
	_add_recipe(CraftingRecipe.create(
		"mana_potion_small", "Small Mana Potion", "mana_potion_small",
		[{"item_id": "blue_herb", "count": 2}, {"item_id": "crystal_vial", "count": 1}],
		10, Enums.StationType.ALCHEMY_TABLE, 1.5, 1.0,
		Enums.ProfessionType.ALCHEMY, 1
	))
	
	_add_recipe(CraftingRecipe.create(
		"poison_coat_basic", "Basic Poison Coat", "poison_coat_basic",
		[{"item_id": "dark_root", "count": 3}, {"item_id": "bone", "count": 2}],
		40, Enums.StationType.ALCHEMY_TABLE, 2.5, 1.0,
		Enums.ProfessionType.ALCHEMY, 15
	))
	
	_add_recipe(CraftingRecipe.create(
		"damage_scroll", "Damage Scroll", "damage_scroll",
		[{"item_id": "herb", "count": 3}, {"item_id": "crystal", "count": 1}],
		50, Enums.StationType.ALCHEMY_TABLE, 2.0, 0.9,
		Enums.ProfessionType.ALCHEMY, 20
	))
	
	# === WORKBENCH RECEPTEK ===
	_add_recipe(CraftingRecipe.create(
		"basic_tool", "Basic Gathering Tool", "basic_tool",
		[{"item_id": "wood", "count": 5}, {"item_id": "stone", "count": 3}],
		20, Enums.StationType.WORKBENCH, 2.0, 1.0
	))
	
	_add_recipe(CraftingRecipe.create(
		"iron_tool", "Iron Gathering Tool", "iron_tool",
		[{"item_id": "iron_ore", "count": 5}, {"item_id": "wood", "count": 3}],
		100, Enums.StationType.WORKBENCH, 3.0, 1.0,
		Enums.ProfessionType.ENGINEERING, 5
	))
	
	_add_recipe(CraftingRecipe.create(
		"steel_tool", "Steel Gathering Tool", "steel_tool",
		[{"item_id": "steel_ingot", "count": 8}, {"item_id": "wood", "count": 5}],
		300, Enums.StationType.WORKBENCH, 4.0, 1.0,
		Enums.ProfessionType.ENGINEERING, 20
	))
	
	_add_recipe(CraftingRecipe.create(
		"crystal_vial", "Crystal Vial", "crystal_vial",
		[{"item_id": "crystal", "count": 1}, {"item_id": "stone", "count": 2}],
		15, Enums.StationType.WORKBENCH, 1.5, 1.0,
		Enums.ProfessionType.ENGINEERING, 1
	))
	
	_add_recipe(CraftingRecipe.create(
		"steel_ingot", "Steel Ingot", "steel_ingot",
		[{"item_id": "iron_ore", "count": 3}, {"item_id": "ember_coal", "count": 2}],
		30, Enums.StationType.WORKBENCH, 2.0, 1.0,
		Enums.ProfessionType.BLACKSMITHING, 10
	))
	
	# === ENCHANTING TABLE RECEPTEK ===
	_add_recipe(CraftingRecipe.create(
		"enchant_crit", "Enchant: Critical Strike", "enchant_crit",
		[{"item_id": "crystal", "count": 5}, {"item_id": "dark_root", "count": 3}],
		200, Enums.StationType.ENCHANTING_TABLE, 5.0, 0.85,
		Enums.ProfessionType.ENCHANTING, 15
	))
	
	_add_recipe(CraftingRecipe.create(
		"enchant_lifesteal", "Enchant: Lifesteal", "enchant_lifesteal",
		[{"item_id": "crystal", "count": 5}, {"item_id": "bone", "count": 5}],
		250, Enums.StationType.ENCHANTING_TABLE, 5.0, 0.80,
		Enums.ProfessionType.ENCHANTING, 20
	))
	
	# === RUNE ALTAR RECEPTEK (endgame) ===
	var ashen_armor := CraftingRecipe.create(
		"ashen_armor", "Legendary Ashen Armor", "ashen_armor",
		[{"item_id": "dragon_scale", "count": 5}, {"item_id": "ashen_core", "count": 2}],
		2000, Enums.StationType.RUNE_ALTAR, 15.0, 0.60,
		Enums.ProfessionType.BLACKSMITHING, 45
	)
	ashen_armor.dark_essence_cost = 50
	ashen_armor.relic_fragment_cost = 10
	ashen_armor.result_rarity = Enums.Rarity.LEGENDARY
	_add_recipe(ashen_armor)


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

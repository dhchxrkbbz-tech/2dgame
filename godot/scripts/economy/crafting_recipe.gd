## CraftingRecipe - Crafting recept Resource definíció
class_name CraftingRecipe
extends Resource

@export var recipe_id: String = ""
@export var recipe_name: String = ""
@export var description: String = ""

## Eredmény item
@export var result_item_id: String = ""
@export var result_quantity: int = 1
@export var result_rarity: int = Enums.Rarity.COMMON

## Hozzávalók: [{"item_id": "iron_ore", "count": 5}]
@export var ingredients: Array[Dictionary] = []

## Költségek
@export var gold_cost: int = 0
@export var dark_essence_cost: int = 0
@export var relic_fragment_cost: int = 0

## Crafting feltételek
@export var crafting_time: float = 2.0  # másodperc
@export var required_station: int = Enums.StationType.WORKBENCH
@export var required_profession: int = -1  # Enums.ProfessionType, -1 = nincs
@export var required_profession_level: int = 0
@export var success_rate: float = 1.0  # 0.0 - 1.0


## Factory metódus
static func create(
	p_id: String,
	p_name: String,
	p_result_id: String,
	p_ingredients: Array[Dictionary],
	p_gold: int = 0,
	p_station: int = Enums.StationType.WORKBENCH,
	p_time: float = 2.0,
	p_success: float = 1.0,
	p_prof: int = -1,
	p_prof_lvl: int = 0
) -> CraftingRecipe:
	var recipe := CraftingRecipe.new()
	recipe.recipe_id = p_id
	recipe.recipe_name = p_name
	recipe.result_item_id = p_result_id
	recipe.ingredients = p_ingredients
	recipe.gold_cost = p_gold
	recipe.required_station = p_station
	recipe.crafting_time = p_time
	recipe.success_rate = p_success
	recipe.required_profession = p_prof
	recipe.required_profession_level = p_prof_lvl
	return recipe

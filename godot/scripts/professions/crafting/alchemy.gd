## Alchemy - Alkímia crafting profession
## Italok, mérgek, főzetek készítése
class_name AlchemyProfession
extends ProfessionBase


func _init() -> void:
	super._init(Enums.ProfessionType.ALCHEMY, "Alchemy")


func craft(recipe: Dictionary, available_materials: Dictionary, available_gold: int) -> Dictionary:
	var required_level: int = recipe.get("required_skill_level", 1)
	if current_level < required_level:
		return {"success": false, "reason": "Skill level too low"}
	
	var ingredients: Array = recipe.get("ingredients", [])
	for ingredient in ingredients:
		var item_id: String = ingredient.get("item_id", "")
		var count: int = ingredient.get("count", 1)
		if available_materials.get(item_id, 0) < count:
			return {"success": false, "reason": "Missing materials: %s" % item_id}
	
	var gold_cost: int = recipe.get("gold_cost", 0)
	if available_gold < gold_cost:
		return {"success": false, "reason": "Not enough gold"}
	
	var success_rate: float = recipe.get("success_rate", 1.0)
	var level_bonus: float = maxf(0.0, (current_level - required_level) * 0.01)
	success_rate = minf(success_rate + level_bonus, 1.0)
	
	var succeeded: bool = randf() < success_rate
	
	var xp_gain: int = recipe.get("craft_xp", 20)
	gain_xp(xp_gain)
	
	# Alchemy bonus: chance extra potion
	var bonus_count: int = 0
	if succeeded and current_level >= 20:
		if randf() < 0.1 + (current_level - 20) * 0.005:
			bonus_count = 1
	
	if not succeeded:
		return {
			"success": false,
			"reason": "Brew failed!",
			"materials_consumed": true,
			"gold_consumed": gold_cost,
			"xp_gained": xp_gain / 2,
		}
	
	var result := {
		"success": true,
		"result_item": recipe.get("result_item", ""),
		"result_count": recipe.get("result_count", 1) + bonus_count,
		"gold_consumed": gold_cost,
		"materials_consumed": true,
		"xp_gained": xp_gain,
	}
	
	action_completed.emit(result)
	EventBus.crafting_completed.emit(recipe.get("recipe_id", ""), true)
	return result


func get_available_tier() -> int:
	if current_level >= 41: return 5
	elif current_level >= 31: return 4
	elif current_level >= 21: return 3
	elif current_level >= 11: return 2
	return 1


## Potion erősség szorzó (szint alapján)
func get_potion_effectiveness() -> float:
	return 1.0 + current_level * 0.01

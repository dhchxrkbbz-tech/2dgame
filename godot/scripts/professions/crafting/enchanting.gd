## Enchanting - Varázslás crafting profession
## Enchant-ok, rúnák, gem kezelés
class_name EnchantingProfession
extends ProfessionBase


func _init() -> void:
	super._init(Enums.ProfessionType.ENCHANTING, "Enchanting")


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
	var level_bonus: float = maxf(0.0, (current_level - required_level) * 0.015)
	success_rate = minf(success_rate + level_bonus, 1.0)
	
	var succeeded: bool = randf() < success_rate
	
	var xp_gain: int = recipe.get("craft_xp", 30)
	gain_xp(xp_gain)
	
	if not succeeded:
		return {
			"success": false,
			"reason": "Enchanting failed!",
			"materials_consumed": true,
			"gold_consumed": gold_cost,
			"xp_gained": xp_gain / 2,
		}
	
	var result := {
		"success": true,
		"result_item": recipe.get("result_item", ""),
		"gold_consumed": gold_cost,
		"materials_consumed": true,
		"xp_gained": xp_gain,
	}
	
	action_completed.emit(result)
	EventBus.crafting_completed.emit(recipe.get("recipe_id", ""), true)
	return result


## Enchant alkalmazása item-re
func apply_enchant(item_data: Dictionary, enchant_type: String, enchant_level: int) -> Dictionary:
	var required: int = enchant_level * 10
	if current_level < required:
		return {"success": false, "reason": "Enchanting level too low"}
	
	var success: bool = randf() < (0.7 + current_level * 0.006)
	
	if success:
		EventBus.enchant_applied.emit(item_data.get("uuid", ""), enchant_type)
	
	gain_xp(25 + enchant_level * 5)
	
	return {
		"success": success,
		"enchant_type": enchant_type,
		"enchant_level": enchant_level,
	}


func get_available_tier() -> int:
	if current_level >= 41: return 5
	elif current_level >= 31: return 4
	elif current_level >= 21: return 3
	elif current_level >= 11: return 2
	return 1

## Tailoring - Szabómesterség crafting profession
## Szövet páncélok, köpenyek készítése
class_name TailoringProfession
extends ProfessionBase


func _init() -> void:
	super._init(Enums.ProfessionType.ENGINEERING, "Tailoring")


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
	
	var xp_gain: int = recipe.get("craft_xp", 22)
	gain_xp(xp_gain)
	
	if not succeeded:
		return {
			"success": false,
			"reason": "Tailoring failed!",
			"materials_consumed": true,
			"gold_consumed": gold_cost,
			"xp_gained": xp_gain / 2,
		}
	
	# Tailoring bonus: extra socket chance
	var bonus_socket: bool = false
	if current_level >= 30 and randf() < 0.05 + (current_level - 30) * 0.005:
		bonus_socket = true
	
	var result := {
		"success": true,
		"result_item": recipe.get("result_item", ""),
		"gold_consumed": gold_cost,
		"materials_consumed": true,
		"xp_gained": xp_gain,
		"bonus_socket": bonus_socket,
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

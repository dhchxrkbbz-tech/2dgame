## Blacksmithing - Kovácsmesterség crafting profession
## Fegyverek és páncélok készítése
class_name BlacksmithingProfession
extends ProfessionBase


func _init() -> void:
	super._init(Enums.ProfessionType.BLACKSMITHING, "Blacksmithing")


## Kovácsolás végrehajtása
func craft(recipe: Dictionary, available_materials: Dictionary, available_gold: int) -> Dictionary:
	var required_level: int = recipe.get("required_skill_level", 1)
	if current_level < required_level:
		return {"success": false, "reason": "Skill level too low"}
	
	# Anyag check
	var ingredients: Array = recipe.get("ingredients", [])
	for ingredient in ingredients:
		var item_id: String = ingredient.get("item_id", "")
		var count: int = ingredient.get("count", 1)
		if available_materials.get(item_id, 0) < count:
			return {"success": false, "reason": "Missing materials: %s" % item_id}
	
	# Gold check
	var gold_cost: int = recipe.get("gold_cost", 0)
	if available_gold < gold_cost:
		return {"success": false, "reason": "Not enough gold"}
	
	# Success rate
	var success_rate: float = recipe.get("success_rate", 1.0)
	# Szint bónusz: +1% per szint a recipe szint felett
	var level_bonus: float = maxf(0.0, (current_level - required_level) * 0.01)
	success_rate = minf(success_rate + level_bonus, 1.0)
	
	var succeeded: bool = randf() < success_rate
	
	# XP mindig jár
	var xp_gain: int = recipe.get("craft_xp", 25)
	gain_xp(xp_gain)
	
	if not succeeded:
		return {
			"success": false,
			"reason": "Crafting failed!",
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


## Elérhető receptek a szint alapján
func get_available_tier() -> int:
	if current_level >= 41:
		return 5  # Legendary
	elif current_level >= 31:
		return 4  # Epic
	elif current_level >= 21:
		return 3  # Rare
	elif current_level >= 11:
		return 2  # Uncommon
	return 1  # Basic


## Enhancement (gear +1 → +10)
func enhance_item(item_data: Dictionary, enhancement_level: int, available_gold: int, available_materials: int) -> Dictionary:
	if enhancement_level < 0 or enhancement_level >= 10:
		return {"success": false, "reason": "Invalid enhancement level"}
	
	var success_rate: float = Constants.ENHANCEMENT_SUCCESS_RATES[enhancement_level]
	var gold_cost: int = Constants.ENHANCEMENT_GOLD_COSTS[enhancement_level]
	var mat_cost: int = Constants.ENHANCEMENT_MATERIAL_COSTS[enhancement_level]
	
	if available_gold < gold_cost:
		return {"success": false, "reason": "Not enough gold"}
	if available_materials < mat_cost:
		return {"success": false, "reason": "Not enough materials"}
	
	var succeeded: bool = randf() < success_rate
	
	EventBus.enhancement_attempted.emit(
		item_data.get("uuid", ""), enhancement_level + 1, succeeded
	)
	
	return {
		"success": succeeded,
		"new_level": enhancement_level + 1 if succeeded else enhancement_level,
		"gold_consumed": gold_cost,
		"materials_consumed": mat_cost,
	}

## Skinning - Nyúzás/Scavenging gathering profession
## Node típusok: Bone, egyéb enemy loot
class_name SkinningProfession
extends ProfessionBase


func _init() -> void:
	super._init(Enums.ProfessionType.SCAVENGING, "Scavenging")


func can_skin(node_type: Enums.GatheringNodeType) -> bool:
	match node_type:
		Enums.GatheringNodeType.BONE:
			return true
	return false


func can_scavenge_enemy(enemy_level: int) -> bool:
	return current_level >= maxi(1, enemy_level - 5)


func scavenge(node_type: Enums.GatheringNodeType, tool_tier: Enums.ToolTier) -> Dictionary:
	if not can_skin(node_type):
		return {"success": false, "reason": "Cannot scavenge this"}
	
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var tool_data: Dictionary = Constants.TOOL_TIER_MULTIPLIERS.get(tool_tier, {})
	
	var yield_min: int = node_data.get("yield_min", 2)
	var yield_max: int = node_data.get("yield_max", 5)
	var yield_mult: float = tool_data.get("yield", 1.0)
	
	var base_yield: int = randi_range(yield_min, yield_max)
	var final_yield: int = int(base_yield * yield_mult)
	final_yield += current_level / 10
	
	var xp_gain: int = 12
	gain_xp(xp_gain)
	
	var result := {
		"success": true,
		"yield": final_yield,
		"node_type": node_type,
		"xp_gained": xp_gain,
	}
	
	action_completed.emit(result)
	EventBus.gathering_completed.emit(node_type, final_yield)
	return result


## Enemy-ből scavenge (kill után)
func scavenge_enemy(enemy_level: int, enemy_biome: Enums.BiomeType) -> Dictionary:
	if not can_scavenge_enemy(enemy_level):
		return {"success": false, "reason": "Level too low"}
	
	var yield_amount: int = randi_range(1, 3)
	yield_amount += current_level / 15
	
	# Biome-specifikus anyag
	var material_type: String = _get_biome_material(enemy_biome)
	
	var xp_gain: int = 15 + enemy_level
	gain_xp(xp_gain)
	
	var result := {
		"success": true,
		"yield": yield_amount,
		"material": material_type,
		"xp_gained": xp_gain,
	}
	
	action_completed.emit(result)
	return result


func _get_biome_material(biome: Enums.BiomeType) -> String:
	match biome:
		Enums.BiomeType.STARTING_MEADOW: return "animal_hide"
		Enums.BiomeType.CURSED_FOREST: return "corrupted_hide"
		Enums.BiomeType.DARK_SWAMP: return "swamp_leather"
		Enums.BiomeType.RUINS: return "ancient_cloth"
		Enums.BiomeType.MOUNTAINS: return "thick_fur"
		Enums.BiomeType.FROZEN_WASTES: return "frost_pelt"
		Enums.BiomeType.ASHLANDS: return "charred_scales"
		Enums.BiomeType.PLAGUE_LANDS: return "plague_tissue"
	return "raw_material"


func get_channel_time(_node_type: Enums.GatheringNodeType, tool_tier: Enums.ToolTier) -> float:
	var tool_data: Dictionary = Constants.TOOL_TIER_MULTIPLIERS.get(tool_tier, {})
	return 2.0 / tool_data.get("speed", 1.0)

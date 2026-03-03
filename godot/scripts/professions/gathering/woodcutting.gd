## Woodcutting - Favágás gathering profession
## Node típusok: Wood
class_name WoodcuttingProfession
extends ProfessionBase


func _init() -> void:
	super._init(Enums.ProfessionType.WOODCUTTING, "Woodcutting")


func can_chop(node_type: Enums.GatheringNodeType) -> bool:
	return node_type == Enums.GatheringNodeType.WOOD


func chop(node_type: Enums.GatheringNodeType, tool_tier: Enums.ToolTier) -> Dictionary:
	if not can_chop(node_type):
		return {"success": false, "reason": "Wrong node type"}
	
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var tool_data: Dictionary = Constants.TOOL_TIER_MULTIPLIERS.get(tool_tier, {})
	
	var yield_min: int = node_data.get("yield_min", 3)
	var yield_max: int = node_data.get("yield_max", 8)
	var yield_mult: float = tool_data.get("yield", 1.0)
	
	var base_yield: int = randi_range(yield_min, yield_max)
	var final_yield: int = int(base_yield * yield_mult)
	final_yield += current_level / 10
	
	# Ritka fa anyag chance (magasabb szinten)
	var rare_wood: bool = randf() < (0.03 + current_level * 0.002)
	
	var xp_gain: int = 10 + current_level / 5
	gain_xp(xp_gain)
	
	var result := {
		"success": true,
		"yield": final_yield,
		"node_type": node_type,
		"rare_wood": rare_wood,
		"xp_gained": xp_gain,
	}
	
	action_completed.emit(result)
	EventBus.gathering_completed.emit(node_type, final_yield)
	return result


func get_channel_time(node_type: Enums.GatheringNodeType, tool_tier: Enums.ToolTier) -> float:
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var tool_data: Dictionary = Constants.TOOL_TIER_MULTIPLIERS.get(tool_tier, {})
	var base_time: float = node_data.get("channel_time", 2.0)
	return base_time / tool_data.get("speed", 1.0)

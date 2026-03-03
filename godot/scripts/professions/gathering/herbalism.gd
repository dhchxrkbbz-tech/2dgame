## Herbalism - Gyógynövény gyűjtés gathering profession
## Node típusok: Herb, Dark Root
class_name HerbalismProfession
extends ProfessionBase


func _init() -> void:
	super._init(Enums.ProfessionType.HERBALISM, "Herbalism")


func can_gather(node_type: Enums.GatheringNodeType) -> bool:
	match node_type:
		Enums.GatheringNodeType.HERB:
			return true
		Enums.GatheringNodeType.DARK_ROOT:
			return current_level >= 20
	return false


func gather(node_type: Enums.GatheringNodeType, tool_tier: Enums.ToolTier) -> Dictionary:
	if not can_gather(node_type):
		return {"success": false, "reason": "Level too low"}
	
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var tool_data: Dictionary = Constants.TOOL_TIER_MULTIPLIERS.get(tool_tier, {})
	
	var yield_min: int = node_data.get("yield_min", 1)
	var yield_max: int = node_data.get("yield_max", 3)
	var yield_mult: float = tool_data.get("yield", 1.0)
	
	var base_yield: int = randi_range(yield_min, yield_max)
	var final_yield: int = int(base_yield * yield_mult)
	final_yield += current_level / 10
	
	# Ritka gyógynövény chance
	var rare_herb: bool = randf() < (0.05 + current_level * 0.002)
	
	var xp_gain: int = _get_xp_for_node(node_type)
	gain_xp(xp_gain)
	
	var result := {
		"success": true,
		"yield": final_yield,
		"node_type": node_type,
		"rare_herb": rare_herb,
		"xp_gained": xp_gain,
	}
	
	action_completed.emit(result)
	EventBus.gathering_completed.emit(node_type, final_yield)
	return result


func _get_xp_for_node(node_type: Enums.GatheringNodeType) -> int:
	match node_type:
		Enums.GatheringNodeType.HERB: return 12
		Enums.GatheringNodeType.DARK_ROOT: return 28
	return 10


func get_channel_time(node_type: Enums.GatheringNodeType, tool_tier: Enums.ToolTier) -> float:
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var tool_data: Dictionary = Constants.TOOL_TIER_MULTIPLIERS.get(tool_tier, {})
	var base_time: float = node_data.get("channel_time", 1.5)
	return base_time / tool_data.get("speed", 1.0)

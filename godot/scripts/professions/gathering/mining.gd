## Mining - Bányászat gathering profession
## Node típusok: Stone, Ore, Crystal, Ember Coal
class_name MiningProfession
extends ProfessionBase


func _init() -> void:
	super._init(Enums.ProfessionType.MINING, "Mining")


## Bányászható-e az adott node
func can_mine(node_type: Enums.GatheringNodeType) -> bool:
	match node_type:
		Enums.GatheringNodeType.STONE:
			return true
		Enums.GatheringNodeType.ORE:
			return current_level >= 5
		Enums.GatheringNodeType.CRYSTAL:
			return current_level >= 15
		Enums.GatheringNodeType.EMBER_COAL:
			return current_level >= 25
	return false


## Bányászás végrehajtása
func mine(node_type: Enums.GatheringNodeType, tool_tier: Enums.ToolTier) -> Dictionary:
	if not can_mine(node_type):
		return {"success": false, "reason": "Level too low"}
	
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var tool_data: Dictionary = Constants.TOOL_TIER_MULTIPLIERS.get(tool_tier, {})
	
	var yield_min: int = node_data.get("yield_min", 1)
	var yield_max: int = node_data.get("yield_max", 3)
	var yield_mult: float = tool_data.get("yield", 1.0)
	
	var base_yield: int = randi_range(yield_min, yield_max)
	var final_yield: int = int(base_yield * yield_mult)
	
	# Level bonus (minden 10 szint +1 yield)
	final_yield += current_level / 10
	
	# Gem chance (bányászatból)
	var gem_found: bool = false
	var gem_chance: float = Constants.GEM_MINING_CHANCE_OTHER
	if node_type == Enums.GatheringNodeType.ORE or node_type == Enums.GatheringNodeType.CRYSTAL:
		gem_chance = Constants.GEM_MINING_CHANCE_MOUNTAINS
	gem_chance += current_level * Constants.GEM_MINING_QUALITY_PER_LEVEL * 0.01
	gem_found = randf() < gem_chance
	
	# XP
	var xp_gain: int = _get_xp_for_node(node_type)
	gain_xp(xp_gain)
	
	var result := {
		"success": true,
		"yield": final_yield,
		"node_type": node_type,
		"gem_found": gem_found,
		"xp_gained": xp_gain,
	}
	
	action_completed.emit(result)
	EventBus.gathering_completed.emit(node_type, final_yield)
	return result


func _get_xp_for_node(node_type: Enums.GatheringNodeType) -> int:
	match node_type:
		Enums.GatheringNodeType.STONE: return 10
		Enums.GatheringNodeType.ORE: return 20
		Enums.GatheringNodeType.CRYSTAL: return 35
		Enums.GatheringNodeType.EMBER_COAL: return 30
	return 10


## Channel idő (tool tier-rel módosított)
func get_channel_time(node_type: Enums.GatheringNodeType, tool_tier: Enums.ToolTier) -> float:
	var node_data: Dictionary = Constants.GATHERING_NODE_DATA.get(node_type, {})
	var tool_data: Dictionary = Constants.TOOL_TIER_MULTIPLIERS.get(tool_tier, {})
	var base_time: float = node_data.get("channel_time", 2.0)
	var speed_mult: float = tool_data.get("speed", 1.0)
	return base_time / speed_mult

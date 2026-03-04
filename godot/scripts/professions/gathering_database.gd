## GatheringDatabase - Gathering node definíciók (Plan 16, szekció 13)
## Minden bányászat/herbalizmus/favágás/horgászat node részletes adattal
class_name GatheringDatabase
extends RefCounted

static var _nodes: Dictionary = {}
static var _initialized: bool = false


static func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	_register_mining_nodes()
	_register_herbalism_nodes()
	_register_woodcutting_nodes()
	_register_fishing_nodes()


static func get_node_data(node_id: String) -> Dictionary:
	initialize()
	return _nodes.get(node_id, {})


static func get_nodes_for_biome(biome: int) -> Array[Dictionary]:
	initialize()
	var result: Array[Dictionary] = []
	for key in _nodes:
		var nd: Dictionary = _nodes[key]
		var biomes: Array = nd.get("biomes", [])
		if biomes.is_empty() or biome in biomes:
			result.append(nd)
	return result


static func get_nodes_for_profession(profession: int) -> Array[Dictionary]:
	initialize()
	var result: Array[Dictionary] = []
	for key in _nodes:
		var nd: Dictionary = _nodes[key]
		if nd.get("profession", -1) == profession:
			result.append(nd)
	return result


static func get_all_nodes() -> Array[Dictionary]:
	initialize()
	var result: Array[Dictionary] = []
	for key in _nodes:
		result.append(_nodes[key])
	return result


static func _reg(id: String, data: Dictionary) -> void:
	data["id"] = id
	_nodes[id] = data


# =================== MINING NODES (Plan 13 – Mining profession) ===================

static func _register_mining_nodes() -> void:
	_reg("mine_copper_ore", {
		"name": "Copper Ore Vein",
		"node_type": Enums.GatheringNodeType.ORE,
		"profession": Enums.ProfessionType.MINING,
		"required_level": 1,
		"result_item": "mat_copper_ore",
		"yield_min": 2, "yield_max": 5,
		"respawn_time": 60.0,
		"channel_time": 2.5,
		"biomes": [Enums.BiomeType.ASHLANDS, Enums.BiomeType.STARTING_MEADOW],
		"xp_reward": 5,
	})
	_reg("mine_iron_ore", {
		"name": "Iron Ore Vein",
		"node_type": Enums.GatheringNodeType.ORE,
		"profession": Enums.ProfessionType.MINING,
		"required_level": 3,
		"result_item": "mat_iron_ore",
		"yield_min": 2, "yield_max": 4,
		"respawn_time": 90.0,
		"channel_time": 3.0,
		"biomes": [Enums.BiomeType.CURSED_FOREST, Enums.BiomeType.RUINS],
		"xp_reward": 8,
	})
	_reg("mine_silver_ore", {
		"name": "Silver Ore Vein",
		"node_type": Enums.GatheringNodeType.ORE,
		"profession": Enums.ProfessionType.MINING,
		"required_level": 5,
		"result_item": "mat_silver_ore",
		"yield_min": 1, "yield_max": 3,
		"respawn_time": 120.0,
		"channel_time": 3.0,
		"biomes": [Enums.BiomeType.MOUNTAINS],
		"xp_reward": 12,
	})
	_reg("mine_gold_ore", {
		"name": "Gold Ore Vein",
		"node_type": Enums.GatheringNodeType.ORE,
		"profession": Enums.ProfessionType.MINING,
		"required_level": 7,
		"result_item": "mat_gold_ore",
		"yield_min": 1, "yield_max": 3,
		"respawn_time": 180.0,
		"channel_time": 3.5,
		"biomes": [Enums.BiomeType.FROZEN_WASTES, Enums.BiomeType.MOUNTAINS],
		"xp_reward": 18,
	})
	_reg("mine_mythril_ore", {
		"name": "Mythril Ore Vein",
		"node_type": Enums.GatheringNodeType.ORE,
		"profession": Enums.ProfessionType.MINING,
		"required_level": 9,
		"result_item": "mat_mythril_ore",
		"yield_min": 1, "yield_max": 2,
		"respawn_time": 300.0,
		"channel_time": 4.0,
		"biomes": [Enums.BiomeType.DARK_SWAMP, Enums.BiomeType.RUINS],
		"xp_reward": 25,
	})
	_reg("mine_demon_steel", {
		"name": "Demon Steel Deposit",
		"node_type": Enums.GatheringNodeType.ORE,
		"profession": Enums.ProfessionType.MINING,
		"required_level": 12,
		"result_item": "mat_demon_steel",
		"yield_min": 1, "yield_max": 2,
		"respawn_time": 450.0,
		"channel_time": 4.5,
		"biomes": [Enums.BiomeType.ASHLANDS],
		"xp_reward": 35,
	})
	_reg("mine_void_metal", {
		"name": "Void Metal Deposit",
		"node_type": Enums.GatheringNodeType.ORE,
		"profession": Enums.ProfessionType.MINING,
		"required_level": 15,
		"result_item": "mat_void_metal",
		"yield_min": 1, "yield_max": 1,
		"respawn_time": 600.0,
		"channel_time": 5.0,
		"biomes": [Enums.BiomeType.PLAGUE_LANDS],
		"xp_reward": 50,
	})


# =================== HERBALISM NODES (Plan 13) ===================

static func _register_herbalism_nodes() -> void:
	_reg("herb_red", {
		"name": "Red Herb Bush",
		"node_type": Enums.GatheringNodeType.HERB,
		"profession": Enums.ProfessionType.HERBALISM,
		"required_level": 1,
		"result_item": "mat_red_herb",
		"yield_min": 1, "yield_max": 4,
		"respawn_time": 45.0,
		"channel_time": 1.5,
		"biomes": [],  # All biomes
		"xp_reward": 4,
	})
	_reg("herb_green", {
		"name": "Green Herb Patch",
		"node_type": Enums.GatheringNodeType.HERB,
		"profession": Enums.ProfessionType.HERBALISM,
		"required_level": 2,
		"result_item": "mat_green_herb",
		"yield_min": 1, "yield_max": 4,
		"respawn_time": 45.0,
		"channel_time": 1.5,
		"biomes": [Enums.BiomeType.CURSED_FOREST, Enums.BiomeType.DARK_SWAMP, Enums.BiomeType.STARTING_MEADOW],
		"xp_reward": 5,
	})
	_reg("herb_blue_mushroom", {
		"name": "Blue Mushroom Cluster",
		"node_type": Enums.GatheringNodeType.HERB,
		"profession": Enums.ProfessionType.HERBALISM,
		"required_level": 3,
		"result_item": "mat_blue_mushroom",
		"yield_min": 1, "yield_max": 3,
		"respawn_time": 60.0,
		"channel_time": 1.5,
		"biomes": [Enums.BiomeType.DARK_SWAMP, Enums.BiomeType.MOUNTAINS],
		"xp_reward": 7,
	})
	_reg("herb_fire_flower", {
		"name": "Fire Flower",
		"node_type": Enums.GatheringNodeType.HERB,
		"profession": Enums.ProfessionType.HERBALISM,
		"required_level": 5,
		"result_item": "mat_fire_flower",
		"yield_min": 1, "yield_max": 2,
		"respawn_time": 90.0,
		"channel_time": 2.0,
		"biomes": [Enums.BiomeType.ASHLANDS],
		"xp_reward": 12,
	})
	_reg("herb_ice_crystal", {
		"name": "Ice Crystal Formation",
		"node_type": Enums.GatheringNodeType.CRYSTAL,
		"profession": Enums.ProfessionType.HERBALISM,
		"required_level": 7,
		"result_item": "mat_ice_crystal",
		"yield_min": 1, "yield_max": 2,
		"respawn_time": 120.0,
		"channel_time": 2.5,
		"biomes": [Enums.BiomeType.FROZEN_WASTES],
		"xp_reward": 18,
	})
	_reg("herb_shadow_root", {
		"name": "Shadow Root",
		"node_type": Enums.GatheringNodeType.DARK_ROOT,
		"profession": Enums.ProfessionType.HERBALISM,
		"required_level": 9,
		"result_item": "mat_cursed_wood",
		"yield_min": 1, "yield_max": 2,
		"respawn_time": 180.0,
		"channel_time": 2.5,
		"biomes": [Enums.BiomeType.DARK_SWAMP],
		"xp_reward": 25,
	})
	_reg("herb_void_bloom", {
		"name": "Void Bloom",
		"node_type": Enums.GatheringNodeType.HERB,
		"profession": Enums.ProfessionType.HERBALISM,
		"required_level": 12,
		"result_item": "mat_magic_essence",
		"yield_min": 1, "yield_max": 1,
		"respawn_time": 300.0,
		"channel_time": 3.0,
		"biomes": [Enums.BiomeType.PLAGUE_LANDS],
		"xp_reward": 40,
	})


# =================== WOODCUTTING NODES (Plan 13) ===================

static func _register_woodcutting_nodes() -> void:
	_reg("wood_basic", {
		"name": "Tree",
		"node_type": Enums.GatheringNodeType.WOOD,
		"profession": Enums.ProfessionType.WOODCUTTING,
		"required_level": 1,
		"result_item": "mat_wood",
		"yield_min": 3, "yield_max": 8,
		"respawn_time": 60.0,
		"channel_time": 2.0,
		"biomes": [Enums.BiomeType.CURSED_FOREST, Enums.BiomeType.STARTING_MEADOW],
		"xp_reward": 5,
	})
	_reg("wood_hard", {
		"name": "Hardwood Tree",
		"node_type": Enums.GatheringNodeType.WOOD,
		"profession": Enums.ProfessionType.WOODCUTTING,
		"required_level": 4,
		"result_item": "mat_hard_wood",
		"yield_min": 2, "yield_max": 5,
		"respawn_time": 90.0,
		"channel_time": 2.5,
		"biomes": [Enums.BiomeType.CURSED_FOREST, Enums.BiomeType.DARK_SWAMP],
		"xp_reward": 10,
	})
	_reg("wood_enchanted", {
		"name": "Enchanted Tree",
		"node_type": Enums.GatheringNodeType.WOOD,
		"profession": Enums.ProfessionType.WOODCUTTING,
		"required_level": 7,
		"result_item": "mat_enchanted_wood",
		"yield_min": 1, "yield_max": 3,
		"respawn_time": 150.0,
		"channel_time": 3.0,
		"biomes": [Enums.BiomeType.CURSED_FOREST],
		"xp_reward": 18,
	})
	_reg("wood_shadow", {
		"name": "Shadow Tree",
		"node_type": Enums.GatheringNodeType.WOOD,
		"profession": Enums.ProfessionType.WOODCUTTING,
		"required_level": 10,
		"result_item": "mat_shadow_wood",
		"yield_min": 1, "yield_max": 2,
		"respawn_time": 240.0,
		"channel_time": 3.5,
		"biomes": [Enums.BiomeType.DARK_SWAMP],
		"xp_reward": 28,
	})
	_reg("wood_nexus_crystal", {
		"name": "Nexus Crystal Formation",
		"node_type": Enums.GatheringNodeType.CRYSTAL,
		"profession": Enums.ProfessionType.WOODCUTTING,
		"required_level": 13,
		"result_item": "mat_nexus_crystal",
		"yield_min": 1, "yield_max": 1,
		"respawn_time": 400.0,
		"channel_time": 4.0,
		"biomes": [Enums.BiomeType.MOUNTAINS, Enums.BiomeType.PLAGUE_LANDS],
		"xp_reward": 45,
	})


# =================== FISHING NODES (Plan 13) ===================

static func _register_fishing_nodes() -> void:
	_reg("fish_common", {
		"name": "Fishing Spot",
		"node_type": Enums.GatheringNodeType.HERB,  # reuse type; ideally FISHING
		"profession": Enums.ProfessionType.SCAVENGING,
		"required_level": 1,
		"result_item": "mat_monster_bone",  # placeholder for common fish
		"yield_min": 1, "yield_max": 3,
		"respawn_time": 30.0,
		"channel_time": 3.0,
		"biomes": [],  # Any water
		"xp_reward": 4,
	})
	_reg("fish_river", {
		"name": "River Fishing Spot",
		"node_type": Enums.GatheringNodeType.HERB,
		"profession": Enums.ProfessionType.SCAVENGING,
		"required_level": 3,
		"result_item": "mat_monster_bone",
		"yield_min": 1, "yield_max": 2,
		"respawn_time": 45.0,
		"channel_time": 3.5,
		"biomes": [Enums.BiomeType.STARTING_MEADOW, Enums.BiomeType.CURSED_FOREST],
		"xp_reward": 7,
	})
	_reg("fish_marsh", {
		"name": "Marsh Fishing Spot",
		"node_type": Enums.GatheringNodeType.HERB,
		"profession": Enums.ProfessionType.SCAVENGING,
		"required_level": 5,
		"result_item": "mat_swamp_moss",
		"yield_min": 1, "yield_max": 2,
		"respawn_time": 60.0,
		"channel_time": 4.0,
		"biomes": [Enums.BiomeType.DARK_SWAMP],
		"xp_reward": 12,
	})
	_reg("fish_lava", {
		"name": "Lava Fishing Spot",
		"node_type": Enums.GatheringNodeType.EMBER_COAL,
		"profession": Enums.ProfessionType.SCAVENGING,
		"required_level": 8,
		"result_item": "mat_ember_core",
		"yield_min": 1, "yield_max": 1,
		"respawn_time": 120.0,
		"channel_time": 5.0,
		"biomes": [Enums.BiomeType.ASHLANDS],
		"xp_reward": 22,
	})
	_reg("fish_void", {
		"name": "Void Pool Fishing Spot",
		"node_type": Enums.GatheringNodeType.CRYSTAL,
		"profession": Enums.ProfessionType.SCAVENGING,
		"required_level": 12,
		"result_item": "mat_void_crystal",
		"yield_min": 1, "yield_max": 1,
		"respawn_time": 300.0,
		"channel_time": 6.0,
		"biomes": [Enums.BiomeType.PLAGUE_LANDS],
		"xp_reward": 40,
	})

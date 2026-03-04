## QuestData - Quest adatstruktúra Resource
## Egyetlen quest teljes definíciója
class_name QuestData
extends Resource

enum QuestType {
	MAIN_STORY,
	SIDE_QUEST,
	BOUNTY,
	DUNGEON_QUEST,
	GATHERING_QUEST,
	DAILY,
	WEEKLY,
	EXPLORATION
}

@export var quest_id: String = ""                 ## Egyedi ID: "main_01_awakening"
@export var quest_name: String = ""               ## Megjelenített név
@export var description: String = ""              ## Rövid leírás
@export var quest_type: QuestType = QuestType.SIDE_QUEST
@export var biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW
@export var recommended_level: int = 1            ## Ajánlott szint
@export var prerequisites: Array[String] = []     ## Korábbi quest ID-k
@export var objectives: Array[Resource] = []      ## QuestObjective-ek
@export var rewards: Resource = null               ## QuestRewards
@export var giver_npc_id: String = ""             ## Ki adja a quest-et
@export var turn_in_npc_id: String = ""           ## Kinél adható le
@export var dialogue_start: String = ""           ## Induló párbeszéd ID
@export var dialogue_complete: String = ""        ## Befejezési párbeszéd ID
@export var is_repeatable: bool = false           ## Ismételhető-e
@export var time_limit: float = 0.0               ## 0 = nincs időlimit (másodperc)
@export var chain_next_quest: String = ""         ## Következő quest a chain-ben


## Quest konvertálása Dictionary-vé (mentéshez/JSON-hez)
func to_dict() -> Dictionary:
	var obj_list: Array[Dictionary] = []
	for obj in objectives:
		if obj is QuestObjective:
			obj_list.append(obj.to_dict())
	
	var reward_dict: Dictionary = {}
	if rewards is QuestRewards:
		reward_dict = rewards.to_dict()
	
	return {
		"quest_id": quest_id,
		"quest_name": quest_name,
		"description": description,
		"quest_type": quest_type,
		"biome": biome,
		"recommended_level": recommended_level,
		"prerequisites": prerequisites,
		"objectives": obj_list,
		"rewards": reward_dict,
		"giver_npc_id": giver_npc_id,
		"turn_in_npc_id": turn_in_npc_id,
		"dialogue_start": dialogue_start,
		"dialogue_complete": dialogue_complete,
		"is_repeatable": is_repeatable,
		"time_limit": time_limit,
		"chain_next_quest": chain_next_quest,
	}


## Quest létrehozása Dictionary-ből
static func from_dict(data: Dictionary) -> QuestData:
	var quest := QuestData.new()
	quest.quest_id = data.get("quest_id", "")
	quest.quest_name = data.get("quest_name", "")
	quest.description = data.get("description", "")
	quest.quest_type = data.get("quest_type", QuestType.SIDE_QUEST) as QuestType
	quest.biome = data.get("biome", Enums.BiomeType.STARTING_MEADOW) as Enums.BiomeType
	quest.recommended_level = data.get("recommended_level", 1)
	quest.prerequisites = data.get("prerequisites", [])
	quest.giver_npc_id = data.get("giver_npc_id", "")
	quest.turn_in_npc_id = data.get("turn_in_npc_id", "")
	quest.dialogue_start = data.get("dialogue_start", "")
	quest.dialogue_complete = data.get("dialogue_complete", "")
	quest.is_repeatable = data.get("is_repeatable", false)
	quest.time_limit = data.get("time_limit", 0.0)
	quest.chain_next_quest = data.get("chain_next_quest", "")
	
	# Objectives
	var obj_array: Array = data.get("objectives", [])
	for obj_data in obj_array:
		if obj_data is Dictionary:
			quest.objectives.append(QuestObjective.from_dict(obj_data))
	
	# Rewards
	var reward_data: Dictionary = data.get("rewards", {})
	if not reward_data.is_empty():
		quest.rewards = QuestRewards.from_dict(reward_data)
	else:
		quest.rewards = QuestRewards.new()
	
	return quest

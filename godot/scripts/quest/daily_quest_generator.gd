extends Node
class_name DailyQuestGenerator

## Generates and rotates daily and weekly quests from template pools

const DAILY_QUEST_COUNT: int = 3
const DAILY_RESET_HOUR: int = 6  ## 6 AM UTC
const WEEKLY_RESET_DAY: int = 1  ## Monday
const DAILY_DURATION: int = 86400  ## 24 hours in seconds
const WEEKLY_DURATION: int = 604800  ## 7 days in seconds

var daily_templates: Array[Dictionary] = []
var weekly_templates: Array[Dictionary] = []

var current_daily_ids: Array[String] = []
var current_weekly_id: String = ""
var daily_reset_time: int = 0
var weekly_reset_time: int = 0

var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	_load_templates()
	_check_reset()


func _load_templates() -> void:
	var daily_file := FileAccess.open("res://data/quests/daily_templates.json", FileAccess.READ)
	if daily_file:
		var daily_json = JSON.parse_string(daily_file.get_as_text())
		if daily_json is Array:
			daily_templates = daily_json
		daily_file.close()
	
	var weekly_file := FileAccess.open("res://data/quests/weekly_templates.json", FileAccess.READ)
	if weekly_file:
		var weekly_json = JSON.parse_string(weekly_file.get_as_text())
		if weekly_json is Array:
			weekly_templates = weekly_json
		weekly_file.close()
	
	if daily_templates.is_empty():
		push_warning("DailyQuestGenerator: No daily templates loaded")
	if weekly_templates.is_empty():
		push_warning("DailyQuestGenerator: No weekly templates loaded")


func _check_reset() -> void:
	var now := int(Time.get_unix_time_from_system())
	
	if now >= daily_reset_time:
		generate_daily_quests()
	
	if now >= weekly_reset_time:
		generate_weekly_quest()


func generate_daily_quests() -> void:
	if daily_templates.is_empty():
		return
	
	## Remove old daily quests from quest manager
	for quest_id in current_daily_ids:
		if QuestManager.quest_states.has(quest_id):
			var state: int = QuestManager.quest_states[quest_id]
			if state == QuestManager.QuestState.ACTIVE:
				QuestManager.abandon_quest(quest_id)
			QuestManager.quest_states.erase(quest_id)
			QuestManager.quest_database.erase(quest_id)
	
	current_daily_ids.clear()
	
	## Seed RNG with day number for consistent daily rotation per day
	var now := int(Time.get_unix_time_from_system())
	var day_number: int = now / DAILY_DURATION
	_rng.seed = day_number * 31337
	
	## Pick random templates without repeats
	var available_indices: Array[int] = []
	for i in range(daily_templates.size()):
		available_indices.append(i)
	
	var count: int = mini(DAILY_QUEST_COUNT, available_indices.size())
	
	for i in range(count):
		var roll: int = _rng.randi_range(0, available_indices.size() - 1)
		var template_idx: int = available_indices[roll]
		available_indices.remove_at(roll)
		
		var template: Dictionary = daily_templates[template_idx]
		var quest_data := _create_quest_from_template(template, "daily", i)
		
		if quest_data:
			QuestManager.quest_database[quest_data.quest_id] = quest_data
			QuestManager.quest_states[quest_data.quest_id] = QuestManager.QuestState.AVAILABLE
			current_daily_ids.append(quest_data.quest_id)
	
	## Calculate next reset time
	var time_dict := Time.get_datetime_dict_from_system(true)
	var current_hour: int = time_dict.get("hour", 0)
	
	if current_hour >= DAILY_RESET_HOUR:
		daily_reset_time = now + (24 - current_hour + DAILY_RESET_HOUR) * 3600
	else:
		daily_reset_time = now + (DAILY_RESET_HOUR - current_hour) * 3600
	
	## Subtract current minutes/seconds for cleaner reset
	var current_minute: int = time_dict.get("minute", 0)
	var current_second: int = time_dict.get("second", 0)
	daily_reset_time -= current_minute * 60 + current_second
	
	EventBus.quest_available.emit("daily_refresh")


func generate_weekly_quest() -> void:
	if weekly_templates.is_empty():
		return
	
	## Remove old weekly quest
	if current_weekly_id != "":
		if QuestManager.quest_states.has(current_weekly_id):
			var state: int = QuestManager.quest_states[current_weekly_id]
			if state == QuestManager.QuestState.ACTIVE:
				QuestManager.abandon_quest(current_weekly_id)
			QuestManager.quest_states.erase(current_weekly_id)
			QuestManager.quest_database.erase(current_weekly_id)
	
	## Seed RNG with week number
	var now := int(Time.get_unix_time_from_system())
	var week_number: int = now / WEEKLY_DURATION
	_rng.seed = week_number * 77773
	
	var template_idx: int = _rng.randi_range(0, weekly_templates.size() - 1)
	var template: Dictionary = weekly_templates[template_idx]
	var quest_data := _create_quest_from_template(template, "weekly", 0)
	
	if quest_data:
		QuestManager.quest_database[quest_data.quest_id] = quest_data
		QuestManager.quest_states[quest_data.quest_id] = QuestManager.QuestState.AVAILABLE
		current_weekly_id = quest_data.quest_id
	
	## Calculate next weekly reset
	var time_dict := Time.get_datetime_dict_from_system(true)
	var current_weekday: int = time_dict.get("weekday", 0)
	var days_until_reset: int = (WEEKLY_RESET_DAY - current_weekday + 7) % 7
	if days_until_reset == 0:
		var current_hour: int = time_dict.get("hour", 0)
		if current_hour >= DAILY_RESET_HOUR:
			days_until_reset = 7
	
	weekly_reset_time = now + days_until_reset * DAILY_DURATION
	
	EventBus.quest_available.emit("weekly_refresh")


func _create_quest_from_template(template: Dictionary, prefix: String, index: int) -> QuestData:
	var quest := QuestData.new()
	var template_id: String = template.get("template_id", "unknown")
	
	## Create unique ID with date component
	var day_stamp: int = int(Time.get_unix_time_from_system()) / DAILY_DURATION
	quest.quest_id = "%s_%s_%d" % [prefix, template_id, day_stamp]
	quest.quest_name = template.get("name", "Unknown Quest")
	quest.description = template.get("description", "")
	quest.recommended_level = template.get("recommended_level", 1)
	quest.is_repeatable = true
	
	## Set quest type
	if prefix == "daily":
		quest.quest_type = QuestData.QuestType.DAILY
		quest.time_limit = DAILY_DURATION
	else:
		quest.quest_type = QuestData.QuestType.WEEKLY
		quest.time_limit = WEEKLY_DURATION
	
	## Scale objectives based on player level (if available)
	var player_level: int = 1
	if has_node("/root/GameManager"):
		var gm := get_node("/root/GameManager")
		if gm.has_method("get_player_level"):
			player_level = gm.get_player_level()
	
	## Create objectives from template
	var objectives_data: Array = template.get("objectives", [])
	for obj_dict in objectives_data:
		var obj := QuestObjective.new()
		obj.objective_id = obj_dict.get("objective_id", "obj")
		obj.description = obj_dict.get("description", "")
		
		var type_str: String = obj_dict.get("type", "KILL_ENEMY")
		obj.type = _parse_objective_type(type_str)
		
		## Scale target count slightly with level
		var base_count: int = obj_dict.get("target_count", 1)
		var level_scale: float = 1.0 + (player_level - 1) * 0.05
		obj.target_count = int(base_count * level_scale)
		obj.target_count = maxi(obj.target_count, base_count)
		
		obj.target_id = obj_dict.get("target_id", "")
		obj.current_count = 0
		quest.objectives.append(obj)
	
	## Create rewards from template, scaled by level
	var rewards_dict: Dictionary = template.get("rewards", {})
	var rewards := QuestRewards.new()
	
	var base_xp: int = rewards_dict.get("experience", 0)
	rewards.experience = int(base_xp * (1.0 + (player_level - 1) * 0.1))
	
	var base_gold: int = rewards_dict.get("gold", 0)
	rewards.gold = int(base_gold * (1.0 + (player_level - 1) * 0.08))
	
	rewards.dark_essence = rewards_dict.get("dark_essence", 0)
	rewards.relic_fragments = rewards_dict.get("relic_fragments", 0)
	
	var items_data: Array = rewards_dict.get("items", [])
	for item_dict in items_data:
		rewards.items.append(item_dict)
	
	quest.rewards = rewards
	
	return quest


func _parse_objective_type(type_str: String) -> QuestObjective.ObjectiveType:
	match type_str:
		"KILL_ENEMY": return QuestObjective.ObjectiveType.KILL_ENEMY
		"KILL_BOSS": return QuestObjective.ObjectiveType.KILL_BOSS
		"COLLECT_ITEM": return QuestObjective.ObjectiveType.COLLECT_ITEM
		"GATHER_RESOURCE": return QuestObjective.ObjectiveType.GATHER_RESOURCE
		"CLEAR_DUNGEON": return QuestObjective.ObjectiveType.CLEAR_DUNGEON
		"CLEAR_ROOM": return QuestObjective.ObjectiveType.CLEAR_ROOM
		"CRAFT_ITEM": return QuestObjective.ObjectiveType.CRAFT_ITEM
		"EXPLORE_AREA": return QuestObjective.ObjectiveType.EXPLORE_AREA
		"SURVIVE_WAVES": return QuestObjective.ObjectiveType.SURVIVE_WAVES
		"USE_SKILL": return QuestObjective.ObjectiveType.USE_SKILL
		_: return QuestObjective.ObjectiveType.KILL_ENEMY


func get_daily_quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	for quest_id in current_daily_ids:
		if QuestManager.quest_database.has(quest_id):
			result.append(QuestManager.quest_database[quest_id])
	return result


func get_weekly_quest() -> QuestData:
	if current_weekly_id != "" and QuestManager.quest_database.has(current_weekly_id):
		return QuestManager.quest_database[current_weekly_id]
	return null


func get_daily_time_remaining() -> int:
	var now := int(Time.get_unix_time_from_system())
	return maxi(0, daily_reset_time - now)


func get_weekly_time_remaining() -> int:
	var now := int(Time.get_unix_time_from_system())
	return maxi(0, weekly_reset_time - now)


func get_formatted_time_remaining(seconds: int) -> String:
	if seconds <= 0:
		return "Resetting..."
	
	var hours: int = seconds / 3600
	var minutes: int = (seconds % 3600) / 60
	
	if hours > 24:
		var days: int = hours / 24
		hours = hours % 24
		return "%dd %dh" % [days, hours]
	
	return "%dh %dm" % [hours, minutes]


func serialize() -> Dictionary:
	return {
		"current_daily_ids": current_daily_ids.duplicate(),
		"current_weekly_id": current_weekly_id,
		"daily_reset_time": daily_reset_time,
		"weekly_reset_time": weekly_reset_time
	}


func deserialize(data: Dictionary) -> void:
	current_daily_ids.clear()
	var ids: Array = data.get("current_daily_ids", [])
	for id in ids:
		current_daily_ids.append(str(id))
	
	current_weekly_id = data.get("current_weekly_id", "")
	daily_reset_time = data.get("daily_reset_time", 0)
	weekly_reset_time = data.get("weekly_reset_time", 0)
	
	_check_reset()

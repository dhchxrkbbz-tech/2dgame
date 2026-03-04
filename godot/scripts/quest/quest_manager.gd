## QuestManager - Quest rendszer központi kezelő (Autoload singleton)
## Quest életciklus, objective tracking, EventBus integráció
extends Node

# === Állapotok ===
enum QuestState {
	AVAILABLE,       ## Felvehető (prerequisite-ok teljesültek)
	NOT_AVAILABLE,   ## Nem felvehető (prerequisite-ok nem teljesültek)
	ACTIVE,          ## Aktív – folyamatban
	COMPLETE,        ## Befejezett – leadható
	TURNED_IN,       ## Leadva – jutalom megkapva
	FAILED,          ## Megbukott (időlimit lejárt)
}

# === Tárolt adatok ===
var quest_database: Dictionary = {}           ## quest_id → QuestData
var quest_states: Dictionary = {}             ## quest_id → QuestState
var quest_progress: Dictionary = {}           ## quest_id → {objective_idx: current_count}
var completed_quests: Array[String] = []      ## Befejezett quest ID-k
var active_quest_ids: Array[String] = []      ## Aktív quest ID-k
var tracked_quest_id: String = ""             ## HUD-on követett quest
var daily_quests: Array[String] = []          ## Mai daily quest-ek
var weekly_quest: String = ""                 ## Heti quest
var daily_reset_time: float = 0.0             ## Utolsó daily reset unix timestamp
var weekly_reset_time: float = 0.0            ## Utolsó weekly reset unix timestamp

# === Limitek ===
const MAX_ACTIVE_QUESTS: int = 15

# === Időzítők ===
var _quest_timers: Dictionary = {}            ## quest_id → remaining_time


func _ready() -> void:
	_connect_eventbus_signals()
	_load_quest_database()
	print("QuestManager: Initialized with %d quests in database" % quest_database.size())


func _process(delta: float) -> void:
	_update_quest_timers(delta)


# ═══════════════════════════════════════════════════════════════
#  QUEST ÉLETCIKLUS
# ═══════════════════════════════════════════════════════════════

## Quest felvétele
func accept_quest(quest_id: String) -> bool:
	if not quest_database.has(quest_id):
		push_warning("QuestManager: Unknown quest '%s'" % quest_id)
		return false
	
	if quest_id in active_quest_ids:
		push_warning("QuestManager: Quest '%s' already active" % quest_id)
		return false
	
	if active_quest_ids.size() >= MAX_ACTIVE_QUESTS:
		EventBus.show_notification.emit("Quest log is full! (Max %d)" % MAX_ACTIVE_QUESTS, Enums.NotificationType.WARNING)
		return false
	
	var quest: QuestData = quest_database[quest_id]
	
	# Prerequisite ellenőrzés
	if not _check_prerequisites(quest):
		push_warning("QuestManager: Prerequisites not met for '%s'" % quest_id)
		return false
	
	# Aktiválás
	quest_states[quest_id] = QuestState.ACTIVE
	active_quest_ids.append(quest_id)
	
	# Objective-ek resetelése (repeatable quest-ek esetén)
	for obj in quest.objectives:
		if obj is QuestObjective:
			obj.reset()
	
	# Progress cache
	quest_progress[quest_id] = {}
	for i in range(quest.objectives.size()):
		quest_progress[quest_id][i] = 0
	
	# Időlimit beállítása
	if quest.time_limit > 0.0:
		_quest_timers[quest_id] = quest.time_limit
	
	# Tracking az első quest-nél automatikusan
	if tracked_quest_id.is_empty():
		tracked_quest_id = quest_id
	
	EventBus.quest_accepted.emit(quest_id)
	EventBus.show_notification.emit("Quest accepted: %s" % quest.quest_name, Enums.NotificationType.INFO)
	print("QuestManager: Quest accepted - '%s'" % quest_id)
	return true


## Quest leadása (turn in) - jutalmak kiosztása
func turn_in_quest(quest_id: String) -> bool:
	if not _is_quest_complete(quest_id):
		return false
	
	var quest: QuestData = quest_database[quest_id]
	
	# Jutalmak kiosztása
	_grant_rewards(quest)
	
	# Állapot frissítés
	quest_states[quest_id] = QuestState.TURNED_IN
	active_quest_ids.erase(quest_id)
	
	if quest_id not in completed_quests:
		completed_quests.append(quest_id)
	
	# Timer eltávolítás
	_quest_timers.erase(quest_id)
	quest_progress.erase(quest_id)
	
	# Tracked quest frissítés
	if tracked_quest_id == quest_id:
		tracked_quest_id = active_quest_ids[0] if not active_quest_ids.is_empty() else ""
	
	EventBus.quest_turned_in.emit(quest_id)
	EventBus.show_notification.emit("Quest completed: %s" % quest.quest_name, Enums.NotificationType.INFO)
	print("QuestManager: Quest turned in - '%s'" % quest_id)
	
	# Chain quest indítása
	if not quest.chain_next_quest.is_empty():
		_make_quest_available(quest.chain_next_quest)
	
	return true


## Quest feladása
func abandon_quest(quest_id: String) -> bool:
	if quest_id not in active_quest_ids:
		return false
	
	var quest: QuestData = quest_database[quest_id]
	
	# Main story quest-ek nem adhatók fel
	if quest.quest_type == QuestData.QuestType.MAIN_STORY:
		EventBus.show_notification.emit("Cannot abandon main story quests!", Enums.NotificationType.WARNING)
		return false
	
	quest_states[quest_id] = QuestState.AVAILABLE
	active_quest_ids.erase(quest_id)
	quest_progress.erase(quest_id)
	_quest_timers.erase(quest_id)
	
	# Objective-ek resetelése
	for obj in quest.objectives:
		if obj is QuestObjective:
			obj.reset()
	
	if tracked_quest_id == quest_id:
		tracked_quest_id = active_quest_ids[0] if not active_quest_ids.is_empty() else ""
	
	EventBus.quest_abandoned.emit(quest_id)
	print("QuestManager: Quest abandoned - '%s'" % quest_id)
	return true


## Quest tracking beállítása
func set_tracked_quest(quest_id: String) -> void:
	if quest_id in active_quest_ids or quest_id.is_empty():
		tracked_quest_id = quest_id
		EventBus.quest_tracking_changed.emit(quest_id)


# ═══════════════════════════════════════════════════════════════
#  OBJECTIVE TRACKING (EventBus signal handler-ek)
# ═══════════════════════════════════════════════════════════════

func _connect_eventbus_signals() -> void:
	EventBus.entity_killed.connect(_on_entity_killed)
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.gathering_completed.connect(_on_gathering_completed)
	EventBus.dungeon_room_entered.connect(_on_room_entered)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.crafting_completed.connect(_on_crafting_completed)
	EventBus.skill_used.connect(_on_skill_used)
	EventBus.room_cleared.connect(_on_room_cleared)
	EventBus.biome_entered.connect(_on_biome_entered)
	EventBus.dungeon_secret_room_found.connect(_on_secret_room_found)
	EventBus.dungeon_wave_completed.connect(_on_wave_completed)


func _on_entity_killed(killer, victim) -> void:
	if victim == null:
		return
	var enemy_id: String = ""
	if victim.has_method("get_enemy_id"):
		enemy_id = victim.get_enemy_id()
	elif victim.has("enemy_id"):
		enemy_id = victim.enemy_id
	
	_update_objectives(
		QuestObjective.ObjectiveType.KILL_ENEMY,
		enemy_id
	)


func _on_boss_defeated(boss_id: String) -> void:
	_update_objectives(QuestObjective.ObjectiveType.KILL_BOSS, boss_id)


func _on_item_picked_up(item_instance) -> void:
	var item_id: String = ""
	if item_instance is Dictionary:
		item_id = item_instance.get("id", "")
	elif item_instance.has_method("get_item_id"):
		item_id = item_instance.get_item_id()
	elif item_instance.has("item_id"):
		item_id = item_instance.item_id
	
	_update_objectives(QuestObjective.ObjectiveType.COLLECT_ITEM, item_id)


func _on_gathering_completed(node_type: Enums.GatheringNodeType, _yield_amount: int) -> void:
	_update_objectives(
		QuestObjective.ObjectiveType.GATHER_RESOURCE,
		Enums.GatheringNodeType.keys()[node_type].to_lower()
	)


func _on_room_entered(room_index: int, room_type: int) -> void:
	_update_objectives(
		QuestObjective.ObjectiveType.REACH_LOCATION,
		"room_%d" % room_index
	)


func _on_room_cleared(room_index: int) -> void:
	_update_objectives(QuestObjective.ObjectiveType.CLEAR_ROOM, "room_%d" % room_index)
	# Dungeon clear check - ha minden room cleared
	_update_objectives(QuestObjective.ObjectiveType.CLEAR_DUNGEON, "any")


func _on_crafting_completed(recipe_id: String, success: bool) -> void:
	if success:
		_update_objectives(QuestObjective.ObjectiveType.CRAFT_ITEM, recipe_id)


func _on_skill_used(player, skill_id: String) -> void:
	_update_objectives(QuestObjective.ObjectiveType.USE_SKILL, skill_id)


func _on_biome_entered(_player, biome: Enums.BiomeType) -> void:
	var biome_name := Enums.BiomeType.keys()[biome].to_lower()
	_update_objectives(QuestObjective.ObjectiveType.EXPLORE_AREA, biome_name)


func _on_secret_room_found(_room_index: int) -> void:
	_update_objectives(QuestObjective.ObjectiveType.EXPLORE_AREA, "secret_room")


func _on_wave_completed(_room_index: int, wave_number: int) -> void:
	_update_objectives(QuestObjective.ObjectiveType.SURVIVE_WAVES, "wave_%d" % wave_number)


## Objektív frissítés - végigmegy az aktív quest-eken
func _update_objectives(obj_type: QuestObjective.ObjectiveType, target_id: String) -> void:
	for quest_id in active_quest_ids:
		if quest_states.get(quest_id) != QuestState.ACTIVE:
			continue
		
		var quest: QuestData = quest_database[quest_id]
		var quest_changed := false
		
		for i in range(quest.objectives.size()):
			var obj: QuestObjective = quest.objectives[i] as QuestObjective
			if obj == null:
				continue
			if obj.is_completed():
				continue
			if obj.type != obj_type:
				continue
			
			# Target ID egyezés (üres target_id = bármi jó)
			if not obj.target_id.is_empty() and obj.target_id != target_id and target_id != "any":
				continue
			
			if obj.update_progress(1):
				quest_changed = true
				quest_progress[quest_id][i] = obj.current_count
				EventBus.quest_progress_updated.emit(quest_id, i, obj.current_count, obj.target_count)
		
		if quest_changed:
			# Ellenőrizd, hogy minden (nem opcionális) objective kész-e
			if _are_all_required_objectives_complete(quest):
				quest_states[quest_id] = QuestState.COMPLETE
				EventBus.quest_completed.emit(quest_id)
				EventBus.show_notification.emit(
					"Quest ready to turn in: %s" % quest.quest_name,
					Enums.NotificationType.INFO
				)


## Ellenőrzi, hogy a quest összes kötelező objective-je kész-e
func _are_all_required_objectives_complete(quest: QuestData) -> bool:
	for obj in quest.objectives:
		if obj is QuestObjective and not obj.is_optional and not obj.is_completed():
			return false
	return true


## Publikus quest completion ellenőrzés (QuestSync-ból hívható)
func _check_quest_completion(quest_id: String) -> void:
	if not quest_database.has(quest_id):
		return
	if quest_states.get(quest_id) != QuestState.ACTIVE:
		return
	
	var quest: QuestData = quest_database[quest_id]
	if _are_all_required_objectives_complete(quest):
		quest_states[quest_id] = QuestState.COMPLETE
		EventBus.quest_completed.emit(quest_id)
		EventBus.show_notification.emit(
			"Quest ready to turn in: %s" % quest.quest_name,
			Enums.NotificationType.INFO
		)


# ═══════════════════════════════════════════════════════════════
#  QUEST ELÉRHETŐSÉG
# ═══════════════════════════════════════════════════════════════

## Prerequisite-ok ellenőrzése
func _check_prerequisites(quest: QuestData) -> bool:
	for prereq_id in quest.prerequisites:
		if prereq_id not in completed_quests:
			return false
	return true


## Quest elérhetővé tétele
func _make_quest_available(quest_id: String) -> void:
	if not quest_database.has(quest_id):
		return
	
	var quest: QuestData = quest_database[quest_id]
	if _check_prerequisites(quest):
		quest_states[quest_id] = QuestState.AVAILABLE
		EventBus.quest_available.emit(quest_id)


## NPC-hez tartozó elérhető quest-ek
func get_available_quests_for_npc(npc_id: String) -> Array[QuestData]:
	var result: Array[QuestData] = []
	for quest_id in quest_database:
		var quest: QuestData = quest_database[quest_id]
		if quest.giver_npc_id == npc_id:
			var state: QuestState = quest_states.get(quest_id, QuestState.NOT_AVAILABLE)
			if state == QuestState.AVAILABLE:
				result.append(quest)
	return result


## NPC-nél leadható befejezett quest-ek
func get_completable_quests_for_npc(npc_id: String) -> Array[QuestData]:
	var result: Array[QuestData] = []
	for quest_id in active_quest_ids:
		var quest: QuestData = quest_database[quest_id]
		if quest.turn_in_npc_id == npc_id and quest_states.get(quest_id) == QuestState.COMPLETE:
			result.append(quest)
	return result


## NPC fej fölötti ikon típusa
func get_npc_quest_indicator(npc_id: String) -> String:
	# Leadható quest → "?"
	if not get_completable_quests_for_npc(npc_id).is_empty():
		return "turn_in"  # Sárga ?
	# Elérhető quest → "!"
	if not get_available_quests_for_npc(npc_id).is_empty():
		return "available"  # Sárga !
	return ""


## Quest állapot lekérése
func get_quest_state(quest_id: String) -> QuestState:
	return quest_states.get(quest_id, QuestState.NOT_AVAILABLE)


## Aktív quest-ek lista (UI-nak)
func get_active_quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	for quest_id in active_quest_ids:
		if quest_database.has(quest_id):
			result.append(quest_database[quest_id])
	return result


## Befejezett quest-ek lista
func get_completed_quests() -> Array[QuestData]:
	var result: Array[QuestData] = []
	for quest_id in completed_quests:
		if quest_database.has(quest_id):
			result.append(quest_database[quest_id])
	return result


# ═══════════════════════════════════════════════════════════════
#  JUTALMAK
# ═══════════════════════════════════════════════════════════════

func _grant_rewards(quest: QuestData) -> void:
	var rewards: QuestRewards = quest.rewards as QuestRewards
	if rewards == null:
		return
	
	# XP
	if rewards.xp > 0:
		var player = GameManager.player
		if player and player.has_method("gain_xp"):
			player.gain_xp(rewards.xp)
		EventBus.xp_gained.emit(GameManager.player, rewards.xp)
	
	# Gold
	if rewards.gold > 0:
		EventBus.currency_changed.emit(Enums.CurrencyType.GOLD, rewards.gold)
	
	# Dark Essence
	if rewards.dark_essence > 0:
		EventBus.dark_essence_changed.emit(rewards.dark_essence)
	
	# Relic Fragments
	if rewards.relic_fragments > 0:
		EventBus.relic_fragments_changed.emit(rewards.relic_fragments)
	
	# Skill pontok
	if rewards.skill_points > 0:
		EventBus.show_notification.emit(
			"+%d Skill Point%s!" % [rewards.skill_points, "s" if rewards.skill_points > 1 else ""],
			Enums.NotificationType.LEVEL_UP
		)
	
	# Item jutalmak
	for item_id in rewards.items:
		EventBus.show_notification.emit("Received item: %s" % item_id, Enums.NotificationType.LOOT)
	
	# Biome/terület unlock
	if not rewards.unlock.is_empty():
		EventBus.quest_unlock_granted.emit(rewards.unlock)
		EventBus.show_notification.emit("Unlocked: %s" % rewards.unlock, Enums.NotificationType.ACHIEVEMENT)


# ═══════════════════════════════════════════════════════════════
#  QUEST IDŐZÍTŐK
# ═══════════════════════════════════════════════════════════════

func _update_quest_timers(delta: float) -> void:
	var failed_quests: Array[String] = []
	
	for quest_id in _quest_timers:
		_quest_timers[quest_id] -= delta
		if _quest_timers[quest_id] <= 0.0:
			failed_quests.append(quest_id)
	
	for quest_id in failed_quests:
		_fail_quest(quest_id)


func _fail_quest(quest_id: String) -> void:
	if quest_id not in active_quest_ids:
		return
	
	var quest: QuestData = quest_database[quest_id]
	quest_states[quest_id] = QuestState.FAILED
	active_quest_ids.erase(quest_id)
	_quest_timers.erase(quest_id)
	quest_progress.erase(quest_id)
	
	if tracked_quest_id == quest_id:
		tracked_quest_id = active_quest_ids[0] if not active_quest_ids.is_empty() else ""
	
	EventBus.quest_failed.emit(quest_id)
	EventBus.show_notification.emit("Quest failed: %s" % quest.quest_name, Enums.NotificationType.WARNING)


func get_quest_remaining_time(quest_id: String) -> float:
	return _quest_timers.get(quest_id, -1.0)


func _is_quest_complete(quest_id: String) -> bool:
	return quest_states.get(quest_id) == QuestState.COMPLETE


# ═══════════════════════════════════════════════════════════════
#  QUEST DATABASE BETÖLTÉS
# ═══════════════════════════════════════════════════════════════

func _load_quest_database() -> void:
	_load_quests_from_json("res://data/quests/main_quests.json")
	_load_quests_from_json("res://data/quests/side_quests.json")
	_load_quests_from_json("res://data/quests/daily_templates.json")
	_load_quests_from_json("res://data/quests/weekly_templates.json")
	
	# Kezdeti elérhetőség beállítása
	_initialize_quest_availability()


func _load_quests_from_json(path: String) -> void:
	if not FileAccess.file_exists(path):
		push_warning("QuestManager: Quest file not found: %s" % path)
		return
	
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("QuestManager: Cannot read %s" % path)
		return
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("QuestManager: JSON parse error in %s: %s" % [path, json.get_error_message()])
		return
	
	var data: Array = json.data if json.data is Array else []
	for quest_dict in data:
		if quest_dict is Dictionary:
			var quest := QuestData.from_dict(quest_dict)
			quest_database[quest.quest_id] = quest
	
	print("QuestManager: Loaded %d quests from %s" % [data.size(), path])


func _initialize_quest_availability() -> void:
	for quest_id in quest_database:
		var quest: QuestData = quest_database[quest_id]
		if quest.prerequisites.is_empty():
			quest_states[quest_id] = QuestState.AVAILABLE
		else:
			quest_states[quest_id] = QuestState.NOT_AVAILABLE


# ═══════════════════════════════════════════════════════════════
#  NPC INTERAKCIÓ KEZELÉS
# ═══════════════════════════════════════════════════════════════

## Quest NPC-vel történő interakció - a DialogueManager-en keresztül
func handle_quest_npc_interaction(npc_id: String) -> void:
	# Először leadható quest-ek
	var completable := get_completable_quests_for_npc(npc_id)
	if not completable.is_empty():
		var quest: QuestData = completable[0]
		_show_turn_in_dialogue(quest)
		return
	
	# Aztán új elérhető quest-ek
	var available := get_available_quests_for_npc(npc_id)
	if not available.is_empty():
		var quest: QuestData = available[0]
		_show_quest_offer_dialogue(quest)
		return
	
	# Nincs elérhető quest
	EventBus.show_notification.emit("No quests available.", Enums.NotificationType.INFO)


func _show_quest_offer_dialogue(quest: QuestData) -> void:
	if has_node("/root/DialogueManager"):
		var dm = get_node("/root/DialogueManager")
		if dm.has_method("start_quest_dialogue"):
			dm.start_quest_dialogue(quest)
	else:
		# Fallback: közvetlen UI használat
		_direct_quest_offer(quest)


func _show_turn_in_dialogue(quest: QuestData) -> void:
	if has_node("/root/DialogueManager"):
		var dm = get_node("/root/DialogueManager")
		if dm.has_method("start_turn_in_dialogue"):
			dm.start_turn_in_dialogue(quest)
	else:
		# Fallback: közvetlen turn in
		turn_in_quest(quest.quest_id)


func _direct_quest_offer(quest: QuestData) -> void:
	# Ha nincs DialogueManager, közvetlenül elfogadjuk a quest-et
	accept_quest(quest.quest_id)


# ═══════════════════════════════════════════════════════════════
#  SAVE / LOAD
# ═══════════════════════════════════════════════════════════════

## Quest álapot serialization (mentéshez)
func serialize() -> Dictionary:
	var progress_data: Dictionary = {}
	for quest_id in active_quest_ids:
		if quest_database.has(quest_id):
			var quest: QuestData = quest_database[quest_id]
			var obj_progress: Array[Dictionary] = []
			for obj in quest.objectives:
				if obj is QuestObjective:
					obj_progress.append({"current": obj.current_count})
			progress_data[quest_id] = obj_progress
	
	return {
		"quest_states": quest_states.duplicate(),
		"active_quest_ids": active_quest_ids.duplicate(),
		"completed_quests": completed_quests.duplicate(),
		"tracked_quest_id": tracked_quest_id,
		"progress": progress_data,
		"daily_quests": daily_quests.duplicate(),
		"weekly_quest": weekly_quest,
		"daily_reset_time": daily_reset_time,
		"weekly_reset_time": weekly_reset_time,
		"quest_timers": _quest_timers.duplicate(),
	}


## Quest állapot deserialization (betöltéshez)
func deserialize(data: Dictionary) -> void:
	quest_states = data.get("quest_states", {})
	active_quest_ids = data.get("active_quest_ids", [])
	completed_quests = data.get("completed_quests", [])
	tracked_quest_id = data.get("tracked_quest_id", "")
	daily_quests = data.get("daily_quests", [])
	weekly_quest = data.get("weekly_quest", "")
	daily_reset_time = data.get("daily_reset_time", 0.0)
	weekly_reset_time = data.get("weekly_reset_time", 0.0)
	_quest_timers = data.get("quest_timers", {})
	
	# Objective progress visszaállítása
	var progress: Dictionary = data.get("progress", {})
	for quest_id in progress:
		if quest_database.has(quest_id):
			var quest: QuestData = quest_database[quest_id]
			var obj_progress: Array = progress[quest_id]
			for i in range(mini(obj_progress.size(), quest.objectives.size())):
				var obj: QuestObjective = quest.objectives[i] as QuestObjective
				if obj:
					obj.current_count = obj_progress[i].get("current", 0)
	
	print("QuestManager: State restored - %d active, %d completed" % [active_quest_ids.size(), completed_quests.size()])


# ═══════════════════════════════════════════════════════════════
#  LEKÉRDEZÉSEK ÉS UTILITY
# ═══════════════════════════════════════════════════════════════

## Tracked quest adatai (HUD Quest Tracker számára)
func get_tracked_quest_data() -> Dictionary:
	if tracked_quest_id.is_empty() or not quest_database.has(tracked_quest_id):
		return {}
	
	var quest: QuestData = quest_database[tracked_quest_id]
	var objectives: Array[Dictionary] = []
	for obj in quest.objectives:
		if obj is QuestObjective:
			objectives.append({
				"text": obj.description,
				"current": obj.current_count,
				"target": obj.target_count,
				"completed": obj.is_completed(),
				"optional": obj.is_optional,
			})
	
	return {
		"id": quest.quest_id,
		"name": quest.quest_name,
		"state": quest_states.get(tracked_quest_id, QuestState.NOT_AVAILABLE),
		"objectives": objectives,
	}


## Quest-ek konvertálása a QuestLogUI számára
func get_quests_for_ui() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	
	# Aktív quest-ek
	for quest_id in active_quest_ids:
		if quest_database.has(quest_id):
			result.append(_quest_to_ui_dict(quest_database[quest_id], "active"))
	
	# Befejezett quest-ek
	for quest_id in completed_quests:
		if quest_database.has(quest_id):
			result.append(_quest_to_ui_dict(quest_database[quest_id], "completed"))
	
	return result


func _quest_to_ui_dict(quest: QuestData, status: String) -> Dictionary:
	var obj_list: Array[Dictionary] = []
	for obj in quest.objectives:
		if obj is QuestObjective:
			obj_list.append({
				"text": obj.description,
				"current": obj.current_count,
				"target": obj.target_count,
				"completed": obj.is_completed(),
			})
	
	var reward_texts: Array[String] = []
	if quest.rewards is QuestRewards:
		reward_texts = (quest.rewards as QuestRewards).get_reward_texts()
	var reward_list: Array[Dictionary] = []
	for rt in reward_texts:
		reward_list.append({"text": rt})
	
	return {
		"id": quest.quest_id,
		"name": quest.quest_name,
		"description": quest.description,
		"status": status,
		"objectives": obj_list,
		"rewards": reward_list,
	}


## Összesen hány quest van befejezve
func get_total_completed_count() -> int:
	return completed_quests.size()


## Main story haladás (hányadik main quest-nél tartunk)
func get_main_story_progress() -> int:
	var count := 0
	for quest_id in completed_quests:
		if quest_database.has(quest_id):
			var quest: QuestData = quest_database[quest_id]
			if quest.quest_type == QuestData.QuestType.MAIN_STORY:
				count += 1
	return count

## AchievementManager - Achievement tracking és unlock kezelés (Autoload singleton)
## Figyeli az EventBus signal-okat és frissíti az achievement haladást
extends Node

## Achievement adatbázis: id → AchievementData
var _achievements: Dictionary = {}  # String → AchievementData

## Condition type → achievement id lista (gyors lookup)
var _condition_index: Dictionary = {}  # String → Array[String]

## Összesen megnyitott achievement-ek száma
var _total_unlocked: int = 0

## Achievement popup queue
var _popup_queue: Array[Dictionary] = []
var _popup_active: bool = false


func _ready() -> void:
	_load_achievement_database()
	_connect_signals()
	print("AchievementManager: %d achievement betöltve" % _achievements.size())


# ==========================================================================
#  ADATBÁZIS BETÖLTÉS
# ==========================================================================

func _load_achievement_database() -> void:
	var file_path := "res://data/achievements/achievements.json"
	if not FileAccess.file_exists(file_path):
		push_warning("AchievementManager: achievements.json not found at " + file_path)
		return
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("AchievementManager: Cannot open " + file_path)
		return
	
	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	file.close()
	
	if parse_result != OK:
		push_error("AchievementManager: JSON parse error")
		return
	
	var data: Dictionary = json.data
	var achievement_array: Array = data.get("achievements", [])
	
	for entry in achievement_array:
		var achievement := AchievementData.from_dict(entry)
		_achievements[achievement.id] = achievement
		
		# Condition index építés
		var ctype: String = achievement.condition_type
		if not _condition_index.has(ctype):
			_condition_index[ctype] = []
		_condition_index[ctype].append(achievement.id)


# ==========================================================================
#  SIGNAL CSATLAKOZÁSOK
# ==========================================================================

func _connect_signals() -> void:
	# Combat events
	EventBus.entity_killed.connect(_on_entity_killed)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.damage_dealt.connect(_on_damage_dealt)
	
	# Exploration events
	EventBus.biome_entered.connect(_on_biome_entered)
	EventBus.chunk_loaded.connect(_on_chunk_loaded)
	EventBus.dungeon_exited.connect(_on_dungeon_exited)
	EventBus.dungeon_secret_room_found.connect(_on_secret_room_found)
	EventBus.dungeon_chest_opened.connect(_on_chest_opened)
	
	# Loot / Economy
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.gold_changed.connect(_on_gold_changed)
	EventBus.crafting_completed.connect(_on_crafting_completed)
	EventBus.enhancement_attempted.connect(_on_enhancement_attempted)
	EventBus.gem_combined.connect(_on_gem_combined)
	EventBus.marketplace_listing_sold.connect(_on_marketplace_sold)
	
	# Progression
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.skill_point_allocated.connect(_on_skill_allocated)
	EventBus.profession_leveled_up.connect(_on_profession_leveled_up)
	
	# Quest / Story
	EventBus.quest_completed.connect(_on_quest_completed)
	
	# Multiplayer
	EventBus.player_connected.connect(_on_player_connected)
	
	# Fast Travel / Waypoints
	EventBus.waypoint_discovered.connect(_on_waypoint_discovered)
	
	# World events
	EventBus.world_event_ended.connect(_on_world_event_ended)
	
	# Gathering
	EventBus.gathering_completed.connect(_on_gathering_completed)
	
	# Weather
	EventBus.weather_changed.connect(_on_weather_changed)


# ==========================================================================
#  HALADÁS FRISSÍTÉS
# ==========================================================================

## Általános haladás frissítő - adott condition_type-ra
func update_progress(condition_type: String, amount: int = 1, target: String = "") -> void:
	if not _condition_index.has(condition_type):
		return
	
	for ach_id in _condition_index[condition_type]:
		var ach: AchievementData = _achievements[ach_id]
		if ach.is_unlocked:
			continue
		
		# Ha van condition_target, ellenőrizzük
		if ach.condition_target != "" and target != "" and ach.condition_target != target:
			continue
		
		ach.current_progress += amount
		
		EventBus.achievement_progress_updated.emit(
			ach.id, ach.current_progress, ach.condition_value
		)
		
		if ach.check_completion():
			_unlock_achievement(ach)


## Haladás beállítása fix értékre (nem növelés, hanem felülírás)
func set_progress(condition_type: String, value: int, target: String = "") -> void:
	if not _condition_index.has(condition_type):
		return
	
	for ach_id in _condition_index[condition_type]:
		var ach: AchievementData = _achievements[ach_id]
		if ach.is_unlocked:
			continue
		
		if ach.condition_target != "" and target != "" and ach.condition_target != target:
			continue
		
		if value > ach.current_progress:
			ach.current_progress = value
			
			EventBus.achievement_progress_updated.emit(
				ach.id, ach.current_progress, ach.condition_value
			)
			
			if ach.check_completion():
				_unlock_achievement(ach)


# ==========================================================================
#  ACHIEVEMENT UNLOCK
# ==========================================================================

func _unlock_achievement(ach: AchievementData) -> void:
	_total_unlocked += 1
	
	# Dark Essence jutalom
	if ach.reward_dark_essence > 0:
		EventBus.dark_essence_changed.emit(ach.reward_dark_essence)
	
	# Popup queue-ba
	var popup_data := ach.to_ui_dict()
	_popup_queue.append(popup_data)
	
	# Signal
	EventBus.achievement_unlocked.emit(ach.id, popup_data)
	
	# Notification rendszer
	EventBus.show_notification.emit(
		"ACHIEVEMENT: %s (+%d DE)" % [ach.name, ach.reward_dark_essence],
		Enums.NotificationType.ACHIEVEMENT
	)
	
	# Stats tracker frissítés
	if has_node("/root/StatsTracker"):
		StatsTracker.increment_stat("achievements_unlocked", 1)
	
	print("AchievementManager: UNLOCKED '%s' – +%d Dark Essence" % [
		ach.name, ach.reward_dark_essence
	])
	
	if not _popup_active:
		_show_next_popup()


func _show_next_popup() -> void:
	if _popup_queue.is_empty():
		_popup_active = false
		return
	
	_popup_active = true
	var data: Dictionary = _popup_queue.pop_front()
	
	# Achievement popup scene betöltése ha létezik
	var popup_scene := load("res://scenes/ui/achievement_popup.tscn")
	if popup_scene:
		var popup: Node = popup_scene.instantiate()
		if popup.has_method("setup"):
			popup.setup(data)
		get_tree().root.add_child(popup)
		
		# Popup eltűnése után következő
		var timer := get_tree().create_timer(Constants.ACHIEVEMENT_POPUP_DURATION + 0.5)
		timer.timeout.connect(_show_next_popup)
	else:
		# Ha nincs popup scene, folytassuk a queue-t
		_popup_active = false


# ==========================================================================
#  EVENT HANDLER-EK
# ==========================================================================

func _on_entity_killed(_killer, victim) -> void:
	update_progress("kill_count", 1)
	
	# Elite ellenőrzés
	if victim and victim.has_method("get_enemy_type"):
		if victim.get_enemy_type() == Enums.EnemyType.ELITE:
			update_progress("elite_kill_count", 1)


func _on_boss_defeated(boss_id: String) -> void:
	update_progress("boss_kill_count", 1)
	update_progress("unique_boss_kills", 1, boss_id)
	
	# World boss ellenőrzés
	if boss_id.begins_with("world_boss_"):
		update_progress("world_boss_kill_count", 1)


func _on_damage_dealt(_source, _target, amount: float, _damage_type) -> void:
	update_progress("total_damage_dealt", int(amount))


func _on_biome_entered(_player, _biome: Enums.BiomeType) -> void:
	# A StatsTracker-ben számolja a biome-okat
	if has_node("/root/StatsTracker"):
		var count: int = StatsTracker.get_stat("biomes_discovered")
		set_progress("biomes_discovered", count)


func _on_chunk_loaded(_chunk_pos: Vector2i) -> void:
	update_progress("chunks_explored", 1)


func _on_dungeon_exited() -> void:
	update_progress("dungeons_completed", 1)


func _on_secret_room_found(_room_index: int) -> void:
	update_progress("secret_rooms_found", 1)


func _on_chest_opened(_chest_data: Dictionary) -> void:
	update_progress("chests_opened", 1)


func _on_item_picked_up(item_instance) -> void:
	if item_instance == null:
		return
	
	# Rarity ellenőrzés
	if item_instance is Dictionary:
		var rarity = item_instance.get("rarity", 0)
		if rarity >= Enums.Rarity.RARE:
			update_progress("rare_items_found", 1)
		if rarity >= Enums.Rarity.LEGENDARY:
			update_progress("legendary_items_found", 1)
	elif item_instance.has_method("get_rarity"):
		var rarity = item_instance.get_rarity()
		if rarity >= Enums.Rarity.RARE:
			update_progress("rare_items_found", 1)
		if rarity >= Enums.Rarity.LEGENDARY:
			update_progress("legendary_items_found", 1)


func _on_gold_changed(_player, new_amount: int) -> void:
	set_progress("total_gold_earned", new_amount)


func _on_crafting_completed(_recipe_id: String, success: bool) -> void:
	if success:
		update_progress("items_crafted", 1)


func _on_enhancement_attempted(_item_uuid: String, level: int, success: bool) -> void:
	if success and level >= 10:
		update_progress("max_enhancement_reached", 1)


func _on_gem_combined(_result_gem_type: Enums.GemType, result_tier: Enums.GemTier) -> void:
	if result_tier == Enums.GemTier.RADIANT:
		update_progress("radiant_gem_crafted", 1)


func _on_marketplace_sold(_listing_id: String) -> void:
	update_progress("marketplace_sales", 1)


func _on_player_leveled_up(_player, new_level: int) -> void:
	set_progress("level_reached", new_level)


func _on_skill_allocated(_skill_id: String, _new_rank: int) -> void:
	# Egyszerűsített: mindig frissítjük
	update_progress("skill_branches_learned", 0)  # StatsTracker-ben kézzel


func _on_profession_leveled_up(_profession: Enums.ProfessionType, new_level: int) -> void:
	set_progress("profession_max_level", new_level)


func _on_quest_completed(quest_id: String) -> void:
	# ACT completion ellenőrzés
	if quest_id.begins_with("main_act_1"):
		set_progress("act_completed", 1, "act_1")
	elif quest_id.begins_with("main_act_2"):
		set_progress("act_completed", 1, "act_2")
	elif quest_id.begins_with("main_act_3"):
		set_progress("act_completed", 1, "act_3")
	
	if quest_id == "main_story_final":
		set_progress("main_story_completed", 1)


func _on_player_connected(_peer_id: int) -> void:
	update_progress("coop_sessions_completed", 1)


func _on_waypoint_discovered(_waypoint_id: String, _waypoint_name: String) -> void:
	update_progress("waypoints_activated", 1)


func _on_world_event_ended(event_type: int, _rewards: Dictionary) -> void:
	update_progress("world_events_participated", 1)
	
	if event_type == Enums.WorldEventType.BLOOD_MOON:
		update_progress("blood_moon_survived", 1)
	elif event_type == Enums.WorldEventType.INVASION:
		update_progress("invasion_defended", 1)


func _on_gathering_completed(_node_type: Enums.GatheringNodeType, yield_amount: int) -> void:
	update_progress("total_resources_gathered", yield_amount)


func _on_weather_changed(_weather: Enums.WeatherType) -> void:
	if has_node("/root/StatsTracker"):
		var count: int = StatsTracker.get_stat("weather_types_seen")
		set_progress("weather_types_seen", count)


# ==========================================================================
#  LEKÉRDEZÉSEK
# ==========================================================================

## Visszaadja egy achievement adatát
func get_achievement(ach_id: String) -> AchievementData:
	return _achievements.get(ach_id, null)


## Visszaadja az összes achievement-et kategória szerint
func get_achievements_by_category(category: Enums.AchievementCategory) -> Array[AchievementData]:
	var result: Array[AchievementData] = []
	for ach in _achievements.values():
		if ach.category == category:
			result.append(ach)
	return result


## Visszaadja az összes feloldott achievement-et
func get_unlocked_achievements() -> Array[AchievementData]:
	var result: Array[AchievementData] = []
	for ach in _achievements.values():
		if ach.is_unlocked:
			result.append(ach)
	return result


## Feloldott achievement-ek száma
func get_unlocked_count() -> int:
	return _total_unlocked


## Összes achievement száma
func get_total_count() -> int:
	return _achievements.size()


## Haladás százalék (összes achievement)
func get_completion_percentage() -> float:
	if _achievements.is_empty():
		return 0.0
	return float(_total_unlocked) / float(_achievements.size()) * 100.0


## Összes Dark Essence jutalom (eddig szerzett)
func get_total_de_earned() -> int:
	var total: int = 0
	for ach in _achievements.values():
		if ach.is_unlocked:
			total += ach.reward_dark_essence
	return total


# ==========================================================================
#  MENTÉS / BETÖLTÉS
# ==========================================================================

func serialize() -> Dictionary:
	var save_data: Dictionary = {}
	for ach_id in _achievements:
		var ach: AchievementData = _achievements[ach_id]
		save_data[ach_id] = ach.serialize()
	return save_data


func deserialize(data: Dictionary) -> void:
	_total_unlocked = 0
	for ach_id in data:
		if _achievements.has(ach_id):
			_achievements[ach_id].load_progress(data[ach_id])
			if _achievements[ach_id].is_unlocked:
				_total_unlocked += 1
	print("AchievementManager: %d/%d achievement betöltve (mentésből)" % [
		_total_unlocked, _achievements.size()
	])

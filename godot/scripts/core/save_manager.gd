## SaveManager - Mentés/Betöltés (Autoload singleton)
## JSON alapú save rendszer, 3 slot, autosave
extends Node

const SAVE_DIR: String = "user://saves/"
const SAVE_FILE_TEMPLATE: String = "slot_%d.json"

var _autosave_timer: Timer
var _current_slot: int = -1


func _ready() -> void:
	# Save könyvtár létrehozása
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)
	
	# Autosave timer
	_autosave_timer = Timer.new()
	_autosave_timer.wait_time = Constants.AUTOSAVE_INTERVAL
	_autosave_timer.timeout.connect(_on_autosave)
	_autosave_timer.autostart = false
	add_child(_autosave_timer)


func start_autosave() -> void:
	_autosave_timer.start()


func stop_autosave() -> void:
	_autosave_timer.stop()


func save_game(slot: int) -> bool:
	var save_data: Dictionary = {}
	save_data["version"] = "0.1.0"
	save_data["timestamp"] = Time.get_unix_time_from_system()
	save_data["datetime"] = Time.get_datetime_string_from_system()
	
	# TODO: Feltölteni a tényleges játék adatokkal
	# save_data["player"] = PlayerManager.serialize()
	# save_data["inventory"] = Inventory.serialize()
	# save_data["equipment"] = Equipment.serialize()
	# save_data["world"] = WorldGenerator.serialize()
	
	# Economy rendszer mentése
	if has_node("/root/EconomyManager"):
		save_data["economy"] = EconomyManager.serialize()
	
	# Quest rendszer mentése
	if has_node("/root/QuestManager"):
		save_data["quests"] = QuestManager.serialize()
	
	# Dialogue állapot mentése
	if has_node("/root/DialogueManager"):
		save_data["dialogues"] = DialogueManager.serialize()
	
	# Tutorial állapot mentése
	if has_node("/root/TutorialManager"):
		save_data["tutorials"] = TutorialManager.serialize()
	
	# Achievement rendszer mentése
	if has_node("/root/AchievementManager"):
		save_data["achievements"] = AchievementManager.serialize()
	
	# Statisztikák mentése
	if has_node("/root/StatsTracker"):
		save_data["stats"] = StatsTracker.serialize()
	
	# Endgame rendszer mentése
	if has_node("/root/EndgameManager"):
		save_data["endgame"] = EndgameManager.serialize()
	
	# Fast Travel mentése
	if has_node("/root/FastTravel"):
		save_data["fast_travel"] = FastTravel.serialize()
	
	var json_string := JSON.stringify(save_data, "\t")
	var file_path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot
	
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: Cannot write to " + file_path)
		return false
	
	file.store_string(json_string)
	file.close()
	
	_current_slot = slot
	print("SaveManager: Game saved to slot %d" % slot)
	return true


func load_game(slot: int) -> Dictionary:
	var file_path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot
	
	if not FileAccess.file_exists(file_path):
		push_warning("SaveManager: No save file in slot %d" % slot)
		return {}
	
	var file := FileAccess.open(file_path, FileAccess.READ)
	if not file:
		push_error("SaveManager: Cannot read " + file_path)
		return {}
	
	var json_string := file.get_as_text()
	file.close()
	
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	if parse_result != OK:
		push_error("SaveManager: JSON parse error in slot %d" % slot)
		return {}
	
	_current_slot = slot
	print("SaveManager: Game loaded from slot %d" % slot)
	
	# Economy rendszer betöltése
	if json.data.has("economy") and has_node("/root/EconomyManager"):
		EconomyManager.deserialize(json.data["economy"])
	
	# Quest rendszer betöltése
	if json.data.has("quests") and has_node("/root/QuestManager"):
		QuestManager.deserialize(json.data["quests"])
	
	# Dialogue állapot betöltése
	if json.data.has("dialogues") and has_node("/root/DialogueManager"):
		DialogueManager.deserialize(json.data["dialogues"])
	
	# Tutorial állapot betöltése
	if json.data.has("tutorials") and has_node("/root/TutorialManager"):
		TutorialManager.deserialize(json.data["tutorials"])
	
	# Achievement rendszer betöltése
	if json.data.has("achievements") and has_node("/root/AchievementManager"):
		AchievementManager.deserialize(json.data["achievements"])
	
	# Statisztikák betöltése
	if json.data.has("stats") and has_node("/root/StatsTracker"):
		StatsTracker.deserialize(json.data["stats"])
	
	# Endgame rendszer betöltése
	if json.data.has("endgame") and has_node("/root/EndgameManager"):
		EndgameManager.deserialize(json.data["endgame"])
	
	# Fast Travel betöltése
	if json.data.has("fast_travel") and has_node("/root/FastTravel"):
		FastTravel.deserialize(json.data["fast_travel"])
	
	return json.data


func delete_save(slot: int) -> bool:
	var file_path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		print("SaveManager: Deleted save slot %d" % slot)
		return true
	return false


func has_save(slot: int) -> bool:
	var file_path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot
	return FileAccess.file_exists(file_path)


func get_save_info(slot: int) -> Dictionary:
	## Visszaadja a slot alap info-it (tooltip-hez / lista megjelenítéshez)
	if not has_save(slot):
		return {"empty": true}
	
	var data := load_game(slot)
	return {
		"empty": false,
		"datetime": data.get("datetime", "Unknown"),
		"version": data.get("version", "?"),
	}


func _on_autosave() -> void:
	if _current_slot >= 0 and GameManager.is_playing():
		save_game(_current_slot)


## Autosave before quit - NOTIFICATION kezelés
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		# Mentés kilépés előtt
		if _current_slot >= 0 and GameManager.is_playing():
			print("SaveManager: Autosaving before quit...")
			save_game(_current_slot)
		get_tree().quit()


## Teljes játék állapot mentése (minden manager)
func save_full_game_state(slot: int) -> bool:
	var save_data: Dictionary = {}
	save_data["version"] = "0.1.0"
	save_data["timestamp"] = Time.get_unix_time_from_system()
	save_data["datetime"] = Time.get_datetime_string_from_system()
	
	# Player adatok
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		var player = players[0]
		save_data["player"] = {
			"class": player.player_class,
			"level": player.level,
			"current_xp": player.current_xp,
			"max_hp": player.max_hp,
			"current_hp": player.current_hp,
			"max_mana": player.max_mana,
			"current_mana": player.current_mana,
			"base_damage": player.base_damage,
			"armor": player.armor,
			"skill_points": player.skill_points,
			"position_x": player.global_position.x,
			"position_y": player.global_position.y,
		}
	
	# Economy rendszer mentése
	if has_node("/root/EconomyManager"):
		save_data["economy"] = get_node("/root/EconomyManager").serialize()
	
	# Inventory & Equipment
	if has_node("/root/EconomyManager"):
		var econ = get_node("/root/EconomyManager")
		if econ.inventory_manager:
			save_data["inventory"] = econ.inventory_manager.serialize()
		if econ.currency_manager:
			save_data["currency"] = econ.currency_manager.serialize()
	
	# Loot Filter mentése
	if has_node("/root/LootManager"):
		var loot_mgr = get_node("/root/LootManager")
		if loot_mgr.filter:
			save_data["loot_filter"] = loot_mgr.filter.serialize()
	
	# Quest rendszer
	if has_node("/root/QuestManager"):
		save_data["quests"] = get_node("/root/QuestManager").serialize()
	
	# Dialogue állapot
	if has_node("/root/DialogueManager"):
		save_data["dialogues"] = get_node("/root/DialogueManager").serialize()
	
	# Tutorial állapot
	if has_node("/root/TutorialManager"):
		save_data["tutorials"] = get_node("/root/TutorialManager").serialize()
	
	# Achievement rendszer
	if has_node("/root/AchievementManager"):
		save_data["achievements"] = get_node("/root/AchievementManager").serialize()
	
	# Stats
	if has_node("/root/StatsTracker"):
		save_data["stats"] = get_node("/root/StatsTracker").serialize()
	
	# Endgame
	if has_node("/root/EndgameManager"):
		save_data["endgame"] = get_node("/root/EndgameManager").serialize()
	
	# Fast Travel
	if has_node("/root/FastTravel"):
		save_data["fast_travel"] = get_node("/root/FastTravel").serialize()
	
	# JSON mentés
	var json_string := JSON.stringify(save_data, "\t")
	var file_path := SAVE_DIR + SAVE_FILE_TEMPLATE % slot
	
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: Cannot write to " + file_path)
		return false
	
	file.store_string(json_string)
	file.close()
	
	_current_slot = slot
	print("SaveManager: Full game state saved to slot %d" % slot)
	return true


## Teljes betöltés
func load_full_game_state(slot: int) -> bool:
	var data := load_game(slot)
	if data.is_empty():
		return false
	
	# Player adatok
	if data.has("player"):
		var players := get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			var player = players[0]
			var pd: Dictionary = data["player"]
			player.player_class = pd.get("class", Enums.PlayerClass.ASSASSIN)
			player.level = pd.get("level", 1)
			player.current_xp = pd.get("current_xp", 0)
			player.max_hp = pd.get("max_hp", 80)
			player.current_hp = pd.get("current_hp", 80)
			player.max_mana = pd.get("max_mana", 60)
			player.current_mana = pd.get("current_mana", 60)
			player.base_damage = pd.get("base_damage", 12)
			player.armor = pd.get("armor", 5)
			player.skill_points = pd.get("skill_points", 0)
			player.global_position = Vector2(pd.get("position_x", 0), pd.get("position_y", 0))
	
	# Inventory & Equipment
	if data.has("inventory") and has_node("/root/EconomyManager"):
		var econ = get_node("/root/EconomyManager")
		if econ.inventory_manager:
			econ.inventory_manager.deserialize(data["inventory"])
	
	# Currency
	if data.has("currency") and has_node("/root/EconomyManager"):
		var econ = get_node("/root/EconomyManager")
		if econ.currency_manager:
			econ.currency_manager.deserialize(data["currency"])
	
	# Loot Filter
	if data.has("loot_filter") and has_node("/root/LootManager"):
		var loot_mgr = get_node("/root/LootManager")
		if loot_mgr.filter:
			loot_mgr.filter.deserialize(data["loot_filter"])
	
	EventBus.hud_update_requested.emit()
	return true

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

## ProfessionManager - Profession rendszer (gathering + crafting szakmák)
## XP, level-ek, specializáció korlátok
class_name ProfessionManager
extends Node

## Profession adatok: ProfessionType → {"level": int, "xp": int, "active": bool}
var _professions: Dictionary = {}

## Aktív profession-ök (max 2 gathering + 2 crafting)
var _active_gathering: Array[int] = []
var _active_crafting: Array[int] = []


func _ready() -> void:
	_init_professions()


func _init_professions() -> void:
	for profession_type in [
		Enums.ProfessionType.MINING,
		Enums.ProfessionType.HERBALISM,
		Enums.ProfessionType.WOODCUTTING,
		Enums.ProfessionType.SCAVENGING,
		Enums.ProfessionType.BLACKSMITHING,
		Enums.ProfessionType.ALCHEMY,
		Enums.ProfessionType.ENCHANTING,
		Enums.ProfessionType.ENGINEERING,
	]:
		_professions[profession_type] = {
			"level": 0,
			"xp": 0,
			"active": false,
		}


## Profession aktiválása
func activate_profession(profession_type: int) -> bool:
	if is_gathering_profession(profession_type):
		if _active_gathering.size() >= Constants.MAX_GATHERING_PROFESSIONS:
			return false
		if profession_type in _active_gathering:
			return true  # Már aktív
		_active_gathering.append(profession_type)
	else:
		if _active_crafting.size() >= Constants.MAX_CRAFTING_PROFESSIONS:
			return false
		if profession_type in _active_crafting:
			return true
		_active_crafting.append(profession_type)
	
	_professions[profession_type]["active"] = true
	_professions[profession_type]["level"] = maxi(1, _professions[profession_type]["level"])
	return true


## Profession deaktiválása
func deactivate_profession(profession_type: int) -> void:
	if is_gathering_profession(profession_type):
		_active_gathering.erase(profession_type)
	else:
		_active_crafting.erase(profession_type)
	_professions[profession_type]["active"] = false


## XP hozzáadás
func add_xp(profession_type: int, amount: int) -> void:
	if not _professions.has(profession_type):
		return
	if not _professions[profession_type]["active"]:
		return
	
	_professions[profession_type]["xp"] += amount
	
	# Level up ellenőrzés
	var current_level: int = _professions[profession_type]["level"]
	var xp_needed := _xp_for_next_level(current_level)
	
	while _professions[profession_type]["xp"] >= xp_needed and current_level < Constants.PROFESSION_MAX_LEVEL:
		_professions[profession_type]["xp"] -= xp_needed
		current_level += 1
		_professions[profession_type]["level"] = current_level
		xp_needed = _xp_for_next_level(current_level)
		EventBus.profession_leveled_up.emit(profession_type, current_level)
	
	EventBus.profession_xp_gained.emit(profession_type, amount)


## Level lekérdezés
func get_level(profession_type: int) -> int:
	if not _professions.has(profession_type):
		return 0
	return _professions[profession_type]["level"]


## XP lekérdezés
func get_xp(profession_type: int) -> int:
	if not _professions.has(profession_type):
		return 0
	return _professions[profession_type]["xp"]


## XP a következő szinthez
func get_xp_to_next_level(profession_type: int) -> int:
	return _xp_for_next_level(get_level(profession_type))


## Aktív?
func is_active(profession_type: int) -> bool:
	if not _professions.has(profession_type):
		return false
	return _professions[profession_type]["active"]


## Gathering profession?
static func is_gathering_profession(profession_type: int) -> bool:
	return profession_type in [
		Enums.ProfessionType.MINING,
		Enums.ProfessionType.HERBALISM,
		Enums.ProfessionType.WOODCUTTING,
		Enums.ProfessionType.SCAVENGING,
	]


## Összes aktív profession level-ek (CraftingManager-nek)
func get_all_levels() -> Dictionary:
	var levels: Dictionary = {}
	for type in _professions:
		levels[type] = _professions[type]["level"]
	return levels


## XP kalkuláció (szintenként növekvő)
func _xp_for_next_level(level: int) -> int:
	if level <= 0:
		return 50
	return int(50 * pow(1.12, level))


## Gathering profession mapping: GatheringNodeType → ProfessionType
static func get_profession_for_node(node_type: int) -> int:
	match node_type:
		Enums.GatheringNodeType.WOOD:
			return Enums.ProfessionType.WOODCUTTING
		Enums.GatheringNodeType.STONE, Enums.GatheringNodeType.ORE, Enums.GatheringNodeType.CRYSTAL:
			return Enums.ProfessionType.MINING
		Enums.GatheringNodeType.HERB, Enums.GatheringNodeType.DARK_ROOT:
			return Enums.ProfessionType.HERBALISM
		Enums.GatheringNodeType.BONE, Enums.GatheringNodeType.EMBER_COAL:
			return Enums.ProfessionType.SCAVENGING
		_:
			return -1


## Profession név
static func get_profession_name(profession_type: int) -> String:
	match profession_type:
		Enums.ProfessionType.MINING: return "Mining"
		Enums.ProfessionType.HERBALISM: return "Herbalism"
		Enums.ProfessionType.WOODCUTTING: return "Woodcutting"
		Enums.ProfessionType.SCAVENGING: return "Scavenging"
		Enums.ProfessionType.BLACKSMITHING: return "Blacksmithing"
		Enums.ProfessionType.ALCHEMY: return "Alchemy"
		Enums.ProfessionType.ENCHANTING: return "Enchanting"
		Enums.ProfessionType.ENGINEERING: return "Engineering"
		_: return "Unknown"


## Serialize
func serialize() -> Dictionary:
	var data: Dictionary = {}
	for type in _professions:
		data[str(type)] = _professions[type].duplicate()
	return {
		"professions": data,
		"active_gathering": _active_gathering.duplicate(),
		"active_crafting": _active_crafting.duplicate(),
	}


## Deserialize
func deserialize(data: Dictionary) -> void:
	if data.has("professions"):
		for type_str in data["professions"]:
			var type := int(type_str)
			if _professions.has(type):
				_professions[type] = data["professions"][type_str]
	
	if data.has("active_gathering"):
		_active_gathering.clear()
		for type in data["active_gathering"]:
			_active_gathering.append(int(type))
	
	if data.has("active_crafting"):
		_active_crafting.clear()
		for type in data["active_crafting"]:
			_active_crafting.append(int(type))

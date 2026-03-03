## ProfessionBase - Alap profession logika
## Gathering és Crafting profession-ök ebből származnak
class_name ProfessionBase
extends RefCounted

signal xp_gained(amount: int)
signal leveled_up(new_level: int)
signal action_completed(result: Dictionary)

var profession_type: Enums.ProfessionType
var profession_name: String = ""
var current_level: int = 1
var current_xp: int = 0
var is_active: bool = false

# === XP táblázat ===
const XP_PER_LEVEL_BASE: int = 100
const XP_GROWTH: float = 1.2


func _init(p_type: Enums.ProfessionType, p_name: String) -> void:
	profession_type = p_type
	profession_name = p_name


## XP szerzés
func gain_xp(amount: int) -> void:
	current_xp += amount
	xp_gained.emit(amount)
	EventBus.profession_xp_gained.emit(profession_type, amount)
	
	var xp_needed := get_xp_for_next_level()
	while current_xp >= xp_needed and current_level < Constants.PROFESSION_MAX_LEVEL:
		current_xp -= xp_needed
		current_level += 1
		leveled_up.emit(current_level)
		EventBus.profession_leveled_up.emit(profession_type, current_level)
		xp_needed = get_xp_for_next_level()


## XP szükséges a következő szinthez
func get_xp_for_next_level() -> int:
	return int(XP_PER_LEVEL_BASE * pow(XP_GROWTH, current_level - 1))


## Szint-alapú tier meghatározás
func get_tier() -> String:
	if current_level <= 10:
		return "basic"
	elif current_level <= 20:
		return "uncommon"
	elif current_level <= 30:
		return "rare"
	elif current_level <= 40:
		return "epic"
	else:
		return "legendary"


## Lehet-e az adott receptet / node-ot használni
func can_use(required_level: int) -> bool:
	return current_level >= required_level


## Serialize
func serialize() -> Dictionary:
	return {
		"profession_type": profession_type,
		"current_level": current_level,
		"current_xp": current_xp,
	}


## Deserialize
func deserialize(data: Dictionary) -> void:
	current_level = data.get("current_level", 1)
	current_xp = data.get("current_xp", 0)

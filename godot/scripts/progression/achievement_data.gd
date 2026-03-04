## AchievementData - Egy achievement adatszerkezete
## Tárolja az achievement feltételeit, jutalmait és állapotát
class_name AchievementData
extends RefCounted


var id: String = ""
var name: String = ""
var description: String = ""
var category: Enums.AchievementCategory = Enums.AchievementCategory.COMBAT
var icon_id: String = ""
var reward_dark_essence: int = 0
var reward_title: String = ""          # Opcionális cím a játékos neve fölé
var condition_type: String = ""        # "kill_count", "level_reached", stb.
var condition_target: String = ""      # Enemy ID, biome ID, stb.
var condition_value: int = 0           # Cél szám
var is_hidden: bool = false            # Rejtett achievement (meglepetés)
var is_unlocked: bool = false
var unlock_date: String = ""
var current_progress: int = 0          # Jelenlegi haladás


## Kategória string → enum konverzió
static var CATEGORY_MAP: Dictionary = {
	"COMBAT": Enums.AchievementCategory.COMBAT,
	"EXPLORATION": Enums.AchievementCategory.EXPLORATION,
	"LOOT_ECONOMY": Enums.AchievementCategory.LOOT_ECONOMY,
	"PROGRESSION": Enums.AchievementCategory.PROGRESSION,
	"SOCIAL": Enums.AchievementCategory.SOCIAL,
	"STORY": Enums.AchievementCategory.STORY,
}


## JSON dictionary-ből betöltés
static func from_dict(data: Dictionary) -> AchievementData:
	var achievement := AchievementData.new()
	achievement.id = data.get("id", "")
	achievement.name = data.get("name", "")
	achievement.description = data.get("description", "")
	achievement.icon_id = data.get("icon_id", "achievement_default")
	achievement.reward_dark_essence = data.get("reward_dark_essence", 0)
	achievement.reward_title = data.get("reward_title", "")
	achievement.condition_type = data.get("condition_type", "")
	achievement.condition_target = data.get("condition_target", "")
	achievement.condition_value = data.get("condition_value", 0)
	achievement.is_hidden = data.get("is_hidden", false)
	achievement.is_unlocked = data.get("is_unlocked", false)
	achievement.unlock_date = data.get("unlock_date", "")
	achievement.current_progress = data.get("current_progress", 0)
	
	var cat_str: String = data.get("category", "COMBAT")
	achievement.category = CATEGORY_MAP.get(cat_str, Enums.AchievementCategory.COMBAT)
	
	return achievement


## Serializálás mentéshez
func serialize() -> Dictionary:
	return {
		"id": id,
		"is_unlocked": is_unlocked,
		"unlock_date": unlock_date,
		"current_progress": current_progress,
	}


## Mentett állapot visszatöltése
func load_progress(save_data: Dictionary) -> void:
	is_unlocked = save_data.get("is_unlocked", false)
	unlock_date = save_data.get("unlock_date", "")
	current_progress = save_data.get("current_progress", 0)


## Haladás ellenőrzése – kész van-e?
func check_completion() -> bool:
	if is_unlocked:
		return false  # Már megvan
	if current_progress >= condition_value:
		is_unlocked = true
		unlock_date = Time.get_datetime_string_from_system()
		return true
	return false


## Haladás százalékban (0.0 - 1.0)
func get_progress_ratio() -> float:
	if condition_value <= 0:
		return 1.0
	return clampf(float(current_progress) / float(condition_value), 0.0, 1.0)


## Megjelenítési szöveg (rejtett achievement kezelés)
func get_display_name() -> String:
	if is_hidden and not is_unlocked:
		return "???"
	return name


func get_display_description() -> String:
	if is_hidden and not is_unlocked:
		return "Hidden Achievement"
	return description


## Dictionary formátum UI-hoz
func to_ui_dict() -> Dictionary:
	return {
		"id": id,
		"name": get_display_name(),
		"description": get_display_description(),
		"category": category,
		"progress": current_progress,
		"target": condition_value,
		"progress_ratio": get_progress_ratio(),
		"is_unlocked": is_unlocked,
		"is_hidden": is_hidden,
		"reward_de": reward_dark_essence,
		"reward_title": reward_title,
		"unlock_date": unlock_date,
	}

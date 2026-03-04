## QuestObjective - Quest célkitűzés Resource
## Egyetlen objective (pl. "Ölj meg 10 slime-ot")
class_name QuestObjective
extends Resource

enum ObjectiveType {
	KILL_ENEMY,          ## Ölj meg X ellenséget (típus szerint)
	KILL_BOSS,           ## Ölj meg egy specifikus boss-t
	COLLECT_ITEM,        ## Gyűjts X item-et
	GATHER_RESOURCE,     ## Gyűjts X resource-t
	REACH_LOCATION,      ## Érj el egy helyet
	TALK_TO_NPC,         ## Beszélj egy NPC-vel
	CLEAR_DUNGEON,       ## Teljesíts egy dungeon-t
	CLEAR_ROOM,          ## Teljesíts egy specifikus room-ot
	CRAFT_ITEM,          ## Craftolj egy item-et
	EXPLORE_AREA,        ## Fedezz fel X chunk-ot egy biome-ban
	SURVIVE_WAVES,       ## Élj túl X hullámot
	ESCORT_NPC,          ## Kísérj el egy NPC-t
	USE_SKILL,           ## Használj egy skill-t X alkalommal
}

@export var type: ObjectiveType = ObjectiveType.KILL_ENEMY
@export var target_id: String = ""            ## Enemy ID, Item ID, NPC ID, stb.
@export var target_count: int = 1             ## Hányat kell
@export var current_count: int = 0            ## Jelenlegi haladás
@export var description: String = ""          ## "Ölj meg 10 Forest Slime-ot"
@export var is_optional: bool = false         ## Opcionális cél (bonus reward)
@export var location_hint: String = ""        ## Hol találod (minimap marker)


## Teljesítve van-e az objective
func is_completed() -> bool:
	return current_count >= target_count


## Progress frissítése - visszaadja, hogy változott-e
func update_progress(amount: int = 1) -> bool:
	if is_completed():
		return false
	var old_count := current_count
	current_count = mini(current_count + amount, target_count)
	return current_count != old_count


## Reset (repeatable quest-ek számára)
func reset() -> void:
	current_count = 0


## Haladás százalékban
func get_progress_percent() -> float:
	if target_count <= 0:
		return 1.0
	return float(current_count) / float(target_count)


## Megjelenítési string
func get_display_text() -> String:
	if target_count <= 1:
		var prefix := "✓" if is_completed() else "○"
		return "%s %s" % [prefix, description]
	else:
		var prefix := "✓" if is_completed() else "○"
		return "%s %s (%d/%d)" % [prefix, description, current_count, target_count]


## Dictionary konverzió (mentéshez)
func to_dict() -> Dictionary:
	return {
		"type": type,
		"target_id": target_id,
		"target_count": target_count,
		"current_count": current_count,
		"description": description,
		"is_optional": is_optional,
		"location_hint": location_hint,
	}


## Dictionary-ből létrehozás
static func from_dict(data: Dictionary) -> QuestObjective:
	var obj := QuestObjective.new()
	obj.type = data.get("type", ObjectiveType.KILL_ENEMY) as ObjectiveType
	obj.target_id = data.get("target_id", "")
	obj.target_count = data.get("target_count", 1)
	obj.current_count = data.get("current_count", 0)
	obj.description = data.get("description", "")
	obj.is_optional = data.get("is_optional", false)
	obj.location_hint = data.get("location_hint", "")
	return obj

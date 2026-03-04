## DialogueData - Párbeszéd adatstruktúra
## Egyetlen párbeszéd szekvencia definíciója
class_name DialogueData
extends Resource

@export var dialogue_id: String = ""        ## Egyedi ID: "main_01_start"
@export var speaker_name: String = ""       ## NPC neve
@export var portrait_id: String = ""        ## Portrait kép referencia
@export var lines: Array[Resource] = []     ## DialogueLine-ok


## Dictionary konverzió
func to_dict() -> Dictionary:
	var line_list: Array[Dictionary] = []
	for line in lines:
		if line is DialogueLine:
			line_list.append(line.to_dict())
	return {
		"dialogue_id": dialogue_id,
		"speaker_name": speaker_name,
		"portrait_id": portrait_id,
		"lines": line_list,
	}


## Dictionary-ből létrehozás
static func from_dict(data: Dictionary) -> DialogueData:
	var dlg := DialogueData.new()
	dlg.dialogue_id = data.get("dialogue_id", "")
	dlg.speaker_name = data.get("speaker_name", "")
	dlg.portrait_id = data.get("portrait_id", "")
	
	var line_array: Array = data.get("lines", [])
	for line_data in line_array:
		if line_data is Dictionary:
			dlg.lines.append(DialogueLine.from_dict(line_data))
	
	return dlg

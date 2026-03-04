## DialogueResponse - Párbeszéd válaszlehetőség
## Játékos választása, akció trigger
class_name DialogueResponse
extends Resource

@export var text: String = ""                     ## Válasz szövege
@export var next_dialogue_id: String = ""         ## Következő párbeszéd ID
@export var action: String = ""                   ## "accept_quest", "decline", "continue", "turn_in"
@export var action_param: String = ""             ## Akció paramétere (pl. quest_id)
@export var condition: String = ""                ## Opcionális feltétel (pl. "level>=10")


## Dictionary konverzió
func to_dict() -> Dictionary:
	return {
		"text": text,
		"next_dialogue_id": next_dialogue_id,
		"action": action,
		"action_param": action_param,
		"condition": condition,
	}


## Dictionary-ből létrehozás
static func from_dict(data: Dictionary) -> DialogueResponse:
	var resp := DialogueResponse.new()
	resp.text = data.get("text", "")
	resp.next_dialogue_id = data.get("next_dialogue_id", "")
	resp.action = data.get("action", "")
	resp.action_param = data.get("action_param", "")
	resp.condition = data.get("condition", "")
	return resp

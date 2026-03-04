## DialogueLine - Egyetlen párbeszéd sor
## Szöveg + válaszlehetőségek
class_name DialogueLine
extends Resource

@export var text: String = ""                     ## Megjelenített szöveg
@export var responses: Array[Resource] = []       ## DialogueResponse-ok


## Van-e válaszlehetőség (vagy csak "continue")
func has_responses() -> bool:
	return not responses.is_empty()


## Dictionary konverzió
func to_dict() -> Dictionary:
	var resp_list: Array[Dictionary] = []
	for resp in responses:
		if resp is DialogueResponse:
			resp_list.append(resp.to_dict())
	return {
		"text": text,
		"responses": resp_list,
	}


## Dictionary-ből létrehozás
static func from_dict(data: Dictionary) -> DialogueLine:
	var line := DialogueLine.new()
	line.text = data.get("text", "")
	
	var responses_data: Array = data.get("responses", [])
	for resp_data in responses_data:
		if resp_data is Dictionary:
			line.responses.append(DialogueResponse.from_dict(resp_data))
	
	return line

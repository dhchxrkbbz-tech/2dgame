## GamepadPromptUI - Kontroller/billentyűzet prompt rendszer
## Automatikusan váltja az ikon/szöveg promptokat az aktív input eszköz alapján
class_name GamepadPromptUI
extends Control

# Prompt ikonok (Xbox layout alapértelmezett)
const XBOX_PROMPTS: Dictionary = {
	"attack": "RT",
	"dodge": "B",
	"interact": "A",
	"skill_1": "A",
	"skill_2": "X",
	"skill_3": "Y",
	"skill_4": "LB",
	"ultimate": "LB+RB",
	"inventory": "Select",
	"skill_tree": "D-Right",
	"map": "D-Up",
	"pause": "Start",
	"potion": "D-Down",
	"chat": "",
}

const KB_PROMPTS: Dictionary = {
	"attack": "LMB",
	"dodge": "Space",
	"interact": "E",
	"skill_1": "1",
	"skill_2": "2",
	"skill_3": "3",
	"skill_4": "4",
	"ultimate": "R",
	"inventory": "I",
	"skill_tree": "K",
	"map": "M",
	"pause": "Esc",
	"potion": "F",
	"chat": "Enter",
}


static func get_prompt(action: String) -> String:
	## Visszaadja az aktuális input eszköznek megfelelő prompt szöveget
	if InputManager.using_gamepad:
		return XBOX_PROMPTS.get(action, InputManager.get_action_key_name(action))
	else:
		# Ha van egyéni keybinding, azt használjuk
		var key_name := InputManager.get_action_key_name(action)
		if key_name != "?":
			return key_name
		return KB_PROMPTS.get(action, "?")


static func get_prompt_text(action: String, action_description: String = "") -> String:
	## Formázott prompt szöveg: "[E] Interact" vagy "[A] Interact"
	var prompt := get_prompt(action)
	if action_description.is_empty():
		return "[%s]" % prompt
	return "[%s] %s" % [prompt, action_description]


static func format_tutorial_text(text: String) -> String:
	## Tutorial szövegben a {action_name} placeholder-eket lecseréli prompt-okra
	## Pl: "Press {dodge} to dodge" → "Press [Space] to dodge" vagy "Press [B] to dodge"
	var result := text
	for action in KB_PROMPTS:
		var placeholder := "{%s}" % action
		if result.find(placeholder) != -1:
			result = result.replace(placeholder, "[%s]" % get_prompt(action))
	return result

## InputManager - Input kezelés (Autoload singleton)
## WASD mozgás, egér, gamepad, skill gombok, key rebinding
extends Node

# === Signalok ===
signal input_device_changed(is_gamepad: bool)
signal action_rebound(action: String, event: InputEvent)

# Mozgás irány (normalizált)
var move_direction: Vector2 = Vector2.ZERO

# Egér pozíció a világban
var mouse_world_position: Vector2 = Vector2.ZERO

# Irány az egér felé (karakter nézési irány)
var facing_direction: Vector2 = Vector2.DOWN

# Aktuális animációs irány (4 vagy 8 irány)
var anim_direction: Enums.Direction = Enums.Direction.SOUTH

# Input engedélyezés (UI megnyitáskor, cutscene stb. letiltható)
var input_enabled: bool = true

# Utolsó aktív input eszköz
var using_gamepad: bool = false

# === Gamepad beállítások ===
var gamepad_deadzone: float = 0.2
var gamepad_cursor_speed: float = 300.0  # px/sec (Medium)
var gamepad_aim_position: Vector2 = Vector2.ZERO  # Szoftver kurzor pozíció
var vibration_enabled: bool = true
var vibration_intensity: float = 1.0
var mouse_sensitivity: float = 1.0

# Gamepad cursor speed presets
enum CursorSpeed { SLOW, MEDIUM, FAST }
const CURSOR_SPEED_VALUES: Dictionary = {
	CursorSpeed.SLOW: 150.0,
	CursorSpeed.MEDIUM: 300.0,
	CursorSpeed.FAST: 500.0
}

# === Key Rebinding ===
# Rebindolható action-ök listája
const REBINDABLE_ACTIONS: Array[String] = [
	"move_up", "move_down", "move_left", "move_right",
	"attack", "dodge", "interact",
	"skill_1", "skill_2", "skill_3", "skill_4", "ultimate",
	"inventory", "skill_tree", "map", "pause", "chat",
]

# Default key bindings tárolása (reset-hez)
var _default_bindings: Dictionary = {}

# Rebind mód
var _rebinding_action: String = ""
var _rebind_callback: Callable = Callable()

# Settings save path
const KEYBIND_SETTINGS_PATH: String = "user://keybindings.cfg"


func _ready() -> void:
	# Mentjük az alapértelmezett binding-eket
	_save_default_bindings()
	# Betöltjük az egyéni binding-eket
	_load_keybindings()
	# Controller detection
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _process(delta: float) -> void:
	if not input_enabled:
		move_direction = Vector2.ZERO
		return
	
	_update_movement()
	_update_mouse_position()
	_update_gamepad_cursor(delta)
	_update_facing_direction()
	_detect_input_device()


func _update_movement() -> void:
	move_direction = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		move_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		move_direction.y += 1
	if Input.is_action_pressed("move_left"):
		move_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		move_direction.x += 1
	
	# Gamepad Left Stick
	if using_gamepad:
		var joy_move := Vector2(
			Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
			Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
		)
		if joy_move.length() > gamepad_deadzone:
			move_direction = joy_move
	
	if move_direction != Vector2.ZERO:
		move_direction = move_direction.normalized()


func _update_mouse_position() -> void:
	if using_gamepad:
		# Gamepad módban a szoftver kurzor pozícióját használjuk
		mouse_world_position = gamepad_aim_position
		return
	
	var viewport := get_viewport()
	if viewport:
		mouse_world_position = viewport.get_mouse_position()
		# Ha van kamera, konvertálás világ koordinátákra
		var canvas_transform := viewport.get_canvas_transform()
		mouse_world_position = canvas_transform.affine_inverse() * viewport.get_mouse_position()


func _update_gamepad_cursor(delta: float) -> void:
	if not using_gamepad:
		return
	
	var right_stick := Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	
	if right_stick.length() > gamepad_deadzone:
		# Right stick mozgatja a szoftver kurzort
		gamepad_aim_position += right_stick * gamepad_cursor_speed * delta
		
		# Képernyő határokon belül tartás
		var viewport := get_viewport()
		if viewport:
			var viewport_size := viewport.get_visible_rect().size
			gamepad_aim_position.x = clampf(gamepad_aim_position.x, 0, viewport_size.x)
			gamepad_aim_position.y = clampf(gamepad_aim_position.y, 0, viewport_size.y)
	elif GameManager.player:
		# Ha nincs Right Stick mozgás és van auto-target
		if AccessibilityManager.should_auto_target():
			_auto_target_nearest_enemy()


func _update_facing_direction() -> void:
	if not GameManager.player:
		return
	
	var player_pos: Vector2 = GameManager.player.global_position
	
	if using_gamepad:
		# Gamepad: Right Stick irány vagy auto-target
		var right_stick := Vector2(
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		)
		if right_stick.length() > gamepad_deadzone:
			facing_direction = right_stick.normalized()
		elif move_direction != Vector2.ZERO:
			facing_direction = move_direction
	else:
		facing_direction = (mouse_world_position - player_pos).normalized()
	
	if facing_direction != Vector2.ZERO:
		anim_direction = _vector_to_direction(facing_direction)


func _detect_input_device() -> void:
	# Automatikus KB/Gamepad váltás detektálás
	# Input._input_event-ben frissítjük
	pass


func _input(event: InputEvent) -> void:
	# === Rebind mód ===
	if _rebinding_action != "":
		if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
			_complete_rebind(event)
			get_viewport().set_input_as_handled()
			return
	
	# === Auto-detect input device ===
	var was_gamepad := using_gamepad
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		using_gamepad = true
	elif event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		using_gamepad = false
	
	if was_gamepad != using_gamepad:
		input_device_changed.emit(using_gamepad)


func _auto_target_nearest_enemy() -> void:
	## Auto-target: legközelebbi ellenség keresése
	if not GameManager.player:
		return
	
	var player_pos := GameManager.player.global_position
	var nearest_dist := 9999.0
	var nearest_pos := player_pos + Vector2(0, 50)  # Default: előre
	
	# Keressünk ellenségeket a player körül
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		var dist := player_pos.distance_to(enemy.global_position)
		if dist < nearest_dist and dist < 200.0:  # Max 200px range
			nearest_dist = dist
			nearest_pos = enemy.global_position
	
	if nearest_dist < 200.0:
		gamepad_aim_position = nearest_pos


func _vector_to_direction(vec: Vector2) -> Enums.Direction:
	## Konvertál egy irányvektort 8 irányos enum értékre
	var angle := vec.angle()
	# Angle to 8 directions
	# 0 = jobb (EAST), PI/2 = le (SOUTH), PI = bal (WEST), -PI/2 = fel (NORTH)
	var segment := int(round(angle / (PI / 4.0))) % 8
	if segment < 0:
		segment += 8
	
	match segment:
		0: return Enums.Direction.EAST
		1: return Enums.Direction.SOUTHEAST
		2: return Enums.Direction.SOUTH
		3: return Enums.Direction.SOUTHWEST
		4: return Enums.Direction.WEST
		5: return Enums.Direction.NORTHWEST
		6: return Enums.Direction.NORTH
		7: return Enums.Direction.NORTHEAST
		_: return Enums.Direction.SOUTH


func get_direction_string(dir: Enums.Direction) -> String:
	## Irány enumot string-re konvertál (animáció nevekhez)
	match dir:
		Enums.Direction.NORTH: return "north"
		Enums.Direction.NORTHEAST: return "northeast"
		Enums.Direction.EAST: return "east"
		Enums.Direction.SOUTHEAST: return "southeast"
		Enums.Direction.SOUTH: return "south"
		Enums.Direction.SOUTHWEST: return "southwest"
		Enums.Direction.WEST: return "west"
		Enums.Direction.NORTHWEST: return "northwest"
		_: return "south"


func get_4dir_string() -> String:
	## 4 irányos string (sprite flip-el dolgozó animációkhoz)
	match anim_direction:
		Enums.Direction.NORTH, Enums.Direction.NORTHEAST, Enums.Direction.NORTHWEST:
			return "north"
		Enums.Direction.SOUTH, Enums.Direction.SOUTHEAST, Enums.Direction.SOUTHWEST:
			return "south"
		Enums.Direction.EAST:
			return "east"
		Enums.Direction.WEST:
			return "west"
		_:
			return "south"


func is_moving() -> bool:
	return move_direction != Vector2.ZERO


func disable_input() -> void:
	input_enabled = false
	move_direction = Vector2.ZERO


func enable_input() -> void:
	input_enabled = true


# === Gamepad funkciók ===
func get_connected_gamepads() -> Array[int]:
	return Input.get_connected_joypads()


func is_gamepad_connected() -> bool:
	return Input.get_connected_joypads().size() > 0


func _on_joy_connection_changed(device: int, connected: bool) -> void:
	if connected:
		push_warning("InputManager: Controller connected (device %d)" % device)
	else:
		push_warning("InputManager: Controller disconnected (device %d)" % device)
		if using_gamepad:
			using_gamepad = false
			input_device_changed.emit(false)


func set_gamepad_deadzone(deadzone: float) -> void:
	gamepad_deadzone = clampf(deadzone, 0.05, 0.5)


func set_cursor_speed(preset: CursorSpeed) -> void:
	gamepad_cursor_speed = CURSOR_SPEED_VALUES.get(preset, 300.0)


func set_vibration_enabled(enabled: bool) -> void:
	vibration_enabled = enabled


func set_vibration_intensity(intensity: float) -> void:
	vibration_intensity = clampf(intensity, 0.0, 1.0)


func vibrate(weak: float = 0.0, strong: float = 0.0, duration: float = 0.2) -> void:
	## Kontroller rezgés
	if not vibration_enabled or not using_gamepad:
		return
	var joypads := Input.get_connected_joypads()
	if joypads.size() > 0:
		Input.start_joy_vibration(
			joypads[0],
			weak * vibration_intensity,
			strong * vibration_intensity,
			duration
		)


func stop_vibration() -> void:
	var joypads := Input.get_connected_joypads()
	if joypads.size() > 0:
		Input.stop_joy_vibration(joypads[0])


# === Key Rebinding ===
func start_rebind(action: String, callback: Callable = Callable()) -> void:
	## Rebind mód indítása – a következő gombnyomás lesz az új binding
	if action not in REBINDABLE_ACTIONS:
		push_warning("InputManager: Action '%s' is not rebindable" % action)
		return
	_rebinding_action = action
	_rebind_callback = callback


func cancel_rebind() -> void:
	_rebinding_action = ""
	_rebind_callback = Callable()


func is_rebinding() -> bool:
	return _rebinding_action != ""


func _complete_rebind(event: InputEvent) -> void:
	var action := _rebinding_action
	_rebinding_action = ""
	
	# Conflict detection – van-e más action ami ezt a gombot használja?
	var conflict_action := _find_conflict(action, event)
	if not conflict_action.is_empty():
		push_warning("InputManager: Key conflict with action '%s'" % conflict_action)
	
	# Régi keyboard/mouse event-ek törlése (gamepad-ot meghagyjuk és fordítva)
	var events := InputMap.action_get_events(action)
	for existing_event in events:
		if event is InputEventKey and existing_event is InputEventKey:
			InputMap.action_erase_event(action, existing_event)
		elif event is InputEventMouseButton and existing_event is InputEventMouseButton:
			InputMap.action_erase_event(action, existing_event)
		elif event is InputEventJoypadButton and existing_event is InputEventJoypadButton:
			InputMap.action_erase_event(action, existing_event)
	
	# Új event hozzáadása
	InputMap.action_add_event(action, event)
	
	action_rebound.emit(action, event)
	
	if _rebind_callback.is_valid():
		_rebind_callback.call(action, event)
	_rebind_callback = Callable()
	
	# Mentés
	_save_keybindings()


func _find_conflict(skip_action: String, event: InputEvent) -> String:
	## Keresés: melyik másik action használja ezt a gombot?
	for action in REBINDABLE_ACTIONS:
		if action == skip_action:
			continue
		var events := InputMap.action_get_events(action)
		for existing_event in events:
			if _events_match(event, existing_event):
				return action
	return ""


func _events_match(a: InputEvent, b: InputEvent) -> bool:
	if a is InputEventKey and b is InputEventKey:
		return (a as InputEventKey).physical_keycode == (b as InputEventKey).physical_keycode
	elif a is InputEventMouseButton and b is InputEventMouseButton:
		return (a as InputEventMouseButton).button_index == (b as InputEventMouseButton).button_index
	elif a is InputEventJoypadButton and b is InputEventJoypadButton:
		return (a as InputEventJoypadButton).button_index == (b as InputEventJoypadButton).button_index
	return false


func get_action_key_name(action: String) -> String:
	## Az action aktuális gomb nevének lekérése (UI-hoz)
	var events := InputMap.action_get_events(action)
	for event in events:
		if using_gamepad:
			if event is InputEventJoypadButton:
				return _get_joypad_button_name(event.button_index)
		else:
			if event is InputEventKey:
				return OS.get_keycode_string(event.physical_keycode)
			elif event is InputEventMouseButton:
				return _get_mouse_button_name(event.button_index)
	
	# Fallback
	for event in events:
		if event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode)
		elif event is InputEventMouseButton:
			return _get_mouse_button_name(event.button_index)
		elif event is InputEventJoypadButton:
			return _get_joypad_button_name(event.button_index)
	
	return "?"


func _get_mouse_button_name(button: MouseButton) -> String:
	match button:
		MOUSE_BUTTON_LEFT: return "LMB"
		MOUSE_BUTTON_RIGHT: return "RMB"
		MOUSE_BUTTON_MIDDLE: return "MMB"
		_: return "Mouse %d" % button


func _get_joypad_button_name(button: JoyButton) -> String:
	match button:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
		JOY_BUTTON_LEFT_SHOULDER: return "LB"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB"
		JOY_BUTTON_LEFT_STICK: return "LS"
		JOY_BUTTON_RIGHT_STICK: return "RS"
		JOY_BUTTON_BACK: return "Select"
		JOY_BUTTON_START: return "Start"
		JOY_BUTTON_DPAD_UP: return "D-Up"
		JOY_BUTTON_DPAD_DOWN: return "D-Down"
		JOY_BUTTON_DPAD_LEFT: return "D-Left"
		JOY_BUTTON_DPAD_RIGHT: return "D-Right"
		_: return "Joy %d" % button


func reset_keybindings() -> void:
	## Minden keybinding visszaállítása alapértelmezettre
	for action in _default_bindings:
		InputMap.action_erase_events(action)
		for event in _default_bindings[action]:
			InputMap.action_add_event(action, event)
	_save_keybindings()


func _save_default_bindings() -> void:
	for action in REBINDABLE_ACTIONS:
		if InputMap.has_action(action):
			_default_bindings[action] = InputMap.action_get_events(action).duplicate()


func _save_keybindings() -> void:
	var config := ConfigFile.new()
	for action in REBINDABLE_ACTIONS:
		var events := InputMap.action_get_events(action)
		var event_data: Array[Dictionary] = []
		for event in events:
			if event is InputEventKey:
				event_data.append({
					"type": "key",
					"keycode": event.physical_keycode
				})
			elif event is InputEventMouseButton:
				event_data.append({
					"type": "mouse",
					"button": event.button_index
				})
			elif event is InputEventJoypadButton:
				event_data.append({
					"type": "joypad",
					"button": event.button_index
				})
		config.set_value("keybindings", action, event_data)
	
	# Gamepad beállítások
	config.set_value("gamepad", "deadzone", gamepad_deadzone)
	config.set_value("gamepad", "cursor_speed", gamepad_cursor_speed)
	config.set_value("gamepad", "vibration_enabled", vibration_enabled)
	config.set_value("gamepad", "vibration_intensity", vibration_intensity)
	config.set_value("gamepad", "mouse_sensitivity", mouse_sensitivity)
	
	config.save(KEYBIND_SETTINGS_PATH)


func _load_keybindings() -> void:
	var config := ConfigFile.new()
	if config.load(KEYBIND_SETTINGS_PATH) != OK:
		return
	
	# Keybindings
	for action in REBINDABLE_ACTIONS:
		if not config.has_section_key("keybindings", action):
			continue
		var event_data: Array = config.get_value("keybindings", action, [])
		if event_data.is_empty():
			continue
		
		InputMap.action_erase_events(action)
		for data in event_data:
			match data.get("type", ""):
				"key":
					var event := InputEventKey.new()
					event.physical_keycode = data["keycode"]
					InputMap.action_add_event(action, event)
				"mouse":
					var event := InputEventMouseButton.new()
					event.button_index = data["button"]
					InputMap.action_add_event(action, event)
				"joypad":
					var event := InputEventJoypadButton.new()
					event.button_index = data["button"]
					InputMap.action_add_event(action, event)
	
	# Gamepad beállítások
	gamepad_deadzone = config.get_value("gamepad", "deadzone", 0.2)
	gamepad_cursor_speed = config.get_value("gamepad", "cursor_speed", 300.0)
	vibration_enabled = config.get_value("gamepad", "vibration_enabled", true)
	vibration_intensity = config.get_value("gamepad", "vibration_intensity", 1.0)
	mouse_sensitivity = config.get_value("gamepad", "mouse_sensitivity", 1.0)

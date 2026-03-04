## ControlsSettingsUI - Vezérlés beállítások fül
## Key rebinding, controller beállítások, toggle vs hold
class_name ControlsSettingsUI
extends VBoxContainer

signal settings_changed()

# Rebind UI elemek referenciák
var rebind_buttons: Dictionary = {}  # action_name → Button
var rebind_label: Label = null  # "Press any key..." label


func _ready() -> void:
	name = "Controls"
	_build_ui()


func _build_ui() -> void:
	# === Key Rebinding szekció ===
	var keybind_label := Label.new()
	keybind_label.text = tr("SETTINGS_KEY_REBINDING")
	keybind_label.add_theme_font_size_override("font_size", AccessibilityManager.get_scaled_font_size(14))
	add_child(keybind_label)
	
	var separator := HSeparator.new()
	add_child(separator)
	
	# Rebind prompt label (rejtett, rebind módban látható)
	rebind_label = Label.new()
	rebind_label.text = tr("SETTINGS_PRESS_KEY")
	rebind_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rebind_label.add_theme_color_override("font_color", Color.YELLOW)
	rebind_label.visible = false
	add_child(rebind_label)
	
	# ScrollContainer a keybinding listához
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(0, 140)
	add_child(scroll)
	
	var keybind_vbox := VBoxContainer.new()
	scroll.add_child(keybind_vbox)
	
	# Minden rebindable action-hoz egy sor
	for action in InputManager.REBINDABLE_ACTIONS:
		_add_rebind_row(keybind_vbox, action)
	
	# Reset keybindings gomb
	var reset_btn := Button.new()
	reset_btn.text = tr("MENU_RESET")
	reset_btn.custom_minimum_size = Vector2(120, 25)
	reset_btn.pressed.connect(_on_reset_keybindings)
	add_child(reset_btn)
	
	# === Controller szekció ===
	var controller_sep := HSeparator.new()
	add_child(controller_sep)
	
	var controller_label := Label.new()
	controller_label.text = "Controller"
	controller_label.add_theme_font_size_override("font_size", AccessibilityManager.get_scaled_font_size(14))
	add_child(controller_label)
	
	# Controller sensitivity
	_add_slider_setting(
		tr("SETTINGS_CONTROLLER_SENSITIVITY"),
		InputManager.gamepad_cursor_speed, 100.0, 600.0,
		func(val: float): InputManager.gamepad_cursor_speed = val
	)
	
	# Controller deadzone
	_add_slider_setting(
		tr("SETTINGS_CONTROLLER_DEADZONE"),
		InputManager.gamepad_deadzone * 100.0, 5.0, 50.0,
		func(val: float): InputManager.set_gamepad_deadzone(val / 100.0)
	)
	
	# Controller vibration
	_add_toggle_setting(
		tr("SETTINGS_CONTROLLER_VIBRATION"),
		InputManager.vibration_enabled,
		func(val: bool): InputManager.set_vibration_enabled(val)
	)
	
	# Mouse sensitivity
	_add_slider_setting(
		tr("SETTINGS_MOUSE_SENSITIVITY"),
		InputManager.mouse_sensitivity * 100.0, 20.0, 300.0,
		func(val: float): InputManager.mouse_sensitivity = val / 100.0
	)
	
	# === Toggle vs Hold szekció ===
	var toggle_sep := HSeparator.new()
	add_child(toggle_sep)
	
	var toggle_label := Label.new()
	toggle_label.text = tr("SETTINGS_TOGGLE_VS_HOLD")
	toggle_label.add_theme_font_size_override("font_size", AccessibilityManager.get_scaled_font_size(14))
	add_child(toggle_label)
	
	_add_toggle_setting(
		tr("SETTINGS_SPRINT") + " " + tr("SETTINGS_TOGGLE"),
		AccessibilityManager.sprint_toggle,
		func(val: bool): AccessibilityManager.set_sprint_toggle(val)
	)
	
	_add_toggle_setting(
		tr("SETTINGS_BLOCK") + " " + tr("SETTINGS_TOGGLE"),
		AccessibilityManager.block_toggle,
		func(val: bool): AccessibilityManager.set_block_toggle(val)
	)
	
	_add_toggle_setting(
		tr("SETTINGS_CHANNEL") + " " + tr("SETTINGS_TOGGLE"),
		AccessibilityManager.channel_toggle,
		func(val: bool): AccessibilityManager.set_channel_toggle(val)
	)
	
	_add_toggle_setting(
		tr("SETTINGS_AUTO_ATTACK"),
		AccessibilityManager.auto_attack,
		func(val: bool): AccessibilityManager.set_auto_attack(val)
	)
	
	# === Auto Aim ===
	var aim_sep := HSeparator.new()
	add_child(aim_sep)
	
	_add_option_setting(
		tr("SETTINGS_AUTO_AIM"),
		[tr("SETTINGS_AUTO_AIM_OFF"), tr("SETTINGS_AUTO_AIM_SUBTLE"), tr("SETTINGS_AUTO_AIM_STRONG")],
		int(AccessibilityManager.auto_aim),
		func(idx: int): AccessibilityManager.set_auto_aim(idx as AccessibilityManager.AutoAimLevel)
	)


func _add_rebind_row(parent: VBoxContainer, action: String) -> void:
	var hbox := HBoxContainer.new()
	
	# Action név
	var action_label := Label.new()
	var action_key := "ACTION_%s" % action.to_upper()
	action_label.text = tr(action_key) if TranslationServer.get_translation_object(TranslationServer.get_locale()) else action.capitalize().replace("_", " ")
	action_label.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(action_label)
	
	# Jelenlegi binding
	var bind_button := Button.new()
	bind_button.text = InputManager.get_action_key_name(action)
	bind_button.custom_minimum_size = Vector2(100, 25)
	bind_button.pressed.connect(func(): _start_rebind(action, bind_button))
	hbox.add_child(bind_button)
	
	rebind_buttons[action] = bind_button
	parent.add_child(hbox)


func _start_rebind(action: String, button: Button) -> void:
	rebind_label.visible = true
	button.text = "..."
	InputManager.start_rebind(action, func(a: String, _event: InputEvent):
		rebind_label.visible = false
		_refresh_all_bindings()
		settings_changed.emit()
	)


func _refresh_all_bindings() -> void:
	for action in rebind_buttons:
		rebind_buttons[action].text = InputManager.get_action_key_name(action)


func _on_reset_keybindings() -> void:
	InputManager.reset_keybindings()
	_refresh_all_bindings()
	settings_changed.emit()


func _add_slider_setting(label_text: String, current_val: float, min_val: float, max_val: float, callback: Callable) -> void:
	var hbox := HBoxContainer.new()
	
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(180, 0)
	hbox.add_child(label)
	
	var slider := HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = current_val
	slider.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(slider)
	
	var value_label := Label.new()
	value_label.text = str(int(current_val))
	slider.value_changed.connect(func(val: float):
		value_label.text = str(int(val))
		callback.call(val)
		settings_changed.emit()
	)
	hbox.add_child(value_label)
	
	add_child(hbox)


func _add_toggle_setting(label_text: String, current_val: bool, callback: Callable) -> void:
	var check := CheckButton.new()
	check.text = label_text
	check.button_pressed = current_val
	check.toggled.connect(func(pressed: bool):
		callback.call(pressed)
		settings_changed.emit()
	)
	add_child(check)


func _add_option_setting(label_text: String, options: Array, current_idx: int, callback: Callable) -> void:
	var hbox := HBoxContainer.new()
	
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(180, 0)
	hbox.add_child(label)
	
	var option_btn := OptionButton.new()
	for opt in options:
		option_btn.add_item(opt)
	option_btn.selected = current_idx
	option_btn.item_selected.connect(func(idx: int):
		callback.call(idx)
		settings_changed.emit()
	)
	hbox.add_child(option_btn)
	
	add_child(hbox)

## AccessibilitySettingsUI - Akadálymentesítés beállítások fül
## Colorblind mód, szövegméret, screen shake, flash, feliratok, nehézség stb.
class_name AccessibilitySettingsUI
extends VBoxContainer

signal settings_changed()


func _ready() -> void:
	name = "Accessibility"
	_build_ui()


func _build_ui() -> void:
	# === Vizuális szekció ===
	var visual_label := Label.new()
	visual_label.text = tr("SETTINGS_ACCESSIBILITY")
	visual_label.add_theme_font_size_override("font_size", AccessibilityManager.get_scaled_font_size(14))
	add_child(visual_label)
	
	var sep1 := HSeparator.new()
	add_child(sep1)
	
	# Colorblind mód
	_add_option_setting(
		tr("SETTINGS_COLORBLIND_MODE"),
		[
			tr("SETTINGS_COLORBLIND_OFF"),
			tr("SETTINGS_COLORBLIND_PROTANOPIA"),
			tr("SETTINGS_COLORBLIND_DEUTERANOPIA"),
			tr("SETTINGS_COLORBLIND_TRITANOPIA")
		],
		int(AccessibilityManager.colorblind_mode),
		func(idx: int):
			AccessibilityManager.set_colorblind_mode(idx as AccessibilityManager.ColorblindMode)
	)
	
	# Szövegméret
	_add_option_setting(
		tr("SETTINGS_TEXT_SIZE"),
		[
			tr("SETTINGS_TEXT_SIZE_SMALL"),
			tr("SETTINGS_TEXT_SIZE_MEDIUM"),
			tr("SETTINGS_TEXT_SIZE_LARGE")
		],
		int(AccessibilityManager.text_size),
		func(idx: int):
			AccessibilityManager.set_text_size(idx as AccessibilityManager.TextSize)
	)
	
	# Screen shake intensity
	_add_slider_setting(
		tr("SETTINGS_SCREEN_SHAKE_INTENSITY"),
		AccessibilityManager.screen_shake_intensity, 0.0, 100.0,
		func(val: float):
			AccessibilityManager.set_screen_shake_intensity(val)
	)
	
	# Reduce flashing
	_add_toggle_setting(
		tr("SETTINGS_REDUCE_FLASHING"),
		AccessibilityManager.reduce_flashing,
		func(val: bool):
			AccessibilityManager.set_reduce_flashing(val)
	)
	
	# === Auditív szekció ===
	var sep2 := HSeparator.new()
	add_child(sep2)
	
	# Sound captions
	_add_toggle_setting(
		tr("SETTINGS_SOUND_CAPTIONS"),
		AccessibilityManager.sound_captions_enabled,
		func(val: bool):
			AccessibilityManager.set_sound_captions(val)
	)
	
	# Mono audio
	_add_toggle_setting(
		tr("SETTINGS_MONO_AUDIO") if tr("SETTINGS_MONO_AUDIO") != "SETTINGS_MONO_AUDIO" else "Mono Audio",
		AccessibilityManager.mono_audio,
		func(val: bool):
			AccessibilityManager.set_mono_audio(val)
	)
	
	# === Gameplay szekció ===
	var sep3 := HSeparator.new()
	add_child(sep3)
	
	# Difficulty (single player only)
	_add_option_setting(
		tr("SETTINGS_DIFFICULTY"),
		[
			tr("SETTINGS_DIFFICULTY_STORY"),
			tr("SETTINGS_DIFFICULTY_NORMAL"),
			tr("SETTINGS_DIFFICULTY_HARD")
		],
		int(AccessibilityManager.difficulty),
		func(idx: int):
			AccessibilityManager.set_difficulty(idx as AccessibilityManager.Difficulty)
	)
	
	# Nehézségi szint leírás
	var diff_desc := Label.new()
	diff_desc.name = "DifficultyDesc"
	diff_desc.text = _get_difficulty_description(AccessibilityManager.difficulty)
	diff_desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	diff_desc.add_theme_font_size_override("font_size", AccessibilityManager.get_scaled_font_size(10))
	add_child(diff_desc)
	
	# Game speed
	_add_option_setting(
		tr("SETTINGS_GAME_SPEED"),
		["50%", "75%", "100%"],
		_speed_to_index(AccessibilityManager.game_speed),
		func(idx: int):
			var speeds := [0.5, 0.75, 1.0]
			AccessibilityManager.set_game_speed(speeds[idx])
	)
	
	# Simplified UI
	_add_toggle_setting(
		tr("SETTINGS_SIMPLIFIED_UI"),
		AccessibilityManager.simplified_ui,
		func(val: bool):
			AccessibilityManager.set_simplified_ui(val)
	)
	
	# Quest path indicator
	_add_toggle_setting(
		tr("SETTINGS_QUEST_PATH"),
		AccessibilityManager.quest_path_indicator,
		func(val: bool):
			AccessibilityManager.set_quest_path_indicator(val)
	)
	
	# Auto-pickup radius
	_add_slider_setting(
		tr("SETTINGS_AUTO_PICKUP_RADIUS"),
		AccessibilityManager.auto_pickup_radius, 16.0, 128.0,
		func(val: float):
			AccessibilityManager.set_auto_pickup_radius(val)
	)


func _get_difficulty_description(diff: AccessibilityManager.Difficulty) -> String:
	match diff:
		AccessibilityManager.Difficulty.STORY:
			return tr("DIFFICULTY_STORY_DESC")
		AccessibilityManager.Difficulty.NORMAL:
			return tr("DIFFICULTY_NORMAL_DESC")
		AccessibilityManager.Difficulty.HARD:
			return tr("DIFFICULTY_HARD_DESC")
		_:
			return ""


func _speed_to_index(speed: float) -> int:
	if speed <= 0.5:
		return 0
	elif speed <= 0.75:
		return 1
	return 2


func _add_slider_setting(label_text: String, current_val: float, min_val: float, max_val: float, callback: Callable) -> void:
	var hbox := HBoxContainer.new()
	
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(200, 0)
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
	label.custom_minimum_size = Vector2(200, 0)
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

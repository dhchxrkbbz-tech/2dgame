## SettingsUI - Beállítások menü
## Hang, videó, kontrollok, gameplay, accessibility, nyelv beállítások
class_name SettingsUI
extends Control

signal settings_changed()
signal settings_closed()

# === Beállítás értékek ===
var settings: Dictionary = {
	"master_volume": 80.0,
	"music_volume": 70.0,
	"sfx_volume": 80.0,
	"ambient_volume": 60.0,
	"ui_volume": 90.0,
	"fullscreen": false,
	"vsync": true,
	"show_damage_numbers": true,
	"show_health_bars": true,
	"screen_shake": true,
	"minimap_enabled": true,
	"auto_loot": false,
	"loot_filter_rarity": 0,  # Minimum rarity to show
	"chat_enabled": true,
	"show_tutorials": true,
}

# === UI elemek ===
var tab_container: TabContainer = null
var close_button: Button = null
var apply_button: Button = null
var reset_button: Button = null

# Új fülök referenciái
var controls_tab: ControlsSettingsUI = null
var accessibility_tab: AccessibilitySettingsUI = null
var language_tab: LanguageSettingsUI = null

# Settings save path
const SETTINGS_PATH: String = "user://settings.cfg"


func _ready() -> void:
	visible = false
	_build_ui()
	_load_settings()


func _build_ui() -> void:
	# Háttér
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 0.95)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	# Cím
	var title := Label.new()
	title.text = tr("SETTINGS_TITLE")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 10)
	title.size = Vector2(640, 30)
	add_child(title)
	
	# TabContainer
	tab_container = TabContainer.new()
	tab_container.position = Vector2(20, 50)
	tab_container.size = Vector2(600, 270)
	add_child(tab_container)
	
	_build_audio_tab()
	_build_video_tab()
	_build_gameplay_tab()
	_build_controls_tab()
	_build_accessibility_tab()
	_build_language_tab()
	
	# Gombok
	apply_button = Button.new()
	apply_button.text = tr("MENU_APPLY")
	apply_button.position = Vector2(430, 330)
	apply_button.size = Vector2(80, 30)
	apply_button.pressed.connect(_on_apply)
	add_child(apply_button)
	
	reset_button = Button.new()
	reset_button.text = tr("MENU_RESET")
	reset_button.position = Vector2(520, 330)
	reset_button.size = Vector2(80, 30)
	reset_button.pressed.connect(_on_reset)
	add_child(reset_button)
	
	close_button = Button.new()
	close_button.text = "X"
	close_button.position = Vector2(600, 10)
	close_button.size = Vector2(30, 30)
	close_button.pressed.connect(func(): visible = false; settings_closed.emit())
	add_child(close_button)


func _build_audio_tab() -> void:
	var vbox := VBoxContainer.new()
	vbox.name = tr("SETTINGS_AUDIO")
	
	_add_slider(vbox, tr("SETTINGS_MASTER_VOLUME"), "master_volume", 0, 100)
	_add_slider(vbox, tr("SETTINGS_MUSIC_VOLUME"), "music_volume", 0, 100)
	_add_slider(vbox, tr("SETTINGS_SFX_VOLUME"), "sfx_volume", 0, 100)
	_add_slider(vbox, tr("SETTINGS_AMBIENT_VOLUME"), "ambient_volume", 0, 100)
	_add_slider(vbox, tr("SETTINGS_UI_VOLUME"), "ui_volume", 0, 100)
	
	tab_container.add_child(vbox)


func _build_video_tab() -> void:
	var vbox := VBoxContainer.new()
	vbox.name = tr("SETTINGS_VIDEO")
	
	_add_checkbox(vbox, tr("SETTINGS_FULLSCREEN"), "fullscreen")
	_add_checkbox(vbox, tr("SETTINGS_VSYNC"), "vsync")
	_add_checkbox(vbox, tr("SETTINGS_SCREEN_SHAKE"), "screen_shake")
	
	tab_container.add_child(vbox)


func _build_gameplay_tab() -> void:
	var vbox := VBoxContainer.new()
	vbox.name = tr("SETTINGS_GAMEPLAY")
	
	_add_checkbox(vbox, tr("SETTINGS_SHOW_DAMAGE_NUMBERS"), "show_damage_numbers")
	_add_checkbox(vbox, tr("SETTINGS_SHOW_HEALTH_BARS"), "show_health_bars")
	_add_checkbox(vbox, tr("SETTINGS_MINIMAP"), "minimap_enabled")
	_add_checkbox(vbox, tr("SETTINGS_AUTO_LOOT"), "auto_loot")
	_add_checkbox(vbox, tr("SETTINGS_CHAT_ENABLED"), "chat_enabled")
	_add_checkbox(vbox, tr("SETTINGS_SHOW_TUTORIALS"), "show_tutorials")
	
	tab_container.add_child(vbox)


func _build_controls_tab() -> void:
	controls_tab = ControlsSettingsUI.new()
	controls_tab.settings_changed.connect(func(): settings_changed.emit())
	tab_container.add_child(controls_tab)


func _build_accessibility_tab() -> void:
	accessibility_tab = AccessibilitySettingsUI.new()
	accessibility_tab.settings_changed.connect(func(): settings_changed.emit())
	tab_container.add_child(accessibility_tab)


func _build_language_tab() -> void:
	language_tab = LanguageSettingsUI.new()
	language_tab.settings_changed.connect(func(): settings_changed.emit())
	tab_container.add_child(language_tab)


func _add_slider(parent: Control, label_text: String, setting_key: String, min_val: float, max_val: float) -> void:
	var hbox := HBoxContainer.new()
	
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(label)
	
	var slider := HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.value = settings.get(setting_key, 50.0)
	slider.custom_minimum_size = Vector2(200, 0)
	slider.value_changed.connect(func(val): settings[setting_key] = val)
	hbox.add_child(slider)
	
	var value_label := Label.new()
	value_label.text = str(int(slider.value))
	slider.value_changed.connect(func(val): value_label.text = str(int(val)))
	hbox.add_child(value_label)
	
	parent.add_child(hbox)


func _add_checkbox(parent: Control, label_text: String, setting_key: String) -> void:
	var check := CheckButton.new()
	check.text = label_text
	check.button_pressed = settings.get(setting_key, false)
	check.toggled.connect(func(pressed): settings[setting_key] = pressed)
	parent.add_child(check)


func _on_apply() -> void:
	_apply_settings()
	_save_settings()
	# Mentjük az accessibility és keybinding beállításokat is
	AccessibilityManager.save_settings()
	settings_changed.emit()


func _on_reset() -> void:
	settings = {
		"master_volume": 80.0,
		"music_volume": 70.0,
		"sfx_volume": 80.0,
		"ambient_volume": 60.0,
		"ui_volume": 90.0,
		"fullscreen": false,
		"vsync": true,
		"show_damage_numbers": true,
		"show_health_bars": true,
		"screen_shake": true,
		"minimap_enabled": true,
		"auto_loot": false,
		"loot_filter_rarity": 0,
		"chat_enabled": true,
		"show_tutorials": true,
	}
	_apply_settings()
	rebuild_ui()


func rebuild_ui() -> void:
	## Teljes UI újraépítés (nyelv váltás után szükséges)
	for child in tab_container.get_children():
		child.queue_free()
	controls_tab = null
	accessibility_tab = null
	language_tab = null
	# Várakozunk egy frame-et, hogy a queue_free lefusson
	await get_tree().process_frame
	_build_audio_tab()
	_build_video_tab()
	_build_gameplay_tab()
	_build_controls_tab()
	_build_accessibility_tab()
	_build_language_tab()


func _apply_settings() -> void:
	# Audio - AudioManager-en keresztül
	AudioManager.set_master_volume(settings["master_volume"] / 100.0)
	AudioManager.set_music_volume(settings["music_volume"] / 100.0)
	AudioManager.set_sfx_volume(settings["sfx_volume"] / 100.0)
	AudioManager.set_ambient_volume(settings["ambient_volume"] / 100.0)
	AudioManager.set_ui_volume(settings["ui_volume"] / 100.0)
	
	# Video
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if settings["vsync"] else DisplayServer.VSYNC_DISABLED
	)
	
	# Tutorial rendszer
	if has_node("/root/TutorialManager"):
		TutorialManager.tutorials_enabled = settings.get("show_tutorials", true)


func _save_settings() -> void:
	var config := ConfigFile.new()
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.save(SETTINGS_PATH)


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		for key in settings:
			if config.has_section_key("settings", key):
				settings[key] = config.get_value("settings", key)
		_apply_settings()


func open() -> void:
	visible = true


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		visible = false
		settings_closed.emit()
		get_viewport().set_input_as_handled()

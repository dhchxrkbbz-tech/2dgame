## AccessibilityManager - Akadálymentesítési rendszer (Autoload singleton)
## Colorblind módok, szövegméretezés, screen shake, flash kontroll,
## nehézségi szint, játéksebesség, egyszerűsített UI, hangfeliratok
extends Node

# === Signalok ===
signal accessibility_settings_changed()
signal colorblind_mode_changed(mode: ColorblindMode)
signal text_size_changed(size: TextSize)
signal difficulty_changed(difficulty: Difficulty)
signal game_speed_changed(speed: float)

# === Enumok ===
enum ColorblindMode {
	OFF,
	PROTANOPIA,
	DEUTERANOPIA,
	TRITANOPIA
}

enum TextSize {
	SMALL,    # Alapértelmezett
	MEDIUM,   # +25%
	LARGE     # +50%
}

enum Difficulty {
	STORY,
	NORMAL,
	HARD
}

enum AutoAimLevel {
	OFF,
	SUBTLE,    # 10° magnetizmus
	STRONG     # Auto-target
}

# === Beállítások ===
var colorblind_mode: ColorblindMode = ColorblindMode.OFF
var text_size: TextSize = TextSize.SMALL
var screen_shake_intensity: float = 100.0  # 0-100%
var reduce_flashing: bool = false
var sound_captions_enabled: bool = false
var difficulty: Difficulty = Difficulty.NORMAL
var game_speed: float = 1.0  # 0.5, 0.75, 1.0
var simplified_ui: bool = false
var quest_path_indicator: bool = true
var auto_pickup_radius: float = 32.0  # pixel-ben
var auto_aim: AutoAimLevel = AutoAimLevel.OFF
var mono_audio: bool = false

# Toggle vs Hold beállítások
var sprint_toggle: bool = false
var block_toggle: bool = false
var channel_toggle: bool = false
var auto_attack: bool = false

# Nehézségi szorzók
var enemy_damage_multiplier: float = 1.0
var player_damage_multiplier: float = 1.0
var auto_potions: bool = false

# Szövegméret szorzók
const TEXT_SIZE_MULTIPLIERS: Dictionary = {
	TextSize.SMALL: 1.0,
	TextSize.MEDIUM: 1.25,
	TextSize.LARGE: 1.5
}

# Colorblind remap táblák (eredeti szín → módosított szín)
const COLORBLIND_REMAP: Dictionary = {
	ColorblindMode.PROTANOPIA: {
		"red_to": Color(1.0, 0.6, 0.0),       # Vörös → Narancssárga
		"green_to": Color(0.3, 0.5, 1.0),      # Zöld → Kék
		"hp_bar": Color(1.0, 1.0, 1.0),        # HP bar: Fehér
		"poison": Color(0.6, 0.2, 0.8),        # Méreg: Lila
	},
	ColorblindMode.DEUTERANOPIA: {
		"red_to": Color(1.0, 0.5, 0.0),
		"green_to": Color(0.2, 0.4, 1.0),
		"hp_bar": Color(1.0, 0.9, 0.7),
		"poison": Color(0.7, 0.2, 0.9),
	},
	ColorblindMode.TRITANOPIA: {
		"blue_to": Color(0.0, 0.8, 0.8),       # Kék → Cián
		"yellow_to": Color(1.0, 1.0, 0.9),     # Sárga → Fehér/Arany
		"hp_bar": Color(1.0, 0.3, 0.3),
		"poison": Color(0.0, 0.8, 0.0),
	}
}

# Ritkaság szimbólumok (colorblind kiegészítés)
const RARITY_SYMBOLS: Dictionary = {
	0: "",          # Common: nincs szimbólum
	1: "●",         # Uncommon: kör
	2: "▲",         # Rare: háromszög
	3: "◆",         # Epic: rombusz
	4: "★",         # Legendary: csillag
}

# Settings save path
const ACCESSIBILITY_SETTINGS_PATH: String = "user://accessibility.cfg"


func _ready() -> void:
	_load_settings()


# === Colorblind mód ===
func set_colorblind_mode(mode: ColorblindMode) -> void:
	colorblind_mode = mode
	colorblind_mode_changed.emit(mode)
	_apply_colorblind_shader()
	accessibility_settings_changed.emit()


func _apply_colorblind_shader() -> void:
	# A CanvasLayer-en keresztül alkalmazzuk a colorblind shader-t
	var viewport := get_viewport()
	if not viewport:
		return
	
	# Keresd meg vagy hozd létre a colorblind overlay-t
	var overlay := get_node_or_null("ColorblindOverlay")
	if colorblind_mode == ColorblindMode.OFF:
		if overlay:
			overlay.queue_free()
		return
	
	if not overlay:
		overlay = ColorRect.new()
		overlay.name = "ColorblindOverlay"
		overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# Teljes képernyőt lefedő overlay
		var canvas_layer := CanvasLayer.new()
		canvas_layer.name = "ColorblindLayer"
		canvas_layer.layer = 100  # Legfelső réteg
		canvas_layer.add_child(overlay)
		add_child(canvas_layer)
		overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# Shader beállítás
	var shader := load("res://assets/shaders/colorblind.gdshader")
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		mat.set_shader_parameter("mode", int(colorblind_mode))
		overlay.material = mat


func get_rarity_symbol(rarity_level: int) -> String:
	return RARITY_SYMBOLS.get(rarity_level, "")


func get_rarity_display(rarity_level: int, rarity_name: String) -> String:
	## Ritkaság megjelenítés szimbólummal (colorblind támogatás)
	var symbol := get_rarity_symbol(rarity_level)
	if symbol.is_empty():
		return rarity_name
	return "%s %s" % [symbol, rarity_name]


# === Szövegméretezés ===
func set_text_size(size: TextSize) -> void:
	text_size = size
	text_size_changed.emit(size)
	accessibility_settings_changed.emit()


func get_text_scale() -> float:
	return TEXT_SIZE_MULTIPLIERS.get(text_size, 1.0)


func get_scaled_font_size(base_size: int) -> int:
	return int(base_size * get_text_scale())


# === Screen Shake ===
func set_screen_shake_intensity(intensity: float) -> void:
	screen_shake_intensity = clampf(intensity, 0.0, 100.0)
	accessibility_settings_changed.emit()


func get_shake_multiplier() -> float:
	return screen_shake_intensity / 100.0


func should_shake() -> bool:
	return screen_shake_intensity > 0.0


# === Flash csökkentés ===
func set_reduce_flashing(enabled: bool) -> void:
	reduce_flashing = enabled
	accessibility_settings_changed.emit()


func get_flash_duration(default_duration: float) -> float:
	if reduce_flashing:
		return min(default_duration, 0.02)  # Max 20ms flash
	return default_duration


func should_flash() -> bool:
	return not reduce_flashing


# === Hangfeliratok ===
func set_sound_captions(enabled: bool) -> void:
	sound_captions_enabled = enabled
	accessibility_settings_changed.emit()


# === Nehézségi szint ===
func set_difficulty(diff: Difficulty) -> void:
	difficulty = diff
	_apply_difficulty_multipliers()
	difficulty_changed.emit(diff)
	accessibility_settings_changed.emit()


func _apply_difficulty_multipliers() -> void:
	match difficulty:
		Difficulty.STORY:
			enemy_damage_multiplier = 0.5
			player_damage_multiplier = 1.5
			auto_potions = true
		Difficulty.NORMAL:
			enemy_damage_multiplier = 1.0
			player_damage_multiplier = 1.0
			auto_potions = false
		Difficulty.HARD:
			enemy_damage_multiplier = 1.3
			player_damage_multiplier = 0.9
			auto_potions = false


func get_enemy_damage(base_damage: float) -> float:
	return base_damage * enemy_damage_multiplier


func get_player_damage(base_damage: float) -> float:
	return base_damage * player_damage_multiplier


# === Játéksebesség ===
func set_game_speed(speed: float) -> void:
	speed = clampf(speed, 0.5, 1.0)
	game_speed = speed
	Engine.time_scale = speed
	game_speed_changed.emit(speed)
	accessibility_settings_changed.emit()


# === Mono Audio ===
func set_mono_audio(enabled: bool) -> void:
	mono_audio = enabled
	# Godot 4 mono audio beállítás
	AudioServer.set_bus_effect_enabled(0, 0, enabled)
	accessibility_settings_changed.emit()


# === Auto Aim ===
func set_auto_aim(level: AutoAimLevel) -> void:
	auto_aim = level
	accessibility_settings_changed.emit()


func get_aim_assist_angle() -> float:
	match auto_aim:
		AutoAimLevel.SUBTLE:
			return deg_to_rad(10.0)
		AutoAimLevel.STRONG:
			return deg_to_rad(45.0)
		_:
			return 0.0


func should_auto_target() -> bool:
	return auto_aim == AutoAimLevel.STRONG


# === Toggle vs Hold ===
func set_sprint_toggle(toggle: bool) -> void:
	sprint_toggle = toggle
	accessibility_settings_changed.emit()


func set_block_toggle(toggle: bool) -> void:
	block_toggle = toggle
	accessibility_settings_changed.emit()


func set_channel_toggle(toggle: bool) -> void:
	channel_toggle = toggle
	accessibility_settings_changed.emit()


func set_auto_attack(enabled: bool) -> void:
	auto_attack = enabled
	accessibility_settings_changed.emit()


# === Simplified UI ===
func set_simplified_ui(enabled: bool) -> void:
	simplified_ui = enabled
	accessibility_settings_changed.emit()


# === Quest Path ===
func set_quest_path_indicator(enabled: bool) -> void:
	quest_path_indicator = enabled
	accessibility_settings_changed.emit()


# === Auto Pickup ===
func set_auto_pickup_radius(radius: float) -> void:
	auto_pickup_radius = clampf(radius, 16.0, 128.0)
	accessibility_settings_changed.emit()


# === Settings mentés/betöltés ===
func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("accessibility", "colorblind_mode", int(colorblind_mode))
	config.set_value("accessibility", "text_size", int(text_size))
	config.set_value("accessibility", "screen_shake_intensity", screen_shake_intensity)
	config.set_value("accessibility", "reduce_flashing", reduce_flashing)
	config.set_value("accessibility", "sound_captions_enabled", sound_captions_enabled)
	config.set_value("accessibility", "difficulty", int(difficulty))
	config.set_value("accessibility", "game_speed", game_speed)
	config.set_value("accessibility", "simplified_ui", simplified_ui)
	config.set_value("accessibility", "quest_path_indicator", quest_path_indicator)
	config.set_value("accessibility", "auto_pickup_radius", auto_pickup_radius)
	config.set_value("accessibility", "auto_aim", int(auto_aim))
	config.set_value("accessibility", "mono_audio", mono_audio)
	config.set_value("accessibility", "sprint_toggle", sprint_toggle)
	config.set_value("accessibility", "block_toggle", block_toggle)
	config.set_value("accessibility", "channel_toggle", channel_toggle)
	config.set_value("accessibility", "auto_attack", auto_attack)
	config.save(ACCESSIBILITY_SETTINGS_PATH)


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(ACCESSIBILITY_SETTINGS_PATH) != OK:
		return
	
	colorblind_mode = config.get_value("accessibility", "colorblind_mode", 0) as ColorblindMode
	text_size = config.get_value("accessibility", "text_size", 0) as TextSize
	screen_shake_intensity = config.get_value("accessibility", "screen_shake_intensity", 100.0)
	reduce_flashing = config.get_value("accessibility", "reduce_flashing", false)
	sound_captions_enabled = config.get_value("accessibility", "sound_captions_enabled", false)
	difficulty = config.get_value("accessibility", "difficulty", 1) as Difficulty
	game_speed = config.get_value("accessibility", "game_speed", 1.0)
	simplified_ui = config.get_value("accessibility", "simplified_ui", false)
	quest_path_indicator = config.get_value("accessibility", "quest_path_indicator", true)
	auto_pickup_radius = config.get_value("accessibility", "auto_pickup_radius", 32.0)
	auto_aim = config.get_value("accessibility", "auto_aim", 0) as AutoAimLevel
	mono_audio = config.get_value("accessibility", "mono_audio", false)
	sprint_toggle = config.get_value("accessibility", "sprint_toggle", false)
	block_toggle = config.get_value("accessibility", "block_toggle", false)
	channel_toggle = config.get_value("accessibility", "channel_toggle", false)
	auto_attack = config.get_value("accessibility", "auto_attack", false)
	
	# Alkalmazás
	_apply_difficulty_multipliers()
	if game_speed != 1.0:
		Engine.time_scale = game_speed
	if colorblind_mode != ColorblindMode.OFF:
		_apply_colorblind_shader()

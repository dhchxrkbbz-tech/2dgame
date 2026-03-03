## HUD - Játékos fejfölötti UI
## HP bar, Mana bar, XP bar, Level, Gold
extends Control

# Node referenciák - runtime-ban létrehozzuk őket
var hp_bar: ProgressBar
var mana_bar: ProgressBar
var xp_bar: ProgressBar
var level_label: Label
var gold_label: Label
var notification_label: Label

var _notification_tween: Tween


func _ready() -> void:
	_build_hud()
	EventBus.hud_update_requested.connect(_update_hud)
	EventBus.show_notification.connect(_show_notification)


func _build_hud() -> void:
	# === Bal alsó sarok: HP és Mana bar ===
	var bottom_left := VBoxContainer.new()
	bottom_left.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	bottom_left.position = Vector2(8, -80)
	bottom_left.size = Vector2(200, 70)
	add_child(bottom_left)
	
	# HP Bar
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(180, 16)
	hp_bar.max_value = 100
	hp_bar.value = 100
	hp_bar.show_percentage = false
	var hp_stylebox := StyleBoxFlat.new()
	hp_stylebox.bg_color = Color(0.8, 0.1, 0.1)
	hp_bar.add_theme_stylebox_override("fill", hp_stylebox)
	var hp_bg := StyleBoxFlat.new()
	hp_bg.bg_color = Color(0.2, 0.05, 0.05)
	hp_bar.add_theme_stylebox_override("background", hp_bg)
	bottom_left.add_child(hp_bar)
	
	# Mana Bar
	mana_bar = ProgressBar.new()
	mana_bar.custom_minimum_size = Vector2(180, 12)
	mana_bar.max_value = 100
	mana_bar.value = 100
	mana_bar.show_percentage = false
	var mana_stylebox := StyleBoxFlat.new()
	mana_stylebox.bg_color = Color(0.1, 0.2, 0.8)
	mana_bar.add_theme_stylebox_override("fill", mana_stylebox)
	var mana_bg := StyleBoxFlat.new()
	mana_bg.bg_color = Color(0.05, 0.05, 0.2)
	mana_bar.add_theme_stylebox_override("background", mana_bg)
	bottom_left.add_child(mana_bar)
	
	# XP Bar
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(180, 8)
	xp_bar.max_value = 100
	xp_bar.value = 0
	xp_bar.show_percentage = false
	var xp_stylebox := StyleBoxFlat.new()
	xp_stylebox.bg_color = Color(0.8, 0.8, 0.0)
	xp_bar.add_theme_stylebox_override("fill", xp_stylebox)
	var xp_bg := StyleBoxFlat.new()
	xp_bg.bg_color = Color(0.15, 0.15, 0.05)
	xp_bar.add_theme_stylebox_override("background", xp_bg)
	bottom_left.add_child(xp_bar)
	
	# Level label
	level_label = Label.new()
	level_label.text = "Lv. 1"
	level_label.add_theme_font_size_override("font_size", 14)
	level_label.add_theme_color_override("font_color", Color.WHITE)
	bottom_left.add_child(level_label)
	
	# Gold label
	gold_label = Label.new()
	gold_label.text = "Gold: 0"
	gold_label.add_theme_font_size_override("font_size", 12)
	gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	bottom_left.add_child(gold_label)
	
	# === Középen felül: notification ===
	notification_label = Label.new()
	notification_label.set_anchors_preset(Control.PRESET_CENTER_TOP)
	notification_label.position = Vector2(-150, 20)
	notification_label.size = Vector2(300, 30)
	notification_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification_label.add_theme_font_size_override("font_size", 18)
	notification_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	notification_label.modulate.a = 0.0
	add_child(notification_label)


func _update_hud() -> void:
	var player = GameManager.player
	if not player:
		return
	
	hp_bar.max_value = player.max_hp
	hp_bar.value = player.current_hp
	
	mana_bar.max_value = player.max_mana
	mana_bar.value = player.current_mana
	
	var xp_needed := Constants.get_xp_for_level(player.level + 1)
	xp_bar.max_value = xp_needed if xp_needed > 0 else 1
	xp_bar.value = player.current_xp
	
	level_label.text = "Lv. %d" % player.level


func _show_notification(text: String, type: Enums.NotificationType) -> void:
	notification_label.text = text
	
	match type:
		Enums.NotificationType.LEVEL_UP:
			notification_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
		Enums.NotificationType.LOOT:
			notification_label.add_theme_color_override("font_color", Color(0.3, 1, 0.3))
		Enums.NotificationType.WARNING:
			notification_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
		_:
			notification_label.add_theme_color_override("font_color", Color.WHITE)
	
	if _notification_tween:
		_notification_tween.kill()
	
	_notification_tween = create_tween()
	notification_label.modulate.a = 1.0
	_notification_tween.tween_interval(2.0)
	_notification_tween.tween_property(notification_label, "modulate:a", 0.0, 1.0)

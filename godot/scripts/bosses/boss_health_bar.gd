## BossHealthBar - Boss HP bar a képernyő tetején
class_name BossHealthBar
extends CanvasLayer

var boss_name_label: Label
var hp_bar: ProgressBar
var phase_label: Label
var enrage_label: Label
var container: PanelContainer

var _target_boss: Node = null


func _ready() -> void:
	layer = 10
	_build_ui()
	visible = false


func _build_ui() -> void:
	container = PanelContainer.new()
	container.anchor_left = 0.15
	container.anchor_right = 0.85
	container.anchor_top = 0.02
	container.anchor_bottom = 0.08
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.06, 0.85)
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.border_width_bottom = 2
	style.border_width_top = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(0.6, 0.2, 0.2)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	container.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	container.add_child(vbox)
	
	# Top row: Boss név + Phase
	var top_row := HBoxContainer.new()
	vbox.add_child(top_row)
	
	boss_name_label = Label.new()
	boss_name_label.text = "Boss Name"
	boss_name_label.add_theme_font_size_override("font_size", 14)
	boss_name_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.6))
	boss_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(boss_name_label)
	
	phase_label = Label.new()
	phase_label.text = ""
	phase_label.add_theme_font_size_override("font_size", 10)
	phase_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.8))
	phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_row.add_child(phase_label)
	
	enrage_label = Label.new()
	enrage_label.text = ""
	enrage_label.add_theme_font_size_override("font_size", 10)
	enrage_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	enrage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_row.add_child(enrage_label)
	
	# HP Bar
	hp_bar = ProgressBar.new()
	hp_bar.min_value = 0
	hp_bar.max_value = 100
	hp_bar.value = 100
	hp_bar.show_percentage = false
	hp_bar.custom_minimum_size = Vector2(0, 16)
	
	var bar_bg := StyleBoxFlat.new()
	bar_bg.bg_color = Color(0.15, 0.1, 0.08)
	bar_bg.corner_radius_top_left = 2
	bar_bg.corner_radius_top_right = 2
	bar_bg.corner_radius_bottom_left = 2
	bar_bg.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("background", bar_bg)
	
	var bar_fill := StyleBoxFlat.new()
	bar_fill.bg_color = Color(0.7, 0.15, 0.1)
	bar_fill.corner_radius_top_left = 2
	bar_fill.corner_radius_top_right = 2
	bar_fill.corner_radius_bottom_left = 2
	bar_fill.corner_radius_bottom_right = 2
	hp_bar.add_theme_stylebox_override("fill", bar_fill)
	
	vbox.add_child(hp_bar)
	
	add_child(container)


func show_boss(boss_node: Node, boss_name: String, max_hp: int) -> void:
	_target_boss = boss_node
	boss_name_label.text = boss_name
	hp_bar.max_value = max_hp
	hp_bar.value = max_hp
	phase_label.text = ""
	enrage_label.text = ""
	visible = true


func update_hp(current_hp: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = current_hp
	
	# Szín váltás HP alapján
	var hp_percent := float(current_hp) / float(max_hp)
	var bar_fill: StyleBoxFlat = hp_bar.get_theme_stylebox("fill")
	if hp_percent > 0.5:
		bar_fill.bg_color = Color(0.7, 0.15, 0.1)
	elif hp_percent > 0.25:
		bar_fill.bg_color = Color(0.8, 0.4, 0.1)
	else:
		bar_fill.bg_color = Color(0.9, 0.1, 0.1)


func update_phase(phase_name: String) -> void:
	phase_label.text = "Phase: " + phase_name


func update_enrage(time_remaining: float) -> void:
	if time_remaining <= 0:
		enrage_label.text = "ENRAGED!"
		enrage_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	elif time_remaining < 60:
		enrage_label.text = "Enrage: %ds" % int(time_remaining)
		enrage_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))
	else:
		var mins := int(time_remaining) / 60
		var secs := int(time_remaining) % 60
		enrage_label.text = "Enrage: %d:%02d" % [mins, secs]
		enrage_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))


func hide_boss() -> void:
	_target_boss = null
	visible = false

## DebugConsole - Fejlesztői konzol (csak debug build-ben)
## F12-vel nyitható, parancsok futtathatók
extends CanvasLayer

var _visible: bool = false
var _console_panel: PanelContainer
var _output_label: RichTextLabel
var _input_field: LineEdit


func _ready() -> void:
	if not OS.is_debug_build():
		queue_free()
		return
	
	layer = 99
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_console_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_debug"):
		_toggle_console()


func _build_ui() -> void:
	_console_panel = PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.85)
	style.border_color = Color(0.3, 0.3, 0.3)
	style.set_border_width_all(1)
	_console_panel.add_theme_stylebox_override("panel", style)
	
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	margin.size = Vector2(640, 200)
	_console_panel.add_child(margin)
	
	var vbox := VBoxContainer.new()
	margin.add_child(vbox)
	
	_output_label = RichTextLabel.new()
	_output_label.custom_minimum_size = Vector2(0, 160)
	_output_label.bbcode_enabled = true
	_output_label.scroll_following = true
	_output_label.add_theme_font_size_override("normal_font_size", 11)
	vbox.add_child(_output_label)
	
	_input_field = LineEdit.new()
	_input_field.placeholder_text = "Enter command..."
	_input_field.text_submitted.connect(_on_command_submitted)
	vbox.add_child(_input_field)
	
	add_child(_console_panel)
	
	_log("[color=yellow]Ashenfall Debug Console[/color]")
	_log("Type 'help' for commands")


func _toggle_console() -> void:
	_visible = !_visible
	_console_panel.visible = _visible
	if _visible:
		_input_field.grab_focus()
		get_tree().paused = true
	else:
		get_tree().paused = GameManager.current_state == Enums.GameState.PAUSED


func _on_command_submitted(command: String) -> void:
	_input_field.clear()
	_log("> " + command)
	_execute_command(command)


func _execute_command(command: String) -> void:
	var parts := command.strip_edges().split(" ")
	if parts.is_empty():
		return
	
	match parts[0].to_lower():
		"help":
			_log("Commands: help, hp [amount], mana [amount], xp [amount], level [num], kill, god, speed [val], pos, stats")
		"hp":
			if parts.size() > 1 and GameManager.player:
				GameManager.player.current_hp = clampi(int(parts[1]), 0, GameManager.player.max_hp)
				EventBus.hud_update_requested.emit()
				_log("HP set to %d" % GameManager.player.current_hp)
		"mana":
			if parts.size() > 1 and GameManager.player:
				GameManager.player.current_mana = clampi(int(parts[1]), 0, GameManager.player.max_mana)
				EventBus.hud_update_requested.emit()
				_log("Mana set to %d" % GameManager.player.current_mana)
		"xp":
			if parts.size() > 1 and GameManager.player:
				GameManager.player.gain_xp(int(parts[1]))
				_log("Gained %s XP" % parts[1])
		"level":
			if parts.size() > 1 and GameManager.player:
				var target_level := int(parts[1])
				while GameManager.player.level < target_level and GameManager.player.level < Constants.MAX_LEVEL:
					GameManager.player._level_up()
				_log("Level set to %d" % GameManager.player.level)
		"kill":
			if GameManager.player:
				GameManager.player.take_damage(99999)
				_log("Player killed")
		"god":
			if GameManager.player:
				GameManager.player.is_invincible = !GameManager.player.is_invincible
				_log("God mode: %s" % ("ON" if GameManager.player.is_invincible else "OFF"))
		"speed":
			if parts.size() > 1 and GameManager.player:
				GameManager.player.move_speed = float(parts[1])
				_log("Speed set to %s" % parts[1])
		"pos":
			if GameManager.player:
				_log("Position: %s" % str(GameManager.player.global_position))
		"stats":
			if GameManager.player:
				var p = GameManager.player
				_log("HP: %d/%d | Mana: %d/%d | Lv: %d | DMG: %d | SPD: %.0f | ARM: %d" % [
					p.current_hp, p.max_hp, p.current_mana, p.max_mana,
					p.level, p.base_damage, p.move_speed, p.armor
				])
		_:
			_log("[color=red]Unknown command: %s[/color]" % parts[0])


func _log(text: String) -> void:
	_output_label.append_text(text + "\n")

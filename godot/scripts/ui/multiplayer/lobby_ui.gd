## LobbyUI - Lobby interface script
## Player list, class selection, ready state, start game
extends Control

@onready var player_slots_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/PlayerSlotsContainer
@onready var start_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/StartButton
@onready var ready_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/ReadyButton
@onready var leave_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonsContainer/LeaveButton
@onready var class_option: OptionButton = $PanelContainer/MarginContainer/VBoxContainer/ClassSelectContainer/ClassOption
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var status_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatusLabel

var _is_ready: bool = false
var _player_slot_scene: PackedScene

func _ready() -> void:
	_setup_class_options()
	_connect_signals()
	_update_ui()
	
	# Host can see start button, clients cannot
	start_button.visible = NetworkManager.is_server()

func _setup_class_options() -> void:
	class_option.clear()
	class_option.add_item("Assassin", Enums.PlayerClass.ASSASSIN)
	class_option.add_item("Tank Guardian", Enums.PlayerClass.TANK)
	class_option.add_item("Mage", Enums.PlayerClass.MAGE)

func _connect_signals() -> void:
	start_button.pressed.connect(_on_start_pressed)
	ready_button.pressed.connect(_on_ready_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	class_option.item_selected.connect(_on_class_selected)
	
	NetworkManager.lobby_manager.lobby_player_joined.connect(_on_player_joined)
	NetworkManager.lobby_manager.lobby_player_left.connect(_on_player_left)
	NetworkManager.lobby_manager.all_players_ready.connect(_on_all_ready)
	EventBus.lobby_updated.connect(_on_lobby_updated)

func _update_ui() -> void:
	title_label.text = "ASHENFALL - LOBBY"
	
	var player_count = NetworkManager.lobby_manager.get_player_count()
	status_label.text = "Players: %d/4" % player_count
	
	# Update player slots
	_refresh_player_slots()
	
	# Update start button
	start_button.disabled = not NetworkManager.lobby_manager._all_players_ready()

func _refresh_player_slots() -> void:
	# Clear existing slots
	for child in player_slots_container.get_children():
		child.queue_free()
	
	var players = NetworkManager.lobby_manager.get_all_players()
	
	for peer_id in players:
		var data = players[peer_id]
		var slot = _create_player_slot(data)
		player_slots_container.add_child(slot)
	
	# Fill remaining empty slots
	var empty_slots = 4 - players.size()
	for i in empty_slots:
		var empty = _create_empty_slot()
		player_slots_container.add_child(empty)

func _create_player_slot(data: Dictionary) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 50)
	
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	panel.add_child(hbox)
	
	# Color indicator
	var color_rect = ColorRect.new()
	color_rect.custom_minimum_size = Vector2(8, 40)
	color_rect.color = data.get("color", Color.WHITE)
	hbox.add_child(color_rect)
	
	# Player name
	var name_label = Label.new()
	name_label.text = data.get("player_name", "Unknown")
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(name_label)
	
	# Class
	var class_label = Label.new()
	var class_type = data.get("selected_class", 0)
	match class_type:
		Enums.PlayerClass.ASSASSIN: class_label.text = "Assassin"
		Enums.PlayerClass.TANK: class_label.text = "Tank"
		Enums.PlayerClass.MAGE: class_label.text = "Mage"
	hbox.add_child(class_label)
	
	# Ready status
	var ready_label = Label.new()
	var is_ready = data.get("is_ready", false)
	var is_host = data.get("peer_id", 0) == 1
	if is_host:
		ready_label.text = "HOST"
		ready_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	elif is_ready:
		ready_label.text = "READY"
		ready_label.add_theme_color_override("font_color", Color.GREEN)
	else:
		ready_label.text = "NOT READY"
		ready_label.add_theme_color_override("font_color", Color.RED)
	hbox.add_child(ready_label)
	
	return panel

func _create_empty_slot() -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 50)
	panel.modulate = Color(1, 1, 1, 0.3)
	
	var label = Label.new()
	label.text = "  -- Empty Slot --"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	
	return panel

# === Button Callbacks ===

func _on_start_pressed() -> void:
	NetworkManager.lobby_manager.start_game_as_host()

func _on_ready_pressed() -> void:
	_is_ready = !_is_ready
	NetworkManager.lobby_manager.set_ready(_is_ready)
	ready_button.text = "CANCEL READY" if _is_ready else "READY UP"

func _on_leave_pressed() -> void:
	NetworkManager.disconnect_from_game()
	# Return to main menu
	get_tree().change_scene_to_file("res://scenes/main/game_world.tscn")

func _on_class_selected(index: int) -> void:
	var class_type = class_option.get_item_id(index) as Enums.PlayerClass
	NetworkManager.lobby_manager.set_class(class_type)

# === Signal Callbacks ===

func _on_player_joined(_peer_id: int, _player_data: Dictionary) -> void:
	_update_ui()

func _on_player_left(_peer_id: int) -> void:
	_update_ui()

func _on_all_ready() -> void:
	start_button.disabled = false

func _on_lobby_updated(_lobby_data: Dictionary) -> void:
	_update_ui()

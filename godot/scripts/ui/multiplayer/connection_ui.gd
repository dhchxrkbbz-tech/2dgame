## ConnectionUI - "Connecting..." screen és host/join menü
extends Control

@onready var main_panel: PanelContainer = $MainPanel
@onready var host_button: Button = $MainPanel/MarginContainer/VBoxContainer/HostButton
@onready var join_button: Button = $MainPanel/MarginContainer/VBoxContainer/JoinButton
@onready var back_button: Button = $MainPanel/MarginContainer/VBoxContainer/BackButton

# Join panel
@onready var join_panel: PanelContainer = $JoinPanel
@onready var ip_input: LineEdit = $JoinPanel/MarginContainer/VBoxContainer/IPInput
@onready var port_input: LineEdit = $JoinPanel/MarginContainer/VBoxContainer/PortInput
@onready var name_input: LineEdit = $JoinPanel/MarginContainer/VBoxContainer/NameInput
@onready var connect_button: Button = $JoinPanel/MarginContainer/VBoxContainer/ConnectButton
@onready var cancel_button: Button = $JoinPanel/MarginContainer/VBoxContainer/CancelButton

# Host panel
@onready var host_panel: PanelContainer = $HostPanel
@onready var host_port_input: LineEdit = $HostPanel/MarginContainer/VBoxContainer/PortInput
@onready var host_name_input: LineEdit = $HostPanel/MarginContainer/VBoxContainer/NameInput
@onready var create_button: Button = $HostPanel/MarginContainer/VBoxContainer/CreateButton
@onready var host_cancel_button: Button = $HostPanel/MarginContainer/VBoxContainer/CancelButton

# Connecting overlay
@onready var connecting_overlay: PanelContainer = $ConnectingOverlay
@onready var connecting_label: Label = $ConnectingOverlay/MarginContainer/VBoxContainer/ConnectingLabel
@onready var connecting_cancel: Button = $ConnectingOverlay/MarginContainer/VBoxContainer/CancelButton

func _ready() -> void:
	_show_main_panel()
	_connect_signals()
	
	# Set defaults
	ip_input.text = "127.0.0.1"
	port_input.text = str(NetworkManager.DEFAULT_PORT)
	host_port_input.text = str(NetworkManager.DEFAULT_PORT)
	name_input.text = "Player"
	host_name_input.text = "Host"

func _connect_signals() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	back_button.pressed.connect(_on_back_pressed)
	connect_button.pressed.connect(_on_connect_pressed)
	cancel_button.pressed.connect(_show_main_panel)
	create_button.pressed.connect(_on_create_pressed)
	host_cancel_button.pressed.connect(_show_main_panel)
	connecting_cancel.pressed.connect(_on_connecting_cancel)
	
	NetworkManager.connection_state_changed.connect(_on_connection_state_changed)

func _show_main_panel() -> void:
	main_panel.visible = true
	join_panel.visible = false
	host_panel.visible = false
	connecting_overlay.visible = false

func _on_host_pressed() -> void:
	main_panel.visible = false
	host_panel.visible = true

func _on_join_pressed() -> void:
	main_panel.visible = false
	join_panel.visible = true

func _on_back_pressed() -> void:
	# Return to main menu
	hide()

func _on_connect_pressed() -> void:
	var ip = ip_input.text.strip_edges()
	var port = int(port_input.text.strip_edges())
	var player_name = name_input.text.strip_edges()
	
	if ip.is_empty():
		ip = "127.0.0.1"
	if port <= 0:
		port = NetworkManager.DEFAULT_PORT
	if player_name.is_empty():
		player_name = "Player"
	
	connecting_label.text = "Connecting to %s:%d..." % [ip, port]
	join_panel.visible = false
	connecting_overlay.visible = true
	
	var error = NetworkManager.join_game(ip, port, player_name)
	if error != OK:
		connecting_label.text = "Failed to connect: %s" % error_string(error)

func _on_create_pressed() -> void:
	var port = int(host_port_input.text.strip_edges())
	var host_name = host_name_input.text.strip_edges()
	
	if port <= 0:
		port = NetworkManager.DEFAULT_PORT
	if host_name.is_empty():
		host_name = "Host"
	
	var error = NetworkManager.host_game(port, host_name)
	if error != OK:
		connecting_label.text = "Failed to create server: %s" % error_string(error)
		connecting_overlay.visible = true
		return
	
	# Switch to lobby
	_switch_to_lobby()

func _on_connecting_cancel() -> void:
	NetworkManager.disconnect_from_game()
	_show_main_panel()

func _on_connection_state_changed(new_state: NetworkManager.ConnectionState) -> void:
	match new_state:
		NetworkManager.ConnectionState.CONNECTED:
			_switch_to_lobby()
		NetworkManager.ConnectionState.DISCONNECTED:
			_show_main_panel()
		NetworkManager.ConnectionState.CONNECTING:
			connecting_overlay.visible = true

func _switch_to_lobby() -> void:
	# Hide connection UI, show lobby UI
	hide()
	# The lobby scene should be instantiated or switched to
	var lobby_scene = preload("res://scenes/ui/lobby_ui.tscn")
	var lobby = lobby_scene.instantiate()
	get_tree().current_scene.add_child(lobby)

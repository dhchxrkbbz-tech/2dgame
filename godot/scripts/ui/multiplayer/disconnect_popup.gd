## DisconnectPopup - Disconnection és reconnect overlay
extends Control

@onready var panel: PanelContainer = $PanelContainer
@onready var title_label: Label = $PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var message_label: Label = $PanelContainer/MarginContainer/VBoxContainer/MessageLabel
@onready var reconnect_button: Button = $PanelContainer/MarginContainer/VBoxContainer/ReconnectButton
@onready var quit_button: Button = $PanelContainer/MarginContainer/VBoxContainer/QuitButton
@onready var progress_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ProgressLabel

var _reconnect_handler: Node

func _ready() -> void:
	visible = false
	reconnect_button.pressed.connect(_on_reconnect_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	NetworkManager.connection_state_changed.connect(_on_connection_state_changed)

func show_disconnect(reason: String = "Connection lost") -> void:
	title_label.text = "DISCONNECTED"
	message_label.text = reason
	progress_label.text = ""
	reconnect_button.visible = true
	visible = true

func show_reconnecting(attempt: int, max_attempts: int) -> void:
	title_label.text = "RECONNECTING"
	message_label.text = "Attempting to reconnect..."
	progress_label.text = "Attempt %d / %d" % [attempt, max_attempts]
	reconnect_button.visible = false
	visible = true

func _on_reconnect_pressed() -> void:
	var conn_info = NetworkManager.connection_manager.get_connection_info()
	var ip = conn_info.get("ip", "127.0.0.1")
	var port = conn_info.get("port", NetworkManager.DEFAULT_PORT)
	
	message_label.text = "Reconnecting..."
	reconnect_button.visible = false
	
	NetworkManager.connection_manager.attempt_reconnect()

func _on_quit_pressed() -> void:
	NetworkManager.disconnect_from_game()
	visible = false
	get_tree().change_scene_to_file("res://scenes/main/game_world.tscn")

func _on_connection_state_changed(new_state: NetworkManager.ConnectionState) -> void:
	match new_state:
		NetworkManager.ConnectionState.CONNECTED:
			visible = false
		NetworkManager.ConnectionState.DISCONNECTED:
			if not visible:
				show_disconnect()

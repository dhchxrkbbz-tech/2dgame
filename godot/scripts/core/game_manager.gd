## GameManager - Fő játék vezérlés (Autoload singleton)
## Felelős: játék állapot kezelés, pause, FPS, quit
extends Node

var current_state: Enums.GameState = Enums.GameState.MENU
var previous_state: Enums.GameState = Enums.GameState.MENU

# Referenciák
var player: CharacterBody2D = null
var game_world: Node2D = null

# Debug
var debug_mode: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS  # Pause alatt is fut
	# Engine.max_fps = 60  # Opcionális FPS limit


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
	if event.is_action_pressed("toggle_debug") and OS.is_debug_build():
		debug_mode = !debug_mode


func change_state(new_state: Enums.GameState) -> void:
	if new_state == current_state:
		return
	previous_state = current_state
	current_state = new_state
	
	match new_state:
		Enums.GameState.MENU:
			get_tree().paused = false
		Enums.GameState.LOADING:
			pass
		Enums.GameState.PLAYING:
			get_tree().paused = false
		Enums.GameState.PAUSED:
			get_tree().paused = true
		Enums.GameState.GAME_OVER:
			get_tree().paused = true


func toggle_pause() -> void:
	if current_state == Enums.GameState.PLAYING:
		change_state(Enums.GameState.PAUSED)
	elif current_state == Enums.GameState.PAUSED:
		change_state(Enums.GameState.PLAYING)


func start_game() -> void:
	change_state(Enums.GameState.PLAYING)


func game_over() -> void:
	change_state(Enums.GameState.GAME_OVER)


func return_to_menu() -> void:
	change_state(Enums.GameState.MENU)


func quit_game() -> void:
	# TODO: Autosave before quit
	get_tree().quit()


func is_playing() -> bool:
	return current_state == Enums.GameState.PLAYING


func is_paused() -> bool:
	return current_state == Enums.GameState.PAUSED


func register_player(p: CharacterBody2D) -> void:
	player = p
	EventBus.player_spawned.emit(p)


func register_game_world(world: Node2D) -> void:
	game_world = world

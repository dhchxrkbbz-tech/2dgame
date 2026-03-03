## SceneManager - Scene váltás kezelés (Autoload singleton)
## Fade transition-ökkel, async loading support
extends Node

signal scene_change_started()
signal scene_change_completed()

var _current_scene_path: String = ""
var _is_loading: bool = false

# Transition overlay (runtime-ban létrehozzuk)
var _transition_layer: CanvasLayer
var _transition_rect: ColorRect
var _transition_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_transition_overlay()


func _setup_transition_overlay() -> void:
	_transition_layer = CanvasLayer.new()
	_transition_layer.layer = 100  # Legfelső réteg
	add_child(_transition_layer)
	
	_transition_rect = ColorRect.new()
	_transition_rect.color = Color(0, 0, 0, 0)
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_transition_layer.add_child(_transition_rect)


func change_scene(scene_path: String, transition: Enums.TransitionType = Enums.TransitionType.FADE) -> void:
	if _is_loading:
		return
	
	_is_loading = true
	scene_change_started.emit()
	
	match transition:
		Enums.TransitionType.FADE:
			await _fade_out(0.3)
			_load_scene(scene_path)
			await _fade_in(0.3)
		Enums.TransitionType.NONE:
			_load_scene(scene_path)
	
	_is_loading = false
	scene_change_completed.emit()


func _load_scene(scene_path: String) -> void:
	_current_scene_path = scene_path
	get_tree().change_scene_to_file(scene_path)


func _fade_out(duration: float) -> void:
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	if _transition_tween:
		_transition_tween.kill()
	_transition_tween = create_tween()
	_transition_tween.tween_property(_transition_rect, "color:a", 1.0, duration)
	await _transition_tween.finished


func _fade_in(duration: float) -> void:
	if _transition_tween:
		_transition_tween.kill()
	_transition_tween = create_tween()
	_transition_tween.tween_property(_transition_rect, "color:a", 0.0, duration)
	await _transition_tween.finished
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func get_current_scene_path() -> String:
	return _current_scene_path

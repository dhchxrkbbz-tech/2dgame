## PlayerCamera - Stardew Valley stílusú kamera
## Smooth follow, zoom, screen shake
extends Camera2D

# === Beállítások ===
@export var follow_speed: float = 5.0
@export var default_zoom: Vector2 = Vector2(2, 2)
@export var min_zoom: Vector2 = Vector2(1, 1)
@export var max_zoom: Vector2 = Vector2(4, 4)

# Screen shake
var _shake_intensity: float = 0.0
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0

# Target
var _target: Node2D = null


func _ready() -> void:
	zoom = default_zoom
	position_smoothing_enabled = true
	position_smoothing_speed = follow_speed


func _process(delta: float) -> void:
	# Screen shake
	if _shake_timer > 0:
		_shake_timer -= delta
		var shake_offset := Vector2(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity)
		)
		offset = shake_offset
		
		# Fokozatosan csökken
		_shake_intensity = lerp(_shake_intensity, 0.0, delta * 5.0)
		
		if _shake_timer <= 0:
			offset = Vector2.ZERO
			_shake_intensity = 0.0


func follow_target(target: Node2D) -> void:
	_target = target
	# Kamera a player child-jaként van, ami automatikus follow-t ad


func shake(intensity: float = 4.0, duration: float = 0.3) -> void:
	## Screen shake effect (hit, robbanás stb.)
	_shake_intensity = intensity
	_shake_duration = duration
	_shake_timer = duration


func zoom_to(target_zoom: Vector2, duration: float = 0.5) -> void:
	var tween := create_tween()
	tween.tween_property(self, "zoom", target_zoom.clamp(min_zoom, max_zoom), duration)


func reset_zoom(duration: float = 0.3) -> void:
	zoom_to(default_zoom, duration)

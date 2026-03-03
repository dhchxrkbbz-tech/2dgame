## NotificationUI - Pop-up értesítés rendszer
## Item drop, level up, achievement, rendszer üzenetek
class_name NotificationUI
extends CanvasLayer

# === Beállítások ===
const MAX_NOTIFICATIONS: int = 5
const NOTIFICATION_DURATION: float = 3.0
const FADE_DURATION: float = 0.5
const SLIDE_DISTANCE: float = 30.0
const NOTIFICATION_HEIGHT: float = 30.0
const NOTIFICATION_SPACING: float = 5.0

# === Típus színek ===
const TYPE_COLORS: Dictionary = {
	"info": Color(0.7, 0.7, 0.7),
	"success": Color(0.3, 0.9, 0.3),
	"warning": Color(0.9, 0.8, 0.2),
	"error": Color(0.9, 0.2, 0.2),
	"loot": Color(0.9, 0.7, 0.1),
	"level_up": Color(0.9, 0.8, 0.2),
	"achievement": Color(0.8, 0.4, 0.9),
}

# === Aktív értesítések ===
var notifications: Array[Dictionary] = []  # {label, timer, type, fading}
var container: VBoxContainer = null


func _ready() -> void:
	layer = 90
	_build_ui()
	
	# EventBus csatlakozások
	if EventBus.has_signal("notification_requested"):
		EventBus.notification_requested.connect(show_notification)


func _build_ui() -> void:
	container = VBoxContainer.new()
	container.position = Vector2(160, 20)  # Felső közép
	container.size = Vector2(320, 200)
	container.add_theme_constant_override("separation", int(NOTIFICATION_SPACING))
	add_child(container)


func _process(delta: float) -> void:
	var to_remove: Array[int] = []
	
	for i in range(notifications.size()):
		var notif: Dictionary = notifications[i]
		notif["timer"] -= delta
		
		var label: Label = notif["label"]
		
		if notif["timer"] <= FADE_DURATION:
			# Fade out
			notif["fading"] = true
			var alpha := maxf(0.0, notif["timer"] / FADE_DURATION)
			label.modulate.a = alpha
		
		if notif["timer"] <= 0.0:
			to_remove.append(i)
	
	# Eltávolítás (fordított sorrendben)
	for i in range(to_remove.size() - 1, -1, -1):
		var idx := to_remove[i]
		var label: Label = notifications[idx]["label"]
		label.queue_free()
		notifications.remove_at(idx)


## Értesítés megjelenítése
func show_notification(message: String, type: String = "info") -> void:
	# Max limit
	if notifications.size() >= MAX_NOTIFICATIONS:
		var oldest: Dictionary = notifications[0]
		oldest["label"].queue_free()
		notifications.remove_at(0)
	
	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", TYPE_COLORS.get(type, Color.WHITE))
	
	# Háttér
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.05, 0.05, 0.1, 0.8)
	stylebox.set_corner_radius_all(3)
	stylebox.content_margin_left = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 4
	stylebox.content_margin_bottom = 4
	label.add_theme_stylebox_override("normal", stylebox)
	
	container.add_child(label)
	
	notifications.append({
		"label": label,
		"timer": NOTIFICATION_DURATION,
		"type": type,
		"fading": false,
	})


## Specifikus notification típusok
func show_loot_notification(item_name: String, rarity_color: Color) -> void:
	var label := Label.new()
	label.text = "Loot: " + item_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", rarity_color)
	
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = Color(0.1, 0.08, 0.02, 0.85)
	stylebox.border_color = rarity_color * 0.5
	stylebox.set_border_width_all(1)
	stylebox.set_corner_radius_all(3)
	stylebox.content_margin_left = 10
	stylebox.content_margin_right = 10
	stylebox.content_margin_top = 4
	stylebox.content_margin_bottom = 4
	label.add_theme_stylebox_override("normal", stylebox)
	
	container.add_child(label)
	
	if notifications.size() >= MAX_NOTIFICATIONS:
		var oldest: Dictionary = notifications[0]
		oldest["label"].queue_free()
		notifications.remove_at(0)
	
	notifications.append({
		"label": label,
		"timer": NOTIFICATION_DURATION + 1.0,
		"type": "loot",
		"fading": false,
	})


func show_level_up(new_level: int) -> void:
	show_notification("LEVEL UP! → Level %d" % new_level, "level_up")


func show_achievement(achievement_name: String) -> void:
	show_notification("Achievement: %s" % achievement_name, "achievement")

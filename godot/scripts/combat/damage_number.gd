## DamageNumber - Lebegő sebzés szám megjelenítés
## Felemelkedik és elhalványul
extends Node2D
class_name DamageNumber

var amount: int = 0
var is_crit: bool = false
var damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL

@onready var label: Label


func _ready() -> void:
	# Label létrehozása
	label = Label.new()
	label.text = str(amount)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12 if not is_crit else 16)
	
	# Szín a damage type alapján
	label.add_theme_color_override("font_color", _get_color())
	
	# Outline
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	
	add_child(label)
	
	# Animáció
	var tween := create_tween()
	tween.set_parallel(true)
	
	# Felfelé mozgás + random X offset
	var offset_x := randf_range(-20, 20)
	tween.tween_property(self, "position:y", position.y - Constants.DAMAGE_NUMBER_RISE, Constants.DAMAGE_NUMBER_DURATION)
	tween.tween_property(self, "position:x", position.x + offset_x, Constants.DAMAGE_NUMBER_DURATION)
	
	# Elhalványulás
	tween.tween_property(self, "modulate:a", 0.0, Constants.DAMAGE_NUMBER_DURATION).set_delay(0.2)
	
	# Crit-nél nagyobb és pulzáló
	if is_crit:
		label.text = str(amount) + "!"
		tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_delay(0.1)
	
	# Törlés
	tween.chain().tween_callback(queue_free)


func _get_color() -> Color:
	if is_crit:
		return Color(1.0, 0.9, 0.0)  # Arany
	
	match damage_type:
		Enums.DamageType.PHYSICAL:
			return Color.WHITE
		Enums.DamageType.ARCANE:
			return Color(0.6, 0.2, 1.0)
		Enums.DamageType.FROST:
			return Color(0.4, 0.8, 1.0)
		Enums.DamageType.HOLY:
			return Color(1.0, 1.0, 0.5)
		Enums.DamageType.POISON:
			return Color(0.2, 0.9, 0.2)
		Enums.DamageType.BLOOD:
			return Color(0.8, 0.1, 0.1)
		Enums.DamageType.SHADOW:
			return Color(0.5, 0.0, 0.5)
		_:
			return Color.WHITE


static func spawn(parent: Node, pos: Vector2, dmg: int, crit: bool = false, dtype: Enums.DamageType = Enums.DamageType.PHYSICAL) -> void:
	var num := DamageNumber.new()
	num.amount = dmg
	num.is_crit = crit
	num.damage_type = dtype
	num.global_position = pos + Vector2(0, -20)
	parent.add_child(num)

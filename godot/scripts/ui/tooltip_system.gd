## TooltipSystem - Tooltip megjelenítő rendszer
## Item, skill, buff tooltip-ek kezelése
class_name TooltipSystem
extends CanvasLayer

var tooltip_panel: PanelContainer = null
var tooltip_label: RichTextLabel = null
var is_showing: bool = false
var follow_mouse: bool = true

const TOOLTIP_MAX_WIDTH: float = 300.0
const TOOLTIP_OFFSET: Vector2 = Vector2(15, 15)
const FADE_SPEED: float = 8.0

var target_alpha: float = 0.0
var current_alpha: float = 0.0


func _ready() -> void:
	layer = 100
	_build_tooltip()


func _build_tooltip() -> void:
	tooltip_panel = PanelContainer.new()
	tooltip_panel.visible = false
	tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Stylebox
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.border_color = Color(0.4, 0.4, 0.5)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 8.0
	style.content_margin_right = 8.0
	style.content_margin_top = 6.0
	style.content_margin_bottom = 6.0
	tooltip_panel.add_theme_stylebox_override("panel", style)
	
	tooltip_label = RichTextLabel.new()
	tooltip_label.bbcode_enabled = true
	tooltip_label.fit_content = true
	tooltip_label.custom_minimum_size = Vector2(0, 0)
	tooltip_label.size = Vector2(TOOLTIP_MAX_WIDTH, 0)
	tooltip_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tooltip_panel.add_child(tooltip_label)
	
	add_child(tooltip_panel)


func _process(delta: float) -> void:
	# Fade in/out
	current_alpha = lerpf(current_alpha, target_alpha, FADE_SPEED * delta)
	if tooltip_panel:
		tooltip_panel.modulate.a = current_alpha
		tooltip_panel.visible = current_alpha > 0.01
	
	# Egeret követi
	if follow_mouse and is_showing:
		_update_position()


func _update_position() -> void:
	if not tooltip_panel:
		return
	
	var mouse_pos := get_viewport().get_mouse_position()
	var screen_size := get_viewport().get_visible_rect().size
	var panel_size := tooltip_panel.size
	
	var pos := mouse_pos + TOOLTIP_OFFSET
	
	# Képernyő szélén belül tartás
	if pos.x + panel_size.x > screen_size.x:
		pos.x = mouse_pos.x - panel_size.x - 5
	if pos.y + panel_size.y > screen_size.y:
		pos.y = mouse_pos.y - panel_size.y - 5
	
	tooltip_panel.position = pos


## === ITEM TOOLTIP ===
func show_item_tooltip(item: Dictionary) -> void:
	var text := _build_item_tooltip(item)
	_show_tooltip(text)


func _build_item_tooltip(item: Dictionary) -> String:
	var rarity: int = item.get("rarity", 0)
	var rarity_color: Color = Constants.RARITY_COLORS.get(rarity, Color.WHITE)
	var rarity_name: String = Rarity.get_name(rarity) if rarity is Enums.Rarity else "Common"
	var color_hex := rarity_color.to_html(false)
	
	var text := "[b][color=#%s]%s[/color][/b]\n" % [color_hex, item.get("name", "Item")]
	text += "[color=#%s]%s[/color]\n" % [color_hex, rarity_name]
	text += "[color=gray]Item Level: %d[/color]\n\n" % item.get("item_level", 1)
	
	# Base stats
	if item.get("base_damage", 0) > 0:
		text += "[color=white]Damage: %d[/color]\n" % item["base_damage"]
	if item.get("base_armor", 0) > 0:
		text += "[color=white]Armor: %d[/color]\n" % item["base_armor"]
	
	# Affixes
	var affixes: Array = item.get("affixes", [])
	if affixes.size() > 0:
		text += "\n"
		for affix in affixes:
			var color := "#4488ff" if affix.get("is_prefix", true) else "#44ff88"
			text += "[color=%s]+%.1f %s[/color]\n" % [color, affix.get("value", 0), affix.get("type", "").replace("_", " ").capitalize()]
	
	# Sockets
	var sockets: int = item.get("socket_count", 0)
	if sockets > 0:
		text += "\n[color=gray]Sockets: %d[/color]\n" % sockets
	
	# Requirements
	var req_level: int = item.get("required_level", 0)
	if req_level > 0:
		text += "\n[color=gray]Required Level: %d[/color]" % req_level
	
	return text


## === SKILL TOOLTIP ===
func show_skill_tooltip(skill: Dictionary) -> void:
	var text := _build_skill_tooltip(skill)
	_show_tooltip(text)


func _build_skill_tooltip(skill: Dictionary) -> String:
	var text := "[b]%s[/b]\n" % skill.get("name", "Skill")
	text += "[color=gray]%s[/color]\n\n" % skill.get("description", "")
	
	if skill.has("damage_multiplier"):
		text += "Damage: [color=yellow]%d%%[/color]\n" % int(skill["damage_multiplier"] * 100)
	if skill.has("cooldown"):
		text += "Cooldown: [color=cyan]%.1fs[/color]\n" % skill["cooldown"]
	if skill.has("mana_cost"):
		text += "Mana Cost: [color=#4488ff]%d[/color]\n" % skill["mana_cost"]
	
	return text


## === STATUS EFFECT TOOLTIP ===
func show_status_tooltip(status: Dictionary) -> void:
	var text := "[b]%s[/b]\n" % status.get("name", "Effect")
	text += "%s\n" % status.get("description", "")
	if status.has("remaining_time"):
		text += "[color=gray]%.1fs remaining[/color]" % status["remaining_time"]
	_show_tooltip(text)


## === GENERIC TOOLTIP ===
func show_text_tooltip(text: String) -> void:
	_show_tooltip(text)


## Tooltip megjelenítése
func _show_tooltip(bbcode_text: String) -> void:
	if tooltip_label:
		tooltip_label.text = bbcode_text
	is_showing = true
	target_alpha = 1.0
	_update_position()


## Tooltip elrejtése
func hide_tooltip() -> void:
	is_showing = false
	target_alpha = 0.0

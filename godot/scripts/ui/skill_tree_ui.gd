## SkillTreeUI - Skill tree megjelenítés és kezelés
## Három branch vizualizáció, pont allokáció, tooltip-ek
class_name SkillTreeUI
extends Control

signal skill_allocated(skill_id: String)
signal skill_tree_closed()

# === Referenciák ===
var skill_tree: SkillTree = null
var skill_manager: SkillManager = null
var player_class: String = ""

# === Layout beállítások ===
const BRANCH_SPACING: float = 200.0
const SKILL_SPACING_Y: float = 80.0
const SKILL_ICON_SIZE: float = 48.0
const BRANCH_COLORS: Dictionary = {
	0: Color(0.8, 0.2, 0.2),  # Branch 1
	1: Color(0.2, 0.8, 0.2),  # Branch 2
	2: Color(0.2, 0.4, 0.9),  # Branch 3
}

# === UI elemek ===
var branch_containers: Array[Control] = []
var skill_buttons: Dictionary = {}  # skill_id -> Button
var tooltip_panel: PanelContainer = null
var points_label: Label = null
var close_button: Button = null

# Available skill points
var available_points: int = 0

# Hover állapot
var hovered_skill_id: String = ""


func _ready() -> void:
	visible = false
	_build_ui()


func _build_ui() -> void:
	# Háttér panel
	var bg := ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 0.9)
	bg.set_anchors_preset(PRESET_FULL_RECT)
	add_child(bg)
	
	# Cím
	var title := Label.new()
	title.text = "SKILL TREE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(0, 10)
	title.size = Vector2(640, 30)
	add_child(title)
	
	# Pont kijelző
	points_label = Label.new()
	points_label.text = "Available Points: 0"
	points_label.position = Vector2(10, 40)
	add_child(points_label)
	
	# Branch container-ek (3 darab)
	for i in range(3):
		var container := Control.new()
		container.position = Vector2(80 + i * BRANCH_SPACING, 80)
		container.custom_minimum_size = Vector2(BRANCH_SPACING - 20, 400)
		add_child(container)
		branch_containers.append(container)
	
	# Bezárás gomb
	close_button = Button.new()
	close_button.text = "X"
	close_button.position = Vector2(600, 10)
	close_button.size = Vector2(30, 30)
	close_button.pressed.connect(_on_close_pressed)
	add_child(close_button)
	
	# Tooltip panel
	tooltip_panel = PanelContainer.new()
	tooltip_panel.visible = false
	tooltip_panel.z_index = 100
	add_child(tooltip_panel)


## Skill tree megnyitása
func open(p_skill_tree: SkillTree, p_skill_manager: SkillManager, p_class: String, points: int) -> void:
	skill_tree = p_skill_tree
	skill_manager = p_skill_manager
	player_class = p_class
	available_points = points
	visible = true
	_refresh_skills()
	get_tree().paused = false  # UI nem pauseolja a játékot


func close() -> void:
	visible = false
	skill_tree_closed.emit()


## Skill gombok frissítése
func _refresh_skills() -> void:
	# Korábbi gombok törlése
	for btn_id in skill_buttons:
		if is_instance_valid(skill_buttons[btn_id]):
			skill_buttons[btn_id].queue_free()
	skill_buttons.clear()
	
	if not skill_tree:
		return
	
	# Branch-ek feldolgozása
	for branch_idx in range(3):
		if branch_idx >= branch_containers.size():
			break
		var container := branch_containers[branch_idx]
		var branch_skills: Array = skill_tree.get_branch_skills(branch_idx)
		
		# Branch név
		var branch_label := Label.new()
		branch_label.text = skill_tree.get_branch_name(branch_idx)
		branch_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		branch_label.size = Vector2(BRANCH_SPACING - 20, 20)
		branch_label.add_theme_color_override("font_color", BRANCH_COLORS.get(branch_idx, Color.WHITE))
		container.add_child(branch_label)
		
		# Skill-ek
		for skill_idx in range(branch_skills.size()):
			var skill: Dictionary = branch_skills[skill_idx]
			var btn := _create_skill_button(skill, branch_idx, skill_idx)
			container.add_child(btn)
			skill_buttons[skill["id"]] = btn
	
	_update_points_display()


func _create_skill_button(skill: Dictionary, branch_idx: int, skill_idx: int) -> Button:
	var btn := Button.new()
	btn.text = skill.get("name", "Skill")
	btn.position = Vector2(10, 30 + skill_idx * SKILL_SPACING_Y)
	btn.size = Vector2(SKILL_ICON_SIZE * 3, SKILL_ICON_SIZE)
	btn.tooltip_text = _build_tooltip(skill)
	
	var skill_id: String = skill.get("id", "")
	var current_rank: int = skill_tree.get_skill_rank(skill_id) if skill_tree else 0
	var max_rank: int = skill.get("max_rank", 5)
	var can_allocate: bool = skill_tree.can_allocate(skill_id) if skill_tree else false
	
	# Szín beállítás
	if current_rank >= max_rank:
		btn.modulate = Color(0.9, 0.8, 0.2)  # Maxolt
	elif current_rank > 0:
		btn.modulate = BRANCH_COLORS.get(branch_idx, Color.WHITE)  # Részben kitanult
	elif can_allocate and available_points > 0:
		btn.modulate = Color.WHITE  # Elérhető
	else:
		btn.modulate = Color(0.4, 0.4, 0.4)  # Locked
	
	# Rank kijelzés
	btn.text = "%s [%d/%d]" % [skill.get("name", "?"), current_rank, max_rank]
	
	btn.pressed.connect(_on_skill_pressed.bind(skill_id))
	btn.mouse_entered.connect(_on_skill_hovered.bind(skill_id))
	btn.mouse_exited.connect(_on_skill_unhovered)
	
	return btn


func _on_skill_pressed(skill_id: String) -> void:
	if not skill_tree or available_points <= 0:
		return
	
	if skill_tree.allocate_point(skill_id):
		available_points -= 1
		skill_allocated.emit(skill_id)
		_refresh_skills()


func _on_skill_hovered(skill_id: String) -> void:
	hovered_skill_id = skill_id
	# Tooltip megjelenítése
	tooltip_panel.visible = true
	tooltip_panel.position = get_viewport().get_mouse_position() + Vector2(15, 15)


func _on_skill_unhovered() -> void:
	hovered_skill_id = ""
	tooltip_panel.visible = false


func _build_tooltip(skill: Dictionary) -> String:
	var text := skill.get("name", "Skill") + "\n"
	text += skill.get("description", "") + "\n"
	text += "Type: %s\n" % skill.get("type", "passive")
	if skill.has("cooldown"):
		text += "Cooldown: %.1fs\n" % skill["cooldown"]
	if skill.has("mana_cost"):
		text += "Mana Cost: %d\n" % skill["mana_cost"]
	if skill.has("damage_multiplier"):
		text += "Damage: %d%%\n" % int(skill["damage_multiplier"] * 100)
	return text


func _update_points_display() -> void:
	if points_label:
		points_label.text = "Available Points: %d" % available_points


func _on_close_pressed() -> void:
	close()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()

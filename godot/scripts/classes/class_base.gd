## ClassBase - Alap class logika
## A 3 játékos osztály (Assassin, Tank, Mage) ebből származik
class_name ClassBase
extends RefCounted

var player_class: Enums.PlayerClass
var player: CharacterBody2D

# === Skill rendszer ===
var skill_manager: SkillManager
var ultimate_manager: UltimateManager

# === Base stat-ok ===
var base_stats: Dictionary = {}

# === Branch nevek ===
var branches: Array[Enums.SkillBranch] = []
var branch_names: Dictionary = {}


func _init(p_class: Enums.PlayerClass, p_player: CharacterBody2D) -> void:
	player_class = p_class
	player = p_player
	base_stats = Constants.CLASS_BASE_STATS.get(player_class, {})
	_setup_branches()
	skill_manager = SkillManager.new(self)
	ultimate_manager = UltimateManager.new(self)


func _setup_branches() -> void:
	# Override a subclass-okban
	pass


## Osztály-specifikus passive bonus
func get_passive_bonus() -> Dictionary:
	return {}


## Osztály-specifikus stat módosítók
func get_stat_modifiers() -> Dictionary:
	return base_stats.duplicate()


## Skill használata
func use_skill(skill_index: int) -> bool:
	if skill_index < 0 or skill_index > 3:
		return false
	return skill_manager.use_skill(skill_index)


## Ultimate használata
func use_ultimate() -> bool:
	return ultimate_manager.use_ultimate()


## Update (minden frame)
func update(delta: float) -> void:
	if skill_manager:
		skill_manager.update(delta)
	if ultimate_manager:
		ultimate_manager.update(delta)


## Mana regen rate
func get_mana_regen() -> float:
	match player_class:
		Enums.PlayerClass.ASSASSIN:
			return Constants.BASE_MANA_REGEN_ASSASSIN
		Enums.PlayerClass.TANK:
			return Constants.BASE_MANA_REGEN_TANK
		Enums.PlayerClass.MAGE:
			return Constants.BASE_MANA_REGEN_MAGE
	return 1.0

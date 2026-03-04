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


## Összes branch passive bonus összegyűjtése (Plan 21 §5.2)
func get_all_branch_passives() -> Dictionary:
	var total_bonuses: Dictionary = {}
	for branch in branches:
		var points: int = 0
		if skill_manager:
			points = skill_manager.get_branch_points(branch)
		if points > 0:
			var bonuses: Dictionary = get_branch_bonus(branch, points)
			for key in bonuses:
				total_bonuses[key] = total_bonuses.get(key, 0.0) + bonuses[key]
	return total_bonuses


## Branch-specifikus bonus (override a subclass-okban)
func get_branch_bonus(_branch: Enums.SkillBranch, _allocated_points: int) -> Dictionary:
	# Fallback: constants-ból olvas
	var passives: Dictionary = Constants.BRANCH_PASSIVES.get(_branch, {})
	var result: Dictionary = {}
	for key in passives:
		result[key] = passives[key] * _allocated_points
	return result


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

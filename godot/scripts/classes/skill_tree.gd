## SkillTree - Skill tree logika és pont kezelés
## Kezeli a 3 branch × (4 skill + 1 ultimate) struktúrát
class_name SkillTree
extends RefCounted

signal skill_unlocked(skill_id: String, rank: int)
signal skill_tree_changed()

var class_ref: ClassBase
var player_class: Enums.PlayerClass

# === Skill adatok branch-enként ===
# branch → Array[SkillData]
var branch_skills: Dictionary = {}

# === Allokált pontok ===
var allocated: Dictionary = {}  # skill_id → rank


func _init(p_class: ClassBase) -> void:
	class_ref = p_class
	player_class = p_class.player_class
	_load_skill_data()


## Skill data betöltés a class branch-ekhez
func _load_skill_data() -> void:
	for branch in class_ref.branches:
		branch_skills[branch] = []
		var branch_name: String = _get_branch_resource_name(branch)
		var path := "res://data/skills/%s.tres" % branch_name
		if ResourceLoader.exists(path):
			var resource: Resource = ResourceLoader.load(path)
			if resource and resource.has_method("get_skills"):
				branch_skills[branch] = resource.get_skills()
		else:
			# Fallback: SkillDatabase-ból tölti be (Plan 21 FIX #2)
			branch_skills[branch] = SkillDatabase.get_skills_for_branch(branch)


func _get_branch_resource_name(branch: Enums.SkillBranch) -> String:
	match branch:
		Enums.SkillBranch.SHADOW: return "assassin_shadow"
		Enums.SkillBranch.POISON: return "assassin_poison"
		Enums.SkillBranch.BLOOD: return "assassin_blood"
		Enums.SkillBranch.GUARDIAN: return "tank_guardian"
		Enums.SkillBranch.WARBRINGER: return "tank_warbringer"
		Enums.SkillBranch.PALADIN: return "tank_paladin"
		Enums.SkillBranch.ARCANE: return "mage_arcane"
		Enums.SkillBranch.FROST: return "mage_frost"
		Enums.SkillBranch.HOLY: return "mage_holy"
	return ""


## Skill pont allokálás
func allocate_point(skill_id: String) -> bool:
	var skill: SkillData = find_skill(skill_id)
	if not skill:
		return false
	
	if not class_ref.skill_manager:
		return false
	
	if class_ref.skill_manager.available_skill_points <= 0:
		return false
	
	var current_rank: int = allocated.get(skill_id, 0)
	if current_rank >= skill.max_rank:
		return false
	
	# Prereq check
	if not skill.is_unlockable(allocated):
		return false
	
	# Ultimate check: 4 skill kell rank >= 1
	if skill.is_ultimate:
		var branch_met := _check_ultimate_prereqs(skill.branch)
		if not branch_met:
			return false
	
	allocated[skill_id] = current_rank + 1
	class_ref.skill_manager.available_skill_points -= 1
	class_ref.skill_manager.allocated_skills = allocated.duplicate()
	
	skill_unlocked.emit(skill_id, current_rank + 1)
	skill_tree_changed.emit()
	EventBus.skill_point_allocated.emit(skill_id, current_rank + 1)
	
	return true


## Ultimate prereq: minden branch skill >= rank 1
func _check_ultimate_prereqs(branch: Enums.SkillBranch) -> bool:
	var skills: Array = branch_skills.get(branch, [])
	for skill in skills:
		if skill is SkillData and not skill.is_ultimate:
			if allocated.get(skill.skill_id, 0) < 1:
				return false
	return true


## Skill keresés ID alapján
func find_skill(skill_id: String) -> SkillData:
	for branch in branch_skills:
		for skill in branch_skills[branch]:
			if skill is SkillData and skill.skill_id == skill_id:
				return skill
	# Fallback: SkillDatabase
	return SkillDatabase.get_skill(skill_id)


## Branch-ben allokált pontok
func get_branch_allocated_points(branch: Enums.SkillBranch) -> int:
	var total: int = 0
	var skills: Array = branch_skills.get(branch, [])
	for skill in skills:
		if skill is SkillData:
			total += allocated.get(skill.skill_id, 0)
	return total


## Összes allokált pont
func get_total_allocated_points() -> int:
	var total: int = 0
	for skill_id in allocated:
		total += allocated[skill_id]
	return total


## Skill rank lekérdezés
func get_skill_rank(skill_id: String) -> int:
	return allocated.get(skill_id, 0)


## Skill tree reset
func reset() -> void:
	var refunded: int = get_total_allocated_points()
	allocated.clear()
	class_ref.skill_manager.available_skill_points += refunded
	class_ref.skill_manager.allocated_skills.clear()
	skill_tree_changed.emit()


## Serialize
func serialize() -> Dictionary:
	return {
		"allocated": allocated.duplicate(),
		"player_class": player_class,
	}


## Deserialize
func deserialize(data: Dictionary) -> void:
	allocated = data.get("allocated", {})
	if class_ref.skill_manager:
		class_ref.skill_manager.allocated_skills = allocated.duplicate()

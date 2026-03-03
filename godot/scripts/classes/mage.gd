## Mage - Mágus/Gyógyító osztály
## Branch-ek: Arcane, Frost, Holy
class_name MageClass
extends ClassBase


func _init(p_player: CharacterBody2D) -> void:
	super._init(Enums.PlayerClass.MAGE, p_player)


func _setup_branches() -> void:
	branches = [
		Enums.SkillBranch.ARCANE,
		Enums.SkillBranch.FROST,
		Enums.SkillBranch.HOLY,
	]
	branch_names = {
		Enums.SkillBranch.ARCANE: "Arcane",
		Enums.SkillBranch.FROST: "Frost",
		Enums.SkillBranch.HOLY: "Holy",
	}


func get_passive_bonus() -> Dictionary:
	return {
		"spell_crit": base_stats.get("spell_crit", 0.06),
		"mana_regen": base_stats.get("mana_regen", 3.0),
	}


func get_branch_bonus(branch: Enums.SkillBranch, allocated_points: int) -> Dictionary:
	match branch:
		Enums.SkillBranch.ARCANE:
			return {
				"spell_damage_bonus": allocated_points * 0.03,
				"mana_cost_reduction": allocated_points * 0.01,
			}
		Enums.SkillBranch.FROST:
			return {
				"slow_effectiveness": allocated_points * 0.02,
				"freeze_duration_bonus": allocated_points * 0.01,
			}
		Enums.SkillBranch.HOLY:
			return {
				"heal_power_bonus": allocated_points * 0.03,
				"shield_strength_bonus": allocated_points * 0.02,
			}
	return {}

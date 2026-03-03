## Tank - Harcos/Védekező osztály
## Branch-ek: Guardian, Warbringer, Paladin
class_name TankClass
extends ClassBase


func _init(p_player: CharacterBody2D) -> void:
	super._init(Enums.PlayerClass.TANK, p_player)


func _setup_branches() -> void:
	branches = [
		Enums.SkillBranch.GUARDIAN,
		Enums.SkillBranch.WARBRINGER,
		Enums.SkillBranch.PALADIN,
	]
	branch_names = {
		Enums.SkillBranch.GUARDIAN: "Guardian",
		Enums.SkillBranch.WARBRINGER: "Warbringer",
		Enums.SkillBranch.PALADIN: "Paladin",
	}


func get_passive_bonus() -> Dictionary:
	return {
		"block_chance": base_stats.get("block_chance", 0.10),
		"threat_multiplier": base_stats.get("threat_multiplier", 1.3),
	}


func get_branch_bonus(branch: Enums.SkillBranch, allocated_points: int) -> Dictionary:
	match branch:
		Enums.SkillBranch.GUARDIAN:
			return {
				"armor_bonus_percent": allocated_points * 0.03,
				"block_chance_bonus": allocated_points * 0.01,
			}
		Enums.SkillBranch.WARBRINGER:
			return {
				"damage_bonus_percent": allocated_points * 0.02,
				"threat_bonus": allocated_points * 0.05,
			}
		Enums.SkillBranch.PALADIN:
			return {
				"heal_bonus_percent": allocated_points * 0.02,
				"holy_damage_bonus": allocated_points * 0.015,
			}
	return {}

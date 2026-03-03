## Assassin - Gyilkos osztály
## Branch-ek: Shadow, Poison, Blood
class_name AssassinClass
extends ClassBase


func _init(p_player: CharacterBody2D) -> void:
	super._init(Enums.PlayerClass.ASSASSIN, p_player)


func _setup_branches() -> void:
	branches = [
		Enums.SkillBranch.SHADOW,
		Enums.SkillBranch.POISON,
		Enums.SkillBranch.BLOOD,
	]
	branch_names = {
		Enums.SkillBranch.SHADOW: "Shadow",
		Enums.SkillBranch.POISON: "Poison",
		Enums.SkillBranch.BLOOD: "Blood",
	}


func get_passive_bonus() -> Dictionary:
	return {
		"crit_chance": base_stats.get("crit_chance", 0.08),
		"crit_multiplier": base_stats.get("crit_multiplier", 1.5),
	}


## Shadow branch: növelt crit és stealth
## Poison branch: DOT bonus
## Blood branch: lifesteal
func get_branch_bonus(branch: Enums.SkillBranch, allocated_points: int) -> Dictionary:
	match branch:
		Enums.SkillBranch.SHADOW:
			return {
				"crit_chance_bonus": allocated_points * 0.01,
				"dodge_chance": allocated_points * 0.005,
			}
		Enums.SkillBranch.POISON:
			return {
				"dot_damage_bonus": allocated_points * 0.02,
				"dot_duration_bonus": allocated_points * 0.01,
			}
		Enums.SkillBranch.BLOOD:
			return {
				"lifesteal_bonus": allocated_points * 0.01,
				"hp_bonus_percent": allocated_points * 0.02,
			}
	return {}

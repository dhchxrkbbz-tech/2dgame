## SkillData - Skill definíció Resource
## Minden skill adatait tárolja (damage, cooldown, mana cost, stb.)
class_name SkillData
extends Resource

@export var skill_name: String = ""
@export var skill_id: String = ""
@export var branch: Enums.SkillBranch = Enums.SkillBranch.SHADOW
@export var player_class: Enums.PlayerClass = Enums.PlayerClass.ASSASSIN

@export var icon: Texture2D
@export_multiline var description: String = ""

@export var max_rank: int = 5
@export var is_ultimate: bool = false

# === Base értékek (rank 1) ===
@export var base_damage_multiplier: float = 1.0
@export var base_cooldown: float = 5.0
@export var base_mana_cost: float = 15.0
@export var base_duration: float = 0.0

# === Típus ===
@export var skill_type: Enums.SkillType = Enums.SkillType.MELEE
@export var target_type: Enums.TargetType = Enums.TargetType.SINGLE_ENEMY

# === Range ===
@export var skill_range: float = 32.0
@export var aoe_radius: float = 0.0

# === Scaling per rank ===
@export var damage_per_rank: float = 0.15  # +15% per rank
@export var cooldown_per_rank: float = 0.0  # CD csökkenés per rank
@export var duration_per_rank: float = 0.0
@export var mana_cost_per_rank: float = 0.0

# === Prereqs ===
@export var prerequisite_skill_id: String = ""
@export var prerequisite_rank: int = 1

# === Visual/Audio ===
@export var effect_scene: PackedScene
@export var animation_name: String = ""
@export var sound_effect: AudioStream

# === Extra adatok ===
@export var applies_effect: Enums.EffectType = -1
@export var effect_duration: float = 0.0
@export var effect_value: float = 0.0

@export var hp_cost_percent: float = 0.0  # Blood skills
@export var is_toggle: bool = false
@export var mana_per_second: float = 0.0  # Toggle skill mana drain


## Rank-alapú damage multiplier
func get_damage_multiplier(rank: int) -> float:
	return base_damage_multiplier + (rank - 1) * damage_per_rank


## Rank-alapú cooldown
func get_cooldown(rank: int, cdr_percent: float = 0.0) -> float:
	var cd := base_cooldown - (rank - 1) * cooldown_per_rank
	cd = maxf(cd, 0.5)
	var effective_cdr := minf(cdr_percent, Constants.CDR_CAP)
	return cd * (1.0 - effective_cdr)


## Rank-alapú mana cost
func get_mana_cost(rank: int) -> float:
	return base_mana_cost + (rank - 1) * mana_cost_per_rank


## Rank-alapú duration
func get_duration(rank: int) -> float:
	return base_duration + (rank - 1) * duration_per_rank


## Prereq teljesül-e
func is_unlockable(allocated_skills: Dictionary) -> bool:
	if prerequisite_skill_id.is_empty():
		return true
	var current_rank: int = allocated_skills.get(prerequisite_skill_id, 0)
	return current_rank >= prerequisite_rank

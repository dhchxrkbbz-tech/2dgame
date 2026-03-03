## BossPhase - Boss fázis adatok
class_name BossPhase
extends RefCounted

var phase_index: int = 0
var phase_name: String = ""
var hp_threshold: float = 1.0  # 0.0 - 1.0 (pl. 0.5 = 50% HP alatt aktiválódik)
var abilities: Array[BossAbility] = []
var stat_modifiers: Dictionary = {}  # "damage_mult", "speed_mult", "armor_change", "attack_speed_mult"
var transition_duration: float = 2.0
var invulnerable_during_transition: bool = true
var special_callback: String = ""  # Custom logic (pl. "start_flying", "spawn_bone_storm")
var aura_damage: float = 0.0  # Folyamatos aura damage per sec
var aura_range: float = 0.0  # Aura range tile-okban


static func create(p_index: int, p_name: String, p_threshold: float) -> BossPhase:
	var phase := BossPhase.new()
	phase.phase_index = p_index
	phase.phase_name = p_name
	phase.hp_threshold = p_threshold
	return phase


func add_ability(ability: BossAbility) -> BossPhase:
	abilities.append(ability)
	return self


func set_modifiers(mods: Dictionary) -> BossPhase:
	stat_modifiers = mods
	return self


func set_aura(damage: float, range_tiles: float) -> BossPhase:
	aura_damage = damage
	aura_range = range_tiles * Constants.TILE_SIZE
	return self

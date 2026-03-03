## AffixData - Item prefix/suffix rendszer
## Affix rolling, stat generálás item level alapján
class_name AffixData
extends RefCounted

enum AffixType { PREFIX, SUFFIX }

var affix_name: String = ""
var affix_type: AffixType = AffixType.PREFIX
var stat_type: String = ""  # "fire_damage", "armor", "max_hp", stb.
var min_range: Vector2 = Vector2(3, 20)  # min at iLvl 1 → min at iLvl 50
var max_range: Vector2 = Vector2(5, 35)  # max at iLvl 1 → max at iLvl 50
var is_percent: bool = false


func roll_value(item_level: int) -> float:
	var t := clampf(float(item_level - 1) / 49.0, 0.0, 1.0)
	var min_val := lerpf(min_range.x, min_range.y, t)
	var max_val := lerpf(max_range.x, max_range.y, t)
	return randf_range(min_val, max_val)


# === STATIKUS AFFIX POOL ===

static var PREFIX_POOL: Array[AffixData] = []
static var SUFFIX_POOL: Array[AffixData] = []
static var _pool_initialized: bool = false


static func initialize_pools() -> void:
	if _pool_initialized:
		return
	_pool_initialized = true
	
	# Prefixes
	PREFIX_POOL.append(_create("Blazing", AffixType.PREFIX, "fire_damage", Vector2(3, 20), Vector2(5, 35)))
	PREFIX_POOL.append(_create("Frozen", AffixType.PREFIX, "ice_damage", Vector2(3, 20), Vector2(5, 35)))
	PREFIX_POOL.append(_create("Toxic", AffixType.PREFIX, "poison_damage", Vector2(3, 20), Vector2(5, 35)))
	PREFIX_POOL.append(_create("Sturdy", AffixType.PREFIX, "armor", Vector2(2, 15), Vector2(4, 25)))
	PREFIX_POOL.append(_create("Vicious", AffixType.PREFIX, "physical_damage", Vector2(2, 15), Vector2(5, 30)))
	PREFIX_POOL.append(_create("Arcane", AffixType.PREFIX, "spell_damage", Vector2(3, 18), Vector2(6, 30)))
	PREFIX_POOL.append(_create("Heavy", AffixType.PREFIX, "max_hp", Vector2(5, 40), Vector2(10, 80)))
	PREFIX_POOL.append(_create("Quick", AffixType.PREFIX, "attack_speed", Vector2(3, 12), Vector2(5, 20), true))
	PREFIX_POOL.append(_create("Vampiric", AffixType.PREFIX, "lifesteal", Vector2(1, 5), Vector2(2, 10), true))
	PREFIX_POOL.append(_create("Blessed", AffixType.PREFIX, "heal_effectiveness", Vector2(3, 15), Vector2(5, 25), true))
	
	# Suffixes
	SUFFIX_POOL.append(_create("of the Bear", AffixType.SUFFIX, "max_hp", Vector2(5, 40), Vector2(10, 80)))
	SUFFIX_POOL.append(_create("of the Fox", AffixType.SUFFIX, "dodge", Vector2(1, 5), Vector2(2, 10), true))
	SUFFIX_POOL.append(_create("of the Eagle", AffixType.SUFFIX, "crit_chance", Vector2(1, 4), Vector2(2, 8), true))
	SUFFIX_POOL.append(_create("of the Tiger", AffixType.SUFFIX, "crit_damage", Vector2(5, 20), Vector2(10, 40), true))
	SUFFIX_POOL.append(_create("of Haste", AffixType.SUFFIX, "move_speed", Vector2(2, 8), Vector2(3, 15), true))
	SUFFIX_POOL.append(_create("of Fortune", AffixType.SUFFIX, "gold_find", Vector2(5, 20), Vector2(10, 50), true))
	SUFFIX_POOL.append(_create("of Discovery", AffixType.SUFFIX, "magic_find", Vector2(3, 12), Vector2(5, 25), true))
	SUFFIX_POOL.append(_create("of Vitality", AffixType.SUFFIX, "hp_regen", Vector2(1, 5), Vector2(2, 12)))
	SUFFIX_POOL.append(_create("of Wisdom", AffixType.SUFFIX, "xp_gain", Vector2(2, 10), Vector2(5, 20), true))
	SUFFIX_POOL.append(_create("of Protection", AffixType.SUFFIX, "damage_reduction", Vector2(1, 5), Vector2(2, 12), true))


static func _create(p_name: String, p_type: AffixType, p_stat: String,
		p_min: Vector2, p_max: Vector2, p_percent: bool = false) -> AffixData:
	var affix := AffixData.new()
	affix.affix_name = p_name
	affix.affix_type = p_type
	affix.stat_type = p_stat
	affix.min_range = p_min
	affix.max_range = p_max
	affix.is_percent = p_percent
	return affix


static func roll_random_prefix(exclude: Array[String] = []) -> AffixData:
	initialize_pools()
	var pool := PREFIX_POOL.filter(func(a): return a.stat_type not in exclude)
	if pool.is_empty():
		return null
	return pool[randi() % pool.size()]


static func roll_random_suffix(exclude: Array[String] = []) -> AffixData:
	initialize_pools()
	var pool := SUFFIX_POOL.filter(func(a): return a.stat_type not in exclude)
	if pool.is_empty():
		return null
	return pool[randi() % pool.size()]

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
	
	# === OFFENSIVE PREFIXES ===
	PREFIX_POOL.append(_create("Sharp", AffixType.PREFIX, "flat_damage", Vector2(1, 26), Vector2(3, 40)))
	PREFIX_POOL.append(_create("Blazing", AffixType.PREFIX, "fire_damage", Vector2(5, 33), Vector2(8, 45), true))
	PREFIX_POOL.append(_create("Frozen", AffixType.PREFIX, "ice_damage", Vector2(5, 33), Vector2(8, 45), true))
	PREFIX_POOL.append(_create("Toxic", AffixType.PREFIX, "poison_damage", Vector2(5, 33), Vector2(8, 45), true))
	PREFIX_POOL.append(_create("Swift", AffixType.PREFIX, "attack_speed", Vector2(3, 21), Vector2(5, 28), true))
	PREFIX_POOL.append(_create("Deadly", AffixType.PREFIX, "crit_chance", Vector2(1, 11), Vector2(2, 15), true))
	PREFIX_POOL.append(_create("Brutal", AffixType.PREFIX, "crit_damage", Vector2(5, 46), Vector2(10, 60), true))
	PREFIX_POOL.append(_create("Piercing", AffixType.PREFIX, "armor_pen", Vector2(2, 26), Vector2(4, 36)))

	# === DEFENSIVE PREFIXES ===
	PREFIX_POOL.append(_create("Sturdy", AffixType.PREFIX, "armor", Vector2(3, 41), Vector2(6, 60)))
	PREFIX_POOL.append(_create("Vital", AffixType.PREFIX, "max_hp", Vector2(8, 81), Vector2(15, 120)))
	PREFIX_POOL.append(_create("Hardy", AffixType.PREFIX, "all_resist", Vector2(2, 20), Vector2(4, 26), true))
	PREFIX_POOL.append(_create("Evasive", AffixType.PREFIX, "dodge", Vector2(1, 11), Vector2(2, 14), true))
	PREFIX_POOL.append(_create("Blocking", AffixType.PREFIX, "block_chance", Vector2(2, 19), Vector2(4, 24), true))

	# === UTILITY PREFIXES ===
	PREFIX_POOL.append(_create("Wise", AffixType.PREFIX, "xp_gain", Vector2(3, 24), Vector2(5, 32), true))
	PREFIX_POOL.append(_create("Lucky", AffixType.PREFIX, "magic_find", Vector2(5, 41), Vector2(10, 55), true))
	PREFIX_POOL.append(_create("Wealthy", AffixType.PREFIX, "gold_find", Vector2(8, 59), Vector2(15, 80), true))

	# === SUFFIXES ===
	SUFFIX_POOL.append(_create("of Fire", AffixType.SUFFIX, "fire_resist", Vector2(5, 30), Vector2(10, 40), true))
	SUFFIX_POOL.append(_create("of Ice", AffixType.SUFFIX, "ice_resist", Vector2(5, 30), Vector2(10, 40), true))
	SUFFIX_POOL.append(_create("of Venom", AffixType.SUFFIX, "poison_resist", Vector2(5, 30), Vector2(10, 40), true))
	SUFFIX_POOL.append(_create("of Shadow", AffixType.SUFFIX, "shadow_resist", Vector2(5, 30), Vector2(10, 40), true))
	SUFFIX_POOL.append(_create("of Storm", AffixType.SUFFIX, "lightning_resist", Vector2(5, 30), Vector2(10, 40), true))
	SUFFIX_POOL.append(_create("of the Mage", AffixType.SUFFIX, "max_mana", Vector2(5, 40), Vector2(10, 60)))
	SUFFIX_POOL.append(_create("of War", AffixType.SUFFIX, "strength", Vector2(2, 15), Vector2(4, 22)))
	SUFFIX_POOL.append(_create("of the Fox", AffixType.SUFFIX, "dexterity", Vector2(2, 15), Vector2(4, 22)))
	SUFFIX_POOL.append(_create("of the Owl", AffixType.SUFFIX, "intelligence", Vector2(2, 15), Vector2(4, 22)))
	SUFFIX_POOL.append(_create("of Life", AffixType.SUFFIX, "hp_regen", Vector2(1, 8), Vector2(2, 12)))
	SUFFIX_POOL.append(_create("of Mana", AffixType.SUFFIX, "mana_regen", Vector2(0.5, 4), Vector2(1, 6)))
	SUFFIX_POOL.append(_create("of Leech", AffixType.SUFFIX, "lifesteal", Vector2(1, 6), Vector2(2, 8), true))
	SUFFIX_POOL.append(_create("of the Star", AffixType.SUFFIX, "all_stats", Vector2(1, 5), Vector2(1, 8)))
	SUFFIX_POOL.append(_create("of Light", AffixType.SUFFIX, "light_radius", Vector2(1, 5), Vector2(1, 5)))


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

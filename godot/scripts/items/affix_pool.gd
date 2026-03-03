## AffixPool - Affix pool kezelés
## Prefix és suffix affix-ek kezelése item generáláshoz
class_name AffixPool
extends RefCounted

# === Prefix pool ===
var prefixes: Array[Affix] = []
# === Suffix pool ===
var suffixes: Array[Affix] = []

# === Cached pools item type-onként ===
var _type_cache: Dictionary = {}


func _init() -> void:
	_load_affixes()


func _load_affixes() -> void:
	# Prefix-ek betöltése
	if ResourceLoader.exists("res://data/affixes/prefixes.tres"):
		var res: Resource = ResourceLoader.load("res://data/affixes/prefixes.tres")
		if res and res.has_method("get_affixes"):
			prefixes = res.get_affixes()
	else:
		_generate_default_prefixes()
	
	# Suffix-ek betöltése
	if ResourceLoader.exists("res://data/affixes/suffixes.tres"):
		var res: Resource = ResourceLoader.load("res://data/affixes/suffixes.tres")
		if res and res.has_method("get_affixes"):
			suffixes = res.get_affixes()
	else:
		_generate_default_suffixes()


func _generate_default_prefixes() -> void:
	prefixes.append(Affix.new("Sharp", "flat_damage", 3.0, 15.0, 5))
	prefixes.append(Affix.new("Brutal", "percent_damage", 5.0, 25.0, 5))
	prefixes.append(Affix.new("Fortified", "flat_armor", 5.0, 30.0, 5))
	prefixes.append(Affix.new("Sturdy", "percent_armor", 3.0, 15.0, 5))
	prefixes.append(Affix.new("Vital", "flat_hp", 10.0, 60.0, 5))
	prefixes.append(Affix.new("Healthy", "percent_hp", 3.0, 15.0, 5))
	prefixes.append(Affix.new("Swift", "attack_speed", 3.0, 15.0, 5))
	prefixes.append(Affix.new("Energetic", "mana", 8.0, 40.0, 5))


func _generate_default_suffixes() -> void:
	suffixes.append(Affix.new("of Precision", "crit_chance", 1.0, 5.0, 5))
	suffixes.append(Affix.new("of Destruction", "crit_damage", 5.0, 30.0, 5))
	suffixes.append(Affix.new("of Haste", "move_speed", 2.0, 10.0, 5))
	suffixes.append(Affix.new("of Clarity", "mana_regen", 0.5, 3.0, 5))
	suffixes.append(Affix.new("of Vampirism", "lifesteal", 1.0, 5.0, 5))
	suffixes.append(Affix.new("of Readiness", "cooldown_reduction", 2.0, 10.0, 5))
	suffixes.append(Affix.new("of Warding", "all_resist", 3.0, 15.0, 5))


## Prefix pool item type-ra szűrve
func get_prefixes_for_type(item_type: Enums.ItemType) -> Array[Affix]:
	var key := "prefix_%d" % item_type
	if key in _type_cache:
		return _type_cache[key]
	
	var filtered: Array[Affix] = []
	for affix in prefixes:
		if affix.is_valid_for_type(item_type):
			filtered.append(affix)
	
	_type_cache[key] = filtered
	return filtered


## Suffix pool item type-ra szűrve
func get_suffixes_for_type(item_type: Enums.ItemType) -> Array[Affix]:
	var key := "suffix_%d" % item_type
	if key in _type_cache:
		return _type_cache[key]
	
	var filtered: Array[Affix] = []
	for affix in suffixes:
		if affix.is_valid_for_type(item_type):
			filtered.append(affix)
	
	_type_cache[key] = filtered
	return filtered


## Véletlenszerű prefix roll
func roll_prefix(item_type: Enums.ItemType, item_level: int, exclude: Array[String] = []) -> Affix:
	var pool := get_prefixes_for_type(item_type)
	pool = pool.filter(func(a): return a.affix_name not in exclude and a.min_level <= item_level)
	if pool.is_empty():
		return null
	return pool[randi() % pool.size()]


## Véletlenszerű suffix roll
func roll_suffix(item_type: Enums.ItemType, item_level: int, exclude: Array[String] = []) -> Affix:
	var pool := get_suffixes_for_type(item_type)
	pool = pool.filter(func(a): return a.affix_name not in exclude and a.min_level <= item_level)
	if pool.is_empty():
		return null
	return pool[randi() % pool.size()]

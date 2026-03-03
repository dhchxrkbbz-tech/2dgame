## BossDatabase - Összes boss regisztrálása és spawn kezelés
## Biome-alapú boss kiválasztás, dungeon boss hozzárendelés
class_name BossDatabase
extends RefCounted

## Boss ID → BossData mapping
static var _bosses: Dictionary = {}
static var _initialized: bool = false


static func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	_register_all_bosses()


static func _register_all_bosses() -> void:
	# === TIER 1: Mini Bosses ===
	_register_mini_boss("cursed_treant", "Cursed Treant", Enums.BiomeType.CURSED_FOREST,
		800, 10, 25, 40.0, 5, 8, Color(0.35, 0.5, 0.2))
	_register_mini_boss("plague_rat_king", "Plague Rat King", Enums.BiomeType.DARK_SWAMP,
		600, 5, 20, 70.0, 5, 8, Color(0.5, 0.35, 0.2))
	_register_mini_boss("frozen_sentinel", "Frozen Sentinel", Enums.BiomeType.FROZEN_WASTES,
		1200, 20, 30, 30.0, 8, 12, Color(0.5, 0.7, 0.9))
	_register_mini_boss("shadow_stalker", "Shadow Stalker", Enums.BiomeType.CURSED_FOREST,
		500, 3, 35, 120.0, 8, 12, Color(0.15, 0.1, 0.2))
	
	# === TIER 2: Dungeon Bosses ===
	_register_dungeon_boss("necromancer_king", "Necromancer King", Enums.BiomeType.RUINS,
		5000, 8, 40, 50.0, 15, 20, Color(0.3, 0.15, 0.4))
	_register_dungeon_boss("spider_matriarch", "Spider Matriarch", Enums.BiomeType.CURSED_FOREST,
		4000, 12, 35, 60.0, 12, 16, Color(0.4, 0.2, 0.5))
	_register_dungeon_boss("infernal_warden", "Infernal Warden", Enums.BiomeType.ASHLANDS,
		6000, 15, 45, 45.0, 18, 22, Color(0.8, 0.3, 0.1))
	_register_dungeon_boss("forgotten_construct", "The Forgotten Construct", Enums.BiomeType.RUINS,
		5500, 25, 50, 35.0, 20, 25, Color(0.5, 0.5, 0.4))


static func _register_mini_boss(id: String, bname: String, biome: int,
		hp: int, armor: int, damage: int, speed: float,
		lvl_min: int, lvl_max: int, color: Color) -> void:
	var data := BossData.new()
	data.boss_id = id
	data.boss_name = bname
	data.tier = 1
	data.base_hp = hp
	data.armor = armor
	data.damage = damage
	data.speed = speed
	data.recommended_level_min = lvl_min
	data.recommended_level_max = lvl_max
	data.required_players = 1
	data.sprite_size = Vector2(48, 48)
	data.collision_size = Vector2(36, 36)
	data.biome = biome
	data.sprite_color = color
	data.loot_table = BossLoot.create_loot_table_tier1(id)
	_bosses[id] = data


static func _register_dungeon_boss(id: String, bname: String, biome: int,
		hp: int, armor: int, damage: int, speed: float,
		lvl_min: int, lvl_max: int, color: Color) -> void:
	var data := BossData.new()
	data.boss_id = id
	data.boss_name = bname
	data.tier = 2
	data.base_hp = hp
	data.armor = armor
	data.damage = damage
	data.speed = speed
	data.recommended_level_min = lvl_min
	data.recommended_level_max = lvl_max
	data.required_players = 1
	data.sprite_size = Vector2(64, 64)
	data.collision_size = Vector2(48, 40)
	data.biome = biome
	data.sprite_color = color
	data.loot_table = BossLoot.create_loot_table_tier2(id)
	_bosses[id] = data


static func get_boss_data(boss_id: String) -> BossData:
	initialize()
	return _bosses.get(boss_id, null)


static func get_mini_boss_for_biome(biome: int) -> String:
	initialize()
	var candidates: Array[String] = []
	for id in _bosses:
		var data: BossData = _bosses[id]
		if data.tier == 1 and data.biome == biome:
			candidates.append(id)
	
	if candidates.is_empty():
		# Fallback: bármelyik tier 1
		for id in _bosses:
			if _bosses[id].tier == 1:
				candidates.append(id)
	
	if candidates.is_empty():
		return ""
	return candidates[randi() % candidates.size()]


static func get_dungeon_boss_for_biome(biome: int) -> String:
	initialize()
	var candidates: Array[String] = []
	for id in _bosses:
		var data: BossData = _bosses[id]
		if data.tier == 2 and data.biome == biome:
			candidates.append(id)
	
	if candidates.is_empty():
		for id in _bosses:
			if _bosses[id].tier == 2:
				candidates.append(id)
	
	if candidates.is_empty():
		return ""
	return candidates[randi() % candidates.size()]


static func create_boss_instance(boss_id: String, level: int = 1) -> BossBase:
	initialize()
	
	match boss_id:
		"cursed_treant":
			var b := CursedTreant.new()
			b.boss_level = level
			return b
		"plague_rat_king":
			var b := PlagueRatKing.new()
			b.boss_level = level
			return b
		"frozen_sentinel":
			var b := FrozenSentinel.new()
			b.boss_level = level
			return b
		"shadow_stalker":
			var b := ShadowStalker.new()
			b.boss_level = level
			return b
		"necromancer_king":
			var b := NecromancerKing.new()
			b.boss_level = level
			return b
		"spider_matriarch":
			var b := SpiderMatriarch.new()
			b.boss_level = level
			return b
		_:
			# Generic boss
			var b := BossBase.new()
			var data := get_boss_data(boss_id)
			if data:
				b.initialize(data, level)
			return b


static func get_all_boss_ids() -> Array[String]:
	initialize()
	var ids: Array[String] = []
	for id in _bosses:
		ids.append(id)
	return ids

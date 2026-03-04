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
	# === TIER 1: Mini Bosses (plan szekció 8.1 + 8.2) ===
	# Meglévő bossok frissített statokkal
	_register_mini_boss("ash_warden", "Ash Warden", Enums.BiomeType.STARTING_MEADOW,
		1500, 8, 15, 50.0, 5, 8, Color(0.7, 0.4, 0.2))
	_register_mini_boss("plague_rat_king", "Plague Rat King", Enums.BiomeType.CURSED_FOREST,
		3000, 15, 30, 70.0, 10, 14, Color(0.5, 0.35, 0.2))
	_register_mini_boss("cursed_treant", "Cursed Treant", Enums.BiomeType.CURSED_FOREST,
		4000, 25, 35, 40.0, 12, 14, Color(0.35, 0.5, 0.2))
	_register_mini_boss("shadow_stalker", "Shadow Stalker", Enums.BiomeType.DARK_SWAMP,
		12000, 50, 95, 120.0, 28, 32, Color(0.15, 0.1, 0.2))
	_register_mini_boss("swamp_hydra", "Swamp Hydra", Enums.BiomeType.DARK_SWAMP,
		15000, 45, 83, 55.0, 26, 30, Color(0.2, 0.5, 0.3))

	# === TIER 2: Dungeon Bosses ===
	_register_dungeon_boss("spider_matriarch", "Spider Matriarch", Enums.BiomeType.CURSED_FOREST,
		10000, 30, 53, 60.0, 16, 20, Color(0.4, 0.2, 0.5))
	_register_dungeon_boss("frozen_sentinel", "Frozen Sentinel", Enums.BiomeType.FROZEN_WASTES,
		18000, 55, 78, 30.0, 22, 26, Color(0.5, 0.7, 0.9))
	_register_dungeon_boss("volcanic_overlord", "Volcanic Overlord", Enums.BiomeType.ASHLANDS,
		35000, 75, 140, 45.0, 34, 38, Color(0.9, 0.3, 0.05))
	_register_dungeon_boss("necromancer_king", "Necromancer King", Enums.BiomeType.RUINS,
		45000, 90, 165, 50.0, 40, 44, Color(0.3, 0.15, 0.4))

	# === TIER 3: World Bosses (4-player recommended) ===
	_register_world_boss("void_weaver", "Void Weaver", Enums.BiomeType.PLAGUE_LANDS,
		150000, 120, 240, 60.0, 48, 50, 5, Color(0.4, 0.1, 0.6))
	_register_world_boss("ancient_dragon", "Ancient Dragon", Enums.BiomeType.ASHLANDS,
		120000, 100, 215, 70.0, 45, 48, 4, Color(0.8, 0.3, 0.05))
	_register_world_boss("riftlord", "Riftlord", Enums.BiomeType.PLAGUE_LANDS,
		100000, 90, 200, 65.0, 50, 50, 3, Color(0.5, 0.0, 0.8))

	# === TIER 4: Raid Bosses (4 player mandatory) ===
	_register_raid_boss("ashen_god", "The Ashen God", Enums.BiomeType.ASHLANDS,
		500000, 150, 350, 55.0, 48, 50, 6, Color(1.0, 0.5, 0.0))
	_register_raid_boss("void_emperor", "The Void Emperor", Enums.BiomeType.PLAGUE_LANDS,
		800000, 200, 475, 50.0, 50, 50, 8, Color(0.3, 0.0, 0.5))


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


static func _register_world_boss(id: String, bname: String, biome: int,
		hp: int, armor: int, damage: int, speed: float,
		lvl_min: int, lvl_max: int, phases: int, color: Color) -> void:
	var data := BossData.new()
	data.boss_id = id
	data.boss_name = bname
	data.tier = 3
	data.base_hp = hp
	data.armor = armor
	data.damage = damage
	data.speed = speed
	data.recommended_level_min = lvl_min
	data.recommended_level_max = lvl_max
	data.required_players = 4
	data.sprite_size = Vector2(96, 96)
	data.collision_size = Vector2(64, 56)
	data.biome = biome
	data.sprite_color = color
	data.loot_table = BossLoot.create_loot_table_tier3(id) if BossLoot.has_method("create_loot_table_tier3") else BossLoot.create_loot_table_tier2(id)
	_bosses[id] = data


static func _register_raid_boss(id: String, bname: String, biome: int,
		hp: int, armor: int, damage: int, speed: float,
		lvl_min: int, lvl_max: int, phases: int, color: Color) -> void:
	var data := BossData.new()
	data.boss_id = id
	data.boss_name = bname
	data.tier = 4
	data.base_hp = hp
	data.armor = armor
	data.damage = damage
	data.speed = speed
	data.recommended_level_min = lvl_min
	data.recommended_level_max = lvl_max
	data.required_players = 4
	data.enrage_time = 300.0  # 5 perc raid boss enrage
	data.sprite_size = Vector2(128, 128)
	data.collision_size = Vector2(80, 72)
	data.biome = biome
	data.sprite_color = color
	data.loot_table = BossLoot.create_loot_table_tier4(id) if BossLoot.has_method("create_loot_table_tier4") else BossLoot.create_loot_table_tier2(id)
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
			# Generic boss (ash_warden, swamp_hydra, volcanic_overlord,
			# void_weaver, ancient_dragon, riftlord, ashen_god, void_emperor)
			var b := BossBase.new()
			var data := get_boss_data(boss_id)
			if data:
				b.initialize(data, level)
			return b


## World boss keresése biome-hoz
static func get_world_boss_for_biome(biome: int) -> String:
	initialize()
	var candidates: Array[String] = []
	for id in _bosses:
		var data: BossData = _bosses[id]
		if data.tier == 3 and data.biome == biome:
			candidates.append(id)
	if candidates.is_empty():
		for id in _bosses:
			if _bosses[id].tier == 3:
				candidates.append(id)
	if candidates.is_empty():
		return ""
	return candidates[randi() % candidates.size()]


## Raid boss lekérdezése
static func get_raid_bosses() -> Array[String]:
	initialize()
	var result: Array[String] = []
	for id in _bosses:
		if _bosses[id].tier == 4:
			result.append(id)
	return result


static func get_all_boss_ids() -> Array[String]:
	initialize()
	var ids: Array[String] = []
	for id in _bosses:
		ids.append(id)
	return ids

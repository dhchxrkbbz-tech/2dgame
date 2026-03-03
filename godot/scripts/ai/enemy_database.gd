## EnemyDatabase - Összes enemy definíció és spawn table
## Központi adatbázis a biome-specifikus ellenségek számára
class_name EnemyDatabase
extends RefCounted

static var _spawn_tables: Dictionary = {}  # BiomeType -> SpawnTable
static var _enemy_registry: Dictionary = {}  # enemy_id -> EnemyData
static var _initialized: bool = false

## Publikus accessorok
static var enemies: Dictionary:
	get: initialize(); return _enemy_registry

static var spawn_tables: Dictionary:
	get: initialize(); return _spawn_tables


static func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	_register_all_enemies()
	_build_spawn_tables()


static func get_spawn_table(biome: Enums.BiomeType) -> SpawnTable:
	initialize()
	return _spawn_tables.get(biome, null)


static func get_enemy_data(enemy_id: String) -> EnemyData:
	initialize()
	return _enemy_registry.get(enemy_id, null)


## Alias a kompatibilitásért
static func get_enemy(enemy_id: String) -> EnemyData:
	return get_enemy_data(enemy_id)


static func _register(id: String, name: String, category: Enums.EnemyType, sub: int,
	hp: int, dmg: int, armor: int, spd: float, atk_range: float, detect: float,
	atk_speed: float, xp: int, gold: Vector2i, biome: Enums.BiomeType,
	pack: Vector2i, color: Color) -> EnemyData:
	
	var data := EnemyData.new()
	data.enemy_id = id
	data.enemy_name = name
	data.enemy_category = category
	data.sub_type = sub
	data.base_hp = hp
	data.base_damage = dmg
	data.base_armor = armor
	data.base_speed = spd
	data.attack_range = atk_range
	data.detection_range = detect
	data.attack_speed = atk_speed
	data.base_xp = xp
	data.gold_range = gold
	data.biome = biome
	data.pack_size_range = pack
	data.sprite_color = color
	_enemy_registry[id] = data
	return data


static func _register_all_enemies() -> void:
	# === STARTING MEADOW (L1-5) ===
	_register("forest_slime", "Forest Slime", Enums.EnemyType.MELEE, 3,
		25, 5, 1, 40.0, 24.0, 128.0, 2.0, 8, Vector2i(1, 3),
		Enums.BiomeType.STARTING_MEADOW, Vector2i(3, 5), Color(0.2, 0.8, 0.2))
	
	_register("wild_boar", "Wild Boar", Enums.EnemyType.MELEE, 1,
		50, 12, 3, 90.0, 28.0, 160.0, 2.0, 12, Vector2i(2, 5),
		Enums.BiomeType.STARTING_MEADOW, Vector2i(1, 2), Color(0.5, 0.3, 0.1))
	
	_register("bandit", "Bandit", Enums.EnemyType.MELEE, 0,
		60, 10, 4, 65.0, 32.0, 192.0, 1.5, 15, Vector2i(3, 8),
		Enums.BiomeType.STARTING_MEADOW, Vector2i(2, 3), Color(0.6, 0.4, 0.2))
	
	_register("bandit_archer", "Bandit Archer", Enums.EnemyType.RANGED, 0,
		35, 14, 2, 55.0, 224.0, 256.0, 2.0, 15, Vector2i(3, 8),
		Enums.BiomeType.STARTING_MEADOW, Vector2i(1, 2), Color(0.7, 0.5, 0.3))
	
	_register("rabid_wolf", "Rabid Wolf", Enums.EnemyType.MELEE, 0,
		45, 13, 2, 85.0, 28.0, 224.0, 1.2, 14, Vector2i(2, 5),
		Enums.BiomeType.STARTING_MEADOW, Vector2i(2, 4), Color(0.4, 0.4, 0.4))
	
	# === CURSED FOREST (L8-15) ===
	_register("giant_spider", "Giant Spider", Enums.EnemyType.MELEE, 0,
		70, 15, 5, 70.0, 28.0, 192.0, 1.5, 22, Vector2i(4, 10),
		Enums.BiomeType.CURSED_FOREST, Vector2i(1, 3), Color(0.3, 0.1, 0.0))
	
	_register("poison_archer", "Poison Archer", Enums.EnemyType.RANGED, 0,
		40, 18, 2, 55.0, 224.0, 256.0, 2.0, 25, Vector2i(5, 12),
		Enums.BiomeType.CURSED_FOREST, Vector2i(1, 2), Color(0.2, 0.6, 0.1))
	
	_register("dark_witch", "Dark Witch", Enums.EnemyType.CASTER, 0,
		50, 22, 2, 45.0, 256.0, 288.0, 3.0, 30, Vector2i(6, 15),
		Enums.BiomeType.CURSED_FOREST, Vector2i(1, 1), Color(0.4, 0.0, 0.6))
	
	_register("shadow_wolf", "Shadow Wolf", Enums.EnemyType.MELEE, 1,
		55, 17, 3, 95.0, 28.0, 224.0, 1.2, 22, Vector2i(4, 10),
		Enums.BiomeType.CURSED_FOREST, Vector2i(2, 4), Color(0.2, 0.0, 0.3))
	
	_register("corrupted_treant", "Corrupted Treant", Enums.EnemyType.MELEE, 2,
		120, 20, 10, 35.0, 36.0, 160.0, 2.5, 35, Vector2i(8, 18),
		Enums.BiomeType.CURSED_FOREST, Vector2i(1, 1), Color(0.3, 0.2, 0.0))
	
	# === DARK SWAMP (L10-18) ===
	_register("swamp_lurker", "Swamp Lurker", Enums.EnemyType.MELEE, 0,
		80, 16, 6, 50.0, 32.0, 160.0, 1.8, 24, Vector2i(5, 12),
		Enums.BiomeType.DARK_SWAMP, Vector2i(1, 2), Color(0.2, 0.4, 0.1))
	
	_register("toxic_frog", "Toxic Frog", Enums.EnemyType.RANGED, 0,
		45, 14, 2, 60.0, 192.0, 224.0, 2.5, 20, Vector2i(4, 10),
		Enums.BiomeType.DARK_SWAMP, Vector2i(2, 4), Color(0.1, 0.7, 0.1))
	
	_register("bog_witch", "Bog Witch", Enums.EnemyType.CASTER, 0,
		55, 20, 2, 40.0, 256.0, 288.0, 3.5, 32, Vector2i(6, 15),
		Enums.BiomeType.DARK_SWAMP, Vector2i(1, 1), Color(0.3, 0.5, 0.2))
	
	_register("vine_creeper", "Vine Creeper", Enums.EnemyType.MELEE, 0,
		65, 12, 4, 55.0, 48.0, 192.0, 2.0, 22, Vector2i(4, 10),
		Enums.BiomeType.DARK_SWAMP, Vector2i(1, 3), Color(0.1, 0.5, 0.0))
	
	_register("swamp_horror", "Swamp Horror", Enums.EnemyType.MELEE, 2,
		130, 22, 8, 30.0, 40.0, 160.0, 2.5, 38, Vector2i(8, 20),
		Enums.BiomeType.DARK_SWAMP, Vector2i(1, 1), Color(0.3, 0.3, 0.1))
	
	# === RUINS (L15-25) ===
	_register("skeleton_warrior", "Skeleton Warrior", Enums.EnemyType.MELEE, 0,
		75, 18, 8, 55.0, 32.0, 192.0, 1.5, 28, Vector2i(6, 14),
		Enums.BiomeType.RUINS, Vector2i(2, 4), Color(0.8, 0.8, 0.7))
	
	_register("skeleton_archer", "Skeleton Archer", Enums.EnemyType.RANGED, 0,
		50, 22, 3, 50.0, 256.0, 288.0, 2.0, 28, Vector2i(6, 14),
		Enums.BiomeType.RUINS, Vector2i(1, 3), Color(0.7, 0.7, 0.6))
	
	_register("ghost", "Ghost", Enums.EnemyType.CASTER, 0,
		40, 25, 0, 70.0, 224.0, 256.0, 3.0, 35, Vector2i(8, 18),
		Enums.BiomeType.RUINS, Vector2i(1, 2), Color(0.6, 0.7, 0.9, 0.6))
	
	_register("animated_armor", "Animated Armor", Enums.EnemyType.MELEE, 2,
		140, 25, 15, 35.0, 36.0, 160.0, 2.0, 40, Vector2i(10, 22),
		Enums.BiomeType.RUINS, Vector2i(1, 1), Color(0.5, 0.5, 0.5))
	
	_register("wraith", "Wraith", Enums.EnemyType.CASTER, 0,
		60, 28, 2, 45.0, 256.0, 288.0, 3.5, 42, Vector2i(10, 25),
		Enums.BiomeType.RUINS, Vector2i(1, 1), Color(0.3, 0.0, 0.5, 0.7))
	
	# === MOUNTAINS (L18-28) ===
	_register("mountain_goat", "Mountain Goat", Enums.EnemyType.MELEE, 1,
		65, 20, 5, 85.0, 28.0, 192.0, 1.8, 30, Vector2i(6, 15),
		Enums.BiomeType.MOUNTAINS, Vector2i(2, 4), Color(0.6, 0.6, 0.5))
	
	_register("rock_elemental", "Rock Elemental", Enums.EnemyType.MELEE, 2,
		150, 28, 18, 30.0, 40.0, 160.0, 2.5, 45, Vector2i(12, 28),
		Enums.BiomeType.MOUNTAINS, Vector2i(1, 1), Color(0.5, 0.4, 0.3))
	
	_register("harpy", "Harpy", Enums.EnemyType.RANGED, 0,
		55, 24, 3, 80.0, 224.0, 288.0, 2.0, 35, Vector2i(8, 18),
		Enums.BiomeType.MOUNTAINS, Vector2i(2, 3), Color(0.6, 0.3, 0.4))
	
	_register("yeti", "Yeti", Enums.EnemyType.MELEE, 2,
		160, 30, 12, 40.0, 40.0, 192.0, 2.0, 48, Vector2i(12, 30),
		Enums.BiomeType.MOUNTAINS, Vector2i(1, 1), Color(0.8, 0.85, 0.9))
	
	_register("mountain_bandit", "Mountain Bandit", Enums.EnemyType.RANGED, 4,
		45, 30, 4, 50.0, 320.0, 320.0, 3.0, 40, Vector2i(10, 22),
		Enums.BiomeType.MOUNTAINS, Vector2i(1, 2), Color(0.5, 0.4, 0.3))
	
	# === FROZEN WASTES (L22-32) ===
	_register("ice_wolf", "Ice Wolf", Enums.EnemyType.MELEE, 1,
		70, 25, 6, 90.0, 28.0, 224.0, 1.2, 38, Vector2i(8, 20),
		Enums.BiomeType.FROZEN_WASTES, Vector2i(2, 5), Color(0.6, 0.8, 1.0))
	
	_register("frost_mage", "Frost Mage", Enums.EnemyType.CASTER, 0,
		55, 30, 3, 45.0, 256.0, 288.0, 3.0, 45, Vector2i(10, 25),
		Enums.BiomeType.FROZEN_WASTES, Vector2i(1, 1), Color(0.3, 0.5, 0.9))
	
	_register("ice_golem", "Ice Golem", Enums.EnemyType.MELEE, 2,
		180, 32, 16, 28.0, 40.0, 160.0, 2.5, 50, Vector2i(14, 32),
		Enums.BiomeType.FROZEN_WASTES, Vector2i(1, 1), Color(0.5, 0.7, 0.95))
	
	_register("snow_wraith", "Snow Wraith", Enums.EnemyType.CASTER, 0,
		50, 28, 2, 65.0, 224.0, 256.0, 3.0, 42, Vector2i(10, 25),
		Enums.BiomeType.FROZEN_WASTES, Vector2i(1, 2), Color(0.7, 0.8, 1.0, 0.6))
	
	_register("frozen_revenant", "Frozen Revenant", Enums.EnemyType.MELEE, 0,
		100, 26, 10, 40.0, 32.0, 192.0, 1.8, 40, Vector2i(10, 22),
		Enums.BiomeType.FROZEN_WASTES, Vector2i(1, 3), Color(0.4, 0.5, 0.7))
	
	# === ASHLANDS (L28-38) ===
	_register("flame_imp", "Flame Imp", Enums.EnemyType.MELEE, 3,
		30, 18, 1, 80.0, 24.0, 192.0, 1.0, 30, Vector2i(6, 15),
		Enums.BiomeType.ASHLANDS, Vector2i(4, 6), Color(1.0, 0.4, 0.0))
	
	_register("fire_elemental", "Fire Elemental", Enums.EnemyType.CASTER, 0,
		80, 35, 5, 50.0, 256.0, 288.0, 3.0, 50, Vector2i(12, 30),
		Enums.BiomeType.ASHLANDS, Vector2i(1, 1), Color(1.0, 0.5, 0.1))
	
	_register("ash_golem", "Ash Golem", Enums.EnemyType.MELEE, 2,
		200, 35, 20, 25.0, 44.0, 160.0, 2.5, 55, Vector2i(16, 35),
		Enums.BiomeType.ASHLANDS, Vector2i(1, 1), Color(0.4, 0.3, 0.2))
	
	_register("magma_worm", "Magma Worm", Enums.EnemyType.RANGED, 0,
		60, 32, 4, 55.0, 224.0, 256.0, 2.5, 45, Vector2i(10, 25),
		Enums.BiomeType.ASHLANDS, Vector2i(1, 3), Color(0.9, 0.2, 0.0))
	
	_register("infernal_knight", "Infernal Knight", Enums.EnemyType.MELEE, 0,
		130, 38, 15, 50.0, 36.0, 224.0, 1.5, 55, Vector2i(14, 32),
		Enums.BiomeType.ASHLANDS, Vector2i(1, 2), Color(0.7, 0.1, 0.0))
	
	# === PLAGUE LANDS (L35-45) ===
	_register("plague_zombie", "Plague Zombie", Enums.EnemyType.MELEE, 3,
		40, 22, 2, 35.0, 28.0, 128.0, 2.0, 35, Vector2i(6, 15),
		Enums.BiomeType.PLAGUE_LANDS, Vector2i(4, 8), Color(0.4, 0.5, 0.2))
	
	_register("plague_rat", "Plague Rat", Enums.EnemyType.MELEE, 3,
		25, 15, 1, 80.0, 24.0, 160.0, 1.0, 25, Vector2i(4, 10),
		Enums.BiomeType.PLAGUE_LANDS, Vector2i(5, 8), Color(0.3, 0.3, 0.1))
	
	_register("abomination", "Abomination", Enums.EnemyType.MELEE, 2,
		250, 40, 18, 25.0, 48.0, 160.0, 3.0, 65, Vector2i(18, 40),
		Enums.BiomeType.PLAGUE_LANDS, Vector2i(1, 1), Color(0.4, 0.3, 0.5))
	
	_register("plague_doctor", "Plague Doctor", Enums.EnemyType.CASTER, 0,
		70, 30, 4, 45.0, 256.0, 288.0, 3.5, 55, Vector2i(14, 32),
		Enums.BiomeType.PLAGUE_LANDS, Vector2i(1, 1), Color(0.2, 0.3, 0.2))
	
	_register("death_knight", "Death Knight", Enums.EnemyType.MELEE, 0,
		180, 42, 18, 50.0, 36.0, 224.0, 1.8, 65, Vector2i(18, 40),
		Enums.BiomeType.PLAGUE_LANDS, Vector2i(1, 2), Color(0.3, 0.0, 0.3))


static func _build_spawn_tables() -> void:
	for biome_type in [
		Enums.BiomeType.STARTING_MEADOW,
		Enums.BiomeType.CURSED_FOREST,
		Enums.BiomeType.DARK_SWAMP,
		Enums.BiomeType.RUINS,
		Enums.BiomeType.MOUNTAINS,
		Enums.BiomeType.FROZEN_WASTES,
		Enums.BiomeType.ASHLANDS,
		Enums.BiomeType.PLAGUE_LANDS,
	]:
		var table := SpawnTable.new()
		table.biome = biome_type
		
		for id in _enemy_registry:
			var data: EnemyData = _enemy_registry[id]
			if data.biome == biome_type:
				# Weight: swarmers + common magasabb, brute + caster alacsonyabb
				var weight: float = 1.0
				match data.enemy_category:
					Enums.EnemyType.MELEE:
						weight = 3.0 if data.sub_type == 3 else 2.0  # swarmer vs normal
					Enums.EnemyType.RANGED:
						weight = 1.5
					Enums.EnemyType.CASTER:
						weight = 1.0
				if data.sub_type == 2:  # brute
					weight *= 0.5
				
				table.add_entry(
					data, weight,
					_get_biome_level_range(biome_type).x,
					_get_biome_level_range(biome_type).y,
					data.pack_size_range
				)
		
		_spawn_tables[biome_type] = table


static func _get_biome_level_range(biome: Enums.BiomeType) -> Vector2i:
	match biome:
		Enums.BiomeType.STARTING_MEADOW: return Vector2i(1, 5)
		Enums.BiomeType.CURSED_FOREST: return Vector2i(8, 15)
		Enums.BiomeType.DARK_SWAMP: return Vector2i(10, 18)
		Enums.BiomeType.RUINS: return Vector2i(15, 25)
		Enums.BiomeType.MOUNTAINS: return Vector2i(18, 28)
		Enums.BiomeType.FROZEN_WASTES: return Vector2i(22, 32)
		Enums.BiomeType.ASHLANDS: return Vector2i(28, 38)
		Enums.BiomeType.PLAGUE_LANDS: return Vector2i(35, 45)
		_: return Vector2i(1, 5)

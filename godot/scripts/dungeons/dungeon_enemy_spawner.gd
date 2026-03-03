## DungeonEnemySpawner - Dungeon-specifikus enemy spawn rendszer
## Biome-alapú enemy kiválasztás, dungeon stat bonus, wave integráció
class_name DungeonEnemySpawner
extends Node

signal enemy_spawned(enemy: Node, room_index: int)
signal all_enemies_dead(room_index: int)

## Konfiguráció
const DUNGEON_STAT_BONUS: float = 0.20  # +20% stat bonus world enemy-khez képest
const DUNGEON_ELITE_CHANCE: float = 0.15  # 15% elite esély (vs world 10%)
const SPAWN_INVULNERABILITY_TIME: float = 0.5  # 0.5s invulnerability spawn után

## Difficulty → enemy count per room
const ENEMY_COUNT_BY_DIFFICULTY: Dictionary = {
	1: 3, 2: 3, 3: 4, 4: 4, 5: 5,
	6: 5, 7: 6, 8: 7, 9: 8, 10: 8,
}

## Floor scaling
const FLOOR_DIFFICULTY_BONUS: Dictionary = {
	1: 0, 2: 2, 3: 4,
}

var rng: RandomNumberGenerator
var biome: Enums.BiomeType = Enums.BiomeType.CURSED_FOREST
var dungeon_difficulty: int = 1
var current_floor: int = 1

## Aktív enemy tracking (room_index -> [enemy_refs])
var room_enemies: Dictionary = {}
var check_timer: float = 0.0
const CHECK_INTERVAL: float = 0.5


func _init() -> void:
	rng = RandomNumberGenerator.new()


func initialize(p_biome: Enums.BiomeType, difficulty: int, floor_num: int = 1, seed_val: int = -1) -> void:
	biome = p_biome
	dungeon_difficulty = difficulty
	current_floor = floor_num
	if seed_val >= 0:
		rng.seed = seed_val


func _process(delta: float) -> void:
	check_timer -= delta
	if check_timer > 0:
		return
	check_timer = CHECK_INTERVAL
	
	# Élő enemy-k ellenőrzése minden aktív szobában
	for room_idx in room_enemies:
		var enemies: Array = room_enemies[room_idx]
		enemies = enemies.filter(func(e): return is_instance_valid(e) and e.is_alive)
		room_enemies[room_idx] = enemies
		
		if enemies.is_empty():
			all_enemies_dead.emit(room_idx)


## Szoba enemy-jeinek spawolása
func spawn_room_enemies(room: DungeonRoom, parent: Node2D) -> Array:
	var spawned: Array = []
	var effective_difficulty := dungeon_difficulty + FLOOR_DIFFICULTY_BONUS.get(current_floor, 0)
	effective_difficulty = mini(effective_difficulty, 10)
	
	var enemy_count: int = ENEMY_COUNT_BY_DIFFICULTY.get(effective_difficulty, 4)
	
	# Multiplayer scaling
	var player_count := get_tree().get_nodes_in_group("player").size()
	if player_count > 1:
		enemy_count = int(float(enemy_count) * (1.0 + (player_count - 1) * 0.2))
	
	var tiles := room.get_tiles()
	var center := room.get_center()
	
	for i in enemy_count:
		var enemy := _create_dungeon_enemy(room, effective_difficulty, i == enemy_count - 1 and effective_difficulty >= 7)
		if not enemy:
			continue
		
		# Spawn pozíció: szoba szélei, ajtóktól távol
		var spawn_pos := _get_spawn_position(room, tiles, center)
		enemy.global_position = Vector2(spawn_pos.x * Constants.TILE_SIZE, spawn_pos.y * Constants.TILE_SIZE)
		
		parent.add_child(enemy)
		spawned.append(enemy)
		enemy_spawned.emit(enemy, room.room_index)
	
	room_enemies[room.room_index] = spawned
	return spawned


## Wave-specifikus spawn (DungeonWaveSpawner integrációhoz)
func spawn_wave_enemies(room: DungeonRoom, wave_num: int, total_waves: int, 
		parent: Node2D) -> Array:
	var spawned: Array = []
	var effective_difficulty := dungeon_difficulty + FLOOR_DIFFICULTY_BONUS.get(current_floor, 0)
	var base_count: int = ENEMY_COUNT_BY_DIFFICULTY.get(mini(effective_difficulty, 10), 4)
	
	# Wave scaling
	var wave_count: int
	match wave_num:
		1: wave_count = base_count
		2: wave_count = int(float(base_count) * 0.8)
		3: wave_count = int(float(base_count) * 0.6) + 1  # +1 guaranteed elite
		_: wave_count = base_count
	
	var tiles := room.get_tiles()
	var center := room.get_center()
	
	for i in wave_count:
		# Utolsó wave-ben utolsó enemy garantált elite
		var force_elite := (wave_num >= total_waves and wave_num >= 3 and i == wave_count - 1)
		var enemy := _create_dungeon_enemy(room, effective_difficulty, force_elite)
		if not enemy:
			continue
		
		var spawn_pos := _get_spawn_position(room, tiles, center)
		enemy.global_position = Vector2(spawn_pos.x * Constants.TILE_SIZE, spawn_pos.y * Constants.TILE_SIZE)
		
		parent.add_child(enemy)
		spawned.append(enemy)
		enemy_spawned.emit(enemy, room.room_index)
	
	# Meglévő room enemy listához hozzáadás
	if not room_enemies.has(room.room_index):
		room_enemies[room.room_index] = []
	room_enemies[room.room_index].append_array(spawned)
	
	return spawned


## Dungeon enemy létrehozás +20% stat bonus-szal
func _create_dungeon_enemy(room: DungeonRoom, effective_difficulty: int, 
		force_elite: bool = false) -> Node:
	# Enemy kiválasztás biome spawn table-ből
	var enemy_data: EnemyData = _pick_enemy_from_biome()
	if not enemy_data:
		return null
	
	var is_elite := force_elite or rng.randf() < DUNGEON_ELITE_CHANCE
	
	var enemy: EnemyBase
	if is_elite and enemy_data.get("can_be_elite") != false:
		var elite := EliteEnemy.new()
		elite.enemy_data = enemy_data
		elite.enemy_level = _get_enemy_level(effective_difficulty)
		elite.is_elite = true
		elite.elite_affixes = EliteAffixSystem.roll_affixes(rng.randi_range(1, 3))
		enemy = elite
	else:
		enemy = EnemyBase.new()
		enemy.enemy_data = enemy_data
		enemy.enemy_level = _get_enemy_level(effective_difficulty)
	
	# Dungeon stat bonus alkalmazás (+20%)
	_apply_dungeon_bonus(enemy)
	
	return enemy


## Dungeon stat bonus
func _apply_dungeon_bonus(enemy: EnemyBase) -> void:
	# A stat bonus a _ready() után alkalmazódik, de az enemy_data-ba beleírjuk
	if enemy.enemy_data:
		var data := enemy.enemy_data
		# Clone data hogy ne módosítsuk az eredetit
		var dungeon_data := EnemyData.new()
		dungeon_data.enemy_name = data.enemy_name
		dungeon_data.enemy_id = data.enemy_id + "_dungeon"
		dungeon_data.enemy_category = data.enemy_category
		dungeon_data.base_hp = int(data.base_hp * (1.0 + DUNGEON_STAT_BONUS))
		dungeon_data.base_damage = int(data.base_damage * (1.0 + DUNGEON_STAT_BONUS))
		dungeon_data.base_armor = int(data.base_armor * (1.0 + DUNGEON_STAT_BONUS))
		dungeon_data.base_speed = data.base_speed
		dungeon_data.attack_range = data.attack_range
		dungeon_data.detection_range = data.detection_range
		dungeon_data.attack_speed = data.attack_speed
		dungeon_data.base_xp = int(data.base_xp * (1.0 + DUNGEON_STAT_BONUS))
		dungeon_data.gold_range = data.gold_range
		dungeon_data.sprite_color = data.sprite_color
		enemy.enemy_data = dungeon_data


## Enemy kiválasztás a biome spawn table-ből
func _pick_enemy_from_biome() -> EnemyData:
	if not EnemyDatabase.spawn_tables.has(biome):
		# Fallback: bármilyen enemy
		for eid in EnemyDatabase.enemies:
			return EnemyDatabase.enemies[eid]
		return null
	
	var table: SpawnTable = EnemyDatabase.spawn_tables[biome]
	
	for _attempt in 10:
		var enemy_id: String = table.roll()
		if not enemy_id.is_empty():
			var data := EnemyDatabase.get_enemy(enemy_id)
			if data:
				return data
	
	# Fallback
	for eid in EnemyDatabase.enemies:
		var data: EnemyData = EnemyDatabase.enemies[eid]
		if data.biome == biome:
			return data
	
	return null


## Enemy szint számítás
func _get_enemy_level(effective_difficulty: int) -> int:
	var level_range := EnemyDatabase._get_biome_level_range(biome)
	var base_level: int = rng.randi_range(level_range.x, level_range.y)
	return base_level + effective_difficulty * 2


## Spawn pozíció: szoba szélei, ajtóktól távol
func _get_spawn_position(room: DungeonRoom, tiles: Array[Vector2i], center: Vector2i) -> Vector2i:
	# Szoba széleihez közel spawoljon
	var edge_tiles: Array[Vector2i] = []
	for tile in tiles:
		var dist_x := mini(tile.x - room.rect.position.x, room.rect.end.x - tile.x - 1)
		var dist_y := mini(tile.y - room.rect.position.y, room.rect.end.y - tile.y - 1)
		if dist_x <= 2 or dist_y <= 2:
			# Ajtóktól távol
			var near_door := false
			for door in room.doors:
				if Vector2i(door["pos"]).distance_to(tile) < 3:
					near_door = true
					break
			if not near_door:
				edge_tiles.append(tile)
	
	if edge_tiles.is_empty():
		# Fallback: random tile (nem center)
		var attempts := 0
		while attempts < 10:
			var pos: Vector2i = tiles[rng.randi() % tiles.size()]
			if pos.distance_to(center) > 2:
				return pos
			attempts += 1
		return tiles[rng.randi() % tiles.size()]
	
	return edge_tiles[rng.randi() % edge_tiles.size()]


## Loot rarity esélyek dungeon difficulty alapján
func get_loot_rarity_weights(difficulty: int) -> Dictionary:
	if difficulty <= 3:
		return {Enums.Rarity.COMMON: 60, Enums.Rarity.UNCOMMON: 30, Enums.Rarity.RARE: 9, Enums.Rarity.EPIC: 1}
	elif difficulty <= 6:
		return {Enums.Rarity.COMMON: 40, Enums.Rarity.UNCOMMON: 40, Enums.Rarity.RARE: 17, Enums.Rarity.EPIC: 3}
	elif difficulty <= 8:
		return {Enums.Rarity.COMMON: 20, Enums.Rarity.UNCOMMON: 40, Enums.Rarity.RARE: 30, Enums.Rarity.EPIC: 10}
	else:
		return {Enums.Rarity.COMMON: 10, Enums.Rarity.UNCOMMON: 30, Enums.Rarity.RARE: 40, Enums.Rarity.EPIC: 20}


## Cleanup
func clear_all() -> void:
	for room_idx in room_enemies:
		for enemy in room_enemies[room_idx]:
			if is_instance_valid(enemy):
				enemy.queue_free()
	room_enemies.clear()

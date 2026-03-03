## EnemySpawner - Világ enemy spawning a chunk rendszerrel
## Chunk adatokból tényleges EnemyBase node-okat hoz létre
class_name EnemySpawner
extends Node

# Aktív ellenségek nyilvántartása
var active_enemies: Dictionary = {}  # chunk_pos -> Array[EnemyBase]
var max_enemies_per_chunk: int = 10
var spawn_distance_min: float = 320.0  # 10 tile (nem a viewport-ban)
var spawn_distance_max: float = 640.0  # 20 tile

var enemy_layer: Node2D = null
var player_ref: Node = null


func initialize(p_enemy_layer: Node2D, p_player: Node = null) -> void:
	enemy_layer = p_enemy_layer
	player_ref = p_player
	
	EnemyDatabase.initialize()
	
	EventBus.chunk_loaded.connect(_on_chunk_loaded)
	EventBus.chunk_unloaded.connect(_on_chunk_unloaded)


func _on_chunk_loaded(chunk_pos: Vector2i) -> void:
	if chunk_pos in active_enemies:
		return  # Már van spawned enemy ebben a chunk-ban
	
	var chunk: ChunkData = WorldManager.chunk_manager.get_chunk(chunk_pos)
	if not chunk:
		return
	
	_spawn_enemies_for_chunk(chunk_pos, chunk)


func _on_chunk_unloaded(chunk_pos: Vector2i) -> void:
	_despawn_chunk_enemies(chunk_pos)


func _spawn_enemies_for_chunk(chunk_pos: Vector2i, chunk: ChunkData) -> void:
	var biome: Enums.BiomeType = chunk.biome
	var spawn_table := EnemyDatabase.get_spawn_table(biome)
	if not spawn_table:
		return
	
	var enemies: Array = []
	
	for spawn_data in chunk.enemy_spawns:
		if enemies.size() >= max_enemies_per_chunk:
			break
		
		var local_pos: Vector2i = spawn_data["pos"]
		var world_tile: Vector2i = chunk.local_to_world(local_pos.x, local_pos.y)
		var world_pos := Vector2(
			world_tile.x * Constants.TILE_SIZE + Constants.TILE_SIZE / 2,
			world_tile.y * Constants.TILE_SIZE + Constants.TILE_SIZE / 2
		)
		
		# Ne spawnolj túl közel a játékoshoz
		if player_ref and is_instance_valid(player_ref):
			var dist := player_ref.global_position.distance_to(world_pos)
			if dist < spawn_distance_min:
				continue
		
		# Spawn table roll
		var roll := spawn_table.roll_spawn(spawn_data.get("level", -1))
		if roll.is_empty():
			continue
		
		var enemy_data: EnemyData = roll["enemy_data"]
		var level: int = roll["level"]
		var pack_size: int = roll["pack_size"]
		
		# Elite esély
		var is_elite: bool = spawn_data.get("type", Enums.EnemyType.MELEE) == Enums.EnemyType.ELITE
		
		# Pack spawning
		for i in pack_size:
			var offset := Vector2(randf_range(-32, 32), randf_range(-32, 32)) if i > 0 else Vector2.ZERO
			var enemy := _create_enemy(enemy_data, level, is_elite and i == 0)
			enemy.global_position = world_pos + offset
			enemy_layer.add_child(enemy)
			enemies.append(enemy)
	
	active_enemies[chunk_pos] = enemies


func _create_enemy(data: EnemyData, level: int, elite: bool) -> EnemyBase:
	var enemy := EnemyBase.new()
	enemy.enemy_data = data
	enemy.enemy_level = level
	enemy.is_elite = elite
	return enemy


func _despawn_chunk_enemies(chunk_pos: Vector2i) -> void:
	if chunk_pos not in active_enemies:
		return
	
	for enemy in active_enemies[chunk_pos]:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	active_enemies.erase(chunk_pos)


func get_active_enemy_count() -> int:
	var count: int = 0
	for chunk_pos in active_enemies:
		for enemy in active_enemies[chunk_pos]:
			if is_instance_valid(enemy) and enemy.is_alive:
				count += 1
	return count


## Cleanup halott enemy-k
func cleanup_dead() -> void:
	for chunk_pos in active_enemies.keys():
		var alive: Array = []
		for enemy in active_enemies[chunk_pos]:
			if is_instance_valid(enemy) and enemy.is_alive:
				alive.append(enemy)
		active_enemies[chunk_pos] = alive

## DungeonWaveSpawner - Dungeon szobák hullám alapú enemy spawn rendszere
## Wave 1: Melee-k | Wave 2: Melee + Ranged | Wave 3: Ranged + Caster | Final: Elite
class_name DungeonWaveSpawner
extends Node

signal wave_started(wave_number: int, total_waves: int)
signal wave_cleared(wave_number: int)
signal room_cleared()
signal elite_spawned(elite: Node)

# Konfiguráció
var dungeon_level: int = 1
var biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW
var difficulty_modifier: float = 1.0

# Állapot
var current_room: DungeonRoom = null
var current_wave: int = 0
var total_waves: int = 1
var is_active: bool = false
var spawned_enemies: Array[Node] = []
var wave_check_timer: float = 0.0
const WAVE_CHECK_INTERVAL: float = 0.5
const WAVE_DELAY: float = 2.0  # Szünet hullámok között


func _process(delta: float) -> void:
	if not is_active:
		return
	
	wave_check_timer -= delta
	if wave_check_timer > 0:
		return
	wave_check_timer = WAVE_CHECK_INTERVAL
	
	# Élő enemy-k ellenőrzése
	spawned_enemies = spawned_enemies.filter(
		func(e): return is_instance_valid(e) and e.is_alive
	)
	
	if spawned_enemies.is_empty() and current_wave > 0:
		wave_cleared.emit(current_wave)
		
		if current_wave >= total_waves:
			# Szoba cleared!
			is_active = false
			if current_room:
				current_room.is_cleared = true
			room_cleared.emit()
		else:
			# Következő hullám késleltetéssel
			await get_tree().create_timer(WAVE_DELAY).timeout
			if is_instance_valid(self):
				_spawn_next_wave()


## Szoba spawning indítása
func start_room(room: DungeonRoom, level: int, room_biome: Enums.BiomeType) -> void:
	current_room = room
	dungeon_level = level
	biome = room_biome
	current_wave = 0
	
	# Wave szám meghatározása szobatípus alapján
	total_waves = _calculate_wave_count(room)
	room.total_waves = total_waves
	
	# Wave tartalom generálás
	_generate_wave_compositions(room)
	
	is_active = true
	_spawn_next_wave()


## Wave szám számítás
func _calculate_wave_count(room: DungeonRoom) -> int:
	match room.room_type:
		DungeonRoom.RoomType.COMBAT:
			# Szoba méret alapján: kis → 1-2, közepes → 2-3, nagy → 3-4
			var area: int = room.rect.size.x * room.rect.size.y
			if area < 80:
				return randi_range(1, 2)
			elif area < 160:
				return randi_range(2, 3)
			else:
				return randi_range(3, 4)
		DungeonRoom.RoomType.BOSS:
			return 1  # Boss = 1 nagy wave
		DungeonRoom.RoomType.TRAP:
			return randi_range(1, 2)
		_:
			return 1


## Wave tartalom generálás
func _generate_wave_compositions(room: DungeonRoom) -> void:
	room.wave_enemies.clear()
	
	for wave_idx in total_waves:
		var wave_num := wave_idx + 1
		var composition := _get_wave_composition(wave_num, total_waves, room)
		room.wave_enemies.append(composition)


## Wave tartalom összeállítás
## Wave 1: Melee-k | Wave 2: Melee + Ranged | Wave 3: Ranged + Caster | Final: Elite
func _get_wave_composition(wave_num: int, wave_total: int, room: DungeonRoom) -> Array:
	var enemies_in_wave: Array = []
	var base_count := _get_base_enemy_count(room)
	
	# Multiplayer scaling: +20% per extra játékos
	var player_count := get_tree().get_nodes_in_group("player").size()
	var mp_mult := 1.0 + (maxi(0, player_count - 1)) * 0.2
	base_count = int(float(base_count) * mp_mult)
	
	if room.room_type == DungeonRoom.RoomType.BOSS:
		# Boss wave: boss + néhány add
		enemies_in_wave.append({
			"category": Enums.EnemyType.BOSS,
			"count": 1,
			"sub_type": 0,
		})
		# Add-ok
		enemies_in_wave.append({
			"category": Enums.EnemyType.MELEE,
			"count": base_count / 2,
			"sub_type": Enums.EnemySubType.SWARMER,
		})
		return enemies_in_wave
	
	if wave_num == wave_total and wave_total >= 3:
		# Utolsó wave (3+ total): Elite + kíséret
		enemies_in_wave.append({
			"category": Enums.EnemyType.ELITE,
			"count": 1,
			"sub_type": 0,
		})
		enemies_in_wave.append({
			"category": Enums.EnemyType.MELEE,
			"count": maxi(1, base_count / 3),
			"sub_type": 0,
		})
		enemies_in_wave.append({
			"category": Enums.EnemyType.RANGED,
			"count": maxi(1, base_count / 4),
			"sub_type": 0,
		})
		return enemies_in_wave
	
	match wave_num:
		1:
			# Wave 1: Csak melee-k
			enemies_in_wave.append({
				"category": Enums.EnemyType.MELEE,
				"count": base_count,
				"sub_type": 0,
			})
			# Kis esély swarmer-ekre
			if randf() < 0.3:
				enemies_in_wave.append({
					"category": Enums.EnemyType.MELEE,
					"count": randi_range(2, 4),
					"sub_type": Enums.EnemySubType.SWARMER,
				})
		2:
			# Wave 2: Melee + Ranged
			enemies_in_wave.append({
				"category": Enums.EnemyType.MELEE,
				"count": maxi(1, base_count * 2 / 3),
				"sub_type": 0,
			})
			enemies_in_wave.append({
				"category": Enums.EnemyType.RANGED,
				"count": maxi(1, base_count / 3),
				"sub_type": 0,
			})
		3:
			# Wave 3: Ranged + Caster
			enemies_in_wave.append({
				"category": Enums.EnemyType.RANGED,
				"count": maxi(1, base_count / 2),
				"sub_type": 0,
			})
			enemies_in_wave.append({
				"category": Enums.EnemyType.CASTER,
				"count": maxi(1, base_count / 3),
				"sub_type": 0,
			})
		_:
			# 4+ wave: vegyes
			enemies_in_wave.append({
				"category": Enums.EnemyType.MELEE,
				"count": maxi(1, base_count / 3),
				"sub_type": 0,
			})
			enemies_in_wave.append({
				"category": Enums.EnemyType.RANGED,
				"count": maxi(1, base_count / 4),
				"sub_type": 0,
			})
			enemies_in_wave.append({
				"category": Enums.EnemyType.CASTER,
				"count": 1,
				"sub_type": 0,
			})
	
	return enemies_in_wave


## Alap enemy szám szoba méret alapján
func _get_base_enemy_count(room: DungeonRoom) -> int:
	var area: int = room.rect.size.x * room.rect.size.y
	var base: int
	
	if area < 60:
		base = randi_range(2, 3)
	elif area < 100:
		base = randi_range(3, 5)
	elif area < 160:
		base = randi_range(4, 7)
	else:
		base = randi_range(6, 10)
	
	return int(float(base) * difficulty_modifier)


## Következő hullám spawn
func _spawn_next_wave() -> void:
	current_wave += 1
	if current_room:
		current_room.current_wave = current_wave
	
	wave_started.emit(current_wave, total_waves)
	
	if not current_room or current_wave - 1 >= current_room.wave_enemies.size():
		return
	
	var wave_data: Array = current_room.wave_enemies[current_wave - 1]
	
	for group in wave_data:
		var category: Enums.EnemyType = group.get("category", Enums.EnemyType.MELEE)
		var count: int = group.get("count", 1)
		var sub_type: int = group.get("sub_type", 0)
		
		for i in count:
			var enemy := _spawn_enemy(category, sub_type)
			if enemy:
				spawned_enemies.append(enemy)
				
				if category == Enums.EnemyType.ELITE:
					elite_spawned.emit(enemy)


## Egyedi enemy spawn
func _spawn_enemy(category: Enums.EnemyType, sub_type: int) -> Node:
	# Enemy adatok a biome spawn table-ből
	var enemy_data: EnemyData = _pick_enemy_for_category(category, sub_type)
	if not enemy_data:
		return null
	
	var enemy: EnemyBase
	if category == Enums.EnemyType.ELITE:
		var elite := EliteEnemy.new()
		elite.enemy_data = enemy_data
		elite.enemy_level = dungeon_level
		elite.is_elite = true
		elite.elite_affixes = EliteAffixSystem.roll_affixes(randi_range(1, 3))
		enemy = elite
	else:
		enemy = EnemyBase.new()
		enemy.enemy_data = enemy_data
		enemy.enemy_level = dungeon_level
	
	# Pozíció a szobán belül
	var spawn_pos := _get_spawn_position()
	enemy.global_position = spawn_pos
	
	get_parent().add_child(enemy)
	return enemy


## Enemy kiválasztás kategória alapján
func _pick_enemy_for_category(category: Enums.EnemyType, sub_type: int) -> EnemyData:
	# EnemyDatabase-ből a biome-nak megfelelő enemy-t keresünk
	if not EnemyDatabase.spawn_tables.has(biome):
		return null
	
	var table: SpawnTable = EnemyDatabase.spawn_tables[biome]
	
	# Próbálkozunk megfelelő kategóriájú enemy-t kapni
	for _attempt in 10:
		var enemy_id: String = table.roll()
		if enemy_id.is_empty():
			continue
		
		var data: EnemyData = EnemyDatabase.get_enemy(enemy_id)
		if not data:
			continue
		
		# Kategória szűrés
		if category == Enums.EnemyType.ELITE:
			# Elite-hez bármelyik melee/ranged jó
			if data.can_be_elite:
				return data
		elif data.enemy_category == category:
			if sub_type == 0 or data.sub_type == sub_type:
				return data
	
	# Fallback: bármilyen enemy az adott biome-ból
	for enemy_id in EnemyDatabase.enemies:
		var data: EnemyData = EnemyDatabase.enemies[enemy_id]
		if data.biome == biome and data.enemy_category == category:
			return data
	
	# Végső fallback: bármilyen enemy
	for enemy_id in EnemyDatabase.enemies:
		var data: EnemyData = EnemyDatabase.enemies[enemy_id]
		if data.biome == biome:
			return data
	
	return null


## Spawn pozíció a szobán belül
func _get_spawn_position() -> Vector2:
	if not current_room:
		return Vector2.ZERO
	
	var center := current_room.get_world_center()
	
	# Random pozíció a szoba szélein (ne a közepén spawnoljon)
	var half_w := float(current_room.rect.size.x * 32) / 2.0 - 32.0
	var half_h := float(current_room.rect.size.y * 32) / 2.0 - 32.0
	
	# 4 szélből véletlenszerű
	var side := randi() % 4
	var pos := center
	
	match side:
		0: pos += Vector2(randf_range(-half_w, half_w), -half_h + randf() * 32)  # Felső
		1: pos += Vector2(randf_range(-half_w, half_w), half_h - randf() * 32)   # Alsó
		2: pos += Vector2(-half_w + randf() * 32, randf_range(-half_h, half_h))  # Bal
		3: pos += Vector2(half_w - randf() * 32, randf_range(-half_h, half_h))   # Jobb
	
	return pos


## Szoba újraindítás (debug/respawn)
func reset_room() -> void:
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	current_wave = 0
	is_active = false
	if current_room:
		current_room.is_cleared = false
		current_room.current_wave = 0

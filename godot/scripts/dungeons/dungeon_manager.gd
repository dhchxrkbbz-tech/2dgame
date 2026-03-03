## DungeonManager - Dungeon belépés/kilépés, instance kezelés
## A dungeon_placer POI-khoz dungeon belépési pontot rendel,
## a dungeon_generator-rel generálja a tartalmát
## Integrálja az összes dungeon alrendszert
class_name DungeonManager
extends Node

# Aktív dungeon state
var is_in_dungeon: bool = false
var current_dungeon_tier: int = 1
var current_dungeon_biome: int = 0
var current_dungeon_level: int = 1
var current_floor: int = 0

# Node referenciák (game_world-ből kapja)
var game_world: Node2D = null
var enemy_layer: Node2D = null
var player_ref: CharacterBody2D = null

# Dungeon layer-ek (generálásnál jönnek létre)
var dungeon_tilemap: TileMapLayer = null
var dungeon_entities: Node2D = null
var decoration_layer: Node2D = null

# Visszatérési pozíció
var overworld_return_pos: Vector2 = Vector2.ZERO

# Dungeon generátor
var generator: DungeonGenerator = null

# Alrendszerek
var fog_of_war: FogOfWar = null
var minimap: DungeonMinimap = null
var door_controller: DoorController = null
var enemy_spawner: DungeonEnemySpawner = null
var loot_spawner: DungeonLootSpawner = null
var corridor_builder: CorridorBuilder = null
var tilemap_painter: DungeonTilemapPainter = null
var room_factory: RoomFactory = null
var biome_theme: BiomeThemeBase = null

# Room tracking
var rooms: Array = []
var current_room_index: int = -1
var cleared_rooms: Array[int] = []

# Boss spawned in dungeon
var dungeon_boss: Node2D = null

# Dungeon data cache
var dungeon_data: Dictionary = {}


func initialize(p_game_world: Node2D, p_enemy_layer: Node2D) -> void:
	game_world = p_game_world
	enemy_layer = p_enemy_layer
	generator = DungeonGenerator.new()
	
	# Alrendszerek inicializálása
	corridor_builder = CorridorBuilder.new()
	tilemap_painter = DungeonTilemapPainter.new()
	room_factory = RoomFactory.new()


func enter_dungeon(tier: int, biome: int, level: int, entry_pos: Vector2) -> void:
	if is_in_dungeon:
		return
	
	overworld_return_pos = entry_pos
	current_dungeon_tier = tier
	current_dungeon_biome = biome
	current_dungeon_level = level
	current_floor = 0
	is_in_dungeon = true
	
	# Player referencia
	player_ref = game_world.player_instance
	if not player_ref:
		return
	
	# Biome theme kiválasztás
	biome_theme = _create_biome_theme(biome as Enums.BiomeType)
	
	# Overworld elrejtése
	_hide_overworld()
	
	# Dungeon generálás
	var biome_enum: Enums.BiomeType = biome as Enums.BiomeType
	dungeon_data = generator.generate_dungeon(randi(), tier, biome_enum)
	rooms = dungeon_data.get("rooms", [])
	
	# Dungeon tilemap létrehozás
	_create_dungeon_layers()
	generator.render_to_tilemap(dungeon_tilemap)
	
	# Alrendszerek beállítása
	_setup_subsystems()
	
	# Entitások populálása
	_populate_dungeon(dungeon_data)
	
	# Ajtók elhelyezése
	_setup_doors()
	
	# Player áthelyezés az entrance room-ba
	var entrance_pos := _find_entrance_position()
	player_ref.global_position = entrance_pos
	
	# Fog of War frissítés a belépéskor
	if fog_of_war:
		var player_tile := Vector2i(
			int(player_ref.global_position.x / Constants.TILE_SIZE),
			int(player_ref.global_position.y / Constants.TILE_SIZE)
		)
		fog_of_war.update_vision(player_tile)
	
	EventBus.dungeon_entered.emit({
		"tier": tier,
		"biome": biome,
		"level": level,
		"floor": current_floor,
		"seed": dungeon_data.get("seed", 0),
	})
	
	print("DungeonManager: Entered Tier %d dungeon (level %d, biome: %s)" % [
		tier, level, biome_theme.theme_name if biome_theme else "unknown"
	])


func exit_dungeon() -> void:
	if not is_in_dungeon:
		return
	
	is_in_dungeon = false
	
	# Dungeon cleanup
	_cleanup_dungeon()
	
	# Overworld visszaállítás
	_show_overworld()
	
	# Player visszahelyezés
	if player_ref and is_instance_valid(player_ref):
		player_ref.global_position = overworld_return_pos
	
	cleared_rooms.clear()
	rooms.clear()
	current_room_index = -1
	current_floor = 0
	dungeon_boss = null
	dungeon_data.clear()
	biome_theme = null
	
	EventBus.dungeon_exited.emit()
	print("DungeonManager: Exited dungeon")


func _process(_delta: float) -> void:
	if not is_in_dungeon or not player_ref or not is_instance_valid(player_ref):
		return
	
	# Fog of War frissítés a player pozíciójával
	if fog_of_war and fog_of_war.enabled:
		var player_tile := Vector2i(
			int(player_ref.global_position.x / Constants.TILE_SIZE),
			int(player_ref.global_position.y / Constants.TILE_SIZE)
		)
		fog_of_war.update_vision(player_tile)
		EventBus.dungeon_fog_updated.emit(player_tile)
	
	# Room detection: melyik szobában van a player
	_detect_current_room()
	
	# Biome environmental effect
	if biome_theme:
		biome_theme.apply_environmental_effect(player_ref, _delta)


func _detect_current_room() -> void:
	if not player_ref:
		return
	
	var player_tile := Vector2i(
		int(player_ref.global_position.x / Constants.TILE_SIZE),
		int(player_ref.global_position.y / Constants.TILE_SIZE)
	)
	
	for i in rooms.size():
		var room: DungeonRoom = rooms[i]
		if room.contains_tile(player_tile):
			if i != current_room_index:
				_on_room_entered(i)
			break


func _on_room_entered(room_index: int) -> void:
	var old_room := current_room_index
	current_room_index = room_index
	var room: DungeonRoom = rooms[room_index]
	
	room.is_discovered = true
	
	# Fog of war: szoba felfedezése
	if fog_of_war:
		fog_of_war.reveal_room(room.rect)
	
	# Minimap frissítés
	if minimap:
		minimap.update_minimap(rooms, fog_of_war, player_ref.global_position)
	
	# Room enter event
	EventBus.dungeon_room_entered.emit(room_index, room.room_type)
	
	# Combat room: seal doors
	if room.room_type == DungeonRoom.RoomType.COMBAT and not room.is_cleared:
		room.is_sealed = true
		if door_controller:
			door_controller.seal_room_doors(room)
		EventBus.dungeon_room_sealed.emit(room_index)
	elif room.room_type == DungeonRoom.RoomType.BOSS and not room.is_cleared:
		EventBus.dungeon_boss_room_reached.emit(room_index)
		room.is_sealed = true
		if door_controller:
			door_controller.seal_room_doors(room)
	elif room.room_type == DungeonRoom.RoomType.SECRET:
		EventBus.dungeon_secret_room_found.emit(room_index)


func _setup_subsystems() -> void:
	var width: int = dungeon_data.get("width", Constants.DUNGEON_WIDTH)
	var height: int = dungeon_data.get("height", Constants.DUNGEON_HEIGHT)
	
	# Fog of War
	fog_of_war = FogOfWar.new()
	fog_of_war.name = "FogOfWar"
	game_world.add_child(fog_of_war)
	fog_of_war.initialize(width, height)
	
	# Door Controller
	door_controller = DoorController.new()
	door_controller.name = "DoorController"
	game_world.add_child(door_controller)
	
	# Enemy Spawner
	enemy_spawner = DungeonEnemySpawner.new()
	enemy_spawner.name = "DungeonEnemySpawner"
	game_world.add_child(enemy_spawner)
	
	# Loot Spawner
	loot_spawner = DungeonLootSpawner.new()
	loot_spawner.name = "DungeonLootSpawner"
	game_world.add_child(loot_spawner)
	
	# Minimap
	minimap = DungeonMinimap.new()
	minimap.name = "DungeonMinimap"
	# Add to CanvasLayer for UI
	var ui_layer := CanvasLayer.new()
	ui_layer.name = "DungeonUILayer"
	ui_layer.layer = 10
	game_world.add_child(ui_layer)
	ui_layer.add_child(minimap)
	minimap.position = Vector2(
		Constants.VIEWPORT_SIZE.x - 170,
		10
	)
	
	# Ambient lighting (biome theme alapján)
	if biome_theme:
		var canvas_mod := CanvasModulate.new()
		canvas_mod.name = "DungeonAmbient"
		canvas_mod.color = biome_theme.ambient_color
		game_world.add_child(canvas_mod)


func _setup_doors() -> void:
	if not door_controller or not dungeon_entities:
		return
	
	for room in rooms:
		for door_data in room.doors:
			var pos: Vector2i = door_data["pos"]
			var world_pos := Vector2(
				pos.x * Constants.TILE_SIZE + Constants.TILE_SIZE / 2,
				pos.y * Constants.TILE_SIZE + Constants.TILE_SIZE / 2
			)
			var door_type: String = door_data.get("door_type", "normal")
			var initial_state := DoorController.DoorState.OPEN
			if door_type == "boss":
				initial_state = DoorController.DoorState.LOCKED
			elif door_type == "hidden":
				initial_state = DoorController.DoorState.CLOSED
			
			door_controller.create_door(world_pos, initial_state, dungeon_entities)


func _find_entrance_position() -> Vector2:
	for room in rooms:
		if room.room_type == DungeonRoom.RoomType.ENTRANCE:
			var center := room.get_center()
			return Vector2(center.x * Constants.TILE_SIZE, center.y * Constants.TILE_SIZE)
	# Fallback: első szoba
	if rooms.size() > 0:
		var center := rooms[0].get_center()
		return Vector2(center.x * Constants.TILE_SIZE, center.y * Constants.TILE_SIZE)
	return Vector2.ZERO


func _create_biome_theme(biome_type: Enums.BiomeType) -> BiomeThemeBase:
	match biome_type:
		Enums.BiomeType.CURSED_FOREST: return ThemeCursedForest.new()
		Enums.BiomeType.DARK_SWAMP: return ThemeDarkSwamp.new()
		Enums.BiomeType.RUINS: return ThemeRuins.new()
		Enums.BiomeType.MOUNTAINS: return ThemeMountains.new()
		Enums.BiomeType.FROZEN_WASTES: return ThemeFrozenWastes.new()
		Enums.BiomeType.ASHLANDS: return ThemeAshlands.new()
		Enums.BiomeType.PLAGUE_LANDS: return ThemePlagueLands.new()
		_: return BiomeThemeBase.new()


func _hide_overworld() -> void:
	# Overworld tilemap layerek elrejtése
	for child in game_world.get_children():
		if child is TileMapLayer:
			child.visible = false
	
	# Overworld entityk elrejtése
	if game_world.has_node("EntityLayer/Enemies"):
		game_world.get_node("EntityLayer/Enemies").visible = false
	if game_world.has_node("EntityLayer/NPCs"):
		game_world.get_node("EntityLayer/NPCs").visible = false


func _show_overworld() -> void:
	for child in game_world.get_children():
		if child is TileMapLayer:
			child.visible = true
	
	if game_world.has_node("EntityLayer/Enemies"):
		game_world.get_node("EntityLayer/Enemies").visible = true
	if game_world.has_node("EntityLayer/NPCs"):
		game_world.get_node("EntityLayer/NPCs").visible = true


func _create_dungeon_layers() -> void:
	# Dungeon TileMap
	dungeon_tilemap = TileMapLayer.new()
	dungeon_tilemap.name = "DungeonTileMap"
	
	# Egyszerű dungeon tileset
	var ts := TileSet.new()
	ts.tile_size = Vector2i(Constants.TILE_SIZE, Constants.TILE_SIZE)
	
	# Source: szürke padló és sötét fal
	var source := TileSetAtlasSource.new()
	var tex := PlaceholderTexture2D.new()
	tex.size = Vector2(Constants.TILE_SIZE * 8, Constants.TILE_SIZE * 8)
	source.texture = tex
	source.texture_region_size = Vector2i(Constants.TILE_SIZE, Constants.TILE_SIZE)
	
	for x in 8:
		for y in 8:
			source.create_tile(Vector2i(x, y))
	
	ts.add_source(source)
	dungeon_tilemap.tile_set = ts
	dungeon_tilemap.z_index = -10
	game_world.add_child(dungeon_tilemap)
	
	# Decoration layer
	decoration_layer = Node2D.new()
	decoration_layer.name = "DungeonDecorations"
	decoration_layer.y_sort_enabled = true
	game_world.add_child(decoration_layer)
	
	# Entity container
	dungeon_entities = Node2D.new()
	dungeon_entities.name = "DungeonEntities"
	dungeon_entities.y_sort_enabled = true
	game_world.add_child(dungeon_entities)


func _populate_dungeon(dungeon_data_dict: Dictionary) -> void:
	var room_list: Array = dungeon_data_dict.get("rooms", [])
	var difficulty: int = dungeon_data_dict.get("difficulty", 1)
	
	for room_dict in room_list:
		if not room_dict is DungeonRoom:
			continue
		var room: DungeonRoom = room_dict
		
		# Biome theme dekoráció
		if biome_theme and decoration_layer:
			biome_theme.decorate_room(room, decoration_layer)
		
		match room.room_type:
			DungeonRoom.RoomType.COMBAT:
				_spawn_room_enemies(room)
			DungeonRoom.RoomType.TREASURE:
				_spawn_chest(room)
			DungeonRoom.RoomType.TRAP:
				_spawn_traps(room)
			DungeonRoom.RoomType.PUZZLE:
				_setup_puzzle_room(room)
			DungeonRoom.RoomType.SAFE:
				_setup_safe_room(room)
			DungeonRoom.RoomType.BOSS:
				_prepare_boss_room(room)
		
		# Unique room per biome theme
		if biome_theme and room.room_type == DungeonRoom.RoomType.TREASURE:
			if randf() < 0.3:  # 30% esély egyedi terem
				biome_theme.create_unique_room(room, decoration_layer)


func _spawn_room_enemies(room: DungeonRoom) -> void:
	if enemy_spawner:
		var biome_enum: Enums.BiomeType = current_dungeon_biome as Enums.BiomeType
		enemy_spawner.spawn_room_enemies(
			room, biome_enum, current_dungeon_level, 
			dungeon_data.get("difficulty", 1), current_floor, dungeon_entities
		)
		return
	
	# Fallback: közvetlen spawn
	var biome_type: Enums.BiomeType = current_dungeon_biome as Enums.BiomeType
	var spawn_table := EnemyDatabase.get_spawn_table(biome_type)
	if not spawn_table:
		return
	
	var enemy_count := randi_range(2, 4 + current_dungeon_tier)
	var center := Vector2(room.center.x * Constants.TILE_SIZE, room.center.y * Constants.TILE_SIZE)
	
	for i in enemy_count:
		var roll := spawn_table.roll_spawn(current_dungeon_level)
		if roll.is_empty():
			continue
		
		var enemy := EnemyBase.new()
		enemy.enemy_data = roll["enemy_data"]
		enemy.enemy_level = roll["level"]
		
		var offset := Vector2(
			randf_range(-room.size.x * Constants.TILE_SIZE * 0.3, room.size.x * Constants.TILE_SIZE * 0.3),
			randf_range(-room.size.y * Constants.TILE_SIZE * 0.3, room.size.y * Constants.TILE_SIZE * 0.3)
		)
		enemy.global_position = center + offset
		dungeon_entities.add_child(enemy)


func _spawn_chest(room: DungeonRoom) -> void:
	if loot_spawner:
		loot_spawner.spawn_room_loot(room, dungeon_data.get("difficulty", 1), dungeon_entities)
		return
	
	# Fallback
	var chest := ChestSystem.create_chest(current_dungeon_level, current_dungeon_tier)
	var center := Vector2(room.center.x * Constants.TILE_SIZE, room.center.y * Constants.TILE_SIZE)
	chest.global_position = center
	dungeon_entities.add_child(chest)


func _spawn_traps(room: DungeonRoom) -> void:
	var trap_count := randi_range(2, 4 + current_dungeon_tier)
	var center := Vector2(room.center.x * Constants.TILE_SIZE, room.center.y * Constants.TILE_SIZE)
	
	for i in trap_count:
		var offset := Vector2(
			randf_range(-room.size.x * Constants.TILE_SIZE * 0.3, room.size.x * Constants.TILE_SIZE * 0.3),
			randf_range(-room.size.y * Constants.TILE_SIZE * 0.3, room.size.y * Constants.TILE_SIZE * 0.3)
		)
		var trap := TrapSystem.create_random_trap(current_dungeon_level)
		trap.global_position = center + offset
		dungeon_entities.add_child(trap)


func _setup_puzzle_room(room: DungeonRoom) -> void:
	if not room.puzzle_data or room.puzzle_data.is_empty():
		return
	
	var puzzle_type: String = room.puzzle_data.get("type", "switch_order")
	var puzzle: PuzzleBase = null
	
	match puzzle_type:
		"switch_order":
			puzzle = SwitchPuzzle.new()
		"pressure_plate":
			puzzle = PressurePlatePuzzle.new()
		"light_beam":
			puzzle = LightBeamPuzzle.new()
		"symbol_match":
			puzzle = SymbolMatchPuzzle.new()
		"timed":
			puzzle = TimedChallengePuzzle.new()
	
	if puzzle:
		puzzle.room_ref = room
		puzzle.difficulty = dungeon_data.get("difficulty", 1)
		var center := room.get_world_center()
		puzzle.position = center
		dungeon_entities.add_child(puzzle)
		puzzle.setup(room.puzzle_data)
		
		# Puzzle solved/failed signals
		puzzle.puzzle_solved.connect(func():
			EventBus.dungeon_puzzle_solved.emit(puzzle_type, room.room_index)
			room.is_cleared = true
		)
		puzzle.puzzle_failed.connect(func():
			EventBus.dungeon_puzzle_failed.emit(puzzle_type, room.room_index)
		)


func _setup_safe_room(room: DungeonRoom) -> void:
	room.is_cleared = true
	var center := room.get_world_center()
	
	# Heal fountain
	if loot_spawner:
		loot_spawner.spawn_heal_fountain(center, dungeon_entities)


func _prepare_boss_room(room: DungeonRoom) -> void:
	var center := Vector2(room.center.x * Constants.TILE_SIZE, room.center.y * Constants.TILE_SIZE)
	
	# Boss arena layout (RoomFactory)
	if room_factory:
		room_factory.create_boss_arena(room, dungeon_entities)
	
	# Boss kiválasztás biome + tier alapján
	var boss_data: BossData = BossDatabase.get_boss_for_biome(current_dungeon_biome)
	if not boss_data:
		var all_bosses := BossDatabase.get_all_bosses()
		for bd in all_bosses:
			if bd.tier == current_dungeon_tier:
				boss_data = bd
				break
	
	if boss_data:
		dungeon_boss = BossDatabase.create_boss_instance(boss_data.boss_id)
		dungeon_boss.global_position = center
		dungeon_entities.add_child(dungeon_boss)
		
		EventBus.boss_defeated.connect(_on_boss_defeated)


func _on_boss_defeated(_boss_id: String) -> void:
	# Boss room unseal
	for room in rooms:
		if room.room_type == DungeonRoom.RoomType.BOSS:
			room.is_cleared = true
			room.is_sealed = false
			if door_controller:
				door_controller.unseal_room_doors(room)
			break
	
	print("DungeonManager: Boss defeated! Exit portal opened.")
	get_tree().create_timer(5.0).timeout.connect(exit_dungeon)


func on_room_entered(room_index: int) -> void:
	if room_index == current_room_index:
		return
	_on_room_entered(room_index)


func on_room_cleared(room_index: int) -> void:
	if room_index not in cleared_rooms:
		cleared_rooms.append(room_index)
		
		var room: DungeonRoom = rooms[room_index] if room_index < rooms.size() else null
		if room:
			room.is_cleared = true
			room.is_sealed = false
			if door_controller:
				door_controller.unseal_room_doors(room)
			EventBus.dungeon_room_unsealed.emit(room_index)
		
		EventBus.room_cleared.emit(room_index)


## Emelet váltás (többemeletes dungeon-öknél)
func change_floor(floor_index: int) -> void:
	if floor_index == current_floor:
		return
	
	current_floor = floor_index
	EventBus.dungeon_floor_changed.emit(floor_index)
	
	# Újragenerálás az új emelethez (ugyanaz a seed + floor offset)
	var floor_seed: int = dungeon_data.get("seed", 0) + floor_index * 1000
	var biome_enum: Enums.BiomeType = current_dungeon_biome as Enums.BiomeType
	var new_data := generator.generate_dungeon(floor_seed, current_dungeon_tier, biome_enum)
	
	# Cleanup és újraépítés
	_cleanup_dungeon_content()
	rooms = new_data.get("rooms", [])
	dungeon_data = new_data
	
	generator.render_to_tilemap(dungeon_tilemap)
	_populate_dungeon(new_data)
	_setup_doors()
	
	# Player az új emelet entrance-jéhez
	var entrance_pos := _find_entrance_position()
	if player_ref:
		player_ref.global_position = entrance_pos
	
	if fog_of_war:
		fog_of_war.initialize(
			new_data.get("width", Constants.DUNGEON_WIDTH),
			new_data.get("height", Constants.DUNGEON_HEIGHT)
		)


func _cleanup_dungeon_content() -> void:
	# Csak a tartalmat töröljük, a layer-eket megtartjuk
	if dungeon_entities and is_instance_valid(dungeon_entities):
		for child in dungeon_entities.get_children():
			child.queue_free()
	if decoration_layer and is_instance_valid(decoration_layer):
		for child in decoration_layer.get_children():
			child.queue_free()
	cleared_rooms.clear()
	current_room_index = -1


func _cleanup_dungeon() -> void:
	if dungeon_tilemap and is_instance_valid(dungeon_tilemap):
		dungeon_tilemap.queue_free()
		dungeon_tilemap = null
	
	if dungeon_entities and is_instance_valid(dungeon_entities):
		dungeon_entities.queue_free()
		dungeon_entities = null
	
	if decoration_layer and is_instance_valid(decoration_layer):
		decoration_layer.queue_free()
		decoration_layer = null
	
	# Alrendszer cleanup
	if fog_of_war and is_instance_valid(fog_of_war):
		fog_of_war.clear()
		fog_of_war.queue_free()
		fog_of_war = null
	
	if door_controller and is_instance_valid(door_controller):
		door_controller.queue_free()
		door_controller = null
	
	if enemy_spawner and is_instance_valid(enemy_spawner):
		enemy_spawner.queue_free()
		enemy_spawner = null
	
	if loot_spawner and is_instance_valid(loot_spawner):
		loot_spawner.queue_free()
		loot_spawner = null
	
	if minimap and is_instance_valid(minimap):
		minimap.queue_free()
		minimap = null
	
	# UI layer cleanup
	if game_world.has_node("DungeonUILayer"):
		game_world.get_node("DungeonUILayer").queue_free()
	
	# Ambient lighting cleanup
	if game_world.has_node("DungeonAmbient"):
		game_world.get_node("DungeonAmbient").queue_free()


## Multiplayer sync adat
func get_sync_data() -> Dictionary:
	return {
		"seed": dungeon_data.get("seed", 0),
		"tier": current_dungeon_tier,
		"biome": current_dungeon_biome,
		"level": current_dungeon_level,
		"floor": current_floor,
		"cleared_rooms": cleared_rooms,
		"door_states": door_controller.get_sync_data() if door_controller else {},
	}


## Multiplayer sync apply
func apply_sync_data(sync_data: Dictionary) -> void:
	if door_controller and sync_data.has("door_states"):
		door_controller.apply_sync_data(sync_data["door_states"])

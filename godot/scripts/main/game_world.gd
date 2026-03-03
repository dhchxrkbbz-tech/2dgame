## GameWorld - Fő gameplay világ scene
## Összefogja a player, map, entity layer-eket
## Procedurális világ generálás és chunk-alapú renderelés
extends Node2D

@onready var entity_layer: Node2D = $EntityLayer
@onready var players_layer: Node2D = $EntityLayer/Players
@onready var enemies_layer: Node2D = $EntityLayer/Enemies
@onready var dropped_items_layer: Node2D = $EntityLayer/DroppedItems
@onready var projectile_layer: Node2D = $ProjectileLayer
@onready var effect_layer: Node2D = $EffectLayer
@onready var canvas_modulate: CanvasModulate = $WorldEnvironment

var player_scene: PackedScene = preload("res://scenes/player/player.tscn")

# === Procedurális világ TileMap layer-ek ===
var tile_map_ground: TileMapLayer
var tile_map_decoration: TileMapLayer
var tile_map_overlay: TileMapLayer

# Player referencia
var player_instance: CharacterBody2D = null

# Sub-system referenciák
var enemy_spawner: EnemySpawner = null
var dungeon_manager: DungeonManager = null

# Világ seed (állítható a scene-ben vagy kódból)
@export var world_seed: int = -1  # -1 = random
@export var world_size: int = 512  # Chunk-okban (256=kis, 512=közepes, 1024=nagy)


func _ready() -> void:
	GameManager.register_game_world(self)

	# Procedurális tile map-ok létrehozása
	_setup_tile_maps()
	
	# Sub-rendszerek inicializálása
	_setup_subsystems()

	# WorldManager-rel világ generálás
	WorldManager.world_ready.connect(_on_world_ready)
	WorldManager.setup_tilemaps(tile_map_ground, tile_map_decoration, tile_map_overlay)
	WorldManager.setup_environment(canvas_modulate)
	WorldManager.generate_world(world_seed, world_size)
	
	# Event Bus kapcsolatok
	_connect_signals()


func _setup_tile_maps() -> void:
	# Dinamikus TileSet generálása
	var tileset: TileSet = WorldTileSetBuilder.create_world_tileset()

	# Ground layer
	tile_map_ground = TileMapLayer.new()
	tile_map_ground.name = "GroundLayer"
	tile_map_ground.tile_set = tileset
	tile_map_ground.z_index = -10
	add_child(tile_map_ground)
	move_child(tile_map_ground, 0)

	# Decoration layer
	tile_map_decoration = TileMapLayer.new()
	tile_map_decoration.name = "DecorationLayer"
	tile_map_decoration.tile_set = tileset
	tile_map_decoration.z_index = -5
	add_child(tile_map_decoration)
	move_child(tile_map_decoration, 1)

	# Overlay layer
	tile_map_overlay = TileMapLayer.new()
	tile_map_overlay.name = "OverlayLayer"
	tile_map_overlay.tile_set = tileset
	tile_map_overlay.z_index = -1
	add_child(tile_map_overlay)
	move_child(tile_map_overlay, 2)


func _on_world_ready(spawn_point: Vector2) -> void:
	# Spawn pont pixel koordinátákra
	var spawn_pos := Vector2(
		spawn_point.x * Constants.TILE_SIZE,
		spawn_point.y * Constants.TILE_SIZE
	)
	_spawn_player(spawn_pos)
	
	# Enemy spawner aktiválás playerrel
	if enemy_spawner:
		enemy_spawner.player_ref = player_instance
	
	# Dungeon bejáratok spawning
	if WorldManager.dungeon_placer:
		WorldManager.dungeon_placer.spawn_dungeon_entrances(entity_layer)
	
	GameManager.start_game()
	print("GameWorld: World ready, player spawned at %s" % str(spawn_pos))


func _spawn_player(spawn_pos: Vector2 = Vector2.ZERO) -> void:
	player_instance = player_scene.instantiate()
	player_instance.global_position = spawn_pos
	players_layer.add_child(player_instance)

	# Placeholder sprite beállítás
	var sprite: Sprite2D = player_instance.get_node("Sprite2D")
	if sprite:
		sprite.texture = PlaceholderSprites.create_player_placeholder(
			player_instance.player_class
		)

	# WorldManager-nek regisztrálás
	WorldManager.register_player(player_instance)


func _process(_delta: float) -> void:
	# Játékos pozíció frissítése a WorldManager-nek
	if player_instance and WorldManager.is_world_ready:
		WorldManager.update_player_position(player_instance.global_position)
	
	# Enemy spawner cleanup (10 másodpercenként)
	if enemy_spawner and Engine.get_frames_drawn() % 600 == 0:
		enemy_spawner.cleanup_dead()


func spawn_entity(entity_scene: PackedScene, pos: Vector2, parent: Node2D = null) -> Node:
	var instance := entity_scene.instantiate()
	instance.global_position = pos
	if parent:
		parent.add_child(instance)
	else:
		entity_layer.add_child(instance)
	return instance


## Ellenség node hozzáadása a világhoz
func add_enemy(enemy: Node2D, pos: Vector2) -> void:
	enemy.global_position = pos
	enemies_layer.add_child(enemy)


## Projectile hozzáadása
func add_projectile(projectile: Node2D, pos: Vector2) -> void:
	projectile.global_position = pos
	projectile_layer.add_child(projectile)


## Effekt hozzáadása
func add_effect(effect: Node2D, pos: Vector2) -> void:
	effect.global_position = pos
	effect_layer.add_child(effect)


## Dropped item hozzáadása a világhoz
func add_dropped_item(item: Node2D, pos: Vector2) -> void:
	item.global_position = pos
	dropped_items_layer.add_child(item)


## Loot drop kényelmi metódus — enemy halála után
func drop_loot(enemy_pos: Vector2, enemy_level: int, tier: String = "normal", magic_find: float = 0.0) -> void:
	var items := LootGenerator.generate_enemy_loot(enemy_level, tier, magic_find)
	for item in items:
		var drop := DroppedItem.create_item_drop(item, enemy_pos)
		dropped_items_layer.add_child(drop)
	
	var gold := LootGenerator.generate_gold(enemy_level, tier)
	if gold > 0:
		var gold_drop := DroppedItem.create_gold_drop(gold, enemy_pos)
		dropped_items_layer.add_child(gold_drop)


## Dungeon belépés
func enter_dungeon(tier: int, biome: int, level: int) -> void:
	if dungeon_manager:
		dungeon_manager.enter_dungeon(tier, biome, level, player_instance.global_position)


## Dungeon kilépés
func exit_dungeon() -> void:
	if dungeon_manager:
		dungeon_manager.exit_dungeon()


# === Sub-rendszerek ===

func _setup_subsystems() -> void:
	# Enemy Spawner
	enemy_spawner = EnemySpawner.new()
	enemy_spawner.name = "EnemySpawner"
	add_child(enemy_spawner)
	enemy_spawner.initialize(enemies_layer)
	
	# Dungeon Manager
	dungeon_manager = DungeonManager.new()
	dungeon_manager.name = "DungeonManager"
	add_child(dungeon_manager)
	dungeon_manager.initialize(self, enemies_layer)
	
	# Item Database inicializálás
	ItemDatabase.initialize()


func _connect_signals() -> void:
	# Entity killed → loot drop
	EventBus.entity_killed.connect(_on_entity_killed)
	
	# Item pickup
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.gold_collected.connect(_on_gold_collected)


func _on_entity_killed(_killer: Variant, victim: Variant) -> void:
	if victim is EnemyBase and is_instance_valid(victim):
		var tier := "normal"
		if victim.is_elite:
			tier = "elite"
		drop_loot(victim.global_position, victim.enemy_level, tier)


func _on_item_picked_up(item_instance: Variant) -> void:
	# TODO: Inventory rendszerbe helyezés
	if item_instance is ItemInstance:
		print("Picked up: %s" % item_instance.get_display_name())


func _on_gold_collected(amount: int) -> void:
	# TODO: Player gold hozzáadás
	print("Collected %d gold" % amount)

## SyncManager - Központi szinkronizáció koordinátor
## Kezeli az összes sub-sync managert
extends Node

var player_sync: Node
var enemy_sync: Node
var projectile_sync: Node
var loot_sync: Node
var world_sync: Node
var combat_sync: Node
var animation_sync: Node

func _ready() -> void:
	_setup_sync_managers()
	NetworkManager.network_tick.connect(_on_network_tick)

func _setup_sync_managers() -> void:
	player_sync = preload("res://scripts/multiplayer/sync/player_sync.gd").new()
	player_sync.name = "PlayerSyncManager"
	add_child(player_sync)
	
	enemy_sync = preload("res://scripts/multiplayer/sync/enemy_sync.gd").new()
	enemy_sync.name = "EnemySyncManager"
	add_child(enemy_sync)
	
	projectile_sync = preload("res://scripts/multiplayer/sync/projectile_sync.gd").new()
	projectile_sync.name = "ProjectileSyncManager"
	add_child(projectile_sync)
	
	loot_sync = preload("res://scripts/multiplayer/sync/loot_sync.gd").new()
	loot_sync.name = "LootSyncManager"
	add_child(loot_sync)
	
	world_sync = preload("res://scripts/multiplayer/sync/world_sync.gd").new()
	world_sync.name = "WorldSyncManager"
	add_child(world_sync)
	
	combat_sync = preload("res://scripts/multiplayer/sync/combat_sync.gd").new()
	combat_sync.name = "CombatSyncManager"
	add_child(combat_sync)
	
	animation_sync = preload("res://scripts/multiplayer/sync/animation_sync.gd").new()
	animation_sync.name = "AnimationSyncManager"
	add_child(animation_sync)

func reset() -> void:
	player_sync.reset()
	enemy_sync.reset()
	projectile_sync.reset()
	loot_sync.reset()
	world_sync.reset()
	combat_sync.reset()
	animation_sync.reset()

func _on_network_tick(tick_number: int) -> void:
	if NetworkManager.is_server():
		_server_tick(tick_number)
	else:
		_client_tick(tick_number)

func _server_tick(tick_number: int) -> void:
	# Server broadcasts state every tick
	player_sync.server_broadcast_positions()
	
	# Enemies sync at half rate (10 tick/sec)
	if tick_number % 2 == 0:
		enemy_sync.server_broadcast_states()
	
	# Animation sync at quarter rate (5 tick/sec)
	if tick_number % 4 == 0:
		animation_sync.server_broadcast_animations()

func _client_tick(tick_number: int) -> void:
	# Client sends input every tick
	player_sync.client_send_input()

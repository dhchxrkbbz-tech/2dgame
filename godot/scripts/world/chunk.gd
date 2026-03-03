## Chunk - Egy chunk vizuális megjelenítése és logikája
## Node2D scene script - a ChunkData-t visual-ra konvertálja
class_name Chunk
extends Node2D

var chunk_data: ChunkData = null
var chunk_pos: Vector2i = Vector2i.ZERO
var is_active: bool = false
var is_loaded: bool = false

# Gyerek node-ok
var tilemap: TileMapLayer = null
var decoration_container: Node2D = null
var enemy_container: Node2D = null
var resource_container: Node2D = null
var poi_container: Node2D = null

# Spawned entity tracking
var spawned_enemies: Array[Node] = []
var spawned_resources: Array[Node] = []


func _ready() -> void:
	_create_containers()


func _create_containers() -> void:
	tilemap = TileMapLayer.new()
	tilemap.name = "TileMap"
	add_child(tilemap)
	
	decoration_container = Node2D.new()
	decoration_container.name = "Decorations"
	add_child(decoration_container)
	
	resource_container = Node2D.new()
	resource_container.name = "Resources"
	add_child(resource_container)
	
	enemy_container = Node2D.new()
	enemy_container.name = "Enemies"
	add_child(enemy_container)
	
	poi_container = Node2D.new()
	poi_container.name = "POIs"
	add_child(poi_container)


## Chunk inicializálás ChunkData alapján
func initialize(data: ChunkData) -> void:
	chunk_data = data
	chunk_pos = data.chunk_pos
	position = Vector2(
		chunk_pos.x * Constants.CHUNK_SIZE * Constants.TILE_SIZE,
		chunk_pos.y * Constants.CHUNK_SIZE * Constants.TILE_SIZE
	)
	_build_tiles()
	_place_decorations()
	_spawn_resources()
	is_loaded = true


## Tile-ok lerakása
func _build_tiles() -> void:
	if not chunk_data or not tilemap:
		return
	
	for x in Constants.CHUNK_SIZE:
		for y in Constants.CHUNK_SIZE:
			var tile_id: int = chunk_data.get_tile(x, y)
			var pos := Vector2i(x, y)
			tilemap.set_cell(pos, 0, Vector2i(tile_id % 16, tile_id / 16))


## Dekoráció elhelyezése
func _place_decorations() -> void:
	if not chunk_data:
		return
	
	for deco in chunk_data.decorations:
		var sprite := Sprite2D.new()
		sprite.position = deco.get("pos", Vector2.ZERO)
		# Placeholder texture - a valós implementáció biome-specifikus sprite-okat használna
		decoration_container.add_child(sprite)


## Nyersanyag node-ok elhelyezése
func _spawn_resources() -> void:
	if not chunk_data:
		return
	
	for poi in chunk_data.pois:
		if poi.get("type", "") == "resource":
			var resource_node := ResourceNode.new()
			resource_node.position = poi.get("pos", Vector2.ZERO)
			resource_node.resource_type = poi.get("resource_type", "stone")
			resource_node.biome = chunk_data.biome
			resource_container.add_child(resource_node)
			spawned_resources.append(resource_node)


## Ellenségek spawnolása
func spawn_enemies(enemy_list: Array[Dictionary]) -> void:
	for enemy_info in enemy_list:
		# EnemySpawner-nek delegáljuk
		var pos: Vector2 = enemy_info.get("pos", Vector2.ZERO)
		EventBus.enemy_spawn_requested.emit(enemy_info, pos + position)


## Chunk aktiválás/deaktiválás
func activate() -> void:
	is_active = true
	visible = true
	set_process(true)
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.set_process(true)
			enemy.set_physics_process(true)


func deactivate() -> void:
	is_active = false
	visible = false
	set_process(false)
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.set_process(false)
			enemy.set_physics_process(false)


## Chunk cleanup
func cleanup() -> void:
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	
	for res in spawned_resources:
		if is_instance_valid(res):
			res.queue_free()
	spawned_resources.clear()
	
	is_loaded = false


## Serialize
func serialize() -> Dictionary:
	return {
		"chunk_pos": {"x": chunk_pos.x, "y": chunk_pos.y},
		"modified": chunk_data.modified if chunk_data else false,
	}

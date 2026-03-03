## SpawnTable - Biome-specifikus enemy spawn meghatározás
## Tartalmazza az összes biome-hoz tartozó enemy definíciókat
class_name SpawnTable
extends RefCounted

## Entry egy spawn táblában
class SpawnEntry:
	var enemy_data: EnemyData
	var weight: float
	var min_level: int
	var max_level: int
	var pack_size: Vector2i  # min, max
	
	func _init(data: EnemyData, w: float, lvl_min: int, lvl_max: int, pack: Vector2i = Vector2i(1, 1)) -> void:
		enemy_data = data
		weight = w
		min_level = lvl_min
		max_level = lvl_max
		pack_size = pack

var entries: Array[SpawnEntry] = []
var biome: Enums.BiomeType


func add_entry(data: EnemyData, weight: float, lvl_min: int, lvl_max: int, pack: Vector2i = Vector2i(1, 1)) -> void:
	entries.append(SpawnEntry.new(data, weight, lvl_min, lvl_max, pack))


func roll_spawn(level_override: int = -1) -> Dictionary:
	## Visszatérés: {"enemy_data": EnemyData, "level": int, "pack_size": int}
	if entries.is_empty():
		return {}
	
	# Weighted random kiválasztás
	var total_weight: float = 0.0
	for entry in entries:
		total_weight += entry.weight
	
	var roll: float = randf() * total_weight
	var current: float = 0.0
	
	for entry in entries:
		current += entry.weight
		if roll <= current:
			var level := level_override if level_override > 0 else randi_range(entry.min_level, entry.max_level)
			var pack_count := randi_range(entry.pack_size.x, entry.pack_size.y)
			return {
				"enemy_data": entry.enemy_data,
				"level": level,
				"pack_size": pack_count,
			}
	
	return {}

## DungeonPlacer - Dungeon bejárat spawn a világban
## Biome difficulty + distance from start → dungeon tier
class_name DungeonPlacer
extends Node

var noise_manager: NoiseManager
var biome_resolver: BiomeResolver
var rng: RandomNumberGenerator

# Dungeon bejárat adatok
var dungeon_entries: Array[Dictionary] = []


func initialize(
	p_noise_manager: NoiseManager,
	p_biome_resolver: BiomeResolver,
	seed_value: int
) -> void:
	noise_manager = p_noise_manager
	biome_resolver = p_biome_resolver
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value + 70000


## Dungeon bejáratok feldolgozása a POI-kból
func process_dungeon_pois(dungeon_pois: Array[Dictionary]) -> void:
	dungeon_entries.clear()

	for poi in dungeon_pois:
		var pos: Vector2 = poi["pos"]
		var data: Dictionary = poi.get("data", {})
		var tier: int = data.get("tier", 1)
		var biome_type = data.get("biome", Enums.BiomeType.STARTING_MEADOW)

		var entry: Dictionary = {
			"pos": pos,
			"tier": tier,
			"biome": biome_type,
			"name": data.get("name", "Unknown Dungeon"),
			"room_count": _get_room_count(tier),
			"enemy_level_range": _get_enemy_level_range(tier),
			"has_boss": tier >= 3,
			"loot_multiplier": 1.0 + tier * 0.25,
			"discovered": false,
			"cleared": false,
		}

		dungeon_entries.append(entry)

	print("DungeonPlacer: Processed %d dungeon entries" % dungeon_entries.size())


## Szobaszám a tier alapján
func _get_room_count(tier: int) -> int:
	match tier:
		1: return rng.randi_range(3, 5)  # Mini dungeon
		2: return rng.randi_range(6, 10)  # Standard
		3: return rng.randi_range(10, 15)  # Large
		4: return rng.randi_range(15, 25)  # Raid
		_: return 5


## Ellenség szint tartomány a tier alapján
func _get_enemy_level_range(tier: int) -> Dictionary:
	match tier:
		1: return {"min": 1, "max": 10}
		2: return {"min": 8, "max": 20}
		3: return {"min": 15, "max": 35}
		4: return {"min": 25, "max": 50}
		_: return {"min": 1, "max": 10}


## Legközelebbi dungeon bejárat keresése
func get_nearest_dungeon(pos: Vector2) -> Dictionary:
	var nearest: Dictionary = {}
	var nearest_dist: float = INF

	for entry in dungeon_entries:
		var dist: float = pos.distance_to(entry["pos"])
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = entry

	return nearest


## Dungeon-ök lekérdezése tier szerint
func get_dungeons_by_tier(tier: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in dungeon_entries:
		if entry["tier"] == tier:
			result.append(entry)
	return result


## Dungeon felfedezettnek jelölése
func mark_discovered(dungeon_name: String) -> void:
	for entry in dungeon_entries:
		if entry["name"] == dungeon_name:
			entry["discovered"] = true
			break


## Dungeon teljesítettnek jelölése
func mark_cleared(dungeon_name: String) -> void:
	for entry in dungeon_entries:
		if entry["name"] == dungeon_name:
			entry["cleared"] = true
			break


## Dungeon-ök sugáron belül
func get_dungeons_in_radius(pos: Vector2, radius: float) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in dungeon_entries:
		if pos.distance_to(entry["pos"]) <= radius:
			result.append(entry)
	return result


## Szerializálás
func serialize() -> Array:
	return dungeon_entries.duplicate(true)


## Deszerializálás
func deserialize(data: Array) -> void:
	dungeon_entries.clear()
	for entry in data:
		dungeon_entries.append(entry)


## Dungeon entrance node-ok létrehozása a világban
func spawn_dungeon_entrances(parent: Node2D) -> Array[DungeonEntrance]:
	var entrances: Array[DungeonEntrance] = []
	for entry in dungeon_entries:
		var pos: Vector2 = entry["pos"]
		var pixel_pos := Vector2(pos.x * Constants.TILE_SIZE, pos.y * Constants.TILE_SIZE)
		var tier: int = entry.get("tier", 1)
		var biome: int = entry.get("biome", 0)
		var level_range: Dictionary = entry.get("enemy_level_range", {"min": 1, "max": 10})
		var avg_level: int = (level_range["min"] + level_range["max"]) / 2
		var dname: String = entry.get("name", "Dungeon")
		
		var entrance := DungeonEntrance.create(pixel_pos, tier, biome, avg_level, dname)
		parent.add_child(entrance)
		entrances.append(entrance)
	
	print("DungeonPlacer: Spawned %d dungeon entrance nodes" % entrances.size())
	return entrances

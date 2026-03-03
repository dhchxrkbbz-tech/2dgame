## POIGenerator - Points of Interest elhelyezés
## Város, falu, kereskedő, rom, oltár, dungeon bejárat, boss arena, barlang, teleport
class_name POIGenerator
extends Node

var rng: RandomNumberGenerator
var noise_manager: NoiseManager
var biome_resolver: BiomeResolver

# Generált POI-k listája
var all_pois: Array[Dictionary] = []
var towns: Array[Dictionary] = []
var dungeons: Array[Dictionary] = []

# POI típusok
const POI_TOWN: String = "town"
const POI_VILLAGE: String = "village"
const POI_TRADER: String = "trader"
const POI_RUIN: String = "ruin"
const POI_SHRINE: String = "shrine"
const POI_DUNGEON: String = "dungeon"
const POI_BOSS_ARENA: String = "boss_arena"
const POI_CAVE: String = "cave"
const POI_TELEPORT: String = "teleport"

# Minimum távolságok POI-k között (tile-okban)
const MIN_DISTANCE_TOWN: float = 100.0
const MIN_DISTANCE_DUNGEON: float = 40.0
const MIN_DISTANCE_GENERAL: float = 30.0

# Világ méret tile-okban (közepes világ)
var world_size: int = 512  # chunk-okban → 8192 tile
var world_tile_size: int = 8192


func initialize(
	p_noise_manager: NoiseManager,
	p_biome_resolver: BiomeResolver,
	seed_value: int,
	p_world_size: int = 512
) -> void:
	noise_manager = p_noise_manager
	biome_resolver = p_biome_resolver
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value + 50000
	world_size = p_world_size
	world_tile_size = world_size * Constants.CHUNK_SIZE


## Teljes POI generálás pipeline
func generate_all_pois(spawn_point: Vector2) -> Array[Dictionary]:
	all_pois.clear()
	towns.clear()
	dungeons.clear()

	# 1. Városok először (legfontosabbak)
	_generate_towns(spawn_point)

	# 2. Falvak
	_generate_villages()

	# 3. Dungeon bejáratok biome-onként
	_generate_dungeons()

	# 4. Boss arénák
	_generate_boss_arenas()

	# 5. Oltárok
	_generate_shrines()

	# 6. Rejtett barlangok
	_generate_caves()

	# 7. Teleport kapuk (városok közelében)
	_generate_teleports()

	# 8. Romok
	_generate_ruins()

	print("POIGenerator: Generated %d POIs total" % all_pois.size())
	return all_pois


## Városok generálása
func _generate_towns(spawn_point: Vector2) -> void:
	var count: int = rng.randi_range(3, 5)
	var search_range: int = world_tile_size / 4  # Keresési tartomány

	# Első város a spawn pont közelében
	var start_town_pos: Vector2 = _find_valid_poi_pos(
		spawn_point, 20, 50,
		Enums.BiomeType.STARTING_MEADOW,
		true
	)
	_add_poi(POI_TOWN, start_town_pos, {"name": "Haven", "size": "large", "is_start": true})
	towns.append(all_pois[-1])

	# Többi város
	for i in range(1, count):
		var center := Vector2(
			rng.randf_range(-search_range, search_range),
			rng.randf_range(-search_range, search_range)
		)
		var pos: Vector2 = _find_valid_poi_pos(center, 30, 80, -1, true, MIN_DISTANCE_TOWN)
		if pos != Vector2.INF:
			_add_poi(POI_TOWN, pos, {
				"name": "Town_%d" % i,
				"size": "medium" if rng.randf() > 0.3 else "large"
			})
			towns.append(all_pois[-1])


## Falvak generálása
func _generate_villages() -> void:
	var count: int = rng.randi_range(8, 15)
	var search_range: int = world_tile_size / 3

	for i in count:
		var center := Vector2(
			rng.randf_range(-search_range, search_range),
			rng.randf_range(-search_range, search_range)
		)
		var pos: Vector2 = _find_valid_poi_pos(center, 20, 60, -1, true, MIN_DISTANCE_GENERAL)
		if pos != Vector2.INF:
			_add_poi(POI_VILLAGE, pos, {"name": "Village_%d" % i})


## Dungeon-ök generálása biome-onként
func _generate_dungeons() -> void:
	var biome_types: Array = [
		Enums.BiomeType.STARTING_MEADOW,
		Enums.BiomeType.CURSED_FOREST,
		Enums.BiomeType.DARK_SWAMP,
		Enums.BiomeType.RUINS,
		Enums.BiomeType.MOUNTAINS,
		Enums.BiomeType.FROZEN_WASTES,
		Enums.BiomeType.ASHLANDS,
		Enums.BiomeType.PLAGUE_LANDS,
	]

	for biome_type in biome_types:
		var count: int = rng.randi_range(2, 6)
		var search_range: int = world_tile_size / 3
		var placed: int = 0

		for _attempt in 100:  # Max próbálkozás
			if placed >= count:
				break
			var center := Vector2(
				rng.randf_range(-search_range, search_range),
				rng.randf_range(-search_range, search_range)
			)
			var pos: Vector2 = _find_valid_poi_pos(
				center, 5, 20, biome_type, true, MIN_DISTANCE_DUNGEON
			)
			if pos != Vector2.INF:
				var tier: int = _calculate_dungeon_tier(pos, biome_type)
				_add_poi(POI_DUNGEON, pos, {
					"biome": biome_type,
					"tier": tier,
					"name": "Dungeon_%s_%d" % [Enums.BiomeType.keys()[biome_type], placed]
				})
				dungeons.append(all_pois[-1])
				placed += 1


## Boss arénák generálása
func _generate_boss_arenas() -> void:
	var count: int = rng.randi_range(5, 8)
	var search_range: int = world_tile_size / 3

	for i in count:
		var center := Vector2(
			rng.randf_range(-search_range, search_range),
			rng.randf_range(-search_range, search_range)
		)
		# Boss aréna magas corruption területen
		var pos: Vector2 = _find_valid_poi_pos(center, 10, 40, -1, true, 60.0)
		if pos != Vector2.INF:
			var corruption: float = noise_manager.get_corruption(pos.x, pos.y)
			if corruption > 0.4:
				_add_poi(POI_BOSS_ARENA, pos, {
					"name": "BossArena_%d" % i,
					"corruption_level": corruption,
				})


## Oltárok generálása
func _generate_shrines() -> void:
	var count: int = rng.randi_range(10, 15)
	var search_range: int = world_tile_size / 3

	for i in count:
		var center := Vector2(
			rng.randf_range(-search_range, search_range),
			rng.randf_range(-search_range, search_range)
		)
		var pos: Vector2 = _find_valid_poi_pos(center, 10, 30, -1, true, MIN_DISTANCE_GENERAL)
		if pos != Vector2.INF:
			var shrine_types: Array = ["health", "mana", "damage", "defense", "speed"]
			_add_poi(POI_SHRINE, pos, {
				"name": "Shrine_%d" % i,
				"shrine_type": shrine_types[rng.randi_range(0, shrine_types.size() - 1)],
			})


## Rejtett barlangok
func _generate_caves() -> void:
	var count: int = rng.randi_range(5, 10)
	var valid_biomes: Array = [Enums.BiomeType.MOUNTAINS, Enums.BiomeType.DARK_SWAMP]
	var search_range: int = world_tile_size / 3

	for i in count:
		var target_biome = valid_biomes[rng.randi_range(0, valid_biomes.size() - 1)]
		var center := Vector2(
			rng.randf_range(-search_range, search_range),
			rng.randf_range(-search_range, search_range)
		)
		var pos: Vector2 = _find_valid_poi_pos(center, 5, 30, target_biome, true, MIN_DISTANCE_GENERAL)
		if pos != Vector2.INF:
			_add_poi(POI_CAVE, pos, {"name": "Cave_%d" % i, "biome": target_biome})


## Teleport kapuk
func _generate_teleports() -> void:
	for town in towns:
		var town_pos: Vector2 = town["pos"]
		var offset := Vector2(
			rng.randf_range(-15, 15),
			rng.randf_range(-15, 15)
		)
		_add_poi(POI_TELEPORT, town_pos + offset, {
			"linked_town": town.get("data", {}).get("name", "Unknown"),
		})


## Romok generálása
func _generate_ruins() -> void:
	var count: int = rng.randi_range(15, 25)
	var valid_biomes: Array = [Enums.BiomeType.RUINS, Enums.BiomeType.CURSED_FOREST]
	var search_range: int = world_tile_size / 3

	for i in count:
		var center := Vector2(
			rng.randf_range(-search_range, search_range),
			rng.randf_range(-search_range, search_range)
		)
		var pos: Vector2 = _find_valid_poi_pos(center, 5, 30, -1, true, 20.0)
		if pos != Vector2.INF:
			_add_poi(POI_RUIN, pos, {"name": "Ruin_%d" % i})


## Dungeon tier meghatározás
func _calculate_dungeon_tier(pos: Vector2, biome_type: Enums.BiomeType) -> int:
	var biome_data: BiomeData = biome_resolver.get_biome_data(biome_type)
	var biome_difficulty: int = biome_data.difficulty_level if biome_data else 0
	var distance_factor: float = pos.length() / 200.0
	var corruption: float = noise_manager.get_corruption(pos.x, pos.y)
	var corruption_bonus: float = corruption * 2.0

	var tier_value: float = biome_difficulty + distance_factor + corruption_bonus
	if tier_value < 2.0:
		return 1
	elif tier_value < 4.0:
		return 2
	elif tier_value < 6.0:
		return 3
	else:
		return 4


## POI hozzáadása a listához
func _add_poi(type: String, pos: Vector2, data: Dictionary = {}) -> void:
	all_pois.append({
		"type": type,
		"pos": pos,
		"data": data,
	})


## Érvényes POI pozíció keresése (Poisson-like sampling)
func _find_valid_poi_pos(
	center: Vector2,
	min_radius: float,
	max_radius: float,
	required_biome: int = -1,  # -1 = bármelyik
	must_be_walkable: bool = true,
	min_distance_from_others: float = MIN_DISTANCE_GENERAL
) -> Vector2:
	for _attempt in 50:
		var angle: float = rng.randf() * TAU
		var dist: float = rng.randf_range(min_radius, max_radius)
		var pos := center + Vector2(cos(angle), sin(angle)) * dist

		# Biome ellenőrzés
		if required_biome >= 0:
			var biome: Enums.BiomeType = biome_resolver.get_biome(
				int(pos.x), int(pos.y), noise_manager
			)
			if biome != required_biome:
				continue

		# Járhatóság
		if must_be_walkable:
			var height: float = noise_manager.get_height(pos.x, pos.y)
			if height < 0.25 or height > 0.85:
				continue

		# Távolság más POI-któl
		var too_close: bool = false
		for existing_poi in all_pois:
			if pos.distance_to(existing_poi["pos"]) < min_distance_from_others:
				too_close = true
				break

		if not too_close:
			return pos

	return Vector2.INF  # Nem találtunk érvényes pozíciót


## POI-k lekérdezése típus szerint
func get_pois_by_type(type: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for poi in all_pois:
		if poi["type"] == type:
			result.append(poi)
	return result


## Legközelebbi POI keresése
func get_nearest_poi(pos: Vector2, type: String = "") -> Dictionary:
	var nearest: Dictionary = {}
	var nearest_dist: float = INF

	for poi in all_pois:
		if type != "" and poi["type"] != type:
			continue
		var dist: float = pos.distance_to(poi["pos"])
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = poi

	return nearest


## POI-k lekérdezése sugáron belül
func get_pois_in_radius(pos: Vector2, radius: float, type: String = "") -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for poi in all_pois:
		if type != "" and poi["type"] != type:
			continue
		if pos.distance_to(poi["pos"]) <= radius:
			result.append(poi)
	return result

## RoadGenerator - Úthálózat generálás
## A* pathfinding a POI-k között, fő és mellékutak
class_name RoadGenerator
extends Node

var noise_manager: NoiseManager
var rng: RandomNumberGenerator

# Generált utak (tile pozíciók set-je)
var road_tiles: Dictionary = {}  # Vector2i -> road_type (0=main, 1=side)
var main_roads: Array[Array] = []  # Array of path arrays
var side_roads: Array[Array] = []

# Költség szorzók az A* pathfinding-hoz
const WATER_COST: float = 100.0
const MOUNTAIN_COST: float = 50.0
const HILL_COST: float = 5.0
const FLAT_COST: float = 1.0

const MAIN_ROAD_WIDTH: int = 2
const SIDE_ROAD_WIDTH: int = 1


func initialize(p_noise_manager: NoiseManager, seed_value: int) -> void:
	noise_manager = p_noise_manager
	rng = RandomNumberGenerator.new()
	rng.seed = seed_value + 60000


## Teljes úthálózat generálás
func generate_roads(towns: Array[Dictionary], dungeons: Array[Dictionary]) -> void:
	road_tiles.clear()
	main_roads.clear()
	side_roads.clear()

	if towns.size() < 2:
		return

	# 1. Minimum Spanning Tree a városok között → fő utak
	var mst_edges: Array = _compute_mst(towns)
	for edge in mst_edges:
		var path: Array[Vector2i] = _astar_path(
			Vector2i(int(edge["from"].x), int(edge["from"].y)),
			Vector2i(int(edge["to"].x), int(edge["to"].y))
		)
		if not path.is_empty():
			_widen_path(path, MAIN_ROAD_WIDTH, 0)
			main_roads.append(path)

	# 2. Mellékutak: minden városhoz a legközelebbi 2-3 dungeon/POI
	for town in towns:
		var town_pos := Vector2(town["pos"].x, town["pos"].y)
		var nearby: Array = _get_nearest_pois(town_pos, dungeons, 3)
		for poi in nearby:
			var path: Array[Vector2i] = _astar_path(
				Vector2i(int(town_pos.x), int(town_pos.y)),
				Vector2i(int(poi["pos"].x), int(poi["pos"].y))
			)
			if not path.is_empty():
				path = _perturb_path(path, 3)
				_widen_path(path, SIDE_ROAD_WIDTH, 1)
				side_roads.append(path)

	print("RoadGenerator: Generated %d main roads, %d side roads, %d road tiles" % [
		main_roads.size(), side_roads.size(), road_tiles.size()
	])


## Minimum Spanning Tree (Prim's algorithm)
func _compute_mst(towns: Array[Dictionary]) -> Array:
	if towns.size() < 2:
		return []

	var edges: Array = []
	var in_mst: Array[bool] = []
	in_mst.resize(towns.size())
	in_mst.fill(false)
	in_mst[0] = true

	var mst_count: int = 1

	while mst_count < towns.size():
		var best_edge: Dictionary = {}
		var best_dist: float = INF

		for i in towns.size():
			if not in_mst[i]:
				continue
			for j in towns.size():
				if in_mst[j]:
					continue
				var dist: float = towns[i]["pos"].distance_to(towns[j]["pos"])
				if dist < best_dist:
					best_dist = dist
					best_edge = {
						"from": towns[i]["pos"],
						"to": towns[j]["pos"],
						"from_idx": i,
						"to_idx": j,
					}

		if best_edge.is_empty():
			break

		in_mst[best_edge["to_idx"]] = true
		edges.append(best_edge)
		mst_count += 1

	return edges


## Egyszerűsített A* pathfinding a heightmap-en
## (Nem teljes A* grid, hanem lépésenkénti irányválasztás a cél felé)
func _astar_path(from: Vector2i, to: Vector2i) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current: Vector2i = from
	var max_steps: int = int(from.distance_to(to) * 3)  # Safety limit
	var step: int = 0

	path.append(current)

	while current != to and step < max_steps:
		step += 1
		var best_next: Vector2i = current
		var best_score: float = INF

		# 8 irányú szomszéd vizsgálat
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var next := Vector2i(current.x + dx, current.y + dy)
				var height: float = noise_manager.get_height(next.x, next.y)

				# Terep költség
				var terrain_cost: float = _get_terrain_cost(height)

				# Heurisztika (távolság a céltól)
				var dist_to_goal: float = Vector2(next.x, next.y).distance_to(Vector2(to.x, to.y))

				var score: float = terrain_cost + dist_to_goal
				if score < best_score:
					best_score = score
					best_next = next

		if best_next == current:
			# Beragadtunk - egyenesen a cél felé
			var dir: Vector2 = Vector2(to.x - current.x, to.y - current.y).normalized()
			best_next = Vector2i(
				current.x + int(sign(dir.x)),
				current.y + int(sign(dir.y))
			)

		current = best_next
		path.append(current)

	return path


## Terep költség a magasság alapján
func _get_terrain_cost(height: float) -> float:
	if height < 0.25:
		return WATER_COST  # Víz - nagyon költséges
	elif height > 0.85:
		return MOUNTAIN_COST  # Hegycsúcs
	elif height > 0.70:
		return HILL_COST  # Hegy
	elif height > 0.55:
		return HILL_COST * 0.5  # Domb
	else:
		return FLAT_COST  # Sík terep


## Út szélesítése
func _widen_path(path: Array[Vector2i], width: int, road_type: int) -> void:
	for tile_pos in path:
		for dx in range(-width + 1, width):
			for dy in range(-width + 1, width):
				var pos := Vector2i(tile_pos.x + dx, tile_pos.y + dy)
				# Fő út felülírja a mellékutat, de nem fordítva
				if pos not in road_tiles or road_tiles[pos] > road_type:
					road_tiles[pos] = road_type


## Út perturbálása organikusabb kinézetért
func _perturb_path(path: Array[Vector2i], noise_amount: int) -> Array[Vector2i]:
	var perturbed: Array[Vector2i] = []
	for i in path.size():
		var tile: Vector2i = path[i]
		if i > 0 and i < path.size() - 1:  # Végpontok maradnak
			tile.x += rng.randi_range(-noise_amount, noise_amount)
			tile.y += rng.randi_range(-noise_amount, noise_amount)
		perturbed.append(tile)
	return perturbed


## Legközelebbi N POI keresése
func _get_nearest_pois(pos: Vector2, pois: Array[Dictionary], count: int) -> Array:
	# Távolság szerint rendezés
	var sorted_pois: Array = pois.duplicate()
	sorted_pois.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return pos.distance_to(a["pos"]) < pos.distance_to(b["pos"])
	)
	return sorted_pois.slice(0, mini(count, sorted_pois.size()))


## Ellenőrzés, hogy egy tile út-e
func is_road_tile(tile_pos: Vector2i) -> bool:
	return tile_pos in road_tiles


## Út típus lekérdezése (0=main, 1=side, -1=nem út)
func get_road_type(tile_pos: Vector2i) -> int:
	return road_tiles.get(tile_pos, -1)


## Közeli úton lévő pozíciók keresése (kereskedő elhelyezéshez)
func get_road_tiles_near(pos: Vector2, radius: float) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var pos_i := Vector2i(int(pos.x), int(pos.y))
	var r: int = int(radius)

	for dx in range(-r, r + 1):
		for dy in range(-r, r + 1):
			var tile := Vector2i(pos_i.x + dx, pos_i.y + dy)
			if is_road_tile(tile):
				result.append(tile)

	return result

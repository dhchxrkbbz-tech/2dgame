## Utils - Segédfüggvények
extends Node

## Lineáris interpoláció két érték között
static func lerp_float(a: float, b: float, t: float) -> float:
	return a + (b - a) * clampf(t, 0.0, 1.0)


## Távolság két pont között tile-okban
static func tile_distance(a: Vector2, b: Vector2) -> float:
	return (a - b).length() / Constants.TILE_SIZE


## Világ pozíció → tile pozíció
static func world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(world_pos.x / Constants.TILE_SIZE),
		int(world_pos.y / Constants.TILE_SIZE)
	)


## Tile pozíció → világ pozíció (közép)
static func tile_to_world(tile_pos: Vector2i) -> Vector2:
	return Vector2(
		tile_pos.x * Constants.TILE_SIZE + Constants.TILE_SIZE / 2.0,
		tile_pos.y * Constants.TILE_SIZE + Constants.TILE_SIZE / 2.0
	)


## Chunk pozíció kiszámítása világ pozícióból
static func world_to_chunk(world_pos: Vector2) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / Constants.CHUNK_PIXEL_SIZE)),
		int(floor(world_pos.y / Constants.CHUNK_PIXEL_SIZE))
	)


## Random elem egy tömbből
static func random_element(array: Array):
	if array.is_empty():
		return null
	return array[randi() % array.size()]


## Súlyozott random választás
## weights: Dictionary { elem: súly } — returns key
static func weighted_random(weights) -> int:
	if weights is Dictionary:
		var total_weight: float = 0.0
		for w in weights.values():
			total_weight += w
		var roll := randf() * total_weight
		var cumulative: float = 0.0
		for key in weights:
			cumulative += weights[key]
			if roll <= cumulative:
				return key
		return weights.keys().back()
	elif weights is Array:
		# Array variant: returns index
		var total_weight: float = 0.0
		for w in weights:
			total_weight += w
		var roll := randf() * total_weight
		var cumulative: float = 0.0
		for i in weights.size():
			cumulative += weights[i]
			if roll <= cumulative:
				return i
		return weights.size() - 1
	return 0


## Szám formázás (1234 → "1,234")
static func format_number(n: int) -> String:
	var s := str(abs(n))
	var result := ""
	for i in range(s.length() - 1, -1, -1):
		result = s[i] + result
		if (s.length() - i) % 3 == 0 and i > 0:
			result = "," + result
	if n < 0:
		result = "-" + result
	return result


## Másodpercet formáz (125 → "2:05")
static func format_time(seconds: float) -> String:
	var mins := int(seconds) / 60
	var secs := int(seconds) % 60
	return "%d:%02d" % [mins, secs]

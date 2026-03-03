## WorldTileSetBuilder - Programatikus TileSet generálás placeholder sprite-okkal
## Biome-specifikus tile-okat generál a PlaceholderSprites segítségével
class_name WorldTileSetBuilder
extends RefCounted

## Dinamikus TileSet létrehozása a világ rendereléshez
## Atlas layout:
##   X tengely (source_x): biome index (0-7)
##   Y tengely (source_y):
##     0: ground variant A
##     1: ground variant B
##     2: road main
##     3: road side
##     4: deep water
##     5: shallow water
##     6: mountain peak
##
## Dekoráció atlas:
##   X: variant (0-3)
##   Y: type (0=tree, 1=rock, 2=grass, 3=special)
static func create_world_tileset() -> TileSet:
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(Constants.TILE_SIZE, Constants.TILE_SIZE)

	# === Ground + Road + Water atlas ===
	var ground_atlas := _create_ground_atlas()
	tileset.add_source(ground_atlas, 0)

	# === Decoration atlas ===
	var deco_atlas := _create_decoration_atlas()
	tileset.add_source(deco_atlas, 1)

	return tileset


## Ground atlas generálása (8 biome × 7 tile típus)
static func _create_ground_atlas() -> TileSetAtlasSource:
	var atlas := TileSetAtlasSource.new()
	var cols: int = 8  # Biome-ok száma
	var rows: int = 7  # Tile típusok: 2 ground + 2 road + 2 water + 1 mountain
	var tile_size: int = Constants.TILE_SIZE

	# Atlas textúra létrehozása
	var image := Image.create(cols * tile_size, rows * tile_size, false, Image.FORMAT_RGBA8)

	var biomes: Array = [
		Enums.BiomeType.STARTING_MEADOW,
		Enums.BiomeType.CURSED_FOREST,
		Enums.BiomeType.DARK_SWAMP,
		Enums.BiomeType.RUINS,
		Enums.BiomeType.MOUNTAINS,
		Enums.BiomeType.FROZEN_WASTES,
		Enums.BiomeType.ASHLANDS,
		Enums.BiomeType.PLAGUE_LANDS,
	]

	# Ground színek biome-onként
	var ground_colors: Dictionary = {
		Enums.BiomeType.STARTING_MEADOW: [Color(0.30, 0.70, 0.20), Color(0.34, 0.66, 0.24)],
		Enums.BiomeType.CURSED_FOREST: [Color(0.15, 0.35, 0.10), Color(0.20, 0.28, 0.14)],
		Enums.BiomeType.DARK_SWAMP: [Color(0.25, 0.35, 0.15), Color(0.30, 0.30, 0.20)],
		Enums.BiomeType.RUINS: [Color(0.50, 0.45, 0.35), Color(0.46, 0.42, 0.32)],
		Enums.BiomeType.MOUNTAINS: [Color(0.55, 0.50, 0.50), Color(0.50, 0.46, 0.46)],
		Enums.BiomeType.FROZEN_WASTES: [Color(0.80, 0.85, 0.90), Color(0.76, 0.82, 0.86)],
		Enums.BiomeType.ASHLANDS: [Color(0.40, 0.25, 0.15), Color(0.36, 0.22, 0.12)],
		Enums.BiomeType.PLAGUE_LANDS: [Color(0.35, 0.40, 0.15), Color(0.32, 0.36, 0.12)],
	}

	var road_colors: Dictionary = {
		Enums.BiomeType.STARTING_MEADOW: Color(0.65, 0.55, 0.35),
		Enums.BiomeType.CURSED_FOREST: Color(0.30, 0.28, 0.25),
		Enums.BiomeType.DARK_SWAMP: Color(0.45, 0.35, 0.20),
		Enums.BiomeType.RUINS: Color(0.50, 0.48, 0.42),
		Enums.BiomeType.MOUNTAINS: Color(0.45, 0.42, 0.40),
		Enums.BiomeType.FROZEN_WASTES: Color(0.60, 0.62, 0.65),
		Enums.BiomeType.ASHLANDS: Color(0.30, 0.20, 0.15),
		Enums.BiomeType.PLAGUE_LANDS: Color(0.40, 0.35, 0.25),
	}

	for col in cols:
		var biome: Enums.BiomeType = biomes[col]
		var g_colors: Array = ground_colors.get(biome, [Color.MAGENTA, Color.MAGENTA])
		var r_color: Color = road_colors.get(biome, Color.GRAY)

		# Row 0: ground A
		_fill_tile_region(image, col, 0, tile_size, g_colors[0])
		# Row 1: ground B
		_fill_tile_region(image, col, 1, tile_size, g_colors[1])
		# Row 2: road main
		_fill_tile_region(image, col, 2, tile_size, r_color)
		# Row 3: road side
		_fill_tile_region(image, col, 3, tile_size, r_color.darkened(0.15))
		# Row 4: deep water
		_fill_tile_region(image, col, 4, tile_size, Color(0.1, 0.15, 0.35))
		# Row 5: shallow water
		_fill_tile_region(image, col, 5, tile_size, Color(0.2, 0.3, 0.5))
		# Row 6: mountain peak
		_fill_tile_region(image, col, 6, tile_size, Color(0.4, 0.38, 0.35))

	var texture := ImageTexture.create_from_image(image)
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(tile_size, tile_size)

	# Tile-ok regisztrálása
	for col in cols:
		for row in rows:
			atlas.create_tile(Vector2i(col, row))

	return atlas


## Decoration atlas generálása (4 variáns × 4 típus)
static func _create_decoration_atlas() -> TileSetAtlasSource:
	var atlas := TileSetAtlasSource.new()
	var cols: int = 4  # Variánsok
	var rows: int = 4  # Típusok: tree, rock, grass, special
	var tile_size: int = Constants.TILE_SIZE

	var image := Image.create(cols * tile_size, rows * tile_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))  # Átlátszó háttér

	# Tree variánsok (row 0) - sötétzöld körök
	var tree_colors: Array = [
		Color(0.15, 0.5, 0.1),
		Color(0.2, 0.45, 0.12),
		Color(0.1, 0.4, 0.08),
	]
	for v in 3:
		_fill_circle(image, v, 0, tile_size, tree_colors[v], 12)

	# Rock variánsok (row 1) - szürke négyzetek
	var rock_color := Color(0.45, 0.42, 0.38)
	for v in 2:
		_fill_rect_centered(image, v, 1, tile_size, rock_color.darkened(v * 0.1), 10, 8)

	# Grass variánsok (row 2) - kis zöld pontok
	var grass_colors: Array = [
		Color(0.35, 0.75, 0.25),
		Color(0.4, 0.7, 0.3),
		Color(0.3, 0.65, 0.2),
		Color(0.38, 0.72, 0.28),
	]
	for v in 4:
		_fill_small_dots(image, v, 2, tile_size, grass_colors[v])

	# Special variánsok (row 3) - lila/narancs
	var special_colors: Array = [
		Color(0.5, 0.2, 0.6),
		Color(0.7, 0.3, 0.1),
		Color(0.6, 0.5, 0.1),
	]
	for v in 3:
		_fill_diamond(image, v, 3, tile_size, special_colors[v])

	var texture := ImageTexture.create_from_image(image)
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(tile_size, tile_size)

	for col in cols:
		for row in rows:
			atlas.create_tile(Vector2i(col, row))

	return atlas


## Segéd: tile régió kitöltése egyetlen színnel + kis határ
static func _fill_tile_region(image: Image, col: int, row: int, tile_size: int, color: Color) -> void:
	var x0: int = col * tile_size
	var y0: int = row * tile_size

	for x in tile_size:
		for y in tile_size:
			var is_border: bool = (x == 0 or y == 0 or x == tile_size - 1 or y == tile_size - 1)
			var c: Color = color.darkened(0.15) if is_border else color
			image.set_pixel(x0 + x, y0 + y, c)


## Segéd: kör rajzolás (fa placeholder)
static func _fill_circle(image: Image, col: int, row: int, tile_size: int, color: Color, radius: int) -> void:
	var cx: int = col * tile_size + tile_size / 2
	var cy: int = row * tile_size + tile_size / 2

	for x in tile_size:
		for y in tile_size:
			var px: int = col * tile_size + x
			var py: int = row * tile_size + y
			var dx: int = px - cx
			var dy: int = py - cy
			if dx * dx + dy * dy <= radius * radius:
				var dist: float = sqrt(dx * dx + dy * dy)
				var shade: float = 1.0 - dist / radius * 0.3
				image.set_pixel(px, py, color * shade)


## Segéd: középre igazított téglalap (kő placeholder)
static func _fill_rect_centered(image: Image, col: int, row: int, tile_size: int, color: Color, w: int, h: int) -> void:
	var cx: int = col * tile_size + tile_size / 2
	var cy: int = row * tile_size + tile_size / 2

	for x in range(cx - w / 2, cx + w / 2):
		for y in range(cy - h / 2, cy + h / 2):
			if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)


## Segéd: kis pontok (fű placeholder)
static func _fill_small_dots(image: Image, col: int, row: int, tile_size: int, color: Color) -> void:
	var x0: int = col * tile_size
	var y0: int = row * tile_size
	# 3 kis pont
	var dots: Array = [
		Vector2i(8, 12), Vector2i(20, 8), Vector2i(14, 22),
	]
	for dot in dots:
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var px: int = x0 + dot.x + dx
				var py: int = y0 + dot.y + dy
				if px >= x0 and py >= y0 and px < x0 + tile_size and py < y0 + tile_size:
					image.set_pixel(px, py, color)


## Segéd: gyémánt forma (speciális placeholder)
static func _fill_diamond(image: Image, col: int, row: int, tile_size: int, color: Color) -> void:
	var cx: int = col * tile_size + tile_size / 2
	var cy: int = row * tile_size + tile_size / 2
	var size: int = 8

	for dy in range(-size, size + 1):
		var width: int = size - abs(dy)
		for dx in range(-width, width + 1):
			var px: int = cx + dx
			var py: int = cy + dy
			if px >= 0 and py >= 0 and px < image.get_width() and py < image.get_height():
				image.set_pixel(px, py, color)

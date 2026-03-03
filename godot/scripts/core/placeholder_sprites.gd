## PlaceholderSprites - Ideiglenes sprite generátor
## Színes téglalapok az asset-ek helyett, amíg az AI generálja a véglegeseket
extends Node

## Generál egy egyszínű placeholder textúrát
static func create_rect_texture(width: int, height: int, color: Color) -> ImageTexture:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(color)
	
	# Keret rajzolás (sötétebb szín)
	var border_color := color.darkened(0.3)
	for x in width:
		image.set_pixel(x, 0, border_color)
		image.set_pixel(x, height - 1, border_color)
	for y in height:
		image.set_pixel(0, y, border_color)
		image.set_pixel(width - 1, y, border_color)
	
	return ImageTexture.create_from_image(image)


## Player placeholder (32x48, class szín alapján)
static func create_player_placeholder(player_class: Enums.PlayerClass) -> ImageTexture:
	var color: Color
	match player_class:
		Enums.PlayerClass.ASSASSIN:
			color = Color(0.5, 0.0, 0.5)  # Lila
		Enums.PlayerClass.TANK:
			color = Color(0.6, 0.6, 0.6)  # Szürke/ezüst
		Enums.PlayerClass.MAGE:
			color = Color(0.0, 0.3, 0.8)  # Kék
		_:
			color = Color.WHITE
	
	var image := Image.create(32, 48, false, Image.FORMAT_RGBA8)
	
	# Test (alsó rész)
	for y in range(16, 48):
		for x in range(4, 28):
			image.set_pixel(x, y, color)
	
	# Fej (felső rész, kerek-ebb)
	var head_color := color.lightened(0.2)
	for y in range(2, 18):
		for x in range(8, 24):
			var dx := x - 16
			var dy := y - 10
			if dx * dx + dy * dy < 64:
				image.set_pixel(x, y, head_color)
	
	# Szemek
	image.set_pixel(12, 10, Color.WHITE)
	image.set_pixel(13, 10, Color.WHITE)
	image.set_pixel(19, 10, Color.WHITE)
	image.set_pixel(20, 10, Color.WHITE)
	
	# Keret
	var border_color := color.darkened(0.4)
	for x in 32:
		if image.get_pixel(x, 0).a > 0:
			image.set_pixel(x, 0, border_color)
	for x in 32:
		if image.get_pixel(x, 47).a > 0:
			image.set_pixel(x, 47, border_color)
	
	return ImageTexture.create_from_image(image)


## Enemy placeholder (32x32, típus szín alapján)
static func create_enemy_placeholder(enemy_type: Enums.EnemyType) -> ImageTexture:
	var color: Color
	match enemy_type:
		Enums.EnemyType.MELEE:
			color = Color(0.8, 0.2, 0.2)  # Piros
		Enums.EnemyType.RANGED:
			color = Color(0.8, 0.6, 0.0)  # Narancs
		Enums.EnemyType.CASTER:
			color = Color(0.2, 0.2, 0.8)  # Kék
		Enums.EnemyType.ELITE:
			color = Color(0.8, 0.8, 0.0)  # Arany
		Enums.EnemyType.BOSS:
			color = Color(0.8, 0.0, 0.0)  # Sötétpiros
		_:
			color = Color.RED
	
	return create_rect_texture(32, 32, color)


## Tile placeholder (32x32)
static func create_tile_placeholder(biome: Enums.BiomeType) -> ImageTexture:
	var color: Color
	match biome:
		Enums.BiomeType.STARTING_MEADOW:
			color = Color(0.3, 0.7, 0.2)  # Zöld
		Enums.BiomeType.CURSED_FOREST:
			color = Color(0.15, 0.35, 0.1)  # Sötétzöld
		Enums.BiomeType.DARK_SWAMP:
			color = Color(0.3, 0.35, 0.2)  # Mocsárzöld
		Enums.BiomeType.RUINS:
			color = Color(0.5, 0.45, 0.35)  # Barna/kő
		Enums.BiomeType.MOUNTAINS:
			color = Color(0.55, 0.5, 0.5)  # Szürke
		Enums.BiomeType.FROZEN_WASTES:
			color = Color(0.8, 0.85, 0.9)  # Fehér/kékes
		Enums.BiomeType.ASHLANDS:
			color = Color(0.4, 0.25, 0.15)  # Sötétbarna
		Enums.BiomeType.PLAGUE_LANDS:
			color = Color(0.35, 0.4, 0.15)  # Méregzöld
		_:
			color = Color(0.3, 0.7, 0.2)
	
	return create_rect_texture(32, 32, color)


## Wall tile (32x32, sötét)
static func create_wall_placeholder() -> ImageTexture:
	return create_rect_texture(32, 32, Color(0.25, 0.2, 0.15))

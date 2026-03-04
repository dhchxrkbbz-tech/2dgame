## CrystalCavernsEnemies - Crystal Caverns biome enemy sprite generátor
## 5 enemy: Crystal Bat, Gem Golem, Shard Shooter, Crystal Mage, Prism Construct
class_name CrystalCavernsEnemies
extends PixelArtBase

const CRYSTAL_BLUE = Color(0.30, 0.60, 0.90)
const CRYSTAL_GLW  = Color(0.70, 0.90, 1.00)
const CRYSTAL_DARK = Color(0.10, 0.25, 0.50)
const CRYSTAL_WHT  = Color(0.90, 0.95, 1.00)
const PRISM_COL    = Color(0.80, 0.60, 0.90)

static func _draw_crystal_bat(img: Image, frame_idx: int, anim: String) -> void:
	var wing := [0, -4, -2, 2][frame_idx % 4]
	draw_shadow(img, 24, 44, 8, 3)
	# Test
	draw_ellipse(img, 24, 24 + wing / 2, 6, 8, CRYSTAL_BLUE)
	# Szárnyak - átlátszó lapok
	fill_rect(img, 4, 16 + wing, 16, 12, Color(CRYSTAL_BLUE.r, CRYSTAL_BLUE.g, CRYSTAL_BLUE.b, 0.5))
	fill_rect(img, 28, 16 + wing, 16, 12, Color(CRYSTAL_BLUE.r, CRYSTAL_BLUE.g, CRYSTAL_BLUE.b, 0.5))
	# Csillogó test
	_set_pixel_safe(img, 22, 22, CRYSTAL_WHT)
	_set_pixel_safe(img, 26, 24, CRYSTAL_WHT)
	# Szemek
	_set_pixel_safe(img, 22, 20, CRYSTAL_GLW)
	_set_pixel_safe(img, 26, 20, CRYSTAL_GLW)

static func _draw_gem_golem(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 40, 76, 16, 5)
	# Lábak - kristály tömbök
	fill_rect(img, 14, 60 + breath, 16, 18, CRYSTAL_BLUE)
	fill_rect(img, 50, 60 + breath, 16, 18, CRYSTAL_BLUE)
	# Test - kocka-blokkok
	fill_rect(img, 10, 18 + breath, 60, 44, CRYSTAL_DARK)
	fill_rect(img, 14, 22 + breath, 24, 16, CRYSTAL_BLUE)
	fill_rect(img, 44, 28 + breath, 20, 14, Color(0.50, 0.30, 0.80))
	fill_rect(img, 18, 42 + breath, 18, 14, CRYSTAL_WHT)
	fill_rect(img, 48, 46 + breath, 16, 10, CRYSTAL_BLUE)
	# Csillogás
	_set_pixel_safe(img, 20, 24 + breath, CRYSTAL_WHT)
	_set_pixel_safe(img, 50, 30 + breath, CRYSTAL_WHT)
	_set_pixel_safe(img, 24, 44 + breath, CRYSTAL_GLW)
	# Karok
	fill_rect(img, 0, 26 + breath, 12, 30, CRYSTAL_BLUE)
	fill_rect(img, 68, 26 + breath, 12, 30, CRYSTAL_BLUE)
	# Szemek
	fill_rect(img, 24, 14 + breath, 4, 3, CRYSTAL_GLW)
	fill_rect(img, 46, 14 + breath, 4, 3, CRYSTAL_GLW)

static func _draw_shard_shooter(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 10, 3)
	fill_rect(img, 20, 76 + breath, 8, 14, CRYSTAL_DARK)
	fill_rect(img, 36, 76 + breath, 8, 14, CRYSTAL_DARK)
	# Vékony test
	fill_rect(img, 20, 30 + breath, 24, 48, CRYSTAL_BLUE)
	fill_rect(img, 20, 30 + breath, 4, 48, CRYSTAL_DARK)
	# Páncél
	fill_rect(img, 18, 28 + breath, 28, 14, Color(0.35, 0.55, 0.85))
	# Karok - kristálypuska forma
	fill_rect(img, 8, 34 + breath, 14, 8, CRYSTAL_BLUE)
	fill_rect(img, 42, 34 + breath, 14, 8, CRYSTAL_BLUE)
	# Kristálypuska
	fill_rect(img, 46, 30 + breath, 16, 4, CRYSTAL_GLW)
	fill_rect(img, 60, 30 + breath, 4, 4, CRYSTAL_WHT)
	# Fej
	fill_rect(img, 22, 8 + breath, 20, 22, CRYSTAL_BLUE)
	_set_pixel_safe(img, 28, 18 + breath, CRYSTAL_GLW)
	_set_pixel_safe(img, 36, 18 + breath, CRYSTAL_GLW)
	if anim == "attack" and frame_idx % 4 >= 2:
		# Kristály lövedék
		var sx := 62 + (frame_idx % 4 - 2) * 8
		fill_rect(img, sx, 30, 6, 3, CRYSTAL_WHT)

static func _draw_crystal_mage(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 12, 4)
	# Kristályos robe
	fill_rect(img, 14, 30 + breath, 36, 58, CRYSTAL_DARK)
	fill_rect(img, 12, 82 + breath, 40, 8, Color(0.08, 0.18, 0.40))
	# Kék izzás foltok
	draw_circle(img, 24, 50 + breath, 4, Color(CRYSTAL_GLW.r, CRYSTAL_GLW.g, CRYSTAL_GLW.b, 0.4))
	draw_circle(img, 40, 62 + breath, 3, Color(CRYSTAL_GLW.r, CRYSTAL_GLW.g, CRYSTAL_GLW.b, 0.4))
	# Karok
	fill_rect(img, 6, 34 + breath, 10, 22, CRYSTAL_DARK)
	fill_rect(img, 48, 34 + breath, 10, 22, CRYSTAL_DARK)
	# Kristály bot
	fill_rect(img, 50, 10 + breath, 4, 70, Color(0.35, 0.22, 0.12))
	draw_circle(img, 52, 8 + breath, 5, CRYSTAL_BLUE)
	draw_circle(img, 52, 8 + breath, 2, CRYSTAL_GLW)
	# Fej
	fill_rect(img, 22, 6 + breath, 20, 24, Color(0.75, 0.68, 0.55))
	fill_rect(img, 18, 2 + breath, 28, 12, CRYSTAL_DARK)
	_set_pixel_safe(img, 28, 18 + breath, CRYSTAL_GLW)
	_set_pixel_safe(img, 36, 18 + breath, CRYSTAL_GLW)

static func _draw_prism_construct(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	var float_y := [0, -1, -2, -1][frame_idx % 4]
	draw_shadow(img, 48, 122, 20, 5)
	# Geometrikus forma - prizma
	# Alsó négyszög
	fill_rect(img, 16, 70 + float_y, 64, 30, CRYSTAL_BLUE)
	# Középső rész
	fill_rect(img, 20, 36 + float_y, 56, 38, CRYSTAL_WHT)
	fill_rect(img, 24, 40 + float_y, 48, 30, CRYSTAL_BLUE)
	# Felső csúcs
	fill_rect(img, 28, 12 + float_y, 40, 28, CRYSTAL_GLW)
	fill_rect(img, 34, 4 + float_y, 28, 16, CRYSTAL_BLUE)
	# Szivárványos fénytörés
	var rainbow := [Color.RED, Color.ORANGE, Color.YELLOW, Color.GREEN, Color.BLUE, Color.PURPLE]
	for i in range(6):
		_set_pixel_safe(img, 30 + i * 6, 50 + float_y, rainbow[i])
		_set_pixel_safe(img, 32 + i * 6, 52 + float_y, rainbow[i])
	# Izzó mag
	draw_circle(img, 48, 54 + float_y, 8, Color(CRYSTAL_WHT.r, CRYSTAL_WHT.g, CRYSTAL_WHT.b, 0.7))

static func generate_enemy(enemy_name: String, anim: String, frame_idx: int) -> Image:
	var sizes := {
		"crystal_bat": Vector2i(48, 48),
		"gem_golem": Vector2i(80, 80),
		"shard_shooter": Vector2i(64, 96),
		"crystal_mage": Vector2i(64, 96),
		"prism_construct": Vector2i(96, 128),
	}
	var size: Vector2i = sizes.get(enemy_name, Vector2i(64, 96))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match enemy_name:
		"crystal_bat":      _draw_crystal_bat(img, frame_idx, anim)
		"gem_golem":        _draw_gem_golem(img, frame_idx, anim)
		"shard_shooter":    _draw_shard_shooter(img, frame_idx, anim)
		"crystal_mage":     _draw_crystal_mage(img, frame_idx, anim)
		"prism_construct":  _draw_prism_construct(img, frame_idx, anim)
	draw_outline(img, Color.BLACK)
	return img

static func get_enemy_names() -> Array:
	return ["crystal_bat", "gem_golem", "shard_shooter", "crystal_mage", "prism_construct"]

static func get_anim_config() -> Dictionary:
	return {"idle": {"frames": 4, "fps": 5, "loop": true}, "walk": {"frames": 4, "fps": 8, "loop": true}, "attack": {"frames": 4, "fps": 10, "loop": false}, "hit": {"frames": 2, "fps": 10, "loop": false}, "death": {"frames": 4, "fps": 7, "loop": false}}

static func export_all(base_path: String) -> void:
	var path := base_path + "crystal_caverns/"
	var anims := get_anim_config()
	for enemy_name in get_enemy_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for i in range(config["frames"]):
				save_png(generate_enemy(enemy_name, anim_name, i), path + "%s/%s_%d.png" % [enemy_name, anim_name, i])
	print("  ✓ Crystal Caverns enemies exported to: ", path)

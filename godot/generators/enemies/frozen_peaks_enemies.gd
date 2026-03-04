## FrozenPeaksEnemies - Frozen Peaks biome enemy sprite generátor
## 5 enemy: Ice Wolf, Frost Giant, Snow Archer, Frost Shaman, Avalanche Elemental
class_name FrozenPeaksEnemies
extends PixelArtBase

const ICE_WHT  = Color(0.91, 0.93, 0.96)  # #E8EEF5
const ICE_BLUE = Color(0.38, 0.63, 0.82)  # #60A0D0
const FROST_BL = Color(0.75, 0.85, 0.94)  # #C0D8F0
const ROBE_BL  = Color(0.06, 0.25, 0.63)  # #1040A0
const STONE_GR = Color(0.60, 0.62, 0.65)
const SNOW_WHT = Color(0.95, 0.96, 0.98)

static func _draw_ice_wolf(img: Image, frame_idx: int, anim: String) -> void:
	var bob := get_walk_bob(frame_idx, 4) if anim == "walk" else 0
	draw_shadow(img, 32, 58, 14, 4)
	# Test
	fill_rect(img, 10, 22 + bob, 44, 22, ICE_WHT)
	fill_rect(img, 6, 26 + bob, 10, 16, ICE_WHT)
	# Fej
	fill_rect(img, 42, 14 + bob, 20, 20, ICE_WHT)
	fill_rect(img, 58, 20 + bob, 6, 8, Color(0.80, 0.82, 0.86))
	# Jégkristályok a bundán
	_set_pixel_safe(img, 20, 24 + bob, ICE_BLUE)
	_set_pixel_safe(img, 30, 20 + bob, ICE_BLUE)
	_set_pixel_safe(img, 36, 28 + bob, ICE_BLUE)
	_set_pixel_safe(img, 14, 30 + bob, ICE_BLUE)
	# Lábak
	fill_rect(img, 12, 42 + bob, 6, 14, ICE_WHT)
	fill_rect(img, 24, 42 + bob, 6, 14, ICE_WHT)
	fill_rect(img, 34, 42 + bob, 6, 14, ICE_WHT)
	fill_rect(img, 46, 42 + bob, 6, 14, ICE_WHT)
	# Szemek
	_set_pixel_safe(img, 48, 18 + bob, ICE_BLUE)
	_set_pixel_safe(img, 54, 18 + bob, ICE_BLUE)
	# Farok
	fill_rect(img, 2, 22 + bob, 8, 4, ICE_WHT)

static func _draw_frost_giant(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 48, 122, 20, 6)
	# Lábak
	fill_rect(img, 20, 90 + breath, 18, 32, FROST_BL)
	fill_rect(img, 58, 90 + breath, 18, 32, FROST_BL)
	# Test
	fill_rect(img, 12, 30 + breath, 72, 64, FROST_BL)
	# Jégpáncél elemek
	fill_rect(img, 14, 32 + breath, 20, 20, ICE_BLUE)
	fill_rect(img, 62, 38 + breath, 18, 16, ICE_BLUE)
	# Karok
	fill_rect(img, 0, 40 + breath, 14, 36, FROST_BL)
	fill_rect(img, 82, 40 + breath, 14, 36, FROST_BL)
	# Jégszilánk fegyver (jobb kéz)
	fill_rect(img, 84, 20 + breath, 6, 56, ICE_BLUE)
	fill_rect(img, 82, 16 + breath, 10, 8, SNOW_WHT)
	# Fej
	fill_rect(img, 30, 6 + breath, 36, 28, FROST_BL)
	_set_pixel_safe(img, 38, 16 + breath, ICE_BLUE)
	_set_pixel_safe(img, 56, 16 + breath, ICE_BLUE)
	# Csillogás
	_set_pixel_safe(img, 42, 42 + breath, SNOW_WHT)
	_set_pixel_safe(img, 60, 56 + breath, SNOW_WHT)

static func _draw_snow_archer(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 10, 3)
	# Lábak
	fill_rect(img, 20, 76 + breath, 8, 14, Color(0.50, 0.52, 0.55))
	fill_rect(img, 36, 76 + breath, 8, 14, Color(0.50, 0.52, 0.55))
	# Test - fehér köpeny
	fill_rect(img, 16, 30 + breath, 32, 48, ICE_WHT)
	fill_rect(img, 14, 70 + breath, 36, 12, SNOW_WHT)
	# Karok
	fill_rect(img, 6, 34 + breath, 12, 8, ICE_WHT)
	fill_rect(img, 46, 34 + breath, 12, 8, ICE_WHT)
	# Ezüst íj
	fill_rect(img, 48, 24 + breath, 4, 40, Color(0.72, 0.74, 0.78))
	fill_rect(img, 50, 24 + breath, 8, 2, Color(0.72, 0.74, 0.78))
	fill_rect(img, 50, 62 + breath, 8, 2, Color(0.72, 0.74, 0.78))
	# Húr
	_set_pixel_safe(img, 52, 26 + breath, Color(0.85, 0.85, 0.90))
	_set_pixel_safe(img, 52, 44 + breath, Color(0.85, 0.85, 0.90))
	_set_pixel_safe(img, 52, 60 + breath, Color(0.85, 0.85, 0.90))
	# Fej
	fill_rect(img, 20, 8 + breath, 24, 24, Color(0.82, 0.68, 0.52))
	# Kapucni
	fill_rect(img, 16, 4 + breath, 32, 16, ICE_WHT)
	# Szemek
	_set_pixel_safe(img, 28, 18 + breath, ICE_BLUE)
	_set_pixel_safe(img, 38, 18 + breath, ICE_BLUE)

static func _draw_frost_shaman(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 12, 4)
	# Robe
	fill_rect(img, 12, 28 + breath, 40, 60, ROBE_BL)
	fill_rect(img, 10, 80 + breath, 44, 10, Color(0.04, 0.18, 0.50))
	# Jég mintázat a robe-on
	_set_pixel_safe(img, 22, 48 + breath, ICE_BLUE)
	_set_pixel_safe(img, 38, 56 + breath, ICE_BLUE)
	_set_pixel_safe(img, 26, 66 + breath, ICE_BLUE)
	# Karok
	fill_rect(img, 4, 36 + breath, 10, 18, ROBE_BL)
	fill_rect(img, 50, 36 + breath, 10, 18, ROBE_BL)
	# Blizzard gömb a kezek között
	if anim == "idle" or anim == "attack":
		draw_circle(img, 32, 56 + breath, 6, Color(ICE_BLUE.r, ICE_BLUE.g, ICE_BLUE.b, 0.6))
		draw_circle(img, 32, 56 + breath, 3, SNOW_WHT)
	# Fej - hó-fehér haj
	fill_rect(img, 18, 4 + breath, 28, 26, Color(0.78, 0.65, 0.50))
	fill_rect(img, 14, 2 + breath, 36, 10, SNOW_WHT)
	fill_rect(img, 14, 10 + breath, 6, 16, SNOW_WHT)
	fill_rect(img, 44, 10 + breath, 6, 16, SNOW_WHT)
	_set_pixel_safe(img, 26, 16 + breath, ICE_BLUE)
	_set_pixel_safe(img, 38, 16 + breath, ICE_BLUE)

static func _draw_avalanche_elemental(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 48, 122, 22, 6)
	# Gömbölyített kő+hó forma
	draw_ellipse(img, 48, 70 + breath, 36, 48, STONE_GR)
	# Hóblokkok
	fill_rect(img, 16, 26 + breath, 28, 22, SNOW_WHT)
	fill_rect(img, 50, 34 + breath, 24, 20, SNOW_WHT)
	fill_rect(img, 24, 84 + breath, 20, 18, SNOW_WHT)
	fill_rect(img, 58, 80 + breath, 18, 14, SNOW_WHT)
	# Kődarabok
	fill_rect(img, 20, 50 + breath, 18, 14, Color(0.45, 0.47, 0.50))
	fill_rect(img, 56, 58 + breath, 16, 12, Color(0.40, 0.42, 0.45))
	# Karok - szikla
	fill_rect(img, 4, 42 + breath, 14, 30, STONE_GR)
	fill_rect(img, 78, 42 + breath, 14, 30, STONE_GR)
	# Szemek
	_set_pixel_safe(img, 36, 38 + breath, ICE_BLUE)
	_set_pixel_safe(img, 54, 38 + breath, ICE_BLUE)
	# Jégcsapok
	fill_rect(img, 22, 18 + breath, 4, 10, ICE_BLUE)
	fill_rect(img, 40, 16 + breath, 4, 12, ICE_BLUE)
	fill_rect(img, 60, 20 + breath, 4, 10, ICE_BLUE)

static func generate_enemy(enemy_name: String, anim: String, frame_idx: int) -> Image:
	var sizes := {
		"ice_wolf": Vector2i(64, 64),
		"frost_giant": Vector2i(96, 128),
		"snow_archer": Vector2i(64, 96),
		"frost_shaman": Vector2i(64, 96),
		"avalanche_elemental": Vector2i(96, 128),
	}
	var size: Vector2i = sizes.get(enemy_name, Vector2i(64, 96))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match enemy_name:
		"ice_wolf":              _draw_ice_wolf(img, frame_idx, anim)
		"frost_giant":           _draw_frost_giant(img, frame_idx, anim)
		"snow_archer":           _draw_snow_archer(img, frame_idx, anim)
		"frost_shaman":          _draw_frost_shaman(img, frame_idx, anim)
		"avalanche_elemental":   _draw_avalanche_elemental(img, frame_idx, anim)
	draw_outline(img, Color.BLACK)
	return img

static func get_enemy_names() -> Array:
	return ["ice_wolf", "frost_giant", "snow_archer", "frost_shaman", "avalanche_elemental"]

static func get_anim_config() -> Dictionary:
	return {"idle": {"frames": 4, "fps": 5, "loop": true}, "walk": {"frames": 4, "fps": 8, "loop": true}, "attack": {"frames": 4, "fps": 10, "loop": false}, "hit": {"frames": 2, "fps": 10, "loop": false}, "death": {"frames": 4, "fps": 7, "loop": false}}

static func export_all(base_path: String) -> void:
	var path := base_path + "frozen_peaks/"
	var anims := get_anim_config()
	for enemy_name in get_enemy_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for i in range(config["frames"]):
				save_png(generate_enemy(enemy_name, anim_name, i), path + "%s/%s_%d.png" % [enemy_name, anim_name, i])
	print("  ✓ Frozen Peaks enemies exported to: ", path)

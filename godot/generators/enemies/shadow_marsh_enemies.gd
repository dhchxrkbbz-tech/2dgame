## ShadowMarshEnemies - Shadow Marsh biome enemy sprite generátor
## 5 enemy: Bog Lurker, Marsh Horror, Will-o-Wisp, Swamp Hag, Hydra
class_name ShadowMarshEnemies
extends PixelArtBase

const MARSH_GRN  = Color(0.10, 0.19, 0.06)  # #1A3010
const MUD_BRN    = Color(0.30, 0.24, 0.12)
const YELGRN     = Color(0.29, 0.35, 0.06)   # #4A5A10
const TENT_DK    = Color(0.16, 0.23, 0.03)   # #2A3A08
const HAG_GRN    = Color(0.12, 0.22, 0.08)
const HYDRA_GRN  = Color(0.23, 0.31, 0.06)   # #3A5010
const WISP_BLUE  = Color(0.40, 0.60, 1.00)
const WISP_PURP  = Color(0.65, 0.30, 0.90)
const WISP_WHT   = Color(0.95, 0.95, 1.00)
const WISP_GREEN = Color(0.30, 0.90, 0.40)
const EYE_YEL    = Color(0.90, 0.85, 0.20)

static func _draw_bog_lurker(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 12, 4)
	# Guggolós humanoid mocsárból kiemelkedve
	# Iszap alj
	fill_rect(img, 8, 72 + breath, 48, 20, MUD_BRN)
	# Test
	fill_rect(img, 14, 36 + breath, 36, 40, MARSH_GRN)
	# Iszap csöpög
	fill_rect(img, 18, 70 + breath, 4, 8, MUD_BRN)
	fill_rect(img, 36, 68 + breath, 4, 10, MUD_BRN)
	fill_rect(img, 44, 72 + breath, 4, 6, MUD_BRN)
	# Karok
	fill_rect(img, 4, 42 + breath, 12, 24, MARSH_GRN)
	fill_rect(img, 48, 42 + breath, 12, 24, MARSH_GRN)
	# Karmok
	fill_rect(img, 2, 64 + breath, 4, 6, Color(0.30, 0.28, 0.20))
	fill_rect(img, 56, 64 + breath, 4, 6, Color(0.30, 0.28, 0.20))
	# Fej
	fill_rect(img, 18, 14 + breath, 28, 24, MARSH_GRN)
	# Sárga szemek
	fill_rect(img, 24, 22 + breath, 4, 3, EYE_YEL)
	fill_rect(img, 36, 22 + breath, 4, 3, EYE_YEL)

static func _draw_marsh_horror(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 40, 74, 16, 5)
	# Kerek test
	draw_ellipse(img, 40, 42 + breath, 28, 24, YELGRN)
	# 6 tentaculum
	var tent_angles := [0.0, 1.047, 2.094, 3.14, 4.19, 5.24]
	for i in range(6):
		var angle := tent_angles[i]
		var tx := int(40 + cos(angle) * 30)
		var ty := int(42 + breath + sin(angle) * 28)
		var mx := int(40 + cos(angle) * 18)
		var my := int(42 + breath + sin(angle) * 16)
		draw_line_px(img, mx, my, tx, ty, TENT_DK)
		draw_line_px(img, mx + 1, my, tx + 1, ty, TENT_DK)
	# Sok szem
	var eye_positions := [Vector2i(30, 34), Vector2i(44, 32), Vector2i(36, 44), Vector2i(50, 42), Vector2i(28, 46), Vector2i(48, 36)]
	for ep in eye_positions:
		_set_pixel_safe(img, ep.x, ep.y + breath, EYE_YEL)

static func _draw_will_o_wisp(img: Image, frame_idx: int, anim: String) -> void:
	# 32×32-es pici sprite, szín-váltó
	var colors := [WISP_BLUE, WISP_PURP, WISP_WHT, WISP_GREEN]
	var main_col: Color = colors[frame_idx % 4]
	var glow_col := Color(main_col.r, main_col.g, main_col.b, 0.3)
	# Halvány fény kör
	draw_circle(img, 16, 16, 10, glow_col)
	# Izzó gömb
	draw_circle(img, 16, 16, 5, main_col)
	# Belső fehér mag
	draw_circle(img, 16, 16, 2, WISP_WHT)
	# Szikrák
	_set_pixel_safe(img, 8, 12, Color(main_col.r, main_col.g, main_col.b, 0.5))
	_set_pixel_safe(img, 22, 8, Color(main_col.r, main_col.g, main_col.b, 0.5))
	_set_pixel_safe(img, 24, 20, Color(main_col.r, main_col.g, main_col.b, 0.5))

static func _draw_swamp_hag(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 10, 3)
	# Görnyedt alak - robe
	fill_rect(img, 14, 34 + breath, 36, 54, HAG_GRN)
	fill_rect(img, 12, 80 + breath, 40, 10, Color(0.08, 0.16, 0.05))
	# Görbület a vállnál
	fill_rect(img, 22, 28 + breath, 24, 10, HAG_GRN)
	# Karok - karmokkal
	fill_rect(img, 4, 40 + breath, 12, 20, HAG_GRN)
	fill_rect(img, 48, 40 + breath, 12, 20, HAG_GRN)
	fill_rect(img, 2, 58 + breath, 4, 8, Color(0.40, 0.38, 0.25))
	fill_rect(img, 56, 58 + breath, 4, 8, Color(0.40, 0.38, 0.25))
	# Fej
	fill_rect(img, 20, 10 + breath, 24, 22, Color(0.50, 0.55, 0.35))
	# Ősz haj
	fill_rect(img, 16, 6 + breath, 32, 8, Color(0.70, 0.68, 0.65))
	fill_rect(img, 42, 12 + breath, 8, 16, Color(0.70, 0.68, 0.65))
	# Görbe orr
	fill_rect(img, 36, 18 + breath, 6, 6, Color(0.45, 0.50, 0.30))
	# Szemek
	_set_pixel_safe(img, 26, 18 + breath, EYE_YEL)
	_set_pixel_safe(img, 34, 18 + breath, EYE_YEL)
	# Mérges buborékok
	if anim == "attack" or anim == "idle":
		draw_circle_outline(img, 10, 34 + breath, 3, Color(0.30, 0.70, 0.10, 0.6))
		draw_circle_outline(img, 54, 44 + breath, 2, Color(0.30, 0.70, 0.10, 0.6))

static func _draw_hydra(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 48, 122, 24, 6)
	# Fő törzs (ovális)
	draw_ellipse(img, 48, 80 + breath, 30, 28, HYDRA_GRN)
	fill_rect(img, 20, 56 + breath, 56, 48, HYDRA_GRN)
	# 3 kígyó-nyak + fej
	# Bal nyak
	draw_line_px(img, 28, 56 + breath, 16, 30 + breath, TENT_DK)
	draw_line_px(img, 29, 56 + breath, 17, 30 + breath, TENT_DK)
	draw_line_px(img, 30, 56 + breath, 18, 30 + breath, TENT_DK)
	draw_circle(img, 14, 26 + breath, 6, HYDRA_GRN)
	# Fogak
	_set_pixel_safe(img, 10, 24 + breath, Color.WHITE)
	_set_pixel_safe(img, 18, 24 + breath, Color.WHITE)
	_set_pixel_safe(img, 12, 20 + breath, EYE_YEL)

	# Közép nyak
	draw_line_px(img, 48, 52 + breath, 48, 18 + breath, TENT_DK)
	draw_line_px(img, 49, 52 + breath, 49, 18 + breath, TENT_DK)
	draw_line_px(img, 50, 52 + breath, 50, 18 + breath, TENT_DK)
	draw_circle(img, 49, 14 + breath, 7, HYDRA_GRN)
	_set_pixel_safe(img, 45, 12 + breath, Color.WHITE)
	_set_pixel_safe(img, 53, 12 + breath, Color.WHITE)
	_set_pixel_safe(img, 49, 8 + breath, EYE_YEL)

	# Jobb nyak
	draw_line_px(img, 68, 56 + breath, 80, 30 + breath, TENT_DK)
	draw_line_px(img, 69, 56 + breath, 81, 30 + breath, TENT_DK)
	draw_line_px(img, 70, 56 + breath, 82, 30 + breath, TENT_DK)
	draw_circle(img, 82, 26 + breath, 6, HYDRA_GRN)
	_set_pixel_safe(img, 78, 24 + breath, Color.WHITE)
	_set_pixel_safe(img, 86, 24 + breath, Color.WHITE)
	_set_pixel_safe(img, 84, 20 + breath, EYE_YEL)

static func generate_enemy(enemy_name: String, anim: String, frame_idx: int) -> Image:
	var sizes := {
		"bog_lurker": Vector2i(64, 96),
		"marsh_horror": Vector2i(80, 80),
		"will_o_wisp": Vector2i(32, 32),
		"swamp_hag": Vector2i(64, 96),
		"hydra": Vector2i(96, 128),
	}
	var size: Vector2i = sizes.get(enemy_name, Vector2i(64, 96))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match enemy_name:
		"bog_lurker":    _draw_bog_lurker(img, frame_idx, anim)
		"marsh_horror":  _draw_marsh_horror(img, frame_idx, anim)
		"will_o_wisp":   _draw_will_o_wisp(img, frame_idx, anim)
		"swamp_hag":     _draw_swamp_hag(img, frame_idx, anim)
		"hydra":         _draw_hydra(img, frame_idx, anim)
	draw_outline(img, Color.BLACK)
	return img

static func get_enemy_names() -> Array:
	return ["bog_lurker", "marsh_horror", "will_o_wisp", "swamp_hag", "hydra"]

static func get_anim_config() -> Dictionary:
	return {"idle": {"frames": 4, "fps": 5, "loop": true}, "walk": {"frames": 4, "fps": 8, "loop": true}, "attack": {"frames": 4, "fps": 10, "loop": false}, "hit": {"frames": 2, "fps": 10, "loop": false}, "death": {"frames": 4, "fps": 7, "loop": false}}

static func export_all(base_path: String) -> void:
	var path := base_path + "shadow_marsh/"
	var anims := get_anim_config()
	for enemy_name in get_enemy_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for i in range(config["frames"]):
				save_png(generate_enemy(enemy_name, anim_name, i), path + "%s/%s_%d.png" % [enemy_name, anim_name, i])
	print("  ✓ Shadow Marsh enemies exported to: ", path)

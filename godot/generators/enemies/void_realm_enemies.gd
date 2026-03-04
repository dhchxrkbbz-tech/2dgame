## VoidRealmEnemies - Void Realm biome enemy sprite generátor
## 5 enemy: Void Stalker, Phase Shifter, Void Ray, Reality Warper, Void Titan
class_name VoidRealmEnemies
extends PixelArtBase

const VOID_PURP  = Color(0.09, 0.03, 0.19)  # #180830
const VOID_GLW   = Color(0.63, 0.13, 0.94)  # #A020F0
const PHASE_BL   = Color(0.13, 0.13, 0.38)  # #202060
const RAY_PURP   = Color(0.75, 0.38, 1.00)  # #C060FF
const RAY_WHT    = Color(0.94, 0.82, 1.00)  # #F0D0FF
const VOID_DEEP  = Color(0.06, 0.00, 0.09)  # #100018
const VOID_CRYST = Color(0.50, 0.19, 0.75)  # #8030C0

static func _draw_void_stalker(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 10, 3)
	# Humanoid de torzult - void energia köré vonva
	# Test (alpha 0.85)
	var body_col := Color(VOID_PURP.r, VOID_PURP.g, VOID_PURP.b, 0.85)
	fill_rect(img, 16, 30 + breath, 32, 48, body_col)
	# Torzult karok - aszimmetrikus
	fill_rect(img, 4, 34 + breath, 14, 26, body_col)
	fill_rect(img, 46, 38 + breath, 16, 30, body_col)
	# Lábak
	fill_rect(img, 18, 76 + breath, 8, 14, body_col)
	fill_rect(img, 36, 74 + breath, 10, 16, body_col)
	# Void energia borítás
	draw_circle(img, 32, 50 + breath, 14, Color(VOID_GLW.r, VOID_GLW.g, VOID_GLW.b, 0.15))
	_set_pixel_safe(img, 22, 42 + breath, VOID_GLW)
	_set_pixel_safe(img, 38, 56 + breath, VOID_GLW)
	_set_pixel_safe(img, 28, 66 + breath, VOID_GLW)
	# Fej
	fill_rect(img, 20, 8 + breath, 24, 24, body_col)
	# Izzó szemek
	fill_rect(img, 26, 16 + breath, 3, 3, VOID_GLW)
	fill_rect(img, 35, 16 + breath, 3, 3, VOID_GLW)

static func _draw_phase_shifter(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	# Frame-enként változó alpha (fázisol)
	var alphas := [0.9, 0.5, 0.3, 0.7]
	var alpha: float = alphas[frame_idx % 4]
	var body_col := Color(PHASE_BL.r, PHASE_BL.g, PHASE_BL.b, alpha)
	draw_shadow(img, 32, 90, 10, 3)
	# Geometrikus, szögletes forma
	fill_rect(img, 14, 28 + breath, 36, 52, body_col)
	# Szögletes vállak
	fill_rect(img, 8, 26 + breath, 48, 12, body_col)
	# Szögletes karok
	fill_rect(img, 2, 30 + breath, 14, 24, body_col)
	fill_rect(img, 48, 30 + breath, 14, 24, body_col)
	# Lábak
	fill_rect(img, 18, 78 + breath, 10, 12, body_col)
	fill_rect(img, 36, 78 + breath, 10, 12, body_col)
	# Geometrikus rúnák
	draw_circle_outline(img, 32, 50 + breath, 8, Color(VOID_GLW.r, VOID_GLW.g, VOID_GLW.b, alpha))
	# Fej (szögletes)
	fill_rect(img, 18, 4 + breath, 28, 24, body_col)
	fill_rect(img, 16, 2 + breath, 32, 4, body_col)
	# Szemek
	_set_pixel_safe(img, 26, 12 + breath, VOID_GLW)
	_set_pixel_safe(img, 38, 12 + breath, VOID_GLW)

static func _draw_void_ray(img: Image, frame_idx: int, anim: String) -> void:
	# 64×64 sugár-szerű forma
	var pulse := [0, 1, 2, 1][frame_idx % 4]
	draw_shadow(img, 32, 56, 8, 3)
	# Elongált energia forma
	draw_ellipse(img, 32, 32, 8 + pulse, 22, RAY_PURP)
	# Belső fény
	draw_ellipse(img, 32, 32, 4, 14, RAY_WHT)
	# Energia sugarak
	draw_line_px(img, 32, 6, 20, 2, RAY_PURP)
	draw_line_px(img, 32, 6, 44, 2, RAY_PURP)
	draw_line_px(img, 32, 58, 20, 62, RAY_PURP)
	draw_line_px(img, 32, 58, 44, 62, RAY_PURP)
	# Szikrák
	_set_pixel_safe(img, 16, 20, Color(RAY_WHT.r, RAY_WHT.g, RAY_WHT.b, 0.6))
	_set_pixel_safe(img, 48, 28, Color(RAY_WHT.r, RAY_WHT.g, RAY_WHT.b, 0.6))
	_set_pixel_safe(img, 20, 44, Color(RAY_WHT.r, RAY_WHT.g, RAY_WHT.b, 0.6))
	_set_pixel_safe(img, 46, 38, Color(RAY_WHT.r, RAY_WHT.g, RAY_WHT.b, 0.6))

static func _draw_reality_warper(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 10, 3)
	# Humanoid de distorted
	var body_col := Color(0.30, 0.15, 0.40)
	fill_rect(img, 14, 28 + breath, 36, 52, body_col)
	# Karok
	fill_rect(img, 4, 34 + breath, 12, 22, body_col)
	fill_rect(img, 48, 38 + breath, 12, 22, body_col)
	# Lábak
	fill_rect(img, 18, 78 + breath, 8, 12, body_col)
	fill_rect(img, 38, 78 + breath, 8, 12, body_col)
	# Random pixel noise - teste "törik" a frame-ek közt
	var rng := RandomNumberGenerator.new()
	rng.seed = frame_idx * 7919
	for i in range(30):
		var nx := rng.randi_range(10, 54)
		var ny := rng.randi_range(24, 86)
		var nc := Color(rng.randf_range(0.2, 0.6), rng.randf_range(0.05, 0.3), rng.randf_range(0.3, 0.7), 0.8)
		_set_pixel_safe(img, nx, ny + breath, nc)
	# Fej (torzított)
	fill_rect(img, 18, 6 + breath, 28, 24, body_col)
	# Distorted arc
	var eye_offset := [0, 1, -1, 0][frame_idx % 4]
	_set_pixel_safe(img, 24 + eye_offset, 14 + breath, VOID_GLW)
	_set_pixel_safe(img, 38 - eye_offset, 16 + breath, VOID_GLW)

static func _draw_void_titan(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 64, 122, 28, 7)
	# Masszív humanoid
	fill_rect(img, 20, 30 + breath, 88, 70, VOID_DEEP)
	# Lábak
	fill_rect(img, 30, 98 + breath, 18, 26, VOID_DEEP)
	fill_rect(img, 80, 98 + breath, 18, 26, VOID_DEEP)
	# Karok
	fill_rect(img, 4, 36 + breath, 18, 44, VOID_DEEP)
	fill_rect(img, 106, 36 + breath, 18, 44, VOID_DEEP)
	# Void kristályok kiemelkedve
	fill_rect(img, 28, 38 + breath, 10, 16, VOID_CRYST)
	fill_rect(img, 76, 44 + breath, 12, 14, VOID_CRYST)
	fill_rect(img, 50, 32 + breath, 8, 20, VOID_CRYST)
	fill_rect(img, 42, 68 + breath, 14, 10, VOID_CRYST)
	fill_rect(img, 88, 56 + breath, 10, 12, VOID_CRYST)
	# Void energia foltok
	draw_circle(img, 44, 52 + breath, 8, Color(VOID_CRYST.r, VOID_CRYST.g, VOID_CRYST.b, 0.3))
	draw_circle(img, 82, 64 + breath, 6, Color(VOID_CRYST.r, VOID_CRYST.g, VOID_CRYST.b, 0.3))
	# Fejpáncél
	fill_rect(img, 38, 4 + breath, 52, 30, VOID_DEEP)
	# Izzó void szemek
	fill_rect(img, 48, 14 + breath, 6, 4, VOID_GLW)
	fill_rect(img, 74, 14 + breath, 6, 4, VOID_GLW)
	# Korona (void kristály)
	fill_rect(img, 48, 0 + breath, 6, 8, VOID_CRYST)
	fill_rect(img, 60, 0 + breath, 8, 6, VOID_CRYST)
	fill_rect(img, 74, 0 + breath, 6, 8, VOID_CRYST)

static func generate_enemy(enemy_name: String, anim: String, frame_idx: int) -> Image:
	var sizes := {
		"void_stalker": Vector2i(64, 96),
		"phase_shifter": Vector2i(64, 96),
		"void_ray": Vector2i(64, 64),
		"reality_warper": Vector2i(64, 96),
		"void_titan": Vector2i(128, 128),
	}
	var size: Vector2i = sizes.get(enemy_name, Vector2i(64, 96))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match enemy_name:
		"void_stalker":    _draw_void_stalker(img, frame_idx, anim)
		"phase_shifter":   _draw_phase_shifter(img, frame_idx, anim)
		"void_ray":        _draw_void_ray(img, frame_idx, anim)
		"reality_warper":  _draw_reality_warper(img, frame_idx, anim)
		"void_titan":      _draw_void_titan(img, frame_idx, anim)
	draw_outline(img, Color.BLACK)
	return img

static func get_enemy_names() -> Array:
	return ["void_stalker", "phase_shifter", "void_ray", "reality_warper", "void_titan"]

static func get_anim_config() -> Dictionary:
	return {"idle": {"frames": 4, "fps": 5, "loop": true}, "walk": {"frames": 4, "fps": 8, "loop": true}, "attack": {"frames": 4, "fps": 10, "loop": false}, "hit": {"frames": 2, "fps": 10, "loop": false}, "death": {"frames": 4, "fps": 7, "loop": false}}

static func export_all(base_path: String) -> void:
	var path := base_path + "void_realm/"
	var anims := get_anim_config()
	for enemy_name in get_enemy_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for i in range(config["frames"]):
				save_png(generate_enemy(enemy_name, anim_name, i), path + "%s/%s_%d.png" % [enemy_name, anim_name, i])
	print("  ✓ Void Realm enemies exported to: ", path)

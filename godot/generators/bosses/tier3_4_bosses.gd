## Tier3_4Bosses - Tier 3 World Boss + Tier 4 Raid Boss sprite generátor
## World: Swamp Hydra, Void Weaver, Ancient Dragon, Riftlord
## Raid: The Ashen God, The Void Emperor
class_name Tier3_4Bosses
extends PixelArtBase

# ─── SWAMP HYDRA (192×192) ───
const HYDRA_GRN  = Color(0.23, 0.31, 0.06)
const HYDRA_DK   = Color(0.16, 0.22, 0.04)
const HYDRA_EYE  = Color(0.90, 0.85, 0.20)
const HYDRA_TOOTH = Color(0.92, 0.90, 0.85)

static func _draw_swamp_hydra(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 96, 184, 40, 8)
	# Főtest (ovális)
	draw_ellipse(img, 96, 120 + breath, 42, 36, HYDRA_GRN)
	fill_rect(img, 56, 88 + breath, 80, 64, HYDRA_GRN)
	# 3 nyak + fej
	var neck_data := [
		{"nx": 60, "ny": 88, "hx": 36, "hy": 30, "hr": 10},  # Bal
		{"nx": 96, "ny": 84, "hx": 96, "hy": 16, "hr": 12},  # Közép
		{"nx": 132, "ny": 88, "hx": 156, "hy": 30, "hr": 10}, # Jobb
	]
	for nd in neck_data:
		# Nyak
		draw_line_px(img, nd["nx"], nd["ny"] + breath, nd["hx"], nd["hy"] + breath, HYDRA_DK)
		draw_line_px(img, nd["nx"] + 1, nd["ny"] + breath, nd["hx"] + 1, nd["hy"] + breath, HYDRA_DK)
		draw_line_px(img, nd["nx"] + 2, nd["ny"] + breath, nd["hx"] + 2, nd["hy"] + breath, HYDRA_DK)
		draw_line_px(img, nd["nx"] - 1, nd["ny"] + breath, nd["hx"] - 1, nd["hy"] + breath, HYDRA_DK)
		# Fej
		draw_circle(img, nd["hx"], nd["hy"] + breath, nd["hr"], HYDRA_GRN)
		# Fogak
		_set_pixel_safe(img, nd["hx"] - 4, nd["hy"] + nd["hr"] - 2 + breath, HYDRA_TOOTH)
		_set_pixel_safe(img, nd["hx"] + 4, nd["hy"] + nd["hr"] - 2 + breath, HYDRA_TOOTH)
		# Szem
		_set_pixel_safe(img, nd["hx"] - 3, nd["hy"] - 2 + breath, HYDRA_EYE)
		_set_pixel_safe(img, nd["hx"] + 3, nd["hy"] - 2 + breath, HYDRA_EYE)
	# Lábak
	fill_rect(img, 60, 154 + breath, 16, 26, HYDRA_DK)
	fill_rect(img, 84, 158 + breath, 16, 22, HYDRA_DK)
	fill_rect(img, 108, 154 + breath, 16, 26, HYDRA_DK)

# ─── VOID WEAVER (256×256) ───
const VOID_BDY   = Color(0.10, 0.03, 0.20)
const VOID_PURP  = Color(0.60, 0.15, 0.90)
const VOID_WHT   = Color(0.90, 0.85, 1.00)

static func _draw_void_weaver(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 128, 248, 50, 10)
	# Pókszerű void lény test
	draw_ellipse(img, 128, 140 + breath, 48, 40, VOID_BDY)
	# Fejrész
	draw_ellipse(img, 128, 80 + breath, 28, 22, VOID_BDY)
	# Portál effekt középen
	draw_circle(img, 128, 130 + breath, 18, Color(VOID_PURP.r, VOID_PURP.g, VOID_PURP.b, 0.3))
	draw_circle(img, 128, 130 + breath, 10, Color(VOID_PURP.r, VOID_PURP.g, VOID_PURP.b, 0.5))
	draw_circle(img, 128, 130 + breath, 4, VOID_WHT)
	# 8 tentaculum lábak
	var tent_starts := [
		[80, 110], [60, 130], [68, 158], [88, 175],
		[176, 110], [196, 130], [188, 158], [168, 175]
	]
	var tent_ends := [
		[20, 60], [10, 110], [14, 180], [40, 230],
		[236, 60], [246, 110], [242, 180], [216, 230]
	]
	for i in range(8):
		draw_line_px(img, tent_starts[i][0], tent_starts[i][1] + breath, tent_ends[i][0], tent_ends[i][1], VOID_BDY)
		draw_line_px(img, tent_starts[i][0] + 1, tent_starts[i][1] + breath, tent_ends[i][0] + 1, tent_ends[i][1], VOID_BDY)
	# Szemek
	fill_rect(img, 116, 74 + breath, 6, 4, VOID_PURP)
	fill_rect(img, 134, 74 + breath, 6, 4, VOID_PURP)

# ─── ANCIENT DRAGON (384×384) ───
const DRAG_FIRE  = Color(0.80, 0.35, 0.05)
const DRAG_ICE   = Color(0.30, 0.60, 0.90)
const DRAG_SCALE = Color(0.20, 0.15, 0.12)

static func _draw_ancient_dragon(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	var wing_flap := [0, -4, -8, -4][frame_idx % 4]
	draw_shadow(img, 192, 370, 80, 14)
	# Hatalmas test (top-down)
	draw_ellipse(img, 192, 200 + breath, 60, 70, DRAG_SCALE)
	# Fej
	fill_rect(img, 160, 80 + breath, 64, 44, DRAG_SCALE)
	fill_rect(img, 172, 68 + breath, 40, 16, DRAG_SCALE)
	# Nyak
	fill_rect(img, 176, 120 + breath, 32, 40, DRAG_SCALE)
	# Szárnyak (top-down, terítve)
	# Bal szárny
	fill_rect(img, 16, 120 + wing_flap + breath, 130, 80, Color(DRAG_FIRE.r, DRAG_FIRE.g, DRAG_FIRE.b, 0.7))
	fill_rect(img, 8, 140 + wing_flap + breath, 8, 40, DRAG_SCALE)
	# Jobb szárny
	fill_rect(img, 238, 120 + wing_flap + breath, 130, 80, Color(DRAG_ICE.r, DRAG_ICE.g, DRAG_ICE.b, 0.7))
	fill_rect(img, 368, 140 + wing_flap + breath, 8, 40, DRAG_SCALE)
	# Tűz+jég dualitás
	# Bal fél (tűz - narancs)
	fill_rect(img, 132, 160 + breath, 60, 80, Color(DRAG_FIRE.r, DRAG_FIRE.g, DRAG_FIRE.b, 0.3))
	# Jobb fél (jég - kék)
	fill_rect(img, 192, 160 + breath, 60, 80, Color(DRAG_ICE.r, DRAG_ICE.g, DRAG_ICE.b, 0.3))
	# Pikkelyek (kis ívek)
	for py in range(0, 120, 10):
		for px in range(0, 100, 14):
			_set_pixel_safe(img, 142 + px, 140 + py + breath, Color(0.25, 0.18, 0.14))
	# Lábak
	fill_rect(img, 148, 260 + breath, 20, 40, DRAG_SCALE)
	fill_rect(img, 216, 260 + breath, 20, 40, DRAG_SCALE)
	# Farok
	draw_line_px(img, 192, 268 + breath, 192, 340, DRAG_SCALE)
	draw_line_px(img, 193, 268 + breath, 193, 340, DRAG_SCALE)
	draw_line_px(img, 194, 268 + breath, 194, 340, DRAG_SCALE)
	fill_rect(img, 186, 336, 16, 10, DRAG_SCALE)
	# Szemek
	fill_rect(img, 176, 84 + breath, 6, 4, DRAG_FIRE)
	fill_rect(img, 202, 84 + breath, 6, 4, DRAG_ICE)

# ─── RIFTLORD (256×256) ───
const RIFT_COL  = Color(0.35, 0.20, 0.50)
const RIFT_ENRG = Color(0.70, 0.40, 0.90)

static func _draw_riftlord(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 128, 248, 44, 10)
	# Kaotikus energia lény - frame-enként biome szín
	var biome_cols := [
		Color(0.42, 0.40, 0.36),  # ashen
		Color(0.10, 0.22, 0.06),  # forest
		Color(0.30, 0.60, 0.90),  # crystal
		Color(0.75, 0.85, 0.94),  # frozen
	]
	var biome_col: Color = biome_cols[frame_idx % 4]
	# Humanoid energia forma
	fill_rect(img, 76, 52 + breath, 104, 120, RIFT_COL)
	fill_rect(img, 84, 40 + breath, 88, 16, RIFT_COL)
	# Biome overlay
	draw_circle(img, 128, 110 + breath, 36, Color(biome_col.r, biome_col.g, biome_col.b, 0.3))
	# Karok
	fill_rect(img, 36, 60 + breath, 42, 60, RIFT_COL)
	fill_rect(img, 178, 60 + breath, 42, 60, RIFT_COL)
	# Lábak
	fill_rect(img, 88, 170 + breath, 24, 48, RIFT_COL)
	fill_rect(img, 144, 170 + breath, 24, 48, RIFT_COL)
	# Fej
	fill_rect(img, 96, 8 + breath, 64, 36, RIFT_COL)
	# Izzó szemek (biome szín)
	fill_rect(img, 108, 18 + breath, 8, 6, biome_col)
	fill_rect(img, 140, 18 + breath, 8, 6, biome_col)
	# Rift vonalak
	for i in range(6):
		var rng := RandomNumberGenerator.new()
		rng.seed = (frame_idx * 31 + i) * 997
		var rx1 := rng.randi_range(60, 196)
		var ry1 := rng.randi_range(40, 200)
		var rx2 := rng.randi_range(60, 196)
		var ry2 := rng.randi_range(40, 200)
		draw_line_px(img, rx1, ry1 + breath, rx2, ry2 + breath, RIFT_ENRG)

# ─── THE ASHEN GOD (256×256) ───
const ASHEN_GOD_BODY = Color(0.35, 0.30, 0.25)
const ASHEN_GOD_FIRE = Color(1.0, 0.50, 0.05)
const ASHEN_GOD_RUNE = Color(1.0, 0.70, 0.20)

static func _draw_ashen_god(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 128, 248, 48, 10)
	# Kolosszális emberi forma
	fill_rect(img, 72, 48 + breath, 112, 140, ASHEN_GOD_BODY)
	# Lábak
	fill_rect(img, 84, 186 + breath, 28, 48, ASHEN_GOD_BODY)
	fill_rect(img, 144, 186 + breath, 28, 48, ASHEN_GOD_BODY)
	# Karok
	fill_rect(img, 32, 56 + breath, 42, 80, ASHEN_GOD_BODY)
	fill_rect(img, 182, 56 + breath, 42, 80, ASHEN_GOD_BODY)
	# Vállak
	fill_rect(img, 52, 44 + breath, 36, 20, ASHEN_GOD_BODY)
	fill_rect(img, 168, 44 + breath, 36, 20, ASHEN_GOD_BODY)
	# Fej
	fill_rect(img, 92, 6 + breath, 72, 46, ASHEN_GOD_BODY)
	# Izzó rúnák
	var rune_positions := [
		Vector2i(100, 80), Vector2i(140, 90), Vector2i(110, 120),
		Vector2i(150, 130), Vector2i(90, 150), Vector2i(160, 110),
		Vector2i(120, 160), Vector2i(130, 70), Vector2i(95, 100),
	]
	for rp in rune_positions:
		draw_circle(img, rp.x, rp.y + breath, 3, ASHEN_GOD_RUNE)
		_set_pixel_safe(img, rp.x, rp.y + breath, Color.WHITE)
	# Hamu + tűz kombináció
	draw_circle(img, 128, 100 + breath, 28, Color(ASHEN_GOD_FIRE.r, ASHEN_GOD_FIRE.g, ASHEN_GOD_FIRE.b, 0.2))
	# Szemek
	fill_rect(img, 106, 22 + breath, 10, 6, ASHEN_GOD_FIRE)
	fill_rect(img, 140, 22 + breath, 10, 6, ASHEN_GOD_FIRE)

# ─── THE VOID EMPEROR (384×384) ───
const VEMPEROR_BODY = Color(0.06, 0.00, 0.12)
const VEMPEROR_VOID = Color(0.50, 0.15, 0.80)
const VEMPEROR_WHT  = Color(0.92, 0.88, 1.00)

static func _draw_void_emperor(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 192, 374, 80, 14)
	# Kozmikus horror - void megtestesülése
	# Központi test
	draw_ellipse(img, 192, 200 + breath, 72, 80, VEMPEROR_BODY)
	# Kiemelkedő energiaoszlopok
	fill_rect(img, 160, 60 + breath, 24, 100, VEMPEROR_BODY)
	fill_rect(img, 200, 60 + breath, 24, 100, VEMPEROR_BODY)
	# Fejforma
	fill_rect(img, 148, 40 + breath, 88, 50, VEMPEROR_BODY)
	fill_rect(img, 164, 20 + breath, 56, 24, VEMPEROR_BODY)
	# Szarvak
	fill_rect(img, 148, 16 + breath, 16, 30, VEMPEROR_VOID)
	fill_rect(img, 220, 16 + breath, 16, 30, VEMPEROR_VOID)
	# Lábak/alj
	fill_rect(img, 140, 278 + breath, 32, 60, VEMPEROR_BODY)
	fill_rect(img, 212, 278 + breath, 32, 60, VEMPEROR_BODY)
	# Karok (void energia)
	fill_rect(img, 60, 100 + breath, 64, 24, VEMPEROR_BODY)
	fill_rect(img, 260, 100 + breath, 64, 24, VEMPEROR_BODY)
	fill_rect(img, 36, 80 + breath, 28, 60, VEMPEROR_BODY)
	fill_rect(img, 320, 80 + breath, 28, 60, VEMPEROR_BODY)
	# Void kristályok
	var crystal_pos := [
		Vector2i(120, 160), Vector2i(264, 160), Vector2i(160, 240),
		Vector2i(224, 240), Vector2i(192, 280), Vector2i(140, 200),
		Vector2i(244, 200),
	]
	for cp in crystal_pos:
		fill_rect(img, cp.x - 6, cp.y - 10 + breath, 12, 20, VEMPEROR_VOID)
		_set_pixel_safe(img, cp.x, cp.y - 4 + breath, VEMPEROR_WHT)
	# Pixel noise (töredező valóság)
	var rng := RandomNumberGenerator.new()
	rng.seed = frame_idx * 11003
	for i in range(60):
		var nx := rng.randi_range(100, 284)
		var ny := rng.randi_range(60, 320)
		var nc := Color(rng.randf_range(0.2, 0.6), 0.0, rng.randf_range(0.4, 0.9), 0.6)
		_set_pixel_safe(img, nx, ny + breath, nc)
	# Szemek (nagy, izzó)
	fill_rect(img, 168, 52 + breath, 12, 8, VEMPEROR_VOID)
	fill_rect(img, 204, 52 + breath, 12, 8, VEMPEROR_VOID)
	fill_rect(img, 172, 54 + breath, 4, 4, VEMPEROR_WHT)
	fill_rect(img, 208, 54 + breath, 4, 4, VEMPEROR_WHT)
	# Portál középen
	draw_circle(img, 192, 190 + breath, 24, Color(VEMPEROR_VOID.r, VEMPEROR_VOID.g, VEMPEROR_VOID.b, 0.3))
	draw_circle(img, 192, 190 + breath, 12, Color(VEMPEROR_WHT.r, VEMPEROR_WHT.g, VEMPEROR_WHT.b, 0.4))

static func generate_boss(boss_name: String, anim: String, frame_idx: int, phase: int = 1) -> Image:
	var sizes := {
		"swamp_hydra": Vector2i(192, 192),
		"void_weaver": Vector2i(256, 256),
		"ancient_dragon": Vector2i(384, 384),
		"riftlord": Vector2i(256, 256),
		"ashen_god": Vector2i(256, 256),
		"void_emperor": Vector2i(384, 384),
	}
	var size: Vector2i = sizes.get(boss_name, Vector2i(256, 256))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match boss_name:
		"swamp_hydra":    _draw_swamp_hydra(img, frame_idx, anim, phase)
		"void_weaver":    _draw_void_weaver(img, frame_idx, anim, phase)
		"ancient_dragon": _draw_ancient_dragon(img, frame_idx, anim, phase)
		"riftlord":       _draw_riftlord(img, frame_idx, anim, phase)
		"ashen_god":      _draw_ashen_god(img, frame_idx, anim, phase)
		"void_emperor":   _draw_void_emperor(img, frame_idx, anim, phase)
	draw_outline(img, Color.BLACK)
	return img

static func get_boss_names() -> Array:
	return ["swamp_hydra", "void_weaver", "ancient_dragon", "riftlord", "ashen_god", "void_emperor"]

static func get_anim_config() -> Dictionary:
	return {
		"idle": {"frames": 4, "fps": 4, "loop": true},
		"walk": {"frames": 4, "fps": 6, "loop": true},
		"attack_1": {"frames": 6, "fps": 10, "loop": false},
		"attack_2": {"frames": 6, "fps": 8, "loop": false},
		"special_attack": {"frames": 8, "fps": 10, "loop": false},
		"hit": {"frames": 3, "fps": 10, "loop": false},
		"death": {"frames": 8, "fps": 7, "loop": false},
		"phase_transition": {"frames": 6, "fps": 8, "loop": false},
		"intro": {"frames": 6, "fps": 8, "loop": false},
	}

static func export_all(base_path: String) -> void:
	var path := base_path + "bosses/tier3_4/"
	var anims := get_anim_config()
	for boss_name in get_boss_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for phase in range(1, 5):
				for i in range(config["frames"]):
					save_png(generate_boss(boss_name, anim_name, i, phase), path + "%s/p%d/%s_%d.png" % [boss_name, phase, anim_name, i])
	print("  ✓ Tier 3-4 bosses exported to: ", path)

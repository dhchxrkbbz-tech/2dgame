## Tier1Bosses - Tier 1 Mini Boss sprite generátor
## 4 boss: Plague Rat King, Shadow Stalker, Cursed Treant, Ash Warden
class_name Tier1Bosses
extends PixelArtBase

# ── Boss animáció config ──
# idle(4fr/4fps), walk(4fr/6fps), attack_1(6fr/10fps), attack_2(6fr/8fps),
# special_attack(8fr/10fps), hit(3fr/10fps), death(8fr/7fps),
# phase_transition(6fr/8fps), intro(6fr/8fps)

# ────────── PLAGUE RAT KING (96×128) ──────────
const RAT_BODY   = Color(0.45, 0.38, 0.30)
const RAT_DARK   = Color(0.30, 0.25, 0.18)
const RAT_CROWN  = Color(0.85, 0.75, 0.20)
const RAT_POISON = Color(0.30, 0.70, 0.10)
const RAT_EYE    = Color(1.00, 0.20, 0.10)
const RAT_TEETH  = Color(0.95, 0.92, 0.85)

static func _draw_plague_rat_king(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 48, 120, 24, 6)
	# Óriási patkány test (kerek)
	draw_ellipse(img, 48, 72 + breath, 32, 36, RAT_BODY)
	# Fej (nagy)
	fill_rect(img, 24, 24 + breath, 48, 36, RAT_BODY)
	draw_ellipse(img, 48, 38 + breath, 22, 16, RAT_BODY)
	# Fülek
	fill_rect(img, 22, 14 + breath, 12, 16, RAT_DARK)
	fill_rect(img, 62, 14 + breath, 12, 16, RAT_DARK)
	fill_rect(img, 24, 16 + breath, 8, 12, Color(0.65, 0.45, 0.40))
	fill_rect(img, 64, 16 + breath, 8, 12, Color(0.65, 0.45, 0.40))
	# Korona (sárga négyszögek)
	fill_rect(img, 28, 10 + breath, 8, 8, RAT_CROWN)
	fill_rect(img, 40, 6 + breath, 8, 12, RAT_CROWN)
	fill_rect(img, 52, 8 + breath, 8, 10, RAT_CROWN)
	fill_rect(img, 60, 10 + breath, 8, 8, RAT_CROWN)
	# Szemek
	fill_rect(img, 32, 34 + breath, 4, 4, RAT_EYE)
	fill_rect(img, 58, 34 + breath, 4, 4, RAT_EYE)
	# Fogak (fehér kis téglalapok)
	fill_rect(img, 40, 50 + breath, 4, 6, RAT_TEETH)
	fill_rect(img, 48, 50 + breath, 4, 6, RAT_TEETH)
	# Lábak (4 láb)
	fill_rect(img, 18, 100 + breath, 10, 18, RAT_DARK)
	fill_rect(img, 34, 104 + breath, 10, 14, RAT_DARK)
	fill_rect(img, 54, 104 + breath, 10, 14, RAT_DARK)
	fill_rect(img, 68, 100 + breath, 10, 18, RAT_DARK)
	# Farok (spirál)
	draw_line_px(img, 48, 106 + breath, 56, 114, RAT_DARK)
	draw_line_px(img, 56, 114, 48, 120, RAT_DARK)
	draw_line_px(img, 48, 120, 42, 124, RAT_DARK)
	# Méreg foltok (phase 2: több)
	if phase >= 1:
		draw_circle(img, 36, 76 + breath, 4, RAT_POISON)
		draw_circle(img, 58, 82 + breath, 3, RAT_POISON)
	if phase >= 2:
		draw_circle(img, 44, 66 + breath, 5, RAT_POISON)
		draw_circle(img, 68, 74 + breath, 4, RAT_POISON)
		draw_circle(img, 28, 88 + breath, 3, RAT_POISON)
		# Méreg buborékok
		draw_circle_outline(img, 22, 44 + breath, 4, RAT_POISON)
		draw_circle_outline(img, 74, 48 + breath, 3, RAT_POISON)

# ────────── SHADOW STALKER (96×128) ──────────
const SHADOW_BDY = Color(0.08, 0.04, 0.12)
const SHADOW_TND = Color(0.12, 0.06, 0.18)
const SHADOW_EYE = Color(1.0, 1.0, 1.0)

static func _draw_shadow_stalker(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 48, 120, 18, 5)
	# Sötét humanoid
	var alpha := 1.0 if phase == 1 else 0.65
	var body_col := Color(SHADOW_BDY.r, SHADOW_BDY.g, SHADOW_BDY.b, alpha)
	fill_rect(img, 26, 30 + breath, 44, 60, body_col)
	fill_rect(img, 28, 88 + breath, 14, 24, body_col)
	fill_rect(img, 54, 88 + breath, 14, 24, body_col)
	# Shadow tendrils (karok - vékony ívek)
	for i in range(5):
		var sx := 20 - i * 3
		var sy := 40 + i * 8 + breath
		var ex := 8 - i * 2
		var ey := 44 + i * 10 + breath
		draw_line_px(img, sx, sy, ex, ey, SHADOW_TND)
		draw_line_px(img, 96 - sx, sy, 96 - ex, ey, SHADOW_TND)
	# Fej
	fill_rect(img, 32, 8 + breath, 32, 26, body_col)
	# Fénylő szemek
	fill_rect(img, 38, 18 + breath, 4, 3, SHADOW_EYE)
	fill_rect(img, 54, 18 + breath, 4, 3, SHADOW_EYE)
	# Phase 2: random alpha pixel-enként
	if phase >= 2:
		var rng := RandomNumberGenerator.new()
		rng.seed = frame_idx * 5003
		for i in range(40):
			var px := rng.randi_range(24, 72)
			var py := rng.randi_range(28, 100)
			var c := img.get_pixel(px, py)
			if c.a > 0:
				c.a = rng.randf_range(0.3, 0.8)
				_set_pixel_safe(img, px, py, c)

# ────────── CURSED TREANT (128×128) ──────────
const TREE_BARK  = Color(0.23, 0.13, 0.06)  # #3A2010
const TREE_CURSE = Color(0.38, 0.06, 0.50)  # #601080
const TREE_LEAF  = Color(0.25, 0.35, 0.10)

static func _draw_cursed_treant(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 64, 122, 28, 7)
	# Fa-törzs (nagy blokkok)
	fill_rect(img, 32, 30 + breath, 64, 76, TREE_BARK)
	fill_rect(img, 40, 24 + breath, 48, 12, TREE_BARK)
	# Barna textúra vonalak
	for i in range(6):
		draw_line_px(img, 42, 34 + i * 12 + breath, 42, 42 + i * 12 + breath, Color(0.18, 0.10, 0.04))
		draw_line_px(img, 72, 38 + i * 12 + breath, 72, 46 + i * 12 + breath, Color(0.18, 0.10, 0.04))
	# Ágak/karok (draw_line_px oldalra)
	fill_rect(img, 4, 36 + breath, 30, 14, TREE_BARK)
	fill_rect(img, 94, 36 + breath, 30, 14, TREE_BARK)
	fill_rect(img, 0, 32 + breath, 10, 8, TREE_BARK)
	fill_rect(img, 118, 32 + breath, 10, 8, TREE_BARK)
	# Arc a törzsbe vésve
	fill_rect(img, 44, 48 + breath, 10, 8, Color(0.10, 0.06, 0.02))
	fill_rect(img, 72, 48 + breath, 10, 8, Color(0.10, 0.06, 0.02))
	fill_rect(img, 54, 66 + breath, 20, 6, Color(0.10, 0.06, 0.02))
	# Lila korrumpált csomók
	draw_circle(img, 50, 38 + breath, 6, TREE_CURSE)
	draw_circle(img, 82, 56 + breath, 7, TREE_CURSE)
	draw_circle(img, 56, 78 + breath, 5, TREE_CURSE)
	draw_circle(img, 76, 42 + breath, 4, TREE_CURSE)
	# Rohadó levelek tetején
	fill_rect(img, 28, 16 + breath, 72, 14, TREE_LEAF)
	_set_pixel_safe(img, 36, 18 + breath, Color(0.35, 0.25, 0.08))
	_set_pixel_safe(img, 58, 20 + breath, Color(0.35, 0.25, 0.08))
	_set_pixel_safe(img, 80, 18 + breath, Color(0.35, 0.25, 0.08))
	# Lábak (gyökerek)
	fill_rect(img, 36, 104 + breath, 16, 20, TREE_BARK)
	fill_rect(img, 76, 104 + breath, 16, 20, TREE_BARK)
	# Phase 2: gyökerek kiemelkednek
	if phase >= 2:
		draw_line_px(img, 30, 118, 16, 126, TREE_BARK)
		draw_line_px(img, 98, 118, 112, 126, TREE_BARK)
		draw_line_px(img, 52, 120, 44, 128, TREE_BARK)

# ────────── ASH WARDEN (96×96) ──────────
const ASH_ARMOR  = Color(0.50, 0.48, 0.44)
const ASH_GLOW   = Color(1.00, 0.40, 0.00)  # #FF6600
const ASH_WEAPON = Color(0.40, 0.38, 0.35)

static func _draw_ash_warden(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 48, 90, 18, 5)
	# Hamu-páncélos harcos
	# Lábak
	fill_rect(img, 24, 68 + breath, 12, 18, ASH_ARMOR)
	fill_rect(img, 58, 68 + breath, 12, 18, ASH_ARMOR)
	# Páncél test (négyszög szegmensek)
	fill_rect(img, 18, 24 + breath, 58, 48, ASH_ARMOR)
	# Szegmensek - páncélrészek
	fill_rect(img, 20, 26 + breath, 26, 22, Color(0.46, 0.44, 0.40))
	fill_rect(img, 50, 30 + breath, 22, 18, Color(0.46, 0.44, 0.40))
	fill_rect(img, 22, 52 + breath, 50, 18, Color(0.48, 0.46, 0.42))
	# Vállpánt
	fill_rect(img, 12, 22 + breath, 16, 10, ASH_ARMOR)
	fill_rect(img, 66, 22 + breath, 16, 10, ASH_ARMOR)
	# Karok
	fill_rect(img, 8, 30 + breath, 12, 28, ASH_ARMOR)
	fill_rect(img, 74, 30 + breath, 12, 28, ASH_ARMOR)
	# Buzogány (jobb kéz)
	fill_rect(img, 78, 18 + breath, 6, 42, ASH_WEAPON)
	fill_rect(img, 74, 12 + breath, 14, 10, ASH_WEAPON)
	# Sisak
	fill_rect(img, 28, 4 + breath, 38, 22, ASH_ARMOR)
	# Izzó szemek
	fill_rect(img, 36, 12 + breath, 4, 3, ASH_GLOW)
	fill_rect(img, 54, 12 + breath, 4, 3, ASH_GLOW)
	# Hamu réteg (szürke-fehér pixel)
	_set_pixel_safe(img, 24, 30 + breath, Color(0.70, 0.68, 0.65))
	_set_pixel_safe(img, 46, 26 + breath, Color(0.70, 0.68, 0.65))
	_set_pixel_safe(img, 62, 42 + breath, Color(0.70, 0.68, 0.65))
	_set_pixel_safe(img, 32, 58 + breath, Color(0.70, 0.68, 0.65))
	# Phase 2: tűznyomok
	if phase >= 2:
		_set_pixel_safe(img, 28, 36 + breath, Color(1.0, 0.50, 0.10))
		_set_pixel_safe(img, 56, 44 + breath, Color(1.0, 0.50, 0.10))
		_set_pixel_safe(img, 40, 62 + breath, Color(1.0, 0.50, 0.10))
		draw_circle(img, 48, 50 + breath, 4, Color(1.0, 0.30, 0.00, 0.3))

static func generate_boss(boss_name: String, anim: String, frame_idx: int, phase: int = 1) -> Image:
	var sizes := {
		"plague_rat_king": Vector2i(96, 128),
		"shadow_stalker": Vector2i(96, 128),
		"cursed_treant": Vector2i(128, 128),
		"ash_warden": Vector2i(96, 96),
	}
	var size: Vector2i = sizes.get(boss_name, Vector2i(96, 128))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match boss_name:
		"plague_rat_king": _draw_plague_rat_king(img, frame_idx, anim, phase)
		"shadow_stalker":  _draw_shadow_stalker(img, frame_idx, anim, phase)
		"cursed_treant":   _draw_cursed_treant(img, frame_idx, anim, phase)
		"ash_warden":      _draw_ash_warden(img, frame_idx, anim, phase)
	draw_outline(img, Color.BLACK)
	return img

static func get_boss_names() -> Array:
	return ["plague_rat_king", "shadow_stalker", "cursed_treant", "ash_warden"]

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
	var path := base_path + "bosses/tier1/"
	var anims := get_anim_config()
	for boss_name in get_boss_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for phase in [1, 2]:
				for i in range(config["frames"]):
					save_png(generate_boss(boss_name, anim_name, i, phase), path + "%s/p%d/%s_%d.png" % [boss_name, phase, anim_name, i])
	print("  ✓ Tier 1 bosses exported to: ", path)

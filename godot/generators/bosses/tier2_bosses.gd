## Tier2Bosses - Tier 2 Dungeon Boss sprite generátor
## 4 boss: Spider Matriarch, Frozen Sentinel, Volcanic Overlord, Necromancer King
class_name Tier2Bosses
extends PixelArtBase

# ────────── SPIDER MATRIARCH (128×128) ──────────
const SPIDER_BDY = Color(0.15, 0.10, 0.08)
const SPIDER_CRY = Color(0.30, 0.55, 0.85)
const SPIDER_EYE = Color(0.40, 0.70, 1.00)
const SPIDER_WEB = Color(0.80, 0.78, 0.75, 0.5)

static func _draw_spider_matriarch(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 64, 120, 30, 7)
	# Óriási pók test
	draw_ellipse(img, 64, 70 + breath, 28, 22, SPIDER_BDY)
	# Fejrész
	draw_ellipse(img, 64, 38 + breath, 18, 14, SPIDER_BDY)
	# Kristályos test fénypont pixelek
	_set_pixel_safe(img, 52, 64 + breath, SPIDER_CRY)
	_set_pixel_safe(img, 74, 68 + breath, SPIDER_CRY)
	_set_pixel_safe(img, 64, 74 + breath, SPIDER_CRY)
	_set_pixel_safe(img, 58, 58 + breath, SPIDER_CRY)
	# 8 láb (csillag alakban)
	var leg_points := [
		[34, 40, 4, 16], [24, 52, 2, 40], [22, 66, 0, 90], [28, 78, 8, 110],
		[94, 40, 124, 16], [104, 52, 126, 40], [106, 66, 128, 90], [100, 78, 120, 110]
	]
	for lp in leg_points:
		draw_line_px(img, lp[0], lp[1] + breath, lp[2], lp[3], SPIDER_BDY)
		draw_line_px(img, lp[0] + 1, lp[1] + breath, lp[2] + 1, lp[3], SPIDER_BDY)
	# 6 szem (izzó kék)
	for i in range(3):
		_set_pixel_safe(img, 54 + i * 4, 32 + breath, SPIDER_EYE)
		_set_pixel_safe(img, 56 + i * 4, 36 + breath, SPIDER_EYE)
	# Háló mintázat a testen
	for i in range(4):
		draw_line_px(img, 40, 54 + i * 8 + breath, 88, 54 + i * 8 + breath, SPIDER_WEB)
	draw_line_px(img, 64, 48 + breath, 64, 92 + breath, SPIDER_WEB)
	# Phase 3: tojások
	if phase >= 3:
		for epos in [Vector2i(20, 100), Vector2i(40, 108), Vector2i(88, 100), Vector2i(106, 108)]:
			draw_circle(img, epos.x, epos.y, 4, Color(0.80, 0.75, 0.65))

# ────────── FROZEN SENTINEL (128×128) ──────────
const ICE_BODY   = Color(0.75, 0.85, 0.95)
const ICE_HEART  = Color(0.20, 0.85, 0.95)
const ICE_CRACK  = Color(0.10, 0.10, 0.15)
const ICE_DARK   = Color(0.50, 0.60, 0.75)

static func _draw_frozen_sentinel(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 64, 122, 26, 7)
	# Golem - nagy négyszögletes tömb-forma
	fill_rect(img, 20, 28 + breath, 88, 72, ICE_BODY)
	# Lábak
	fill_rect(img, 28, 98 + breath, 20, 24, ICE_BODY)
	fill_rect(img, 80, 98 + breath, 20, 24, ICE_BODY)
	# Karok
	fill_rect(img, 4, 36 + breath, 18, 44, ICE_BODY)
	fill_rect(img, 106, 36 + breath, 18, 44, ICE_BODY)
	# Jég rétegek (draw_rect átfedők)
	fill_rect(img, 24, 32 + breath, 80, 4, ICE_DARK)
	fill_rect(img, 24, 56 + breath, 80, 4, ICE_DARK)
	fill_rect(img, 24, 80 + breath, 80, 4, ICE_DARK)
	# Jégkristály szív (cián kör)
	draw_circle(img, 64, 60 + breath, 10, ICE_HEART)
	draw_circle(img, 64, 60 + breath, 5, Color(0.90, 0.98, 1.00))
	# Fej
	fill_rect(img, 36, 4 + breath, 56, 28, ICE_BODY)
	# Szemek
	fill_rect(img, 46, 12 + breath, 6, 4, ICE_HEART)
	fill_rect(img, 76, 12 + breath, 6, 4, ICE_HEART)
	# Phase 2: crack-ok
	if phase >= 2:
		draw_line_px(img, 40, 36 + breath, 56, 52 + breath, ICE_CRACK)
		draw_line_px(img, 80, 40 + breath, 70, 60 + breath, ICE_CRACK)
		draw_line_px(img, 50, 68 + breath, 72, 84 + breath, ICE_CRACK)
	# Phase 3: rage red glow
	if phase >= 3:
		draw_circle(img, 64, 60 + breath, 14, Color(0.80, 0.10, 0.05, 0.3))

# ────────── VOLCANIC OVERLORD (192×192) ──────────
const OBSID_BDY  = Color(0.06, 0.04, 0.04)
const LAVA_ORG   = Color(1.00, 0.40, 0.05)
const LAVA_RED   = Color(0.85, 0.15, 0.05)

static func _draw_volcanic_overlord(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 96, 184, 36, 8)
	# Obsidián szikla lény
	fill_rect(img, 40, 40 + breath, 112, 110, OBSID_BDY)
	# Lábak
	fill_rect(img, 48, 148 + breath, 28, 36, OBSID_BDY)
	fill_rect(img, 116, 148 + breath, 28, 36, OBSID_BDY)
	# Karok
	fill_rect(img, 10, 52 + breath, 32, 60, OBSID_BDY)
	fill_rect(img, 150, 52 + breath, 32, 60, OBSID_BDY)
	# Vállak
	fill_rect(img, 30, 36 + breath, 30, 20, OBSID_BDY)
	fill_rect(img, 132, 36 + breath, 30, 20, OBSID_BDY)
	# Fej
	fill_rect(img, 60, 8 + breath, 72, 36, OBSID_BDY)
	# Szemek
	fill_rect(img, 74, 18 + breath, 8, 6, LAVA_ORG)
	fill_rect(img, 110, 18 + breath, 8, 6, LAVA_ORG)
	# Láva repedések
	var cracks := [
		[56, 60, 80, 90], [100, 50, 130, 80], [70, 100, 90, 130],
		[120, 90, 140, 120], [60, 80, 50, 110], [130, 70, 144, 100]
	]
	var crack_col := LAVA_ORG if phase <= 2 else LAVA_RED
	for c in cracks:
		draw_line_px(img, c[0], c[1] + breath, c[2], c[3] + breath, crack_col)
		draw_line_px(img, c[0] + 1, c[1] + breath, c[2] + 1, c[3] + breath, crack_col)
	# Phase-based lava gradient
	if phase >= 3:
		draw_circle(img, 96, 90 + breath, 16, Color(LAVA_RED.r, LAVA_RED.g, LAVA_RED.b, 0.3))
	if phase >= 4:
		# Teljes izzás
		for y_off in range(0, 100, 8):
			for x_off in range(0, 100, 12):
				_set_pixel_safe(img, 48 + x_off, 44 + y_off + breath, Color(LAVA_ORG.r, LAVA_ORG.g, LAVA_ORG.b, 0.2))

# ────────── NECROMANCER KING (128×128) ──────────
const NECRO_ROBE = Color(0.25, 0.03, 0.38)  # #400860
const NECRO_BONE = Color(0.88, 0.84, 0.75)
const NECRO_GLW  = Color(0.50, 0.13, 0.75)  # #8020C0
const NECRO_GOLD = Color(0.85, 0.75, 0.20)

static func _draw_necromancer_king(img: Image, frame_idx: int, anim: String, phase: int = 1) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 64, 122, 22, 6)
	# Lila robe
	fill_rect(img, 28, 36 + breath, 72, 76, NECRO_ROBE)
	fill_rect(img, 24, 104 + breath, 80, 14, Color(0.20, 0.02, 0.30))
	# Karok (csontkezek)
	fill_rect(img, 14, 44 + breath, 16, 32, NECRO_ROBE)
	fill_rect(img, 98, 44 + breath, 16, 32, NECRO_ROBE)
	# Csontujjak
	fill_rect(img, 10, 74 + breath, 4, 10, NECRO_BONE)
	fill_rect(img, 16, 74 + breath, 4, 12, NECRO_BONE)
	fill_rect(img, 22, 74 + breath, 4, 10, NECRO_BONE)
	fill_rect(img, 102, 74 + breath, 4, 10, NECRO_BONE)
	fill_rect(img, 108, 74 + breath, 4, 12, NECRO_BONE)
	fill_rect(img, 114, 74 + breath, 4, 10, NECRO_BONE)
	# Lila energia a kezek közt
	draw_circle(img, 64, 76 + breath, 12, Color(NECRO_GLW.r, NECRO_GLW.g, NECRO_GLW.b, 0.4))
	draw_circle(img, 64, 76 + breath, 6, Color(NECRO_GLW.r, NECRO_GLW.g, NECRO_GLW.b, 0.7))
	# Fej (koponya + korona)
	fill_rect(img, 40, 6 + breath, 48, 32, NECRO_BONE)
	# Szem üregek
	fill_rect(img, 48, 16 + breath, 8, 8, Color(0.10, 0.05, 0.15))
	fill_rect(img, 72, 16 + breath, 8, 8, Color(0.10, 0.05, 0.15))
	# Izzó szemek
	fill_rect(img, 50, 18 + breath, 4, 4, NECRO_GLW)
	fill_rect(img, 74, 18 + breath, 4, 4, NECRO_GLW)
	# Csontkorona
	fill_rect(img, 42, 0 + breath, 8, 10, NECRO_GOLD)
	fill_rect(img, 56, 0 + breath, 8, 8, NECRO_GOLD)
	fill_rect(img, 64, 0 + breath, 8, 10, NECRO_GOLD)
	fill_rect(img, 78, 0 + breath, 8, 8, NECRO_GOLD)
	# Phase 4: lich transform
	if phase >= 4:
		# Zöld nekrotikus aura
		draw_circle(img, 64, 64 + breath, 36, Color(0.20, 0.80, 0.15, 0.15))
		# Zöldes szemek
		fill_rect(img, 50, 18 + breath, 4, 4, Color(0.30, 1.0, 0.20))
		fill_rect(img, 74, 18 + breath, 4, 4, Color(0.30, 1.0, 0.20))

static func generate_boss(boss_name: String, anim: String, frame_idx: int, phase: int = 1) -> Image:
	var sizes := {
		"spider_matriarch": Vector2i(128, 128),
		"frozen_sentinel": Vector2i(128, 128),
		"volcanic_overlord": Vector2i(192, 192),
		"necromancer_king": Vector2i(128, 128),
	}
	var size: Vector2i = sizes.get(boss_name, Vector2i(128, 128))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match boss_name:
		"spider_matriarch":  _draw_spider_matriarch(img, frame_idx, anim, phase)
		"frozen_sentinel":   _draw_frozen_sentinel(img, frame_idx, anim, phase)
		"volcanic_overlord": _draw_volcanic_overlord(img, frame_idx, anim, phase)
		"necromancer_king":  _draw_necromancer_king(img, frame_idx, anim, phase)
	draw_outline(img, Color.BLACK)
	return img

static func get_boss_names() -> Array:
	return ["spider_matriarch", "frozen_sentinel", "volcanic_overlord", "necromancer_king"]

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
	var path := base_path + "bosses/tier2/"
	var anims := get_anim_config()
	for boss_name in get_boss_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for phase in range(1, 5):
				for i in range(config["frames"]):
					save_png(generate_boss(boss_name, anim_name, i, phase), path + "%s/p%d/%s_%d.png" % [boss_name, phase, anim_name, i])
	print("  ✓ Tier 2 bosses exported to: ", path)

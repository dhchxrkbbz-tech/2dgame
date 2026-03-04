## AshenWastesEnemies - Ashen Wastes biome enemy sprite generátor
## 5 enemy: Ash Zombie, Cinder Rat, Ember Archer, Ash Witch, Ash Golem
class_name AshenWastesEnemies
extends PixelArtBase

# Biome paletta
const ASH_GREY     = Color(0.42, 0.40, 0.37)
const ASH_LIGHT    = Color(0.53, 0.50, 0.44)
const EMBER_ORANGE = Color(1.0, 0.40, 0.0)
const EMBER_GLOW   = Color(1.0, 0.60, 0.10)
const DARK_ASH     = Color(0.18, 0.15, 0.12)
const BONE_WHITE   = Color(0.85, 0.80, 0.72)
const WITCH_GRAY   = Color(0.30, 0.28, 0.25)
const WITCH_PURPLE = Color(0.40, 0.15, 0.50)
const SKIN_GRAY    = Color(0.55, 0.50, 0.45)

# ═══════════════════════════════════════════════════════════════
# ASH ZOMBIE (64×96) - Lassú, izzó szemek, hamucsomók
# ═══════════════════════════════════════════════════════════════
static func _draw_ash_zombie(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	var sway := get_walk_sway(frame_idx, 4) if anim == "walk" else 0
	
	draw_shadow(img, 32, 90, 12, 4)
	# Lábak - lassú, csoszogó
	fill_rect(img, 18 + sway, 76 + breath, 10, 14, SKIN_GRAY)
	fill_rect(img, 36 + sway, 76 + breath, 10, 14, SKIN_GRAY)
	# Test - emberi alap, lefelé lógó karok
	fill_rect(img, 16, 30 + breath, 32, 48, SKIN_GRAY)
	fill_rect(img, 16, 30 + breath, 6, 48, Color(0.45, 0.40, 0.35))
	# Hamucsomók a testen
	fill_rect(img, 22, 40 + breath, 6, 4, ASH_LIGHT)
	fill_rect(img, 36, 50 + breath, 8, 4, ASH_LIGHT)
	fill_rect(img, 28, 60 + breath, 4, 6, ASH_GREY)
	# Karok - lógó
	fill_rect(img, 8, 36 + breath, 10, 34, SKIN_GRAY)
	fill_rect(img, 46, 36 + breath, 10, 34, SKIN_GRAY)
	# Kezek
	fill_rect(img, 8, 66 + breath, 10, 6, Color(0.48, 0.42, 0.38))
	fill_rect(img, 46, 66 + breath, 10, 6, Color(0.48, 0.42, 0.38))
	# Fej
	fill_rect(img, 22, 8 + breath, 20, 24, SKIN_GRAY)
	# Izzó szemek
	fill_rect(img, 26, 18 + breath, 4, 3, EMBER_ORANGE)
	fill_rect(img, 34, 18 + breath, 4, 3, EMBER_ORANGE)
	# Szájnyílás
	fill_rect(img, 28, 26 + breath, 8, 3, DARK_ASH)
	
	if anim == "attack":
		var phase := frame_idx % 4
		if phase == 2:
			# Karok előrenyúlnak
			fill_rect(img, 12, 30, 8, 6, SKIN_GRAY)
			fill_rect(img, 44, 30, 8, 6, SKIN_GRAY)
	
	if anim == "death":
		var phase := frame_idx % 4
		if phase >= 2:
			# Szétesés - hamu felhő
			for i in range(8):
				var rx := 10 + (frame_idx * 7 + i * 13) % 44
				var ry := 50 + (frame_idx * 11 + i * 7) % 30
				draw_circle(img, rx, ry, 3, Color(ASH_LIGHT.r, ASH_LIGHT.g, ASH_LIGHT.b, 0.6 - phase * 0.15))

# ═══════════════════════════════════════════════════════════════
# CINDER RAT (48×48) - Kis rágcsáló, izzó farok
# ═══════════════════════════════════════════════════════════════
static func _draw_cinder_rat(img: Image, frame_idx: int, anim: String) -> void:
	var bob := get_walk_bob(frame_idx, 4) if anim == "walk" else 0
	
	draw_shadow(img, 24, 44, 10, 3)
	# Test - kerek rágcsáló forma
	draw_ellipse(img, 24, 26 + bob, 12, 10, Color(0.55, 0.23, 0.0))
	# Fej
	draw_ellipse(img, 36, 22 + bob, 8, 7, Color(0.55, 0.23, 0.0))
	# Hegyes fogak
	_set_pixel_safe(img, 42, 26 + bob, BONE_WHITE)
	_set_pixel_safe(img, 43, 27 + bob, BONE_WHITE)
	# Szemek - izzó
	_set_pixel_safe(img, 38, 20 + bob, EMBER_ORANGE)
	_set_pixel_safe(img, 40, 20 + bob, EMBER_ORANGE)
	# Mancsok
	fill_rect(img, 16, 34 + bob, 6, 4, Color(0.10, 0.08, 0.05))
	fill_rect(img, 26, 34 + bob, 6, 4, Color(0.10, 0.08, 0.05))
	# Izzó farok
	draw_line_px(img, 12, 24 + bob, 4, 18 + bob, EMBER_ORANGE)
	draw_line_px(img, 4, 18 + bob, 2, 14 + bob, EMBER_GLOW)
	
	if anim == "attack" and frame_idx % 4 == 2:
		# Harapás
		fill_rect(img, 44, 24 + bob, 4, 4, BONE_WHITE)

# ═══════════════════════════════════════════════════════════════
# EMBER ARCHER (64×96) - Narancsvörös páncél, íjász
# ═══════════════════════════════════════════════════════════════
static func _draw_ember_archer(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	var bob := get_walk_bob(frame_idx, 4) if anim == "walk" else 0
	var oy := breath + bob
	
	draw_shadow(img, 32, 90, 12, 4)
	# Csizmák
	fill_rect(img, 18, 78 + oy, 10, 12, DARK_ASH)
	fill_rect(img, 36, 78 + oy, 10, 12, DARK_ASH)
	# Lábak
	fill_rect(img, 20, 66 + oy, 8, 14, Color(0.20, 0.15, 0.10))
	fill_rect(img, 36, 66 + oy, 8, 14, Color(0.20, 0.15, 0.10))
	# Sötét köpeny
	fill_rect(img, 14, 44 + oy, 36, 24, Color(0.12, 0.10, 0.08))
	# Narancsvörös páncél mellvért
	fill_rect(img, 16, 28 + oy, 32, 20, Color(0.70, 0.25, 0.05))
	fill_rect(img, 16, 28 + oy, 6, 20, Color(0.55, 0.20, 0.04))
	# Karok
	fill_rect(img, 8, 32 + oy, 10, 26, Color(0.12, 0.10, 0.08))
	fill_rect(img, 46, 32 + oy, 10, 26, Color(0.12, 0.10, 0.08))
	# Kezek
	fill_rect(img, 8, 56 + oy, 8, 6, SKIN_GRAY)
	fill_rect(img, 48, 56 + oy, 8, 6, SKIN_GRAY)
	# Íj (bal kéz)
	draw_line_px(img, 6, 24 + oy, 6, 64 + oy, Color(0.40, 0.25, 0.10))
	draw_line_px(img, 6, 24 + oy, 12, 44 + oy, Color(0.80, 0.75, 0.60))
	draw_line_px(img, 6, 64 + oy, 12, 44 + oy, Color(0.80, 0.75, 0.60))
	# Fej
	fill_rect(img, 22, 8 + oy, 20, 22, SKIN_GRAY)
	# Sisak
	fill_rect(img, 20, 6 + oy, 24, 10, Color(0.70, 0.25, 0.05))
	# Szemek
	_set_pixel_safe(img, 28, 18 + oy, EMBER_ORANGE)
	_set_pixel_safe(img, 36, 18 + oy, EMBER_ORANGE)
	
	if anim == "attack":
		var phase := frame_idx % 4
		if phase >= 1 and phase <= 2:
			# Tüzes nyíl
			var arrow_x := 50 + (phase - 1) * 6
			fill_rect(img, arrow_x, 40, 10, 2, Color(0.80, 0.30, 0.05))
			_set_pixel_safe(img, arrow_x + 10, 40, EMBER_GLOW)

# ═══════════════════════════════════════════════════════════════
# ASH WITCH (64×96) - Sötétszürke robe, lila glifek, fehér haj
# ═══════════════════════════════════════════════════════════════
static func _draw_ash_witch(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	var oy := breath
	
	draw_shadow(img, 32, 90, 12, 4)
	# Robe (földig ér)
	fill_rect(img, 12, 30 + oy, 40, 58, WITCH_GRAY)
	fill_rect(img, 10, 82 + oy, 44, 8, Color(0.25, 0.22, 0.20))
	fill_rect(img, 12, 30 + oy, 6, 58, Color(0.25, 0.22, 0.20))
	# Lila glifek a robe-on
	draw_circle(img, 22, 50 + oy, 3, WITCH_PURPLE)
	draw_circle(img, 40, 60 + oy, 3, WITCH_PURPLE)
	_set_pixel_safe(img, 30, 44 + oy, WITCH_PURPLE)
	_set_pixel_safe(img, 34, 56 + oy, WITCH_PURPLE)
	# Karok előrenyújtva varázsláshoz
	fill_rect(img, 4, 34 + oy, 14, 20, WITCH_GRAY)
	fill_rect(img, 46, 34 + oy, 14, 20, WITCH_GRAY)
	fill_rect(img, 4, 52 + oy, 10, 6, SKIN_GRAY)
	fill_rect(img, 50, 52 + oy, 10, 6, SKIN_GRAY)
	# Fej
	fill_rect(img, 22, 6 + oy, 20, 26, SKIN_GRAY)
	# Fehér haj
	fill_rect(img, 20, 4 + oy, 24, 10, BONE_WHITE)
	fill_rect(img, 18, 8 + oy, 4, 20, BONE_WHITE)
	fill_rect(img, 42, 8 + oy, 4, 20, BONE_WHITE)
	# Szemek
	_set_pixel_safe(img, 28, 18 + oy, WITCH_PURPLE)
	_set_pixel_safe(img, 36, 18 + oy, WITCH_PURPLE)
	
	if anim == "attack" or anim == "special":
		var phase := frame_idx % 4
		if phase >= 1:
			# Varázslat - lila energia a kezek közt
			var intensity := float(phase) / 3.0
			draw_circle(img, 32, 46, 8 + phase * 3, Color(WITCH_PURPLE.r, WITCH_PURPLE.g, WITCH_PURPLE.b, intensity * 0.6))

# ═══════════════════════════════════════════════════════════════
# ASH GOLEM (96×128) - Masszív, kő textúra, izzó repedések
# ═══════════════════════════════════════════════════════════════
static func _draw_ash_golem(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	
	draw_shadow(img, 48, 122, 22, 6)
	# Lábak - vastag oszlopok
	fill_rect(img, 18, 96 + breath, 20, 28, ASH_GREY)
	fill_rect(img, 58, 96 + breath, 20, 28, ASH_GREY)
	# Test - masszív tömb
	fill_rect(img, 12, 32 + breath, 72, 68, ASH_GREY)
	fill_rect(img, 12, 32 + breath, 12, 68, Color(0.35, 0.32, 0.28))
	# Kő textúra (nagy fill_rect blokkok)
	fill_rect(img, 24, 40 + breath, 20, 14, ASH_LIGHT)
	fill_rect(img, 52, 55 + breath, 18, 12, ASH_LIGHT)
	fill_rect(img, 30, 70 + breath, 22, 10, Color(0.48, 0.44, 0.40))
	# Izzó repedések
	draw_line_px(img, 30, 36 + breath, 42, 60 + breath, EMBER_ORANGE)
	draw_line_px(img, 50, 44 + breath, 60, 72 + breath, EMBER_ORANGE)
	draw_line_px(img, 20, 56 + breath, 38, 80 + breath, EMBER_GLOW)
	# Karok - vastag
	fill_rect(img, 0, 40 + breath, 16, 44, ASH_GREY)
	fill_rect(img, 80, 40 + breath, 16, 44, ASH_GREY)
	# Öklök
	fill_rect(img, 0, 80 + breath, 16, 12, Color(0.50, 0.46, 0.42))
	fill_rect(img, 80, 80 + breath, 16, 12, Color(0.50, 0.46, 0.42))
	# Fej - kis kő tömb a test tetején
	fill_rect(img, 30, 12 + breath, 36, 24, ASH_GREY)
	# Izzó szemek
	fill_rect(img, 36, 22 + breath, 6, 4, EMBER_ORANGE)
	fill_rect(img, 54, 22 + breath, 6, 4, EMBER_ORANGE)
	
	if anim == "attack" and frame_idx % 4 == 2:
		# Földbe csapás
		draw_circle(img, 48, 120, 20, Color(EMBER_ORANGE.r, EMBER_ORANGE.g, EMBER_ORANGE.b, 0.5))

# ═══════════════════════════════════════════════════════════════
# UNIFIED GENERATOR
# ═══════════════════════════════════════════════════════════════
static func generate_enemy(enemy_name: String, anim: String, frame_idx: int) -> Image:
	var sizes := {
		"ash_zombie": Vector2i(64, 96),
		"cinder_rat": Vector2i(48, 48),
		"ember_archer": Vector2i(64, 96),
		"ash_witch": Vector2i(64, 96),
		"ash_golem": Vector2i(96, 128),
	}
	var size: Vector2i = sizes.get(enemy_name, Vector2i(64, 96))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	match enemy_name:
		"ash_zombie":   _draw_ash_zombie(img, frame_idx, anim)
		"cinder_rat":   _draw_cinder_rat(img, frame_idx, anim)
		"ember_archer": _draw_ember_archer(img, frame_idx, anim)
		"ash_witch":    _draw_ash_witch(img, frame_idx, anim)
		"ash_golem":    _draw_ash_golem(img, frame_idx, anim)
	
	draw_outline(img, Color.BLACK)
	return img

static func get_enemy_names() -> Array:
	return ["ash_zombie", "cinder_rat", "ember_archer", "ash_witch", "ash_golem"]

static func get_anim_config() -> Dictionary:
	return {
		"idle":    {"frames": 4, "fps": 5, "loop": true},
		"walk":    {"frames": 4, "fps": 8, "loop": true},
		"attack":  {"frames": 4, "fps": 10, "loop": false},
		"hit":     {"frames": 2, "fps": 10, "loop": false},
		"death":   {"frames": 4, "fps": 7, "loop": false},
	}

static func export_all(base_path: String) -> void:
	var path := base_path + "ashen_wastes/"
	var anims := get_anim_config()
	for enemy_name in get_enemy_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for i in range(config["frames"]):
				save_png(
					generate_enemy(enemy_name, anim_name, i),
					path + "%s/%s_%d.png" % [enemy_name, anim_name, i]
				)
	print("  ✓ Ashen Wastes enemies exported to: ", path)

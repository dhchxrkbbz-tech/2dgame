## CombatVfxGenerator - Combat VFX effektek
## Melee/ranged hit, crit flash, block spark, dodge trail, boss telegraph, status overlays, damage font
class_name CombatVfxGenerator
extends PixelArtBase

# --- Melee ütés (4 frame, 32×32) ---
static func gen_melee_hit() -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(4):
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var progress := float(f) / 3.0
		var alpha := 1.0 - progress * 0.4
		# Fehér villanás
		if f == 0:
			draw_circle(img, 16, 16, 8, Color(1.0, 1.0, 1.0, 0.6))
		# Vágásív
		var arc := int(progress * 20) + 5
		for i in range(arc):
			var a := float(i) / arc * PI * 0.8 - 0.4
			var px := int(16 + cos(a) * 10)
			var py := int(16 + sin(a) * 10)
			_set_pixel_safe(img, px, py, Color(0.90, 0.85, 0.70, alpha))
		# Szikrák
		var rng := RandomNumberGenerator.new()
		rng.seed = f * 222
		for s in range(3 + f):
			_set_pixel_safe(img, rng.randi_range(4, 28), rng.randi_range(4, 28), Color(1.0, 0.80, 0.30, alpha * 0.6))
		frames.append(img)
	return frames

# --- Ranged ütés (4 frame, 32×32) ---
static func gen_ranged_hit() -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(4):
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var radius := 3 + f * 3
		var alpha := 1.0 - float(f) * 0.25
		draw_circle(img, 16, 16, radius, Color(0.90, 0.70, 0.20, alpha * 0.4))
		draw_circle_outline(img, 16, 16, radius, Color(1.0, 0.80, 0.30, alpha))
		frames.append(img)
	return frames

# --- Critical hit flash (3 frame, 48×48) ---
static func gen_crit_flash() -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(3):
		var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var alpha := 1.0 - float(f) * 0.3
		# Csillagszerű villanás
		for angle_i in range(12):
			var angle := angle_i * PI / 6.0
			var length := 15 + f * 3
			draw_line_px(img, 24, 24, int(24 + cos(angle) * length), int(24 + sin(angle) * length),
				Color(1.0, 0.90, 0.30, alpha))
		draw_circle(img, 24, 24, 5 - f, Color(1.0, 1.0, 0.80, alpha))
		frames.append(img)
	return frames

# --- Block spark (3 frame, 32×32) ---
static func gen_block_spark() -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(3):
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var alpha := 1.0 - float(f) * 0.3
		# Pajzs villanás
		draw_circle_outline(img, 16, 16, 10 + f * 2, Color(0.70, 0.65, 0.30, alpha))
		# Szikrák
		var rng := RandomNumberGenerator.new()
		rng.seed = f * 333
		for s in range(5 + f * 2):
			var px := rng.randi_range(4, 28)
			var py := rng.randi_range(4, 28)
			_set_pixel_safe(img, px, py, Color(1.0, 0.85, 0.30, alpha * 0.7))
		frames.append(img)
	return frames

# --- Dodge trail (3 frame, 64×64) ---
static func gen_dodge_trail() -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(3):
		var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var alpha := 0.5 - float(f) * 0.15
		# Szellemkép (halványuló silhouet)
		fill_rect(img, 20 + f * 6, 16, 16, 32, Color(0.50, 0.50, 0.55, alpha))
		fill_rect(img, 24 + f * 6, 8, 8, 12, Color(0.50, 0.50, 0.55, alpha))
		frames.append(img)
	return frames

# --- Boss telegraph (előrejelzés, 6 frame, 96×96) ---
static func gen_boss_telegraph(shape: String) -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(6):
		var img := Image.create(96, 96, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var alpha := 0.1 + float(f) / 5.0 * 0.4  # Erősödő figyelmeztetés
		var warn := Color(1.0, 0.20, 0.10, alpha)
		match shape:
			"circle":
				draw_circle(img, 48, 48, 35, Color(warn.r, warn.g, warn.b, alpha * 0.3))
				draw_circle_outline(img, 48, 48, 35, warn)
				draw_circle_outline(img, 48, 48, 33, Color(warn.r, warn.g, warn.b, alpha * 0.5))
			"cone":
				for row in range(40):
					var width := int(float(row) / 40.0 * 30)
					fill_rect(img, 48 - width, 48 - row, width * 2, 1, Color(warn.r, warn.g, warn.b, alpha * 0.3))
				draw_line_px(img, 48, 48, 18, 8, warn)
				draw_line_px(img, 48, 48, 78, 8, warn)
			"line":
				fill_rect(img, 38, 8, 20, 80, Color(warn.r, warn.g, warn.b, alpha * 0.3))
				fill_rect(img, 38, 8, 2, 80, warn)
				fill_rect(img, 56, 8, 2, 80, warn)
			"cross":
				fill_rect(img, 40, 8, 16, 80, Color(warn.r, warn.g, warn.b, alpha * 0.3))
				fill_rect(img, 8, 40, 80, 16, Color(warn.r, warn.g, warn.b, alpha * 0.3))
		frames.append(img)
	return frames

# --- Status overlay (32×32, státusz hatás vizualizáció a karakterre) ---
static func gen_status_overlay(status: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match status:
		"poison_drip":
			for i in range(5):
				var rng := RandomNumberGenerator.new()
				rng.seed = i * 777
				_set_pixel_safe(img, rng.randi_range(8, 24), rng.randi_range(20, 30), Color(0.20, 0.55, 0.10, 0.6))
		"fire_aura":
			for i in range(8):
				var x := 8 + i * 2
				var h := 4 + (i % 3) * 3
				fill_rect(img, x, 28 - h, 2, h, Color(1.0, 0.50, 0.10, 0.4))
		"frost_overlay":
			for corner in [Vector2i(4, 4), Vector2i(24, 4), Vector2i(4, 24), Vector2i(24, 24)]:
				fill_rect(img, corner.x, corner.y, 4, 4, Color(0.60, 0.80, 1.0, 0.3))
		"shadow_cloak":
			for y in range(32):
				for x in range(32):
					var dist := Vector2(x - 16, y - 16).length()
					if dist > 12 and dist < 16:
						_set_pixel_safe(img, x, y, Color(0.10, 0.05, 0.15, 0.4))
	return img

# --- Damage font (számjegyek 0-9, 8×12 pixel) ---
static func gen_damage_digit(digit: int, is_crit: bool) -> Image:
	var img := Image.create(8, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var col := Color(1.0, 0.90, 0.20) if is_crit else Color(1.0, 1.0, 1.0)
	var outline_col := Color(0.10, 0.05, 0.0) if is_crit else Color(0.15, 0.15, 0.15)
	# 5×7 pixel font
	var patterns := _get_digit_pattern(digit)
	for py in range(7):
		for px in range(5):
			if patterns[py * 5 + px]:
				_set_pixel_safe(img, px + 1, py + 2, col)
				# Outline
				if px > 0: _set_pixel_safe(img, px, py + 2, outline_col)
				if px < 4: _set_pixel_safe(img, px + 2, py + 2, outline_col)
	return img

static func _get_digit_pattern(digit: int) -> Array:
	# 5×7 bitminta minden számjegyhez
	var patterns := {
		0: [0,1,1,1,0, 1,0,0,0,1, 1,0,0,1,1, 1,0,1,0,1, 1,1,0,0,1, 1,0,0,0,1, 0,1,1,1,0],
		1: [0,0,1,0,0, 0,1,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,1,1,1,0],
		2: [0,1,1,1,0, 1,0,0,0,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,1,0,0,0, 1,1,1,1,1],
		3: [0,1,1,1,0, 1,0,0,0,1, 0,0,0,0,1, 0,0,1,1,0, 0,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0],
		4: [0,0,0,1,0, 0,0,1,1,0, 0,1,0,1,0, 1,0,0,1,0, 1,1,1,1,1, 0,0,0,1,0, 0,0,0,1,0],
		5: [1,1,1,1,1, 1,0,0,0,0, 1,1,1,1,0, 0,0,0,0,1, 0,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0],
		6: [0,1,1,1,0, 1,0,0,0,0, 1,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0],
		7: [1,1,1,1,1, 0,0,0,0,1, 0,0,0,1,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0, 0,0,1,0,0],
		8: [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,0],
		9: [0,1,1,1,0, 1,0,0,0,1, 1,0,0,0,1, 0,1,1,1,1, 0,0,0,0,1, 0,0,0,0,1, 0,1,1,1,0],
	}
	return patterns.get(digit, patterns[0])

static func get_anim_config() -> Dictionary:
	return {
		"melee_hit": {"frames": 4, "fps": 12, "loop": false},
		"ranged_hit": {"frames": 4, "fps": 10, "loop": false},
		"crit_flash": {"frames": 3, "fps": 12, "loop": false},
		"block_spark": {"frames": 3, "fps": 10, "loop": false},
		"dodge_trail": {"frames": 3, "fps": 8, "loop": false},
		"boss_telegraph": {"frames": 6, "fps": 8, "loop": true},
	}

static func export_all(base_path: String) -> void:
	var path := base_path + "effects/combat/"
	# Melee/ranged hit
	var melee := gen_melee_hit()
	for i in range(melee.size()):
		save_png(melee[i], path + "melee_hit_%d.png" % i)
	var ranged := gen_ranged_hit()
	for i in range(ranged.size()):
		save_png(ranged[i], path + "ranged_hit_%d.png" % i)
	# Crit flash
	var crit := gen_crit_flash()
	for i in range(crit.size()):
		save_png(crit[i], path + "crit_flash_%d.png" % i)
	# Block spark
	var block := gen_block_spark()
	for i in range(block.size()):
		save_png(block[i], path + "block_spark_%d.png" % i)
	# Dodge trail
	var dodge := gen_dodge_trail()
	for i in range(dodge.size()):
		save_png(dodge[i], path + "dodge_trail_%d.png" % i)
	# Boss telegraph
	for shape in ["circle", "cone", "line", "cross"]:
		var tele := gen_boss_telegraph(shape)
		for i in range(tele.size()):
			save_png(tele[i], path + "telegraph_%s_%d.png" % [shape, i])
	# Status overlays
	for status in ["poison_drip", "fire_aura", "frost_overlay", "shadow_cloak"]:
		save_png(gen_status_overlay(status), path + "overlay_%s.png" % status)
	# Damage font
	for d in range(10):
		save_png(gen_damage_digit(d, false), path + "dmg_font/digit_%d.png" % d)
		save_png(gen_damage_digit(d, true), path + "dmg_font/digit_%d_crit.png" % d)
	print("  ✓ Combat VFX exported to: ", path)

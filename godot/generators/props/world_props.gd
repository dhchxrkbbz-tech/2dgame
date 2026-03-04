## WorldPropsGenerator - Világ dekorációs propok (~83 sprite)
## Biome-specifikus növények, sziklák, fáklyák, tűzhelyek stb.
class_name WorldPropsGenerator
extends PixelArtBase

# --- Fa típusok (bioménként) ---
static func gen_tree(biome: String, variant: int) -> Image:
	var img := Image.create(64, 96, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var pal: Dictionary = PALETTES.get(biome, PALETTES["ashen_wastes"])
	var rng := RandomNumberGenerator.new()
	rng.seed = biome.hash() + variant * 333
	# Törzs
	var trunk_col: Color = pal.get("wall", Color(0.30, 0.20, 0.10))
	fill_rect(img, 26, 48, 12, 48, trunk_col)
	fill_rect(img, 28, 50, 8, 44, trunk_col.lightened(0.1))
	# Korona (biome-specifikus szín)
	var foliage: Color = pal.get("ground2", Color(0.20, 0.40, 0.12))
	match biome:
		"corrupted_forest":
			foliage = Color(0.30, 0.10, 0.35)
		"frozen_peaks":
			foliage = Color(0.65, 0.75, 0.85)
		"shadow_marsh":
			foliage = Color(0.15, 0.28, 0.08)
		"volcanic_depths":
			foliage = Color(0.70, 0.35, 0.05)
		"crystal_caverns":
			foliage = Color(0.40, 0.60, 0.85)
	draw_circle(img, 32, 32, 18 + variant * 2, foliage)
	draw_circle(img, 26, 28, 12, foliage.lightened(0.08))
	draw_circle(img, 38, 26, 10, foliage.darkened(0.08))
	# Levelek random pontok
	for i in range(20):
		var lx := rng.randi_range(14, 50)
		var ly := rng.randi_range(10, 48)
		_set_pixel_safe(img, lx, ly, foliage.lightened(rng.randf() * 0.15))
	return img

# --- Szikla ---
static func gen_rock(biome: String, size: int) -> Image:
	# size: 0=kicsi(32x32), 1=közepes(48x48), 2=nagy(64x64)
	var s := [32, 48, 64][clampi(size, 0, 2)]
	var img := Image.create(s, s, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var pal: Dictionary = PALETTES.get(biome, PALETTES["ashen_wastes"])
	var rock_col: Color = pal.get("wall", Color(0.35, 0.30, 0.28))
	var half := s / 2
	draw_ellipse(img, half, half + 2, half - 4, half - 6, rock_col)
	draw_ellipse(img, half - 2, half, half - 6, half - 8, rock_col.lightened(0.12))
	draw_shadow(img, Color(0, 0, 0, 0.2))
	return img

# --- Bokor ---
static func gen_bush(biome: String, variant: int) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var pal: Dictionary = PALETTES.get(biome, PALETTES["ashen_wastes"])
	var leaf_col: Color = pal.get("ground2", Color(0.18, 0.35, 0.10))
	match biome:
		"corrupted_forest": leaf_col = Color(0.25, 0.08, 0.30)
		"frozen_peaks": leaf_col = Color(0.60, 0.72, 0.82)
		"shadow_marsh": leaf_col = Color(0.12, 0.22, 0.06)
		"ashen_wastes": leaf_col = Color(0.30, 0.25, 0.20)
	draw_ellipse(img, 16, 18, 12, 10, leaf_col)
	draw_ellipse(img, 12, 16, 8, 8, leaf_col.lightened(0.1))
	draw_ellipse(img, 20, 14, 8, 8, leaf_col.darkened(0.06))
	var rng := RandomNumberGenerator.new()
	rng.seed = variant * 777
	for i in range(8):
		_set_pixel_safe(img, rng.randi_range(6, 26), rng.randi_range(8, 28), leaf_col.lightened(0.18))
	return img

# --- Virág ---
static func gen_flower(biome: String, variant: int) -> Image:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var colors := [Color(0.90, 0.20, 0.20), Color(0.90, 0.70, 0.10), Color(0.50, 0.20, 0.80), Color(0.90, 0.45, 0.70)]
	var col: Color = colors[variant % colors.size()]
	# Szár
	fill_rect(img, 7, 8, 2, 8, Color(0.15, 0.35, 0.08))
	# Szirmok
	_set_pixel_safe(img, 6, 6, col)
	_set_pixel_safe(img, 8, 6, col)
	_set_pixel_safe(img, 7, 5, col)
	_set_pixel_safe(img, 7, 7, col)
	_set_pixel_safe(img, 7, 6, Color(0.90, 0.85, 0.20))
	return img

# --- Fáklya (4 frame animált) ---
static func gen_torch(frame: int) -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(4):
		var img := Image.create(16, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		# Bot
		fill_rect(img, 6, 12, 4, 20, Color(0.30, 0.18, 0.06))
		# Láng
		var flicker := (f % 2) * 2
		fill_rect(img, 5, 6 - flicker, 6, 8, Color(1.0, 0.60, 0.10))
		fill_rect(img, 6, 4 - flicker, 4, 6, Color(1.0, 0.85, 0.20))
		_set_pixel_safe(img, 7, 2 - flicker, Color(1.0, 0.95, 0.50))
		_set_pixel_safe(img, 8, 3 - flicker, Color(1.0, 0.90, 0.40))
		frames.append(img)
	return frames

# --- Tábortűz (4 frame animált) ---
static func gen_campfire(frame: int) -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(4):
		var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		# Kövek kör
		draw_circle_outline(img, 16, 20, 8, Color(0.35, 0.30, 0.25))
		draw_circle_outline(img, 16, 20, 7, Color(0.28, 0.24, 0.20))
		# Fahasábok
		fill_rect(img, 10, 18, 12, 4, Color(0.30, 0.18, 0.06))
		fill_rect(img, 12, 16, 8, 4, Color(0.25, 0.14, 0.05))
		# Tűz
		var off := (f % 2) * 2
		draw_circle(img, 16, 14 - off, 5, Color(1.0, 0.55, 0.10))
		draw_circle(img, 16, 12 - off, 3, Color(1.0, 0.80, 0.20))
		_set_pixel_safe(img, 16, 8 - off, Color(1.0, 0.95, 0.50))
		# Szikrák
		_set_pixel_safe(img, 12 + f, 6, Color(1.0, 0.70, 0.20, 0.7))
		_set_pixel_safe(img, 20 - f, 8, Color(1.0, 0.60, 0.15, 0.6))
		frames.append(img)
	return frames

# --- Sírkő ---
static func gen_gravestone(variant: int) -> Image:
	var img := Image.create(32, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var stone_col := Color(0.40, 0.38, 0.36)
	match variant % 3:
		0:  # Egyszerű
			fill_rect(img, 8, 12, 16, 28, stone_col)
			fill_rect(img, 10, 10, 12, 4, stone_col)
		1:  # Kereszt
			fill_rect(img, 12, 8, 8, 32, stone_col)
			fill_rect(img, 6, 14, 20, 6, stone_col)
		2:  # Lekerekített
			fill_rect(img, 8, 18, 16, 22, stone_col)
			draw_circle(img, 16, 18, 8, stone_col)
	draw_shadow(img, Color(0, 0, 0, 0.15))
	return img

# --- Hordó ---
static func gen_barrel() -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var wood := Color(0.40, 0.25, 0.10)
	var band := Color(0.35, 0.32, 0.28)
	draw_ellipse(img, 16, 16, 12, 14, wood)
	draw_ellipse(img, 16, 16, 11, 13, wood.lightened(0.08))
	# Abroncsok
	fill_rect(img, 6, 8, 20, 2, band)
	fill_rect(img, 6, 22, 20, 2, band)
	return img

# --- Láda (loot nélkül, zárt) ---
static func gen_crate() -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var wood := Color(0.38, 0.24, 0.10)
	fill_rect(img, 4, 8, 24, 20, wood)
	fill_rect(img, 4, 8, 24, 2, wood.lightened(0.15))
	fill_rect(img, 4, 26, 24, 2, wood.darkened(0.1))
	fill_rect(img, 4, 8, 2, 20, wood.darkened(0.1))
	fill_rect(img, 26, 8, 2, 20, wood.darkened(0.15))
	return img

# --- Kristály oszlop (crystal/void biome) ---
static func gen_crystal_pillar(color: Color) -> Image:
	var img := Image.create(32, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	fill_rect(img, 10, 4, 12, 56, color)
	fill_rect(img, 12, 6, 8, 52, color.lightened(0.2))
	# Csúcs
	fill_rect(img, 12, 2, 8, 4, color.lightened(0.3))
	_set_pixel_safe(img, 15, 0, color.lightened(0.5))
	_set_pixel_safe(img, 16, 0, color.lightened(0.5))
	# Talp
	fill_rect(img, 8, 58, 16, 6, color.darkened(0.2))
	return img

# --- Fénygömb (dekoratív, animálható) ---
static func gen_light_orb(color: Color, frame: int) -> Image:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var pulse := 1.0 + sin(frame * PI / 2.0) * 0.15
	draw_circle(img, 8, 8, int(5 * pulse), Color(color.r, color.g, color.b, 0.3))
	draw_circle(img, 8, 8, 3, color)
	_set_pixel_safe(img, 7, 7, color.lightened(0.4))
	return img

static func export_all(base_path: String) -> void:
	var path := base_path + "props/world/"
	var biomes := ["ashen_wastes", "corrupted_forest", "crystal_caverns", "frozen_peaks", "shadow_marsh", "volcanic_depths", "necrotic_ruins", "void_realm"]
	for b in biomes:
		for v in range(3):
			save_png(gen_tree(b, v), path + "%s/tree_%d.png" % [b, v])
		for s in range(3):
			save_png(gen_rock(b, s), path + "%s/rock_%d.png" % [b, s])
		for v in range(2):
			save_png(gen_bush(b, v), path + "%s/bush_%d.png" % [b, v])
		for v in range(4):
			save_png(gen_flower(b, v), path + "%s/flower_%d.png" % [b, v])
	# Fáklya frames
	var torch_frames := gen_torch(0)
	for i in range(torch_frames.size()):
		save_png(torch_frames[i], path + "torch/torch_%d.png" % i)
	# Tábortűz frames
	var fire_frames := gen_campfire(0)
	for i in range(fire_frames.size()):
		save_png(fire_frames[i], path + "campfire/campfire_%d.png" % i)
	# Egyéb
	for v in range(3):
		save_png(gen_gravestone(v), path + "gravestone_%d.png" % v)
	save_png(gen_barrel(), path + "barrel.png")
	save_png(gen_crate(), path + "crate.png")
	save_png(gen_crystal_pillar(Color(0.40, 0.60, 0.90)), path + "crystal_pillar_blue.png")
	save_png(gen_crystal_pillar(Color(0.55, 0.20, 0.80)), path + "crystal_pillar_purple.png")
	for f in range(4):
		save_png(gen_light_orb(Color(0.40, 0.60, 1.0), f), path + "light_orb_blue_%d.png" % f)
		save_png(gen_light_orb(Color(0.60, 0.20, 0.80), f), path + "light_orb_purple_%d.png" % f)
	print("  ✓ World props exported to: ", path)

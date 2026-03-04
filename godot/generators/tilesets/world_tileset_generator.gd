## WorldTilesetGenerator - Világ tileset generátor (8 biome × ~47 tile = ~376 tile)
## 64×64 pixel, autotile support
class_name WorldTilesetGenerator
extends PixelArtBase

# ── Biome-specifikus paletta kibővítés ──
const BIOME_TILES := {
	"ashen_wastes": {
		"ground": Color(0.42, 0.40, 0.36), "ground2": Color(0.48, 0.44, 0.38),
		"wall": Color(0.30, 0.28, 0.25), "wall2": Color(0.25, 0.22, 0.20),
		"liquid": Color(0.80, 0.35, 0.05), "liquid2": Color(0.90, 0.50, 0.10),
		"accent": Color(0.60, 0.30, 0.05),
	},
	"corrupted_forest": {
		"ground": Color(0.18, 0.25, 0.10), "ground2": Color(0.22, 0.32, 0.14),
		"wall": Color(0.12, 0.18, 0.06), "wall2": Color(0.08, 0.14, 0.04),
		"liquid": Color(0.15, 0.40, 0.08), "liquid2": Color(0.20, 0.50, 0.12),
		"accent": Color(0.40, 0.12, 0.50),
	},
	"crystal_caverns": {
		"ground": Color(0.22, 0.28, 0.38), "ground2": Color(0.28, 0.34, 0.44),
		"wall": Color(0.15, 0.20, 0.32), "wall2": Color(0.10, 0.15, 0.28),
		"liquid": Color(0.30, 0.55, 0.85), "liquid2": Color(0.45, 0.70, 0.95),
		"accent": Color(0.70, 0.85, 1.00),
	},
	"frozen_peaks": {
		"ground": Color(0.82, 0.85, 0.90), "ground2": Color(0.88, 0.90, 0.94),
		"wall": Color(0.65, 0.70, 0.78), "wall2": Color(0.55, 0.60, 0.68),
		"liquid": Color(0.50, 0.70, 0.90), "liquid2": Color(0.60, 0.80, 0.95),
		"accent": Color(0.40, 0.65, 0.90),
	},
	"shadow_marsh": {
		"ground": Color(0.18, 0.22, 0.12), "ground2": Color(0.22, 0.28, 0.16),
		"wall": Color(0.12, 0.16, 0.08), "wall2": Color(0.08, 0.12, 0.06),
		"liquid": Color(0.20, 0.35, 0.12), "liquid2": Color(0.25, 0.42, 0.18),
		"accent": Color(0.45, 0.55, 0.15),
	},
	"volcanic_depths": {
		"ground": Color(0.20, 0.12, 0.08), "ground2": Color(0.28, 0.16, 0.10),
		"wall": Color(0.12, 0.08, 0.06), "wall2": Color(0.08, 0.05, 0.04),
		"liquid": Color(0.90, 0.35, 0.05), "liquid2": Color(1.00, 0.55, 0.10),
		"accent": Color(1.00, 0.40, 0.05),
	},
	"necrotic_ruins": {
		"ground": Color(0.30, 0.28, 0.22), "ground2": Color(0.36, 0.32, 0.26),
		"wall": Color(0.22, 0.20, 0.16), "wall2": Color(0.16, 0.14, 0.12),
		"liquid": Color(0.25, 0.50, 0.15), "liquid2": Color(0.35, 0.60, 0.20),
		"accent": Color(0.50, 0.18, 0.60),
	},
	"void_realm": {
		"ground": Color(0.10, 0.06, 0.18), "ground2": Color(0.14, 0.08, 0.24),
		"wall": Color(0.06, 0.03, 0.12), "wall2": Color(0.04, 0.02, 0.08),
		"liquid": Color(0.40, 0.15, 0.70), "liquid2": Color(0.55, 0.25, 0.85),
		"accent": Color(0.70, 0.30, 0.95),
	},
}

## Talaj tile (4 variáns foltokkal)
static func gen_ground_tile(biome: String, variant: int) -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var pal: Dictionary = BIOME_TILES[biome]
	img.fill(pal["ground"])
	var rng := RandomNumberGenerator.new()
	rng.seed = variant * 12345 + biome.hash()
	for i in range(40):
		var tx := rng.randi_range(2, 58)
		var ty := rng.randi_range(2, 58)
		var ts := rng.randi_range(2, 6)
		fill_rect(img, tx, ty, ts, ts, pal["ground"].lerp(pal["ground2"], rng.randf()))
	return img

## Fal/szikla tile (4 variáns + kő textúra)
static func gen_wall_tile(biome: String, variant: int) -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var pal: Dictionary = BIOME_TILES[biome]
	img.fill(pal["wall"])
	draw_stone_texture(img, pal["wall2"])
	var rng := RandomNumberGenerator.new()
	rng.seed = variant * 54321 + biome.hash()
	for i in range(8):
		var tx := rng.randi_range(4, 56)
		var ty := rng.randi_range(4, 56)
		_set_pixel_safe(img, tx, ty, pal["wall"].lightened(0.15))
	return img

## Víz/folyadék tile (4 frame, animált)
static func gen_liquid_tile(biome: String, frame_idx: int) -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var pal: Dictionary = BIOME_TILES[biome]
	img.fill(pal["liquid"])
	# Hullám mintázat
	var wave_offset := frame_idx * 4
	for row in range(0, 64, 8):
		for col in range(64):
			var wave := sin((col + wave_offset + row) * 0.2) * 0.15
			var c: Color = pal["liquid"].lerp(pal["liquid2"], 0.5 + wave)
			_set_pixel_safe(img, col, row, c)
			_set_pixel_safe(img, col, row + 1, c)
	# Csillanás
	var rng := RandomNumberGenerator.new()
	rng.seed = frame_idx * 777
	for i in range(6):
		var sx := rng.randi_range(4, 58)
		var sy := rng.randi_range(4, 58)
		_set_pixel_safe(img, sx, sy, Color.WHITE)
	return img

## Szegély tile (autotile - 16 blob részhalmaz leegyszerűsítve)
## edge_mask: 4 bit (felső, jobb, alsó, bal szomszéd ground-e)
static func gen_border_tile(biome: String, edge_mask: int) -> Image:
	var img := gen_ground_tile(biome, edge_mask + 100)
	var pal: Dictionary = BIOME_TILES[biome]
	var border_col: Color = pal["wall"]
	# 4 irány szegély
	if edge_mask & 1:  # Felső szomszéd fal
		fill_rect(img, 0, 0, 64, 8, border_col)
	if edge_mask & 2:  # Jobb szomszéd fal
		fill_rect(img, 56, 0, 8, 64, border_col)
	if edge_mask & 4:  # Alsó szomszéd fal
		fill_rect(img, 0, 56, 64, 8, border_col)
	if edge_mask & 8:  # Bal szomszéd fal
		fill_rect(img, 0, 0, 8, 64, border_col)
	return img

## Átmeneti tile (biome-to-biome)
static func gen_transition_tile(biome_a: String, biome_b: String, direction: int) -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var pal_a: Dictionary = BIOME_TILES[biome_a]
	var pal_b: Dictionary = BIOME_TILES[biome_b]
	# Gradiens átmenet
	for x in range(64):
		for y in range(64):
			var t := 0.0
			match direction:
				0: t = float(y) / 64.0  # N→S
				1: t = float(x) / 64.0  # W→E
				2: t = 1.0 - float(y) / 64.0  # S→N
				3: t = 1.0 - float(x) / 64.0  # E→W
			var c: Color = pal_a["ground"].lerp(pal_b["ground"], t)
			_set_pixel_safe(img, x, y, c)
	return img

## Biome-specifikus extra tile
static func gen_biome_special(biome: String, variant: int) -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var pal: Dictionary = BIOME_TILES[biome]
	img.fill(pal["ground"])
	var rng := RandomNumberGenerator.new()
	rng.seed = variant * 99999 + biome.hash()
	match biome:
		"ashen_wastes":
			# Hamu kupac
			for i in range(12):
				var cx := rng.randi_range(8, 56)
				var cy := rng.randi_range(8, 56)
				draw_circle(img, cx, cy, rng.randi_range(3, 8), Color(0.55, 0.52, 0.48))
		"corrupted_forest":
			# Gomba folt
			for i in range(5):
				var mx := rng.randi_range(10, 54)
				var my := rng.randi_range(10, 54)
				draw_circle(img, mx, my, 4, Color(0.45, 0.30, 0.18))
				fill_rect(img, mx - 1, my + 3, 2, 4, Color(0.35, 0.25, 0.12))
		"crystal_caverns":
			# Kristályfolt
			for i in range(6):
				var cx := rng.randi_range(8, 56)
				var cy := rng.randi_range(8, 56)
				fill_rect(img, cx, cy, 4, 8, pal["accent"])
				_set_pixel_safe(img, cx + 1, cy, Color.WHITE)
		"frozen_peaks":
			# Jégcsap mintázat
			for i in range(8):
				var cx := rng.randi_range(6, 58)
				var cy := rng.randi_range(6, 58)
				fill_rect(img, cx, cy, 2, rng.randi_range(4, 10), Color(0.80, 0.90, 1.00))
		"shadow_marsh":
			# Iszap tócsa
			draw_ellipse(img, 32, 32, rng.randi_range(10, 20), rng.randi_range(8, 14), Color(0.22, 0.18, 0.10))
		"volcanic_depths":
			# Láva repedés
			for i in range(4):
				var x1 := rng.randi_range(4, 60)
				var y1 := rng.randi_range(4, 60)
				var x2 := rng.randi_range(4, 60)
				var y2 := rng.randi_range(4, 60)
				draw_line_px(img, x1, y1, x2, y2, pal["accent"])
		"necrotic_ruins":
			# Csontdarabok
			for i in range(6):
				var bx := rng.randi_range(8, 56)
				var by := rng.randi_range(8, 56)
				fill_rect(img, bx, by, rng.randi_range(3, 8), 2, Color(0.78, 0.74, 0.65))
		"void_realm":
			# Void rés
			draw_circle(img, 32, 32, rng.randi_range(6, 14), Color(pal["accent"].r, pal["accent"].g, pal["accent"].b, 0.3))
			draw_circle(img, 32, 32, 3, Color(0.90, 0.85, 1.00, 0.5))
	return img

static func get_biome_names() -> Array:
	return BIOME_TILES.keys()

static func export_all(base_path: String) -> void:
	var path := base_path + "tilesets/world/"
	for biome in get_biome_names():
		# 4 talaj variáns
		for v in range(4):
			save_png(gen_ground_tile(biome, v), path + "%s/ground_%d.png" % [biome, v])
		# 4 fal variáns
		for v in range(4):
			save_png(gen_wall_tile(biome, v), path + "%s/wall_%d.png" % [biome, v])
		# 4 frame folyadék
		for f in range(4):
			save_png(gen_liquid_tile(biome, f), path + "%s/liquid_%d.png" % [biome, f])
		# 16 szegély
		for mask in range(16):
			save_png(gen_border_tile(biome, mask), path + "%s/border_%d.png" % [biome, mask])
		# 4 extra
		for v in range(4):
			save_png(gen_biome_special(biome, v), path + "%s/special_%d.png" % [biome, v])
	# Átmeneti tile-ok (biome párok fő szomszédok)
	var transitions := [
		["ashen_wastes", "corrupted_forest"],
		["corrupted_forest", "crystal_caverns"],
		["crystal_caverns", "frozen_peaks"],
		["frozen_peaks", "shadow_marsh"],
		["shadow_marsh", "volcanic_depths"],
		["volcanic_depths", "necrotic_ruins"],
		["necrotic_ruins", "void_realm"],
	]
	for pair in transitions:
		for dir in range(4):
			save_png(gen_transition_tile(pair[0], pair[1], dir), path + "transitions/%s_to_%s_dir%d.png" % [pair[0], pair[1], dir])
	print("  ✓ World tilesets exported to: ", path)

## DungeonTilesetGenerator - Dungeon tileset generátor (7 téma × ~46 tile = ~322 tile)
## 64×64 pixel
class_name DungeonTilesetGenerator
extends PixelArtBase

const DUNGEON_THEMES := {
	"witch_hollow": {
		"floor": Color(0.14, 0.12, 0.10), "floor2": Color(0.18, 0.15, 0.12),
		"wall": Color(0.08, 0.06, 0.04), "wall2": Color(0.18, 0.14, 0.10),
		"moss": Color(0.10, 0.22, 0.06), "accent": Color(0.40, 0.15, 0.50),
		"door": Color(0.35, 0.22, 0.10), "trap": Color(0.50, 0.12, 0.08),
	},
	"crystal_depths": {
		"floor": Color(0.16, 0.20, 0.30), "floor2": Color(0.20, 0.26, 0.36),
		"wall": Color(0.10, 0.14, 0.24), "wall2": Color(0.14, 0.18, 0.30),
		"moss": Color(0.25, 0.45, 0.70), "accent": Color(0.60, 0.80, 1.00),
		"door": Color(0.30, 0.40, 0.55), "trap": Color(0.40, 0.60, 0.90),
	},
	"frozen_tomb": {
		"floor": Color(0.60, 0.65, 0.72), "floor2": Color(0.68, 0.72, 0.78),
		"wall": Color(0.45, 0.50, 0.58), "wall2": Color(0.52, 0.58, 0.65),
		"moss": Color(0.70, 0.82, 0.95), "accent": Color(0.40, 0.65, 0.90),
		"door": Color(0.55, 0.60, 0.68), "trap": Color(0.50, 0.70, 0.90),
	},
	"obsidian_forge": {
		"floor": Color(0.10, 0.06, 0.04), "floor2": Color(0.14, 0.08, 0.06),
		"wall": Color(0.06, 0.04, 0.03), "wall2": Color(0.12, 0.06, 0.04),
		"moss": Color(0.00, 0.00, 0.00), "accent": Color(0.90, 0.40, 0.05),
		"door": Color(0.25, 0.12, 0.05), "trap": Color(0.80, 0.30, 0.05),
	},
	"bone_catacombs": {
		"floor": Color(0.25, 0.22, 0.18), "floor2": Color(0.30, 0.26, 0.20),
		"wall": Color(0.18, 0.16, 0.12), "wall2": Color(0.22, 0.19, 0.15),
		"moss": Color(0.15, 0.25, 0.08), "accent": Color(0.72, 0.68, 0.55),
		"door": Color(0.35, 0.28, 0.18), "trap": Color(0.55, 0.20, 0.10),
	},
	"void_nexus": {
		"floor": Color(0.08, 0.04, 0.14), "floor2": Color(0.12, 0.06, 0.20),
		"wall": Color(0.04, 0.02, 0.08), "wall2": Color(0.08, 0.04, 0.14),
		"moss": Color(0.00, 0.00, 0.00), "accent": Color(0.55, 0.20, 0.80),
		"door": Color(0.15, 0.08, 0.25), "trap": Color(0.50, 0.15, 0.70),
	},
	"shadow_labyrinth": {
		"floor": Color(0.12, 0.10, 0.10), "floor2": Color(0.16, 0.14, 0.14),
		"wall": Color(0.06, 0.05, 0.05), "wall2": Color(0.10, 0.08, 0.08),
		"moss": Color(0.00, 0.00, 0.00), "accent": Color(0.30, 0.10, 0.10),
		"door": Color(0.20, 0.15, 0.15), "trap": Color(0.45, 0.10, 0.10),
	},
}

## Padló (8 variáns)
static func gen_floor_tile(theme: String, variant: int) -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var pal: Dictionary = DUNGEON_THEMES[theme]
	img.fill(pal["floor"])
	var rng := RandomNumberGenerator.new()
	rng.seed = variant * 11111 + theme.hash()
	# Kő padló kockatextúra
	for gx in range(0, 64, 16):
		for gy in range(0, 64, 16):
			var offset := rng.randi_range(-1, 1)
			fill_rect(img, gx, gy, 15, 15, pal["floor"].lerp(pal["floor2"], rng.randf()))
			# Fuga vonal
			fill_rect(img, gx + 15, gy, 1, 16, pal["floor"].darkened(0.2))
			fill_rect(img, gx, gy + 15, 16, 1, pal["floor"].darkened(0.2))
	# Random foltok
	for i in range(10):
		_set_pixel_safe(img, rng.randi_range(2, 62), rng.randi_range(2, 62), pal["floor2"])
	return img

## Fal (edge_mask autotile)
static func gen_wall_tile(theme: String, edge_mask: int) -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var pal: Dictionary = DUNGEON_THEMES[theme]
	img.fill(pal["wall"])
	draw_stone_texture(img, pal["wall2"])
	# Moha ha van
	if pal["moss"] != Color.BLACK:
		draw_moss_patches(img, pal["moss"])
	# Szegélyek
	if edge_mask & 1: fill_rect(img, 0, 0, 64, 2, pal["wall"].darkened(0.3))
	if edge_mask & 2: fill_rect(img, 62, 0, 2, 64, pal["wall"].darkened(0.3))
	if edge_mask & 4: fill_rect(img, 0, 62, 64, 2, pal["wall"].darkened(0.3))
	if edge_mask & 8: fill_rect(img, 0, 0, 2, 64, pal["wall"].darkened(0.3))
	return img

## Ajtó keret (6 state: closed, open, locked × 2 irány)
static func gen_door_tile(theme: String, state: String, horizontal: bool) -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var pal: Dictionary = DUNGEON_THEMES[theme]
	img.fill(Color(0, 0, 0, 0))
	if horizontal:
		# Fal két szélén
		fill_rect(img, 0, 0, 64, 12, pal["wall"])
		fill_rect(img, 0, 52, 64, 12, pal["wall"])
		if state == "closed" or state == "locked":
			fill_rect(img, 8, 12, 48, 40, pal["door"])
			if state == "locked":
				fill_rect(img, 28, 28, 8, 8, Color(0.75, 0.65, 0.20))
		# Open: üres közép
	else:
		fill_rect(img, 0, 0, 12, 64, pal["wall"])
		fill_rect(img, 52, 0, 12, 64, pal["wall"])
		if state == "closed" or state == "locked":
			fill_rect(img, 12, 8, 40, 48, pal["door"])
			if state == "locked":
				fill_rect(img, 28, 28, 8, 8, Color(0.75, 0.65, 0.20))
	draw_outline(img, Color.BLACK)
	return img

## Lépcső (2 irány: up, down)
static func gen_stairs_tile(theme: String, going_up: bool) -> Image:
	var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	var pal: Dictionary = DUNGEON_THEMES[theme]
	img.fill(pal["floor"])
	var step_count := 6
	for i in range(step_count):
		var y_pos := i * 10 if going_up else (step_count - 1 - i) * 10
		var shade := pal["floor"].lerp(pal["floor2"], float(i) / step_count)
		fill_rect(img, 8, y_pos + 2, 48, 9, shade)
		fill_rect(img, 8, y_pos + 2, 48, 2, shade.lightened(0.15))
	draw_outline(img, Color.BLACK)
	return img

## Csapda tile
static func gen_trap_tile(theme: String, trap_type: String) -> Image:
	var img := gen_floor_tile(theme, 99)
	var pal: Dictionary = DUNGEON_THEMES[theme]
	match trap_type:
		"spike":
			for sx in range(12, 52, 10):
				for sy in range(12, 52, 10):
					fill_rect(img, sx, sy, 4, 8, pal["trap"])
					_set_pixel_safe(img, sx + 1, sy, pal["trap"].lightened(0.3))
		"fire":
			draw_circle(img, 32, 32, 12, Color(pal["trap"].r, pal["trap"].g, pal["trap"].b, 0.3))
			for i in range(4):
				_set_pixel_safe(img, 28 + i * 4, 28, Color(1.0, 0.60, 0.10))
		"arrow":
			# Kis lyukak a falban
			for i in range(3):
				fill_rect(img, 2, 14 + i * 16, 6, 4, Color(0.02, 0.02, 0.02))
		"pressure":
			# Nyomólap
			fill_rect(img, 16, 16, 32, 32, pal["floor"].darkened(0.1))
			draw_outline(img, pal["floor"].darkened(0.2))
	return img

## Dekoratív tile
static func gen_decoration_tile(theme: String, deco_type: int) -> Image:
	var img := gen_floor_tile(theme, deco_type + 200)
	var pal: Dictionary = DUNGEON_THEMES[theme]
	match deco_type % 4:
		0:  # Repedés
			draw_line_px(img, 10, 20, 40, 50, pal["wall"].darkened(0.3))
			draw_line_px(img, 30, 10, 50, 40, pal["wall"].darkened(0.3))
		1:  # Rúnák
			draw_circle_outline(img, 32, 32, 14, pal["accent"])
			draw_circle_outline(img, 32, 32, 8, pal["accent"])
		2:  # Folt
			draw_circle(img, 28, 34, 10, pal["floor2"].darkened(0.15))
		3:  # Kövek
			fill_rect(img, 8, 12, 12, 8, pal["wall2"])
			fill_rect(img, 40, 36, 16, 10, pal["wall2"])
			fill_rect(img, 22, 48, 10, 8, pal["wall2"])
	return img

static func get_theme_names() -> Array:
	return DUNGEON_THEMES.keys()

static func export_all(base_path: String) -> void:
	var path := base_path + "tilesets/dungeon/"
	for theme in get_theme_names():
		# 8 padló
		for v in range(8):
			save_png(gen_floor_tile(theme, v), path + "%s/floor_%d.png" % [theme, v])
		# 16 fal
		for mask in range(16):
			save_png(gen_wall_tile(theme, mask), path + "%s/wall_%d.png" % [theme, mask])
		# 6 ajtó
		for state in ["closed", "open", "locked"]:
			save_png(gen_door_tile(theme, state, true), path + "%s/door_%s_h.png" % [theme, state])
			save_png(gen_door_tile(theme, state, false), path + "%s/door_%s_v.png" % [theme, state])
		# 2 lépcső
		save_png(gen_stairs_tile(theme, true), path + "%s/stairs_up.png" % theme)
		save_png(gen_stairs_tile(theme, false), path + "%s/stairs_down.png" % theme)
		# 4 csapda
		for trap in ["spike", "fire", "arrow", "pressure"]:
			save_png(gen_trap_tile(theme, trap), path + "%s/trap_%s.png" % [theme, trap])
		# 8 dekoráció
		for d in range(8):
			save_png(gen_decoration_tile(theme, d), path + "%s/deco_%d.png" % [theme, d])
	print("  ✓ Dungeon tilesets exported to: ", path)

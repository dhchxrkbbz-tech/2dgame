## DungeonPropsGenerator - Dungeon propok (~55 sprite)
## Ládák (4 rarity × 2 state), csapdák, fáklyák, ajtók, portál, mimic
class_name DungeonPropsGenerator
extends PixelArtBase

const RARITY := {
	"common": Color(0.60, 0.55, 0.45),
	"uncommon": Color(0.20, 0.65, 0.20),
	"rare": Color(0.25, 0.45, 0.85),
	"legendary": Color(0.85, 0.60, 0.10),
}

# --- Láda (rarity × state: closed/open) ---
static func gen_chest(rarity: String, is_open: bool) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var base := Color(0.35, 0.22, 0.08)
	var accent: Color = RARITY.get(rarity, RARITY["common"])
	if is_open:
		# Alsó rész
		fill_rect(img, 4, 16, 24, 14, base)
		fill_rect(img, 6, 18, 20, 10, base.lightened(0.1))
		# Fedél hátra
		fill_rect(img, 4, 8, 24, 10, base)
		fill_rect(img, 6, 10, 20, 6, base.lightened(0.05))
		# Ragyogás belül
		fill_rect(img, 8, 16, 16, 6, accent.lightened(0.3))
	else:
		fill_rect(img, 4, 10, 24, 20, base)
		fill_rect(img, 6, 12, 20, 16, base.lightened(0.08))
		# Fedél vonal
		fill_rect(img, 4, 10, 24, 4, base.darkened(0.1))
	# Rarity díszítés
	fill_rect(img, 14, 14, 4, 4, accent)
	# Csatok
	fill_rect(img, 4, 18, 2, 6, Color(0.35, 0.32, 0.28))
	fill_rect(img, 26, 18, 2, 6, Color(0.35, 0.32, 0.28))
	draw_outline(img, Color.BLACK)
	return img

# --- Mimic (zárt + támad animáció) ---
static func gen_mimic(state: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var base := Color(0.35, 0.22, 0.08)
	if state == "disguised":
		# Úgy néz ki mint egy láda
		fill_rect(img, 4, 10, 24, 20, base)
		fill_rect(img, 6, 12, 20, 16, base.lightened(0.08))
		fill_rect(img, 14, 14, 4, 4, RARITY["rare"])
		fill_rect(img, 4, 10, 24, 4, base.darkened(0.1))
	else:
		# Nyitott száj, fogak
		fill_rect(img, 4, 16, 24, 14, base)
		fill_rect(img, 6, 18, 20, 10, Color(0.50, 0.08, 0.08))
		# Fogak felső
		for fx in range(6, 26, 4):
			fill_rect(img, fx, 16, 2, 4, Color(0.90, 0.88, 0.80))
		# Fogak alsó
		for fx in range(8, 24, 4):
			fill_rect(img, fx, 26, 2, 4, Color(0.90, 0.88, 0.80))
		# Szemek
		fill_rect(img, 10, 10, 4, 4, Color(1.0, 0.20, 0.10))
		fill_rect(img, 18, 10, 4, 4, Color(1.0, 0.20, 0.10))
		# Fedél mint homlok
		fill_rect(img, 4, 6, 24, 10, base)
		# Nyelv
		fill_rect(img, 14, 22, 4, 6, Color(0.70, 0.15, 0.15))
	draw_outline(img, Color.BLACK)
	return img

# --- Dungeon fáklya (falra, 4 frame) ---
static func gen_wall_torch_frames() -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(4):
		var img := Image.create(16, 32, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		# Tartó
		fill_rect(img, 4, 16, 8, 4, Color(0.32, 0.28, 0.24))
		# Bot
		fill_rect(img, 6, 8, 4, 12, Color(0.28, 0.16, 0.06))
		# Láng
		var flick := f % 2
		fill_rect(img, 5, 4 - flick, 6, 6, Color(1.0, 0.55, 0.10))
		fill_rect(img, 6, 2 - flick, 4, 4, Color(1.0, 0.80, 0.20))
		_set_pixel_safe(img, 7, 1 - flick, Color(1.0, 0.95, 0.50))
		frames.append(img)
	return frames

# --- Portál (4 frame animált) ---
static func gen_portal_frames(color: Color) -> Array[Image]:
	var frames: Array[Image] = []
	for f in range(4):
		var img := Image.create(48, 64, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		# Kő keret
		var stone := Color(0.30, 0.28, 0.24)
		fill_rect(img, 4, 4, 8, 56, stone)
		fill_rect(img, 36, 4, 8, 56, stone)
		fill_rect(img, 4, 4, 40, 8, stone)
		# Portál felület (animált)
		var pulse := 0.7 + sin(f * PI / 2.0) * 0.15
		var portal_col := Color(color.r, color.g, color.b, pulse)
		fill_rect(img, 12, 12, 24, 44, portal_col)
		# Örvény pontok
		var rng := RandomNumberGenerator.new()
		rng.seed = f * 444
		for i in range(8):
			var px := rng.randi_range(14, 34)
			var py := rng.randi_range(14, 54)
			_set_pixel_safe(img, px, py, Color(color.r, color.g, color.b, 0.9))
		draw_circle_outline(img, 24, 34, 8 + f, Color(color.r, color.g, color.b, 0.5))
		draw_outline(img, Color.BLACK)
		frames.append(img)
	return frames

# --- Dungeon ajtó (vasajtó, 3 state) ---
static func gen_iron_door(state: String) -> Image:
	var img := Image.create(48, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var iron := Color(0.30, 0.30, 0.32)
	var stone := Color(0.25, 0.22, 0.18)
	# Kő keret
	fill_rect(img, 0, 0, 8, 64, stone)
	fill_rect(img, 40, 0, 8, 64, stone)
	fill_rect(img, 0, 0, 48, 8, stone)
	if state == "open":
		# Üres
		pass
	elif state == "locked":
		fill_rect(img, 8, 8, 32, 56, iron)
		fill_rect(img, 10, 10, 28, 52, iron.lightened(0.06))
		fill_rect(img, 20, 30, 8, 8, Color(0.75, 0.65, 0.20))  # Lakat
		# Szegecskék
		for ry in range(14, 56, 12):
			_set_pixel_safe(img, 12, ry, Color(0.50, 0.48, 0.44))
			_set_pixel_safe(img, 35, ry, Color(0.50, 0.48, 0.44))
	else:  # closed
		fill_rect(img, 8, 8, 32, 56, iron)
		fill_rect(img, 10, 10, 28, 52, iron.lightened(0.06))
		for ry in range(14, 56, 12):
			_set_pixel_safe(img, 12, ry, Color(0.50, 0.48, 0.44))
			_set_pixel_safe(img, 35, ry, Color(0.50, 0.48, 0.44))
	draw_outline(img, Color.BLACK)
	return img

# --- Csontrakás ---
static func gen_bone_pile() -> Image:
	var img := Image.create(32, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var bone := Color(0.82, 0.78, 0.68)
	# Random csontok
	fill_rect(img, 4, 14, 24, 4, bone.darkened(0.1))
	fill_rect(img, 8, 10, 16, 4, bone)
	fill_rect(img, 6, 8, 4, 10, bone)
	fill_rect(img, 20, 6, 4, 12, bone)
	# Koponya
	draw_circle(img, 16, 8, 4, bone.lightened(0.08))
	_set_pixel_safe(img, 14, 7, Color(0.05, 0.05, 0.05))
	_set_pixel_safe(img, 17, 7, Color(0.05, 0.05, 0.05))
	return img

# --- Pókháló ---
static func gen_cobweb() -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var web := Color(0.85, 0.82, 0.78, 0.5)
	draw_line_px(img, 0, 0, 30, 30, web)
	draw_line_px(img, 0, 0, 30, 16, web)
	draw_line_px(img, 0, 0, 16, 30, web)
	# Kereszt szálak
	draw_line_px(img, 4, 8, 16, 4, web)
	draw_line_px(img, 8, 4, 4, 16, web)
	draw_line_px(img, 8, 16, 24, 12, web)
	draw_line_px(img, 16, 8, 12, 24, web)
	return img

# --- Tüskés rács padló csapda ---
static func gen_spike_trap(active: bool) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var floor_col := Color(0.18, 0.15, 0.12)
	img.fill(floor_col)
	if active:
		for sx in range(4, 28, 6):
			for sy in range(4, 28, 6):
				fill_rect(img, sx, sy, 2, 6, Color(0.45, 0.42, 0.38))
				_set_pixel_safe(img, sx, sy, Color(0.55, 0.50, 0.45))
	else:
		# Rés a padlóban
		for sx in range(4, 28, 6):
			for sy in range(6, 28, 6):
				_set_pixel_safe(img, sx, sy, Color(0.06, 0.04, 0.04))
				_set_pixel_safe(img, sx + 1, sy, Color(0.06, 0.04, 0.04))
	return img

# --- Kincshalom ---
static func gen_treasure_pile() -> Image:
	var img := Image.create(48, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var gold := Color(0.85, 0.70, 0.15)
	# Halom
	draw_ellipse(img, 24, 20, 18, 10, gold.darkened(0.15))
	draw_ellipse(img, 24, 18, 14, 8, gold)
	# Érmék
	var rng := RandomNumberGenerator.new()
	rng.seed = 12345
	for i in range(12):
		var cx := rng.randi_range(10, 38)
		var cy := rng.randi_range(12, 28)
		_set_pixel_safe(img, cx, cy, gold.lightened(0.2))
	# Drágakő
	fill_rect(img, 20, 14, 4, 4, Color(0.20, 0.50, 0.85))
	fill_rect(img, 28, 16, 3, 3, Color(0.85, 0.15, 0.15))
	return img

static func get_anim_config() -> Dictionary:
	return {
		"torch": {"frames": 4, "fps": 8, "loop": true},
		"portal": {"frames": 4, "fps": 6, "loop": true},
		"mimic_attack": {"frames": 4, "fps": 8, "loop": false},
	}

static func export_all(base_path: String) -> void:
	var path := base_path + "props/dungeon/"
	# Ládák
	for rarity in RARITY.keys():
		save_png(gen_chest(rarity, false), path + "chest_%s_closed.png" % rarity)
		save_png(gen_chest(rarity, true), path + "chest_%s_open.png" % rarity)
	# Mimic
	save_png(gen_mimic("disguised"), path + "mimic_disguised.png")
	save_png(gen_mimic("revealed"), path + "mimic_revealed.png")
	# Fáklya
	var torch := gen_wall_torch_frames()
	for i in range(torch.size()):
		save_png(torch[i], path + "wall_torch_%d.png" % i)
	# Portálok
	var colors := {"blue": Color(0.30, 0.50, 0.90), "purple": Color(0.55, 0.20, 0.80), "green": Color(0.15, 0.60, 0.25)}
	for col_name in colors.keys():
		var portal := gen_portal_frames(colors[col_name])
		for i in range(portal.size()):
			save_png(portal[i], path + "portal_%s_%d.png" % [col_name, i])
	# Ajtók
	for state in ["closed", "open", "locked"]:
		save_png(gen_iron_door(state), path + "iron_door_%s.png" % state)
	# Vegyes
	save_png(gen_bone_pile(), path + "bone_pile.png")
	save_png(gen_cobweb(), path + "cobweb.png")
	save_png(gen_spike_trap(false), path + "spike_trap_off.png")
	save_png(gen_spike_trap(true), path + "spike_trap_on.png")
	save_png(gen_treasure_pile(), path + "treasure_pile.png")
	print("  ✓ Dungeon props exported to: ", path)

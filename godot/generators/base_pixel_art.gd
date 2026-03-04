## PixelArtBase - Közös helper függvények minden sprite generátorhoz
## Ashenfall Visual Art Pipeline - Plan 19
## Minden generator ezt az osztályt örökli/használja
class_name PixelArtBase

# ═══════════════════════════════════════════════════════════════
# BIOME PALETTÁK
# ═══════════════════════════════════════════════════════════════

const PALETTES = {
	"ashen_wastes": {
		"ground":  Color(0.45, 0.42, 0.38),
		"ground2": Color(0.55, 0.50, 0.44),
		"accent":  Color(0.80, 0.40, 0.10),
		"dark":    Color(0.18, 0.15, 0.12),
		"outline": Color(0.05, 0.04, 0.03),
	},
	"corrupted_forest": {
		"ground":  Color(0.12, 0.22, 0.10),
		"accent":  Color(0.50, 0.10, 0.60),
		"dark":    Color(0.06, 0.10, 0.05),
		"poison":  Color(0.25, 0.60, 0.10),
		"outline": Color(0.02, 0.05, 0.02),
	},
	"crystal_caverns": {
		"crystal": Color(0.30, 0.60, 0.90),
		"glow":    Color(0.70, 0.90, 1.00),
		"dark":    Color(0.05, 0.10, 0.20),
		"outline": Color(0.02, 0.04, 0.08),
	},
	"frozen_peaks": {
		"snow":    Color(0.90, 0.92, 0.95),
		"ice":     Color(0.60, 0.80, 0.95),
		"dark":    Color(0.10, 0.15, 0.25),
		"outline": Color(0.04, 0.06, 0.10),
	},
	"shadow_marsh": {
		"ground":  Color(0.15, 0.20, 0.08),
		"water":   Color(0.20, 0.28, 0.12),
		"accent":  Color(0.55, 0.50, 0.15),
		"outline": Color(0.04, 0.06, 0.02),
	},
	"volcanic_depths": {
		"rock":    Color(0.15, 0.10, 0.08),
		"lava":    Color(0.90, 0.35, 0.05),
		"glow":    Color(1.00, 0.60, 0.10),
		"outline": Color(0.05, 0.03, 0.02),
	},
	"necrotic_ruins": {
		"bone":    Color(0.88, 0.84, 0.72),
		"stone":   Color(0.35, 0.30, 0.28),
		"accent":  Color(0.40, 0.10, 0.50),
		"outline": Color(0.08, 0.06, 0.05),
	},
	"void_realm": {
		"void":    Color(0.10, 0.05, 0.18),
		"energy":  Color(0.60, 0.20, 0.90),
		"glow":    Color(0.85, 0.50, 1.00),
		"outline": Color(0.04, 0.02, 0.08),
	},
}

# ═══════════════════════════════════════════════════════════════
# RITKASÁG SZÍNEK
# ═══════════════════════════════════════════════════════════════

const RARITY_COLORS = {
	"normal":    Color(0.69, 0.69, 0.69),
	"magic":     Color(0.27, 0.53, 1.00),
	"rare":      Color(1.00, 0.85, 0.00),
	"epic":      Color(0.67, 0.27, 1.00),
	"legendary": Color(1.00, 0.53, 0.00),
	"set":       Color(0.27, 0.80, 0.27),
}

# ═══════════════════════════════════════════════════════════════
# CLASS SZÍNEK
# ═══════════════════════════════════════════════════════════════

const CLASS_COLORS = {
	"assassin": {
		"primary":   Color(0.18, 0.07, 0.28),  # sötétlila
		"secondary": Color(0.08, 0.04, 0.12),  # fekete
		"accent":    Color(0.42, 0.08, 0.21),  # bíbor
	},
	"tank": {
		"primary":   Color(0.35, 0.41, 0.47),  # acélszürke
		"secondary": Color(0.78, 0.57, 0.16),  # aranybarna
		"accent":    Color(0.10, 0.17, 0.29),  # sötétkék
	},
	"mage": {
		"primary":   Color(0.06, 0.12, 0.35),  # sötétkék
		"secondary": Color(0.29, 0.07, 0.50),  # lila
		"accent":    Color(0.91, 0.91, 0.94),  # fehér
	},
}

# ═══════════════════════════════════════════════════════════════
# RAJZOLÓ HELPER FÜGGVÉNYEK
# ═══════════════════════════════════════════════════════════════

## Téglalap kitöltés (boundary-checked)
static func fill_rect(img: Image, x: int, y: int, w: int, h: int, col: Color) -> void:
	var img_w := img.get_width()
	var img_h := img.get_height()
	for px in range(max(0, x), min(img_w, x + w)):
		for py in range(max(0, y), min(img_h, y + h)):
			img.set_pixel(px, py, col)

## Outline rajzolás alpha edge detection alapján
static func draw_outline(img: Image, col: Color := Color.BLACK, thickness: int = 1) -> void:
	var w := img.get_width()
	var h := img.get_height()
	var outline_pixels := []
	
	for x in range(w):
		for y in range(h):
			if img.get_pixel(x, y).a < 0.1:
				# Átlátszó pixel - ellenőrizzük a szomszédokat
				for dx in range(-thickness, thickness + 1):
					for dy in range(-thickness, thickness + 1):
						if dx == 0 and dy == 0:
							continue
						var nx := x + dx
						var ny := y + dy
						if nx >= 0 and nx < w and ny >= 0 and ny < h:
							if img.get_pixel(nx, ny).a > 0.5:
								outline_pixels.append(Vector2i(x, y))
	
	for p in outline_pixels:
		img.set_pixel(p.x, p.y, col)

## Kör rajzolás (kitöltött)
static func draw_circle(img: Image, cx: int, cy: int, r: int, col: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for x in range(max(0, cx - r), min(w, cx + r + 1)):
		for y in range(max(0, cy - r), min(h, cy + r + 1)):
			var dx := x - cx
			var dy := y - cy
			if dx * dx + dy * dy <= r * r:
				if col.a < 1.0:
					var existing := img.get_pixel(x, y)
					img.set_pixel(x, y, existing.blend(col))
				else:
					img.set_pixel(x, y, col)

## Kör körvonal (nem kitöltött)
static func draw_circle_outline(img: Image, cx: int, cy: int, r: int, col: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	# Midpoint circle algorithm
	var x := r
	var y := 0
	var err := 0
	while x >= y:
		_set_pixel_safe(img, cx + x, cy + y, col)
		_set_pixel_safe(img, cx + y, cy + x, col)
		_set_pixel_safe(img, cx - y, cy + x, col)
		_set_pixel_safe(img, cx - x, cy + y, col)
		_set_pixel_safe(img, cx - x, cy - y, col)
		_set_pixel_safe(img, cx - y, cy - x, col)
		_set_pixel_safe(img, cx + y, cy - x, col)
		_set_pixel_safe(img, cx + x, cy - y, col)
		if err <= 0:
			y += 1
			err += 2 * y + 1
		if err > 0:
			x -= 1
			err -= 2 * x + 1

## Vonal rajzolás (Bresenham algoritmus)
static func draw_line_px(img: Image, x0: int, y0: int, x1: int, y1: int, col: Color) -> void:
	var dx := absi(x1 - x0)
	var dy := -absi(y1 - y0)
	var sx := 1 if x0 < x1 else -1
	var sy := 1 if y0 < y1 else -1
	var err := dx + dy
	
	while true:
		_set_pixel_safe(img, x0, y0, col)
		if x0 == x1 and y0 == y1:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			x0 += sx
		if e2 <= dx:
			err += dx
			y0 += sy

## Ellipszis rajzolás
static func draw_ellipse(img: Image, cx: int, cy: int, rx: int, ry: int, col: Color) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for x in range(max(0, cx - rx), min(w, cx + rx + 1)):
		for y in range(max(0, cy - ry), min(h, cy + ry + 1)):
			var dx := float(x - cx) / float(rx) if rx > 0 else 0.0
			var dy := float(y - cy) / float(ry) if ry > 0 else 0.0
			if dx * dx + dy * dy <= 1.0:
				img.set_pixel(x, y, col)

## Biztonságos pixel beállítás
static func _set_pixel_safe(img: Image, x: int, y: int, col: Color) -> void:
	if x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
		if col.a < 1.0:
			var existing := img.get_pixel(x, y)
			img.set_pixel(x, y, existing.blend(col))
		else:
			img.set_pixel(x, y, col)

## Kép eltolása (shift)
static func shift_image(img: Image, dx: int, dy: int) -> Image:
	var w := img.get_width()
	var h := img.get_height()
	var result := Image.create(w, h, false, Image.FORMAT_RGBA8)
	result.fill(Color(0, 0, 0, 0))
	
	for x in range(w):
		for y in range(h):
			var nx := x + dx
			var ny := y + dy
			if nx >= 0 and nx < w and ny >= 0 and ny < h:
				result.set_pixel(nx, ny, img.get_pixel(x, y))
	
	return result

## Horizontális tükrözés
static func flip_horizontal(img: Image) -> Image:
	var w := img.get_width()
	var h := img.get_height()
	var result := Image.create(w, h, false, Image.FORMAT_RGBA8)
	
	for x in range(w):
		for y in range(h):
			result.set_pixel(w - 1 - x, y, img.get_pixel(x, y))
	
	return result

## Paletta swap alkalmazása
static func apply_palette(img: Image, palette_map: Dictionary) -> Image:
	var w := img.get_width()
	var h := img.get_height()
	var result := img.duplicate()
	
	for x in range(w):
		for y in range(h):
			var pixel := result.get_pixel(x, y)
			if pixel.a < 0.1:
				continue
			for from_col in palette_map:
				if _colors_match(pixel, from_col, 0.05):
					var to_col: Color = palette_map[from_col]
					to_col.a = pixel.a
					result.set_pixel(x, y, to_col)
					break
	
	return result

## Szín összehasonlítás (tolerance-cel)
static func _colors_match(a: Color, b: Color, tolerance: float = 0.05) -> bool:
	return (absf(a.r - b.r) < tolerance and
			absf(a.g - b.g) < tolerance and
			absf(a.b - b.b) < tolerance)

## Szín sötétítés kontrolláltan
static func darken_color(col: Color, amount: float) -> Color:
	return Color(
		clampf(col.r - amount, 0.0, 1.0),
		clampf(col.g - amount, 0.0, 1.0),
		clampf(col.b - amount, 0.0, 1.0),
		col.a
	)

## Szín világosítás
static func lighten_color(col: Color, amount: float) -> Color:
	return Color(
		clampf(col.r + amount, 0.0, 1.0),
		clampf(col.g + amount, 0.0, 1.0),
		clampf(col.b + amount, 0.0, 1.0),
		col.a
	)

## Keret rajzolás (UI elemekhez)
static func draw_frame(img: Image, col: Color, thickness: int = 2) -> void:
	var w := img.get_width()
	var h := img.get_height()
	for t in range(thickness):
		for x in range(w):
			_set_pixel_safe(img, x, t, col)
			_set_pixel_safe(img, x, h - 1 - t, col)
		for y in range(h):
			_set_pixel_safe(img, t, y, col)
			_set_pixel_safe(img, w - 1 - t, y, col)

## Textúra random foltokkal (talaj generáláshoz)
static func add_noise_texture(img: Image, base_col: Color, var_col: Color,
		count: int = 30, min_size: int = 2, max_size: int = 6,
		seed_val: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var w := img.get_width()
	var h := img.get_height()
	
	for i in range(count):
		var tx := rng.randi_range(1, w - max_size - 1)
		var ty := rng.randi_range(1, h - max_size - 1)
		var ts := rng.randi_range(min_size, max_size)
		var blend_col := base_col.lerp(var_col, rng.randf())
		fill_rect(img, tx, ty, ts, ts, blend_col)

## Kő textúra generálás (falakhoz)
static func draw_stone_texture(img: Image, col: Color, seed_val: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var w := img.get_width()
	var h := img.get_height()
	
	# Kő rétegek
	for i in range(8):
		var bx := rng.randi_range(0, w - 16)
		var by := rng.randi_range(0, h - 12)
		var bw := rng.randi_range(10, 24)
		var bh := rng.randi_range(8, 16)
		var stone_col := col.lerp(darken_color(col, 0.1), rng.randf() * 0.5)
		fill_rect(img, bx, by, bw, bh, stone_col)
	
	# Repedések
	for i in range(4):
		var sx := rng.randi_range(4, w - 4)
		var sy := rng.randi_range(4, h - 4)
		var ex := sx + rng.randi_range(-8, 8)
		var ey := sy + rng.randi_range(4, 12)
		draw_line_px(img, sx, sy, ex, ey, darken_color(col, 0.2))

## Moha foltok rajzolás (dungeon/forest)
static func draw_moss_patches(img: Image, col: Color, count: int = 5, seed_val: int = 0) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_val
	var w := img.get_width()
	var h := img.get_height()
	
	for i in range(count):
		var cx := rng.randi_range(8, w - 8)
		var cy := rng.randi_range(8, h - 8)
		var r := rng.randi_range(3, 7)
		draw_circle(img, cx, cy, r, Color(col.r, col.g, col.b, 0.6))

# ═══════════════════════════════════════════════════════════════
# SPRITEFRAMES BUILDER
# ═══════════════════════════════════════════════════════════════

## SpriteFrames resource összeállítása
## anim_data formátum: { "anim_name": { "frames": [ImageTexture], "fps": float, "loop": bool } }
static func build_sprite_frames(anim_data: Dictionary) -> SpriteFrames:
	var sf := SpriteFrames.new()
	# Töröljük az alap "default" animációt ha van
	if sf.has_animation("default"):
		sf.remove_animation("default")
	
	for anim_name in anim_data:
		var data: Dictionary = anim_data[anim_name]
		sf.add_animation(anim_name)
		sf.set_animation_loop(anim_name, data.get("loop", true))
		sf.set_animation_speed(anim_name, data.get("fps", 8.0))
		for tex in data.get("frames", []):
			sf.add_frame(anim_name, tex)
	
	return sf

## Image → ImageTexture konverzió
static func to_texture(img: Image) -> ImageTexture:
	return ImageTexture.create_from_image(img)

## PNG mentés helper
static func save_png(img: Image, path: String) -> void:
	var dir := path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	img.save_png(path)

## Több frame exportálás
static func export_frames(frames: Array, base_path: String, prefix: String) -> void:
	for i in range(frames.size()):
		var path := "%s/%s_%d.png" % [base_path, prefix, i]
		save_png(frames[i], path)

# ═══════════════════════════════════════════════════════════════
# SHADOW / ÁRNYÉK
# ═══════════════════════════════════════════════════════════════

## Ellipszis árnyék a sprite alá
static func draw_shadow(img: Image, cx: int, cy: int, rx: int, ry: int) -> void:
	draw_ellipse(img, cx, cy, rx, ry, Color(0, 0, 0, 0.25))

# ═══════════════════════════════════════════════════════════════
# LÉGZÉS ANIMÁCIÓ HELPER
# ═══════════════════════════════════════════════════════════════

## Standard breath offset számítás idle animációhoz
static func get_breath_offset(frame_idx: int, frame_count: int = 4) -> int:
	var offsets_4 := [0, -1, -1, 0]
	var offsets_6 := [0, 0, -1, -1, 0, 0]
	if frame_count == 4:
		return offsets_4[frame_idx % 4]
	elif frame_count == 6:
		return offsets_6[frame_idx % 6]
	return 0

## Walk sway offset (séta közben enyhe billegés)
static func get_walk_sway(frame_idx: int, frame_count: int = 6) -> int:
	var offsets := [0, 1, 0, -1, 0, 1] if frame_count == 6 else [0, 1, 0, -1]
	return offsets[frame_idx % offsets.size()]

## Walk bob offset (séta közben enyhe emelkedés)
static func get_walk_bob(frame_idx: int, frame_count: int = 6) -> int:
	var offsets := [0, -1, 0, 0, -1, 0] if frame_count == 6 else [0, -1, 0, -1]
	return offsets[frame_idx % offsets.size()]

## HudIconGenerator - HUD ikonok (~26 db, 32×32)
## Pénznemek(3 animált), HUD stat ikonok(16), státusz effektek(8)
class_name HudIconGenerator
extends PixelArtBase

# --- Pénznem ikonok (animált, 4 frame) ---
static func gen_currency_icon(currency: String, frame: int) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match currency:
		"gold":
			var col := Color(0.85, 0.70, 0.15)
			var pulse := 1.0 + sin(frame * PI / 2.0) * 0.05
			draw_circle(img, 16, 16, int(10 * pulse), col)
			draw_circle(img, 16, 16, int(8 * pulse), col.lightened(0.12))
			# G betű
			fill_rect(img, 12, 12, 8, 2, col.darkened(0.2))
			fill_rect(img, 12, 12, 2, 8, col.darkened(0.2))
			fill_rect(img, 12, 18, 8, 2, col.darkened(0.2))
			fill_rect(img, 16, 15, 4, 5, col.darkened(0.2))
			# Csillogás
			if frame == 0:
				_set_pixel_safe(img, 10, 10, Color(1.0, 1.0, 0.80, 0.7))
		"ash_coins":
			var col := Color(0.45, 0.40, 0.35)
			draw_circle(img, 16, 16, 10, col)
			draw_circle(img, 16, 16, 8, col.lightened(0.1))
			# Hamu minta
			var rng := RandomNumberGenerator.new()
			rng.seed = frame * 111
			for i in range(6):
				_set_pixel_safe(img, rng.randi_range(10, 22), rng.randi_range(10, 22), col.lightened(0.15))
			draw_circle_outline(img, 16, 16, 9, col.darkened(0.15))
		"premium":
			var col := Color(0.50, 0.20, 0.70)
			var pulse := 1.0 + sin(frame * PI / 2.0) * 0.08
			draw_circle(img, 16, 16, int(10 * pulse), col)
			draw_circle(img, 16, 16, 6, col.lightened(0.25))
			# Csillag
			_set_pixel_safe(img, 16, 10, Color(1.0, 0.90, 0.60))
			_set_pixel_safe(img, 12, 14, Color(1.0, 0.90, 0.60))
			_set_pixel_safe(img, 20, 14, Color(1.0, 0.90, 0.60))
			_set_pixel_safe(img, 14, 20, Color(1.0, 0.90, 0.60))
			_set_pixel_safe(img, 18, 20, Color(1.0, 0.90, 0.60))
			if frame % 2 == 0:
				_set_pixel_safe(img, 9, 9, Color(1.0, 1.0, 1.0, 0.5))
	return img

# --- HUD stat ikon ---
static func gen_stat_icon(stat: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match stat:
		"health":
			# Szív
			draw_circle(img, 12, 12, 5, Color(0.85, 0.10, 0.10))
			draw_circle(img, 20, 12, 5, Color(0.85, 0.10, 0.10))
			fill_rect(img, 8, 12, 16, 8, Color(0.85, 0.10, 0.10))
			_set_pixel_safe(img, 16, 24, Color(0.85, 0.10, 0.10))
			fill_rect(img, 10, 18, 12, 4, Color(0.85, 0.10, 0.10))
		"mana":
			# Csepp
			draw_circle(img, 16, 18, 7, Color(0.15, 0.30, 0.85))
			_set_pixel_safe(img, 16, 8, Color(0.15, 0.30, 0.85))
			fill_rect(img, 14, 8, 4, 6, Color(0.15, 0.30, 0.85))
			_set_pixel_safe(img, 13, 15, Color(0.40, 0.55, 0.95))
		"stamina":
			# Villám
			fill_rect(img, 14, 4, 6, 8, Color(0.85, 0.75, 0.10))
			fill_rect(img, 10, 12, 8, 4, Color(0.85, 0.75, 0.10))
			fill_rect(img, 12, 16, 6, 8, Color(0.85, 0.75, 0.10))
			_set_pixel_safe(img, 14, 24, Color(0.85, 0.75, 0.10))
		"attack":
			# Kard
			fill_rect(img, 14, 4, 4, 18, Color(0.60, 0.58, 0.55))
			fill_rect(img, 10, 20, 12, 2, Color(0.40, 0.25, 0.10))
			fill_rect(img, 14, 22, 4, 6, Color(0.35, 0.20, 0.08))
		"defense":
			# Pajzs
			draw_ellipse(img, 16, 16, 10, 12, Color(0.45, 0.42, 0.38))
			draw_ellipse(img, 16, 16, 8, 10, Color(0.50, 0.48, 0.42))
			fill_rect(img, 14, 10, 4, 12, Color(0.65, 0.55, 0.20))
			fill_rect(img, 10, 14, 12, 4, Color(0.65, 0.55, 0.20))
		"speed":
			# Szárny/cipő
			fill_rect(img, 8, 14, 16, 10, Color(0.30, 0.18, 0.08))
			fill_rect(img, 6, 22, 20, 4, Color(0.28, 0.16, 0.06))
			# Szárnyak
			fill_rect(img, 4, 8, 6, 8, Color(0.70, 0.68, 0.60))
			fill_rect(img, 22, 8, 6, 8, Color(0.70, 0.68, 0.60))
		"crit":
			# Csillag villanás
			draw_line_px(img, 16, 4, 16, 28, Color(1.0, 0.80, 0.10))
			draw_line_px(img, 4, 16, 28, 16, Color(1.0, 0.80, 0.10))
			draw_line_px(img, 8, 8, 24, 24, Color(1.0, 0.80, 0.10))
			draw_line_px(img, 24, 8, 8, 24, Color(1.0, 0.80, 0.10))
			draw_circle(img, 16, 16, 3, Color(1.0, 0.90, 0.30))
		"xp":
			# Csillag
			draw_circle(img, 16, 16, 8, Color(0.20, 0.60, 0.85))
			draw_circle(img, 16, 16, 5, Color(0.30, 0.70, 0.95))
			_set_pixel_safe(img, 14, 14, Color(0.60, 0.90, 1.0))
		"level":
			# Felfelé nyíl
			_set_pixel_safe(img, 16, 6, Color(0.85, 0.70, 0.15))
			fill_rect(img, 14, 8, 4, 2, Color(0.85, 0.70, 0.15))
			fill_rect(img, 12, 10, 8, 2, Color(0.85, 0.70, 0.15))
			fill_rect(img, 14, 12, 4, 14, Color(0.85, 0.70, 0.15))
		"luck":
			# Lóhere
			draw_circle(img, 13, 12, 4, Color(0.15, 0.60, 0.15))
			draw_circle(img, 19, 12, 4, Color(0.15, 0.60, 0.15))
			draw_circle(img, 16, 9, 4, Color(0.15, 0.60, 0.15))
			fill_rect(img, 15, 16, 2, 10, Color(0.15, 0.40, 0.08))
	return img

# --- Státusz effekt ikon ---
static func gen_status_icon(status: String) -> Image:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match status:
		"poison":
			draw_circle(img, 12, 12, 8, Color(0.15, 0.50, 0.08))
			# Koponya
			draw_circle(img, 12, 10, 4, Color(0.80, 0.78, 0.65))
			_set_pixel_safe(img, 10, 9, Color(0, 0, 0))
			_set_pixel_safe(img, 13, 9, Color(0, 0, 0))
		"burn":
			draw_circle(img, 12, 14, 6, Color(1.0, 0.40, 0.05))
			draw_circle(img, 12, 12, 4, Color(1.0, 0.70, 0.15))
			_set_pixel_safe(img, 12, 8, Color(1.0, 0.90, 0.40))
		"freeze":
			draw_circle(img, 12, 12, 8, Color(0.50, 0.75, 1.0))
			# Jégkristály
			draw_line_px(img, 12, 4, 12, 20, Color(0.80, 0.90, 1.0))
			draw_line_px(img, 4, 12, 20, 12, Color(0.80, 0.90, 1.0))
		"bleed":
			# Vércsepp
			draw_circle(img, 12, 14, 5, Color(0.60, 0.02, 0.02))
			_set_pixel_safe(img, 12, 6, Color(0.60, 0.02, 0.02))
			fill_rect(img, 11, 7, 2, 4, Color(0.60, 0.02, 0.02))
		"stun":
			# Csillagok
			for i in range(3):
				var angle := i * 2.0 * PI / 3.0
				var sx := int(12 + cos(angle) * 6)
				var sy := int(10 + sin(angle) * 6)
				_set_pixel_safe(img, sx, sy, Color(1.0, 1.0, 0.30))
				_set_pixel_safe(img, sx + 1, sy, Color(1.0, 1.0, 0.30))
		"shield":
			draw_ellipse(img, 12, 12, 8, 10, Color(0.60, 0.55, 0.20))
			draw_ellipse(img, 12, 12, 6, 8, Color(0.70, 0.65, 0.30))
		"haste":
			# Nyilak jobbra
			for i in range(3):
				var ox := i * 5
				draw_line_px(img, 4 + ox, 12, 8 + ox, 8, Color(0.20, 0.70, 0.90))
				draw_line_px(img, 4 + ox, 12, 8 + ox, 16, Color(0.20, 0.70, 0.90))
		"slow":
			# Óra
			draw_circle_outline(img, 12, 12, 8, Color(0.50, 0.45, 0.40))
			draw_line_px(img, 12, 12, 12, 6, Color(0.50, 0.45, 0.40))
			draw_line_px(img, 12, 12, 16, 12, Color(0.50, 0.45, 0.40))
	return img

static func get_stat_names() -> Array:
	return ["health", "mana", "stamina", "attack", "defense", "speed", "crit", "xp", "level", "luck"]

static func get_status_names() -> Array:
	return ["poison", "burn", "freeze", "bleed", "stun", "shield", "haste", "slow"]

static func get_currency_names() -> Array:
	return ["gold", "ash_coins", "premium"]

static func get_anim_config() -> Dictionary:
	return {"currency": {"frames": 4, "fps": 4, "loop": true}}

static func export_all(base_path: String) -> void:
	var path := base_path + "icons/hud/"
	# Pénznemek
	for c in get_currency_names():
		for f in range(4):
			save_png(gen_currency_icon(c, f), path + "currency/%s_%d.png" % [c, f])
	# Stat ikonok
	for s in get_stat_names():
		save_png(gen_stat_icon(s), path + "stats/%s.png" % s)
	# Státusz effektek
	for st in get_status_names():
		save_png(gen_status_icon(st), path + "status/%s.png" % st)
	print("  ✓ HUD icons exported to: ", path)

## CorruptedForestEnemies - Corrupted Forest biome enemy sprite generátor
## 5 enemy: Blighted Wolf, Thorn Crawler, Fungal Spitter, Druid Wraith, Treant Guardian
class_name CorruptedForestEnemies
extends PixelArtBase

const DARK_GREEN  = Color(0.10, 0.23, 0.06)
const FOREST_GRN  = Color(0.15, 0.30, 0.08)
const CORRUPT_PUR = Color(0.50, 0.10, 0.60)
const POISON_GRN  = Color(0.25, 0.60, 0.10)
const BARK_BROWN  = Color(0.23, 0.13, 0.05)
const BARK_DARK   = Color(0.15, 0.08, 0.03)
const MUSHROOM_BR = Color(0.42, 0.27, 0.12)
const LEAF_GREEN  = Color(0.20, 0.40, 0.08)
const WRAITH_GREEN = Color(0.15, 0.50, 0.15)

static func _draw_blighted_wolf(img: Image, frame_idx: int, anim: String) -> void:
	var bob := get_walk_bob(frame_idx, 4) if anim == "walk" else 0
	draw_shadow(img, 32, 58, 16, 4)
	# Test - farkas forma, púpozott hát
	draw_ellipse(img, 32, 34 + bob, 18, 14, DARK_GREEN)
	# Hátsó púp
	draw_ellipse(img, 24, 28 + bob, 10, 8, Color(0.12, 0.25, 0.08))
	# Fej
	draw_ellipse(img, 48, 28 + bob, 10, 8, DARK_GREEN)
	# Mancsok
	fill_rect(img, 14, 46 + bob, 8, 8, DARK_GREEN)
	fill_rect(img, 26, 48 + bob, 8, 8, DARK_GREEN)
	fill_rect(img, 38, 48 + bob, 8, 8, DARK_GREEN)
	fill_rect(img, 50, 46 + bob, 8, 8, DARK_GREEN)
	# Lila szemek
	_set_pixel_safe(img, 50, 26 + bob, CORRUPT_PUR)
	_set_pixel_safe(img, 54, 26 + bob, CORRUPT_PUR)
	# Fekete sörény
	fill_rect(img, 20, 22 + bob, 16, 6, Color(0.05, 0.08, 0.03))
	# Fogak
	_set_pixel_safe(img, 56, 32 + bob, Color(0.90, 0.88, 0.80))
	_set_pixel_safe(img, 58, 32 + bob, Color(0.90, 0.88, 0.80))
	if anim == "attack" and frame_idx % 4 == 2:
		fill_rect(img, 56, 28, 6, 8, Color(0.90, 0.88, 0.80))

static func _draw_thorn_crawler(img: Image, frame_idx: int, anim: String) -> void:
	var bob := get_walk_bob(frame_idx, 4) if anim == "walk" else 0
	draw_shadow(img, 32, 58, 18, 3)
	# Test - lapos rovarszerű
	draw_ellipse(img, 32, 36 + bob, 20, 8, Color(0.25, 0.18, 0.08))
	draw_ellipse(img, 32, 36 + bob, 16, 6, FOREST_GRN)
	# Sok láb
	for i in range(6):
		var lx := 12 + i * 8
		var ly := 42 + bob + (i % 2) * 2
		fill_rect(img, lx, ly, 4, 10, Color(0.18, 0.12, 0.05))
	# Tövisek - kiálló fekete vonalak
	for i in range(4):
		var tx := 18 + i * 10
		draw_line_px(img, tx, 30 + bob, tx + 2, 22 + bob, Color(0.05, 0.05, 0.02))
	# Szemek
	_set_pixel_safe(img, 46, 32 + bob, Color(0.80, 0.70, 0.10))
	_set_pixel_safe(img, 50, 32 + bob, Color(0.80, 0.70, 0.10))

static func _draw_fungal_spitter(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 12, 4)
	# Lábak
	fill_rect(img, 20, 76 + breath, 8, 14, MUSHROOM_BR)
	fill_rect(img, 36, 76 + breath, 8, 14, MUSHROOM_BR)
	# Humanoid gomba test
	fill_rect(img, 16, 36 + breath, 32, 42, MUSHROOM_BR)
	fill_rect(img, 16, 36 + breath, 6, 42, Color(0.35, 0.20, 0.08))
	# Zöld foltok
	draw_circle(img, 24, 50 + breath, 4, POISON_GRN)
	draw_circle(img, 38, 60 + breath, 3, POISON_GRN)
	# Kalapgomba fej
	draw_ellipse(img, 32, 18 + breath, 22, 14, Color(0.50, 0.30, 0.15))
	draw_ellipse(img, 32, 22 + breath, 18, 8, MUSHROOM_BR)
	# Foltok a kalapgomba
	draw_circle(img, 24, 14 + breath, 3, Color(0.60, 0.35, 0.18))
	draw_circle(img, 40, 16 + breath, 2, Color(0.60, 0.35, 0.18))
	# Sárga szemek
	_set_pixel_safe(img, 28, 26 + breath, Color(0.80, 0.70, 0.10))
	_set_pixel_safe(img, 36, 26 + breath, Color(0.80, 0.70, 0.10))
	if anim == "attack" and frame_idx % 4 >= 2:
		# Spórák kilövése
		for i in range(3):
			draw_circle(img, 32 + i * 8, 10 - frame_idx * 3, 3, Color(POISON_GRN.r, POISON_GRN.g, POISON_GRN.b, 0.7))

static func _draw_druid_wraith(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	var float_y := [0, -2, -3, -2][frame_idx % 4]
	draw_shadow(img, 32, 88, 10, 3)
	# Lebegő alak - áttetsző köd alsó rész
	for y in range(60, 90):
		var alpha := 0.7 - float(y - 60) / 42.0
		fill_rect(img, 18, y + float_y, 28, 1, Color(WRAITH_GREEN.r, WRAITH_GREEN.g, WRAITH_GREEN.b, max(0.05, alpha)))
	# Feltest - áttetsző zöld
	fill_rect(img, 18, 30 + float_y, 28, 32, Color(WRAITH_GREEN.r, WRAITH_GREEN.g, WRAITH_GREEN.b, 0.7))
	# Karok
	fill_rect(img, 10, 36 + float_y, 10, 20, Color(WRAITH_GREEN.r, WRAITH_GREEN.g, WRAITH_GREEN.b, 0.6))
	fill_rect(img, 44, 36 + float_y, 10, 20, Color(WRAITH_GREEN.r, WRAITH_GREEN.g, WRAITH_GREEN.b, 0.6))
	# Izzó rúnák
	draw_circle(img, 26, 44 + float_y, 2, Color(0.30, 0.80, 0.30, 0.8))
	draw_circle(img, 38, 48 + float_y, 2, Color(0.30, 0.80, 0.30, 0.8))
	# Fej
	fill_rect(img, 22, 10 + float_y, 20, 22, Color(WRAITH_GREEN.r, WRAITH_GREEN.g, WRAITH_GREEN.b, 0.7))
	# Izzó szemek
	_set_pixel_safe(img, 28, 20 + float_y, Color(0.50, 1.0, 0.50))
	_set_pixel_safe(img, 36, 20 + float_y, Color(0.50, 1.0, 0.50))

static func _draw_treant_guardian(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 48, 122, 22, 6)
	# Gyökerek/lábak
	fill_rect(img, 14, 98 + breath, 18, 26, BARK_BROWN)
	fill_rect(img, 64, 98 + breath, 18, 26, BARK_BROWN)
	# Törzs - élő fa
	fill_rect(img, 16, 28 + breath, 64, 72, BARK_BROWN)
	fill_rect(img, 16, 28 + breath, 10, 72, BARK_DARK)
	# Kéreg textúra
	draw_line_px(img, 30, 34 + breath, 30, 94 + breath, BARK_DARK)
	draw_line_px(img, 50, 40 + breath, 50, 90 + breath, BARK_DARK)
	draw_line_px(img, 66, 36 + breath, 66, 88 + breath, BARK_DARK)
	# Lila korrumpált foltok
	draw_circle(img, 36, 50 + breath, 6, Color(0.31, 0.06, 0.38))
	draw_circle(img, 58, 66 + breath, 5, Color(0.31, 0.06, 0.38))
	draw_circle(img, 42, 80 + breath, 4, Color(0.31, 0.06, 0.38))
	# Ágkarok
	fill_rect(img, 0, 36 + breath, 18, 10, BARK_BROWN)
	fill_rect(img, 78, 36 + breath, 18, 10, BARK_BROWN)
	# Ágvégek
	draw_line_px(img, 0, 36 + breath, -4, 30 + breath, BARK_BROWN)
	draw_line_px(img, 0, 44 + breath, -4, 50 + breath, BARK_BROWN)
	# Arc a törzsbe vésve
	fill_rect(img, 34, 36 + breath, 8, 4, Color(0.08, 0.05, 0.02))
	fill_rect(img, 52, 36 + breath, 8, 4, Color(0.08, 0.05, 0.02))
	fill_rect(img, 40, 48 + breath, 16, 4, Color(0.08, 0.05, 0.02))
	# Rohadó levelek a tetején
	for i in range(6):
		var lx := 20 + i * 10
		var ly := 16 + (i % 3) * 4 + breath
		fill_rect(img, lx, ly, 6, 6, LEAF_GREEN)
	# Moh
	fill_rect(img, 22, 70 + breath, 12, 6, Color(0.12, 0.28, 0.06))

static func generate_enemy(enemy_name: String, anim: String, frame_idx: int) -> Image:
	var sizes := {
		"blighted_wolf": Vector2i(64, 64),
		"thorn_crawler": Vector2i(64, 64),
		"fungal_spitter": Vector2i(64, 96),
		"druid_wraith": Vector2i(64, 96),
		"treant_guardian": Vector2i(96, 128),
	}
	var size: Vector2i = sizes.get(enemy_name, Vector2i(64, 96))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	match enemy_name:
		"blighted_wolf":    _draw_blighted_wolf(img, frame_idx, anim)
		"thorn_crawler":    _draw_thorn_crawler(img, frame_idx, anim)
		"fungal_spitter":   _draw_fungal_spitter(img, frame_idx, anim)
		"druid_wraith":     _draw_druid_wraith(img, frame_idx, anim)
		"treant_guardian":  _draw_treant_guardian(img, frame_idx, anim)
	
	draw_outline(img, Color.BLACK)
	return img

static func get_enemy_names() -> Array:
	return ["blighted_wolf", "thorn_crawler", "fungal_spitter", "druid_wraith", "treant_guardian"]

static func get_anim_config() -> Dictionary:
	return {
		"idle":    {"frames": 4, "fps": 5, "loop": true},
		"walk":    {"frames": 4, "fps": 8, "loop": true},
		"attack":  {"frames": 4, "fps": 10, "loop": false},
		"hit":     {"frames": 2, "fps": 10, "loop": false},
		"death":   {"frames": 4, "fps": 7, "loop": false},
	}

static func export_all(base_path: String) -> void:
	var path := base_path + "corrupted_forest/"
	var anims := get_anim_config()
	for enemy_name in get_enemy_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for i in range(config["frames"]):
				save_png(generate_enemy(enemy_name, anim_name, i), path + "%s/%s_%d.png" % [enemy_name, anim_name, i])
	print("  ✓ Corrupted Forest enemies exported to: ", path)

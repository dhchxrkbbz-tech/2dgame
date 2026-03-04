## NecroticRuinsEnemies - Necrotic Ruins biome enemy sprite generátor
## 5 enemy: Skeleton Warrior, Bone Archer, Lich Apprentice, Death Knight, Bone Colossus
class_name NecroticRuinsEnemies
extends PixelArtBase

const BONE_WHT   = Color(0.85, 0.82, 0.72)  # #D8D0B8
const RUST_BRN   = Color(0.53, 0.33, 0.19)  # #885530
const LICH_PURP  = Color(0.19, 0.03, 0.31)  # #300850
const LICH_GLW   = Color(0.50, 0.13, 0.75)
const DK_BLACK   = Color(0.03, 0.03, 0.03)  # #080808
const DK_RED     = Color(0.75, 0.00, 0.13)  # #C00020
const BONE_YEL   = Color(0.78, 0.72, 0.53)  # #C8B888
const ROT_GRN    = Color(0.13, 0.25, 0.06)  # #204010

static func _draw_skeleton_warrior(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 10, 3)
	# Csont lábak
	fill_rect(img, 22, 74 + breath, 4, 16, BONE_WHT)
	fill_rect(img, 38, 74 + breath, 4, 16, BONE_WHT)
	# Medence
	fill_rect(img, 18, 66 + breath, 28, 10, BONE_WHT)
	# Gerinc
	fill_rect(img, 30, 28 + breath, 4, 40, BONE_WHT)
	# Bordák
	for i in range(5):
		fill_rect(img, 22, 34 + i * 6 + breath, 20, 2, BONE_WHT)
	# Karok - csont szegmensek
	fill_rect(img, 12, 30 + breath, 4, 20, BONE_WHT)
	fill_rect(img, 10, 48 + breath, 4, 14, BONE_WHT)
	fill_rect(img, 48, 30 + breath, 4, 20, BONE_WHT)
	fill_rect(img, 50, 48 + breath, 4, 14, BONE_WHT)
	# Pajzs (bal)
	fill_rect(img, 2, 36 + breath, 12, 22, RUST_BRN)
	fill_rect(img, 4, 38 + breath, 8, 18, Color(0.45, 0.28, 0.15))
	# Kard (jobb)
	fill_rect(img, 54, 20 + breath, 4, 42, Color(0.60, 0.58, 0.55))
	fill_rect(img, 52, 18 + breath, 8, 4, Color(0.60, 0.58, 0.55))
	fill_rect(img, 53, 60 + breath, 6, 6, RUST_BRN)
	# Koponya
	fill_rect(img, 22, 6 + breath, 20, 22, BONE_WHT)
	_set_pixel_safe(img, 28, 14 + breath, Color.BLACK)
	_set_pixel_safe(img, 36, 14 + breath, Color.BLACK)
	fill_rect(img, 30, 20 + breath, 4, 4, Color(0.20, 0.18, 0.15))

static func _draw_bone_archer(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 10, 3)
	# Csont lábak
	fill_rect(img, 22, 74 + breath, 4, 16, BONE_WHT)
	fill_rect(img, 38, 74 + breath, 4, 16, BONE_WHT)
	# Medence + gerinc
	fill_rect(img, 18, 66 + breath, 28, 10, BONE_WHT)
	fill_rect(img, 30, 28 + breath, 4, 40, BONE_WHT)
	# Bordák
	for i in range(4):
		fill_rect(img, 24, 36 + i * 6 + breath, 16, 2, BONE_WHT)
	# Sötét köpeny részletek
	fill_rect(img, 18, 54 + breath, 28, 16, Color(0.15, 0.12, 0.10))
	# Karok
	fill_rect(img, 12, 30 + breath, 4, 20, BONE_WHT)
	fill_rect(img, 48, 30 + breath, 4, 20, BONE_WHT)
	# Íj (jobb)
	fill_rect(img, 52, 22 + breath, 3, 40, RUST_BRN)
	fill_rect(img, 54, 22 + breath, 6, 2, RUST_BRN)
	fill_rect(img, 54, 60 + breath, 6, 2, RUST_BRN)
	# Nyíl húzás
	if anim == "attack" and frame_idx % 4 >= 1:
		fill_rect(img, 10, 40 + breath, 42, 1, Color(0.55, 0.50, 0.42))
		fill_rect(img, 8, 38 + breath, 4, 5, Color(0.60, 0.58, 0.55))
	# Koponya
	fill_rect(img, 22, 6 + breath, 20, 22, BONE_WHT)
	_set_pixel_safe(img, 28, 14 + breath, Color.BLACK)
	_set_pixel_safe(img, 36, 14 + breath, Color.BLACK)
	fill_rect(img, 30, 20 + breath, 4, 4, Color(0.20, 0.18, 0.15))

static func _draw_lich_apprentice(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 12, 4)
	# Sötétlila robe
	fill_rect(img, 12, 28 + breath, 40, 60, LICH_PURP)
	fill_rect(img, 10, 80 + breath, 44, 10, Color(0.14, 0.02, 0.24))
	# Nekrotikus aura
	draw_circle(img, 32, 50 + breath, 18, Color(LICH_GLW.r, LICH_GLW.g, LICH_GLW.b, 0.15))
	# Lebegő csontkezek
	fill_rect(img, 2, 38 + breath, 10, 4, BONE_WHT)
	fill_rect(img, 0, 36 + breath, 6, 8, BONE_WHT)
	fill_rect(img, 52, 38 + breath, 10, 4, BONE_WHT)
	fill_rect(img, 58, 36 + breath, 6, 8, BONE_WHT)
	# Energia a kezek közt
	if anim == "attack" or anim == "idle":
		draw_circle(img, 32, 42 + breath, 5, Color(LICH_GLW.r, LICH_GLW.g, LICH_GLW.b, 0.5))
	# Koponya kapucniban
	fill_rect(img, 14, 4 + breath, 36, 14, LICH_PURP)
	fill_rect(img, 20, 8 + breath, 24, 22, BONE_WHT)
	# Izzó szemek
	fill_rect(img, 26, 16 + breath, 3, 3, LICH_GLW)
	fill_rect(img, 35, 16 + breath, 3, 3, LICH_GLW)

static func _draw_death_knight(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 12, 4)
	# Teljes fekete páncél
	fill_rect(img, 16, 74 + breath, 10, 16, DK_BLACK)
	fill_rect(img, 38, 74 + breath, 10, 16, DK_BLACK)
	fill_rect(img, 12, 30 + breath, 40, 48, DK_BLACK)
	# Rozsda
	fill_rect(img, 20, 40 + breath, 8, 6, Color(0.25, 0.15, 0.08))
	fill_rect(img, 40, 52 + breath, 6, 8, Color(0.25, 0.15, 0.08))
	# Páncél vállpánt
	fill_rect(img, 8, 28 + breath, 14, 10, DK_BLACK)
	fill_rect(img, 42, 28 + breath, 14, 10, DK_BLACK)
	# Karok
	fill_rect(img, 4, 36 + breath, 10, 28, DK_BLACK)
	fill_rect(img, 50, 36 + breath, 10, 28, DK_BLACK)
	# Fegyver
	fill_rect(img, 54, 16 + breath, 4, 50, Color(0.30, 0.28, 0.25))
	fill_rect(img, 50, 14 + breath, 12, 4, Color(0.30, 0.28, 0.25))
	# Sisak
	fill_rect(img, 18, 4 + breath, 28, 26, DK_BLACK)
	fill_rect(img, 20, 6 + breath, 24, 22, Color(0.06, 0.06, 0.06))
	# Piros szemek
	fill_rect(img, 26, 14 + breath, 3, 3, DK_RED)
	fill_rect(img, 35, 14 + breath, 3, 3, DK_RED)
	# Sisak nyílás
	fill_rect(img, 24, 12 + breath, 16, 10, Color(0.04, 0.04, 0.04))

static func _draw_bone_colossus(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 64, 122, 26, 7)
	# Lábak (csont)
	fill_rect(img, 28, 92 + breath, 14, 30, BONE_YEL)
	fill_rect(img, 86, 92 + breath, 14, 30, BONE_YEL)
	# Hatalmas csontváz test
	fill_rect(img, 20, 26 + breath, 88, 70, BONE_YEL)
	# Gerinc
	fill_rect(img, 60, 20 + breath, 8, 76, Color(0.72, 0.66, 0.48))
	# Bordák (nagy)
	for i in range(6):
		fill_rect(img, 30, 30 + i * 10 + breath, 68, 3, BONE_YEL)
	# Bomlás foltok
	fill_rect(img, 36, 42 + breath, 10, 8, ROT_GRN)
	fill_rect(img, 78, 56 + breath, 8, 10, ROT_GRN)
	fill_rect(img, 50, 72 + breath, 12, 8, ROT_GRN)
	# Karok
	fill_rect(img, 4, 32 + breath, 18, 40, BONE_YEL)
	fill_rect(img, 106, 32 + breath, 18, 40, BONE_YEL)
	# Koponya (nagy)
	fill_rect(img, 40, 2 + breath, 48, 28, BONE_YEL)
	# Szem üregek
	fill_rect(img, 48, 10 + breath, 8, 8, Color(0.10, 0.08, 0.05))
	fill_rect(img, 72, 10 + breath, 8, 8, Color(0.10, 0.08, 0.05))
	# Izzó szem pontok
	fill_rect(img, 50, 12 + breath, 4, 4, Color(0.40, 0.80, 0.20))
	fill_rect(img, 74, 12 + breath, 4, 4, Color(0.40, 0.80, 0.20))
	# Fogak
	fill_rect(img, 50, 22 + breath, 4, 4, BONE_WHT)
	fill_rect(img, 58, 22 + breath, 4, 4, BONE_WHT)
	fill_rect(img, 66, 22 + breath, 4, 4, BONE_WHT)
	fill_rect(img, 74, 22 + breath, 4, 4, BONE_WHT)

static func generate_enemy(enemy_name: String, anim: String, frame_idx: int) -> Image:
	var sizes := {
		"skeleton_warrior": Vector2i(64, 96),
		"bone_archer": Vector2i(64, 96),
		"lich_apprentice": Vector2i(64, 96),
		"death_knight": Vector2i(64, 96),
		"bone_colossus": Vector2i(128, 128),
	}
	var size: Vector2i = sizes.get(enemy_name, Vector2i(64, 96))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match enemy_name:
		"skeleton_warrior":  _draw_skeleton_warrior(img, frame_idx, anim)
		"bone_archer":       _draw_bone_archer(img, frame_idx, anim)
		"lich_apprentice":   _draw_lich_apprentice(img, frame_idx, anim)
		"death_knight":      _draw_death_knight(img, frame_idx, anim)
		"bone_colossus":     _draw_bone_colossus(img, frame_idx, anim)
	draw_outline(img, Color.BLACK)
	return img

static func get_enemy_names() -> Array:
	return ["skeleton_warrior", "bone_archer", "lich_apprentice", "death_knight", "bone_colossus"]

static func get_anim_config() -> Dictionary:
	return {"idle": {"frames": 4, "fps": 5, "loop": true}, "walk": {"frames": 4, "fps": 8, "loop": true}, "attack": {"frames": 4, "fps": 10, "loop": false}, "hit": {"frames": 2, "fps": 10, "loop": false}, "death": {"frames": 4, "fps": 7, "loop": false}}

static func export_all(base_path: String) -> void:
	var path := base_path + "necrotic_ruins/"
	var anims := get_anim_config()
	for enemy_name in get_enemy_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for i in range(config["frames"]):
				save_png(generate_enemy(enemy_name, anim_name, i), path + "%s/%s_%d.png" % [enemy_name, anim_name, i])
	print("  ✓ Necrotic Ruins enemies exported to: ", path)

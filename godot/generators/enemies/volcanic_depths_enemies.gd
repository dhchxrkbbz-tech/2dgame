## VolcanicDepthsEnemies - Volcanic Depths biome enemy sprite generátor
## 5 enemy: Magma Slime, Fire Imp, Lava Bomber, Flame Priest, Obsidian Dragon
class_name VolcanicDepthsEnemies
extends PixelArtBase

const MAGMA_ORG  = Color(0.78, 0.25, 0.06)  # #C84010
const MAGMA_GLW  = Color(1.00, 0.50, 0.19)  # #FF8030
const FIRE_RED   = Color(0.72, 0.13, 0.06)  # #B82010
const FLAME_ROBE = Color(0.63, 0.13, 0.06)  # #A02010
const GOLD_TRIM  = Color(0.85, 0.70, 0.20)
const OBSIDIAN   = Color(0.06, 0.03, 0.03)  # #100808
const LAVA_CRACK = Color(1.00, 0.25, 0.06)  # #FF4010
const SKIN_FIRE  = Color(0.80, 0.30, 0.10)

static func _draw_magma_slime(img: Image, frame_idx: int, anim: String) -> void:
	# 48×48 amorf gömb, olvadó szélekkel
	var squash := [0, 1, 2, 1][frame_idx % 4]
	draw_shadow(img, 24, 42, 10, 3)
	# Olvadó gömb (nem egyenes outline)
	draw_ellipse(img, 24, 24 + squash, 14 + squash, 13 - squash, MAGMA_ORG)
	# Olvadó szél-cseppek
	fill_rect(img, 10, 34, 4, 6, MAGMA_ORG)
	fill_rect(img, 30, 36, 4, 4, MAGMA_ORG)
	fill_rect(img, 22, 38, 3, 4, MAGMA_ORG)
	# Izzó belső
	draw_circle(img, 24, 22 + squash, 6, MAGMA_GLW)
	draw_circle(img, 24, 22 + squash, 3, Color(1.0, 0.90, 0.40))
	# Szemek
	_set_pixel_safe(img, 20, 20 + squash, Color.BLACK)
	_set_pixel_safe(img, 28, 20 + squash, Color.BLACK)

static func _draw_fire_imp(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 24, 58, 8, 3)
	# Kis démon test
	fill_rect(img, 10, 20 + breath, 28, 30, FIRE_RED)
	# Lábak
	fill_rect(img, 12, 48 + breath, 8, 12, FIRE_RED)
	fill_rect(img, 28, 48 + breath, 8, 12, FIRE_RED)
	# Kis szárnyak
	fill_rect(img, 2, 18 + breath, 10, 14, Color(0.60, 0.10, 0.05))
	fill_rect(img, 36, 18 + breath, 10, 14, Color(0.60, 0.10, 0.05))
	# Fej
	fill_rect(img, 12, 6 + breath, 24, 16, FIRE_RED)
	# Szarvak
	fill_rect(img, 10, 2 + breath, 4, 8, Color(0.40, 0.08, 0.04))
	fill_rect(img, 34, 2 + breath, 4, 8, Color(0.40, 0.08, 0.04))
	# Sárga szemek
	_set_pixel_safe(img, 18, 12 + breath, Color(1.0, 0.90, 0.20))
	_set_pixel_safe(img, 28, 12 + breath, Color(1.0, 0.90, 0.20))
	# Hegyes farok
	draw_line_px(img, 24, 48 + breath, 38, 56 + breath, FIRE_RED)
	draw_line_px(img, 38, 56 + breath, 42, 54 + breath, FIRE_RED)
	# Ujjakból tűznyelvek
	_set_pixel_safe(img, 8, 44 + breath, Color(1.0, 0.60, 0.10))
	_set_pixel_safe(img, 40, 44 + breath, Color(1.0, 0.60, 0.10))

static func _draw_lava_bomber(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 12, 4)
	# Erős alkat
	fill_rect(img, 12, 30 + breath, 40, 46, Color(0.50, 0.10, 0.05))
	# Lábak
	fill_rect(img, 16, 74 + breath, 10, 16, Color(0.50, 0.10, 0.05))
	fill_rect(img, 38, 74 + breath, 10, 16, Color(0.50, 0.10, 0.05))
	# Sötétvörös páncél
	fill_rect(img, 14, 32 + breath, 36, 18, Color(0.45, 0.08, 0.04))
	# Karok
	fill_rect(img, 2, 34 + breath, 12, 26, Color(0.50, 0.10, 0.05))
	fill_rect(img, 50, 34 + breath, 12, 26, Color(0.50, 0.10, 0.05))
	# Izzó kő-gömb jobb kézben
	draw_circle(img, 56, 30 + breath, 8, MAGMA_ORG)
	draw_circle(img, 56, 30 + breath, 4, MAGMA_GLW)
	# Fej
	fill_rect(img, 18, 8 + breath, 28, 24, Color(0.55, 0.15, 0.08))
	# Sisak
	fill_rect(img, 16, 6 + breath, 32, 12, Color(0.35, 0.06, 0.03))
	_set_pixel_safe(img, 26, 20 + breath, LAVA_CRACK)
	_set_pixel_safe(img, 38, 20 + breath, LAVA_CRACK)

static func _draw_flame_priest(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	draw_shadow(img, 32, 90, 12, 4)
	# Tűz-robe
	fill_rect(img, 12, 28 + breath, 40, 60, FLAME_ROBE)
	fill_rect(img, 10, 80 + breath, 44, 10, Color(0.50, 0.10, 0.04))
	# Arany szegély
	fill_rect(img, 12, 28 + breath, 40, 2, GOLD_TRIM)
	fill_rect(img, 12, 86 + breath, 40, 2, GOLD_TRIM)
	# Tüzes rúnák
	_set_pixel_safe(img, 24, 48 + breath, LAVA_CRACK)
	_set_pixel_safe(img, 38, 54 + breath, LAVA_CRACK)
	_set_pixel_safe(img, 20, 64 + breath, LAVA_CRACK)
	_set_pixel_safe(img, 42, 70 + breath, LAVA_CRACK)
	# Karok
	fill_rect(img, 2, 36 + breath, 12, 20, FLAME_ROBE)
	fill_rect(img, 50, 36 + breath, 12, 20, FLAME_ROBE)
	# Tűznyelvek kezekből
	_set_pixel_safe(img, 4, 54 + breath, MAGMA_GLW)
	_set_pixel_safe(img, 6, 56 + breath, Color(1.0, 0.60, 0.10))
	_set_pixel_safe(img, 56, 54 + breath, MAGMA_GLW)
	_set_pixel_safe(img, 54, 56 + breath, Color(1.0, 0.60, 0.10))
	# Fej
	fill_rect(img, 20, 6 + breath, 24, 24, Color(0.78, 0.62, 0.45))
	# Kapucni
	fill_rect(img, 16, 2 + breath, 32, 14, FLAME_ROBE)
	_set_pixel_safe(img, 28, 18 + breath, LAVA_CRACK)
	_set_pixel_safe(img, 36, 18 + breath, LAVA_CRACK)

static func _draw_obsidian_dragon(img: Image, frame_idx: int, anim: String) -> void:
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	var wing_flap := [0, -3, -6, -3][frame_idx % 4]
	draw_shadow(img, 64, 122, 28, 7)
	# Test (top-down sárkány)
	draw_ellipse(img, 64, 74 + breath, 28, 34, OBSIDIAN)
	# Szárnyak kiterítve
	fill_rect(img, 4, 44 + wing_flap + breath, 36, 40, Color(0.08, 0.04, 0.04))
	fill_rect(img, 88, 44 + wing_flap + breath, 36, 40, Color(0.08, 0.04, 0.04))
	# Szárny kezek
	fill_rect(img, 4, 42 + wing_flap + breath, 4, 44, Color(0.10, 0.05, 0.05))
	fill_rect(img, 120, 42 + wing_flap + breath, 4, 44, Color(0.10, 0.05, 0.05))
	# Fej
	fill_rect(img, 52, 20 + breath, 24, 28, OBSIDIAN)
	fill_rect(img, 56, 14 + breath, 16, 10, OBSIDIAN)
	# Izzó repedések
	draw_line_px(img, 50, 60 + breath, 70, 80 + breath, LAVA_CRACK)
	draw_line_px(img, 60, 50 + breath, 80, 70 + breath, LAVA_CRACK)
	draw_line_px(img, 44, 70 + breath, 56, 90 + breath, LAVA_CRACK)
	draw_line_px(img, 72, 64 + breath, 84, 86 + breath, LAVA_CRACK)
	# Szemek
	fill_rect(img, 56, 26 + breath, 4, 3, LAVA_CRACK)
	fill_rect(img, 68, 26 + breath, 4, 3, LAVA_CRACK)
	# Farok
	draw_line_px(img, 64, 106 + breath, 64, 124, OBSIDIAN)
	draw_line_px(img, 65, 106 + breath, 65, 124, OBSIDIAN)
	fill_rect(img, 60, 120, 10, 6, OBSIDIAN)

static func generate_enemy(enemy_name: String, anim: String, frame_idx: int) -> Image:
	var sizes := {
		"magma_slime": Vector2i(48, 48),
		"fire_imp": Vector2i(48, 64),
		"lava_bomber": Vector2i(64, 96),
		"flame_priest": Vector2i(64, 96),
		"obsidian_dragon": Vector2i(128, 128),
	}
	var size: Vector2i = sizes.get(enemy_name, Vector2i(64, 96))
	var img := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match enemy_name:
		"magma_slime":     _draw_magma_slime(img, frame_idx, anim)
		"fire_imp":        _draw_fire_imp(img, frame_idx, anim)
		"lava_bomber":     _draw_lava_bomber(img, frame_idx, anim)
		"flame_priest":    _draw_flame_priest(img, frame_idx, anim)
		"obsidian_dragon": _draw_obsidian_dragon(img, frame_idx, anim)
	draw_outline(img, Color.BLACK)
	return img

static func get_enemy_names() -> Array:
	return ["magma_slime", "fire_imp", "lava_bomber", "flame_priest", "obsidian_dragon"]

static func get_anim_config() -> Dictionary:
	return {"idle": {"frames": 4, "fps": 5, "loop": true}, "walk": {"frames": 4, "fps": 8, "loop": true}, "attack": {"frames": 4, "fps": 10, "loop": false}, "hit": {"frames": 2, "fps": 10, "loop": false}, "death": {"frames": 4, "fps": 7, "loop": false}}

static func export_all(base_path: String) -> void:
	var path := base_path + "volcanic_depths/"
	var anims := get_anim_config()
	for enemy_name in get_enemy_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for i in range(config["frames"]):
				save_png(generate_enemy(enemy_name, anim_name, i), path + "%s/%s_%d.png" % [enemy_name, anim_name, i])
	print("  ✓ Volcanic Depths enemies exported to: ", path)

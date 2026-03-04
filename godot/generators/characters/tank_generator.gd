## TankGenerator - Tank/Guardian class sprite generátor
## 64×96 pixel, 4 irány, 9 animáció
## Nehéz acélpáncél, nagy pajzs, balta/buzogány
class_name TankGenerator
extends PixelArtBase

const W = 64
const H = 96

# Tank paletta
const ARMOR       = Color(0.35, 0.41, 0.47)  # acélszürke páncél
const ARMOR_HI    = Color(0.55, 0.60, 0.65)  # páncél highlight
const ARMOR_DARK  = Color(0.22, 0.26, 0.32)  # páncél árnyék
const GOLD_TRIM   = Color(0.78, 0.57, 0.16)  # arany díszítés
const SKIN        = Color(0.82, 0.68, 0.52)  # bőrszín
const SKIN_DARK   = Color(0.65, 0.50, 0.38)  # bőr árnyék
const HELMET      = Color(0.28, 0.32, 0.38)  # sisak
const SHIELD_COL  = Color(0.30, 0.35, 0.42)  # pajzs szürke
const SHIELD_EMB  = Color(0.70, 0.55, 0.12)  # pajzs embléma arany
const WEAPON_COL  = Color(0.40, 0.38, 0.35)  # fegyver fém
const WEAPON_HI   = Color(0.60, 0.58, 0.55)  # fegyver highlight
const HANDLE      = Color(0.35, 0.22, 0.12)  # fa markolat
const CAPE        = Color(0.10, 0.17, 0.29)  # sötétkék köpeny
const BOOT        = Color(0.20, 0.22, 0.25)  # nehéz csizma
const EYE_COL     = Color(0.20, 0.60, 0.90)  # kék szemek
const EDGE        = Color(0.0, 0.0, 0.0)

static func _draw_body_south(img: Image, breath_y: int = 0, lean_x: int = 0) -> void:
	var ox := lean_x
	var oy := breath_y
	
	draw_shadow(img, 32, 90, 16, 5)
	
	# Nehéz csizmák (szélesebbek)
	fill_rect(img, 14 + ox, 78 + oy, 14, 14, BOOT)
	fill_rect(img, 36 + ox, 78 + oy, 14, 14, BOOT)
	# Csizma fém pántok
	fill_rect(img, 14 + ox, 80 + oy, 14, 2, ARMOR)
	fill_rect(img, 36 + ox, 80 + oy, 14, 2, ARMOR)
	
	# Lábvértek
	fill_rect(img, 16 + ox, 64 + oy, 12, 16, ARMOR)
	fill_rect(img, 36 + ox, 64 + oy, 12, 16, ARMOR)
	fill_rect(img, 16 + ox, 64 + oy, 2, 16, ARMOR_DARK)
	fill_rect(img, 36 + ox, 64 + oy, 2, 16, ARMOR_DARK)
	
	# Köpeny (hátsó kilátszó rész)
	fill_rect(img, 14 + ox, 50 + oy, 36, 24, CAPE)
	
	# Mellvért (széles!)
	fill_rect(img, 12 + ox, 28 + oy, 40, 36, ARMOR)
	# Mellvért árnyék
	fill_rect(img, 12 + ox, 28 + oy, 8, 36, ARMOR_DARK)
	# Mellvért highlight
	fill_rect(img, 40 + ox, 32 + oy, 4, 12, ARMOR_HI)
	# Arany díszítés (V-forma a mellkason)
	draw_line_px(img, 32 + ox, 30 + oy, 20 + ox, 42 + oy, GOLD_TRIM)
	draw_line_px(img, 32 + ox, 30 + oy, 44 + ox, 42 + oy, GOLD_TRIM)
	
	# Váll vértek (kiemelkedő)
	fill_rect(img, 6 + ox, 26 + oy, 14, 12, ARMOR)
	fill_rect(img, 44 + ox, 26 + oy, 14, 12, ARMOR)
	fill_rect(img, 6 + ox, 26 + oy, 14, 2, ARMOR_HI)
	fill_rect(img, 44 + ox, 26 + oy, 14, 2, ARMOR_HI)
	# Arany szegély vállvérteken
	fill_rect(img, 6 + ox, 36 + oy, 14, 2, GOLD_TRIM)
	fill_rect(img, 44 + ox, 36 + oy, 14, 2, GOLD_TRIM)
	
	# Öv
	fill_rect(img, 12 + ox, 58 + oy, 40, 4, HANDLE)
	fill_rect(img, 30 + ox, 58 + oy, 4, 4, GOLD_TRIM)
	
	# Karok
	fill_rect(img, 4 + ox, 36 + oy, 10, 24, ARMOR)
	fill_rect(img, 50 + ox, 36 + oy, 10, 24, ARMOR)
	# Kézfejek (kesztyű)
	fill_rect(img, 4 + ox, 58 + oy, 10, 6, ARMOR_DARK)
	fill_rect(img, 50 + ox, 58 + oy, 10, 6, ARMOR_DARK)
	
	# Pajzs (bal kéz - nagy négyszögletes)
	fill_rect(img, 0 + ox, 34 + oy, 12, 34, SHIELD_COL)
	fill_rect(img, 2 + ox, 36 + oy, 8, 30, ARMOR)
	# Pajzs embléma
	draw_circle(img, 6 + ox, 50 + oy, 3, SHIELD_EMB)
	# Pajzs szegély
	fill_rect(img, 0 + ox, 34 + oy, 12, 2, GOLD_TRIM)
	fill_rect(img, 0 + ox, 66 + oy, 12, 2, GOLD_TRIM)
	
	# Buzogány (jobb kéz)
	fill_rect(img, 54 + ox, 18 + oy, 4, 46, HANDLE)
	# Buzogány fej
	fill_rect(img, 50 + ox, 14 + oy, 12, 10, WEAPON_COL)
	fill_rect(img, 52 + ox, 12 + oy, 8, 4, WEAPON_COL)
	_set_pixel_safe(img, 56 + ox, 14 + oy, WEAPON_HI)
	
	# Nyak (páncélból alig látszik)
	fill_rect(img, 26 + ox, 22 + oy, 12, 8, ARMOR_DARK)
	
	# Sisak
	fill_rect(img, 20 + ox, 4 + oy, 24, 22, HELMET)
	# Sisak highlight
	fill_rect(img, 38 + ox, 6 + oy, 4, 8, ARMOR_HI)
	# Arcnyílás
	fill_rect(img, 24 + ox, 14 + oy, 16, 8, Color(0.05, 0.05, 0.08))
	# Szemek a nyíláson
	_set_pixel_safe(img, 28 + ox, 17 + oy, EYE_COL)
	_set_pixel_safe(img, 29 + ox, 17 + oy, EYE_COL)
	_set_pixel_safe(img, 34 + ox, 17 + oy, EYE_COL)
	_set_pixel_safe(img, 35 + ox, 17 + oy, EYE_COL)
	# Sisak taréj
	fill_rect(img, 30 + ox, 2 + oy, 4, 6, GOLD_TRIM)

static func _draw_body_north(img: Image, breath_y: int = 0, lean_x: int = 0) -> void:
	var ox := lean_x
	var oy := breath_y
	
	draw_shadow(img, 32, 90, 16, 5)
	
	# Csizmák
	fill_rect(img, 14 + ox, 78 + oy, 14, 14, BOOT)
	fill_rect(img, 36 + ox, 78 + oy, 14, 14, BOOT)
	fill_rect(img, 14 + ox, 80 + oy, 14, 2, ARMOR)
	fill_rect(img, 36 + ox, 80 + oy, 14, 2, ARMOR)
	
	# Lábvértek
	fill_rect(img, 16 + ox, 64 + oy, 12, 16, ARMOR)
	fill_rect(img, 36 + ox, 64 + oy, 12, 16, ARMOR)
	
	# Köpeny hátulnézet (nagyobb)
	fill_rect(img, 10 + ox, 28 + oy, 44, 42, CAPE)
	fill_rect(img, 12 + ox, 30 + oy, 40, 38, CAPE)
	# Köpeny redők
	draw_line_px(img, 22 + ox, 32 + oy, 22 + ox, 68 + oy, Color(0.07, 0.12, 0.22))
	draw_line_px(img, 42 + ox, 32 + oy, 42 + ox, 68 + oy, Color(0.07, 0.12, 0.22))
	
	# Váll vértek hátulról
	fill_rect(img, 6 + ox, 26 + oy, 14, 12, ARMOR)
	fill_rect(img, 44 + ox, 26 + oy, 14, 12, ARMOR)
	
	# Sisak hátulról
	fill_rect(img, 20 + ox, 4 + oy, 24, 22, HELMET)
	fill_rect(img, 30 + ox, 2 + oy, 4, 6, GOLD_TRIM)
	
	# Pajzs háton
	fill_rect(img, 16 + ox, 30 + oy, 32, 28, SHIELD_COL)
	fill_rect(img, 18 + ox, 32 + oy, 28, 24, ARMOR)
	draw_circle(img, 32 + ox, 44 + oy, 5, SHIELD_EMB)

static func _draw_body_east(img: Image, breath_y: int = 0, lean_x: int = 0) -> void:
	var ox := lean_x
	var oy := breath_y
	
	draw_shadow(img, 32, 90, 16, 5)
	
	fill_rect(img, 22 + ox, 78 + oy, 16, 14, BOOT)
	fill_rect(img, 22 + ox, 80 + oy, 16, 2, ARMOR)
	
	fill_rect(img, 24 + ox, 64 + oy, 12, 16, ARMOR)
	
	# Köpeny oldalnézet
	fill_rect(img, 14 + ox, 50 + oy, 28, 20, CAPE)
	
	# Mellvért oldalnézet
	fill_rect(img, 16 + ox, 28 + oy, 28, 36, ARMOR)
	fill_rect(img, 16 + ox, 28 + oy, 6, 36, ARMOR_DARK)
	fill_rect(img, 38 + ox, 32 + oy, 4, 12, ARMOR_HI)
	
	# Váll vért
	fill_rect(img, 36 + ox, 26 + oy, 12, 12, ARMOR)
	fill_rect(img, 36 + ox, 26 + oy, 12, 2, ARMOR_HI)
	fill_rect(img, 36 + ox, 36 + oy, 12, 2, GOLD_TRIM)
	
	# Öv
	fill_rect(img, 16 + ox, 58 + oy, 28, 4, HANDLE)
	
	# Kar
	fill_rect(img, 40 + ox, 36 + oy, 10, 24, ARMOR)
	fill_rect(img, 40 + ox, 58 + oy, 10, 6, ARMOR_DARK)
	
	# Pajzs oldalnézet (bal kéz előtt)
	fill_rect(img, 10 + ox, 34 + oy, 6, 30, SHIELD_COL)
	fill_rect(img, 10 + ox, 34 + oy, 6, 2, GOLD_TRIM)
	fill_rect(img, 10 + ox, 62 + oy, 6, 2, GOLD_TRIM)
	
	# Buzogány
	fill_rect(img, 48 + ox, 20 + oy, 4, 44, HANDLE)
	fill_rect(img, 44 + ox, 14 + oy, 12, 10, WEAPON_COL)
	
	# Sisak oldalnézet
	fill_rect(img, 20 + ox, 4 + oy, 22, 22, HELMET)
	fill_rect(img, 36 + ox, 14 + oy, 6, 8, Color(0.05, 0.05, 0.08))
	_set_pixel_safe(img, 38 + ox, 17 + oy, EYE_COL)
	_set_pixel_safe(img, 39 + ox, 17 + oy, EYE_COL)
	fill_rect(img, 30 + ox, 2 + oy, 4, 6, GOLD_TRIM)

# ═══════════════════════════════════════════════════════════════
# ANIMÁCIÓ FRAME GENERÁTOROK
# ═══════════════════════════════════════════════════════════════

static func generate_idle(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var breath := get_breath_offset(frame_idx, 4)
	
	match direction:
		"south": _draw_body_south(img, breath)
		"north": _draw_body_north(img, breath)
		"east":  _draw_body_east(img, breath)
		"west":  return flip_horizontal(generate_idle("east", frame_idx))
	
	# Páncél csillanás az 1. frame-ben
	if frame_idx == 1:
		_set_pixel_safe(img, 42, 34, Color(1.0, 1.0, 1.0, 0.8))
		_set_pixel_safe(img, 43, 35, Color(1.0, 1.0, 1.0, 0.4))
	
	draw_outline(img, EDGE)
	return img

static func generate_walk(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var bob := get_walk_bob(frame_idx, 6)
	var sway := get_walk_sway(frame_idx, 6)
	
	match direction:
		"south": _draw_body_south(img, bob, sway)
		"north": _draw_body_north(img, bob, sway)
		"east":  _draw_body_east(img, bob, sway)
		"west":  return flip_horizontal(generate_walk("east", frame_idx))
	
	draw_outline(img, EDGE)
	return img

static func generate_run(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var bob := get_walk_bob(frame_idx, 6) * 2
	var sway := get_walk_sway(frame_idx, 6)
	
	match direction:
		"south": _draw_body_south(img, bob, sway)
		"north": _draw_body_north(img, bob, sway)
		"east":  _draw_body_east(img, bob, sway)
		"west":  return flip_horizontal(generate_run("east", frame_idx))
	
	draw_outline(img, EDGE)
	return img

static func generate_attack_melee(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var phase := frame_idx % 5
	
	match direction:
		"south":
			_draw_body_south(img)
			match phase:
				0:  # Balta hátra lendítés
					fill_rect(img, 56, 10, 4, 46, HANDLE)
					fill_rect(img, 52, 4, 12, 12, WEAPON_COL)
				1:  # Felső pozíció
					fill_rect(img, 30, 0, 4, 30, HANDLE)
					fill_rect(img, 26, -4, 12, 10, WEAPON_COL)
				2:  # Lecsapás!
					fill_rect(img, 30, 20, 4, 44, HANDLE)
					fill_rect(img, 26, 60, 12, 10, WEAPON_COL)
					# Impact shockwave
					draw_circle(img, 32, 72, 10, Color(1.0, 0.8, 0.3, 0.4))
				3:  # Becsapódás
					fill_rect(img, 28, 40, 4, 30, HANDLE)
					fill_rect(img, 24, 66, 12, 8, WEAPON_COL)
				4:  # Recovery
					fill_rect(img, 54, 18, 4, 46, HANDLE)
					fill_rect(img, 50, 14, 12, 10, WEAPON_COL)
		"north": _draw_body_north(img)
		"east":
			_draw_body_east(img)
			match phase:
				2:  # Horizontal slash
					fill_rect(img, 48, 40, 14, 4, WEAPON_COL)
					fill_rect(img, 50, 36, 4, 14, HANDLE)
		"west": return flip_horizontal(generate_attack_melee("east", frame_idx))
	
	draw_outline(img, EDGE)
	return img

static func generate_attack_ranged(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var phase := frame_idx % 5
	
	match direction:
		"south":
			_draw_body_south(img)
			# Pajzs dobás
			if phase >= 2 and phase <= 3:
				var throw_y := 40 - (phase - 2) * 20
				fill_rect(img, 28, throw_y, 8, 6, SHIELD_COL)
				fill_rect(img, 30, throw_y + 1, 4, 4, SHIELD_EMB)
		"north": _draw_body_north(img)
		"east":  _draw_body_east(img)
		"west":  return flip_horizontal(generate_attack_ranged("east", frame_idx))
	
	draw_outline(img, EDGE)
	return img

static func generate_cast_spell(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var phase := frame_idx % 6
	
	match direction:
		"south":
			_draw_body_south(img)
			if phase >= 2:
				var glow_r := 6 + phase * 3
				draw_circle(img, 8, 48, glow_r, Color(0.2, 0.6, 0.9, 0.4))
				# Pajzs izzás
				fill_rect(img, 0, 34, 12, 34, Color(0.3, 0.7, 1.0, 0.3))
		"north": _draw_body_north(img)
		"east":  _draw_body_east(img)
		"west":  return flip_horizontal(generate_cast_spell("east", frame_idx))
	
	draw_outline(img, EDGE)
	return img

static func generate_hit(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var knockback := [1, 2, 1][frame_idx % 3]
	
	match direction:
		"south":
			_draw_body_south(img, 0, knockback)
			if frame_idx == 0:
				# Pajzs spark
				draw_circle(img, 6, 50, 4, Color(1.0, 0.9, 0.3, 0.7))
		"north": _draw_body_north(img, 0, -knockback)
		"east":  _draw_body_east(img, 0, knockback)
		"west":  return flip_horizontal(generate_hit("east", frame_idx))
	
	draw_outline(img, EDGE)
	return img

static func generate_death(frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var phase := frame_idx % 6
	
	match phase:
		0: _draw_body_south(img)
		1: _draw_body_south(img, 8)
		2: _draw_body_south(img, 16)
		3:
			fill_rect(img, 10, 50, 44, 24, ARMOR)
			fill_rect(img, 14, 48, 20, 12, HELMET)
			fill_rect(img, 46, 56, 12, 10, WEAPON_COL)
		4:
			fill_rect(img, 6, 60, 52, 16, ARMOR)
			fill_rect(img, 10, 58, 18, 8, HELMET)
			fill_rect(img, 50, 62, 12, 8, WEAPON_COL)
		5:
			fill_rect(img, 4, 68, 56, 14, ARMOR)
			fill_rect(img, 8, 66, 16, 6, HELMET)
			fill_rect(img, 2, 72, 8, 14, SHIELD_COL)
			fill_rect(img, 56, 70, 6, 10, WEAPON_COL)
	
	draw_outline(img, EDGE)
	return img

static func generate_dodge_roll(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var phase := frame_idx % 4
	var squish := [0, 2, 4, 2][phase]
	var roll_x := [0, 3, 6, 3][phase]
	
	match direction:
		"south":
			draw_shadow(img, 32 + roll_x, 88, 18, 5)
			draw_ellipse(img, 32 + roll_x, 50 + squish, 20, 22 - squish, ARMOR)
			draw_ellipse(img, 32 + roll_x, 38 + squish, 14, 12, HELMET)
		"north":
			draw_shadow(img, 32 - roll_x, 88, 18, 5)
			draw_ellipse(img, 32 - roll_x, 50 + squish, 20, 22 - squish, CAPE)
			draw_ellipse(img, 32 - roll_x, 38 + squish, 14, 12, HELMET)
		"east":
			draw_shadow(img, 32 + roll_x * 2, 88, 18, 5)
			draw_ellipse(img, 32 + roll_x * 2, 50 + squish, 20, 22 - squish, ARMOR)
			draw_ellipse(img, 32 + roll_x * 2, 38 + squish, 14, 12, HELMET)
		"west": return flip_horizontal(generate_dodge_roll("east", frame_idx))
	
	draw_outline(img, EDGE)
	return img

# ═══════════════════════════════════════════════════════════════
# SPRITEFRAMES BUILDER
# ═══════════════════════════════════════════════════════════════

static func build_all_sprite_frames() -> SpriteFrames:
	var anim_data := {}
	var directions := ["south", "north", "east", "west"]
	
	for dir in directions:
		var frames := []
		for i in range(4): frames.append(to_texture(generate_idle(dir, i)))
		anim_data["idle_" + dir] = {"frames": frames, "fps": 5.0, "loop": true}
	
	for dir in directions:
		var frames := []
		for i in range(6): frames.append(to_texture(generate_walk(dir, i)))
		anim_data["walk_" + dir] = {"frames": frames, "fps": 10.0, "loop": true}
	
	for dir in directions:
		var frames := []
		for i in range(6): frames.append(to_texture(generate_run(dir, i)))
		anim_data["run_" + dir] = {"frames": frames, "fps": 15.0, "loop": true}
	
	for dir in directions:
		var frames := []
		for i in range(5): frames.append(to_texture(generate_attack_melee(dir, i)))
		anim_data["attack_melee_" + dir] = {"frames": frames, "fps": 12.0, "loop": false}
	
	for dir in directions:
		var frames := []
		for i in range(5): frames.append(to_texture(generate_attack_ranged(dir, i)))
		anim_data["attack_ranged_" + dir] = {"frames": frames, "fps": 12.0, "loop": false}
	
	for dir in directions:
		var frames := []
		for i in range(6): frames.append(to_texture(generate_cast_spell(dir, i)))
		anim_data["cast_spell_" + dir] = {"frames": frames, "fps": 12.0, "loop": false}
	
	for dir in directions:
		var frames := []
		for i in range(3): frames.append(to_texture(generate_hit(dir, i)))
		anim_data["hit_" + dir] = {"frames": frames, "fps": 10.0, "loop": false}
	
	var death_frames := []
	for i in range(6): death_frames.append(to_texture(generate_death(i)))
	anim_data["death"] = {"frames": death_frames, "fps": 8.0, "loop": false}
	
	for dir in directions:
		var frames := []
		for i in range(4): frames.append(to_texture(generate_dodge_roll(dir, i)))
		anim_data["dodge_roll_" + dir] = {"frames": frames, "fps": 13.0, "loop": false}
	
	return build_sprite_frames(anim_data)

static func export_all(base_path: String) -> void:
	var directions := ["south", "north", "east", "west"]
	var path := base_path + "tank/"
	
	for dir in directions:
		for i in range(4): save_png(generate_idle(dir, i), path + "idle_%s_%d.png" % [dir, i])
		for i in range(6): save_png(generate_walk(dir, i), path + "walk_%s_%d.png" % [dir, i])
		for i in range(6): save_png(generate_run(dir, i), path + "run_%s_%d.png" % [dir, i])
		for i in range(5): save_png(generate_attack_melee(dir, i), path + "attack_melee_%s_%d.png" % [dir, i])
		for i in range(5): save_png(generate_attack_ranged(dir, i), path + "attack_ranged_%s_%d.png" % [dir, i])
		for i in range(6): save_png(generate_cast_spell(dir, i), path + "cast_spell_%s_%d.png" % [dir, i])
		for i in range(3): save_png(generate_hit(dir, i), path + "hit_%s_%d.png" % [dir, i])
		for i in range(4): save_png(generate_dodge_roll(dir, i), path + "dodge_roll_%s_%d.png" % [dir, i])
	for i in range(6): save_png(generate_death(i), path + "death_%d.png" % i)
	
	print("  ✓ Tank sprites exported to: ", path)

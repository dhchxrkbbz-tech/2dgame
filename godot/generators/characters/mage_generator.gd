## MageGenerator - Mage class sprite generátor
## 64×96 pixel, 4 irány, 9 animáció
## Hosszú sötétkék köpeny, rúnás szegély, kristály bot
class_name MageGenerator
extends PixelArtBase

const W = 64
const H = 96

# Mage paletta
const ROBE       = Color(0.06, 0.12, 0.35)  # sötétkék köpeny
const ROBE_DARK  = Color(0.04, 0.08, 0.25)  # köpeny árnyék
const ROBE_HI    = Color(0.10, 0.18, 0.45)  # köpeny highlight
const RUNE_COL   = Color(0.50, 0.30, 0.80)  # rúna szín
const RUNE_GLOW  = Color(0.70, 0.50, 1.00)  # rúna izzás
const SKIN       = Color(0.88, 0.75, 0.60)  # bőrszín
const SKIN_DARK  = Color(0.72, 0.58, 0.45)  # bőr árnyék
const STAFF_WOOD = Color(0.30, 0.18, 0.08)  # bot fa
const STAFF_DARK = Color(0.20, 0.12, 0.05)  # bot árnyék
const CRYSTAL    = Color(0.50, 0.30, 0.90)  # kristály
const CRYSTAL_GL = Color(0.80, 0.60, 1.00)  # kristály izzás
const HAIR       = Color(0.85, 0.85, 0.90)  # fehér/ezüst haj
const HOOD       = Color(0.05, 0.08, 0.22)  # csuklyás sapka
const STAR_COL   = Color(0.90, 0.85, 0.50)  # csillagminta
const EYE_COL    = Color(0.70, 0.50, 1.00)  # lila szemek
const EDGE       = Color(0.0, 0.0, 0.0)

static func _draw_body_south(img: Image, breath_y: int = 0, lean_x: int = 0) -> void:
	var ox := lean_x
	var oy := breath_y
	
	draw_shadow(img, 32, 90, 13, 4)
	
	# Hosszú köpeny alja (széles, földig ér)
	fill_rect(img, 12 + ox, 72 + oy, 40, 18, ROBE)
	fill_rect(img, 10 + ox, 84 + oy, 44, 6, ROBE_DARK)
	# Rúnás szegély alul
	for i in range(5):
		_set_pixel_safe(img, 14 + i * 8 + ox, 86 + oy, RUNE_COL)
		_set_pixel_safe(img, 16 + i * 8 + ox, 88 + oy, RUNE_COL)
	
	# Köpeny fő test
	fill_rect(img, 16 + ox, 30 + oy, 32, 44, ROBE)
	# Köpeny árnyék
	fill_rect(img, 16 + ox, 30 + oy, 6, 44, ROBE_DARK)
	# Köpeny highlight jobb oldalon
	fill_rect(img, 44 + ox, 34 + oy, 2, 20, ROBE_HI)
	
	# Rúna díszítés a mellkason
	draw_line_px(img, 28 + ox, 34 + oy, 36 + ox, 34 + oy, RUNE_COL)
	draw_line_px(img, 32 + ox, 32 + oy, 32 + ox, 38 + oy, RUNE_COL)
	draw_circle(img, 32 + ox, 36 + oy, 2, RUNE_GLOW)
	
	# Öv (kötél)
	fill_rect(img, 16 + ox, 54 + oy, 32, 3, Color(0.50, 0.40, 0.20))
	
	# Ujjak/karok (bő ujjú köpeny)
	fill_rect(img, 8 + ox, 34 + oy, 10, 24, ROBE)
	fill_rect(img, 46 + ox, 34 + oy, 10, 24, ROBE)
	# Ujj szegélyek
	fill_rect(img, 8 + ox, 56 + oy, 10, 2, RUNE_COL)
	fill_rect(img, 46 + ox, 56 + oy, 10, 2, RUNE_COL)
	
	# Kezek (csupasz)
	fill_rect(img, 8 + ox, 56 + oy, 8, 6, SKIN)
	fill_rect(img, 48 + ox, 56 + oy, 8, 6, SKIN)
	
	# Bot (bal kéz)
	fill_rect(img, 6 + ox, 8 + oy, 4, 80, STAFF_WOOD)
	fill_rect(img, 6 + ox, 8 + oy, 1, 80, STAFF_DARK)
	# Kristály a bot tetején
	fill_rect(img, 3 + ox, 2 + oy, 10, 10, CRYSTAL)
	draw_circle(img, 8 + ox, 7 + oy, 4, CRYSTAL)
	# Kristály izzás
	draw_circle(img, 8 + ox, 7 + oy, 2, CRYSTAL_GL)
	_set_pixel_safe(img, 8 + ox, 6 + oy, Color(1.0, 1.0, 1.0, 0.9))
	
	# Nyak
	fill_rect(img, 26 + ox, 24 + oy, 12, 8, SKIN_DARK)
	
	# Fej
	fill_rect(img, 22 + ox, 8 + oy, 20, 18, SKIN)
	fill_rect(img, 22 + ox, 8 + oy, 4, 18, SKIN_DARK)
	
	# Csuklyás sapka
	fill_rect(img, 18 + ox, 2 + oy, 28, 14, HOOD)
	# Csuklyanyílás
	fill_rect(img, 24 + ox, 10 + oy, 16, 10, SKIN)
	
	# Haj (ezüst, oldalról kilátszik)
	fill_rect(img, 22 + ox, 10 + oy, 4, 14, HAIR)
	fill_rect(img, 38 + ox, 10 + oy, 4, 14, HAIR)
	
	# Csillagos minta a csuklyán
	_set_pixel_safe(img, 26 + ox, 4 + oy, STAR_COL)
	_set_pixel_safe(img, 34 + ox, 6 + oy, STAR_COL)
	_set_pixel_safe(img, 38 + ox, 3 + oy, STAR_COL)
	
	# Szemek
	_set_pixel_safe(img, 28 + ox, 16 + oy, EYE_COL)
	_set_pixel_safe(img, 29 + ox, 16 + oy, EYE_COL)
	_set_pixel_safe(img, 34 + ox, 16 + oy, EYE_COL)
	_set_pixel_safe(img, 35 + ox, 16 + oy, EYE_COL)

static func _draw_body_north(img: Image, breath_y: int = 0, lean_x: int = 0) -> void:
	var ox := lean_x
	var oy := breath_y
	
	draw_shadow(img, 32, 90, 13, 4)
	
	# Köpeny alja
	fill_rect(img, 12 + ox, 72 + oy, 40, 18, ROBE)
	fill_rect(img, 10 + ox, 84 + oy, 44, 6, ROBE_DARK)
	
	# Köpeny test hátulnézet
	fill_rect(img, 16 + ox, 30 + oy, 32, 44, ROBE)
	# Redők
	draw_line_px(img, 24 + ox, 34 + oy, 24 + ox, 72 + oy, ROBE_DARK)
	draw_line_px(img, 40 + ox, 34 + oy, 40 + ox, 72 + oy, ROBE_DARK)
	# Rúna szegély hátul
	for i in range(6):
		_set_pixel_safe(img, 18 + i * 5 + ox, 74 + oy, RUNE_COL)
	
	# Karok
	fill_rect(img, 8 + ox, 34 + oy, 10, 24, ROBE)
	fill_rect(img, 46 + ox, 34 + oy, 10, 24, ROBE)
	
	# Bot hátulnézet
	fill_rect(img, 6 + ox, 8 + oy, 4, 80, STAFF_WOOD)
	fill_rect(img, 3 + ox, 2 + oy, 10, 10, CRYSTAL)
	draw_circle(img, 8 + ox, 7 + oy, 3, CRYSTAL_GL)
	
	# Csuklya hátulnézet
	fill_rect(img, 18 + ox, 2 + oy, 28, 26, HOOD)
	draw_line_px(img, 32 + ox, 4 + oy, 32 + ox, 26 + oy, ROBE_DARK)
	# Csillagok
	_set_pixel_safe(img, 28 + ox, 8 + oy, STAR_COL)
	_set_pixel_safe(img, 36 + ox, 12 + oy, STAR_COL)

static func _draw_body_east(img: Image, breath_y: int = 0, lean_x: int = 0) -> void:
	var ox := lean_x
	var oy := breath_y
	
	draw_shadow(img, 32, 90, 13, 4)
	
	# Köpeny alja
	fill_rect(img, 16 + ox, 72 + oy, 28, 18, ROBE)
	fill_rect(img, 14 + ox, 84 + oy, 32, 6, ROBE_DARK)
	
	# Köpeny test oldalnézet
	fill_rect(img, 18 + ox, 30 + oy, 24, 44, ROBE)
	fill_rect(img, 18 + ox, 30 + oy, 4, 44, ROBE_DARK)
	
	# Kar
	fill_rect(img, 38 + ox, 34 + oy, 10, 24, ROBE)
	fill_rect(img, 38 + ox, 56 + oy, 10, 2, RUNE_COL)
	fill_rect(img, 40 + ox, 56 + oy, 8, 6, SKIN)
	
	# Bot
	fill_rect(img, 12 + ox, 8 + oy, 4, 80, STAFF_WOOD)
	fill_rect(img, 9 + ox, 2 + oy, 10, 10, CRYSTAL)
	draw_circle(img, 14 + ox, 7 + oy, 3, CRYSTAL_GL)
	_set_pixel_safe(img, 14 + ox, 6 + oy, Color(1.0, 1.0, 1.0, 0.9))
	
	# Csuklya oldalnézet
	fill_rect(img, 20 + ox, 2 + oy, 22, 18, HOOD)
	fill_rect(img, 36 + ox, 10 + oy, 6, 10, SKIN)
	
	# Haj
	fill_rect(img, 20 + ox, 10 + oy, 4, 14, HAIR)
	
	# Szem
	_set_pixel_safe(img, 38 + ox, 16 + oy, EYE_COL)
	_set_pixel_safe(img, 39 + ox, 16 + oy, EYE_COL)

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
	
	# Rúna izzás pulsálás frame alapján
	if frame_idx == 1 or frame_idx == 2:
		draw_circle(img, 8, 7, 5, Color(CRYSTAL_GL.r, CRYSTAL_GL.g, CRYSTAL_GL.b, 0.3))
	
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
			# Bot ütés
			match phase:
				0: pass # Alap pozíció
				1:  # Bot felemelés
					fill_rect(img, 4, 2, 4, 80, STAFF_WOOD)
				2:  # Lecsapás
					fill_rect(img, 28, 10, 4, 70, STAFF_WOOD)
					fill_rect(img, 25, 4, 10, 10, CRYSTAL)
					draw_circle(img, 30, 9, 4, CRYSTAL_GL)
					# Arcane impact
					draw_circle(img, 30, 78, 8, RUNE_GLOW)
				3, 4: pass
		"north": _draw_body_north(img)
		"east":  _draw_body_east(img)
		"west":  return flip_horizontal(generate_attack_melee("east", frame_idx))
	
	draw_outline(img, EDGE)
	return img

static func generate_attack_ranged(direction: String, frame_idx: int) -> Image:
	return generate_cast_spell(direction, frame_idx)

static func generate_cast_spell(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var phase := frame_idx % 6
	
	match direction:
		"south":
			_draw_body_south(img)
			# Energy gathering fázisok
			match phase:
				0: pass
				1:
					# Kézfej izzás
					draw_circle(img, 50, 56, 4, RUNE_GLOW)
				2:
					# Energia gyűlés
					draw_circle(img, 50, 50, 6, Color(RUNE_COL.r, RUNE_COL.g, RUNE_COL.b, 0.5))
					draw_circle(img, 50, 50, 3, RUNE_GLOW)
				3:
					# Nagyobb energia gömb
					draw_circle(img, 50, 46, 10, Color(RUNE_COL.r, RUNE_COL.g, RUNE_COL.b, 0.6))
					draw_circle(img, 50, 46, 5, CRYSTAL_GL)
					# Bot kristály is izzik
					draw_circle(img, 8, 7, 6, Color(CRYSTAL_GL.r, CRYSTAL_GL.g, CRYSTAL_GL.b, 0.5))
				4:
					# Kilövés
					draw_circle(img, 50, 40, 12, Color(RUNE_COL.r, RUNE_COL.g, RUNE_COL.b, 0.7))
					draw_circle(img, 50, 40, 6, Color(1.0, 1.0, 1.0, 0.8))
					# Energia sugarak
					for i in range(6):
						var angle := float(i) * TAU / 6.0
						var px := int(50 + cos(angle) * 14)
						var py := int(40 + sin(angle) * 10)
						_set_pixel_safe(img, px, py, RUNE_GLOW)
				5:
					# Utó-izzás
					draw_circle(img, 50, 42, 6, Color(RUNE_COL.r, RUNE_COL.g, RUNE_COL.b, 0.3))
		"north": _draw_body_north(img)
		"east":
			_draw_body_east(img)
			if phase >= 2 and phase <= 4:
				var cast_x := 48 + (phase - 2) * 4
				draw_circle(img, cast_x, 48, 5 + phase * 2, Color(RUNE_COL.r, RUNE_COL.g, RUNE_COL.b, 0.5))
		"west": return flip_horizontal(generate_cast_spell("east", frame_idx))
	
	draw_outline(img, EDGE)
	return img

static func generate_hit(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var knockback := [3, 5, 2][frame_idx % 3]
	
	match direction:
		"south":
			_draw_body_south(img, 0, knockback)
			if frame_idx == 0:
				fill_rect(img, 16, 30, 32, 44, Color(1.0, 0.2, 0.1, 0.25))
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
		0:
			_draw_body_south(img)
			fill_rect(img, 16, 30, 32, 44, Color(1.0, 0.1, 0.0, 0.3))
		1: _draw_body_south(img, 8)
		2: _draw_body_south(img, 18)
		3:
			# Összerogy
			fill_rect(img, 12, 54, 40, 22, ROBE)
			fill_rect(img, 14, 50, 20, 10, HOOD)
			fill_rect(img, 2, 50, 4, 40, STAFF_WOOD)
			fill_rect(img, 0, 44, 8, 8, CRYSTAL)
		4:
			fill_rect(img, 8, 64, 48, 16, ROBE)
			fill_rect(img, 10, 60, 18, 8, HOOD)
			fill_rect(img, 0, 56, 4, 36, STAFF_WOOD)
		5:
			# Földön
			fill_rect(img, 4, 70, 56, 12, ROBE)
			fill_rect(img, 6, 68, 14, 6, HOOD)
			fill_rect(img, 56, 72, 6, 4, SKIN)
			# Bot mellett
			fill_rect(img, 0, 64, 4, 28, STAFF_WOOD)
			fill_rect(img, -2, 60, 8, 8, CRYSTAL)
			# Rúna halvány utóizzás
			draw_circle(img, 2, 64, 4, Color(RUNE_GLOW.r, RUNE_GLOW.g, RUNE_GLOW.b, 0.3))
	
	draw_outline(img, EDGE)
	return img

static func generate_dodge_roll(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var phase := frame_idx % 4
	var squish := [0, 3, 5, 2][phase]
	var roll_x := [0, 4, 8, 4][phase]
	
	match direction:
		"south":
			draw_shadow(img, 32 + roll_x, 88, 14, 4)
			draw_ellipse(img, 32 + roll_x, 50 + squish, 16, 22 - squish, ROBE)
			draw_ellipse(img, 32 + roll_x, 38 + squish, 12, 10, HOOD)
			# Arcane trail
			if phase >= 1:
				draw_circle(img, 32 + roll_x - 6, 50 + squish, 4, Color(RUNE_COL.r, RUNE_COL.g, RUNE_COL.b, 0.3))
		"north":
			draw_shadow(img, 32 - roll_x, 88, 14, 4)
			draw_ellipse(img, 32 - roll_x, 50 + squish, 16, 22 - squish, ROBE)
			draw_ellipse(img, 32 - roll_x, 38 + squish, 12, 10, HOOD)
		"east":
			draw_shadow(img, 32 + roll_x * 2, 88, 14, 4)
			draw_ellipse(img, 32 + roll_x * 2, 50 + squish, 16, 22 - squish, ROBE)
			draw_ellipse(img, 32 + roll_x * 2, 38 + squish, 12, 10, HOOD)
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
	var path := base_path + "mage/"
	
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
	
	print("  ✓ Mage sprites exported to: ", path)

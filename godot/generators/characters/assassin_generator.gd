## AssassinGenerator - Assassin class sprite generátor
## 64×96 pixel, 4 irány, 9 animáció
## Kapucnis köpeny, sötétlila/fekete, két tőr
class_name AssassinGenerator
extends PixelArtBase

const W = 64
const H = 96

# Assassin paletta
const CLOAK      = Color(0.18, 0.08, 0.28)  # sötétlila köpeny
const CLOAK_DARK = Color(0.12, 0.05, 0.20)  # köpeny árnyék
const HOOD       = Color(0.08, 0.04, 0.12)  # fekete kapucni
const SKIN       = Color(0.85, 0.70, 0.55)  # bőrszín
const SKIN_DARK  = Color(0.70, 0.55, 0.40)  # bőr árnyék
const BLADE      = Color(0.70, 0.72, 0.75)  # ezüst penge
const BLADE_HI   = Color(0.90, 0.92, 0.95)  # penge highlight
const BELT_COL   = Color(0.30, 0.15, 0.08)  # bőr öv
const BOOT       = Color(0.10, 0.06, 0.14)  # csizma
const EYE_COL    = Color(0.60, 0.20, 0.80)  # lila szemek
const EDGE       = Color(0.0, 0.0, 0.0)     # fekete outline

# ═══════════════════════════════════════════════════════════════
# SOUTH FACING (alapnézet)
# ═══════════════════════════════════════════════════════════════

static func _draw_body_south(img: Image, breath_y: int = 0, lean_x: int = 0) -> void:
	var ox := lean_x
	var oy := breath_y
	
	# Árnyék a lábak alatt
	draw_shadow(img, 32, 90, 14, 4)
	
	# Csizmák
	fill_rect(img, 18 + ox, 78 + oy, 10, 12, BOOT)
	fill_rect(img, 36 + ox, 78 + oy, 10, 12, BOOT)
	
	# Lábak (köpeny alól kilátszó nadrág)
	fill_rect(img, 20 + ox, 68 + oy, 8, 12, CLOAK_DARK)
	fill_rect(img, 36 + ox, 68 + oy, 8, 12, CLOAK_DARK)
	
	# Köpeny (fő test)
	fill_rect(img, 16 + ox, 30 + oy, 32, 40, CLOAK)
	# Köpeny árnyék (bal oldal)
	fill_rect(img, 16 + ox, 30 + oy, 6, 40, CLOAK_DARK)
	# Köpeny szegély alul
	fill_rect(img, 14 + ox, 66 + oy, 36, 4, CLOAK_DARK)
	
	# Öv
	fill_rect(img, 16 + ox, 50 + oy, 32, 4, BELT_COL)
	# Öv csat (arany)
	fill_rect(img, 30 + ox, 50 + oy, 4, 4, Color(0.75, 0.60, 0.15))
	
	# Karok (köpennyel fedve)
	fill_rect(img, 10 + ox, 34 + oy, 8, 26, CLOAK)
	fill_rect(img, 46 + ox, 34 + oy, 8, 26, CLOAK)
	
	# Kezek (bőr)
	fill_rect(img, 10 + ox, 58 + oy, 8, 6, SKIN)
	fill_rect(img, 46 + ox, 58 + oy, 8, 6, SKIN)
	
	# Tőrök a kezekben
	# Bal tőr
	fill_rect(img, 12 + ox, 62 + oy, 4, 12, BLADE)
	_set_pixel_safe(img, 13 + ox, 63 + oy, BLADE_HI)
	# Jobb tőr
	fill_rect(img, 48 + ox, 62 + oy, 4, 12, BLADE)
	_set_pixel_safe(img, 49 + ox, 63 + oy, BLADE_HI)
	
	# Nyak
	fill_rect(img, 26 + ox, 26 + oy, 12, 6, SKIN_DARK)
	
	# Fej
	fill_rect(img, 22 + ox, 8 + oy, 20, 20, SKIN)
	# Arc árnyék
	fill_rect(img, 22 + ox, 8 + oy, 4, 20, SKIN_DARK)
	
	# Kapucni
	fill_rect(img, 18 + ox, 4 + oy, 28, 18, HOOD)
	# Kapucni nyílás (arc látható)
	fill_rect(img, 24 + ox, 12 + oy, 16, 10, SKIN)
	
	# Szemek
	_set_pixel_safe(img, 28 + ox, 16 + oy, EYE_COL)
	_set_pixel_safe(img, 29 + ox, 16 + oy, EYE_COL)
	_set_pixel_safe(img, 34 + ox, 16 + oy, EYE_COL)
	_set_pixel_safe(img, 35 + ox, 16 + oy, EYE_COL)

static func _draw_body_north(img: Image, breath_y: int = 0, lean_x: int = 0) -> void:
	var ox := lean_x
	var oy := breath_y
	
	draw_shadow(img, 32, 90, 14, 4)
	
	# Csizmák
	fill_rect(img, 18 + ox, 78 + oy, 10, 12, BOOT)
	fill_rect(img, 36 + ox, 78 + oy, 10, 12, BOOT)
	
	# Lábak
	fill_rect(img, 20 + ox, 68 + oy, 8, 12, CLOAK_DARK)
	fill_rect(img, 36 + ox, 68 + oy, 8, 12, CLOAK_DARK)
	
	# Köpeny hátulnézet
	fill_rect(img, 16 + ox, 30 + oy, 32, 40, CLOAK)
	fill_rect(img, 16 + ox, 30 + oy, 32, 8, CLOAK_DARK)
	fill_rect(img, 14 + ox, 66 + oy, 36, 4, CLOAK_DARK)
	
	# Öv hátulról
	fill_rect(img, 16 + ox, 50 + oy, 32, 4, BELT_COL)
	
	# Karok
	fill_rect(img, 10 + ox, 34 + oy, 8, 26, CLOAK)
	fill_rect(img, 46 + ox, 34 + oy, 8, 26, CLOAK)
	fill_rect(img, 10 + ox, 58 + oy, 8, 6, SKIN)
	fill_rect(img, 46 + ox, 58 + oy, 8, 6, SKIN)
	
	# Tőrök
	fill_rect(img, 12 + ox, 62 + oy, 4, 12, BLADE)
	fill_rect(img, 48 + ox, 62 + oy, 4, 12, BLADE)
	
	# Kapucni hátulról (teljes)
	fill_rect(img, 18 + ox, 4 + oy, 28, 26, HOOD)
	# Kapucni redő
	draw_line_px(img, 32 + ox, 6 + oy, 32 + ox, 28 + oy, CLOAK_DARK)

static func _draw_body_east(img: Image, breath_y: int = 0, lean_x: int = 0) -> void:
	var ox := lean_x
	var oy := breath_y
	
	draw_shadow(img, 32, 90, 14, 4)
	
	# Csizmák
	fill_rect(img, 24 + ox, 78 + oy, 12, 12, BOOT)
	
	# Láb
	fill_rect(img, 26 + ox, 68 + oy, 8, 12, CLOAK_DARK)
	
	# Köpeny oldalnézet
	fill_rect(img, 20 + ox, 30 + oy, 24, 40, CLOAK)
	fill_rect(img, 20 + ox, 30 + oy, 6, 40, CLOAK_DARK)
	fill_rect(img, 18 + ox, 66 + oy, 28, 4, CLOAK_DARK)
	
	# Öv
	fill_rect(img, 20 + ox, 50 + oy, 24, 4, BELT_COL)
	
	# Kar (előtte)
	fill_rect(img, 40 + ox, 34 + oy, 8, 26, CLOAK)
	fill_rect(img, 40 + ox, 58 + oy, 8, 6, SKIN)
	# Tőr
	fill_rect(img, 42 + ox, 62 + oy, 4, 12, BLADE)
	
	# Nyak
	fill_rect(img, 28 + ox, 26 + oy, 8, 6, SKIN_DARK)
	
	# Fej oldalnézet
	fill_rect(img, 24 + ox, 8 + oy, 16, 20, SKIN)
	
	# Kapucni oldalnézet
	fill_rect(img, 20 + ox, 4 + oy, 22, 18, HOOD)
	fill_rect(img, 34 + ox, 12 + oy, 8, 10, SKIN)
	
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
		"south":
			_draw_body_south(img, breath)
		"north":
			_draw_body_north(img, breath)
		"east":
			_draw_body_east(img, breath)
		"west":
			var east_img := generate_idle("east", frame_idx)
			return flip_horizontal(east_img)
	
	draw_outline(img, EDGE)
	return img

static func generate_walk(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var bob := get_walk_bob(frame_idx, 6)
	var sway := get_walk_sway(frame_idx, 6)
	
	# Láb animáció: váltakozó lépés pozíciók
	var leg_offsets := [
		[0, 4], [-2, 8], [-4, 4], [0, -4], [2, -8], [4, -4]
	]
	var leg := leg_offsets[frame_idx % 6]
	
	match direction:
		"south":
			draw_shadow(img, 32, 90, 14, 4)
			# Csizmák animált pozícióban
			fill_rect(img, 18 + leg[0], 78 + bob, 10, 12, BOOT)
			fill_rect(img, 36 - leg[0], 78 + bob + leg[1] / 2, 10, 12, BOOT)
			# Lábak
			fill_rect(img, 20 + leg[0], 68 + bob, 8, 12, CLOAK_DARK)
			fill_rect(img, 36 - leg[0], 68 + bob, 8, 12, CLOAK_DARK)
			# Felső test
			_draw_body_south(img, bob, sway)
			# Felülírjuk az alsó részt a walk lábakkal
		"north":
			_draw_body_north(img, bob, sway)
		"east":
			_draw_body_east(img, bob, sway)
		"west":
			var east_img := generate_walk("east", frame_idx)
			return flip_horizontal(east_img)
	
	draw_outline(img, EDGE)
	return img

static func generate_run(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var bob := get_walk_bob(frame_idx, 6) * 2  # Erősebb mozgás
	var sway := get_walk_sway(frame_idx, 6)
	
	match direction:
		"south":
			_draw_body_south(img, bob, sway)
		"north":
			_draw_body_north(img, bob, sway)
		"east":
			_draw_body_east(img, bob, sway)
		"west":
			var east_img := generate_run("east", frame_idx)
			return flip_horizontal(east_img)
	
	draw_outline(img, EDGE)
	return img

static func generate_attack_melee(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# 5 frame: anticipation, lendület, ütés, slash, recovery
	var attack_phase := frame_idx % 5
	
	match direction:
		"south":
			_draw_body_south(img)
			# Tőr pozíciók a támadás fázisai szerint
			match attack_phase:
				0:  # Anticipation - kar hátra
					fill_rect(img, 6, 40, 4, 14, BLADE)
				1:  # Lendület
					fill_rect(img, 8, 30, 4, 14, BLADE)
				2:  # Ütés - slash arc
					fill_rect(img, 12, 24, 4, 14, BLADE)
					# Slash arc effect
					draw_line_px(img, 10, 20, 50, 40, Color(0.9, 0.9, 1.0, 0.7))
					draw_line_px(img, 12, 22, 52, 42, Color(0.9, 0.9, 1.0, 0.5))
				3:  # Második tőr slash
					fill_rect(img, 48, 24, 4, 14, BLADE)
					draw_line_px(img, 54, 20, 14, 40, Color(0.9, 0.9, 1.0, 0.7))
				4:  # Recovery
					fill_rect(img, 10, 58, 4, 12, BLADE)
					fill_rect(img, 48, 58, 4, 12, BLADE)
		"north":
			_draw_body_north(img)
		"east":
			_draw_body_east(img)
			match attack_phase:
				2:
					fill_rect(img, 50, 30, 12, 4, BLADE)
					_set_pixel_safe(img, 61, 31, BLADE_HI)
				3:
					fill_rect(img, 52, 24, 10, 4, BLADE)
		"west":
			var east_img := generate_attack_melee("east", frame_idx)
			return flip_horizontal(east_img)
	
	draw_outline(img, EDGE)
	return img

static func generate_attack_ranged(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var phase := frame_idx % 5
	
	match direction:
		"south":
			_draw_body_south(img)
			if phase == 2 or phase == 3:
				# Tőr dobás - repülő tőr
				var throw_x := 32 + (phase - 2) * 20
				fill_rect(img, throw_x, 20, 4, 10, BLADE)
				_set_pixel_safe(img, throw_x + 1, 20, BLADE_HI)
		"north":
			_draw_body_north(img)
		"east":
			_draw_body_east(img)
		"west":
			var east_img := generate_attack_ranged("east", frame_idx)
			return flip_horizontal(east_img)
	
	draw_outline(img, EDGE)
	return img

static func generate_cast_spell(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var phase := frame_idx % 6
	
	match direction:
		"south":
			_draw_body_south(img)
			# Shadow energy gathering
			if phase >= 2:
				var intensity := float(phase - 1) / 4.0
				var aura_col := Color(0.4, 0.1, 0.6, intensity * 0.6)
				draw_circle(img, 32, 45, 8 + phase * 2, aura_col)
			if phase >= 4:
				# Energy release
				for i in range(4):
					var angle := float(i) * TAU / 4.0 + float(phase) * 0.5
					var px := int(32 + cos(angle) * 16)
					var py := int(45 + sin(angle) * 12)
					draw_circle(img, px, py, 3, Color(0.6, 0.2, 0.9, 0.8))
		"north":
			_draw_body_north(img)
		"east":
			_draw_body_east(img)
		"west":
			var east_img := generate_cast_spell("east", frame_idx)
			return flip_horizontal(east_img)
	
	draw_outline(img, EDGE)
	return img

static func generate_hit(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var knockback := [2, 4, 1][frame_idx % 3]
	
	match direction:
		"south":
			_draw_body_south(img, 0, knockback)
			# Vörös flash overlay
			if frame_idx == 0:
				fill_rect(img, 16, 30, 32, 40, Color(1.0, 0.2, 0.1, 0.3))
		"north":
			_draw_body_north(img, 0, -knockback)
		"east":
			_draw_body_east(img, 0, knockback)
		"west":
			var east_img := generate_hit("east", frame_idx)
			return flip_horizontal(east_img)
	
	draw_outline(img, EDGE)
	return img

static func generate_death(frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# 6 frame: álló → térdre → oldalra → földön
	var phase := frame_idx % 6
	
	match phase:
		0:  # Álló, hit becsapódás
			_draw_body_south(img)
			fill_rect(img, 16, 30, 32, 40, Color(1.0, 0.1, 0.0, 0.3))
		1:  # Térdre esés
			_draw_body_south(img, 10)
		2:  # Összerogyás
			_draw_body_south(img, 20)
		3:  # Oldalt dőlés
			# Összerogyott alak
			fill_rect(img, 12, 50, 40, 20, CLOAK)
			fill_rect(img, 14, 48, 16, 10, HOOD)
			fill_rect(img, 10, 60, 8, 6, SKIN)
			fill_rect(img, 46, 60, 8, 6, SKIN)
		4:  # Majdnem földön
			fill_rect(img, 8, 60, 48, 14, CLOAK)
			fill_rect(img, 10, 58, 16, 8, HOOD)
			fill_rect(img, 8, 68, 6, 4, SKIN)
		5:  # Földön fekve
			fill_rect(img, 6, 66, 52, 12, CLOAK)
			fill_rect(img, 8, 64, 14, 6, HOOD)
			fill_rect(img, 54, 68, 6, 4, SKIN)
			# Tőrök szanaszét
			fill_rect(img, 2, 70, 4, 8, BLADE)
			fill_rect(img, 58, 66, 4, 8, BLADE)
	
	draw_outline(img, EDGE)
	return img

static func generate_dodge_roll(direction: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var phase := frame_idx % 4
	
	# Összegömbölyödött alak
	var squish := [0, 2, 4, 2][phase]
	var roll_x := [0, 4, 8, 4][phase]
	
	match direction:
		"south":
			draw_shadow(img, 32 + roll_x, 88, 16, 5)
			draw_ellipse(img, 32 + roll_x, 50 + squish, 16, 20 - squish, CLOAK)
			draw_ellipse(img, 32 + roll_x, 40 + squish, 12, 10, HOOD)
		"north":
			draw_shadow(img, 32 - roll_x, 88, 16, 5)
			draw_ellipse(img, 32 - roll_x, 50 + squish, 16, 20 - squish, CLOAK)
			draw_ellipse(img, 32 - roll_x, 40 + squish, 12, 10, HOOD)
		"east":
			draw_shadow(img, 32 + roll_x * 2, 88, 16, 5)
			draw_ellipse(img, 32 + roll_x * 2, 50 + squish, 16, 20 - squish, CLOAK)
			draw_ellipse(img, 32 + roll_x * 2, 40 + squish, 12, 10, HOOD)
		"west":
			var east_img := generate_dodge_roll("east", frame_idx)
			return flip_horizontal(east_img)
	
	draw_outline(img, EDGE)
	return img

# ═══════════════════════════════════════════════════════════════
# SPRITEFRAMES BUILDER
# ═══════════════════════════════════════════════════════════════

static func build_all_sprite_frames() -> SpriteFrames:
	var anim_data := {}
	var directions := ["south", "north", "east", "west"]
	
	# Idle - 4 frame, 5 fps, loop
	for dir in directions:
		var frames := []
		for i in range(4):
			frames.append(to_texture(generate_idle(dir, i)))
		anim_data["idle_" + dir] = {"frames": frames, "fps": 5.0, "loop": true}
	
	# Walk - 6 frame, 10 fps, loop
	for dir in directions:
		var frames := []
		for i in range(6):
			frames.append(to_texture(generate_walk(dir, i)))
		anim_data["walk_" + dir] = {"frames": frames, "fps": 10.0, "loop": true}
	
	# Run - 6 frame, 15 fps, loop
	for dir in directions:
		var frames := []
		for i in range(6):
			frames.append(to_texture(generate_run(dir, i)))
		anim_data["run_" + dir] = {"frames": frames, "fps": 15.0, "loop": true}
	
	# Attack melee - 5 frame, 12 fps, no loop
	for dir in directions:
		var frames := []
		for i in range(5):
			frames.append(to_texture(generate_attack_melee(dir, i)))
		anim_data["attack_melee_" + dir] = {"frames": frames, "fps": 12.0, "loop": false}
	
	# Attack ranged - 5 frame, 12 fps, no loop
	for dir in directions:
		var frames := []
		for i in range(5):
			frames.append(to_texture(generate_attack_ranged(dir, i)))
		anim_data["attack_ranged_" + dir] = {"frames": frames, "fps": 12.0, "loop": false}
	
	# Cast spell - 6 frame, 12 fps, no loop
	for dir in directions:
		var frames := []
		for i in range(6):
			frames.append(to_texture(generate_cast_spell(dir, i)))
		anim_data["cast_spell_" + dir] = {"frames": frames, "fps": 12.0, "loop": false}
	
	# Hit - 3 frame, 10 fps, no loop
	for dir in directions:
		var frames := []
		for i in range(3):
			frames.append(to_texture(generate_hit(dir, i)))
		anim_data["hit_" + dir] = {"frames": frames, "fps": 10.0, "loop": false}
	
	# Death - 6 frame, 8 fps, no loop (csak south)
	var death_frames := []
	for i in range(6):
		death_frames.append(to_texture(generate_death(i)))
	anim_data["death"] = {"frames": death_frames, "fps": 8.0, "loop": false}
	
	# Dodge roll - 4 frame, 13 fps, no loop
	for dir in directions:
		var frames := []
		for i in range(4):
			frames.append(to_texture(generate_dodge_roll(dir, i)))
		anim_data["dodge_roll_" + dir] = {"frames": frames, "fps": 13.0, "loop": false}
	
	return build_sprite_frames(anim_data)

static func export_all(base_path: String) -> void:
	var directions := ["south", "north", "east", "west"]
	var path := base_path + "assassin/"
	
	for dir in directions:
		for i in range(4):
			save_png(generate_idle(dir, i), path + "idle_%s_%d.png" % [dir, i])
		for i in range(6):
			save_png(generate_walk(dir, i), path + "walk_%s_%d.png" % [dir, i])
		for i in range(6):
			save_png(generate_run(dir, i), path + "run_%s_%d.png" % [dir, i])
		for i in range(5):
			save_png(generate_attack_melee(dir, i), path + "attack_melee_%s_%d.png" % [dir, i])
		for i in range(5):
			save_png(generate_attack_ranged(dir, i), path + "attack_ranged_%s_%d.png" % [dir, i])
		for i in range(6):
			save_png(generate_cast_spell(dir, i), path + "cast_spell_%s_%d.png" % [dir, i])
		for i in range(3):
			save_png(generate_hit(dir, i), path + "hit_%s_%d.png" % [dir, i])
		for i in range(4):
			save_png(generate_dodge_roll(dir, i), path + "dodge_roll_%s_%d.png" % [dir, i])
	
	for i in range(6):
		save_png(generate_death(i), path + "death_%d.png" % i)
	
	print("  ✓ Assassin sprites exported to: ", path)

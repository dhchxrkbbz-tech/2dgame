## SkillIconGenerator - Skill ikonok (48 db, 32×32)
## 9 branch × 5 skill + 3 ultimate = 48
class_name SkillIconGenerator
extends PixelArtBase

const SKILL_BRANCHES := {
	"shadow_blade": {
		"color": Color(0.20, 0.10, 0.25),
		"accent": Color(0.50, 0.20, 0.60),
		"skills": ["shadow_strike", "blade_dance", "phantom_step", "dark_chain", "void_slash"],
		"ultimate": "shadow_annihilation",
	},
	"poison_mastery": {
		"color": Color(0.10, 0.25, 0.08),
		"accent": Color(0.30, 0.70, 0.15),
		"skills": ["poison_dart", "toxic_cloud", "venom_coat", "plague_spread", "acid_rain"],
		"ultimate": "pandemic",
	},
	"trap_craft": {
		"color": Color(0.30, 0.20, 0.08),
		"accent": Color(0.65, 0.45, 0.15),
		"skills": ["spike_trap", "net_throw", "mine_plant", "snare_wire", "explosive_barrel"],
		"ultimate": "death_zone",
	},
	"holy_shield": {
		"color": Color(0.65, 0.60, 0.30),
		"accent": Color(0.90, 0.85, 0.40),
		"skills": ["shield_bash", "holy_barrier", "divine_guard", "aura_protect", "unbreakable"],
		"ultimate": "invincible_fortress",
	},
	"war_cry": {
		"color": Color(0.50, 0.15, 0.08),
		"accent": Color(0.85, 0.30, 0.10),
		"skills": ["battle_shout", "taunt", "rage_blow", "war_stomp", "berserker"],
		"ultimate": "warlord_fury",
	},
	"fortify": {
		"color": Color(0.35, 0.30, 0.25),
		"accent": Color(0.55, 0.50, 0.42),
		"skills": ["iron_skin", "stone_wall", "thorns_aura", "endure_pain", "last_stand"],
		"ultimate": "titan_form",
	},
	"arcane_fire": {
		"color": Color(0.55, 0.15, 0.05),
		"accent": Color(0.95, 0.45, 0.10),
		"skills": ["fireball", "flame_wave", "meteor", "inferno_ring", "fire_storm"],
		"ultimate": "apocalypse_flame",
	},
	"frost_magic": {
		"color": Color(0.20, 0.40, 0.65),
		"accent": Color(0.50, 0.80, 1.00),
		"skills": ["ice_bolt", "frost_nova", "blizzard", "ice_wall", "frozen_orb"],
		"ultimate": "absolute_zero",
	},
	"dark_arts": {
		"color": Color(0.15, 0.05, 0.20),
		"accent": Color(0.45, 0.15, 0.60),
		"skills": ["drain_life", "curse", "summon_undead", "shadow_bolt", "soul_harvest"],
		"ultimate": "death_incarnate",
	},
}

static func gen_skill_icon(branch: String, skill_index: int) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var b: Dictionary = SKILL_BRANCHES.get(branch, SKILL_BRANCHES["arcane_fire"])
	# Háttér
	img.fill(b["color"])
	# Kerek keret
	draw_circle_outline(img, 16, 16, 14, b["accent"])
	draw_circle_outline(img, 16, 16, 13, b["accent"].darkened(0.2))
	# Skill-specifikus szimbólum
	_draw_skill_symbol(img, branch, skill_index, b["accent"])
	return img

static func gen_ultimate_icon(branch: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var b: Dictionary = SKILL_BRANCHES.get(branch, SKILL_BRANCHES["arcane_fire"])
	img.fill(b["color"])
	# Duplakeret (ultimate jelzés)
	draw_circle_outline(img, 16, 16, 14, Color(0.85, 0.70, 0.15))
	draw_circle_outline(img, 16, 16, 13, Color(0.85, 0.70, 0.15))
	draw_circle_outline(img, 16, 16, 11, b["accent"])
	# Nagy szimbólum középen
	draw_circle(img, 16, 16, 6, b["accent"])
	draw_circle(img, 16, 16, 3, b["accent"].lightened(0.3))
	# Sugarak
	for angle_i in range(8):
		var angle := angle_i * PI / 4.0
		var ex := int(16 + cos(angle) * 10)
		var ey := int(16 + sin(angle) * 10)
		draw_line_px(img, 16, 16, ex, ey, Color(b["accent"].r, b["accent"].g, b["accent"].b, 0.5))
	return img

static func _draw_skill_symbol(img: Image, branch: String, index: int, col: Color) -> void:
	match branch:
		"shadow_blade":
			match index:
				0: draw_line_px(img, 8, 24, 24, 8, col)  # Vágás
				1:  # Tánc
					draw_line_px(img, 12, 22, 20, 10, col)
					draw_line_px(img, 20, 22, 12, 10, col)
				2: draw_circle(img, 16, 16, 4, col); draw_line_px(img, 16, 16, 24, 16, col)  # Lépés
				3:  # Lánc
					draw_circle_outline(img, 12, 12, 3, col)
					draw_circle_outline(img, 20, 20, 3, col)
					draw_line_px(img, 14, 14, 18, 18, col)
				4:  # Nagy vágás
					draw_line_px(img, 6, 26, 26, 6, col)
					fill_rect(img, 10, 10, 4, 4, col.lightened(0.3))
		"poison_mastery":
			match index:
				0: fill_rect(img, 14, 8, 4, 16, col); _set_pixel_safe(img, 15, 6, col.lightened(0.3))
				1: draw_circle(img, 16, 14, 6, Color(col.r, col.g, col.b, 0.5))
				2: draw_line_px(img, 8, 16, 24, 16, col); fill_rect(img, 10, 14, 12, 4, col.darkened(0.2))
				3: for i in range(3): draw_circle_outline(img, 10 + i * 6, 16, 3, col)
				4: for dy in range(8, 24, 3): fill_rect(img, 10, dy, 12, 1, col)
		"trap_craft":
			match index:
				0:  # Tüske
					for sx in range(10, 22, 4):
						fill_rect(img, sx, 12, 2, 8, col)
						_set_pixel_safe(img, sx, 11, col.lightened(0.2))
				1: draw_circle_outline(img, 16, 16, 8, col)  # Háló
				2: draw_circle(img, 16, 16, 5, col); draw_circle(img, 16, 16, 2, col.lightened(0.4))  # Akna
				3: draw_line_px(img, 8, 16, 24, 16, col); draw_line_px(img, 16, 8, 16, 24, col)  # Drót
				4: draw_circle(img, 16, 16, 6, col); draw_circle(img, 16, 16, 3, Color(1.0, 0.5, 0.1))  # Robbanó
		"holy_shield":
			match index:
				0: draw_ellipse(img, 16, 16, 6, 8, col); draw_line_px(img, 16, 8, 24, 16, col)
				1: draw_circle_outline(img, 16, 16, 8, col); draw_circle_outline(img, 16, 16, 5, col)
				2: draw_ellipse(img, 16, 16, 8, 10, col)
				3: draw_circle(img, 16, 16, 6, Color(col.r, col.g, col.b, 0.4))
				4: draw_ellipse(img, 16, 16, 10, 12, col); draw_circle(img, 16, 16, 3, col.lightened(0.3))
		"war_cry":
			match index:
				0:  # Kiáltás
					fill_rect(img, 12, 10, 8, 12, col)
					for i in range(3):
						draw_circle_outline(img, 24, 16, 3 + i * 3, col)
				1: draw_circle_outline(img, 16, 16, 10, col)  # Provokáció
				2: draw_line_px(img, 8, 24, 24, 8, col); fill_rect(img, 20, 8, 6, 6, col)  # Düh
				3: draw_circle(img, 16, 20, 8, col); draw_line_px(img, 8, 20, 24, 20, col)  # Csapás
				4: fill_rect(img, 10, 10, 12, 12, col); fill_rect(img, 12, 12, 8, 8, col.lightened(0.3))
		"fortify":
			match index:
				0: draw_ellipse(img, 16, 16, 8, 10, col)  # Bőr
				1: fill_rect(img, 8, 8, 16, 16, col)  # Fal
				2:  # Tüskék
					draw_circle_outline(img, 16, 16, 8, col)
					for a in range(0, 360, 45):
						var rad := deg_to_rad(a)
						_set_pixel_safe(img, int(16 + cos(rad) * 10), int(16 + sin(rad) * 10), col)
				3: fill_rect(img, 8, 8, 16, 16, col.darkened(0.2)); fill_rect(img, 10, 10, 12, 12, col)
				4: draw_circle(img, 16, 16, 10, col); draw_circle(img, 16, 16, 4, col.lightened(0.4))
		"arcane_fire":
			match index:
				0: draw_circle(img, 16, 14, 6, Color(1.0, 0.5, 0.1)); draw_circle(img, 16, 12, 3, Color(1.0, 0.8, 0.2))
				1: fill_rect(img, 6, 14, 20, 6, Color(1.0, 0.4, 0.05, 0.7))
				2: draw_circle(img, 16, 8, 5, col); draw_line_px(img, 16, 13, 16, 26, Color(1.0, 0.5, 0.1))
				3: draw_circle_outline(img, 16, 16, 8, Color(1.0, 0.5, 0.1)); draw_circle(img, 16, 16, 3, col)
				4: for i in range(5): draw_circle(img, 8 + i * 4, 10 + (i % 2) * 4, 3, col)
		"frost_magic":
			match index:
				0: fill_rect(img, 14, 8, 4, 16, col); _set_pixel_safe(img, 15, 6, col.lightened(0.4))
				1: draw_circle(img, 16, 16, 8, col); draw_circle_outline(img, 16, 16, 8, col.lightened(0.2))
				2: for fx in range(8, 24, 4): for fy in range(8, 24, 4): _set_pixel_safe(img, fx, fy, col)
				3: fill_rect(img, 6, 14, 20, 4, col)
				4: draw_circle(img, 16, 16, 7, col); draw_circle(img, 16, 16, 4, col.lightened(0.3))
		"dark_arts":
			match index:
				0: draw_line_px(img, 10, 10, 22, 22, col); draw_line_px(img, 22, 10, 10, 22, col)
				1: draw_circle_outline(img, 16, 16, 8, col); draw_circle_outline(img, 16, 16, 4, col)
				2:  # Csontváz fej
					draw_circle(img, 16, 14, 5, Color(0.80, 0.75, 0.65))
					_set_pixel_safe(img, 14, 13, Color(0, 0, 0))
					_set_pixel_safe(img, 18, 13, Color(0, 0, 0))
				3: fill_rect(img, 14, 8, 4, 16, col); draw_circle(img, 16, 8, 3, col.lightened(0.2))
				4: draw_circle(img, 16, 16, 8, col); draw_circle(img, 16, 16, 3, Color(0.8, 0.1, 0.1))

static func get_branch_names() -> Array:
	return SKILL_BRANCHES.keys()

static func export_all(base_path: String) -> void:
	var path := base_path + "icons/skills/"
	for branch in get_branch_names():
		for i in range(5):
			var skill_name: String = SKILL_BRANCHES[branch]["skills"][i]
			save_png(gen_skill_icon(branch, i), path + "%s/%s.png" % [branch, skill_name])
		save_png(gen_ultimate_icon(branch), path + "%s/%s.png" % [branch, SKILL_BRANCHES[branch]["ultimate"]])
	print("  ✓ Skill icons exported to: ", path)

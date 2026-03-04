## VfxGenerator - Skill VFX effektek (45 db, 9 branch × 5 skill)
## Különböző méretű sprite-sheet frame-ek az egyes skill effektekhez
class_name VfxGenerator
extends PixelArtBase

const VFX_CONFIG := {
	"shadow_blade": {
		"color": Color(0.20, 0.10, 0.25),
		"glow": Color(0.50, 0.20, 0.60),
		"effects": ["slash_dark", "blade_swirl", "phase_trail", "chain_shadow", "void_cut"],
	},
	"poison_mastery": {
		"color": Color(0.10, 0.25, 0.08),
		"glow": Color(0.30, 0.70, 0.15),
		"effects": ["dart_green", "cloud_toxic", "coat_venom", "plague_wave", "acid_drops"],
	},
	"trap_craft": {
		"color": Color(0.30, 0.20, 0.08),
		"glow": Color(0.65, 0.45, 0.15),
		"effects": ["spike_burst", "net_spread", "mine_explode", "wire_flash", "barrel_boom"],
	},
	"holy_shield": {
		"color": Color(0.65, 0.60, 0.30),
		"glow": Color(0.90, 0.85, 0.40),
		"effects": ["bash_impact", "barrier_dome", "guard_flash", "aura_ring", "fortress_wall"],
	},
	"war_cry": {
		"color": Color(0.50, 0.15, 0.08),
		"glow": Color(0.85, 0.30, 0.10),
		"effects": ["shout_wave", "taunt_ring", "rage_burst", "stomp_crack", "fury_aura"],
	},
	"fortify": {
		"color": Color(0.35, 0.30, 0.25),
		"glow": Color(0.55, 0.50, 0.42),
		"effects": ["iron_flash", "stone_rise", "thorn_pop", "endure_glow", "titan_pulse"],
	},
	"arcane_fire": {
		"color": Color(0.55, 0.15, 0.05),
		"glow": Color(0.95, 0.45, 0.10),
		"effects": ["fireball_trail", "flame_wave", "meteor_fall", "inferno_ring", "firestorm"],
	},
	"frost_magic": {
		"color": Color(0.20, 0.40, 0.65),
		"glow": Color(0.50, 0.80, 1.00),
		"effects": ["ice_bolt_trail", "frost_nova", "blizzard_snow", "ice_wall_rise", "frozen_orb"],
	},
	"dark_arts": {
		"color": Color(0.15, 0.05, 0.20),
		"glow": Color(0.45, 0.15, 0.60),
		"effects": ["drain_beam", "curse_rune", "undead_summon", "shadow_bolt", "soul_vortex"],
	},
}

## Skill VFX generátor (6 frame animáció, 64×64)
static func gen_skill_vfx(branch: String, skill_index: int) -> Array[Image]:
	var cfg: Dictionary = VFX_CONFIG.get(branch, VFX_CONFIG["arcane_fire"])
	var col: Color = cfg["color"]
	var glow: Color = cfg["glow"]
	var effect_name: String = cfg["effects"][clampi(skill_index, 0, 4)]
	var frames: Array[Image] = []
	for f in range(6):
		var img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
		img.fill(Color(0, 0, 0, 0))
		var progress := float(f) / 5.0  # 0.0 → 1.0
		_draw_vfx_frame(img, effect_name, col, glow, f, progress)
		frames.append(img)
	return frames

static func _draw_vfx_frame(img: Image, effect: String, col: Color, glow: Color, frame: int, progress: float) -> void:
	var alpha := 1.0 - progress * 0.3  # Fade out
	if effect.contains("slash") or effect.contains("cut"):
		# Vágás ív
		var arc_len := int(progress * 40) + 10
		var start_x := 32 - arc_len / 2
		for i in range(arc_len):
			var y_off := int(sin(float(i) / arc_len * PI) * 15)
			_set_pixel_safe(img, start_x + i, 32 - y_off, Color(glow.r, glow.g, glow.b, alpha))
			_set_pixel_safe(img, start_x + i, 33 - y_off, Color(glow.r, glow.g, glow.b, alpha * 0.6))
	elif effect.contains("swirl") or effect.contains("ring") or effect.contains("nova"):
		# Körkörös bővülés
		var radius := int(progress * 25) + 5
		draw_circle_outline(img, 32, 32, radius, Color(glow.r, glow.g, glow.b, alpha))
		if radius > 8:
			draw_circle_outline(img, 32, 32, radius - 3, Color(col.r, col.g, col.b, alpha * 0.5))
	elif effect.contains("trail") or effect.contains("beam"):
		# Nyomvonal / sugár
		var length := int(progress * 50) + 5
		fill_rect(img, 32, 30, length, 4, Color(glow.r, glow.g, glow.b, alpha))
		fill_rect(img, 32, 31, length, 2, Color(glow.r, glow.g, glow.b, alpha * 0.7).lightened(0.2))
		# Csúcs
		draw_circle(img, 32 + length - 2, 32, 3, Color(glow.r, glow.g, glow.b, alpha))
	elif effect.contains("cloud") or effect.contains("aura"):
		# Felhő / aura terjedés
		var rng := RandomNumberGenerator.new()
		rng.seed = frame * 999
		var radius := int(progress * 20) + 8
		for i in range(20 + int(progress * 30)):
			var px := 32 + rng.randi_range(-radius, radius)
			var py := 32 + rng.randi_range(-radius, radius)
			if Vector2(px - 32, py - 32).length() <= radius:
				_set_pixel_safe(img, px, py, Color(glow.r, glow.g, glow.b, alpha * rng.randf_range(0.2, 0.6)))
	elif effect.contains("burst") or effect.contains("explode") or effect.contains("boom"):
		# Robbanás
		var radius := int(progress * 28) + 3
		draw_circle(img, 32, 32, radius, Color(glow.r, glow.g, glow.b, alpha * (1.0 - progress * 0.5)))
		if radius > 5:
			draw_circle(img, 32, 32, radius - 4, Color(1.0, 1.0, 1.0, alpha * 0.3))
		# Részecskék
		for i in range(8):
			var angle := i * PI / 4.0
			var dist := int(progress * 20) + 2
			var px := int(32 + cos(angle) * dist)
			var py := int(32 + sin(angle) * dist)
			_set_pixel_safe(img, px, py, glow)
	elif effect.contains("wave"):
		# Hullám (félkör)
		var spread := int(progress * 30) + 5
		for x_off in range(-spread, spread + 1):
			var y_off := int(sin(float(x_off + spread) / (spread * 2) * PI) * 8)
			_set_pixel_safe(img, 32 + x_off, 32 - y_off, Color(glow.r, glow.g, glow.b, alpha))
	elif effect.contains("fall") or effect.contains("drops"):
		# Hulló (meteór / cseppek)
		var y_pos := int(progress * 50)
		draw_circle(img, 32, y_pos + 5, 5, Color(glow.r, glow.g, glow.b, alpha))
		# Nyomvonal
		for t in range(mini(y_pos, 20)):
			_set_pixel_safe(img, 32 + (t % 3) - 1, y_pos + 5 - t, Color(glow.r, glow.g, glow.b, alpha * 0.4))
	elif effect.contains("wall") or effect.contains("rise"):
		# Fal / emelkedés
		var height := int(progress * 40)
		fill_rect(img, 12, 52 - height, 40, height, Color(col.r, col.g, col.b, alpha * 0.6))
		fill_rect(img, 14, 52 - height, 36, 4, Color(glow.r, glow.g, glow.b, alpha))
	elif effect.contains("dome") or effect.contains("orb"):
		# Kupola / gömb
		var radius := int(progress * 18) + 5
		draw_circle(img, 32, 32, radius, Color(glow.r, glow.g, glow.b, alpha * 0.3))
		draw_circle_outline(img, 32, 32, radius, Color(glow.r, glow.g, glow.b, alpha * 0.7))
	elif effect.contains("rune") or effect.contains("summon"):
		# Rúna kör
		var radius := 12 + int(progress * 5)
		draw_circle_outline(img, 32, 32, radius, Color(glow.r, glow.g, glow.b, alpha))
		# Belső szimbólumok
		draw_line_px(img, 22, 22, 42, 42, Color(glow.r, glow.g, glow.b, alpha * 0.6))
		draw_line_px(img, 42, 22, 22, 42, Color(glow.r, glow.g, glow.b, alpha * 0.6))
		if frame > 2:
			draw_circle(img, 32, 32, 4, Color(glow.r, glow.g, glow.b, alpha))
	elif effect.contains("flash") or effect.contains("glow") or effect.contains("pulse"):
		# Villanás / pulzálás
		var intensity := sin(progress * PI) 
		var radius := int(intensity * 20) + 3
		draw_circle(img, 32, 32, radius, Color(glow.r, glow.g, glow.b, intensity * alpha))
		if intensity > 0.5:
			draw_circle(img, 32, 32, int(radius * 0.5), Color(1.0, 1.0, 1.0, intensity * 0.4))
	elif effect.contains("vortex") or effect.contains("crack"):
		# Örvény / repedés
		for i in range(frame + 2):
			var angle := i * PI / 3.0 + progress * PI
			var dist := 5 + i * 3
			var px := int(32 + cos(angle) * dist)
			var py := int(32 + sin(angle) * dist)
			draw_circle(img, px, py, 2, Color(glow.r, glow.g, glow.b, alpha))
	else:
		# Alapértelmezett: részecskék
		var rng := RandomNumberGenerator.new()
		rng.seed = frame * 555
		for i in range(10 + frame * 3):
			var px := 32 + rng.randi_range(-15, 15)
			var py := 32 + rng.randi_range(-15, 15)
			_set_pixel_safe(img, px, py, Color(glow.r, glow.g, glow.b, alpha * rng.randf()))

static func get_branch_names() -> Array:
	return VFX_CONFIG.keys()

static func get_anim_config() -> Dictionary:
	return {"skill_vfx": {"frames": 6, "fps": 10, "loop": false}}

static func export_all(base_path: String) -> void:
	var path := base_path + "effects/skills/"
	for branch in get_branch_names():
		var cfg: Dictionary = VFX_CONFIG[branch]
		for i in range(5):
			var effect_name: String = cfg["effects"][i]
			var frames := gen_skill_vfx(branch, i)
			for f in range(frames.size()):
				save_png(frames[f], path + "%s/%s_%d.png" % [branch, effect_name, f])
	print("  ✓ Skill VFX exported to: ", path)

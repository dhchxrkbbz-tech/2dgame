## ParticleTextures - Particle textúrák (20 db, 8×8 → 16×16)
## Tűz, jég, méreg, vér, füst, szikra, hamu, por, vízcsepp, hó stb.
class_name ParticleTextures
extends PixelArtBase

static func gen_particle(particle_type: String) -> Image:
	var size := 8
	if particle_type in ["fire_large", "smoke", "blood_splat"]:
		size = 16
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var half := size / 2
	match particle_type:
		"fire":
			draw_circle(img, half, half, 3, Color(1.0, 0.50, 0.10, 0.8))
			_set_pixel_safe(img, half, half - 1, Color(1.0, 0.85, 0.20, 0.9))
			_set_pixel_safe(img, half, half - 2, Color(1.0, 0.95, 0.50, 0.6))
		"fire_large":
			draw_circle(img, half, half + 2, 5, Color(1.0, 0.40, 0.05, 0.7))
			draw_circle(img, half, half, 3, Color(1.0, 0.70, 0.15, 0.8))
			_set_pixel_safe(img, half, half - 3, Color(1.0, 0.90, 0.40, 0.6))
		"ember":
			_set_pixel_safe(img, half, half, Color(1.0, 0.60, 0.10, 0.9))
			_set_pixel_safe(img, half + 1, half, Color(1.0, 0.45, 0.08, 0.7))
		"ice":
			draw_circle(img, half, half, 2, Color(0.60, 0.85, 1.0, 0.7))
			_set_pixel_safe(img, half - 1, half - 1, Color(0.80, 0.95, 1.0, 0.5))
		"ice_shard":
			fill_rect(img, half - 1, half - 3, 2, 6, Color(0.55, 0.80, 1.0, 0.8))
			_set_pixel_safe(img, half, half - 3, Color(0.80, 0.95, 1.0, 0.9))
		"snow":
			_set_pixel_safe(img, half, half, Color(0.95, 0.95, 1.0, 0.8))
			_set_pixel_safe(img, half - 1, half, Color(0.90, 0.92, 0.98, 0.5))
			_set_pixel_safe(img, half + 1, half, Color(0.90, 0.92, 0.98, 0.5))
			_set_pixel_safe(img, half, half - 1, Color(0.90, 0.92, 0.98, 0.5))
			_set_pixel_safe(img, half, half + 1, Color(0.90, 0.92, 0.98, 0.5))
		"poison":
			draw_circle(img, half, half, 2, Color(0.25, 0.60, 0.10, 0.6))
			_set_pixel_safe(img, half, half, Color(0.35, 0.75, 0.15, 0.8))
		"poison_drop":
			_set_pixel_safe(img, half, half - 1, Color(0.20, 0.55, 0.08, 0.7))
			fill_rect(img, half - 1, half, 2, 2, Color(0.25, 0.60, 0.10, 0.8))
		"blood":
			draw_circle(img, half, half, 2, Color(0.55, 0.02, 0.02, 0.7))
			_set_pixel_safe(img, half + 1, half + 1, Color(0.40, 0.01, 0.01, 0.5))
		"blood_splat":
			draw_circle(img, half, half, 4, Color(0.50, 0.02, 0.02, 0.6))
			draw_circle(img, half + 2, half - 1, 2, Color(0.55, 0.03, 0.03, 0.5))
			draw_circle(img, half - 3, half + 2, 2, Color(0.45, 0.01, 0.01, 0.4))
		"smoke":
			draw_circle(img, half, half, 5, Color(0.30, 0.28, 0.25, 0.3))
			draw_circle(img, half + 1, half - 1, 3, Color(0.35, 0.33, 0.30, 0.25))
		"dust":
			draw_circle(img, half, half, 2, Color(0.55, 0.48, 0.35, 0.4))
			_set_pixel_safe(img, half - 1, half + 1, Color(0.50, 0.44, 0.32, 0.3))
		"ash":
			_set_pixel_safe(img, half, half, Color(0.35, 0.30, 0.25, 0.5))
			_set_pixel_safe(img, half + 1, half, Color(0.30, 0.26, 0.22, 0.4))
		"spark":
			_set_pixel_safe(img, half, half, Color(1.0, 0.90, 0.50, 0.9))
			_set_pixel_safe(img, half - 1, half, Color(1.0, 0.80, 0.30, 0.5))
			_set_pixel_safe(img, half + 1, half, Color(1.0, 0.80, 0.30, 0.5))
		"water_drop":
			draw_circle(img, half, half, 2, Color(0.30, 0.55, 0.80, 0.6))
			_set_pixel_safe(img, half - 1, half - 1, Color(0.50, 0.75, 1.0, 0.4))
		"void":
			draw_circle(img, half, half, 2, Color(0.30, 0.10, 0.50, 0.6))
			_set_pixel_safe(img, half, half, Color(0.50, 0.20, 0.80, 0.8))
		"holy":
			draw_circle(img, half, half, 2, Color(0.90, 0.85, 0.40, 0.5))
			_set_pixel_safe(img, half, half, Color(1.0, 0.95, 0.60, 0.8))
		"dark":
			draw_circle(img, half, half, 2, Color(0.08, 0.04, 0.12, 0.6))
			_set_pixel_safe(img, half, half, Color(0.15, 0.08, 0.20, 0.8))
		"lightning":
			_set_pixel_safe(img, half, half - 2, Color(1.0, 1.0, 0.60, 0.9))
			_set_pixel_safe(img, half + 1, half - 1, Color(1.0, 1.0, 0.60, 0.9))
			_set_pixel_safe(img, half - 1, half, Color(1.0, 1.0, 0.60, 0.9))
			_set_pixel_safe(img, half, half + 1, Color(1.0, 1.0, 0.60, 0.9))
			_set_pixel_safe(img, half + 1, half + 2, Color(1.0, 1.0, 0.60, 0.9))
		"earth":
			fill_rect(img, half - 1, half - 1, 3, 3, Color(0.45, 0.35, 0.18, 0.7))
			_set_pixel_safe(img, half, half, Color(0.55, 0.42, 0.22, 0.8))

static func get_particle_types() -> Array:
	return [
		"fire", "fire_large", "ember", "ice", "ice_shard", "snow",
		"poison", "poison_drop", "blood", "blood_splat", "smoke", "dust",
		"ash", "spark", "water_drop", "void", "holy", "dark", "lightning", "earth"
	]

static func export_all(base_path: String) -> void:
	var path := base_path + "effects/particles/"
	for pt in get_particle_types():
		save_png(gen_particle(pt), path + "%s.png" % pt)
	print("  ✓ Particle textures exported to: ", path)

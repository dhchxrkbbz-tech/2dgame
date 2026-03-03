## DropDisplay - Rarity-alapú drop vizuális effektek
## Particle, glow, hang effektek rarity szerint
class_name DropDisplay
extends Node2D

## Rarity particle konfigurációk
const RARITY_CONFIG := {
	Enums.Rarity.COMMON: {
		"glow": false,
		"particles": false,
		"sound": false,
		"label_size": 8,
		"bob_speed": 2.0,
		"icon_scale": 1.0,
	},
	Enums.Rarity.UNCOMMON: {
		"glow": false,
		"particles": false,
		"sound": false,
		"label_size": 8,
		"bob_speed": 2.5,
		"icon_scale": 1.0,
	},
	Enums.Rarity.RARE: {
		"glow": true,
		"glow_energy": 0.3,
		"particles": false,
		"sound": false,
		"label_size": 9,
		"bob_speed": 3.0,
		"icon_scale": 1.1,
	},
	Enums.Rarity.EPIC: {
		"glow": true,
		"glow_energy": 0.6,
		"particles": true,
		"particle_amount": 4,
		"sound": false,
		"label_size": 10,
		"bob_speed": 3.5,
		"icon_scale": 1.2,
	},
	Enums.Rarity.LEGENDARY: {
		"glow": true,
		"glow_energy": 1.0,
		"particles": true,
		"particle_amount": 8,
		"sound": true,
		"label_size": 11,
		"bob_speed": 4.0,
		"icon_scale": 1.3,
	},
}


## Glow effekt hozzáadása
static func add_glow(node: Node2D, rarity: int) -> PointLight2D:
	var config: Dictionary = RARITY_CONFIG.get(rarity, RARITY_CONFIG[Enums.Rarity.COMMON])
	if not config.get("glow", false):
		return null
	
	var light := PointLight2D.new()
	light.color = Constants.RARITY_COLORS.get(rarity, Color.WHITE)
	light.energy = config.get("glow_energy", 0.5)
	light.texture = _create_glow_texture()
	light.texture_scale = 0.5
	light.shadow_enabled = false
	node.add_child(light)
	return light


## Particle effekt hozzáadása
static func add_particles(node: Node2D, rarity: int) -> GPUParticles2D:
	var config: Dictionary = RARITY_CONFIG.get(rarity, RARITY_CONFIG[Enums.Rarity.COMMON])
	if not config.get("particles", false):
		return null
	
	var particles := GPUParticles2D.new()
	var mat := ParticleProcessMaterial.new()
	
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = 6.0
	mat.direction = Vector3(0, -1, 0)
	mat.spread = 30.0
	mat.initial_velocity_min = 8.0
	mat.initial_velocity_max = 15.0
	mat.gravity = Vector3(0, -20, 0)
	mat.scale_min = 0.5
	mat.scale_max = 1.5
	mat.color = Constants.RARITY_COLORS.get(rarity, Color.WHITE)
	
	particles.process_material = mat
	particles.amount = config.get("particle_amount", 4)
	particles.lifetime = 1.0
	particles.preprocess = 0.5
	
	node.add_child(particles)
	return particles


## Szín meghatározás
static func get_rarity_color(rarity: int) -> Color:
	return Constants.RARITY_COLORS.get(rarity, Color(0.8, 0.8, 0.8))


## Glow textúra generálás
static func _create_glow_texture() -> GradientTexture2D:
	var tex := GradientTexture2D.new()
	var gradient := Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))
	gradient.add_point(0.5, Color(1, 1, 1, 0.3))
	gradient.add_point(1.0, Color(1, 1, 1, 0))
	tex.gradient = gradient
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	return tex


## Minimap jelzés epic+ item-ekhez
static func should_show_on_minimap(rarity: int) -> bool:
	return rarity >= Enums.Rarity.EPIC


## Minimap pötty szín
static func get_minimap_dot_color(rarity: int) -> Color:
	return get_rarity_color(rarity)

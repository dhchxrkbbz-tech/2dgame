## GemIconGenerator - Gem ikonok (51 normál + 15 legendás = 66 db, 32×32)
## 6 típus × 6 tier + 15 legendary
class_name GemIconGenerator
extends PixelArtBase

const GEM_TYPES := {
	"ruby": {"color": Color(0.80, 0.10, 0.10), "glow": Color(1.0, 0.30, 0.30), "stat": "damage"},
	"sapphire": {"color": Color(0.10, 0.25, 0.80), "glow": Color(0.40, 0.55, 1.0), "stat": "mana"},
	"emerald": {"color": Color(0.10, 0.60, 0.15), "glow": Color(0.30, 0.85, 0.40), "stat": "regen"},
	"topaz": {"color": Color(0.85, 0.70, 0.10), "glow": Color(1.0, 0.88, 0.30), "stat": "speed"},
	"amethyst": {"color": Color(0.50, 0.15, 0.65), "glow": Color(0.70, 0.35, 0.90), "stat": "crit"},
	"diamond": {"color": Color(0.75, 0.80, 0.85), "glow": Color(0.90, 0.95, 1.0), "stat": "all"},
}

const TIER_SIZES := [4, 5, 6, 7, 8, 9]  # Kristály méret tier szerint
const TIER_NAMES := ["chipped", "flawed", "regular", "flawless", "perfect", "radiant"]

const LEGENDARY_GEMS := {
	"heart_of_flame": {"base": "ruby", "effect": Color(1.0, 0.50, 0.10)},
	"ocean_tear": {"base": "sapphire", "effect": Color(0.20, 0.60, 0.95)},
	"natures_wrath": {"base": "emerald", "effect": Color(0.15, 0.75, 0.25)},
	"lightning_shard": {"base": "topaz", "effect": Color(1.0, 1.0, 0.40)},
	"void_crystal": {"base": "amethyst", "effect": Color(0.40, 0.10, 0.60)},
	"prismatic_core": {"base": "diamond", "effect": Color(1.0, 0.90, 0.80)},
	"blood_gem": {"base": "ruby", "effect": Color(0.50, 0.02, 0.02)},
	"frost_gem": {"base": "sapphire", "effect": Color(0.60, 0.80, 1.0)},
	"poison_gem": {"base": "emerald", "effect": Color(0.30, 0.55, 0.05)},
	"sun_gem": {"base": "topaz", "effect": Color(1.0, 0.85, 0.20)},
	"shadow_gem": {"base": "amethyst", "effect": Color(0.15, 0.05, 0.20)},
	"star_gem": {"base": "diamond", "effect": Color(1.0, 1.0, 0.90)},
	"chaos_gem": {"base": "ruby", "effect": Color(0.80, 0.20, 0.80)},
	"arcane_gem": {"base": "sapphire", "effect": Color(0.60, 0.30, 0.90)},
	"earth_gem": {"base": "emerald", "effect": Color(0.45, 0.35, 0.15)},
}

## Normál gem ikon
static func gen_gem_icon(gem_type: String, tier: int) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var data: Dictionary = GEM_TYPES.get(gem_type, GEM_TYPES["ruby"])
	var col: Color = data["color"]
	var glow: Color = data["glow"]
	var sz: int = TIER_SIZES[clampi(tier, 0, 5)]
	# Háttér fénylés (magasabb tiernél erősebb)
	var glow_alpha := 0.05 + tier * 0.04
	draw_circle(img, 16, 16, sz + 3, Color(glow.r, glow.g, glow.b, glow_alpha))
	# Kristály forma (hatszögszerű)
	_draw_gem_shape(img, 16, 16, sz, col)
	# Fénypont
	_set_pixel_safe(img, 14, 12, glow.lightened(0.3))
	_set_pixel_safe(img, 13, 13, Color(1.0, 1.0, 1.0, 0.4))
	# Tier szegély
	if tier >= 3:
		draw_circle_outline(img, 16, 16, sz + 1, glow.darkened(0.1))
	if tier >= 5:
		draw_circle_outline(img, 16, 16, sz + 2, Color(0.85, 0.70, 0.15))
	return img

## Legendary gem ikon
static func gen_legendary_gem_icon(gem_name: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var data: Dictionary = LEGENDARY_GEMS.get(gem_name, LEGENDARY_GEMS["heart_of_flame"])
	var base_data: Dictionary = GEM_TYPES[data["base"]]
	var col: Color = base_data["color"]
	var effect: Color = data["effect"]
	# Aura
	draw_circle(img, 16, 16, 13, Color(effect.r, effect.g, effect.b, 0.12))
	draw_circle(img, 16, 16, 10, Color(effect.r, effect.g, effect.b, 0.08))
	# Kristály (max méret)
	_draw_gem_shape(img, 16, 16, 9, col)
	# Effekt overlay
	draw_circle(img, 16, 16, 5, Color(effect.r, effect.g, effect.b, 0.35))
	# Aranyszegély (legendary)
	draw_circle_outline(img, 16, 16, 11, Color(0.85, 0.70, 0.15))
	draw_circle_outline(img, 16, 16, 12, Color(0.85, 0.70, 0.15))
	# Fénypont
	_set_pixel_safe(img, 13, 11, Color(1.0, 1.0, 1.0, 0.6))
	_set_pixel_safe(img, 14, 12, effect.lightened(0.4))
	return img

static func _draw_gem_shape(img: Image, cx: int, cy: int, sz: int, col: Color) -> void:
	# Hexagonális kristályforma
	# Felső csúcs
	for row in range(sz * 2):
		var y := cy - sz + row
		var half_w: int
		if row < sz:
			half_w = int(float(row) / sz * sz)
		else:
			half_w = int(float(sz * 2 - row) / sz * sz)
		half_w = maxi(half_w, 1)
		var shade := col if row < sz else col.darkened(0.15)
		for dx in range(-half_w, half_w + 1):
			_set_pixel_safe(img, cx + dx, y, shade)
	# Fényes oldal (bal-felső)
	for row in range(sz):
		var y := cy - sz + row
		var hw := int(float(row) / sz * sz * 0.4)
		for dx in range(-hw, 0):
			_set_pixel_safe(img, cx + dx, y, col.lightened(0.2))

static func get_gem_type_names() -> Array:
	return GEM_TYPES.keys()

static func get_legendary_names() -> Array:
	return LEGENDARY_GEMS.keys()

static func export_all(base_path: String) -> void:
	var path := base_path + "icons/gems/"
	# Normál gemek
	for gt in get_gem_type_names():
		for tier in range(6):
			save_png(gen_gem_icon(gt, tier), path + "normal/%s_%s.png" % [gt, TIER_NAMES[tier]])
	# Legendary gemek
	for lg in get_legendary_names():
		save_png(gen_legendary_gem_icon(lg), path + "legendary/%s.png" % lg)
	print("  ✓ Gem icons exported to: ", path)

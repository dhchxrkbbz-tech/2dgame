## ItemIconGenerator - Item ikonok (~232 darab, 32×32)
## Fegyverek(50), páncélok(60), kiegészítők(10), set items(32), legendary(30), consumable(15), crafting(30), misc(5)
class_name ItemIconGenerator
extends PixelArtBase

## Fegyver ikon
static func gen_weapon_icon(weapon_type: String, variant: int, rarity: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var metal := Color(0.60, 0.58, 0.55)
	var handle := Color(0.30, 0.18, 0.06)
	var r_col: Color = RARITY_COLORS.get(rarity, RARITY_COLORS["common"])
	match weapon_type:
		"sword":
			# Penge
			fill_rect(img, 14, 2, 4, 20, metal)
			fill_rect(img, 15, 2, 2, 18, metal.lightened(0.15))
			# Keresztvas
			fill_rect(img, 10, 20, 12, 2, handle.lightened(0.2))
			# Markolat
			fill_rect(img, 14, 22, 4, 8, handle)
			# Pommel
			fill_rect(img, 14, 28, 4, 2, r_col)
		"dagger":
			fill_rect(img, 14, 6, 3, 14, metal)
			fill_rect(img, 15, 6, 1, 12, metal.lightened(0.15))
			fill_rect(img, 12, 18, 8, 2, handle.lightened(0.2))
			fill_rect(img, 14, 20, 3, 8, handle)
			_set_pixel_safe(img, 15, 28, r_col)
		"staff":
			fill_rect(img, 14, 8, 3, 22, handle)
			fill_rect(img, 15, 10, 1, 18, handle.lightened(0.1))
			# Kristály csúcs
			draw_circle(img, 15, 5, 4, r_col)
			draw_circle(img, 15, 5, 2, r_col.lightened(0.3))
		"bow":
			# Ív
			draw_circle_outline(img, 22, 16, 12, handle)
			# Húr
			draw_line_px(img, 16, 4, 16, 28, Color(0.70, 0.68, 0.60))
		"mace":
			fill_rect(img, 14, 14, 4, 16, handle)
			fill_rect(img, 10, 4, 12, 12, metal)
			fill_rect(img, 12, 6, 8, 8, metal.lightened(0.1))
			# Tüskék
			_set_pixel_safe(img, 9, 8, metal)
			_set_pixel_safe(img, 22, 8, metal)
			_set_pixel_safe(img, 16, 3, metal)
		"axe":
			fill_rect(img, 14, 10, 3, 20, handle)
			# Penge
			fill_rect(img, 16, 4, 10, 14, metal)
			fill_rect(img, 18, 6, 6, 10, metal.lightened(0.12))
			# Él
			fill_rect(img, 24, 6, 2, 10, metal.lightened(0.25))
		"shield":
			draw_ellipse(img, 16, 16, 12, 14, metal)
			draw_ellipse(img, 16, 16, 10, 12, metal.lightened(0.08))
			draw_circle(img, 16, 16, 4, r_col)
			draw_circle_outline(img, 16, 16, 8, r_col.darkened(0.2))
		"wand":
			fill_rect(img, 14, 10, 3, 20, handle)
			fill_rect(img, 15, 12, 1, 16, handle.lightened(0.1))
			draw_circle(img, 15, 7, 3, r_col)
			_set_pixel_safe(img, 15, 6, r_col.lightened(0.4))
	# Rarity szegély
	if rarity != "common":
		draw_outline(img, r_col)
	return img

## Páncél ikon
static func gen_armor_icon(armor_type: String, variant: int, rarity: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var r_col: Color = RARITY_COLORS.get(rarity, RARITY_COLORS["common"])
	var base_col := Color(0.35, 0.30, 0.25)
	match armor_type:
		"helmet":
			draw_ellipse(img, 16, 14, 10, 12, base_col)
			draw_ellipse(img, 16, 12, 8, 10, base_col.lightened(0.1))
			fill_rect(img, 8, 18, 16, 4, base_col.darkened(0.1))
			fill_rect(img, 10, 20, 12, 2, Color(0.05, 0.05, 0.05))
		"chest":
			fill_rect(img, 6, 4, 20, 24, base_col)
			fill_rect(img, 8, 6, 16, 20, base_col.lightened(0.08))
			fill_rect(img, 2, 6, 6, 14, base_col)
			fill_rect(img, 24, 6, 6, 14, base_col)
			fill_rect(img, 14, 8, 4, 12, r_col.darkened(0.2))
		"legs":
			fill_rect(img, 8, 2, 16, 12, base_col)
			fill_rect(img, 8, 14, 8, 16, base_col)
			fill_rect(img, 16, 14, 8, 16, base_col)
			fill_rect(img, 10, 4, 12, 8, base_col.lightened(0.08))
		"boots":
			fill_rect(img, 6, 8, 8, 18, base_col)
			fill_rect(img, 18, 8, 8, 18, base_col)
			fill_rect(img, 4, 24, 12, 4, base_col.darkened(0.05))
			fill_rect(img, 16, 24, 12, 4, base_col.darkened(0.05))
		"gloves":
			fill_rect(img, 4, 4, 10, 16, base_col)
			fill_rect(img, 18, 4, 10, 16, base_col)
			fill_rect(img, 4, 18, 4, 6, base_col)
			fill_rect(img, 8, 18, 4, 8, base_col)
			fill_rect(img, 18, 18, 4, 6, base_col)
			fill_rect(img, 22, 18, 4, 8, base_col)
		"cape":
			fill_rect(img, 8, 2, 16, 4, base_col)
			fill_rect(img, 4, 6, 24, 22, r_col.darkened(0.3))
			fill_rect(img, 6, 8, 20, 18, r_col.darkened(0.2))
	if rarity != "common":
		draw_outline(img, r_col)
	return img

## Kiegészítő ikon (gyűrű, nyaklánc, amulett)
static func gen_accessory_icon(acc_type: String, rarity: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	var r_col: Color = RARITY_COLORS.get(rarity, RARITY_COLORS["common"])
	var gold := Color(0.80, 0.65, 0.15)
	match acc_type:
		"ring":
			draw_circle_outline(img, 16, 16, 8, gold)
			draw_circle_outline(img, 16, 16, 7, gold.lightened(0.1))
			draw_circle(img, 16, 10, 3, r_col)
		"necklace":
			draw_circle_outline(img, 16, 14, 10, gold)
			draw_circle(img, 16, 24, 3, r_col)
			_set_pixel_safe(img, 16, 23, r_col.lightened(0.3))
		"amulet":
			draw_circle_outline(img, 16, 12, 6, gold)
			draw_line_px(img, 10, 4, 16, 8, gold)
			draw_line_px(img, 22, 4, 16, 8, gold)
			draw_circle(img, 16, 20, 5, r_col)
			draw_circle(img, 16, 20, 3, r_col.lightened(0.2))
		"belt":
			fill_rect(img, 2, 12, 28, 6, Color(0.30, 0.18, 0.06))
			fill_rect(img, 12, 12, 8, 6, gold)
	if rarity != "common":
		draw_outline(img, r_col)
	return img

## Fogyasztható ikon (potion, scroll, food)
static func gen_consumable_icon(con_type: String, variant: int) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match con_type:
		"health_potion":
			_draw_potion(img, Color(0.80, 0.10, 0.10))
		"mana_potion":
			_draw_potion(img, Color(0.15, 0.25, 0.85))
		"stamina_potion":
			_draw_potion(img, Color(0.15, 0.70, 0.20))
		"elixir":
			_draw_potion(img, Color(0.80, 0.60, 0.10))
		"scroll":
			fill_rect(img, 8, 4, 16, 24, Color(0.82, 0.78, 0.65))
			fill_rect(img, 6, 4, 4, 4, Color(0.70, 0.65, 0.50))
			fill_rect(img, 6, 24, 4, 4, Color(0.70, 0.65, 0.50))
			fill_rect(img, 22, 4, 4, 4, Color(0.70, 0.65, 0.50))
			fill_rect(img, 22, 24, 4, 4, Color(0.70, 0.65, 0.50))
			for ty in range(8, 24, 3):
				fill_rect(img, 10, ty, 12, 1, Color(0.20, 0.15, 0.10))
		"food":
			# Kenyér
			draw_ellipse(img, 16, 18, 10, 8, Color(0.75, 0.55, 0.20))
			draw_ellipse(img, 16, 16, 8, 6, Color(0.85, 0.65, 0.25))
	return img

static func _draw_potion(img: Image, liquid_col: Color) -> void:
	# Üveg
	fill_rect(img, 12, 4, 8, 4, Color(0.70, 0.72, 0.75))
	draw_ellipse(img, 16, 18, 8, 10, Color(0.60, 0.62, 0.65, 0.6))
	# Folyadék
	draw_ellipse(img, 16, 20, 7, 8, liquid_col)
	# Fény
	_set_pixel_safe(img, 12, 14, Color(1.0, 1.0, 1.0, 0.4))
	# Dugó
	fill_rect(img, 13, 2, 6, 4, Color(0.30, 0.18, 0.06))

## Crafting anyag ikon
static func gen_crafting_icon(mat_type: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match mat_type:
		"ore":
			draw_ellipse(img, 16, 18, 10, 8, Color(0.40, 0.35, 0.30))
			fill_rect(img, 12, 12, 6, 6, Color(0.55, 0.50, 0.42))
			_set_pixel_safe(img, 14, 14, Color(0.70, 0.65, 0.55))
		"herb":
			fill_rect(img, 14, 14, 2, 14, Color(0.15, 0.35, 0.08))
			draw_circle(img, 15, 10, 4, Color(0.20, 0.50, 0.12))
			draw_circle(img, 11, 14, 3, Color(0.18, 0.45, 0.10))
			draw_circle(img, 19, 12, 3, Color(0.22, 0.55, 0.14))
		"leather":
			fill_rect(img, 6, 6, 20, 20, Color(0.45, 0.30, 0.12))
			fill_rect(img, 8, 8, 16, 16, Color(0.50, 0.34, 0.14))
		"cloth":
			fill_rect(img, 4, 8, 24, 18, Color(0.65, 0.60, 0.55))
			fill_rect(img, 4, 8, 24, 2, Color(0.60, 0.55, 0.50))
			for fx in range(6, 26, 4):
				fill_rect(img, fx, 10, 1, 14, Color(0.55, 0.50, 0.45))
		"gem_raw":
			draw_circle(img, 16, 16, 8, Color(0.40, 0.35, 0.30))
			fill_rect(img, 12, 12, 6, 6, Color(0.50, 0.30, 0.70))
			_set_pixel_safe(img, 14, 13, Color(0.70, 0.50, 0.90))
		"wood":
			fill_rect(img, 8, 4, 8, 24, Color(0.38, 0.24, 0.10))
			fill_rect(img, 10, 6, 4, 20, Color(0.42, 0.28, 0.12))
			fill_rect(img, 16, 8, 8, 20, Color(0.36, 0.22, 0.09))
	return img

static func get_weapon_types() -> Array:
	return ["sword", "dagger", "staff", "bow", "mace", "axe", "shield", "wand"]

static func get_armor_types() -> Array:
	return ["helmet", "chest", "legs", "boots", "gloves", "cape"]

static func get_accessory_types() -> Array:
	return ["ring", "necklace", "amulet", "belt"]

static func get_consumable_types() -> Array:
	return ["health_potion", "mana_potion", "stamina_potion", "elixir", "scroll", "food"]

static func get_crafting_types() -> Array:
	return ["ore", "herb", "leather", "cloth", "gem_raw", "wood"]

static func export_all(base_path: String) -> void:
	var path := base_path + "icons/items/"
	var rarities := ["common", "uncommon", "rare", "epic", "legendary"]
	# Fegyverek (8 type × ~6 rarity variant)
	for wt in get_weapon_types():
		for i in range(rarities.size()):
			save_png(gen_weapon_icon(wt, i, rarities[i]), path + "weapons/%s_%s.png" % [wt, rarities[i]])
	# Páncélok (6 type × ~5 rarity)
	for at in get_armor_types():
		for i in range(rarities.size()):
			save_png(gen_armor_icon(at, i, rarities[i]), path + "armor/%s_%s.png" % [at, rarities[i]])
	# Kiegészítők
	for ac in get_accessory_types():
		for r in ["uncommon", "rare", "epic"]:
			save_png(gen_accessory_icon(ac, r), path + "accessories/%s_%s.png" % [ac, r])
	# Fogyaszthatók
	for ct in get_consumable_types():
		save_png(gen_consumable_icon(ct, 0), path + "consumables/%s.png" % ct)
	# Crafting
	for mt in get_crafting_types():
		save_png(gen_crafting_icon(mt), path + "crafting/%s.png" % mt)
	print("  ✓ Item icons exported to: ", path)

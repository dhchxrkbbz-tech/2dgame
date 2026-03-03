## ThemePlagueLands - Plague Lands dungeon téma
## "Plague Sanctum" - pestis szentély
class_name ThemePlagueLands
extends BiomeThemeBase


func _init() -> void:
	biome_type = Enums.BiomeType.PLAGUE_LANDS
	theme_name = "Plague Sanctum"
	dungeon_name = "Plague Sanctum"
	
	ambient_color = Color(0.25, 0.3, 0.15, 1.0)
	torch_color = Color(0.6, 0.8, 0.2, 0.7)
	floor_tint = Color(0.3, 0.32, 0.2)
	wall_tint = Color(0.22, 0.25, 0.15)
	
	hazard_type = "corruption"
	hazard_density = 0.1
	
	special_mechanics = ["corruption_stacks", "poisoned_chests"]
	
	decoration_types = [
		"toxic_puddle", "plague_rat", "diseased_corpse", "toxic_mushroom",
		"bubbling_ooze", "broken_vial", "corrupted_plant",
	]
	prop_types = ["alchemy_table", "specimen_jar", "plague_mask"]
	
	boss_names = ["Plague Lord", "Toxic Abomination"]
	unique_enemies = ["plague_bearer", "toxic_slime", "corrupted_rat"]


func apply_environmental_effect(player: Node, delta: float) -> void:
	# Corruption: korrupciós stack-ek gyűlnek
	# 5 stack = DOT kezdődik
	if player.has_method("get_current_tile_type"):
		var tile_type = player.get_current_tile_type()
		if tile_type == "corruption":
			if player.has_method("add_corruption_stack"):
				player.add_corruption_stack(delta)


func _get_decoration_color(deco_type: String) -> Color:
	match deco_type:
		"toxic_puddle": return Color(0.4, 0.7, 0.2, 0.5)
		"plague_rat": return Color(0.4, 0.35, 0.3, 0.6)
		"diseased_corpse": return Color(0.35, 0.4, 0.25, 0.6)
		"toxic_mushroom": return Color(0.5, 0.7, 0.2, 0.7)
		"bubbling_ooze": return Color(0.3, 0.6, 0.15, 0.6)
		"broken_vial": return Color(0.5, 0.7, 0.3, 0.5)
		"corrupted_plant": return Color(0.3, 0.45, 0.15, 0.6)
		_: return Color(0.35, 0.4, 0.2, 0.5)


## Egyedi room: Plague Laboratory - pestis labor
## Alkímista asztal, mintaüvegek, mérgező folyadékok
func create_unique_room(room: DungeonRoom, parent: Node2D) -> void:
	var tile_size := 32
	var center := room.get_world_center()
	
	# Alkímista asztalok
	var table_offsets := [
		Vector2(-40, -20), Vector2(40, -20),
		Vector2(-40, 20), Vector2(40, 20),
	]
	for i in table_offsets.size():
		var table := Sprite2D.new()
		table.name = "AlchemyTable_%d" % i
		table.position = center + table_offsets[i]
		var img := Image.create(20, 12, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.4, 0.3, 0.2, 0.8))
		# Üvegcsék az asztalon
		for x in range(4, 8):
			for y in range(2, 8):
				img.set_pixel(x, y, Color(0.4, 0.7, 0.2, 0.7))
		for x in range(12, 16):
			for y in range(2, 8):
				img.set_pixel(x, y, Color(0.7, 0.3, 0.5, 0.7))
		table.texture = ImageTexture.create_from_image(img)
		parent.add_child(table)
	
	# Központi nagy katlan
	var cauldron := Sprite2D.new()
	cauldron.name = "PlagueCauldron"
	cauldron.position = center
	var c_img := Image.create(22, 20, false, Image.FORMAT_RGBA8)
	# Katlan test
	for x in 22:
		for y in 20:
			var dx := float(x - 11) / 11.0
			var dy := float(y - 10) / 10.0
			if dx * dx + dy * dy < 1.0:
				if y < 6:
					# Perem
					c_img.set_pixel(x, y, Color(0.3, 0.25, 0.2, 0.9))
				else:
					# Mérgező folyadék
					c_img.set_pixel(x, y, Color(0.35, 0.65, 0.15, 0.85))
	cauldron.texture = ImageTexture.create_from_image(c_img)
	parent.add_child(cauldron)
	
	# Katlan gőz/fény
	var cauldron_light := PointLight2D.new()
	cauldron_light.name = "CauldronLight"
	cauldron_light.position = center
	cauldron_light.color = Color(0.4, 0.7, 0.2, 0.4)
	cauldron_light.energy = 0.5
	var light_img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	for x in 48:
		for y in 48:
			var dx := float(x - 24) / 24.0
			var dy := float(y - 24) / 24.0
			var alpha := clampf(1.0 - sqrt(dx * dx + dy * dy), 0.0, 1.0)
			light_img.set_pixel(x, y, Color(1, 1, 1, alpha))
	cauldron_light.texture = ImageTexture.create_from_image(light_img)
	parent.add_child(cauldron_light)
	
	# Toxic puddle-ok a padlón
	var tiles := room.get_tiles()
	for tile_pos in tiles:
		if randf() < 0.08:
			var world_pos := Vector2(
				tile_pos.x * tile_size + tile_size / 2,
				tile_pos.y * tile_size + tile_size / 2
			)
			var puddle := Sprite2D.new()
			puddle.name = "ToxicPuddle_%d_%d" % [tile_pos.x, tile_pos.y]
			puddle.position = world_pos
			puddle.z_index = -1
			var p_img := Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
			# Szabálytalan tócsa
			for px in tile_size:
				for py in tile_size:
					var pdx := float(px - tile_size / 2) / float(tile_size / 2)
					var pdy := float(py - tile_size / 2) / float(tile_size / 2)
					if pdx * pdx + pdy * pdy < randf_range(0.3, 0.6):
						p_img.set_pixel(px, py, Color(0.35, 0.6, 0.15, 0.4))
			puddle.texture = ImageTexture.create_from_image(p_img)
			parent.add_child(puddle)
			puddle.set_meta("tile_type", "corruption")
	
	# Mintaüvegek polcokon
	for i in 3:
		var jar := Sprite2D.new()
		jar.name = "SpecimenJar_%d" % i
		jar.position = center + Vector2(randf_range(-55, 55), randf_range(-40, 40))
		var j_img := Image.create(8, 12, false, Image.FORMAT_RGBA8)
		# Üveg
		for x in range(1, 7):
			for y in range(2, 11):
				j_img.set_pixel(x, y, Color(0.6, 0.65, 0.6, 0.4))
		# Tartalom
		var content_color := [
			Color(0.4, 0.7, 0.2, 0.6),
			Color(0.7, 0.3, 0.4, 0.6),
			Color(0.3, 0.5, 0.7, 0.6),
		][i]
		for x in range(2, 6):
			for y in range(5, 10):
				j_img.set_pixel(x, y, content_color)
		# Kupak
		for x in range(2, 6):
			j_img.set_pixel(x, 1, Color(0.5, 0.4, 0.3, 0.8))
		jar.texture = ImageTexture.create_from_image(j_img)
		parent.add_child(jar)

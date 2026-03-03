## ThemeAshlands - Ashlands dungeon téma
## "Molten Forge" - olvadt kovácsműhely
class_name ThemeAshlands
extends BiomeThemeBase


func _init() -> void:
	biome_type = Enums.BiomeType.ASHLANDS
	theme_name = "Molten Forge"
	dungeon_name = "Molten Forge"
	
	ambient_color = Color(0.35, 0.15, 0.1, 1.0)
	torch_color = Color(0.9, 0.5, 0.2, 0.9)
	floor_tint = Color(0.35, 0.2, 0.15)
	wall_tint = Color(0.3, 0.15, 0.1)
	
	hazard_type = "lava"
	hazard_density = 0.1
	
	special_mechanics = ["lava_dot", "heat_exhaustion"]
	
	decoration_types = [
		"lava_crack", "ember", "ash_pile", "charred_bone",
		"slag_heap", "fire_geyser", "obsidian_shard",
	]
	prop_types = ["anvil", "forge_furnace", "weapon_rack"]
	
	boss_names = ["Infernal Warden", "Magma Colossus"]
	unique_enemies = ["fire_imp", "magma_slime", "ember_elemental"]


func apply_environmental_effect(player: Node, delta: float) -> void:
	# Lava DOT: láva tile-okon folyamatos sebzés
	# 10% max HP / másodperc
	if player.has_method("get_current_tile_type"):
		var tile_type = player.get_current_tile_type()
		if tile_type == "lava":
			if player.has_method("take_environmental_damage"):
				var max_hp: float = player.get("max_hp") if player.get("max_hp") else 100.0
				player.take_environmental_damage(max_hp * 0.1 * delta, "fire")


func _get_decoration_color(deco_type: String) -> Color:
	match deco_type:
		"lava_crack": return Color(0.9, 0.4, 0.1, 0.8)
		"ember": return Color(0.9, 0.6, 0.2, 0.6)
		"ash_pile": return Color(0.3, 0.28, 0.25, 0.5)
		"charred_bone": return Color(0.2, 0.18, 0.15, 0.6)
		"slag_heap": return Color(0.35, 0.25, 0.2, 0.6)
		"fire_geyser": return Color(0.95, 0.5, 0.15, 0.9)
		"obsidian_shard": return Color(0.15, 0.12, 0.15, 0.8)
		_: return Color(0.4, 0.25, 0.15, 0.5)


## Egyedi room: Forge Room - kovácsműhely
## Központi kovács, láva csatornák, fegyver tartók
func create_unique_room(room: DungeonRoom, parent: Node2D) -> void:
	var tile_size := 32
	var center := room.get_world_center()
	
	# Központi kohó
	var furnace := Sprite2D.new()
	furnace.name = "Furnace"
	furnace.position = center
	var f_img := Image.create(24, 28, false, Image.FORMAT_RGBA8)
	# Kohó test
	for x in 24:
		for y in 28:
			if y < 8:
				f_img.set_pixel(x, y, Color(0.3, 0.2, 0.15, 0.9))
			elif y < 20:
				f_img.set_pixel(x, y, Color(0.35, 0.25, 0.18, 0.9))
			else:
				f_img.set_pixel(x, y, Color(0.3, 0.2, 0.15, 0.9))
	# Tűz nyílás
	for x in range(8, 16):
		for y in range(10, 18):
			f_img.set_pixel(x, y, Color(0.9, 0.5, 0.15, 0.95))
	furnace.texture = ImageTexture.create_from_image(f_img)
	parent.add_child(furnace)
	
	# Kohó fény
	var forge_light := PointLight2D.new()
	forge_light.name = "ForgeLight"
	forge_light.position = center
	forge_light.color = Color(0.9, 0.5, 0.2, 0.6)
	forge_light.energy = 0.8
	var light_img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
	for x in 64:
		for y in 64:
			var dx := float(x - 32) / 32.0
			var dy := float(y - 32) / 32.0
			var alpha := clampf(1.0 - sqrt(dx * dx + dy * dy), 0.0, 1.0)
			light_img.set_pixel(x, y, Color(1, 1, 1, alpha))
	forge_light.texture = ImageTexture.create_from_image(light_img)
	parent.add_child(forge_light)
	
	# Láva csatornák (4 irányba a központból)
	var directions := [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]
	for dir_idx in directions.size():
		var dir: Vector2 = directions[dir_idx]
		for i in range(2, 5):
			var lava_pos := center + dir * float(i * tile_size)
			var lava := Sprite2D.new()
			lava.name = "LavaChannel_%d_%d" % [dir_idx, i]
			lava.position = lava_pos
			lava.z_index = -1
			var l_img := Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
			if dir.x != 0:
				# Vízszintes csatorna
				for x in tile_size:
					for y in range(12, 20):
						l_img.set_pixel(x, y, Color(0.9, 0.4 + randf() * 0.2, 0.1, 0.7))
			else:
				# Függőleges csatorna
				for x in range(12, 20):
					for y in tile_size:
						l_img.set_pixel(x, y, Color(0.9, 0.4 + randf() * 0.2, 0.1, 0.7))
			lava.texture = ImageTexture.create_from_image(l_img)
			parent.add_child(lava)
			lava.set_meta("tile_type", "lava")
	
	# Üllők és fegyver tartók
	var anvil_offsets := [Vector2(-50, 30), Vector2(50, 30)]
	for i in anvil_offsets.size():
		var anvil := Sprite2D.new()
		anvil.name = "Anvil_%d" % i
		anvil.position = center + anvil_offsets[i]
		var a_img := Image.create(12, 10, false, Image.FORMAT_RGBA8)
		a_img.fill(Color(0.4, 0.38, 0.35, 0.9))
		# Teteje szélesebb
		for x in 12:
			for y in range(0, 3):
				a_img.set_pixel(x, y, Color(0.5, 0.48, 0.45, 0.95))
		anvil.texture = ImageTexture.create_from_image(a_img)
		parent.add_child(anvil)

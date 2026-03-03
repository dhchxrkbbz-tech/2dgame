## ThemeMountains - Mountains dungeon téma
## "Deep Mine" - mély bánya
class_name ThemeMountains
extends BiomeThemeBase


func _init() -> void:
	biome_type = Enums.BiomeType.MOUNTAINS
	theme_name = "Deep Mine"
	dungeon_name = "Deep Mine"
	
	ambient_color = Color(0.2, 0.18, 0.22, 1.0)
	torch_color = Color(0.6, 0.5, 0.8, 0.7)
	floor_tint = Color(0.3, 0.28, 0.32)
	wall_tint = Color(0.25, 0.22, 0.28)
	
	hazard_type = "falling_rocks"
	hazard_density = 0.08
	
	special_mechanics = ["falling_rocks", "crystal_glow"]
	
	decoration_types = [
		"crystal_cluster", "mine_cart", "support_beam", "loose_rock",
		"gem_vein", "stalagmite", "cave_moss",
	]
	prop_types = ["mining_equipment", "ore_deposit", "wooden_scaffold"]
	
	boss_names = ["Rock Titan", "Crystal Golem"]
	unique_enemies = ["rock_golem", "bat_swarm", "cave_spider"]


func apply_environmental_effect(_player: Node, _delta: float) -> void:
	# Falling rocks: időnként szikla esik random helyekre
	# Implementáció: Timer-alapú hazard a dungeon_generator-ben
	pass


func _get_decoration_color(deco_type: String) -> Color:
	match deco_type:
		"crystal_cluster": return Color(0.5, 0.4, 0.9, 0.8)
		"mine_cart": return Color(0.5, 0.4, 0.3, 0.7)
		"support_beam": return Color(0.5, 0.4, 0.25, 0.7)
		"loose_rock": return Color(0.4, 0.38, 0.35, 0.6)
		"gem_vein": return Color(0.6, 0.3, 0.7, 0.7)
		"stalagmite": return Color(0.35, 0.32, 0.3, 0.7)
		"cave_moss": return Color(0.25, 0.4, 0.25, 0.4)
		_: return Color(0.35, 0.32, 0.35, 0.5)


## Egyedi room: Crystal Cavern - kristálybarlang
## Fénylő kristályok világítják meg a termet
func create_unique_room(room: DungeonRoom, parent: Node2D) -> void:
	var center := room.get_world_center()
	
	# Kristály klaszterek
	var crystal_configs := [
		{"offset": Vector2(-50, -30), "color": Color(0.4, 0.3, 0.9, 0.9), "size": Vector2(8, 20)},
		{"offset": Vector2(40, -20), "color": Color(0.9, 0.3, 0.5, 0.8), "size": Vector2(6, 16)},
		{"offset": Vector2(-30, 35), "color": Color(0.3, 0.8, 0.5, 0.85), "size": Vector2(10, 22)},
		{"offset": Vector2(45, 25), "color": Color(0.5, 0.4, 0.9, 0.9), "size": Vector2(7, 18)},
		{"offset": Vector2(0, -45), "color": Color(0.8, 0.6, 0.3, 0.8), "size": Vector2(9, 24)},
	]
	
	for i in crystal_configs.size():
		var cfg: Dictionary = crystal_configs[i]
		
		# Kristály sprite
		var crystal := Sprite2D.new()
		crystal.name = "Crystal_%d" % i
		crystal.position = center + cfg["offset"]
		var size: Vector2 = cfg["size"]
		var img := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
		var color: Color = cfg["color"]
		img.fill(color)
		# Fényesebb csúcs
		for x in int(size.x):
			for y in mini(4, int(size.y)):
				img.set_pixel(x, y, Color(color.r + 0.2, color.g + 0.2, color.b + 0.2, 1.0))
		crystal.texture = ImageTexture.create_from_image(img)
		parent.add_child(crystal)
		
		# Kristály fény
		var light := PointLight2D.new()
		light.name = "CrystalLight_%d" % i
		light.position = center + cfg["offset"]
		light.color = Color(color.r, color.g, color.b, 0.4)
		light.energy = 0.5
		var light_img := Image.create(64, 64, false, Image.FORMAT_RGBA8)
		for x in 64:
			for y in 64:
				var dx := float(x - 32) / 32.0
				var dy := float(y - 32) / 32.0
				var alpha := clampf(1.0 - sqrt(dx * dx + dy * dy), 0.0, 1.0)
				light_img.set_pixel(x, y, Color(1, 1, 1, alpha * alpha))
		light.texture = ImageTexture.create_from_image(light_img)
		parent.add_child(light)
	
	# Sztalagmitok a szoba szélén
	for i in 4:
		var angle := i * TAU / 4.0 + randf_range(-0.3, 0.3)
		var dist := randf_range(30, 55)
		var stalac := Sprite2D.new()
		stalac.name = "Stalagmite_%d" % i
		stalac.position = center + Vector2(cos(angle), sin(angle)) * dist
		var s_img := Image.create(6, 14, false, Image.FORMAT_RGBA8)
		s_img.fill(Color(0.35, 0.32, 0.3, 0.7))
		stalac.texture = ImageTexture.create_from_image(s_img)
		parent.add_child(stalac)

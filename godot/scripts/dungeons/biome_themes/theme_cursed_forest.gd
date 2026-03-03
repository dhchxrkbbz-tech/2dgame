## ThemeCursedForest - Cursed Forest dungeon téma
## "Witch's Hollow" - boszorkány barlang
class_name ThemeCursedForest
extends BiomeThemeBase


func _init() -> void:
	biome_type = Enums.BiomeType.CURSED_FOREST
	theme_name = "Witch's Hollow"
	dungeon_name = "Witch's Hollow"
	
	ambient_color = Color(0.15, 0.25, 0.15, 1.0)
	torch_color = Color(0.3, 0.8, 0.3, 0.7)
	floor_tint = Color(0.3, 0.35, 0.25)
	wall_tint = Color(0.2, 0.25, 0.18)
	
	hazard_type = "darkness"
	hazard_density = 0.0
	
	special_mechanics = ["reduced_visibility"]
	
	decoration_types = [
		"mushroom_cluster", "vine", "root", "cobweb", 
		"poison_mushroom", "moss_patch", "glow_mushroom",
	]
	prop_types = ["twisted_tree", "cauldron", "herb_basket"]
	
	boss_names = ["Dark Witch", "Corrupted Treant"]
	unique_enemies = ["witch_minion", "mushroom_spore", "vine_crawler"]


func apply_environmental_effect(player: Node, _delta: float) -> void:
	# Csökkentett látótáv (darkness hazard)
	# Implementáció: kisebb vision radius a FogOfWar-ban
	pass


func _get_decoration_color(deco_type: String) -> Color:
	match deco_type:
		"mushroom_cluster": return Color(0.5, 0.3, 0.6, 0.7)
		"vine": return Color(0.2, 0.5, 0.2, 0.6)
		"root": return Color(0.4, 0.3, 0.2, 0.7)
		"cobweb": return Color(0.8, 0.8, 0.8, 0.3)
		"poison_mushroom": return Color(0.4, 0.8, 0.2, 0.6)
		"moss_patch": return Color(0.2, 0.6, 0.2, 0.4)
		"glow_mushroom": return Color(0.3, 0.9, 0.5, 0.8)
		_: return Color(0.3, 0.4, 0.3, 0.5)


## Egyedi room: Mushroom Garden (heal + poison trap)
func create_unique_room(room: DungeonRoom, parent: Node2D) -> void:
	var center := room.get_world_center()
	
	# Glow mushroom-ok a szoba körül
	for i in 6:
		var offset := Vector2(randf_range(-48, 48), randf_range(-48, 48))
		var sprite := Sprite2D.new()
		sprite.name = "GlowMushroom_%d" % i
		sprite.position = center + offset
		var img := Image.create(12, 12, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.3, 0.9, 0.5, 0.8))
		sprite.texture = ImageTexture.create_from_image(img)
		parent.add_child(sprite)
		
		# Fényforrás
		var light := PointLight2D.new()
		light.position = center + offset
		light.color = Color(0.3, 0.8, 0.4, 0.4)
		light.energy = 0.3
		var light_img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
		for x in 32:
			for y in 32:
				var dx := float(x - 16) / 16.0
				var dy := float(y - 16) / 16.0
				var alpha := clampf(1.0 - sqrt(dx * dx + dy * dy), 0.0, 1.0)
				light_img.set_pixel(x, y, Color(1, 1, 1, alpha))
		light.texture = ImageTexture.create_from_image(light_img)
		parent.add_child(light)

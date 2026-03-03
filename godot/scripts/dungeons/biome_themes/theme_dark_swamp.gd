## ThemeDarkSwamp - Dark Swamp dungeon téma
## "Sunken Temple" - elsüllyedt templom
class_name ThemeDarkSwamp
extends BiomeThemeBase


func _init() -> void:
	biome_type = Enums.BiomeType.DARK_SWAMP
	theme_name = "Sunken Temple"
	dungeon_name = "Sunken Temple"
	
	ambient_color = Color(0.15, 0.2, 0.25, 1.0)
	torch_color = Color(0.2, 0.5, 0.7, 0.6)
	floor_tint = Color(0.25, 0.3, 0.25)
	wall_tint = Color(0.15, 0.2, 0.18)
	
	hazard_type = "swamp_slow"
	hazard_density = 0.15
	
	special_mechanics = ["flooded_rooms", "swamp_slow"]
	
	decoration_types = [
		"lily_pad", "swamp_vine", "algae", "bubble",
		"dead_fish", "reed", "mud_puddle",
	]
	prop_types = ["sunken_pillar", "moss_statue", "broken_altar"]
	
	boss_names = ["Bog Horror", "Swamp Hydra"]
	unique_enemies = ["bog_lurker", "poison_frog", "swamp_leech"]


func apply_environmental_effect(player: Node, _delta: float) -> void:
	# Swamp slow: lassítja a playert víz tile-okon
	# Implementáció: mozgássebesség 60%-ra csökken vizes tile-okon
	if player.has_method("get_current_tile_type"):
		var tile_type = player.get_current_tile_type()
		if tile_type == "water":
			if player.has_method("apply_speed_modifier"):
				player.apply_speed_modifier("swamp_slow", 0.6)


func _get_decoration_color(deco_type: String) -> Color:
	match deco_type:
		"lily_pad": return Color(0.2, 0.6, 0.3, 0.5)
		"swamp_vine": return Color(0.3, 0.4, 0.2, 0.6)
		"algae": return Color(0.2, 0.5, 0.2, 0.4)
		"bubble": return Color(0.5, 0.6, 0.7, 0.3)
		"dead_fish": return Color(0.5, 0.5, 0.4, 0.5)
		"reed": return Color(0.4, 0.5, 0.3, 0.6)
		"mud_puddle": return Color(0.3, 0.25, 0.2, 0.5)
		_: return Color(0.3, 0.35, 0.25, 0.5)


## Egyedi room: Flooded Chamber - részben elárasztott terem
func create_unique_room(room: DungeonRoom, parent: Node2D) -> void:
	var tile_size := 32
	var tiles := room.get_tiles()
	
	# Vizes tile-ok a szoba alsó 40%-ában
	var water_y_start := room.position.y + int(room.height * 0.6)
	
	for tile_pos in tiles:
		if tile_pos.y >= water_y_start:
			var world_pos := Vector2(tile_pos.x * tile_size + tile_size / 2, tile_pos.y * tile_size + tile_size / 2)
			var water_sprite := Sprite2D.new()
			water_sprite.name = "Water_%d_%d" % [tile_pos.x, tile_pos.y]
			water_sprite.position = world_pos
			water_sprite.z_index = -1
			var img := Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
			img.fill(Color(0.15, 0.3, 0.45, 0.5))
			water_sprite.texture = ImageTexture.create_from_image(img)
			parent.add_child(water_sprite)
	
	# Elsüllyedt oszlopok
	for i in 3:
		var offset := Vector2(randf_range(-40, 40), randf_range(-40, 40))
		var center := room.get_world_center()
		var pillar := Sprite2D.new()
		pillar.name = "SunkenPillar_%d" % i
		pillar.position = center + offset
		var img := Image.create(10, 16, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.3, 0.35, 0.3, 0.7))
		pillar.texture = ImageTexture.create_from_image(img)
		parent.add_child(pillar)

## ThemeFrozenWastes - Frozen Wastes dungeon téma
## "Frost Citadel" - jégcitadella
class_name ThemeFrozenWastes
extends BiomeThemeBase


func _init() -> void:
	biome_type = Enums.BiomeType.FROZEN_WASTES
	theme_name = "Frost Citadel"
	dungeon_name = "Frost Citadel"
	
	ambient_color = Color(0.3, 0.35, 0.45, 1.0)
	torch_color = Color(0.5, 0.7, 0.9, 0.6)
	floor_tint = Color(0.4, 0.45, 0.55)
	wall_tint = Color(0.35, 0.4, 0.5)
	
	hazard_type = "ice_slide"
	hazard_density = 0.12
	
	special_mechanics = ["ice_slide", "frozen_enemies"]
	
	decoration_types = [
		"ice_shard", "frozen_statue", "snowdrift", "icicle",
		"frost_rune", "frozen_web", "ice_crystal",
	]
	prop_types = ["frozen_chest", "ice_pillar", "snow_pile"]
	
	boss_names = ["Frost Guardian", "Ice Wyrm"]
	unique_enemies = ["frost_elemental", "ice_wraith", "frozen_skeleton"]


func apply_environmental_effect(player: Node, _delta: float) -> void:
	# Ice slide: jégen csúszás (momentum megmarad)
	# Implementáció: jég tile-on a player sebessége tovább viszi
	if player.has_method("get_current_tile_type"):
		var tile_type = player.get_current_tile_type()
		if tile_type == "ice":
			if player.has_method("apply_ice_physics"):
				player.apply_ice_physics()


func _get_decoration_color(deco_type: String) -> Color:
	match deco_type:
		"ice_shard": return Color(0.6, 0.75, 0.9, 0.7)
		"frozen_statue": return Color(0.5, 0.6, 0.7, 0.8)
		"snowdrift": return Color(0.8, 0.85, 0.9, 0.5)
		"icicle": return Color(0.55, 0.7, 0.85, 0.7)
		"frost_rune": return Color(0.4, 0.6, 0.9, 0.5)
		"frozen_web": return Color(0.7, 0.8, 0.9, 0.3)
		"ice_crystal": return Color(0.5, 0.65, 0.85, 0.8)
		_: return Color(0.5, 0.6, 0.7, 0.5)


## Egyedi room: Frozen Lake - befagyott tó terem
## Csúszós felület, repedező jég mechanika
func create_unique_room(room: DungeonRoom, parent: Node2D) -> void:
	var tile_size := 32
	var center := room.get_world_center()
	var tiles := room.get_tiles()
	
	# Jég borítás a szoba belső részén (keret nélkül)
	var inner_margin := 2
	for tile_pos in tiles:
		var local_x := tile_pos.x - room.position.x
		var local_y := tile_pos.y - room.position.y
		
		if local_x >= inner_margin and local_x < room.width - inner_margin \
		   and local_y >= inner_margin and local_y < room.height - inner_margin:
			var world_pos := Vector2(
				tile_pos.x * tile_size + tile_size / 2,
				tile_pos.y * tile_size + tile_size / 2
			)
			var ice := Sprite2D.new()
			ice.name = "Ice_%d_%d" % [tile_pos.x, tile_pos.y]
			ice.position = world_pos
			ice.z_index = -1
			var img := Image.create(tile_size, tile_size, false, Image.FORMAT_RGBA8)
			# Változatos jég szín
			var blue_shift := randf_range(-0.05, 0.05)
			img.fill(Color(0.55 + blue_shift, 0.7 + blue_shift, 0.85, 0.4))
			# Repedések
			if randf() < 0.2:
				for x_off in range(8, 24):
					var y_off := int(tile_size / 2 + sin(x_off * 0.5) * 3)
					if y_off >= 0 and y_off < tile_size:
						img.set_pixel(x_off, y_off, Color(0.4, 0.55, 0.7, 0.6))
			ice.texture = ImageTexture.create_from_image(img)
			parent.add_child(ice)
			
			ice.set_meta("tile_type", "ice")
	
	# Jégcsapok a szoba szélén
	var icicle_positions := [
		center + Vector2(-60, -50),
		center + Vector2(60, -50),
		center + Vector2(-40, -50),
		center + Vector2(40, -50),
	]
	
	for i in icicle_positions.size():
		var icicle := Sprite2D.new()
		icicle.name = "Icicle_%d" % i
		icicle.position = icicle_positions[i]
		var img := Image.create(4, 16, false, Image.FORMAT_RGBA8)
		# Jégcsap: fentről lefelé vékonyodik
		for y in 16:
			var width_at_y := maxi(1, int(4 * (1.0 - float(y) / 16.0)))
			var x_start := (4 - width_at_y) / 2
			for x in range(x_start, x_start + width_at_y):
				img.set_pixel(x, y, Color(0.6, 0.75, 0.9, 0.8))
		icicle.texture = ImageTexture.create_from_image(img)
		parent.add_child(icicle)

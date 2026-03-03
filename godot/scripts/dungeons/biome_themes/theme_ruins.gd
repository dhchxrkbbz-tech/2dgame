## ThemeRuins - Ancient Ruins dungeon téma
## "Ancient Crypt" - ősi kripta
class_name ThemeRuins
extends BiomeThemeBase


func _init() -> void:
	biome_type = Enums.BiomeType.RUINS
	theme_name = "Ancient Crypt"
	dungeon_name = "Ancient Crypt"
	
	ambient_color = Color(0.25, 0.2, 0.15, 1.0)
	torch_color = Color(0.8, 0.6, 0.3, 0.8)
	floor_tint = Color(0.35, 0.3, 0.25)
	wall_tint = Color(0.3, 0.25, 0.2)
	
	hazard_type = "none"
	hazard_density = 0.0
	
	special_mechanics = ["skeleton_respawn"]
	
	decoration_types = [
		"bone_pile", "coffin", "candelabra", "cobweb",
		"broken_pottery", "cracked_floor", "ancient_rune",
	]
	prop_types = ["sarcophagus", "stone_tablet", "rusted_gate"]
	
	boss_names = ["Necromancer King", "Ancient Lich"]
	unique_enemies = ["skeleton_warrior", "ghost", "mummy"]


func apply_environmental_effect(_player: Node, _delta: float) -> void:
	# Skeleton Respawn: 30% eséllyel visszajönnek a csontváz ellenségek
	# Implementáció: dungeon_enemy_spawner-ben kezelve
	pass


func _get_decoration_color(deco_type: String) -> Color:
	match deco_type:
		"bone_pile": return Color(0.7, 0.65, 0.55, 0.6)
		"coffin": return Color(0.4, 0.3, 0.2, 0.8)
		"candelabra": return Color(0.6, 0.5, 0.3, 0.7)
		"cobweb": return Color(0.8, 0.8, 0.8, 0.3)
		"broken_pottery": return Color(0.5, 0.4, 0.3, 0.5)
		"cracked_floor": return Color(0.35, 0.3, 0.25, 0.4)
		"ancient_rune": return Color(0.5, 0.4, 0.7, 0.5)
		_: return Color(0.4, 0.35, 0.3, 0.5)


## Egyedi room: Coffin Chamber - koporsós szoba
## 30% eséllyel a koporsók kinyílnak és csontváz jön belőlük
func create_unique_room(room: DungeonRoom, parent: Node2D) -> void:
	var center := room.get_world_center()
	
	# Koporsók elrendezése sorokba
	var coffin_count := randi_range(4, 8)
	var row_count := 2
	var coffins_per_row := ceili(float(coffin_count) / row_count)
	
	for i in coffin_count:
		var row := i / coffins_per_row
		var col := i % coffins_per_row
		var offset := Vector2(
			(col - coffins_per_row / 2.0) * 40 + 20,
			(row - row_count / 2.0) * 50 + 25
		)
		
		var coffin := Sprite2D.new()
		coffin.name = "Coffin_%d" % i
		coffin.position = center + offset
		var img := Image.create(14, 24, false, Image.FORMAT_RGBA8)
		img.fill(Color(0.35, 0.25, 0.15, 0.8))
		# Fém díszítés (felső rész)
		for x in range(4, 10):
			for y in range(2, 4):
				img.set_pixel(x, y, Color(0.5, 0.45, 0.3, 0.9))
		coffin.texture = ImageTexture.create_from_image(img)
		parent.add_child(coffin)
		
		# Koporsó metadata: respawn chance
		coffin.set_meta("can_respawn", randf() < 0.3)
		coffin.set_meta("enemy_type", "skeleton_warrior")
	
	# Központi szarkofág
	var sarcophagus := Sprite2D.new()
	sarcophagus.name = "CentralSarcophagus"
	sarcophagus.position = center
	var sarc_img := Image.create(20, 32, false, Image.FORMAT_RGBA8)
	sarc_img.fill(Color(0.4, 0.35, 0.25, 0.9))
	for x in range(3, 17):
		for y in range(2, 6):
			sarc_img.set_pixel(x, y, Color(0.6, 0.5, 0.3, 0.9))
	sarcophagus.texture = ImageTexture.create_from_image(sarc_img)
	parent.add_child(sarcophagus)

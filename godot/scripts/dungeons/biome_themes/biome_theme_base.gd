## BiomeThemeBase - Alap osztály biome-specifikus dungeon témákhoz
## Minden biome theme ebből származik
class_name BiomeThemeBase
extends RefCounted

## Biome azonosító
var biome_type: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW
var theme_name: String = "Default"
var dungeon_name: String = "Dungeon"

## Vizuális paraméterek
var ambient_color: Color = Color(0.3, 0.3, 0.3, 1.0)
var torch_color: Color = Color(0.9, 0.7, 0.4, 0.8)
var floor_tint: Color = Color.WHITE
var wall_tint: Color = Color.WHITE

## Hazard beállítások
var hazard_type: String = ""  # "lava", "ice", "swamp", "corruption", "darkness"
var hazard_density: float = 0.0
var hazard_damage_percent: float = 0.0

## Speciális mechanikák
var special_mechanics: Array[String] = []

## Enemy módosítók
var enemy_type_weights: Dictionary = {}  # EnemyType -> weight
var unique_enemies: Array[String] = []

## Dekoráció típusok
var decoration_types: Array[String] = []
var prop_types: Array[String] = []

## Boss info
var boss_names: Array[String] = []


## Környezeti hatás alkalmazása a játékosra (tick-enként)
func apply_environmental_effect(_player: Node, _delta: float) -> void:
	pass


## Szoba dekorálása biome-specifikusan
func decorate_room(room: DungeonRoom, parent: Node2D, rng: RandomNumberGenerator) -> void:
	var tiles := room.get_tiles()
	var density := 0.05 * (decoration_types.size() / maxf(1.0, 5.0))
	
	for tile in tiles:
		if rng.randf() < density:
			var deco_type := decoration_types[rng.randi() % decoration_types.size()]
			var world_pos := Vector2(tile.x * Constants.TILE_SIZE, tile.y * Constants.TILE_SIZE)
			_create_decoration_sprite(deco_type, world_pos, parent)


func _create_decoration_sprite(deco_type: String, world_pos: Vector2, parent: Node2D) -> void:
	var sprite := Sprite2D.new()
	sprite.name = "Deco_%s" % deco_type
	sprite.position = world_pos
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(_get_decoration_color(deco_type))
	sprite.texture = ImageTexture.create_from_image(img)
	sprite.modulate.a = 0.6
	parent.add_child(sprite)


func _get_decoration_color(_deco_type: String) -> Color:
	return Color(0.4, 0.4, 0.4, 0.5)


## CanvasModulate beállítás a biome-hoz
func create_ambient_modulate() -> CanvasModulate:
	var modulate := CanvasModulate.new()
	modulate.name = "BiomeAmbient"
	modulate.color = ambient_color
	return modulate


## Biome-specifikus egyedi room létrehozása
func create_unique_room(_room: DungeonRoom, _parent: Node2D) -> void:
	pass  # Override biome-specifikus room-okhoz

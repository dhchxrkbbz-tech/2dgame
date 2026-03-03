## FogOfWar - Fog of War vezérlés dungeon-ökben
## Dinamikus texture frissítés a játékos pozíciója alapján
class_name FogOfWar
extends Node2D

## Fog állapotok
const FOG_HIDDEN: float = 0.0      # Soha nem látta
const FOG_EXPLORED: float = 0.5    # Korábban látta
const FOG_VISIBLE: float = 1.0     # Most látja

## Konfiguráció
@export var vision_radius: int = 8  # Tile sugár
@export var enabled: bool = true

## Belső adatok
var fog_image: Image
var fog_texture: ImageTexture
var fog_data: Dictionary = {}  # Vector2i -> float (0.0-1.0)
var dungeon_width: int = 80
var dungeon_height: int = 60
var tile_size: int = Constants.TILE_SIZE

## Shader sprite
var fog_sprite: Sprite2D
var fog_material: ShaderMaterial


func _ready() -> void:
	z_index = 100  # Fog felül legyen


## Inicializálás a dungeon mérettel
func initialize(width: int, height: int) -> void:
	dungeon_width = width
	dungeon_height = height
	
	# Fog image létrehozás
	fog_image = Image.create(dungeon_width, dungeon_height, false, Image.FORMAT_RF)
	fog_image.fill(Color(0, 0, 0, 1))  # Minden rejtett
	
	fog_texture = ImageTexture.create_from_image(fog_image)
	
	# Fog data inicializálás
	fog_data.clear()
	for x in dungeon_width:
		for y in dungeon_height:
			fog_data[Vector2i(x, y)] = FOG_HIDDEN
	
	# Fog sprite a shader-rel
	_create_fog_display()


func _create_fog_display() -> void:
	fog_sprite = Sprite2D.new()
	fog_sprite.name = "FogSprite"
	fog_sprite.centered = false
	
	# Fog shader material
	var shader := Shader.new()
	shader.code = _get_fog_shader_code()
	fog_material = ShaderMaterial.new()
	fog_material.shader = shader
	fog_material.set_shader_parameter("fog_texture", fog_texture)
	fog_material.set_shader_parameter("explored_alpha", 0.4)
	fog_material.set_shader_parameter("visible_alpha", 0.0)
	fog_material.set_shader_parameter("hidden_alpha", 1.0)
	
	# Fog sprite mérete = dungeon pixel méret
	var display_image := Image.create(
		dungeon_width * tile_size, dungeon_height * tile_size,
		false, Image.FORMAT_RGBA8
	)
	display_image.fill(Color(0, 0, 0, 1))
	fog_sprite.texture = ImageTexture.create_from_image(display_image)
	fog_sprite.material = fog_material
	
	add_child(fog_sprite)


## Játékos pozíció frissítés
func update_vision(player_tile_pos: Vector2i) -> void:
	if not enabled:
		return
	
	# Előző visible tile-ok → explored
	for pos in fog_data:
		if fog_data[pos] == FOG_VISIBLE:
			fog_data[pos] = FOG_EXPLORED
	
	# Új visible terület (kör alakú)
	for dx in range(-vision_radius, vision_radius + 1):
		for dy in range(-vision_radius, vision_radius + 1):
			if dx * dx + dy * dy <= vision_radius * vision_radius:
				var check := player_tile_pos + Vector2i(dx, dy)
				if check.x >= 0 and check.x < dungeon_width and \
				   check.y >= 0 and check.y < dungeon_height:
					fog_data[check] = FOG_VISIBLE
	
	# Fog texture frissítés
	_update_fog_texture()


## Teljes szoba felfedezése
func reveal_room(room_rect: Rect2i) -> void:
	for x in range(room_rect.position.x - 1, room_rect.end.x + 1):
		for y in range(room_rect.position.y - 1, room_rect.end.y + 1):
			var pos := Vector2i(x, y)
			if pos.x >= 0 and pos.x < dungeon_width and \
			   pos.y >= 0 and pos.y < dungeon_height:
				if fog_data.get(pos, FOG_HIDDEN) == FOG_HIDDEN:
					fog_data[pos] = FOG_EXPLORED


## Fog texture frissítés az aktuális adatokkal
func _update_fog_texture() -> void:
	if not fog_image:
		return
	
	for x in dungeon_width:
		for y in dungeon_height:
			var value: float = fog_data.get(Vector2i(x, y), FOG_HIDDEN)
			fog_image.set_pixel(x, y, Color(value, 0, 0, 1))
	
	fog_texture.update(fog_image)
	if fog_material:
		fog_material.set_shader_parameter("fog_texture", fog_texture)


## Tile pozíció az adott fog állapotban van-e
func is_tile_visible(tile_pos: Vector2i) -> bool:
	return fog_data.get(tile_pos, FOG_HIDDEN) == FOG_VISIBLE


func is_tile_explored(tile_pos: Vector2i) -> bool:
	return fog_data.get(tile_pos, FOG_HIDDEN) >= FOG_EXPLORED


func is_tile_hidden(tile_pos: Vector2i) -> bool:
	return fog_data.get(tile_pos, FOG_HIDDEN) == FOG_HIDDEN


## Fog kikapcsolás (debug vagy multiplayer)
func disable_fog() -> void:
	enabled = false
	if fog_sprite:
		fog_sprite.visible = false


## Fog bekapcsolás
func enable_fog() -> void:
	enabled = true
	if fog_sprite:
		fog_sprite.visible = true


## Teljes dungeon felfedezése (cheat/debug)
func reveal_all() -> void:
	for pos in fog_data:
		fog_data[pos] = FOG_VISIBLE
	_update_fog_texture()


## Fog of War shader kód
func _get_fog_shader_code() -> String:
	return """
shader_type canvas_item;

uniform sampler2D fog_texture : filter_nearest;
uniform float explored_alpha : hint_range(0.0, 1.0) = 0.4;
uniform float visible_alpha : hint_range(0.0, 1.0) = 0.0;
uniform float hidden_alpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec2 fog_uv = SCREEN_UV;
	float fog_value = texture(fog_texture, UV).r;
	float alpha;
	if (fog_value > 0.9) {
		alpha = visible_alpha;
	} else if (fog_value > 0.1) {
		alpha = explored_alpha;
	} else {
		alpha = hidden_alpha;
	}
	COLOR = vec4(0.0, 0.0, 0.0, alpha);
}
"""


## Cleanup
func clear() -> void:
	fog_data.clear()
	if fog_sprite and is_instance_valid(fog_sprite):
		fog_sprite.queue_free()
		fog_sprite = null

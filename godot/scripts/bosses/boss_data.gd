## BossData - Boss statisztikák Resource
class_name BossData
extends Resource

@export var boss_name: String = ""
@export var boss_id: String = ""
@export var tier: int = 1  # 1-4
@export var base_hp: int = 800
@export var armor: int = 10
@export var damage: int = 25
@export var speed: float = 40.0
@export var attack_speed: float = 1.0
@export var recommended_level_min: int = 5
@export var recommended_level_max: int = 10
@export var required_players: int = 1
@export var enrage_time: float = 0.0  # 0 = nincs enrage
@export var sprite_size: Vector2 = Vector2(48, 48)  # Pixel size
@export var collision_size: Vector2 = Vector2(32, 32)
@export var biome: int = Enums.BiomeType.CURSED_FOREST
@export var sprite_color: Color = Color.RED

# Dinamikusan beállított
var phases: Array[BossPhase] = []
var loot_table: Dictionary = {}  # {"guaranteed": [], "rare": [], "ultra_rare": []}

## EnemyData - Enemy definíció Resource
## Tartalmazza az összes enemy statisztikát és konfigurációt
class_name EnemyData
extends Resource

## Enemy azonosítás
@export var enemy_name: String = ""
@export var enemy_id: String = ""

## Típus
@export var enemy_category: Enums.EnemyType = Enums.EnemyType.MELEE
@export var sub_type: int = 0  # 0=normal, 1=charger, 2=brute, 3=swarmer, 4=sniper

## Alap statisztikák (Level 1)
@export var base_hp: int = 40
@export var base_damage: int = 10
@export var base_armor: int = 3
@export var base_speed: float = 60.0
@export var attack_speed: float = 1.5  # Másodperc/attack

## Tartomány
@export var detection_range: float = 192.0  # 6 tile
@export var attack_range: float = 32.0  # 1 tile (melee)
@export var leash_range: float = 960.0  # 30 tile

## Jutalom
@export var base_xp: int = 15
@export var gold_range: Vector2i = Vector2i(2, 8)

## Biome
@export var biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW

## Pack
@export var pack_size_range: Vector2i = Vector2i(1, 1)
@export var can_be_elite: bool = true

## Vizuális
@export var sprite_color: Color = Color.RED
@export var sprite_size: Vector2i = Vector2i(24, 24)


func get_scaled_hp(level: int) -> int:
	return DamageCalculator.scale_hp(base_hp, level)

func get_scaled_damage(level: int) -> int:
	return DamageCalculator.scale_damage(base_damage, level)

func get_scaled_armor(level: int) -> int:
	return DamageCalculator.scale_armor(base_armor, level)

func get_scaled_xp(level: int) -> int:
	return DamageCalculator.scale_xp(base_xp, level)

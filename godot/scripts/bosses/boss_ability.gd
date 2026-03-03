## BossAbility - Boss képesség definíció
class_name BossAbility
extends RefCounted

enum AreaType { NONE, CIRCLE, CONE, LINE, RECT }

var ability_name: String = ""
var damage: float = 0.0
var cooldown: float = 5.0
var current_cooldown: float = 0.0
var range: float = 128.0
var area_type: AreaType = AreaType.NONE
var area_size: Vector2 = Vector2(64, 64)
var telegraph_time: float = 1.0
var animation_name: String = ""
var priority: int = 0  # Magasabb = előbb használja
var min_range: float = 0.0  # Minimum távolság (melee vs ranged)
var status_effect: int = -1  # Enums.EffectType
var status_duration: float = 0.0
var projectile_count: int = 1
var projectile_speed: float = 200.0
var is_tracking: bool = false
var summon_count: int = 0
var summon_data: Dictionary = {}  # Summon paraméterek
var phase_only: int = -1  # Melyik phase-ban elérhető (-1 = mind)
var requires_players: int = 1  # Min játékos szám ahol aktív
var callback_name: String = ""  # Custom logic function neve a boss-on


func is_ready() -> bool:
	return current_cooldown <= 0.0


func use() -> void:
	current_cooldown = cooldown


func update(delta: float) -> void:
	if current_cooldown > 0.0:
		current_cooldown -= delta


func is_in_range(distance: float) -> bool:
	return distance >= min_range and distance <= range


static func create(p_name: String, p_damage: float, p_cooldown: float, p_range: float, 
		p_area_type: AreaType = AreaType.NONE, p_area_size: Vector2 = Vector2.ZERO,
		p_telegraph: float = 1.0) -> BossAbility:
	var ability := BossAbility.new()
	ability.ability_name = p_name
	ability.damage = p_damage
	ability.cooldown = p_cooldown
	ability.range = p_range
	ability.area_type = p_area_type
	ability.area_size = p_area_size
	ability.telegraph_time = p_telegraph
	return ability

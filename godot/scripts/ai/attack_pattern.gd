## AttackPattern - Enemy támadás minta resource
## Minden attack típus adatait tárolja: damage, cooldown, range, effect, telegraph
class_name AttackPattern
extends Resource

## Attack azonosítás
@export var attack_name: String = "Basic Attack"
@export var attack_id: String = ""

## Damage
@export var damage_multiplier: float = 1.0  # base_damage * multiplier
@export var damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL

## Timing
@export var cooldown: float = 1.5
@export var telegraph_time: float = 0.0  # 0 = nincs telegraph
@export var cast_time: float = 0.0  # 0 = instant

## Range
@export var attack_range: float = 32.0  # pixel
@export var min_range: float = 0.0  # minimum range (caster/ranged)

## Area
enum AreaType { NONE, CIRCLE, CONE, LINE, RECT }
@export var area_type: AreaType = AreaType.NONE
@export var area_size: Vector2 = Vector2(32, 32)  # sugár vagy méret

## Projectile
@export var is_projectile: bool = false
@export var projectile_speed: float = 150.0
@export var projectile_tracking: float = 0.0  # 0 = egyenes vonal
@export var projectile_pierce: int = 0
@export var projectile_aoe_radius: float = 0.0  # 0 = nincs splash

## Status effect
@export var applies_effect: bool = false
@export var effect_type: Enums.EffectType = Enums.EffectType.SLOW
@export var effect_duration: float = 0.0
@export var effect_value: float = 0.0

## Knockback
@export var knockback_force: float = 0.0

## Speciális
@export var is_charge: bool = false
@export var charge_speed: float = 300.0
@export var charge_distance: float = 128.0

@export var is_summon: bool = false
@export var summon_count: int = 0
@export var summon_enemy_id: String = ""

@export var is_heal: bool = false
@export var heal_percent: float = 0.0  # % of target max HP

@export var is_buff: bool = false
@export var buff_effect_type: Enums.EffectType = Enums.EffectType.DAMAGE_UP
@export var buff_duration: float = 0.0
@export var buff_value: float = 0.0

## Prioritás (magasabb = előbb próbálja)
@export var priority: int = 0

## Animáció
@export var animation_name: String = "attack_1"

## Cooldown nyilvántartás (futási idő, nem mentett)
var _current_cooldown: float = 0.0


func is_ready() -> bool:
	return _current_cooldown <= 0.0


func trigger() -> void:
	_current_cooldown = cooldown


func update_cooldown(delta: float) -> void:
	if _current_cooldown > 0:
		_current_cooldown -= delta


func reset_cooldown() -> void:
	_current_cooldown = 0.0


# === Factory methods ===

static func create_melee_basic() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Basic Slash"
	p.attack_id = "basic_slash"
	p.damage_multiplier = 1.0
	p.cooldown = 1.5
	p.attack_range = 32.0
	p.area_type = AreaType.NONE
	p.animation_name = "attack_1"
	return p


static func create_heavy_strike() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Heavy Strike"
	p.attack_id = "heavy_strike"
	p.damage_multiplier = 2.0
	p.cooldown = 3.0
	p.attack_range = 48.0
	p.telegraph_time = 0.8
	p.applies_effect = true
	p.effect_type = Enums.EffectType.STUN
	p.effect_duration = 1.0
	p.priority = 2
	p.animation_name = "attack_2"
	return p


static func create_charge_attack() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Charge Attack"
	p.attack_id = "charge"
	p.damage_multiplier = 1.5
	p.cooldown = 5.0
	p.attack_range = 128.0
	p.is_charge = true
	p.charge_speed = 300.0
	p.charge_distance = 128.0
	p.knockback_force = 100.0
	p.priority = 3
	p.animation_name = "attack_1"
	return p


static func create_bite() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Bite"
	p.attack_id = "bite"
	p.damage_multiplier = 1.2
	p.cooldown = 2.0
	p.attack_range = 32.0
	p.applies_effect = true
	p.effect_type = Enums.EffectType.POISON_DOT
	p.effect_duration = 4.0
	p.effect_value = 3.0
	p.animation_name = "attack_1"
	return p


static func create_arrow_shot() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Arrow Shot"
	p.attack_id = "arrow_shot"
	p.damage_multiplier = 1.0
	p.cooldown = 2.0
	p.attack_range = 256.0
	p.is_projectile = true
	p.projectile_speed = 200.0
	p.animation_name = "attack_1"
	return p


static func create_poison_spit() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Poison Spit"
	p.attack_id = "poison_spit"
	p.damage_multiplier = 0.6
	p.cooldown = 3.0
	p.attack_range = 192.0
	p.is_projectile = true
	p.projectile_speed = 120.0
	p.projectile_aoe_radius = 48.0
	p.applies_effect = true
	p.effect_type = Enums.EffectType.POISON_DOT
	p.effect_duration = 4.0
	p.effect_value = 4.0
	p.priority = 1
	p.animation_name = "attack_1"
	return p


static func create_sniper_shot() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Sniper Shot"
	p.attack_id = "sniper_shot"
	p.damage_multiplier = 2.0
	p.cooldown = 5.0
	p.attack_range = 320.0
	p.telegraph_time = 1.5
	p.is_projectile = true
	p.projectile_speed = 350.0
	p.priority = 2
	p.animation_name = "attack_1"
	return p


static func create_web_shot() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Web Shot"
	p.attack_id = "web_shot"
	p.damage_multiplier = 0.2
	p.cooldown = 4.0
	p.attack_range = 192.0
	p.is_projectile = true
	p.projectile_speed = 100.0
	p.applies_effect = true
	p.effect_type = Enums.EffectType.ROOT
	p.effect_duration = 2.0
	p.priority = 3
	p.animation_name = "attack_1"
	return p


static func create_fireball() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Fireball"
	p.attack_id = "fireball"
	p.damage_multiplier = 1.5
	p.damage_type = Enums.DamageType.ARCANE
	p.cooldown = 3.0
	p.attack_range = 256.0
	p.telegraph_time = 0.5
	p.is_projectile = true
	p.projectile_speed = 130.0
	p.projectile_aoe_radius = 64.0
	p.priority = 1
	p.animation_name = "attack_1"
	return p


static func create_frost_nova() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Frost Nova"
	p.attack_id = "frost_nova"
	p.damage_multiplier = 0.8
	p.damage_type = Enums.DamageType.FROST
	p.cooldown = 8.0
	p.attack_range = 96.0
	p.min_range = 0.0
	p.telegraph_time = 1.0
	p.area_type = AreaType.CIRCLE
	p.area_size = Vector2(96, 96)
	p.applies_effect = true
	p.effect_type = Enums.EffectType.SLOW
	p.effect_duration = 2.0
	p.effect_value = 50.0
	p.priority = 3
	p.animation_name = "attack_1"
	return p


static func create_curse() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Curse"
	p.attack_id = "curse"
	p.damage_multiplier = 0.0
	p.damage_type = Enums.DamageType.SHADOW
	p.cooldown = 10.0
	p.attack_range = 224.0
	p.applies_effect = true
	p.effect_type = Enums.EffectType.DAMAGE_DOWN
	p.effect_duration = 8.0
	p.effect_value = 20.0
	p.priority = 2
	p.animation_name = "attack_1"
	return p


static func create_summon_minion() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Summon Minion"
	p.attack_id = "summon_minion"
	p.damage_multiplier = 0.0
	p.cooldown = 15.0
	p.attack_range = 9999.0
	p.is_summon = true
	p.summon_count = 2
	p.summon_enemy_id = "swarmer_minion"
	p.priority = 1
	p.animation_name = "attack_1"
	return p


static func create_heal_beam() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Heal Beam"
	p.attack_id = "heal_beam"
	p.damage_multiplier = 0.0
	p.cooldown = 8.0
	p.attack_range = 192.0
	p.is_heal = true
	p.heal_percent = 0.15  # 15% of target max HP
	p.priority = 5  # Highest priority for healers
	p.animation_name = "attack_1"
	return p


static func create_buff_allies() -> AttackPattern:
	var p := AttackPattern.new()
	p.attack_name = "Empower Allies"
	p.attack_id = "buff_allies"
	p.damage_multiplier = 0.0
	p.cooldown = 12.0
	p.attack_range = 160.0
	p.is_buff = true
	p.buff_effect_type = Enums.EffectType.DAMAGE_UP
	p.buff_duration = 8.0
	p.buff_value = 20.0
	p.priority = 4
	p.animation_name = "attack_1"
	return p

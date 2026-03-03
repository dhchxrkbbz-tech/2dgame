## UltimateManager - Ultimate skill kezelés
## Minden class-nak 3 ultimate-ja van (1 per branch), egyszerre 1 aktív
class_name UltimateManager
extends RefCounted

signal ultimate_used(skill_data: SkillData)
signal ultimate_ready()
signal ultimate_cooldown_started(duration: float)
signal ultimate_cooldown_finished()

var class_ref: ClassBase

# === Aktív ultimate ===
var equipped_ultimate: SkillData = null
var ultimate_rank: int = 0

# === Cooldown ===
var cooldown_timer: float = 0.0
var is_on_cooldown: bool = false

# === Transform state (Blood/egyéb) ===
var is_transformed: bool = false
var transform_timer: float = 0.0
var transform_data: Dictionary = {}


func _init(p_class: ClassBase) -> void:
	class_ref = p_class


func update(delta: float) -> void:
	# Cooldown
	if cooldown_timer > 0:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			cooldown_timer = 0.0
			is_on_cooldown = false
			ultimate_cooldown_finished.emit()
			ultimate_ready.emit()
	
	# Transform duration
	if is_transformed:
		transform_timer -= delta
		if transform_timer <= 0:
			_end_transform()


## Ultimate használata
func use_ultimate() -> bool:
	if not equipped_ultimate:
		return false
	if is_on_cooldown:
		return false
	if ultimate_rank <= 0:
		return false
	
	# Mana check
	var mana_cost: float = equipped_ultimate.get_mana_cost(ultimate_rank)
	if class_ref.player and not class_ref.player.use_mana(int(mana_cost)):
		return false
	
	# HP cost check
	if equipped_ultimate.hp_cost_percent > 0 and class_ref.player:
		var hp_cost := int(class_ref.player.max_hp * equipped_ultimate.hp_cost_percent / 100.0)
		if class_ref.player.current_hp <= hp_cost:
			return false
	
	# Cooldown start
	var cd: float = equipped_ultimate.get_cooldown(ultimate_rank)
	cooldown_timer = cd
	is_on_cooldown = true
	
	ultimate_cooldown_started.emit(cd)
	
	# Execute
	_execute_ultimate()
	
	ultimate_used.emit(equipped_ultimate)
	EventBus.skill_used.emit(class_ref.player, equipped_ultimate.skill_id)
	
	return true


func _execute_ultimate() -> void:
	if not equipped_ultimate or not class_ref.player:
		return
	
	var damage_mult: float = equipped_ultimate.get_damage_multiplier(ultimate_rank)
	var duration: float = equipped_ultimate.get_duration(ultimate_rank)
	
	match equipped_ultimate.skill_type:
		Enums.SkillType.AOE:
			_execute_aoe_ultimate(damage_mult, duration)
		Enums.SkillType.TRANSFORMATION:
			_execute_transform_ultimate(damage_mult, duration)
		Enums.SkillType.BUFF:
			_execute_buff_ultimate(duration)
		Enums.SkillType.CHANNEL:
			_execute_channel_ultimate(damage_mult, duration)
		Enums.SkillType.HEAL:
			_execute_heal_ultimate(duration)
		_:
			_execute_aoe_ultimate(damage_mult, duration)


func _execute_aoe_ultimate(damage_mult: float, duration: float) -> void:
	if equipped_ultimate.effect_scene:
		var aoe: Node2D = equipped_ultimate.effect_scene.instantiate()
		aoe.global_position = class_ref.player.global_position
		if aoe.has_method("setup"):
			aoe.setup(
				class_ref.player.base_damage * damage_mult,
				equipped_ultimate.aoe_radius,
				duration
			)
		var effect_layer := class_ref.player.get_tree().current_scene.get_node_or_null("EffectLayer")
		if effect_layer:
			effect_layer.add_child(aoe)


func _execute_transform_ultimate(damage_mult: float, duration: float) -> void:
	is_transformed = true
	transform_timer = duration
	transform_data = {
		"damage_bonus": damage_mult,
		"attack_speed_bonus": 0.3,
	}
	# Stat módosítások alkalmazása a player-re
	if class_ref.player:
		class_ref.player.base_damage = int(class_ref.player.base_damage * damage_mult)


func _execute_buff_ultimate(duration: float) -> void:
	if equipped_ultimate.applies_effect >= 0 and class_ref.player:
		var effect := StatusEffect.create(
			equipped_ultimate.applies_effect,
			duration,
			equipped_ultimate.effect_value,
			class_ref.player
		)
		if class_ref.player.status_effects:
			class_ref.player.status_effects.apply_effect(effect)


func _execute_channel_ultimate(damage_mult: float, duration: float) -> void:
	# Channel: a player nem mozoghat a channel ideje alatt
	if class_ref.player:
		class_ref.player.can_act = false
		var timer := class_ref.player.get_tree().create_timer(duration)
		timer.timeout.connect(func():
			class_ref.player.can_act = true
			_execute_aoe_ultimate(damage_mult, 0.5)
		)


func _execute_heal_ultimate(duration: float) -> void:
	# AoE heal zone
	if equipped_ultimate.effect_scene:
		var zone: Node2D = equipped_ultimate.effect_scene.instantiate()
		zone.global_position = class_ref.player.global_position
		if zone.has_method("setup"):
			zone.setup(0, equipped_ultimate.aoe_radius, duration)
		var effect_layer := class_ref.player.get_tree().current_scene.get_node_or_null("EffectLayer")
		if effect_layer:
			effect_layer.add_child(zone)


func _end_transform() -> void:
	is_transformed = false
	transform_timer = 0.0
	# Stat visszaállítás
	if class_ref.player:
		var stats: Dictionary = Constants.CLASS_BASE_STATS.get(class_ref.player_class, {})
		class_ref.player.base_damage = stats.get("base_damage", 12)
	transform_data.clear()


## Ultimate equip
func equip_ultimate(skill_data: SkillData, rank: int) -> void:
	equipped_ultimate = skill_data
	ultimate_rank = rank


## Cooldown percent (UI-hoz)
func get_cooldown_percent() -> float:
	if not equipped_ultimate or not is_on_cooldown:
		return 0.0
	var total_cd: float = equipped_ultimate.get_cooldown(ultimate_rank)
	if total_cd <= 0:
		return 0.0
	return cooldown_timer / total_cd


## Serialize
func serialize() -> Dictionary:
	return {
		"equipped_ultimate_id": equipped_ultimate.skill_id if equipped_ultimate else "",
		"ultimate_rank": ultimate_rank,
		"cooldown_remaining": cooldown_timer,
	}


## Deserialize
func deserialize(data: Dictionary) -> void:
	ultimate_rank = data.get("ultimate_rank", 0)
	cooldown_timer = data.get("cooldown_remaining", 0.0)
	is_on_cooldown = cooldown_timer > 0

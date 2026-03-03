## SkillManager - Skill kezelés és cooldown tracking
## Kezeli az aktív skill-eket, cooldown-okat, GCD-t
class_name SkillManager
extends RefCounted

signal skill_used(skill_data: SkillData)
signal cooldown_started(skill_index: int, duration: float)
signal cooldown_finished(skill_index: int)

var class_ref: ClassBase

# === Aktív skill slot-ok (4 skill) ===
var equipped_skills: Array[SkillData] = [null, null, null, null]
var skill_ranks: Dictionary = {}  # skill_id → rank

# === Cooldown-ok ===
var cooldowns: Array[float] = [0.0, 0.0, 0.0, 0.0]
var gcd_timer: float = 0.0

# === Skill tree állapot ===
var allocated_skills: Dictionary = {}  # skill_id → allocated rank
var available_skill_points: int = 0


func _init(p_class: ClassBase) -> void:
	class_ref = p_class


func update(delta: float) -> void:
	# GCD timer
	if gcd_timer > 0:
		gcd_timer -= delta
		if gcd_timer < 0:
			gcd_timer = 0
	
	# Cooldown timer-ek
	for i in range(4):
		if cooldowns[i] > 0:
			cooldowns[i] -= delta
			if cooldowns[i] <= 0:
				cooldowns[i] = 0
				cooldown_finished.emit(i)
				EventBus.skill_cooldown_finished.emit(
					equipped_skills[i].skill_id if equipped_skills[i] else ""
				)


## Skill használata index alapján (0-3)
func use_skill(index: int) -> bool:
	if index < 0 or index >= 4:
		return false
	
	var skill: SkillData = equipped_skills[index]
	if not skill:
		return false
	
	# GCD check
	if gcd_timer > 0:
		return false
	
	# Cooldown check
	if cooldowns[index] > 0:
		return false
	
	var rank: int = allocated_skills.get(skill.skill_id, 0)
	if rank <= 0:
		return false
	
	# Mana check
	var mana_cost: float = skill.get_mana_cost(rank)
	if class_ref.player and not class_ref.player.use_mana(int(mana_cost)):
		return false
	
	# HP cost check (Blood skills)
	if skill.hp_cost_percent > 0 and class_ref.player:
		var hp_cost := int(class_ref.player.max_hp * skill.hp_cost_percent / 100.0)
		if class_ref.player.current_hp <= hp_cost:
			return false
		class_ref.player.current_hp -= hp_cost
	
	# Cooldown start
	var cd: float = skill.get_cooldown(rank)
	cooldowns[index] = cd
	gcd_timer = Constants.GLOBAL_COOLDOWN
	
	cooldown_started.emit(index, cd)
	EventBus.skill_cooldown_started.emit(skill.skill_id, cd)
	
	# Execute skill
	_execute_skill(skill, rank)
	
	skill_used.emit(skill)
	EventBus.skill_used.emit(class_ref.player, skill.skill_id)
	
	return true


## Skill végrehajtása
func _execute_skill(skill: SkillData, rank: int) -> void:
	var damage_mult: float = skill.get_damage_multiplier(rank)
	var duration: float = skill.get_duration(rank)
	
	match skill.skill_type:
		Enums.SkillType.MELEE:
			_execute_melee(skill, damage_mult)
		Enums.SkillType.PROJECTILE:
			_execute_projectile(skill, damage_mult)
		Enums.SkillType.AOE:
			_execute_aoe(skill, damage_mult, duration)
		Enums.SkillType.BUFF:
			_execute_buff(skill, duration, rank)
		Enums.SkillType.HEAL:
			_execute_heal(skill, rank)
		Enums.SkillType.TELEPORT:
			_execute_teleport(skill, rank)
		Enums.SkillType.DEBUFF:
			_execute_debuff(skill, duration, rank)
		_:
			_execute_melee(skill, damage_mult)


func _execute_melee(skill: SkillData, damage_mult: float) -> void:
	if not class_ref.player:
		return
	var base_dmg: int = class_ref.player.base_damage
	var final_dmg: float = base_dmg * damage_mult
	if class_ref.player.hitbox:
		class_ref.player.hitbox.activate(0.3, final_dmg)
		if skill.applies_effect >= 0:
			class_ref.player.hitbox.set_effect(
				skill.applies_effect, skill.effect_duration, skill.effect_value
			)


func _execute_projectile(skill: SkillData, damage_mult: float) -> void:
	if not class_ref.player:
		return
	var base_dmg: int = class_ref.player.base_damage
	var final_dmg: float = base_dmg * damage_mult
	# Projectile létrehozás (scene-based)
	if skill.effect_scene:
		var proj: Node2D = skill.effect_scene.instantiate()
		proj.global_position = class_ref.player.global_position
		if proj.has_method("setup"):
			proj.setup(class_ref.player.last_direction, final_dmg, skill.skill_range)
		var effect_layer := class_ref.player.get_tree().current_scene.get_node_or_null("EffectLayer")
		if effect_layer:
			effect_layer.add_child(proj)


func _execute_aoe(skill: SkillData, damage_mult: float, duration: float) -> void:
	if not class_ref.player:
		return
	var base_dmg: int = class_ref.player.base_damage
	var final_dmg: float = base_dmg * damage_mult
	# AoE effect létrehozás
	if skill.effect_scene:
		var aoe: Node2D = skill.effect_scene.instantiate()
		aoe.global_position = class_ref.player.global_position
		if aoe.has_method("setup"):
			aoe.setup(final_dmg, skill.aoe_radius, duration)
		var effect_layer := class_ref.player.get_tree().current_scene.get_node_or_null("EffectLayer")
		if effect_layer:
			effect_layer.add_child(aoe)


func _execute_buff(skill: SkillData, duration: float, rank: int) -> void:
	if not class_ref.player or not class_ref.player.status_effects:
		return
	if skill.applies_effect >= 0:
		var effect := StatusEffect.create(
			skill.applies_effect, duration, skill.effect_value, class_ref.player
		)
		class_ref.player.status_effects.apply_effect(effect)


func _execute_heal(skill: SkillData, rank: int) -> void:
	if not class_ref.player:
		return
	var heal_percent: float = skill.base_damage_multiplier + (rank - 1) * skill.damage_per_rank
	var heal_amount: int = int(class_ref.player.max_hp * heal_percent / 100.0)
	class_ref.player.heal(heal_amount)


func _execute_teleport(skill: SkillData, rank: int) -> void:
	if not class_ref.player:
		return
	var tp_range: float = skill.skill_range + (rank - 1) * 32.0
	var direction: Vector2 = class_ref.player.last_direction
	var target_pos: Vector2 = class_ref.player.global_position + direction * tp_range
	class_ref.player.global_position = target_pos


func _execute_debuff(skill: SkillData, duration: float, rank: int) -> void:
	# AOE debuff alkalmazás
	if not class_ref.player:
		return
	var entities := class_ref.player.get_tree().get_nodes_in_group("enemy")
	for entity in entities:
		if not is_instance_valid(entity):
			continue
		var dist: float = class_ref.player.global_position.distance_to(entity.global_position)
		if dist <= skill.aoe_radius and entity.has_node("StatusEffectManager"):
			var effect := StatusEffect.create(
				skill.applies_effect, duration, skill.effect_value, class_ref.player
			)
			entity.get_node("StatusEffectManager").apply_effect(effect)


## Skill pont allokálás
func allocate_skill_point(skill_id: String) -> bool:
	if available_skill_points <= 0:
		return false
	
	var skill: SkillData = _find_skill_data(skill_id)
	if not skill:
		return false
	
	var current_rank: int = allocated_skills.get(skill_id, 0)
	if current_rank >= skill.max_rank:
		return false
	
	if not skill.is_unlockable(allocated_skills):
		return false
	
	allocated_skills[skill_id] = current_rank + 1
	available_skill_points -= 1
	
	EventBus.skill_point_allocated.emit(skill_id, current_rank + 1)
	return true


## Skill equip slot-ba
func equip_skill(skill_id: String, slot: int) -> bool:
	if slot < 0 or slot >= 4:
		return false
	var skill: SkillData = _find_skill_data(skill_id)
	if not skill or skill.is_ultimate:
		return false
	var rank: int = allocated_skills.get(skill_id, 0)
	if rank <= 0:
		return false
	equipped_skills[slot] = skill
	return true


func _find_skill_data(_skill_id: String) -> SkillData:
	# Placeholder - a tényleges skill data betöltés a ResourceLoader-en keresztül történik
	return null


## Összes allokált pont egy branch-ben
func get_branch_points(branch: Enums.SkillBranch) -> int:
	var total: int = 0
	for skill_id in allocated_skills:
		var skill: SkillData = _find_skill_data(skill_id)
		if skill and skill.branch == branch:
			total += allocated_skills[skill_id]
	return total


## Serialize
func serialize() -> Dictionary:
	var data := {}
	data["allocated_skills"] = allocated_skills.duplicate()
	data["available_skill_points"] = available_skill_points
	var equipped_ids: Array[String] = []
	for skill in equipped_skills:
		equipped_ids.append(skill.skill_id if skill else "")
	data["equipped_skills"] = equipped_ids
	return data


## Deserialize
func deserialize(data: Dictionary) -> void:
	allocated_skills = data.get("allocated_skills", {})
	available_skill_points = data.get("available_skill_points", 0)
	var equipped_ids: Array = data.get("equipped_skills", [])
	for i in range(mini(equipped_ids.size(), 4)):
		if equipped_ids[i] != "":
			var skill := _find_skill_data(equipped_ids[i])
			equipped_skills[i] = skill

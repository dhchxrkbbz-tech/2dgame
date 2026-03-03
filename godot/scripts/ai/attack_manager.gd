## AttackManager - Enemy támadás kezelő
## Kezeli az attack pattern-ek kiválasztását, végrehajtását, telegraph-ot
class_name AttackManager
extends Node

signal attack_started(pattern: AttackPattern)
signal attack_finished(pattern: AttackPattern)
signal telegraph_started(position: Vector2, radius: float, duration: float)

var owner_entity: Node = null
var attack_patterns: Array[AttackPattern] = []
var current_attack: AttackPattern = null
var is_attacking: bool = false

# Summon tracking
var active_summons: Array[Node] = []
const MAX_SUMMONS: int = 6


func _ready() -> void:
	owner_entity = get_parent()


func _process(delta: float) -> void:
	for pattern in attack_patterns:
		pattern.update_cooldown(delta)
	
	# Clean summons
	active_summons = active_summons.filter(func(s): return is_instance_valid(s) and s.is_alive)


## Attack pattern-ek beállítása
func setup_patterns(patterns: Array[AttackPattern]) -> void:
	attack_patterns = patterns


## Legjobb elérhető attack kiválasztása
func choose_attack(target_distance: float, has_los: bool = true) -> AttackPattern:
	var available: Array[AttackPattern] = []
	
	for pattern in attack_patterns:
		if not pattern.is_ready():
			continue
		if target_distance > pattern.attack_range:
			continue
		if target_distance < pattern.min_range:
			continue
		
		# Heal check: csak sérült ally-ra
		if pattern.is_heal:
			var hurt_ally := _find_hurt_ally(pattern.attack_range)
			if not hurt_ally:
				continue
		
		# Buff check: van-e ally a közelben
		if pattern.is_buff:
			var ally := _find_ally_in_range(pattern.attack_range)
			if not ally:
				continue
		
		# Summon check: ne legyen túl sok
		if pattern.is_summon:
			if active_summons.size() >= MAX_SUMMONS:
				continue
		
		# Projectile/ranged: LOS kell
		if pattern.is_projectile and not has_los:
			continue
		
		available.append(pattern)
	
	if available.is_empty():
		return null
	
	# Prioritás szerinti rendezés
	available.sort_custom(func(a, b): return a.priority > b.priority)
	
	# 30% eséllyel a 2. legjobb opció (variáció)
	if available.size() > 1 and randf() < 0.3:
		return available[1]
	
	return available[0]


## Támadás végrehajtás
func execute_attack(pattern: AttackPattern, target: Node) -> void:
	if is_attacking:
		return
	
	is_attacking = true
	current_attack = pattern
	pattern.trigger()
	attack_started.emit(pattern)
	
	# Telegraph kezelés
	if pattern.telegraph_time > 0:
		var telegraph_pos := target.global_position if is_instance_valid(target) else owner_entity.global_position
		var telegraph_radius := pattern.area_size.x if pattern.area_type != AttackPattern.AreaType.NONE else 48.0
		telegraph_started.emit(telegraph_pos, telegraph_radius, pattern.telegraph_time)
		
		await owner_entity.get_tree().create_timer(pattern.telegraph_time).timeout
		
		if not is_instance_valid(owner_entity) or not owner_entity.is_alive:
			_finish_attack()
			return
	
	# Támadás típus végrehajtás
	if pattern.is_heal:
		_execute_heal(pattern)
	elif pattern.is_buff:
		_execute_buff(pattern)
	elif pattern.is_summon:
		_execute_summon(pattern)
	elif pattern.is_charge:
		_execute_charge(pattern, target)
	elif pattern.is_projectile:
		_execute_projectile(pattern, target)
	elif pattern.area_type != AttackPattern.AreaType.NONE:
		_execute_aoe(pattern, target)
	else:
		_execute_melee(pattern, target)
	
	# Támadás befejezés delay
	var finish_delay := 0.3
	if pattern.cast_time > 0:
		finish_delay = pattern.cast_time
	
	await owner_entity.get_tree().create_timer(finish_delay).timeout
	_finish_attack()


func _finish_attack() -> void:
	var completed := current_attack
	is_attacking = false
	current_attack = null
	if completed:
		attack_finished.emit(completed)


## Melee támadás
func _execute_melee(pattern: AttackPattern, target: Node) -> void:
	if not is_instance_valid(target):
		return

	var final_damage := _calc_damage(pattern)
	
	# Hitbox-on keresztüli támadás
	var hitbox: HitboxComponent = owner_entity.get_node_or_null("Hitbox")
	if hitbox:
		hitbox.damage = final_damage
		hitbox.damage_type = pattern.damage_type
		hitbox.knockback_force = pattern.knockback_force
		
		# Irányba forgatás
		var dir := (target.global_position - owner_entity.global_position).normalized()
		var hitbox_shape = hitbox.get_child(0) if hitbox.get_child_count() > 0 else null
		if hitbox_shape:
			hitbox_shape.position = dir * 16
		
		# Status effect alkalmazás
		if pattern.applies_effect:
			hitbox.set_effect(pattern.effect_type, pattern.effect_duration, pattern.effect_value)
		
		hitbox.activate(0.2)


## Ranged lövedék
func _execute_projectile(pattern: AttackPattern, target: Node) -> void:
	if not is_instance_valid(target):
		return
	
	var final_damage := _calc_damage(pattern)
	var dir := (target.global_position - owner_entity.global_position).normalized()
	
	var proj := Projectile.new()
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 4
	shape.shape = circle
	proj.add_child(shape)
	proj.collision_layer = 1 << (Constants.LAYER_PROJECTILE - 1)
	proj.collision_mask = 1 << (Constants.LAYER_PLAYER_HURTBOX - 1)
	
	# Status effect a lövedékre
	var effect: StatusEffect = null
	if pattern.applies_effect:
		effect = StatusEffect.create(
			pattern.effect_type, pattern.effect_duration, pattern.effect_value, owner_entity
		)
	
	proj.global_position = owner_entity.global_position
	proj.setup(owner_entity, dir, final_damage, pattern.damage_type, target if pattern.projectile_tracking > 0 else null, effect)
	proj.speed = pattern.projectile_speed
	proj.tracking_strength = pattern.projectile_tracking
	proj.pierce_count = pattern.projectile_pierce
	proj.aoe_radius = pattern.projectile_aoe_radius
	
	# Projekti sprite
	var proj_sprite := Sprite2D.new()
	var proj_color := _get_projectile_color(pattern)
	var img := Image.create(6, 6, false, Image.FORMAT_RGBA8)
	img.fill(proj_color)
	proj_sprite.texture = ImageTexture.create_from_image(img)
	proj.add_child(proj_sprite)
	
	var proj_layer := owner_entity.get_tree().current_scene.get_node_or_null("ProjectileLayer")
	if proj_layer:
		proj_layer.add_child(proj)
	else:
		owner_entity.get_parent().add_child(proj)


## AoE támadás (frost nova, stb.)
func _execute_aoe(pattern: AttackPattern, target: Node) -> void:
	var final_damage := _calc_damage(pattern)
	var center: Vector2
	
	# Self-centered AoE => owner pozíciója, target-centered => target pozíciója
	if pattern.min_range == 0 and pattern.area_type == AttackPattern.AreaType.CIRCLE:
		center = owner_entity.global_position
	elif is_instance_valid(target):
		center = target.global_position
	else:
		center = owner_entity.global_position
	
	var radius: float = pattern.area_size.x
	
	# Vizuális
	var effect_node := _create_aoe_visual(center, radius, pattern)
	owner_entity.get_parent().add_child(effect_node)
	
	# Damage a körben lévő játékosokra
	for player in owner_entity.get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(center) <= radius:
			if player.has_method("take_damage"):
				player.take_damage(final_damage, pattern.damage_type)
			
			# Status effect
			if pattern.applies_effect:
				var sem: StatusEffectManager = player.get_node_or_null("StatusEffectManager")
				if sem:
					var effect := StatusEffect.create(
						pattern.effect_type, pattern.effect_duration, pattern.effect_value, owner_entity
					)
					sem.apply_effect(effect)
	
	# AoE visual cleanup
	var tween := effect_node.create_tween()
	tween.tween_property(effect_node, "modulate:a", 0.0, 0.5)
	tween.tween_callback(effect_node.queue_free)


## Charge támadás
func _execute_charge(pattern: AttackPattern, target: Node) -> void:
	if not is_instance_valid(target) or not is_instance_valid(owner_entity):
		return
	
	var final_damage := _calc_damage(pattern)
	var dir := (target.global_position - owner_entity.global_position).normalized()
	var start_pos := owner_entity.global_position
	var end_pos := start_pos + dir * pattern.charge_distance
	
	# Charge tween
	var tween := owner_entity.create_tween()
	tween.tween_property(owner_entity, "global_position", end_pos, pattern.charge_distance / pattern.charge_speed)
	
	# Damage ellenőrzés menet közben
	await tween.finished
	
	if not is_instance_valid(owner_entity):
		return
	
	# Impact damage check
	for player in owner_entity.get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(owner_entity.global_position) <= 40:
			if player.has_method("take_damage"):
				player.take_damage(final_damage, pattern.damage_type)
			if pattern.knockback_force > 0 and player.has_method("apply_knockback"):
				var kb_dir := (player.global_position - owner_entity.global_position).normalized()
				player.apply_knockback(kb_dir * pattern.knockback_force)


## Heal végrehajtás
func _execute_heal(pattern: AttackPattern) -> void:
	var heal_target := _find_hurt_ally(pattern.attack_range)
	if not heal_target:
		return
	
	var heal_amount: int = int(heal_target.max_hp * pattern.heal_percent)
	if heal_target.has_method("heal"):
		heal_target.heal(heal_amount)


## Buff végrehajtás
func _execute_buff(pattern: AttackPattern) -> void:
	var allies := _find_all_allies_in_range(pattern.attack_range)
	for ally in allies:
		var sem: StatusEffectManager = ally.get_node_or_null("StatusEffectManager")
		if sem:
			var effect := StatusEffect.create(
				pattern.buff_effect_type, pattern.buff_duration, pattern.buff_value, owner_entity
			)
			sem.apply_effect(effect)


## Summon végrehajtás
func _execute_summon(pattern: AttackPattern) -> void:
	for i in pattern.summon_count:
		if active_summons.size() >= MAX_SUMMONS:
			break
		
		var minion := EnemyBase.new()
		var data := EnemyData.new()
		data.enemy_name = "Summoned Minion"
		data.enemy_id = "summoned_minion"
		data.enemy_category = Enums.EnemyType.MELEE
		data.sub_type = 3  # swarmer
		data.base_hp = 15
		data.base_damage = 5
		data.base_speed = 60.0
		data.attack_range = 24.0
		data.detection_range = 200.0
		data.base_xp = 2
		data.sprite_color = Color(0.5, 0.3, 0.7)
		
		minion.enemy_data = data
		minion.enemy_level = owner_entity.enemy_level if "enemy_level" in owner_entity else 1
		
		var angle := TAU * float(i) / float(pattern.summon_count)
		var offset := Vector2(cos(angle) * 40, sin(angle) * 40)
		minion.global_position = owner_entity.global_position + offset
		
		owner_entity.get_parent().add_child(minion)
		active_summons.append(minion)


# === Segéd metódusok ===

func _calc_damage(pattern: AttackPattern) -> int:
	var base_dmg: float = 10.0
	if "damage" in owner_entity:
		base_dmg = owner_entity.damage
	
	var dmg_mod: float = 1.0
	if "status_manager" in owner_entity and owner_entity.status_manager:
		dmg_mod = 1.0 + owner_entity.status_manager.get_total_damage_modifier()
	
	return int(base_dmg * pattern.damage_multiplier * dmg_mod)


func _find_hurt_ally(search_range: float) -> Node:
	var best_ally: Node = null
	var lowest_hp_pct: float = 1.0
	
	for enemy in owner_entity.get_tree().get_nodes_in_group("enemy"):
		if enemy == owner_entity or not is_instance_valid(enemy):
			continue
		if not enemy.is_alive:
			continue
		if enemy.global_position.distance_to(owner_entity.global_position) > search_range:
			continue
		
		var hp_pct: float = float(enemy.current_hp) / float(max(1, enemy.max_hp))
		if hp_pct < 0.5 and hp_pct < lowest_hp_pct:
			lowest_hp_pct = hp_pct
			best_ally = enemy
	
	return best_ally


func _find_ally_in_range(search_range: float) -> Node:
	for enemy in owner_entity.get_tree().get_nodes_in_group("enemy"):
		if enemy == owner_entity or not is_instance_valid(enemy):
			continue
		if not enemy.is_alive:
			continue
		if enemy.global_position.distance_to(owner_entity.global_position) <= search_range:
			return enemy
	return null


func _find_all_allies_in_range(search_range: float) -> Array[Node]:
	var allies: Array[Node] = []
	for enemy in owner_entity.get_tree().get_nodes_in_group("enemy"):
		if enemy == owner_entity or not is_instance_valid(enemy):
			continue
		if not enemy.is_alive:
			continue
		if enemy.global_position.distance_to(owner_entity.global_position) <= search_range:
			allies.append(enemy)
	return allies


func _get_projectile_color(pattern: AttackPattern) -> Color:
	match pattern.damage_type:
		Enums.DamageType.ARCANE: return Color(1.0, 0.5, 0.1)
		Enums.DamageType.FROST: return Color(0.4, 0.7, 1.0)
		Enums.DamageType.POISON: return Color(0.2, 0.8, 0.1)
		Enums.DamageType.SHADOW: return Color(0.4, 0.1, 0.6)
		Enums.DamageType.HOLY: return Color(1.0, 0.9, 0.5)
		_: return Color.YELLOW


func _create_aoe_visual(center: Vector2, radius: float, pattern: AttackPattern) -> Node2D:
	var node := Node2D.new()
	node.global_position = center
	
	var canvas := Sprite2D.new()
	var size := int(radius * 2)
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	
	var aoe_color := Color(1, 0, 0, 0.3)
	match pattern.damage_type:
		Enums.DamageType.FROST: aoe_color = Color(0.3, 0.6, 1.0, 0.3)
		Enums.DamageType.ARCANE: aoe_color = Color(1.0, 0.4, 0.1, 0.3)
		Enums.DamageType.POISON: aoe_color = Color(0.2, 0.7, 0.1, 0.3)
		Enums.DamageType.SHADOW: aoe_color = Color(0.4, 0.1, 0.5, 0.3)
	
	for x in img.get_width():
		for y in img.get_height():
			var cx := float(x) - radius
			var cy := float(y) - radius
			if sqrt(cx * cx + cy * cy) <= radius:
				img.set_pixel(x, y, aoe_color)
	
	canvas.texture = ImageTexture.create_from_image(img)
	node.add_child(canvas)
	
	return node

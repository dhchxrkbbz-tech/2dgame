## BossBase - Alap boss class, minden boss ebből származik
## Multi-phase, telegraph, enrage, threat table, summon kezelés
class_name BossBase
extends CharacterBody2D

signal boss_defeated(boss_id: String)
signal phase_changed(phase_index: int, phase_name: String)
signal boss_enraged()

enum BossState { IDLE, TELEGRAPH, CASTING, MOVING, TRANSITIONING, ENRAGED, DEAD }

# Boss adatok
var boss_data: BossData
var current_hp: int = 0
var max_hp: int = 0
var current_phase_index: int = 0
var current_state: BossState = BossState.IDLE
var is_invulnerable: bool = false
var is_enraged: bool = false
var enrage_timer: float = 0.0
var fight_started: bool = false
var boss_level: int = 1

# Stat módosítók (phase-ből)
var damage_multiplier: float = 1.0
var speed_multiplier: float = 1.0
var attack_speed_multiplier: float = 1.0
var armor_modifier: int = 0

# Rendszer komponensek
var threat_table: BossThreatTable
var telegraph: BossTelegraph
var health_bar: BossHealthBar
var status_effect_manager: StatusEffectManager

# Node-ok
var sprite: Sprite2D
var collision_shape: CollisionShape2D
var hurtbox: Area2D
var detection_area: Area2D
var summons: Array[Node] = []

# AI
var _current_target: Node = null
var _idle_timer: float = 0.0
var _cast_timer: float = 0.0
var _current_ability: BossAbility = null
var _telegraph_timer: float = 0.0
var _transition_timer: float = 0.0
var _aura_timer: float = 0.0
var _move_direction: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("boss")
	add_to_group("enemies")
	
	if boss_data:
		_initialize()


func initialize(data: BossData, level: int = 1) -> void:
	boss_data = data
	boss_level = level
	_initialize()


func _initialize() -> void:
	max_hp = _scale_hp(boss_data.base_hp)
	current_hp = max_hp
	enrage_timer = boss_data.enrage_time
	
	_create_nodes()
	_setup_collision()


func _scale_hp(base: int) -> int:
	# Level scaling
	var level_mult := 1.0 + (boss_level - 1) * 0.08
	# Multiplayer scaling
	var player_count := get_tree().get_nodes_in_group("player").size()
	var mp_mult := DamageCalculator.boss_hp_multiplier(player_count)
	return int(base * level_mult * mp_mult)


func _create_nodes() -> void:
	# Sprite
	sprite = Sprite2D.new()
	var img := Image.create(int(boss_data.sprite_size.x), int(boss_data.sprite_size.y), false, Image.FORMAT_RGBA8)
	img.fill(boss_data.sprite_color)
	# Kiemelő szegély
	for x in int(boss_data.sprite_size.x):
		for y in [0, 1, int(boss_data.sprite_size.y) - 1, int(boss_data.sprite_size.y) - 2]:
			img.set_pixel(x, y, boss_data.sprite_color.lightened(0.3))
	for y in int(boss_data.sprite_size.y):
		for x in [0, 1, int(boss_data.sprite_size.x) - 1, int(boss_data.sprite_size.x) - 2]:
			img.set_pixel(x, y, boss_data.sprite_color.lightened(0.3))
	sprite.texture = ImageTexture.create_from_image(img)
	add_child(sprite)
	
	# Collision
	collision_shape = CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = boss_data.collision_size
	collision_shape.shape = rect
	collision_layer = 1 << (Constants.LAYER_ENEMY_PHYSICS - 1)
	collision_mask = 1 << (Constants.LAYER_WALL - 1)
	add_child(collision_shape)
	
	# Hurtbox
	hurtbox = Area2D.new()
	hurtbox.name = "Hurtbox"
	hurtbox.collision_layer = 1 << (Constants.LAYER_ENEMY_HURTBOX - 1)
	hurtbox.collision_mask = 0
	var hurtbox_shape := CollisionShape2D.new()
	var hurtbox_rect := RectangleShape2D.new()
	hurtbox_rect.size = boss_data.collision_size * 1.2
	hurtbox_shape.shape = hurtbox_rect
	hurtbox.add_child(hurtbox_shape)
	add_child(hurtbox)
	
	# Detection area
	detection_area = Area2D.new()
	detection_area.name = "DetectionArea"
	detection_area.collision_layer = 0
	detection_area.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	var detect_shape := CollisionShape2D.new()
	var detect_circle := CircleShape2D.new()
	detect_circle.radius = 320.0  # Boss-ok nagy detection range
	detect_shape.shape = detect_circle
	detection_area.add_child(detect_shape)
	detection_area.body_entered.connect(_on_player_detected)
	add_child(detection_area)
	
	# Status effect manager
	status_effect_manager = StatusEffectManager.new()
	add_child(status_effect_manager)
	
	# Telegraph (child node)
	telegraph = BossTelegraph.new()
	telegraph.name = "Telegraph"
	add_child(telegraph)
	
	# Threat table
	threat_table = BossThreatTable.new()
	
	# Health bar (CanvasLayer → a képernyő tetején)
	health_bar = BossHealthBar.new()
	health_bar.name = "BossHealthBar"
	add_child(health_bar)


func _setup_collision() -> void:
	# Boss-ok nem push-olhatók
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING


func _on_player_detected(body: Node) -> void:
	if body.is_in_group("player") and not fight_started:
		start_fight()


func start_fight() -> void:
	if fight_started:
		return
	fight_started = true
	
	# Health bar megjelenítés
	health_bar.show_boss(self, boss_data.boss_name, max_hp)
	
	# Első phase
	if boss_data.phases.size() > 0:
		_apply_phase(0)
	
	# Init threat minden detektált player-re
	for body in detection_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			threat_table.add_threat(body, 1.0)
	
	# Boss zene
	EventBus.boss_fight_started.emit(boss_data.boss_id)
	
	current_state = BossState.IDLE


func _physics_process(delta: float) -> void:
	if not fight_started:
		return
	if current_state == BossState.DEAD:
		return
	
	# Threat table update
	threat_table.update(delta)
	
	# Target frissítés
	_current_target = threat_table.get_top_threat()
	if not _current_target or not is_instance_valid(_current_target):
		_current_target = _find_nearest_player()
	
	# Enrage timer
	if boss_data.enrage_time > 0 and not is_enraged:
		enrage_timer -= delta
		health_bar.update_enrage(enrage_timer)
		if enrage_timer <= 0:
			_trigger_enrage()
	
	# Phase check
	_check_phase_transition()
	
	# Ability cooldown-ok
	_update_ability_cooldowns(delta)
	
	# Aura damage
	_process_aura_damage(delta)
	
	# State machine
	match current_state:
		BossState.IDLE:
			_state_idle(delta)
		BossState.TELEGRAPH:
			_state_telegraph(delta)
		BossState.CASTING:
			_state_casting(delta)
		BossState.MOVING:
			_state_moving(delta)
		BossState.TRANSITIONING:
			_state_transitioning(delta)
	
	# Status effect modifiers
	if status_effect_manager:
		var mods := status_effect_manager.get_aggregated_modifiers()
		# Speed módosító alkalmazás
		if not status_effect_manager.can_move():
			velocity = Vector2.ZERO
	
	move_and_slide()


func _state_idle(delta: float) -> void:
	_idle_timer -= delta
	if _idle_timer <= 0:
		# Próbálj ability-t használni
		var ability := _select_best_ability()
		if ability:
			_start_ability(ability)
		else:
			# Mozogj a target felé
			if _current_target and is_instance_valid(_current_target):
				current_state = BossState.MOVING
			else:
				_idle_timer = 0.5


func _state_telegraph(delta: float) -> void:
	_telegraph_timer -= delta
	if _telegraph_timer <= 0:
		# Telegraph vége → ability végrehajtás
		current_state = BossState.CASTING
		_cast_timer = 0.5  # Cast idő
		_execute_ability(_current_ability)


func _state_casting(delta: float) -> void:
	_cast_timer -= delta
	velocity = Vector2.ZERO  # Ne mozogjon cast közben
	if _cast_timer <= 0:
		current_state = BossState.IDLE
		_idle_timer = _get_idle_time()


func _state_moving(delta: float) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		current_state = BossState.IDLE
		_idle_timer = 0.3
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var speed := boss_data.speed * speed_multiplier
	
	# Status effect speed módosító
	if status_effect_manager:
		speed *= (1.0 + status_effect_manager.get_aggregated_modifiers().get("speed", 0.0))
	
	velocity = dir * speed
	
	# Ha elég közel van, próbálj ability-t
	var dist := global_position.distance_to(_current_target.global_position)
	var best := _select_best_ability()
	if best:
		_start_ability(best)
	elif dist < 48:
		# Melee range → idle
		current_state = BossState.IDLE
		_idle_timer = 0.3


func _state_transitioning(delta: float) -> void:
	_transition_timer -= delta
	velocity = Vector2.ZERO
	
	# Villogás az átmenet alatt
	sprite.modulate.a = 0.5 + sin(_transition_timer * 8.0) * 0.5
	
	if _transition_timer <= 0:
		sprite.modulate.a = 1.0
		is_invulnerable = false
		current_state = BossState.IDLE
		_idle_timer = 1.0


func _get_idle_time() -> float:
	var base := 1.0 / (boss_data.attack_speed * attack_speed_multiplier)
	if is_enraged:
		base *= 0.5
	return base


func _update_ability_cooldowns(delta: float) -> void:
	if current_phase_index >= boss_data.phases.size():
		return
	var phase: BossPhase = boss_data.phases[current_phase_index]
	for ability in phase.abilities:
		ability.update(delta)


func _select_best_ability() -> BossAbility:
	if current_phase_index >= boss_data.phases.size():
		return null
	
	var phase: BossPhase = boss_data.phases[current_phase_index]
	var dist := 99999.0
	if _current_target and is_instance_valid(_current_target):
		dist = global_position.distance_to(_current_target.global_position)
	
	var best: BossAbility = null
	var best_priority := -1
	
	for ability in phase.abilities:
		if not ability.is_ready():
			continue
		if not ability.is_in_range(dist):
			continue
		if ability.requires_players > threat_table.get_player_count():
			continue
		if ability.priority > best_priority:
			best = ability
			best_priority = ability.priority
	
	return best


func _start_ability(ability: BossAbility) -> void:
	_current_ability = ability
	ability.use()
	
	if ability.telegraph_time > 0:
		current_state = BossState.TELEGRAPH
		_telegraph_timer = ability.telegraph_time
		_show_telegraph(ability)
	else:
		current_state = BossState.CASTING
		_cast_timer = 0.5
		_execute_ability(ability)


func _show_telegraph(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var target_pos := _current_target.global_position
	
	match ability.area_type:
		BossAbility.AreaType.CIRCLE:
			telegraph.show_circle(target_pos, ability.area_size.x, ability.telegraph_time)
		BossAbility.AreaType.LINE:
			var dir := global_position.direction_to(target_pos)
			var end_pos := global_position + dir * ability.range
			telegraph.show_line(global_position, end_pos, ability.area_size.y, ability.telegraph_time)
		BossAbility.AreaType.CONE:
			var dir := global_position.direction_to(target_pos)
			telegraph.show_cone(global_position, dir, ability.area_size.x, ability.area_size.y, ability.telegraph_time)
		BossAbility.AreaType.RECT:
			telegraph.show_rect_area(target_pos, ability.area_size, ability.telegraph_time)
		BossAbility.AreaType.NONE:
			pass


func _execute_ability(ability: BossAbility) -> void:
	# Custom callback a specifikus boss-on
	if ability.callback_name != "" and has_method(ability.callback_name):
		call(ability.callback_name, ability)
		return
	
	# Default végrehajtás ability type alapján
	match ability.area_type:
		BossAbility.AreaType.CIRCLE:
			_execute_circle_aoe(ability)
		BossAbility.AreaType.LINE:
			_execute_line_attack(ability)
		BossAbility.AreaType.CONE:
			_execute_cone_attack(ability)
		BossAbility.AreaType.RECT:
			_execute_rect_aoe(ability)
		BossAbility.AreaType.NONE:
			if ability.is_tracking:
				_execute_projectile(ability)
			else:
				_execute_melee(ability)
	
	# Summon
	if ability.summon_count > 0:
		_execute_summon(ability)


func _execute_circle_aoe(ability: BossAbility) -> void:
	if not _current_target:
		return
	var center := _current_target.global_position
	var radius := ability.area_size.x
	
	for player in get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(center) <= radius:
			_deal_damage_to(player, ability.damage)
			if ability.status_effect >= 0:
				_apply_status_to(player, ability.status_effect, ability.status_duration)


func _execute_line_attack(ability: BossAbility) -> void:
	if not _current_target:
		return
	var dir := global_position.direction_to(_current_target.global_position)
	var width := ability.area_size.y
	var length := ability.range
	
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var proj := to_player.dot(dir)
		if proj < 0 or proj > length:
			continue
		var perp_dist := abs(to_player.cross(dir))
		if perp_dist <= width / 2.0:
			_deal_damage_to(player, ability.damage)
			if ability.status_effect >= 0:
				_apply_status_to(player, ability.status_effect, ability.status_duration)


func _execute_cone_attack(ability: BossAbility) -> void:
	if not _current_target:
		return
	var dir := global_position.direction_to(_current_target.global_position)
	var angle := deg_to_rad(ability.area_size.x)
	var length := ability.area_size.y
	
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var dist := to_player.length()
		if dist > length:
			continue
		var player_angle := abs(to_player.angle_to(dir))
		if player_angle <= angle / 2.0:
			_deal_damage_to(player, ability.damage)
			if ability.status_effect >= 0:
				_apply_status_to(player, ability.status_effect, ability.status_duration)


func _execute_rect_aoe(ability: BossAbility) -> void:
	if not _current_target:
		return
	var center := _current_target.global_position
	var half_size := ability.area_size / 2.0
	
	for player in get_tree().get_nodes_in_group("player"):
		var diff := player.global_position - center
		if abs(diff.x) <= half_size.x and abs(diff.y) <= half_size.y:
			_deal_damage_to(player, ability.damage)
			if ability.status_effect >= 0:
				_apply_status_to(player, ability.status_effect, ability.status_duration)


func _execute_projectile(ability: BossAbility) -> void:
	if not _current_target:
		return
	
	for i in ability.projectile_count:
		var proj := Projectile.new()
		proj.setup(
			ability.damage * damage_multiplier,
			ability.projectile_speed,
			global_position.direction_to(_current_target.global_position),
			"boss",
			Enums.DamageType.DARK,
		)
		proj.global_position = global_position
		proj.tracking_target = _current_target if ability.is_tracking else null
		get_parent().add_child(proj)


func _execute_melee(ability: BossAbility) -> void:
	if not _current_target:
		return
	var dist := global_position.distance_to(_current_target.global_position)
	if dist <= ability.range:
		_deal_damage_to(_current_target, ability.damage)
		if ability.status_effect >= 0:
			_apply_status_to(_current_target, ability.status_effect, ability.status_duration)


func _execute_summon(ability: BossAbility) -> void:
	var data := ability.summon_data
	for i in ability.summon_count:
		_spawn_summon(data, i)


func _spawn_summon(data: Dictionary, index: int) -> void:
	var enemy := EnemyBase.new()
	var enemy_data := EnemyData.new()
	enemy_data.enemy_name = data.get("name", "Minion")
	enemy_data.enemy_id = data.get("id", "boss_minion")
	enemy_data.enemy_category = data.get("category", Enums.EnemyType.MELEE)
	enemy_data.base_hp = data.get("hp", 30)
	enemy_data.base_damage = data.get("damage", 12)
	enemy_data.base_armor = data.get("armor", 0)
	enemy_data.base_speed = data.get("speed", 60.0)
	enemy_data.attack_range = data.get("attack_range", 32.0)
	enemy_data.detection_range = 256.0
	enemy_data.attack_speed = data.get("attack_speed", 1.0)
	enemy_data.base_xp = data.get("xp", 10)
	enemy_data.sprite_color = data.get("color", Color(0.5, 0.5, 0.5))
	
	enemy.enemy_data = enemy_data
	enemy.enemy_level = boss_level
	
	var offset := Vector2(
		cos(TAU * index / max(1, _current_ability.summon_count)) * 48,
		sin(TAU * index / max(1, _current_ability.summon_count)) * 48
	)
	enemy.global_position = global_position + offset
	
	var parent := get_parent()
	if parent:
		parent.add_child(enemy)
	summons.append(enemy)


func _deal_damage_to(target: Node, base_damage: float) -> void:
	if not target or not is_instance_valid(target):
		return
	
	var final_damage := base_damage * damage_multiplier
	if is_enraged:
		final_damage *= 2.0
	
	if target.has_method("take_damage"):
		target.take_damage(int(final_damage))
	
	# Threat generálás
	threat_table.add_threat(target, 1.0)


func _apply_status_to(target: Node, effect_type: int, duration: float) -> void:
	if not target or not is_instance_valid(target):
		return
	var sem := target.get_node_or_null("StatusEffectManager")
	if sem and sem is StatusEffectManager:
		var effect := StatusEffect.new()
		effect.effect_type = effect_type
		effect.duration = duration
		sem.add_effect(effect)


func take_damage(amount: int, attacker: Node = null) -> void:
	if current_state == BossState.DEAD:
		return
	if is_invulnerable:
		# Invulnerable feedback
		_show_damage_number(0, true)
		return
	
	var armor_val := boss_data.armor + armor_modifier
	var final := DamageCalculator.calculate_damage(amount, armor_val)
	current_hp -= final
	
	# Threat
	if attacker:
		threat_table.add_threat(attacker, float(final))
	
	# HP bar frissítés
	health_bar.update_hp(current_hp, max_hp)
	
	# Damage number
	_show_damage_number(final, false)
	
	# Hit flash
	sprite.modulate = Color(1.5, 0.5, 0.5)
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	
	if current_hp <= 0:
		_die()


func _show_damage_number(amount: int, is_immune: bool) -> void:
	var dmg_num := DamageNumber.new()
	dmg_num.global_position = global_position + Vector2(randf_range(-16, 16), -boss_data.sprite_size.y / 2.0)
	if is_immune:
		dmg_num.setup(0, Color(0.7, 0.7, 0.7), false)
	else:
		dmg_num.setup(amount, Color(1, 1, 0.3), amount > boss_data.base_hp * 0.05)
	get_parent().add_child(dmg_num)


func _check_phase_transition() -> void:
	if current_state == BossState.TRANSITIONING or current_state == BossState.DEAD:
		return
	
	var hp_percent := float(current_hp) / float(max_hp)
	
	for i in boss_data.phases.size():
		if i <= current_phase_index:
			continue
		var phase: BossPhase = boss_data.phases[i]
		if hp_percent <= phase.hp_threshold:
			_transition_to_phase(i)
			break


func _transition_to_phase(phase_index: int) -> void:
	var phase: BossPhase = boss_data.phases[phase_index]
	
	current_state = BossState.TRANSITIONING
	is_invulnerable = phase.invulnerable_during_transition
	_transition_timer = phase.transition_duration
	current_phase_index = phase_index
	
	# Stat modifiers
	damage_multiplier = phase.stat_modifiers.get("damage_mult", 1.0)
	speed_multiplier = phase.stat_modifiers.get("speed_mult", 1.0)
	attack_speed_multiplier = phase.stat_modifiers.get("attack_speed_mult", 1.0)
	armor_modifier = phase.stat_modifiers.get("armor_change", 0)
	
	# UI
	health_bar.update_phase(phase.phase_name)
	
	# Custom callback
	if phase.special_callback != "" and has_method(phase.special_callback):
		call(phase.special_callback)
	
	phase_changed.emit(phase_index, phase.phase_name)
	EventBus.boss_phase_changed.emit(boss_data.boss_id, phase_index)


func _apply_phase(phase_index: int) -> void:
	if phase_index >= boss_data.phases.size():
		return
	current_phase_index = phase_index
	var phase: BossPhase = boss_data.phases[phase_index]
	health_bar.update_phase(phase.phase_name)
	
	damage_multiplier = phase.stat_modifiers.get("damage_mult", 1.0)
	speed_multiplier = phase.stat_modifiers.get("speed_mult", 1.0)
	attack_speed_multiplier = phase.stat_modifiers.get("attack_speed_mult", 1.0)
	armor_modifier = phase.stat_modifiers.get("armor_change", 0)


func _trigger_enrage() -> void:
	is_enraged = true
	damage_multiplier *= 2.0
	attack_speed_multiplier *= 1.5
	
	sprite.modulate = Color(1.5, 0.5, 0.3)
	
	health_bar.update_enrage(0)
	boss_enraged.emit()
	EventBus.boss_enraged.emit(boss_data.boss_id)


func _process_aura_damage(delta: float) -> void:
	if current_phase_index >= boss_data.phases.size():
		return
	var phase: BossPhase = boss_data.phases[current_phase_index]
	if phase.aura_damage <= 0:
		return
	
	_aura_timer += delta
	if _aura_timer < 1.0:
		return
	_aura_timer -= 1.0
	
	for player in get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(global_position) <= phase.aura_range:
			_deal_damage_to(player, phase.aura_damage)


func _die() -> void:
	current_state = BossState.DEAD
	current_hp = 0
	
	# Summon-ok elpusztítása
	for s in summons:
		if is_instance_valid(s):
			s.queue_free()
	summons.clear()
	
	# Loot drop
	_drop_loot()
	
	# Health bar elrejtés
	health_bar.hide_boss()
	
	# Signals
	boss_defeated.emit(boss_data.boss_id)
	EventBus.boss_defeated.emit(boss_data.boss_id)
	
	# XP
	var xp := _calculate_xp()
	for player in get_tree().get_nodes_in_group("player"):
		EventBus.xp_gained.emit(xp)
	
	# Halál animáció
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 1.5)
	tween.tween_callback(queue_free)


func _drop_loot() -> void:
	var player_count := threat_table.get_player_count()
	var drops := BossLoot.generate_drops(boss_data.loot_table, global_position, player_count)
	BossLoot.drop_loot_at(drops, global_position)


func _calculate_xp() -> int:
	var base_xp := boss_data.base_hp / 2
	match boss_data.tier:
		1: return base_xp
		2: return base_xp * 2
		3: return base_xp * 4
		4: return base_xp * 8
		_: return base_xp


func _find_nearest_player() -> Node:
	var nearest: Node = null
	var nearest_dist := 99999.0
	for player in get_tree().get_nodes_in_group("player"):
		var dist := global_position.distance_to(player.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = player
	return nearest


func heal(amount: int) -> void:
	current_hp = mini(current_hp + amount, max_hp)
	health_bar.update_hp(current_hp, max_hp)


func get_active_summon_count() -> int:
	summons = summons.filter(func(s): return is_instance_valid(s) and s.current_hp > 0)
	return summons.size()

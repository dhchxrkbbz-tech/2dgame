## AshWarden - Tier 1 Boss: Ash Meadows / Starter Biome
## Első boss. Tüzes támadások, aréna tűzfal, flame dash.
## Level: 5-8, HP: 1,500, DMG: 12-18, 2 phases
class_name AshWarden
extends BossBase


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Ash Warden"
	boss_data.boss_id = "ash_warden"
	boss_data.tier = 1
	boss_data.base_hp = 1500
	boss_data.armor = 6
	boss_data.damage = 15
	boss_data.speed = 55.0
	boss_data.attack_speed = 1.0
	boss_data.recommended_level_min = 5
	boss_data.recommended_level_max = 8
	boss_data.required_players = 1
	boss_data.enrage_time = Constants.BOSS_ENRAGE_TIMERS.get(1, 300.0)
	boss_data.sprite_size = Vector2(40, 48)
	boss_data.collision_size = Vector2(28, 32)
	boss_data.biome = Enums.BiomeType.ASH_MEADOWS
	boss_data.sprite_color = Color(0.85, 0.35, 0.1)
	boss_data.loot_table = BossLoot.create_loot_table_tier1("ash_warden")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Ember Guardian (100% - 50%)
	var phase1 := BossPhase.create(0, "Ember Guardian", 1.0)
	
	var flame_slash := BossAbility.create(
		"Flame Slash", 18, 4.0, 64.0,
		BossAbility.AreaType.CONE, Vector2(60, 48), 0.8
	)
	flame_slash.priority = 5
	flame_slash.callback_name = "_ability_flame_slash"
	phase1.add_ability(flame_slash)
	
	var ember_toss := BossAbility.create(
		"Ember Toss", 12, 6.0, 160.0,
		BossAbility.AreaType.CIRCLE, Vector2(48, 48), 1.0
	)
	ember_toss.priority = 4
	ember_toss.status_effect = Enums.EffectType.BURN_DOT
	ember_toss.status_duration = 3.0
	ember_toss.callback_name = "_ability_ember_toss"
	phase1.add_ability(ember_toss)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Inferno (50% - 0%)
	var phase2 := BossPhase.create(1, "Inferno", 0.5)
	phase2.set_modifiers({"damage_mult": 1.3, "speed_mult": 1.2})
	
	var flame_slash2 := BossAbility.create(
		"Flame Slash", 22, 3.5, 64.0,
		BossAbility.AreaType.CONE, Vector2(70, 56), 0.7
	)
	flame_slash2.priority = 5
	flame_slash2.callback_name = "_ability_flame_slash"
	phase2.add_ability(flame_slash2)
	
	var ember_toss2 := BossAbility.create(
		"Ember Toss", 15, 5.0, 180.0,
		BossAbility.AreaType.CIRCLE, Vector2(56, 56), 0.8
	)
	ember_toss2.priority = 4
	ember_toss2.status_effect = Enums.EffectType.BURN_DOT
	ember_toss2.status_duration = 4.0
	ember_toss2.callback_name = "_ability_ember_toss"
	phase2.add_ability(ember_toss2)
	
	var flame_dash := BossAbility.create(
		"Flame Dash", 25, 8.0, 128.0,
		BossAbility.AreaType.LINE, Vector2(128, 24), 1.2
	)
	flame_dash.priority = 7
	flame_dash.callback_name = "_ability_flame_dash"
	phase2.add_ability(flame_dash)
	
	boss_data.phases.append(phase2)


# === Ability implementációk ===

func _ability_flame_slash(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var cone_angle := deg_to_rad(60.0)
	
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var dist := to_player.length()
		if dist > ability.range:
			continue
		var angle := abs(to_player.angle_to(dir))
		if angle <= cone_angle / 2.0:
			_deal_damage_to(player, ability.damage)
	
	# Tűz effekt
	_spawn_fire_effect(global_position + dir * 32, Vector2(48, 48), 0.4)


func _ability_ember_toss(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var target_pos := _current_target.global_position
	
	# 3 zsarátnok különböző pozíciókba
	for i in 3:
		var offset := Vector2(randf_range(-32, 32), randf_range(-32, 32))
		var pos := target_pos + offset
		
		# Késleltetett detonáció
		var delay := 0.2 * i
		var timer := get_tree().create_timer(delay)
		timer.timeout.connect(func():
			for player in get_tree().get_nodes_in_group("player"):
				if player.global_position.distance_to(pos) <= ability.area_size.x / 2.0:
					_deal_damage_to(player, ability.damage)
					_apply_status_to(player, Enums.EffectType.BURN_DOT, ability.status_duration)
			_spawn_fire_effect(pos, Vector2(24, 24), 0.5)
		)


func _ability_flame_dash(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var dash_distance := 96.0
	var start_pos := global_position
	var end_pos := global_position + dir * dash_distance
	
	# Gyors dash
	var tween := create_tween()
	tween.tween_property(self, "global_position", end_pos, 0.2)
	
	# Tűznyom a dash úton
	for i in 4:
		var trail_pos := start_pos + dir * (dash_distance * i / 4.0)
		_spawn_fire_trail(trail_pos, 2.0)
	
	# Damage a célpontra
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - start_pos
		var proj := to_player.dot(dir)
		if proj < 0 or proj > dash_distance:
			continue
		var perp := abs(to_player.cross(dir))
		if perp <= 16.0:
			_deal_damage_to(player, ability.damage)


# === Segéd metódusok ===

func _spawn_fire_effect(pos: Vector2, size: Vector2, duration: float) -> void:
	var effect := Sprite2D.new()
	var img := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.5, 0.1, 0.6))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = pos
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, duration)
	tween.tween_callback(effect.queue_free)


func _spawn_fire_trail(pos: Vector2, duration: float) -> void:
	var trail := Sprite2D.new()
	var img := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.3, 0.0, 0.5))
	trail.texture = ImageTexture.create_from_image(img)
	trail.global_position = pos
	trail.z_index = -1
	get_parent().add_child(trail)
	
	# Tűznyom damage tick
	var tick := Timer.new()
	tick.wait_time = 0.5
	tick.autostart = true
	tick.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(pos) <= 16:
				_deal_damage_to(player, 5.0)
	)
	trail.add_child(tick)
	
	var life := Timer.new()
	life.wait_time = duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(trail.queue_free)
	trail.add_child(life)

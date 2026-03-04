## AncientDragon - Tier 3 World Boss: Ashlands / Mountains
## Hatalmas sárkány. Breath Attack, Wing Gust, Tail Slam, Sky Dive.
## Level: 45-48, HP: 120,000, DMG: 180-250, 4 phases, 4-player recommended
class_name AncientDragon
extends BossBase


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Ancient Dragon"
	boss_data.boss_id = "ancient_dragon"
	boss_data.tier = 3
	boss_data.base_hp = 120000
	boss_data.armor = 50
	boss_data.damage = 210
	boss_data.speed = 45.0
	boss_data.attack_speed = 0.8
	boss_data.recommended_level_min = 45
	boss_data.recommended_level_max = 48
	boss_data.required_players = 4
	boss_data.enrage_time = Constants.BOSS_ENRAGE_TIMERS.get(3, 600.0)
	boss_data.sprite_size = Vector2(96, 96)
	boss_data.collision_size = Vector2(72, 72)
	boss_data.biome = Enums.BiomeType.ASHLANDS
	boss_data.sprite_color = Color(0.4, 0.15, 0.1)
	boss_data.loot_table = BossLoot.create_loot_table_tier3("ancient_dragon")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Slumbering Wrath (100% - 75%)
	var phase1 := BossPhase.create(0, "Slumbering Wrath", 1.0)
	
	var fire_breath := BossAbility.create(
		"Fire Breath", 200, 6.0, 160.0,
		BossAbility.AreaType.CONE, Vector2(60, 160), 1.5
	)
	fire_breath.priority = 6
	fire_breath.status_effect = Enums.EffectType.BURN_DOT
	fire_breath.status_duration = 5.0
	fire_breath.callback_name = "_ability_fire_breath"
	phase1.add_ability(fire_breath)
	
	var claw_swipe := BossAbility.create(
		"Claw Swipe", 190, 4.0, 80.0,
		BossAbility.AreaType.CONE, Vector2(90, 80), 0.8
	)
	claw_swipe.priority = 5
	claw_swipe.callback_name = "_ability_claw_swipe"
	phase1.add_ability(claw_swipe)
	
	var tail_slam := BossAbility.create(
		"Tail Slam", 220, 8.0, 96.0,
		BossAbility.AreaType.CIRCLE, Vector2(96, 96), 1.2
	)
	tail_slam.priority = 7
	tail_slam.callback_name = "_ability_tail_slam"
	phase1.add_ability(tail_slam)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Skyborn (75% - 50%)
	var phase2 := BossPhase.create(1, "Skyborn", 0.75)
	phase2.set_modifiers({"damage_mult": 1.2, "speed_mult": 1.3})
	
	var fire_breath2 := BossAbility.create(
		"Fire Breath", 220, 5.0, 180.0,
		BossAbility.AreaType.CONE, Vector2(70, 180), 1.3
	)
	fire_breath2.priority = 6
	fire_breath2.status_effect = Enums.EffectType.BURN_DOT
	fire_breath2.status_duration = 6.0
	fire_breath2.callback_name = "_ability_fire_breath"
	phase2.add_ability(fire_breath2)
	
	var wing_gust := BossAbility.create(
		"Wing Gust", 150, 10.0, 128.0,
		BossAbility.AreaType.CIRCLE, Vector2(128, 128), 1.0
	)
	wing_gust.priority = 8
	wing_gust.callback_name = "_ability_wing_gust"
	phase2.add_ability(wing_gust)
	
	var sky_dive := BossAbility.create(
		"Sky Dive", 250, 15.0, 300.0,
		BossAbility.AreaType.CIRCLE, Vector2(80, 80), 2.5
	)
	sky_dive.priority = 9
	sky_dive.callback_name = "_ability_sky_dive"
	phase2.add_ability(sky_dive)
	
	boss_data.phases.append(phase2)
	
	# Phase 3: Infernal Storm (50% - 25%)
	var phase3 := BossPhase.create(2, "Infernal Storm", 0.50)
	phase3.set_modifiers({"damage_mult": 1.5, "attack_speed_mult": 1.3})
	phase3.aura_damage = 20.0
	phase3.aura_range = 64.0
	
	var firestorm := BossAbility.create(
		"Firestorm", 180, 8.0, 250.0,
		BossAbility.AreaType.CIRCLE, Vector2(200, 200), 2.0
	)
	firestorm.priority = 9
	firestorm.callback_name = "_ability_firestorm"
	phase3.add_ability(firestorm)
	
	var claw_swipe2 := BossAbility.create(
		"Dragon Fury", 240, 3.5, 80.0,
		BossAbility.AreaType.CONE, Vector2(100, 96), 0.6
	)
	claw_swipe2.priority = 5
	claw_swipe2.callback_name = "_ability_claw_swipe"
	phase3.add_ability(claw_swipe2)
	
	var sky_dive2 := BossAbility.create(
		"Sky Dive", 280, 12.0, 300.0,
		BossAbility.AreaType.CIRCLE, Vector2(96, 96), 2.0
	)
	sky_dive2.priority = 8
	sky_dive2.callback_name = "_ability_sky_dive"
	phase3.add_ability(sky_dive2)
	
	boss_data.phases.append(phase3)
	
	# Phase 4: Ancient Fury (25% - 0%)
	var phase4 := BossPhase.create(3, "Ancient Fury", 0.25)
	phase4.set_modifiers({"damage_mult": 2.0, "attack_speed_mult": 1.6, "speed_mult": 1.5})
	phase4.aura_damage = 40.0
	phase4.aura_range = 80.0
	
	var apocalypse_breath := BossAbility.create(
		"Apocalypse Breath", 300, 10.0, 200.0,
		BossAbility.AreaType.CONE, Vector2(120, 200), 2.0
	)
	apocalypse_breath.priority = 10
	apocalypse_breath.status_effect = Enums.EffectType.BURN_DOT
	apocalypse_breath.status_duration = 8.0
	apocalypse_breath.callback_name = "_ability_fire_breath"
	phase4.add_ability(apocalypse_breath)
	
	var sky_dive3 := BossAbility.create(
		"Annihilation Dive", 350, 10.0, 300.0,
		BossAbility.AreaType.CIRCLE, Vector2(112, 112), 2.0
	)
	sky_dive3.priority = 9
	sky_dive3.callback_name = "_ability_sky_dive"
	phase4.add_ability(sky_dive3)
	
	var summon_drakes := BossAbility.create(
		"Summon Drakes", 0, 25.0, 300.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	summon_drakes.priority = 7
	summon_drakes.summon_count = 2
	summon_drakes.summon_data = {
		"name": "Fire Drake", "id": "fire_drake", "hp": 3000,
		"damage": 80, "speed": 70.0, "attack_range": 96.0,
		"xp": 200, "color": Color(0.8, 0.3, 0.1),
		"category": Enums.EnemyType.RANGED,
	}
	summon_drakes.callback_name = "_ability_summon_drakes"
	phase4.add_ability(summon_drakes)
	
	boss_data.phases.append(phase4)


# === Ability implementációk ===

func _ability_fire_breath(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var cone_angle := deg_to_rad(ability.area_size.x)
	var length := ability.area_size.y
	
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var dist := to_player.length()
		if dist > length:
			continue
		var angle := abs(to_player.angle_to(dir))
		if angle <= cone_angle / 2.0:
			var falloff := 1.0 - (dist / length) * 0.3
			_deal_damage_to(player, ability.damage * falloff)
			_apply_status_to(player, Enums.EffectType.BURN_DOT, ability.status_duration)
	
	# Visual: tűzlélegzet
	_spawn_cone_effect(global_position, dir, length, cone_angle, Color(1.0, 0.4, 0.0, 0.5), 0.8)


func _ability_claw_swipe(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var cone_angle := deg_to_rad(ability.area_size.x)
	var length := ability.area_size.y
	
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var dist := to_player.length()
		if dist > length:
			continue
		var angle := abs(to_player.angle_to(dir))
		if angle <= cone_angle / 2.0:
			_deal_damage_to(player, ability.damage)
			if player.has_method("apply_knockback"):
				player.apply_knockback(dir * 150.0)


func _ability_tail_slam(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	# Hátsó félkör
	var back_dir := Vector2.ZERO
	if _current_target and is_instance_valid(_current_target):
		back_dir = _current_target.global_position.direction_to(global_position)
	
	for player in get_tree().get_nodes_in_group("player"):
		var dist := player.global_position.distance_to(global_position)
		if dist <= radius:
			_deal_damage_to(player, ability.damage)
			_apply_status_to(player, Enums.EffectType.STUN, 1.0)
			if player.has_method("apply_knockback"):
				var kb := global_position.direction_to(player.global_position) * 200.0
				player.apply_knockback(kb)
	
	_spawn_circle_effect(global_position, radius, Color(0.5, 0.3, 0.1, 0.4), 0.5)


func _ability_wing_gust(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	for player in get_tree().get_nodes_in_group("player"):
		var dist := player.global_position.distance_to(global_position)
		if dist <= radius:
			_deal_damage_to(player, ability.damage)
			# Erős knockback
			if player.has_method("apply_knockback"):
				var kb := global_position.direction_to(player.global_position) * 350.0
				player.apply_knockback(kb)
	
	_spawn_circle_effect(global_position, radius, Color(0.9, 0.9, 0.8, 0.3), 0.6)


func _ability_sky_dive(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var target_pos := _current_target.global_position
	var radius := ability.area_size.x / 2.0
	
	# Eltűnik (levegőbe emelkedik)
	is_invulnerable = true
	var rise_tween := create_tween()
	rise_tween.tween_property(sprite, "modulate:a", 0.2, 0.5)
	rise_tween.tween_property(sprite, "position:y", -64.0, 0.5)
	
	# Telegraph a célponton
	_spawn_circle_effect(target_pos, radius, Color(1.0, 0.3, 0.0, 0.3), 2.0)
	
	# Delay → impact
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		global_position = target_pos
		is_invulnerable = false
		
		var land_tween := create_tween()
		land_tween.tween_property(sprite, "position:y", 0.0, 0.15)
		land_tween.tween_property(sprite, "modulate:a", 1.0, 0.15)
		
		for player in get_tree().get_nodes_in_group("player"):
			var dist := player.global_position.distance_to(target_pos)
			if dist <= radius:
				var falloff := 1.0 - (dist / radius) * 0.4
				_deal_damage_to(player, ability.damage * falloff)
				_apply_status_to(player, Enums.EffectType.STUN, 1.5)
				if player.has_method("apply_knockback"):
					var kb := target_pos.direction_to(player.global_position) * 300.0
					player.apply_knockback(kb)
		
		_spawn_circle_effect(target_pos, radius * 1.3, Color(1.0, 0.4, 0.0, 0.7), 0.5)
	)


func _ability_firestorm(ability: BossAbility) -> void:
	var center := global_position
	var radius := ability.area_size.x / 2.0
	var count := 12
	
	for i in count:
		var delay := randf() * 3.0
		var pos := center + Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
		var timer := get_tree().create_timer(delay)
		timer.timeout.connect(func():
			_spawn_circle_effect(pos, 16.0, Color(1.0, 0.5, 0.0, 0.3), 0.3)
			var dmg_timer := get_tree().create_timer(0.3)
			dmg_timer.timeout.connect(func():
				for player in get_tree().get_nodes_in_group("player"):
					if player.global_position.distance_to(pos) <= 24.0:
						_deal_damage_to(player, ability.damage)
				_spawn_circle_effect(pos, 24.0, Color(1.0, 0.3, 0.0, 0.6), 0.3)
			)
		)


func _ability_summon_drakes(ability: BossAbility) -> void:
	var current_count := get_active_summon_count()
	if current_count >= 4:
		return
	
	var to_spawn := mini(ability.summon_count, 4 - current_count)
	for i in to_spawn:
		_spawn_summon(ability.summon_data, i)


# === Segéd metódusok ===

func _spawn_circle_effect(center: Vector2, radius: float, color: Color, duration: float) -> void:
	var effect := Node2D.new()
	effect.global_position = center
	
	var script_text := """
extends Node2D
var radius: float
var color: Color
func _draw():
	draw_circle(Vector2.ZERO, radius, color)
"""
	var script := GDScript.new()
	script.source_code = script_text
	script.reload()
	effect.set_script(script)
	effect.set("radius", radius)
	effect.set("color", color)
	
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, duration)
	tween.tween_callback(effect.queue_free)


func _spawn_cone_effect(origin: Vector2, dir: Vector2, length: float, angle: float, color: Color, duration: float) -> void:
	var effect := Node2D.new()
	effect.global_position = origin
	
	var script_text := """
extends Node2D
var dir: Vector2
var length: float
var angle: float
var color: Color
func _draw():
	var points: PackedVector2Array = [Vector2.ZERO]
	var segments := 8
	var start_angle := dir.angle() - angle / 2.0
	for i in segments + 1:
		var a := start_angle + angle * float(i) / float(segments)
		points.append(Vector2(cos(a), sin(a)) * length)
	draw_colored_polygon(points, color)
"""
	var script := GDScript.new()
	script.source_code = script_text
	script.reload()
	effect.set_script(script)
	effect.set("dir", dir)
	effect.set("length", length)
	effect.set("angle", angle)
	effect.set("color", color)
	
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, duration)
	tween.tween_callback(effect.queue_free)

## VolcanicOverlord - Tier 2 Boss: Ashlands
## Tüzes óriás. Magma Rain, Lava Wave, Eruption, Meteor Strike.
## Level: 34-38, HP: 35,000, DMG: 120-160, 4 phases
class_name VolcanicOverlord
extends BossBase


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Volcanic Overlord"
	boss_data.boss_id = "volcanic_overlord"
	boss_data.tier = 2
	boss_data.base_hp = 35000
	boss_data.armor = 30
	boss_data.damage = 140
	boss_data.speed = 30.0
	boss_data.attack_speed = 0.9
	boss_data.recommended_level_min = 34
	boss_data.recommended_level_max = 38
	boss_data.required_players = 1
	boss_data.enrage_time = Constants.BOSS_ENRAGE_TIMERS.get(2, 420.0)
	boss_data.sprite_size = Vector2(64, 72)
	boss_data.collision_size = Vector2(48, 56)
	boss_data.biome = Enums.BiomeType.ASHLANDS
	boss_data.sprite_color = Color(0.7, 0.2, 0.05)
	boss_data.loot_table = BossLoot.create_loot_table_tier2("volcanic_overlord")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Molten Guardian (100% - 75%)
	var phase1 := BossPhase.create(0, "Molten Guardian", 1.0)
	
	var magma_slam := BossAbility.create(
		"Magma Slam", 140, 5.0, 64.0,
		BossAbility.AreaType.CIRCLE, Vector2(56, 56), 1.2
	)
	magma_slam.priority = 5
	magma_slam.callback_name = "_ability_magma_slam"
	phase1.add_ability(magma_slam)
	
	var lava_ball := BossAbility.create(
		"Lava Ball", 120, 4.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(40, 40), 1.0
	)
	lava_ball.priority = 4
	lava_ball.status_effect = Enums.EffectType.BURN_DOT
	lava_ball.status_duration = 5.0
	lava_ball.is_tracking = true
	lava_ball.projectile_speed = 150.0
	lava_ball.callback_name = "_ability_lava_ball"
	phase1.add_ability(lava_ball)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Erupting (75% - 50%)
	var phase2 := BossPhase.create(1, "Erupting", 0.75)
	phase2.set_modifiers({"damage_mult": 1.2})
	
	var magma_slam2 := BossAbility.create(
		"Magma Slam", 155, 4.5, 64.0,
		BossAbility.AreaType.CIRCLE, Vector2(64, 64), 1.0
	)
	magma_slam2.priority = 5
	magma_slam2.callback_name = "_ability_magma_slam"
	phase2.add_ability(magma_slam2)
	
	var lava_wave := BossAbility.create(
		"Lava Wave", 130, 8.0, 180.0,
		BossAbility.AreaType.RECT, Vector2(64, 180), 1.5
	)
	lava_wave.priority = 7
	lava_wave.status_effect = Enums.EffectType.BURN_DOT
	lava_wave.status_duration = 4.0
	lava_wave.callback_name = "_ability_lava_wave"
	phase2.add_ability(lava_wave)
	
	var magma_rain := BossAbility.create(
		"Magma Rain", 100, 12.0, 250.0,
		BossAbility.AreaType.CIRCLE, Vector2(160, 160), 2.0
	)
	magma_rain.priority = 8
	magma_rain.callback_name = "_ability_magma_rain"
	phase2.add_ability(magma_rain)
	
	boss_data.phases.append(phase2)
	
	# Phase 3: Volcanic Fury (50% - 25%)
	var phase3 := BossPhase.create(2, "Volcanic Fury", 0.50)
	phase3.set_modifiers({"damage_mult": 1.4, "attack_speed_mult": 1.2})
	phase3.aura_damage = 15.0
	phase3.aura_range = 48.0
	
	var eruption := BossAbility.create(
		"Eruption", 160, 6.0, 96.0,
		BossAbility.AreaType.CIRCLE, Vector2(96, 96), 1.5
	)
	eruption.priority = 8
	eruption.callback_name = "_ability_eruption"
	phase3.add_ability(eruption)
	
	var lava_wave2 := BossAbility.create(
		"Lava Wave", 145, 7.0, 200.0,
		BossAbility.AreaType.RECT, Vector2(72, 200), 1.2
	)
	lava_wave2.priority = 6
	lava_wave2.status_effect = Enums.EffectType.BURN_DOT
	lava_wave2.status_duration = 5.0
	lava_wave2.callback_name = "_ability_lava_wave"
	phase3.add_ability(lava_wave2)
	
	var magma_rain2 := BossAbility.create(
		"Magma Rain", 110, 10.0, 280.0,
		BossAbility.AreaType.CIRCLE, Vector2(180, 180), 1.8
	)
	magma_rain2.priority = 7
	magma_rain2.callback_name = "_ability_magma_rain"
	phase3.add_ability(magma_rain2)
	
	boss_data.phases.append(phase3)
	
	# Phase 4: Meltdown (25% - 0%)
	var phase4 := BossPhase.create(3, "Meltdown", 0.25)
	phase4.set_modifiers({"damage_mult": 1.8, "attack_speed_mult": 1.5, "speed_mult": 1.3})
	phase4.aura_damage = 25.0
	phase4.aura_range = 64.0
	
	var meteor := BossAbility.create(
		"Meteor Strike", 200, 15.0, 300.0,
		BossAbility.AreaType.CIRCLE, Vector2(96, 96), 2.5
	)
	meteor.priority = 10
	meteor.callback_name = "_ability_meteor_strike"
	phase4.add_ability(meteor)
	
	var eruption2 := BossAbility.create(
		"Eruption", 180, 5.0, 96.0,
		BossAbility.AreaType.CIRCLE, Vector2(112, 112), 1.2
	)
	eruption2.priority = 8
	eruption2.callback_name = "_ability_eruption"
	phase4.add_ability(eruption2)
	
	var lava_wave3 := BossAbility.create(
		"Lava Wave", 160, 6.0, 220.0,
		BossAbility.AreaType.RECT, Vector2(80, 220), 1.0
	)
	lava_wave3.priority = 6
	lava_wave3.status_effect = Enums.EffectType.BURN_DOT
	lava_wave3.status_duration = 6.0
	lava_wave3.callback_name = "_ability_lava_wave"
	phase4.add_ability(lava_wave3)
	
	boss_data.phases.append(phase4)


# === Ability implementációk ===

func _ability_magma_slam(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	for player in get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(global_position) <= radius:
			_deal_damage_to(player, ability.damage)
			if player.has_method("apply_knockback"):
				var kb := global_position.direction_to(player.global_position) * 150.0
				player.apply_knockback(kb)
	
	# Impact effekt
	_spawn_impact_effect(global_position, radius, Color(1.0, 0.3, 0.0, 0.5))


func _ability_lava_ball(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var proj := Projectile.new()
	proj.setup(
		ability.damage * damage_multiplier,
		ability.projectile_speed,
		global_position.direction_to(_current_target.global_position),
		"boss",
		Enums.DamageType.FIRE,
	)
	proj.global_position = global_position
	proj.tracking_target = _current_target
	get_parent().add_child(proj)


func _ability_lava_wave(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var length := ability.area_size.y
	var width := ability.area_size.x
	
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var proj_val := to_player.dot(dir)
		if proj_val < 0 or proj_val > length:
			continue
		var perp := abs(to_player.cross(dir))
		if perp <= width / 2.0:
			_deal_damage_to(player, ability.damage)
			_apply_status_to(player, Enums.EffectType.BURN_DOT, ability.status_duration)
	
	# Lava trail vizuális
	var effect := Sprite2D.new()
	var img := Image.create(int(width), int(length), false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.4, 0.0, 0.4))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = global_position + dir * length / 2.0
	effect.rotation = dir.angle() + PI / 2.0
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 1.0)
	tween.tween_callback(effect.queue_free)


func _ability_magma_rain(ability: BossAbility) -> void:
	var center := _current_target.global_position if _current_target and is_instance_valid(_current_target) else global_position
	var radius := ability.area_size.x / 2.0
	var count := 8
	
	for i in count:
		var delay := randf() * 2.0
		var pos := center + Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
		var timer := get_tree().create_timer(delay)
		timer.timeout.connect(func():
			# Warning circle
			_spawn_impact_effect(pos, 20.0, Color(1.0, 0.5, 0.0, 0.3))
			# Delayed damage
			var dmg_timer := get_tree().create_timer(0.5)
			dmg_timer.timeout.connect(func():
				for player in get_tree().get_nodes_in_group("player"):
					if player.global_position.distance_to(pos) <= 20.0:
						_deal_damage_to(player, ability.damage)
				_spawn_impact_effect(pos, 24.0, Color(1.0, 0.2, 0.0, 0.7))
			)
		)


func _ability_eruption(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	# Ground rumble → then damage
	_spawn_impact_effect(global_position, radius, Color(0.8, 0.3, 0.0, 0.3))
	
	var timer := get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(global_position) <= radius:
				_deal_damage_to(player, ability.damage)
				if player.has_method("apply_knockback"):
					var kb := global_position.direction_to(player.global_position) * 250.0
					player.apply_knockback(kb)
		_spawn_impact_effect(global_position, radius * 1.2, Color(1.0, 0.4, 0.0, 0.6))
	)


func _ability_meteor_strike(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var target_pos := _current_target.global_position
	var radius := ability.area_size.x / 2.0
	
	# Telegraph: nagy piros kör
	_spawn_impact_effect(target_pos, radius, Color(1.0, 0.2, 0.0, 0.3))
	
	# Delay → impact
	var timer := get_tree().create_timer(1.5)
	timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			var dist := player.global_position.distance_to(target_pos)
			if dist <= radius:
				var falloff := 1.0 - (dist / radius) * 0.5
				_deal_damage_to(player, ability.damage * falloff)
				_apply_status_to(player, Enums.EffectType.STUN, 1.5)
				if player.has_method("apply_knockback"):
					var kb := target_pos.direction_to(player.global_position) * 300.0
					player.apply_knockback(kb)
		
		# Massive impact visual
		_spawn_impact_effect(target_pos, radius * 1.5, Color(1.0, 0.3, 0.0, 0.8))
		
		# Lava hazard marad 5 mp-ig
		_spawn_lava_hazard(target_pos, radius * 0.6, 5.0)
	)


# === Segéd metódusok ===

func _spawn_impact_effect(pos: Vector2, radius: float, color: Color) -> void:
	var effect := Node2D.new()
	effect.global_position = pos
	
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
	tween.tween_property(effect, "modulate:a", 0.0, 0.6)
	tween.tween_callback(effect.queue_free)


func _spawn_lava_hazard(center: Vector2, radius: float, duration: float) -> void:
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
	effect.set("color", Color(1.0, 0.3, 0.0, 0.35))
	
	get_parent().add_child(effect)
	
	var tick := Timer.new()
	tick.wait_time = 0.5
	tick.autostart = true
	tick.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(center) <= radius:
				_deal_damage_to(player, 20.0)
	)
	effect.add_child(tick)
	
	var life := Timer.new()
	life.wait_time = duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(effect.queue_free)
	effect.add_child(life)

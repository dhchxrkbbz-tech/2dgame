## VoidEmperor - Tier 4 Raid Boss: The Void Throne (Ultimate Endgame)
## A játék végleges boss-a. NM5+ szinten. 8 phases.
## Level: 50+NM5, HP: 800,000, DMG: 400-550, 4-player mandatory
class_name VoidEmperor
extends BossBase

var _reality_anchors: Array[Node] = []
var _void_corruption_level: float = 0.0


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "The Void Emperor"
	boss_data.boss_id = "void_emperor"
	boss_data.tier = 4
	boss_data.base_hp = 800000
	boss_data.armor = 80
	boss_data.damage = 470
	boss_data.speed = 45.0
	boss_data.attack_speed = 1.0
	boss_data.recommended_level_min = 50
	boss_data.recommended_level_max = 50
	boss_data.required_players = 4
	boss_data.enrage_time = Constants.BOSS_ENRAGE_TIMERS.get(4, 900.0)
	boss_data.sprite_size = Vector2(96, 112)
	boss_data.collision_size = Vector2(64, 80)
	boss_data.biome = Enums.BiomeType.VOID_RIFT
	boss_data.sprite_color = Color(0.1, 0.0, 0.2)
	boss_data.loot_table = BossLoot.create_loot_table_tier4("void_emperor")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Imperial Presence (100% - 90%)
	var p1 := BossPhase.create(0, "Imperial Presence", 1.0)
	
	var void_slash := BossAbility.create(
		"Void Slash", 420, 3.0, 96.0,
		BossAbility.AreaType.CONE, Vector2(100, 96), 0.8
	)
	void_slash.priority = 5
	void_slash.callback_name = "_ability_void_slash"
	p1.add_ability(void_slash)
	
	var dark_pulse := BossAbility.create(
		"Dark Pulse", 380, 5.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(64, 64), 1.0
	)
	dark_pulse.priority = 6
	dark_pulse.callback_name = "_ability_dark_pulse"
	p1.add_ability(dark_pulse)
	
	boss_data.phases.append(p1)
	
	# Phase 2: Void Command (90% - 78%)
	var p2 := BossPhase.create(1, "Void Command", 0.90)
	p2.set_modifiers({"damage_mult": 1.1})
	
	var summon_guards := BossAbility.create(
		"Summon Void Guard", 0, 18.0, 300.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	summon_guards.priority = 8
	summon_guards.summon_count = 2
	summon_guards.summon_data = {
		"name": "Void Guard", "id": "void_guard", "hp": 10000,
		"damage": 120, "speed": 45.0, "attack_range": 48.0,
		"xp": 300, "color": Color(0.15, 0.0, 0.3),
		"category": Enums.EnemyType.MELEE,
	}
	summon_guards.callback_name = "_ability_summon_guards"
	p2.add_ability(summon_guards)
	
	var void_slash2 := BossAbility.create(
		"Void Slash", 440, 2.8, 96.0,
		BossAbility.AreaType.CONE, Vector2(100, 96), 0.7
	)
	void_slash2.priority = 5
	void_slash2.callback_name = "_ability_void_slash"
	p2.add_ability(void_slash2)
	
	var dark_beam := BossAbility.create(
		"Dark Beam", 400, 6.0, 220.0,
		BossAbility.AreaType.LINE, Vector2(220, 32), 1.5
	)
	dark_beam.priority = 7
	dark_beam.callback_name = "_ability_dark_beam"
	p2.add_ability(dark_beam)
	
	boss_data.phases.append(p2)
	
	# Phase 3: Dimensional Terror (78% - 65%)
	var p3 := BossPhase.create(2, "Dimensional Terror", 0.78)
	p3.set_modifiers({"damage_mult": 1.2, "speed_mult": 1.1})
	
	var void_prison := BossAbility.create(
		"Void Prison", 350, 14.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(48, 48), 2.0
	)
	void_prison.priority = 9
	void_prison.callback_name = "_ability_void_prison"
	p3.add_ability(void_prison)
	
	var reality_shatter := BossAbility.create(
		"Reality Shatter", 450, 8.0, 180.0,
		BossAbility.AreaType.CIRCLE, Vector2(120, 120), 1.8
	)
	reality_shatter.priority = 8
	reality_shatter.callback_name = "_ability_reality_shatter"
	p3.add_ability(reality_shatter)
	
	var dark_beam2 := BossAbility.create(
		"Dark Beam", 420, 5.0, 240.0,
		BossAbility.AreaType.LINE, Vector2(240, 40), 1.2
	)
	dark_beam2.priority = 6
	dark_beam2.callback_name = "_ability_dark_beam"
	p3.add_ability(dark_beam2)
	
	boss_data.phases.append(p3)
	
	# Phase 4: Corruption Spread (65% - 50%)
	var p4 := BossPhase.create(3, "Corruption Spread", 0.65)
	p4.set_modifiers({"damage_mult": 1.35, "attack_speed_mult": 1.2})
	p4.aura_damage = 25.0
	p4.aura_range = 80.0
	
	var corruption_wave := BossAbility.create(
		"Corruption Wave", 430, 7.0, 220.0,
		BossAbility.AreaType.RECT, Vector2(100, 220), 1.5
	)
	corruption_wave.priority = 8
	corruption_wave.status_effect = Enums.EffectType.POISON_DOT
	corruption_wave.status_duration = 6.0
	corruption_wave.callback_name = "_ability_corruption_wave"
	p4.add_ability(corruption_wave)
	
	var void_storm := BossAbility.create(
		"Void Storm", 380, 10.0, 260.0,
		BossAbility.AreaType.CIRCLE, Vector2(200, 200), 2.0
	)
	void_storm.priority = 9
	void_storm.callback_name = "_ability_void_storm"
	p4.add_ability(void_storm)
	
	var void_slash3 := BossAbility.create(
		"Void Slash", 460, 2.5, 96.0,
		BossAbility.AreaType.CONE, Vector2(110, 96), 0.6
	)
	void_slash3.priority = 5
	void_slash3.callback_name = "_ability_void_slash"
	p4.add_ability(void_slash3)
	
	boss_data.phases.append(p4)
	
	# Phase 5: Abyssal Rift (50% - 38%)
	var p5 := BossPhase.create(4, "Abyssal Rift", 0.50)
	p5.set_modifiers({"damage_mult": 1.5, "attack_speed_mult": 1.3, "speed_mult": 1.2})
	p5.aura_damage = 40.0
	p5.aura_range = 96.0
	
	var abyssal_maw := BossAbility.create(
		"Abyssal Maw", 500, 12.0, 300.0,
		BossAbility.AreaType.CIRCLE, Vector2(120, 120), 2.5
	)
	abyssal_maw.priority = 10
	abyssal_maw.callback_name = "_ability_abyssal_maw"
	p5.add_ability(abyssal_maw)
	
	var corruption_wave2 := BossAbility.create(
		"Corruption Wave", 460, 6.0, 240.0,
		BossAbility.AreaType.RECT, Vector2(110, 240), 1.2
	)
	corruption_wave2.priority = 7
	corruption_wave2.status_effect = Enums.EffectType.POISON_DOT
	corruption_wave2.status_duration = 8.0
	corruption_wave2.callback_name = "_ability_corruption_wave"
	p5.add_ability(corruption_wave2)
	
	var reality_shatter2 := BossAbility.create(
		"Reality Shatter", 480, 7.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(140, 140), 1.5
	)
	reality_shatter2.priority = 8
	reality_shatter2.callback_name = "_ability_reality_shatter"
	p5.add_ability(reality_shatter2)
	
	boss_data.phases.append(p5)
	
	# Phase 6: Emperor's Wrath (38% - 25%)
	var p6 := BossPhase.create(5, "Emperor's Wrath", 0.38)
	p6.set_modifiers({"damage_mult": 1.8, "attack_speed_mult": 1.5, "speed_mult": 1.3})
	p6.aura_damage = 55.0
	p6.aura_range = 112.0
	
	var emperor_beam := BossAbility.create(
		"Emperor's Beam", 520, 5.0, 280.0,
		BossAbility.AreaType.LINE, Vector2(280, 56), 1.5
	)
	emperor_beam.priority = 8
	emperor_beam.callback_name = "_ability_dark_beam"
	p6.add_ability(emperor_beam)
	
	var summon_champions := BossAbility.create(
		"Summon Champions", 0, 25.0, 300.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	summon_champions.priority = 9
	summon_champions.summon_count = 2
	summon_champions.summon_data = {
		"name": "Void Champion", "id": "void_champion", "hp": 20000,
		"damage": 180, "speed": 55.0, "attack_range": 64.0,
		"xp": 500, "color": Color(0.2, 0.0, 0.4),
		"category": Enums.EnemyType.MELEE,
	}
	summon_champions.callback_name = "_ability_summon_guards"
	p6.add_ability(summon_champions)
	
	var abyssal_maw2 := BossAbility.create(
		"Abyssal Maw", 550, 10.0, 300.0,
		BossAbility.AreaType.CIRCLE, Vector2(140, 140), 2.0
	)
	abyssal_maw2.priority = 10
	abyssal_maw2.callback_name = "_ability_abyssal_maw"
	p6.add_ability(abyssal_maw2)
	
	boss_data.phases.append(p6)
	
	# Phase 7: Void Ascension (25% - 10%)
	var p7 := BossPhase.create(6, "Void Ascension", 0.25)
	p7.set_modifiers({"damage_mult": 2.2, "attack_speed_mult": 1.8, "speed_mult": 1.5})
	p7.aura_damage = 70.0
	p7.aura_range = 128.0
	
	var dimensional_collapse := BossAbility.create(
		"Dimensional Collapse", 580, 8.0, 300.0,
		BossAbility.AreaType.CIRCLE, Vector2(240, 240), 2.5
	)
	dimensional_collapse.priority = 10
	dimensional_collapse.callback_name = "_ability_dimensional_collapse"
	p7.add_ability(dimensional_collapse)
	
	var void_slash4 := BossAbility.create(
		"Imperial Execution", 600, 3.0, 96.0,
		BossAbility.AreaType.CONE, Vector2(120, 96), 0.5
	)
	void_slash4.priority = 6
	void_slash4.callback_name = "_ability_void_slash"
	p7.add_ability(void_slash4)
	
	var void_storm2 := BossAbility.create(
		"Void Storm", 450, 8.0, 280.0,
		BossAbility.AreaType.CIRCLE, Vector2(250, 250), 1.8
	)
	void_storm2.priority = 8
	void_storm2.callback_name = "_ability_void_storm"
	p7.add_ability(void_storm2)
	
	boss_data.phases.append(p7)
	
	# Phase 8: Eternal Void (10% - 0%)
	var p8 := BossPhase.create(7, "Eternal Void", 0.10)
	p8.set_modifiers({"damage_mult": 3.0, "attack_speed_mult": 2.0, "speed_mult": 2.0})
	p8.aura_damage = 100.0
	p8.aura_range = 160.0
	
	var eternal_void := BossAbility.create(
		"Eternal Void", 700, 15.0, 350.0,
		BossAbility.AreaType.CIRCLE, Vector2(300, 300), 3.0
	)
	eternal_void.priority = 10
	eternal_void.callback_name = "_ability_eternal_void"
	p8.add_ability(eternal_void)
	
	var imperial_execution := BossAbility.create(
		"Imperial Execution", 650, 2.5, 96.0,
		BossAbility.AreaType.CONE, Vector2(140, 96), 0.4
	)
	imperial_execution.priority = 7
	imperial_execution.callback_name = "_ability_void_slash"
	p8.add_ability(imperial_execution)
	
	var corruption_nova := BossAbility.create(
		"Corruption Nova", 550, 6.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(200, 200), 1.5
	)
	corruption_nova.priority = 8
	corruption_nova.callback_name = "_ability_corruption_nova"
	p8.add_ability(corruption_nova)
	
	boss_data.phases.append(p8)


# === Ability implementációk ===

func _ability_void_slash(ability: BossAbility) -> void:
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
	
	_spawn_void_effect(global_position + dir * length * 0.5, length * 0.5, Color(0.2, 0.0, 0.4, 0.5), 0.4)


func _ability_dark_pulse(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var target_pos := _current_target.global_position
	var radius := ability.area_size.x / 2.0
	
	for player in get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(target_pos) <= radius:
			_deal_damage_to(player, ability.damage)
	
	_spawn_void_effect(target_pos, radius, Color(0.3, 0.0, 0.5, 0.5), 0.5)


func _ability_dark_beam(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var length := ability.area_size.x
	var width := ability.area_size.y
	
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var proj_val := to_player.dot(dir)
		if proj_val < 0 or proj_val > length:
			continue
		var perp := abs(to_player.cross(dir))
		if perp <= width / 2.0:
			_deal_damage_to(player, ability.damage)
	
	var effect := Sprite2D.new()
	var img := Image.create(int(width * 2), int(length), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.2, 0.0, 0.4, 0.5))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = global_position + dir * length / 2.0
	effect.rotation = dir.angle() + PI / 2.0
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(effect.queue_free)


func _ability_summon_guards(ability: BossAbility) -> void:
	var current_count := get_active_summon_count()
	if current_count >= 6:
		return
	var to_spawn := mini(ability.summon_count, 6 - current_count)
	for i in to_spawn:
		_spawn_summon(ability.summon_data, i)


func _ability_void_prison(ability: BossAbility) -> void:
	var secondary := threat_table.get_secondary_target()
	if not secondary or not is_instance_valid(secondary):
		secondary = threat_table.get_random_target()
	if not secondary or not is_instance_valid(secondary):
		return
	
	_apply_status_to(secondary, Enums.EffectType.ROOT, 5.0)
	_spawn_void_effect(secondary.global_position, 24.0, Color(0.3, 0.0, 0.5, 0.6), 5.0)
	
	# Prison DOT
	var tick_count := 0
	var tick_timer := Timer.new()
	tick_timer.wait_time = 1.0
	tick_timer.autostart = true
	tick_timer.timeout.connect(func():
		tick_count += 1
		if is_instance_valid(secondary):
			_deal_damage_to(secondary, ability.damage * 0.5)
		if tick_count >= 5:
			tick_timer.queue_free()
	)
	add_child(tick_timer)


func _ability_reality_shatter(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	_spawn_void_effect(global_position, radius, Color(0.15, 0.0, 0.3, 0.3), 1.5)
	
	var timer := get_tree().create_timer(1.5)
	timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(global_position) <= radius:
				_deal_damage_to(player, ability.damage)
				_apply_status_to(player, Enums.EffectType.SILENCE, 2.0)
		_spawn_void_effect(global_position, radius * 1.3, Color(0.3, 0.0, 0.6, 0.7), 0.5)
	)


func _ability_corruption_wave(ability: BossAbility) -> void:
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
			_apply_status_to(player, Enums.EffectType.POISON_DOT, ability.status_duration)
	
	var effect := Sprite2D.new()
	var img := Image.create(int(width), int(length), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.2, 0.0, 0.3, 0.4))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = global_position + dir * length / 2.0
	effect.rotation = dir.angle() + PI / 2.0
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 1.0)
	tween.tween_callback(effect.queue_free)


func _ability_void_storm(ability: BossAbility) -> void:
	var center := global_position
	var radius := ability.area_size.x / 2.0
	var count := 14
	
	for i in count:
		var delay := randf() * 3.0
		var pos := center + Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
		var timer := get_tree().create_timer(delay)
		timer.timeout.connect(func():
			_spawn_void_effect(pos, 18.0, Color(0.2, 0.0, 0.4, 0.3), 0.3)
			var dmg_timer := get_tree().create_timer(0.3)
			dmg_timer.timeout.connect(func():
				for player in get_tree().get_nodes_in_group("player"):
					if player.global_position.distance_to(pos) <= 22.0:
						_deal_damage_to(player, ability.damage)
			)
		)


func _ability_abyssal_maw(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var target_pos := _current_target.global_position
	var radius := ability.area_size.x / 2.0
	
	_spawn_void_effect(target_pos, radius, Color(0.1, 0.0, 0.2, 0.3), 2.0)
	
	# Pull → damage
	var pull_timer := get_tree().create_timer(1.0)
	pull_timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			var dist := player.global_position.distance_to(target_pos)
			if dist <= radius and dist > 16:
				var pull_dir := player.global_position.direction_to(target_pos)
				if player.has_method("apply_knockback"):
					player.apply_knockback(pull_dir * 100.0)
	)
	
	var dmg_timer := get_tree().create_timer(2.0)
	dmg_timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(target_pos) <= radius:
				_deal_damage_to(player, ability.damage)
				_apply_status_to(player, Enums.EffectType.STUN, 2.0)
		_spawn_void_effect(target_pos, radius * 1.3, Color(0.2, 0.0, 0.5, 0.8), 0.5)
	)


func _ability_dimensional_collapse(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	_spawn_void_effect(global_position, radius, Color(0.1, 0.0, 0.2, 0.3), 2.5)
	
	# Pull fázis
	for i in 5:
		var timer := get_tree().create_timer(0.5 * i)
		timer.timeout.connect(func():
			for player in get_tree().get_nodes_in_group("player"):
				var dist := player.global_position.distance_to(global_position)
				if dist <= radius and dist > 20:
					var pull_dir := player.global_position.direction_to(global_position)
					if player.has_method("apply_knockback"):
						player.apply_knockback(pull_dir * 120.0)
		)
	
	# Final explosion
	var explosion := get_tree().create_timer(2.5)
	explosion.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			var dist := player.global_position.distance_to(global_position)
			if dist <= radius:
				var falloff := 1.0 - (dist / radius) * 0.3
				_deal_damage_to(player, ability.damage * falloff)
				_apply_status_to(player, Enums.EffectType.STUN, 2.5)
		_spawn_void_effect(global_position, radius * 1.5, Color(0.3, 0.0, 0.6, 0.9), 0.8)
	)


func _ability_corruption_nova(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	for player in get_tree().get_nodes_in_group("player"):
		var dist := player.global_position.distance_to(global_position)
		if dist <= radius:
			_deal_damage_to(player, ability.damage)
			_apply_status_to(player, Enums.EffectType.POISON_DOT, 8.0)
			_apply_status_to(player, Enums.EffectType.SLOW, 3.0)
	
	_spawn_void_effect(global_position, radius, Color(0.25, 0.0, 0.4, 0.6), 0.5)


func _ability_eternal_void(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	# Charge-up: 3 sec invulnerable
	is_invulnerable = true
	sprite.modulate = Color(0.5, 0.0, 1.0)
	
	_spawn_void_effect(global_position, radius, Color(0.1, 0.0, 0.2, 0.2), 3.0)
	
	var charge := get_tree().create_timer(3.0)
	charge.timeout.connect(func():
		is_invulnerable = false
		sprite.modulate = Color.WHITE
		
		# Massive damage to entire arena
		for player in get_tree().get_nodes_in_group("player"):
			var dist := player.global_position.distance_to(global_position)
			if dist <= radius:
				var falloff := 1.0 - (dist / radius) * 0.4
				_deal_damage_to(player, ability.damage * falloff)
				_apply_status_to(player, Enums.EffectType.STUN, 3.0)
				_apply_status_to(player, Enums.EffectType.POISON_DOT, 10.0)
				_apply_status_to(player, Enums.EffectType.SILENCE, 5.0)
		
		_spawn_void_effect(global_position, radius * 2.0, Color(0.2, 0.0, 0.5, 0.9), 1.5)
		
		# Void hazard marad 8 mp
		_spawn_void_zone(global_position, radius * 0.5, 8.0)
	)


# === Segéd metódusok ===

func _spawn_void_effect(center: Vector2, radius: float, color: Color, duration: float) -> void:
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


func _spawn_void_zone(center: Vector2, radius: float, duration: float) -> void:
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
	effect.set("color", Color(0.15, 0.0, 0.3, 0.3))
	
	get_parent().add_child(effect)
	
	var tick := Timer.new()
	tick.wait_time = 0.5
	tick.autostart = true
	tick.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(center) <= radius:
				_deal_damage_to(player, 40.0)
	)
	effect.add_child(tick)
	
	var life := Timer.new()
	life.wait_time = duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(effect.queue_free)
	effect.add_child(life)

## AshenGod - Tier 4 Raid Boss: The Ashen Throne
## Végső boss - tűz és hamu istene. 6 phase, 4-player mandatory, weekly lockout.
## Level: 50+, HP: 500,000, DMG: 300-400
class_name AshenGod
extends BossBase

var _ash_storm_active: bool = false


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "The Ashen God"
	boss_data.boss_id = "ashen_god"
	boss_data.tier = 4
	boss_data.base_hp = 500000
	boss_data.armor = 65
	boss_data.damage = 350
	boss_data.speed = 40.0
	boss_data.attack_speed = 0.9
	boss_data.recommended_level_min = 50
	boss_data.recommended_level_max = 50
	boss_data.required_players = 4
	boss_data.enrage_time = Constants.BOSS_ENRAGE_TIMERS.get(4, 900.0)
	boss_data.sprite_size = Vector2(80, 96)
	boss_data.collision_size = Vector2(56, 72)
	boss_data.biome = Enums.BiomeType.ASHLANDS
	boss_data.sprite_color = Color(0.55, 0.15, 0.05)
	boss_data.loot_table = BossLoot.create_loot_table_tier4("ashen_god")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Awakening (100% - 85%)
	var phase1 := BossPhase.create(0, "Awakening", 1.0)
	
	var ash_strike := BossAbility.create(
		"Ash Strike", 320, 3.5, 80.0,
		BossAbility.AreaType.CONE, Vector2(80, 80), 0.8
	)
	ash_strike.priority = 5
	ash_strike.callback_name = "_ability_ash_strike"
	phase1.add_ability(ash_strike)
	
	var cinder_rain := BossAbility.create(
		"Cinder Rain", 280, 8.0, 250.0,
		BossAbility.AreaType.CIRCLE, Vector2(180, 180), 2.0
	)
	cinder_rain.priority = 7
	cinder_rain.callback_name = "_ability_cinder_rain"
	phase1.add_ability(cinder_rain)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Infernal Wrath (85% - 70%)
	var phase2 := BossPhase.create(1, "Infernal Wrath", 0.85)
	phase2.set_modifiers({"damage_mult": 1.15, "attack_speed_mult": 1.1})
	
	var flame_pillar := BossAbility.create(
		"Flame Pillar", 300, 6.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(48, 48), 1.5
	)
	flame_pillar.priority = 7
	flame_pillar.callback_name = "_ability_flame_pillar"
	phase2.add_ability(flame_pillar)
	
	var ash_strike2 := BossAbility.create(
		"Ash Strike", 340, 3.0, 96.0,
		BossAbility.AreaType.CONE, Vector2(90, 96), 0.7
	)
	ash_strike2.priority = 5
	ash_strike2.callback_name = "_ability_ash_strike"
	phase2.add_ability(ash_strike2)
	
	var lava_eruption := BossAbility.create(
		"Lava Eruption", 350, 10.0, 120.0,
		BossAbility.AreaType.CIRCLE, Vector2(120, 120), 2.0
	)
	lava_eruption.priority = 8
	lava_eruption.callback_name = "_ability_lava_eruption"
	phase2.add_ability(lava_eruption)
	
	boss_data.phases.append(phase2)
	
	# Phase 3: Ash Storm (70% - 55%)
	var phase3 := BossPhase.create(2, "Ash Storm", 0.70)
	phase3.set_modifiers({"damage_mult": 1.3, "speed_mult": 1.2})
	phase3.aura_damage = 20.0
	phase3.aura_range = 64.0
	
	var ash_storm := BossAbility.create(
		"Ash Storm", 250, 12.0, 280.0,
		BossAbility.AreaType.CIRCLE, Vector2(250, 250), 2.5
	)
	ash_storm.priority = 9
	ash_storm.callback_name = "_ability_ash_storm"
	phase3.add_ability(ash_storm)
	
	var flame_pillar2 := BossAbility.create(
		"Flame Pillar", 320, 5.0, 220.0,
		BossAbility.AreaType.CIRCLE, Vector2(56, 56), 1.2
	)
	flame_pillar2.priority = 7
	flame_pillar2.callback_name = "_ability_flame_pillar"
	phase3.add_ability(flame_pillar2)
	
	var summon_elementals := BossAbility.create(
		"Summon Elementals", 0, 20.0, 300.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	summon_elementals.priority = 8
	summon_elementals.summon_count = 3
	summon_elementals.summon_data = {
		"name": "Ash Elemental", "id": "ash_elemental", "hp": 5000,
		"damage": 100, "speed": 50.0, "attack_range": 64.0,
		"xp": 200, "color": Color(0.6, 0.3, 0.1),
		"category": Enums.EnemyType.CASTER,
	}
	summon_elementals.callback_name = "_ability_summon_elementals"
	phase3.add_ability(summon_elementals)
	
	boss_data.phases.append(phase3)
	
	# Phase 4: Molten Core (55% - 35%)
	var phase4 := BossPhase.create(3, "Molten Core", 0.55)
	phase4.set_modifiers({"damage_mult": 1.5, "attack_speed_mult": 1.3})
	phase4.aura_damage = 35.0
	phase4.aura_range = 80.0
	
	var molten_wave := BossAbility.create(
		"Molten Wave", 380, 7.0, 200.0,
		BossAbility.AreaType.RECT, Vector2(80, 200), 1.5
	)
	molten_wave.priority = 8
	molten_wave.status_effect = Enums.EffectType.BURN_DOT
	molten_wave.status_duration = 6.0
	molten_wave.callback_name = "_ability_molten_wave"
	phase4.add_ability(molten_wave)
	
	var lava_eruption2 := BossAbility.create(
		"Mega Eruption", 400, 8.0, 140.0,
		BossAbility.AreaType.CIRCLE, Vector2(140, 140), 2.0
	)
	lava_eruption2.priority = 9
	lava_eruption2.callback_name = "_ability_lava_eruption"
	phase4.add_ability(lava_eruption2)
	
	var flame_pillar3 := BossAbility.create(
		"Flame Pillar", 340, 4.0, 240.0,
		BossAbility.AreaType.CIRCLE, Vector2(64, 64), 1.0
	)
	flame_pillar3.priority = 6
	flame_pillar3.callback_name = "_ability_flame_pillar"
	phase4.add_ability(flame_pillar3)
	
	boss_data.phases.append(phase4)
	
	# Phase 5: Godflame (35% - 15%)
	var phase5 := BossPhase.create(4, "Godflame", 0.35)
	phase5.set_modifiers({"damage_mult": 1.8, "attack_speed_mult": 1.5, "speed_mult": 1.3})
	phase5.aura_damage = 50.0
	phase5.aura_range = 96.0
	
	var divine_flame := BossAbility.create(
		"Divine Flame", 420, 5.0, 160.0,
		BossAbility.AreaType.CONE, Vector2(120, 160), 1.5
	)
	divine_flame.priority = 9
	divine_flame.status_effect = Enums.EffectType.BURN_DOT
	divine_flame.status_duration = 8.0
	divine_flame.callback_name = "_ability_divine_flame"
	phase5.add_ability(divine_flame)
	
	var ash_storm2 := BossAbility.create(
		"Ash Apocalypse", 300, 10.0, 300.0,
		BossAbility.AreaType.CIRCLE, Vector2(300, 300), 2.0
	)
	ash_storm2.priority = 10
	ash_storm2.callback_name = "_ability_ash_storm"
	phase5.add_ability(ash_storm2)
	
	var molten_wave2 := BossAbility.create(
		"Molten Tsunami", 400, 6.0, 220.0,
		BossAbility.AreaType.RECT, Vector2(100, 220), 1.2
	)
	molten_wave2.priority = 8
	molten_wave2.status_effect = Enums.EffectType.BURN_DOT
	molten_wave2.status_duration = 8.0
	molten_wave2.callback_name = "_ability_molten_wave"
	phase5.add_ability(molten_wave2)
	
	boss_data.phases.append(phase5)
	
	# Phase 6: Final Judgment (15% - 0%)
	var phase6 := BossPhase.create(5, "Final Judgment", 0.15)
	phase6.set_modifiers({"damage_mult": 2.5, "attack_speed_mult": 2.0, "speed_mult": 1.5})
	phase6.aura_damage = 80.0
	phase6.aura_range = 128.0
	
	var judgment := BossAbility.create(
		"Final Judgment", 500, 15.0, 300.0,
		BossAbility.AreaType.CIRCLE, Vector2(250, 250), 3.0
	)
	judgment.priority = 10
	judgment.callback_name = "_ability_final_judgment"
	phase6.add_ability(judgment)
	
	var divine_flame2 := BossAbility.create(
		"Divine Flame", 450, 4.0, 180.0,
		BossAbility.AreaType.CONE, Vector2(140, 180), 1.2
	)
	divine_flame2.priority = 8
	divine_flame2.status_effect = Enums.EffectType.BURN_DOT
	divine_flame2.status_duration = 10.0
	divine_flame2.callback_name = "_ability_divine_flame"
	phase6.add_ability(divine_flame2)
	
	boss_data.phases.append(phase6)


# === Ability implementációk ===

func _ability_ash_strike(ability: BossAbility) -> void:
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
	
	_spawn_effect_circle(global_position + dir * length * 0.5, length * 0.5, Color(0.6, 0.3, 0.1, 0.5), 0.4)


func _ability_cinder_rain(ability: BossAbility) -> void:
	var center := _current_target.global_position if _current_target and is_instance_valid(_current_target) else global_position
	var radius := ability.area_size.x / 2.0
	var count := 15
	
	for i in count:
		var delay := randf() * 3.0
		var pos := center + Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
		var timer := get_tree().create_timer(delay)
		timer.timeout.connect(func():
			_spawn_effect_circle(pos, 16.0, Color(1.0, 0.4, 0.0, 0.3), 0.3)
			var dmg_timer := get_tree().create_timer(0.4)
			dmg_timer.timeout.connect(func():
				for player in get_tree().get_nodes_in_group("player"):
					if player.global_position.distance_to(pos) <= 20.0:
						_deal_damage_to(player, ability.damage)
				_spawn_effect_circle(pos, 20.0, Color(1.0, 0.2, 0.0, 0.6), 0.3)
			)
		)


func _ability_flame_pillar(ability: BossAbility) -> void:
	# Lángooszlop minden player alatt
	for player in get_tree().get_nodes_in_group("player"):
		var pos := player.global_position
		var radius := ability.area_size.x / 2.0
		
		# Telegraph
		_spawn_effect_circle(pos, radius, Color(1.0, 0.5, 0.0, 0.3), 1.0)
		
		# Delayed damage
		var timer := get_tree().create_timer(1.0)
		timer.timeout.connect(func():
			for p in get_tree().get_nodes_in_group("player"):
				if p.global_position.distance_to(pos) <= radius:
					_deal_damage_to(p, ability.damage)
			_spawn_effect_circle(pos, radius * 1.3, Color(1.0, 0.3, 0.0, 0.7), 0.5)
		)


func _ability_lava_eruption(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	_spawn_effect_circle(global_position, radius, Color(0.8, 0.2, 0.0, 0.3), 1.5)
	
	var timer := get_tree().create_timer(1.5)
	timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(global_position) <= radius:
				_deal_damage_to(player, ability.damage)
				_apply_status_to(player, Enums.EffectType.STUN, 1.5)
				if player.has_method("apply_knockback"):
					player.apply_knockback(global_position.direction_to(player.global_position) * 300.0)
		_spawn_effect_circle(global_position, radius * 1.5, Color(1.0, 0.3, 0.0, 0.8), 0.6)
	)


func _ability_ash_storm(ability: BossAbility) -> void:
	var center := global_position
	var radius := ability.area_size.x / 2.0
	var duration := 5.0
	var tick_rate := 0.5
	
	_spawn_storm_zone(center, radius, ability.damage, duration, tick_rate)


func _ability_summon_elementals(ability: BossAbility) -> void:
	var current_count := get_active_summon_count()
	if current_count >= 6:
		return
	var to_spawn := mini(ability.summon_count, 6 - current_count)
	for i in to_spawn:
		_spawn_summon(ability.summon_data, i)


func _ability_molten_wave(ability: BossAbility) -> void:
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
	
	var effect := Sprite2D.new()
	var img := Image.create(int(width), int(length), false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 0.3, 0.0, 0.4))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = global_position + dir * length / 2.0
	effect.rotation = dir.angle() + PI / 2.0
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 1.0)
	tween.tween_callback(effect.queue_free)


func _ability_divine_flame(ability: BossAbility) -> void:
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
			_apply_status_to(player, Enums.EffectType.BURN_DOT, ability.status_duration)
	
	_spawn_effect_circle(global_position + dir * length * 0.5, length * 0.5, Color(1.0, 0.8, 0.2, 0.6), 0.8)


func _ability_final_judgment(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	# 3 mp charge
	is_invulnerable = true
	_spawn_effect_circle(global_position, radius, Color(1.0, 0.5, 0.0, 0.2), 3.0)
	
	# Screen shake jelzés
	sprite.modulate = Color(2.0, 1.0, 0.5)
	
	var charge_timer := get_tree().create_timer(3.0)
	charge_timer.timeout.connect(func():
		is_invulnerable = false
		sprite.modulate = Color.WHITE
		
		for player in get_tree().get_nodes_in_group("player"):
			var dist := player.global_position.distance_to(global_position)
			if dist <= radius:
				var falloff := 1.0 - (dist / radius) * 0.3
				_deal_damage_to(player, ability.damage * falloff)
				_apply_status_to(player, Enums.EffectType.STUN, 2.0)
				_apply_status_to(player, Enums.EffectType.BURN_DOT, 10.0)
		
		_spawn_effect_circle(global_position, radius * 1.5, Color(1.0, 0.4, 0.0, 0.9), 1.0)
	)


# === Segéd metódusok ===

func _spawn_effect_circle(center: Vector2, radius: float, color: Color, duration: float) -> void:
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


func _spawn_storm_zone(center: Vector2, radius: float, damage_per_tick: float, duration: float, tick_rate: float) -> void:
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
	effect.set("color", Color(0.5, 0.3, 0.1, 0.25))
	
	get_parent().add_child(effect)
	
	var tick := Timer.new()
	tick.wait_time = tick_rate
	tick.autostart = true
	tick.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(center) <= radius:
				_deal_damage_to(player, damage_per_tick * 0.2)
	)
	effect.add_child(tick)
	
	var life := Timer.new()
	life.wait_time = duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(effect.queue_free)
	effect.add_child(life)

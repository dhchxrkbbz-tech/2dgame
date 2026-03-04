## Riftlord - Tier 3 World Boss: Void Rift
## Dimenzió-kontroll boss. Portal Mechanics, Phase Shift, Rift Storm.
## Level: 50, HP: 100,000, DMG: 170-230, 3 phases, 4-player recommended
class_name Riftlord
extends BossBase


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Riftlord"
	boss_data.boss_id = "riftlord"
	boss_data.tier = 3
	boss_data.base_hp = 100000
	boss_data.armor = 45
	boss_data.damage = 200
	boss_data.speed = 55.0
	boss_data.attack_speed = 1.1
	boss_data.recommended_level_min = 50
	boss_data.recommended_level_max = 50
	boss_data.required_players = 4
	boss_data.enrage_time = Constants.BOSS_ENRAGE_TIMERS.get(3, 600.0)
	boss_data.sprite_size = Vector2(56, 64)
	boss_data.collision_size = Vector2(40, 48)
	boss_data.biome = Enums.BiomeType.VOID_RIFT
	boss_data.sprite_color = Color(0.15, 0.05, 0.35)
	boss_data.loot_table = BossLoot.create_loot_table_tier3("riftlord")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Rift Warden (100% - 65%)
	var phase1 := BossPhase.create(0, "Rift Warden", 1.0)
	
	var rift_blast := BossAbility.create(
		"Rift Blast", 180, 3.5, 180.0,
		BossAbility.AreaType.CIRCLE, Vector2(56, 56), 1.0
	)
	rift_blast.priority = 5
	rift_blast.callback_name = "_ability_rift_blast"
	phase1.add_ability(rift_blast)
	
	var dimensional_slash := BossAbility.create(
		"Dimensional Slash", 200, 4.0, 96.0,
		BossAbility.AreaType.LINE, Vector2(96, 32), 0.8
	)
	dimensional_slash.priority = 6
	dimensional_slash.callback_name = "_ability_dimensional_slash"
	phase1.add_ability(dimensional_slash)
	
	var portal_summon := BossAbility.create(
		"Portal Summon", 0, 15.0, 300.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	portal_summon.priority = 7
	portal_summon.summon_count = 3
	portal_summon.summon_data = {
		"name": "Void Spawn", "id": "void_spawn", "hp": 2000,
		"damage": 60, "speed": 65.0, "attack_range": 48.0,
		"xp": 80, "color": Color(0.2, 0.05, 0.4),
		"category": Enums.EnemyType.MELEE,
	}
	portal_summon.callback_name = "_ability_portal_summon"
	phase1.add_ability(portal_summon)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Phase Shift (65% - 30%)
	var phase2 := BossPhase.create(1, "Phase Shift", 0.65)
	phase2.set_modifiers({"damage_mult": 1.3, "speed_mult": 1.2})
	
	var rift_storm := BossAbility.create(
		"Rift Storm", 170, 8.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(160, 160), 2.0
	)
	rift_storm.priority = 8
	rift_storm.callback_name = "_ability_rift_storm"
	phase2.add_ability(rift_storm)
	
	var phase_shift := BossAbility.create(
		"Phase Shift", 230, 6.0, 200.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.5
	)
	phase_shift.priority = 7
	phase_shift.callback_name = "_ability_phase_shift"
	phase2.add_ability(phase_shift)
	
	var rift_blast2 := BossAbility.create(
		"Rift Blast", 200, 3.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(64, 64), 0.8
	)
	rift_blast2.priority = 5
	rift_blast2.callback_name = "_ability_rift_blast"
	phase2.add_ability(rift_blast2)
	
	var dimensional_slash2 := BossAbility.create(
		"Dimensional Slash", 220, 3.5, 112.0,
		BossAbility.AreaType.LINE, Vector2(112, 40), 0.6
	)
	dimensional_slash2.priority = 6
	dimensional_slash2.callback_name = "_ability_dimensional_slash"
	phase2.add_ability(dimensional_slash2)
	
	boss_data.phases.append(phase2)
	
	# Phase 3: Rift Collapse (30% - 0%)
	var phase3 := BossPhase.create(2, "Rift Collapse", 0.30)
	phase3.set_modifiers({"damage_mult": 1.7, "attack_speed_mult": 1.5, "speed_mult": 1.4})
	phase3.aura_damage = 25.0
	phase3.aura_range = 72.0
	
	var collapse := BossAbility.create(
		"Dimensional Collapse", 280, 12.0, 250.0,
		BossAbility.AreaType.CIRCLE, Vector2(200, 200), 2.5
	)
	collapse.priority = 10
	collapse.callback_name = "_ability_dimensional_collapse"
	phase3.add_ability(collapse)
	
	var rift_storm2 := BossAbility.create(
		"Rift Storm", 190, 6.0, 220.0,
		BossAbility.AreaType.CIRCLE, Vector2(180, 180), 1.5
	)
	rift_storm2.priority = 8
	rift_storm2.callback_name = "_ability_rift_storm"
	phase3.add_ability(rift_storm2)
	
	var phase_shift2 := BossAbility.create(
		"Phase Shift", 250, 5.0, 220.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.3
	)
	phase_shift2.priority = 7
	phase_shift2.callback_name = "_ability_phase_shift"
	phase3.add_ability(phase_shift2)
	
	boss_data.phases.append(phase3)


# === Ability implementációk ===

func _ability_rift_blast(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var target_pos := _current_target.global_position
	var radius := ability.area_size.x / 2.0
	
	for player in get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(target_pos) <= radius:
			_deal_damage_to(player, ability.damage)
	
	_spawn_rift_effect(target_pos, radius, Color(0.2, 0.0, 0.5, 0.5), 0.5)


func _ability_dimensional_slash(ability: BossAbility) -> void:
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
	
	# Slash vizuális
	var effect := Sprite2D.new()
	var img := Image.create(int(width * 2), int(length), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.0, 0.6, 0.5))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = global_position + dir * length / 2.0
	effect.rotation = dir.angle() + PI / 2.0
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 0.4)
	tween.tween_callback(effect.queue_free)


func _ability_portal_summon(ability: BossAbility) -> void:
	var current_count := get_active_summon_count()
	if current_count >= 6:
		return
	
	var to_spawn := mini(ability.summon_count, 6 - current_count)
	for i in to_spawn:
		_spawn_summon(ability.summon_data, i)


func _ability_rift_storm(ability: BossAbility) -> void:
	var center := global_position
	var radius := ability.area_size.x / 2.0
	var count := 10
	
	for i in count:
		var delay := randf() * 2.5
		var pos := center + Vector2(randf_range(-radius, radius), randf_range(-radius, radius))
		var timer := get_tree().create_timer(delay)
		timer.timeout.connect(func():
			_spawn_rift_effect(pos, 20.0, Color(0.3, 0.0, 0.6, 0.3), 0.3)
			var dmg_timer := get_tree().create_timer(0.3)
			dmg_timer.timeout.connect(func():
				for player in get_tree().get_nodes_in_group("player"):
					if player.global_position.distance_to(pos) <= 24.0:
						_deal_damage_to(player, ability.damage)
			)
		)


func _ability_phase_shift(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	# Teleport véletlenszerű pozícióba a target közelében
	var angle := randf() * TAU
	var dist := randf_range(64, 128)
	var new_pos := _current_target.global_position + Vector2(cos(angle), sin(angle)) * dist
	
	# Eltűnés → megjelenés
	is_invulnerable = true
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func():
		global_position = new_pos
		is_invulnerable = false
	)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.15)
	
	# Megérkezési robbanás
	tween.tween_callback(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(new_pos) <= 40:
				_deal_damage_to(player, ability.damage)
		_spawn_rift_effect(new_pos, 40.0, Color(0.3, 0.0, 0.6, 0.6), 0.4)
	)


func _ability_dimensional_collapse(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	# Gravitáció felé húzza a játékosokat
	var pull_duration := 2.0
	var pull_timer := 0.0
	
	_spawn_rift_effect(global_position, radius, Color(0.2, 0.0, 0.4, 0.3), pull_duration)
	
	# Pull egyszerűsítés: 4 tick húzás
	for i in 4:
		var timer := get_tree().create_timer(0.5 * i)
		timer.timeout.connect(func():
			for player in get_tree().get_nodes_in_group("player"):
				var dist_to_boss := player.global_position.distance_to(global_position)
				if dist_to_boss <= radius and dist_to_boss > 16:
					var pull_dir := player.global_position.direction_to(global_position)
					var pull_force := pull_dir * 80.0
					if player.has_method("apply_knockback"):
						player.apply_knockback(pull_force)
		)
	
	# Final explosion
	var explosion_timer := get_tree().create_timer(pull_duration)
	explosion_timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			var dist := player.global_position.distance_to(global_position)
			if dist <= radius:
				var falloff := 1.0 - (dist / radius) * 0.4
				_deal_damage_to(player, ability.damage * falloff)
				_apply_status_to(player, Enums.EffectType.STUN, 2.0)
		_spawn_rift_effect(global_position, radius * 1.5, Color(0.4, 0.0, 0.7, 0.7), 0.6)
	)


# === Segéd metódusok ===

func _spawn_rift_effect(center: Vector2, radius: float, color: Color, duration: float) -> void:
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

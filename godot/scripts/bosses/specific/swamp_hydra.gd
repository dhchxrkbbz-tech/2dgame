## SwampHydra - Tier 1 Boss: Dark Swamp
## Multi-head boss. Acid Spit, Tail Sweep, Head Regeneration.
## Level: 26-30, HP: 15,000, DMG: 70-95, 3 phases
class_name SwampHydra
extends BossBase

var active_heads: int = 3
var max_heads: int = 5


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Swamp Hydra"
	boss_data.boss_id = "swamp_hydra"
	boss_data.tier = 1
	boss_data.base_hp = 15000
	boss_data.armor = 18
	boss_data.damage = 80
	boss_data.speed = 35.0
	boss_data.attack_speed = 1.2
	boss_data.recommended_level_min = 26
	boss_data.recommended_level_max = 30
	boss_data.required_players = 1
	boss_data.enrage_time = Constants.BOSS_ENRAGE_TIMERS.get(1, 300.0)
	boss_data.sprite_size = Vector2(64, 64)
	boss_data.collision_size = Vector2(48, 48)
	boss_data.biome = Enums.BiomeType.DARK_SWAMP
	boss_data.sprite_color = Color(0.25, 0.5, 0.2)
	boss_data.loot_table = BossLoot.create_loot_table_tier1("swamp_hydra")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Three Heads (100% - 65%)
	var phase1 := BossPhase.create(0, "Three Heads", 1.0)
	
	var acid_spit := BossAbility.create(
		"Acid Spit", 75, 4.0, 192.0,
		BossAbility.AreaType.CIRCLE, Vector2(40, 40), 0.8
	)
	acid_spit.priority = 5
	acid_spit.projectile_count = 3
	acid_spit.status_effect = Enums.EffectType.POISON_DOT
	acid_spit.status_duration = 4.0
	acid_spit.callback_name = "_ability_acid_spit"
	phase1.add_ability(acid_spit)
	
	var tail_sweep := BossAbility.create(
		"Tail Sweep", 85, 6.0, 80.0,
		BossAbility.AreaType.CIRCLE, Vector2(80, 80), 1.0
	)
	tail_sweep.priority = 6
	tail_sweep.callback_name = "_ability_tail_sweep"
	phase1.add_ability(tail_sweep)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Growing Fury (65% - 30%)
	var phase2 := BossPhase.create(1, "Growing Fury", 0.65)
	phase2.set_modifiers({"attack_speed_mult": 1.3})
	
	var acid_spit2 := BossAbility.create(
		"Acid Barrage", 70, 3.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(48, 48), 0.6
	)
	acid_spit2.priority = 5
	acid_spit2.projectile_count = 4
	acid_spit2.status_effect = Enums.EffectType.POISON_DOT
	acid_spit2.status_duration = 5.0
	acid_spit2.callback_name = "_ability_acid_spit"
	phase2.add_ability(acid_spit2)
	
	var tail_sweep2 := BossAbility.create(
		"Tail Sweep", 90, 5.0, 80.0,
		BossAbility.AreaType.CIRCLE, Vector2(96, 96), 0.8
	)
	tail_sweep2.priority = 6
	tail_sweep2.callback_name = "_ability_tail_sweep"
	phase2.add_ability(tail_sweep2)
	
	var poison_pool := BossAbility.create(
		"Poison Pool", 30, 10.0, 160.0,
		BossAbility.AreaType.CIRCLE, Vector2(64, 64), 1.2
	)
	poison_pool.priority = 7
	poison_pool.callback_name = "_ability_poison_pool"
	phase2.add_ability(poison_pool)
	
	boss_data.phases.append(phase2)
	
	# Phase 3: Hydra Unleashed (30% - 0%)
	var phase3 := BossPhase.create(2, "Hydra Unleashed", 0.30)
	phase3.set_modifiers({"damage_mult": 1.4, "attack_speed_mult": 1.5})
	
	var acid_storm := BossAbility.create(
		"Acid Storm", 65, 2.5, 220.0,
		BossAbility.AreaType.CIRCLE, Vector2(56, 56), 0.5
	)
	acid_storm.priority = 5
	acid_storm.projectile_count = 5
	acid_storm.status_effect = Enums.EffectType.POISON_DOT
	acid_storm.status_duration = 5.0
	acid_storm.callback_name = "_ability_acid_spit"
	phase3.add_ability(acid_storm)
	
	var tail_sweep3 := BossAbility.create(
		"Tail Sweep", 95, 4.0, 96.0,
		BossAbility.AreaType.CIRCLE, Vector2(112, 112), 0.6
	)
	tail_sweep3.priority = 6
	tail_sweep3.callback_name = "_ability_tail_sweep"
	phase3.add_ability(tail_sweep3)
	
	var devour := BossAbility.create(
		"Devour", 120, 12.0, 48.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 1.5
	)
	devour.priority = 9
	devour.callback_name = "_ability_devour"
	phase3.add_ability(devour)
	
	var poison_pool2 := BossAbility.create(
		"Poison Pool", 35, 8.0, 160.0,
		BossAbility.AreaType.CIRCLE, Vector2(80, 80), 1.0
	)
	poison_pool2.priority = 7
	poison_pool2.callback_name = "_ability_poison_pool"
	phase3.add_ability(poison_pool2)
	
	boss_data.phases.append(phase3)


# === Ability implementációk ===

func _ability_acid_spit(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var base_dir := global_position.direction_to(_current_target.global_position)
	var count := ability.projectile_count
	var spread := deg_to_rad(15.0)
	
	for i in count:
		var angle_offset := (float(i) - float(count - 1) / 2.0) * spread
		var dir := base_dir.rotated(angle_offset)
		
		var proj := Projectile.new()
		proj.setup(
			ability.damage * damage_multiplier,
			180.0,
			dir,
			"boss",
			Enums.DamageType.POISON,
		)
		proj.global_position = global_position + dir * 24
		get_parent().add_child(proj)


func _ability_tail_sweep(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	for player in get_tree().get_nodes_in_group("player"):
		var dist := player.global_position.distance_to(global_position)
		if dist <= radius:
			_deal_damage_to(player, ability.damage)
			# Knockback
			if player.has_method("apply_knockback"):
				var kb_dir := global_position.direction_to(player.global_position)
				player.apply_knockback(kb_dir * 200.0)
	
	# Visual sweep
	_spawn_sweep_effect(global_position, radius, Color(0.3, 0.5, 0.2, 0.4))


func _ability_poison_pool(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var target_pos := _current_target.global_position
	var radius := ability.area_size.x / 2.0
	var duration := 6.0
	
	_spawn_poison_pool(target_pos, radius, ability.damage, duration)


func _ability_devour(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dist := global_position.distance_to(_current_target.global_position)
	if dist > ability.range:
		return
	
	_deal_damage_to(_current_target, ability.damage)
	
	# Self heal (15% of damage)
	var heal_amount := int(ability.damage * 0.15)
	heal(heal_amount)
	
	# Visual: nagy harapás effekt
	var effect := Sprite2D.new()
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.4, 0.7, 0.1, 0.8))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = _current_target.global_position
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_callback(effect.queue_free)


# === Segéd metódusok ===

func _spawn_sweep_effect(center: Vector2, radius: float, color: Color) -> void:
	var effect := Node2D.new()
	effect.global_position = center
	
	var script_text := """
extends Node2D
var radius: float
var color: Color
func _draw():
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, color, 3.0)
"""
	var script := GDScript.new()
	script.source_code = script_text
	script.reload()
	effect.set_script(script)
	effect.set("radius", radius)
	effect.set("color", color)
	
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(effect.queue_free)


func _spawn_poison_pool(center: Vector2, radius: float, damage_per_tick: float, duration: float) -> void:
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
	effect.set("color", Color(0.2, 0.6, 0.1, 0.3))
	
	get_parent().add_child(effect)
	
	var tick := Timer.new()
	tick.wait_time = 1.0
	tick.autostart = true
	tick.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(center) <= radius:
				_deal_damage_to(player, damage_per_tick)
				_apply_status_to(player, Enums.EffectType.POISON_DOT, 2.0)
	)
	effect.add_child(tick)
	
	var life := Timer.new()
	life.wait_time = duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(effect.queue_free)
	effect.add_child(life)

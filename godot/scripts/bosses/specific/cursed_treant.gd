## CursedTreant - Mini Boss 1: Cursed Forest
## Lassú, erős fa szörny. Root Slam, Leaf Storm, Vine Grab.
class_name CursedTreant
extends BossBase


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Cursed Treant"
	boss_data.boss_id = "cursed_treant"
	boss_data.tier = 1
	boss_data.base_hp = 800
	boss_data.armor = 10
	boss_data.damage = 25
	boss_data.speed = 40.0
	boss_data.attack_speed = 0.8
	boss_data.recommended_level_min = 5
	boss_data.recommended_level_max = 8
	boss_data.required_players = 1
	boss_data.sprite_size = Vector2(48, 48)
	boss_data.collision_size = Vector2(36, 36)
	boss_data.biome = Enums.BiomeType.CURSED_FOREST
	boss_data.sprite_color = Color(0.35, 0.5, 0.2)
	boss_data.loot_table = BossLoot.create_loot_table_tier1("cursed_treant")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Root Guardian (100%-50%)
	var phase1 := BossPhase.create(0, "Root Guardian", 1.0)
	
	var root_slam := BossAbility.create(
		"Root Slam", 35, 5.0, 128.0,
		BossAbility.AreaType.LINE, Vector2(96, 32), 1.0
	)
	root_slam.priority = 5
	root_slam.callback_name = "_ability_root_slam"
	phase1.add_ability(root_slam)
	
	var leaf_storm := BossAbility.create(
		"Leaf Storm", 15, 8.0, 64.0,
		BossAbility.AreaType.CIRCLE, Vector2(64, 64), 0.5
	)
	leaf_storm.priority = 3
	leaf_storm.callback_name = "_ability_leaf_storm"
	phase1.add_ability(leaf_storm)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Unleashed (50%-0%)
	var phase2 := BossPhase.create(1, "Unleashed", 0.5)
	phase2.set_modifiers({"attack_speed_mult": 1.2})
	
	# Korábbi ability-k + erősebb Leaf Storm
	var root_slam2 := BossAbility.create(
		"Root Slam", 35, 5.0, 128.0,
		BossAbility.AreaType.LINE, Vector2(96, 32), 1.0
	)
	root_slam2.priority = 5
	root_slam2.callback_name = "_ability_root_slam"
	phase2.add_ability(root_slam2)
	
	var leaf_storm2 := BossAbility.create(
		"Leaf Storm", 15, 8.0, 96.0,  # Nagyobb sugár
		BossAbility.AreaType.CIRCLE, Vector2(96, 96), 0.5
	)
	leaf_storm2.priority = 3
	leaf_storm2.callback_name = "_ability_leaf_storm"
	phase2.add_ability(leaf_storm2)
	
	var vine_grab := BossAbility.create(
		"Vine Grab", 20, 6.0, 160.0,
		BossAbility.AreaType.LINE, Vector2(160, 24), 0.8
	)
	vine_grab.priority = 7
	vine_grab.status_effect = Enums.EffectType.ROOT
	vine_grab.status_duration = 2.0
	vine_grab.callback_name = "_ability_vine_grab"
	phase2.add_ability(vine_grab)
	
	boss_data.phases.append(phase2)


# === Custom ability implementációk ===

func _ability_root_slam(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	
	# 3 pozíció a vonalon
	for i in 3:
		var pos := global_position + dir * (32 + i * 32)
		# Damage check
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(pos) <= 20:
				_deal_damage_to(player, ability.damage)
	
	# Visual feedback: ground shake
	_spawn_ground_effect(global_position + dir * 48, Vector2(96, 32), Color(0.4, 0.6, 0.2, 0.5), 0.5)


func _ability_leaf_storm(ability: BossAbility) -> void:
	# 3 másodpercig tartó AoE a boss körül
	var radius := ability.area_size.x
	var duration := 3.0
	var tick_rate := 0.5
	
	_spawn_aoe_dot(global_position, radius, ability.damage, duration, tick_rate, Color(0.3, 0.7, 0.1, 0.3))


func _ability_vine_grab(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var dist := global_position.distance_to(_current_target.global_position)
	
	if dist <= ability.range:
		_deal_damage_to(_current_target, ability.damage)
		_apply_status_to(_current_target, Enums.EffectType.ROOT, 2.0)
		# Visual
		_spawn_ground_effect(_current_target.global_position, Vector2(24, 24), Color(0.2, 0.5, 0.1, 0.6), 2.0)


# === Segéd függvények ===

func _spawn_ground_effect(pos: Vector2, size: Vector2, color: Color, duration: float) -> void:
	var effect := Node2D.new()
	effect.global_position = pos
	effect.z_index = -1
	
	var sprite_node := Sprite2D.new()
	var img := Image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)
	img.fill(color)
	sprite_node.texture = ImageTexture.create_from_image(img)
	effect.add_child(sprite_node)
	
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(sprite_node, "modulate:a", 0.0, duration)
	tween.tween_callback(effect.queue_free)


func _spawn_aoe_dot(center: Vector2, radius: float, damage_per_tick: float, duration: float, tick_rate: float, color: Color) -> void:
	var timer := 0.0
	var dot_timer := 0.0
	var effect := Node2D.new()
	effect.global_position = center
	
	# Visual circle
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
	
	# Use a timer node for DOT ticks
	var tick_node := Timer.new()
	tick_node.wait_time = tick_rate
	tick_node.autostart = true
	tick_node.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(center) <= radius:
				_deal_damage_to(player, damage_per_tick)
	)
	effect.add_child(tick_node)
	
	# Remove after duration
	var life_timer := Timer.new()
	life_timer.wait_time = duration
	life_timer.one_shot = true
	life_timer.autostart = true
	life_timer.timeout.connect(effect.queue_free)
	effect.add_child(life_timer)

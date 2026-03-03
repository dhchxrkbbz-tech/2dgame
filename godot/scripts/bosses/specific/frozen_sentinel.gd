## FrozenSentinel - Mini Boss 3: Mountains / Frozen Wastes
## Lassú, masszív védelem. Ice Slam, Frost Breath, Ice Spike Rain.
class_name FrozenSentinel
extends BossBase


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Frozen Sentinel"
	boss_data.boss_id = "frozen_sentinel"
	boss_data.tier = 1
	boss_data.base_hp = 1200
	boss_data.armor = 20
	boss_data.damage = 30
	boss_data.speed = 30.0
	boss_data.attack_speed = 0.7
	boss_data.recommended_level_min = 8
	boss_data.recommended_level_max = 12
	boss_data.required_players = 1
	boss_data.sprite_size = Vector2(56, 56)
	boss_data.collision_size = Vector2(40, 40)
	boss_data.biome = Enums.BiomeType.FROZEN_WASTES
	boss_data.sprite_color = Color(0.5, 0.7, 0.9)
	boss_data.loot_table = BossLoot.create_loot_table_tier1("frozen_sentinel")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Ice Fortress (100%-50%)
	var phase1 := BossPhase.create(0, "Ice Fortress", 1.0)
	
	var ice_slam := BossAbility.create(
		"Ice Slam", 40, 6.0, 64.0,
		BossAbility.AreaType.CIRCLE, Vector2(96, 96), 1.2
	)
	ice_slam.priority = 6
	ice_slam.callback_name = "_ability_ice_slam"
	phase1.add_ability(ice_slam)
	
	var frost_breath := BossAbility.create(
		"Frost Breath", 25, 8.0, 128.0,
		BossAbility.AreaType.CONE, Vector2(60, 128), 1.0
	)
	frost_breath.priority = 5
	frost_breath.status_effect = Enums.EffectType.SLOW
	frost_breath.status_duration = 3.0
	frost_breath.callback_name = "_ability_frost_breath"
	phase1.add_ability(frost_breath)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Crumbling (50%-0%)
	var phase2 := BossPhase.create(1, "Crumbling", 0.5)
	phase2.set_modifiers({"damage_mult": 1.4, "armor_change": -10})
	
	var ice_slam2 := BossAbility.create("Ice Slam", 56, 5.0, 64.0, BossAbility.AreaType.CIRCLE, Vector2(96, 96), 1.0)
	ice_slam2.priority = 6
	ice_slam2.callback_name = "_ability_ice_slam"
	phase2.add_ability(ice_slam2)
	
	var frost_breath2 := BossAbility.create("Frost Breath", 35, 7.0, 128.0, BossAbility.AreaType.CONE, Vector2(60, 128), 0.8)
	frost_breath2.priority = 5
	frost_breath2.status_effect = Enums.EffectType.SLOW
	frost_breath2.status_duration = 3.0
	frost_breath2.callback_name = "_ability_frost_breath"
	phase2.add_ability(frost_breath2)
	
	var ice_spike_rain := BossAbility.create(
		"Ice Spike Rain", 35, 10.0, 256.0,
		BossAbility.AreaType.CIRCLE, Vector2(64, 64), 1.5
	)
	ice_spike_rain.priority = 8
	ice_spike_rain.callback_name = "_ability_ice_spike_rain"
	phase2.add_ability(ice_spike_rain)
	
	boss_data.phases.append(phase2)


# === Custom ability implementációk ===

func _ability_ice_slam(ability: BossAbility) -> void:
	# 3×3 AoE a boss körül
	var radius := 48.0
	for player in get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(global_position) <= radius:
			_deal_damage_to(player, ability.damage)
	
	# Vizuál
	_spawn_ice_effect(global_position, radius, 0.5)


func _ability_frost_breath(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var cone_angle := deg_to_rad(60)
	var cone_length := 128.0
	
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var dist := to_player.length()
		if dist > cone_length:
			continue
		var angle_diff := abs(to_player.angle_to(dir))
		if angle_diff <= cone_angle / 2.0:
			_deal_damage_to(player, ability.damage)
			_apply_status_to(player, Enums.EffectType.SLOW, 3.0)
	
	telegraph.show_cone(global_position, dir, 60, cone_length, 0.5, Color(0.5, 0.8, 1.0, 0.4))


func _ability_ice_spike_rain(ability: BossAbility) -> void:
	# 5 random helyre jégtüske
	var positions: Array[Vector2] = []
	for i in 5:
		var pos := global_position + Vector2(randf_range(-128, 128), randf_range(-128, 128))
		positions.append(pos)
	
	# Telegraph
	telegraph.show_multi_circle(positions, 32.0, 1.5, Color(0.4, 0.7, 1.0, 0.3))
	
	# Damage 1.5s késleltetéssel
	var timer := Timer.new()
	timer.wait_time = 1.5
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(func():
		for pos in positions:
			for player in get_tree().get_nodes_in_group("player"):
				if player.global_position.distance_to(pos) <= 32:
					_deal_damage_to(player, ability.damage)
			_spawn_ice_effect(pos, 32, 0.5)
		timer.queue_free()
	)
	add_child(timer)


func _spawn_ice_effect(pos: Vector2, radius: float, duration: float) -> void:
	var effect := Sprite2D.new()
	var size := int(radius * 2)
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.5, 0.8, 1.0, 0.5))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = pos
	effect.z_index = -1
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, duration)
	tween.tween_callback(effect.queue_free)

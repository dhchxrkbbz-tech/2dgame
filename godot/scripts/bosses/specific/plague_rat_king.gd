## PlagueRatKing - Mini Boss 2: Plague Lands / Dark Swamp
## Gyors, summon-os boss. Toxic Bite, Summon Rats, Plague Wave.
class_name PlagueRatKing
extends BossBase

const MAX_RATS := 6
const MAX_RATS_P2 := 10


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Plague Rat King"
	boss_data.boss_id = "plague_rat_king"
	boss_data.tier = 1
	boss_data.base_hp = 600
	boss_data.armor = 5
	boss_data.damage = 20
	boss_data.speed = 70.0
	boss_data.attack_speed = 1.2
	boss_data.recommended_level_min = 5
	boss_data.recommended_level_max = 8
	boss_data.required_players = 1
	boss_data.sprite_size = Vector2(40, 40)
	boss_data.collision_size = Vector2(28, 28)
	boss_data.biome = Enums.BiomeType.DARK_SWAMP
	boss_data.sprite_color = Color(0.5, 0.35, 0.2)
	boss_data.loot_table = BossLoot.create_loot_table_tier1("plague_rat_king")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Swarm Master (100%-50%)
	var phase1 := BossPhase.create(0, "Swarm Master", 1.0)
	
	var summon_rats := BossAbility.create(
		"Summon Rats", 0, 10.0, 300.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	summon_rats.priority = 8
	summon_rats.summon_count = 3
	summon_rats.summon_data = {
		"name": "Plague Rat", "id": "plague_rat", "hp": 15,
		"damage": 8, "speed": 80.0, "attack_range": 24.0,
		"xp": 5, "color": Color(0.4, 0.3, 0.2),
		"category": Enums.EnemyType.SWARM,
	}
	summon_rats.callback_name = "_ability_summon_rats"
	phase1.add_ability(summon_rats)
	
	var toxic_bite := BossAbility.create(
		"Toxic Bite", 25, 4.0, 48.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	toxic_bite.priority = 6
	toxic_bite.status_effect = Enums.EffectType.POISON
	toxic_bite.status_duration = 4.0
	toxic_bite.callback_name = "_ability_toxic_bite"
	phase1.add_ability(toxic_bite)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Frenzy (50%-0%)
	var phase2 := BossPhase.create(1, "Frenzy", 0.5)
	phase2.set_modifiers({"speed_mult": 1.3})
	
	var summon_rats2 := BossAbility.create(
		"Summon Rats", 0, 10.0, 300.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	summon_rats2.priority = 8
	summon_rats2.summon_count = 5
	summon_rats2.summon_data = {
		"name": "Frenzied Rat", "id": "frenzied_rat", "hp": 20,
		"damage": 10, "speed": 90.0, "attack_range": 24.0,
		"xp": 8, "color": Color(0.5, 0.3, 0.15),
		"category": Enums.EnemyType.SWARM,
	}
	summon_rats2.callback_name = "_ability_summon_rats"
	phase2.add_ability(summon_rats2)
	
	var toxic_bite2 := BossAbility.create(
		"Toxic Bite", 25, 4.0, 48.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	toxic_bite2.priority = 6
	toxic_bite2.status_effect = Enums.EffectType.POISON
	toxic_bite2.status_duration = 4.0
	toxic_bite2.callback_name = "_ability_toxic_bite"
	phase2.add_ability(toxic_bite2)
	
	var plague_wave := BossAbility.create(
		"Plague Wave", 40, 7.0, 160.0,
		BossAbility.AreaType.RECT, Vector2(96, 160), 0.8
	)
	plague_wave.priority = 7
	plague_wave.callback_name = "_ability_plague_wave"
	phase2.add_ability(plague_wave)
	
	boss_data.phases.append(phase2)


# === Custom ability implementációk ===

func _ability_summon_rats(ability: BossAbility) -> void:
	var max_summons := MAX_RATS if current_phase_index == 0 else MAX_RATS_P2
	var current_count := get_active_summon_count()
	
	if current_count >= max_summons:
		return
	
	var to_spawn := mini(ability.summon_count, max_summons - current_count)
	for i in to_spawn:
		_spawn_summon(ability.summon_data, i)


func _ability_toxic_bite(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dist := global_position.distance_to(_current_target.global_position)
	if dist > ability.range:
		return
	
	_deal_damage_to(_current_target, ability.damage)
	_apply_status_to(_current_target, Enums.EffectType.POISON, ability.status_duration)
	
	# Visual: zöld splash
	var effect := Sprite2D.new()
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.7, 0.1, 0.7))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = _current_target.global_position
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "scale", Vector2(2, 2), 0.3)
	tween.parallel().tween_property(effect, "modulate:a", 0.0, 0.3)
	tween.tween_callback(effect.queue_free)


func _ability_plague_wave(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var wave_length := 160.0
	var wave_width := 96.0
	
	# Damage minden player-nek a téglalap területen
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var proj := to_player.dot(dir)
		if proj < 0 or proj > wave_length:
			continue
		var perp := abs(to_player.cross(dir))
		if perp <= wave_width / 2.0:
			_deal_damage_to(player, ability.damage)
			_apply_status_to(player, Enums.EffectType.POISON, 3.0)
	
	# Vizuális: zöld hullám
	var effect := Node2D.new()
	effect.global_position = global_position
	
	var wave_sprite := Sprite2D.new()
	var img := Image.create(int(wave_width), int(wave_length), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.2, 0.6, 0.1, 0.5))
	wave_sprite.texture = ImageTexture.create_from_image(img)
	wave_sprite.rotation = dir.angle() + PI / 2.0
	wave_sprite.position = dir * wave_length / 2.0
	effect.add_child(wave_sprite)
	
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(wave_sprite, "modulate:a", 0.0, 0.8)
	tween.tween_callback(effect.queue_free)

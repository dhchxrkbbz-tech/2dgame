## SpiderMatriarch - Dungeon Boss 2: Webbed Cavern
## 2 fázisos, summon tojások, web shot, venom spray, ceiling drop
class_name SpiderMatriarch
extends BossBase

var web_carpet_active: bool = false
var is_on_ceiling: bool = false
var _ceiling_timer: float = 0.0
var _ceiling_target_pos: Vector2 = Vector2.ZERO


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Spider Matriarch"
	boss_data.boss_id = "spider_matriarch"
	boss_data.tier = 2
	boss_data.base_hp = 4000
	boss_data.armor = 12
	boss_data.damage = 35
	boss_data.speed = 60.0
	boss_data.attack_speed = 1.0
	boss_data.recommended_level_min = 12
	boss_data.recommended_level_max = 16
	boss_data.required_players = 1
	boss_data.sprite_size = Vector2(64, 64)
	boss_data.collision_size = Vector2(48, 40)
	boss_data.biome = Enums.BiomeType.CURSED_FOREST
	boss_data.sprite_color = Color(0.4, 0.2, 0.5)
	boss_data.loot_table = BossLoot.create_loot_table_tier2("spider_matriarch")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Broodmother (100%-50%)
	var phase1 := BossPhase.create(0, "Broodmother", 1.0)
	
	var web_shot := BossAbility.create(
		"Web Shot", 15, 5.0, 256.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	web_shot.priority = 7
	web_shot.status_effect = Enums.EffectType.ROOT
	web_shot.status_duration = 2.0
	web_shot.is_tracking = false
	web_shot.projectile_speed = 180.0
	web_shot.callback_name = "_ability_web_shot"
	phase1.add_ability(web_shot)
	
	var spawn_eggs := BossAbility.create(
		"Spawn Eggs", 0, 12.0, 200.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	spawn_eggs.priority = 8
	spawn_eggs.callback_name = "_ability_spawn_eggs"
	phase1.add_ability(spawn_eggs)
	
	var venom_spray := BossAbility.create(
		"Venom Spray", 25, 7.0, 96.0,
		BossAbility.AreaType.CONE, Vector2(90, 96), 0.5
	)
	venom_spray.priority = 6
	venom_spray.status_effect = Enums.EffectType.POISON
	venom_spray.status_duration = 4.0
	venom_spray.callback_name = "_ability_venom_spray"
	phase1.add_ability(venom_spray)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Enraged Queen (50%-0%)
	var phase2 := BossPhase.create(1, "Enraged Queen", 0.5)
	phase2.set_modifiers({"damage_mult": 1.2, "speed_mult": 1.15})
	
	# Korábbi ability-k
	var web_shot2 := BossAbility.create("Web Shot", 15, 5.0, 256.0, BossAbility.AreaType.NONE, Vector2.ZERO, 0.0)
	web_shot2.priority = 7
	web_shot2.status_effect = Enums.EffectType.ROOT
	web_shot2.status_duration = 2.0
	web_shot2.projectile_speed = 180.0
	web_shot2.callback_name = "_ability_web_shot"
	phase2.add_ability(web_shot2)
	
	var spawn_eggs2 := BossAbility.create("Spawn Eggs", 0, 12.0, 200.0, BossAbility.AreaType.NONE, Vector2.ZERO, 0.0)
	spawn_eggs2.priority = 8
	spawn_eggs2.callback_name = "_ability_spawn_eggs_p2"
	phase2.add_ability(spawn_eggs2)
	
	var venom_spray2 := BossAbility.create("Venom Spray", 30, 7.0, 96.0, BossAbility.AreaType.CONE, Vector2(90, 96), 0.5)
	venom_spray2.priority = 6
	venom_spray2.status_effect = Enums.EffectType.POISON
	venom_spray2.status_duration = 4.0
	venom_spray2.callback_name = "_ability_venom_spray"
	phase2.add_ability(venom_spray2)
	
	# Új ability-k
	var web_carpet := BossAbility.create("Web Carpet", 0, 20.0, 999.0, BossAbility.AreaType.NONE, Vector2.ZERO, 0.0)
	web_carpet.priority = 9
	web_carpet.callback_name = "_ability_web_carpet"
	phase2.add_ability(web_carpet)
	
	var ceiling_drop := BossAbility.create("Ceiling Drop", 60, 12.0, 300.0, BossAbility.AreaType.CIRCLE, Vector2(96, 96), 1.5)
	ceiling_drop.priority = 10
	ceiling_drop.callback_name = "_ability_ceiling_drop"
	phase2.add_ability(ceiling_drop)
	
	boss_data.phases.append(phase2)


# === Custom ability implementációk ===

func _ability_web_shot(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var proj := Projectile.new()
	var dir := global_position.direction_to(_current_target.global_position)
	proj.setup(ability.damage * damage_multiplier, ability.projectile_speed, dir, "boss", Enums.DamageType.NATURE)
	proj.global_position = global_position
	
	# Web hatás: root a targeten
	proj.on_hit_status = Enums.EffectType.ROOT
	proj.on_hit_status_duration = 2.0
	
	get_parent().add_child(proj)


func _ability_spawn_eggs(ability: BossAbility) -> void:
	# 3 tojás lerakása
	_spawn_egg_cluster(3, false)


func _ability_spawn_eggs_p2(ability: BossAbility) -> void:
	# 5 tojás Phase 2-ben, mérgező kis pókok
	_spawn_egg_cluster(5, true)


func _spawn_egg_cluster(count: int, poisonous: bool) -> void:
	for i in count:
		var angle := TAU * float(i) / float(count)
		var pos := global_position + Vector2.from_angle(angle) * 64
		_spawn_egg(pos, poisonous)


func _spawn_egg(pos: Vector2, poisonous: bool) -> void:
	# Tojás: 30 HP, 5s után kikel
	var egg := Area2D.new()
	egg.name = "SpiderEgg"
	egg.global_position = pos
	egg.collision_layer = 1 << (Constants.LAYER_ENEMY_HURTBOX - 1)
	egg.collision_mask = 0
	
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(12, 12)
	shape.shape = rect
	egg.add_child(shape)
	
	var egg_sprite := Sprite2D.new()
	var img := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.8, 0.6) if not poisonous else Color(0.5, 0.8, 0.3))
	egg_sprite.texture = ImageTexture.create_from_image(img)
	egg.add_child(egg_sprite)
	
	get_parent().add_child(egg)
	
	# Egg HP
	var egg_hp := 30
	
	# Hatch timer
	var hatch_timer := Timer.new()
	hatch_timer.wait_time = 5.0
	hatch_timer.one_shot = true
	hatch_timer.autostart = true
	hatch_timer.timeout.connect(func():
		if is_instance_valid(egg):
			_hatch_spiderling(egg.global_position, poisonous)
			egg.queue_free()
	)
	egg.add_child(hatch_timer)


func _hatch_spiderling(pos: Vector2, poisonous: bool) -> void:
	var spider_data := {
		"name": "Spiderling" if not poisonous else "Venomous Spiderling",
		"id": "spiderling",
		"hp": 20,
		"damage": 10 if not poisonous else 12,
		"speed": 70.0,
		"attack_range": 24.0,
		"xp": 5,
		"color": Color(0.3, 0.2, 0.4) if not poisonous else Color(0.3, 0.5, 0.2),
		"category": Enums.EnemyType.SWARM,
	}
	
	var spider := EnemyBase.new()
	var data := EnemyData.new()
	data.enemy_name = spider_data["name"]
	data.enemy_id = spider_data["id"]
	data.enemy_category = spider_data["category"]
	data.base_hp = spider_data["hp"]
	data.base_damage = spider_data["damage"]
	data.base_speed = spider_data["speed"]
	data.attack_range = spider_data["attack_range"]
	data.detection_range = 200.0
	data.base_xp = spider_data["xp"]
	data.sprite_color = spider_data["color"]
	
	spider.enemy_data = data
	spider.enemy_level = boss_level
	spider.global_position = pos
	
	get_parent().add_child(spider)
	summons.append(spider)


func _ability_venom_spray(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var cone_angle := deg_to_rad(90)
	var cone_length := 96.0
	
	for player in get_tree().get_nodes_in_group("player"):
		var to_player := player.global_position - global_position
		var dist := to_player.length()
		if dist > cone_length:
			continue
		var angle_diff := abs(to_player.angle_to(dir))
		if angle_diff <= cone_angle / 2.0:
			_deal_damage_to(player, ability.damage)
			_apply_status_to(player, Enums.EffectType.POISON, 4.0)
	
	# Vizuális zöld kúp
	telegraph.show_cone(global_position, dir, 90, cone_length, 0.5, Color(0.3, 0.7, 0.1, 0.4))


func _ability_web_carpet(ability: BossAbility) -> void:
	web_carpet_active = true
	
	# 60% az aréna hálóval borítva → slow
	var carpet_size := Vector2(384, 384)
	var effect := Node2D.new()
	effect.global_position = global_position
	effect.z_index = -1
	
	var carpet_sprite := Sprite2D.new()
	var img := Image.create(int(carpet_size.x), int(carpet_size.y), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.8, 0.8, 0.8, 0.15))
	carpet_sprite.texture = ImageTexture.create_from_image(img)
	effect.add_child(carpet_sprite)
	get_parent().add_child(effect)
	
	# 10s slow
	var tick_timer := Timer.new()
	tick_timer.wait_time = 1.0
	tick_timer.autostart = true
	var ticks := 0
	tick_timer.timeout.connect(func():
		ticks += 1
		if ticks >= 10:
			effect.queue_free()
			web_carpet_active = false
			return
		for player in get_tree().get_nodes_in_group("player"):
			var diff := player.global_position - global_position
			if abs(diff.x) <= carpet_size.x / 2.0 and abs(diff.y) <= carpet_size.y / 2.0:
				_apply_status_to(player, Enums.EffectType.SLOW, 2.0)
	)
	effect.add_child(tick_timer)


func _ability_ceiling_drop(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	# Felugrik a plafonra → untargetable
	is_invulnerable = true
	is_on_ceiling = true
	_ceiling_target_pos = _current_target.global_position
	_ceiling_timer = 3.0
	
	# Vizuálisan eltűnik felfelé
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.2, 0.3)
	
	# Árnyék a célpont alatt
	telegraph.show_circle(_ceiling_target_pos, 48.0, 3.0, Color(0.3, 0.1, 0.3, 0.4))


func _physics_process(delta: float) -> void:
	if is_on_ceiling:
		_ceiling_timer -= delta
		velocity = Vector2.ZERO
		
		# Target tracking
		if _current_target and is_instance_valid(_current_target):
			_ceiling_target_pos = _current_target.global_position
		
		if _ceiling_timer <= 0:
			_ceiling_land()
		return
	
	super._physics_process(delta)


func _ceiling_land() -> void:
	is_on_ceiling = false
	is_invulnerable = false
	
	# Teleport a cél pozícióra
	global_position = _ceiling_target_pos
	
	# Visual visszatérés
	sprite.modulate.a = 1.0
	
	# 3×3 AoE csapódás (96×96 pixel)
	var impact_radius := 48.0
	for player in get_tree().get_nodes_in_group("player"):
		if player.global_position.distance_to(global_position) <= impact_radius:
			_deal_damage_to(player, 60 * damage_multiplier)
	
	# Impact vizuál
	var effect := Sprite2D.new()
	var img := Image.create(96, 96, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.4, 0.2, 0.5, 0.5))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = global_position
	effect.z_index = -1
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "scale", Vector2(1.5, 1.5), 0.3)
	tween.parallel().tween_property(effect, "modulate:a", 0.0, 0.3)
	tween.tween_callback(effect.queue_free)
	
	current_state = BossState.IDLE
	_idle_timer = 1.5

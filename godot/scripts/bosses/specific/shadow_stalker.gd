## ShadowStalker - Mini Boss 4: Cursed Forest / Ruins
## Gyors hit-and-run boss. Shadow Dash, Shadow Pool, Clone Split.
class_name ShadowStalker
extends BossBase

var _stealth_timer: float = 0.0
var _is_stealthed: bool = false
var _clones: Array[Node] = []


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Shadow Stalker"
	boss_data.boss_id = "shadow_stalker"
	boss_data.tier = 1
	boss_data.base_hp = 500
	boss_data.armor = 3
	boss_data.damage = 35
	boss_data.speed = 120.0
	boss_data.attack_speed = 1.5
	boss_data.recommended_level_min = 8
	boss_data.recommended_level_max = 12
	boss_data.required_players = 1
	boss_data.sprite_size = Vector2(36, 36)
	boss_data.collision_size = Vector2(24, 24)
	boss_data.biome = Enums.BiomeType.CURSED_FOREST
	boss_data.sprite_color = Color(0.15, 0.1, 0.2)
	boss_data.loot_table = BossLoot.create_loot_table_tier1("shadow_stalker")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Predator (100%-50%)
	var phase1 := BossPhase.create(0, "Predator", 1.0)
	
	var shadow_dash := BossAbility.create(
		"Shadow Dash", 30, 4.0, 160.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	shadow_dash.priority = 7
	shadow_dash.min_range = 48.0
	shadow_dash.callback_name = "_ability_shadow_dash"
	phase1.add_ability(shadow_dash)
	
	var shadow_pool := BossAbility.create(
		"Shadow Pool", 10, 8.0, 256.0,
		BossAbility.AreaType.CIRCLE, Vector2(96, 96), 0.0
	)
	shadow_pool.priority = 5
	shadow_pool.callback_name = "_ability_shadow_pool"
	phase1.add_ability(shadow_pool)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Phantom (50%-0%)
	var phase2 := BossPhase.create(1, "Phantom", 0.5)
	phase2.set_modifiers({"speed_mult": 1.3})
	
	var shadow_dash2 := BossAbility.create("Shadow Dash", 30, 3.0, 200.0, BossAbility.AreaType.NONE, Vector2.ZERO, 0.0)
	shadow_dash2.priority = 7
	shadow_dash2.min_range = 32.0
	shadow_dash2.callback_name = "_ability_shadow_dash"
	phase2.add_ability(shadow_dash2)
	
	var shadow_pool2 := BossAbility.create("Shadow Pool", 10, 8.0, 256.0, BossAbility.AreaType.CIRCLE, Vector2(128, 128), 0.0)
	shadow_pool2.priority = 5
	shadow_pool2.callback_name = "_ability_shadow_pool_large"
	phase2.add_ability(shadow_pool2)
	
	var clone_split := BossAbility.create("Clone Split", 0, 15.0, 999.0, BossAbility.AreaType.NONE, Vector2.ZERO, 0.0)
	clone_split.priority = 9
	clone_split.callback_name = "_ability_clone_split"
	phase2.add_ability(clone_split)
	
	boss_data.phases.append(phase2)


# === Custom ability implementációk ===

func _ability_shadow_dash(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var dir := global_position.direction_to(_current_target.global_position)
	var dash_dist := global_position.distance_to(_current_target.global_position) + 48
	
	# Rövid invulnerability a dash során
	is_invulnerable = true
	
	# Gyors mozgás a targeten keresztül
	var start_pos := global_position
	var end_pos := global_position + dir * dash_dist
	
	var tween := create_tween()
	tween.tween_property(self, "global_position", end_pos, 0.2)
	tween.tween_callback(func():
		is_invulnerable = false
	)
	
	# Damage a közben érintett playereknek
	# Kis késleltetéssel
	var damage_timer := Timer.new()
	damage_timer.wait_time = 0.1
	damage_timer.one_shot = true
	damage_timer.autostart = true
	damage_timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(global_position) <= 40:
				_deal_damage_to(player, ability.damage)
		damage_timer.queue_free()
	)
	add_child(damage_timer)
	
	# Shadow trail vizuál
	_spawn_shadow_trail(start_pos, end_pos)


func _ability_shadow_pool(ability: BossAbility) -> void:
	_create_shadow_pool(96.0, 5.0, 10.0)


func _ability_shadow_pool_large(ability: BossAbility) -> void:
	_create_shadow_pool(128.0, 5.0, 10.0)


func _create_shadow_pool(radius: float, duration: float, dps: float) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var pool_pos := _current_target.global_position
	
	var pool := Node2D.new()
	pool.global_position = pool_pos
	pool.z_index = -1
	
	# Vizuál
	var pool_sprite := Sprite2D.new()
	var size := int(radius * 2)
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.1, 0.05, 0.15, 0.4))
	pool_sprite.texture = ImageTexture.create_from_image(img)
	pool.add_child(pool_sprite)
	
	get_parent().add_child(pool)
	
	# DOT timer
	var tick_timer := Timer.new()
	tick_timer.wait_time = 1.0
	tick_timer.autostart = true
	tick_timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(pool_pos) <= radius:
				_deal_damage_to(player, dps)
	)
	pool.add_child(tick_timer)
	
	# Lifetime
	var life_timer := Timer.new()
	life_timer.wait_time = duration
	life_timer.one_shot = true
	life_timer.autostart = true
	life_timer.timeout.connect(pool.queue_free)
	pool.add_child(life_timer)


func _ability_clone_split(ability: BossAbility) -> void:
	# 2 klón létrehozása
	for clone in _clones:
		if is_instance_valid(clone):
			clone.queue_free()
	_clones.clear()
	
	for i in 2:
		var clone := _create_clone(i)
		_clones.append(clone)
	
	# Boss stealth-be megy 3s-re
	_is_stealthed = true
	_stealth_timer = 3.0
	is_invulnerable = true
	sprite.modulate.a = 0.1


func _create_clone(index: int) -> Node2D:
	var clone := CharacterBody2D.new()
	clone.name = "ShadowClone_%d" % index
	
	var offset := Vector2(64 if index == 0 else -64, 0)
	clone.global_position = global_position + offset
	
	# Clone sprite (hasonló, de halványabb)
	var clone_sprite := Sprite2D.new()
	var img := Image.create(int(boss_data.sprite_size.x), int(boss_data.sprite_size.y), false, Image.FORMAT_RGBA8)
	img.fill(boss_data.sprite_color)
	clone_sprite.texture = ImageTexture.create_from_image(img)
	clone_sprite.modulate.a = 0.7
	clone.add_child(clone_sprite)
	
	# Clone collision
	var col := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = boss_data.collision_size
	col.shape = rect
	clone.collision_layer = 1 << (Constants.LAYER_ENEMY_PHYSICS - 1)
	clone.collision_mask = 1 << (Constants.LAYER_WALL - 1)
	clone.add_child(col)
	
	# Clone HP script (dummy)
	clone.set_meta("hp", 50)
	clone.set_meta("max_hp", 50)
	clone.set_meta("damage", 15)
	
	get_parent().add_child(clone)
	
	# Clone AI: egyszerű chase
	var chase_timer := Timer.new()
	chase_timer.wait_time = 0.1
	chase_timer.autostart = true
	chase_timer.timeout.connect(func():
		if not is_instance_valid(clone):
			return
		var target := _find_nearest_player()
		if target:
			var dir := clone.global_position.direction_to(target.global_position)
			clone.velocity = dir * 80
			clone.move_and_slide()
			if clone.global_position.distance_to(target.global_position) <= 32:
				if target.has_method("take_damage"):
					target.take_damage(15)
	)
	clone.add_child(chase_timer)
	
	return clone


func _physics_process(delta: float) -> void:
	if _is_stealthed:
		_stealth_timer -= delta
		velocity = Vector2.ZERO
		if _stealth_timer <= 0:
			_is_stealthed = false
			is_invulnerable = false
			sprite.modulate.a = 1.0
			# Teleport mögé a target-nek
			if _current_target and is_instance_valid(_current_target):
				var behind := _current_target.global_position + Vector2(0, 40)
				global_position = behind
		# Nem futtatjuk a super._physics_process-t stealth alatt
		return
	
	super._physics_process(delta)


func _spawn_shadow_trail(start: Vector2, end: Vector2) -> void:
	var segments := 5
	for i in segments:
		var t := float(i) / float(segments)
		var pos := start.lerp(end, t)
		
		var trail := Sprite2D.new()
		var img := Image.create(int(boss_data.sprite_size.x), int(boss_data.sprite_size.y), false, Image.FORMAT_RGBA8)
		img.fill(Color(0.1, 0.05, 0.15, 0.3))
		trail.texture = ImageTexture.create_from_image(img)
		trail.global_position = pos
		get_parent().add_child(trail)
		
		var tween := trail.create_tween()
		tween.tween_property(trail, "modulate:a", 0.0, 0.5 + t * 0.5)
		tween.tween_callback(trail.queue_free)

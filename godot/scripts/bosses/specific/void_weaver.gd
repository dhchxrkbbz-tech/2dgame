## VoidWeaver - Tier 3 World Boss: Void Rift
## Dimenzió-manipuláló boss. Void Rift, Shadow Clones, Reality Tear, Void Prison.
## Level: 48-50, HP: 150,000, DMG: 200-280, 5 phases, 4-player recommended
class_name VoidWeaver
extends BossBase

var shadow_clones: Array[Node] = []
const MAX_CLONES := 3


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Void Weaver"
	boss_data.boss_id = "void_weaver"
	boss_data.tier = 3
	boss_data.base_hp = 150000
	boss_data.armor = 40
	boss_data.damage = 240
	boss_data.speed = 50.0
	boss_data.attack_speed = 1.0
	boss_data.recommended_level_min = 48
	boss_data.recommended_level_max = 50
	boss_data.required_players = 4
	boss_data.enrage_time = Constants.BOSS_ENRAGE_TIMERS.get(3, 600.0)
	boss_data.sprite_size = Vector2(56, 64)
	boss_data.collision_size = Vector2(40, 48)
	boss_data.biome = Enums.BiomeType.VOID_RIFT
	boss_data.sprite_color = Color(0.3, 0.1, 0.5)
	boss_data.loot_table = BossLoot.create_loot_table_tier3("void_weaver")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Reality Bender (100% - 80%)
	var phase1 := BossPhase.create(0, "Reality Bender", 1.0)
	
	var void_bolt := BossAbility.create(
		"Void Bolt", 210, 3.0, 200.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.5
	)
	void_bolt.priority = 4
	void_bolt.is_tracking = true
	void_bolt.projectile_speed = 200.0
	void_bolt.callback_name = "_ability_void_bolt"
	phase1.add_ability(void_bolt)
	
	var shadow_strike := BossAbility.create(
		"Shadow Strike", 230, 5.0, 64.0,
		BossAbility.AreaType.CONE, Vector2(90, 64), 0.8
	)
	shadow_strike.priority = 5
	shadow_strike.callback_name = "_ability_shadow_strike"
	phase1.add_ability(shadow_strike)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Void Manipulation (80% - 60%)
	var phase2 := BossPhase.create(1, "Void Manipulation", 0.80)
	phase2.set_modifiers({"damage_mult": 1.15})
	
	var void_rift := BossAbility.create(
		"Void Rift", 180, 10.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(64, 64), 1.5
	)
	void_rift.priority = 8
	void_rift.callback_name = "_ability_void_rift"
	phase2.add_ability(void_rift)
	
	var void_bolt2 := BossAbility.create(
		"Void Bolt", 220, 2.5, 220.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.4
	)
	void_bolt2.priority = 4
	void_bolt2.is_tracking = true
	void_bolt2.projectile_speed = 220.0
	void_bolt2.projectile_count = 2
	void_bolt2.callback_name = "_ability_void_bolt"
	phase2.add_ability(void_bolt2)
	
	var shadow_strike2 := BossAbility.create(
		"Shadow Strike", 240, 4.5, 64.0,
		BossAbility.AreaType.CONE, Vector2(90, 72), 0.7
	)
	shadow_strike2.priority = 5
	shadow_strike2.callback_name = "_ability_shadow_strike"
	phase2.add_ability(shadow_strike2)
	
	boss_data.phases.append(phase2)
	
	# Phase 3: Dimensional Rift (60% - 40%)
	var phase3 := BossPhase.create(2, "Dimensional Rift", 0.60)
	phase3.set_modifiers({"damage_mult": 1.3, "speed_mult": 1.2})
	
	var reality_tear := BossAbility.create(
		"Reality Tear", 260, 8.0, 160.0,
		BossAbility.AreaType.LINE, Vector2(160, 40), 1.5
	)
	reality_tear.priority = 8
	reality_tear.callback_name = "_ability_reality_tear"
	phase3.add_ability(reality_tear)
	
	var shadow_clones_ability := BossAbility.create(
		"Shadow Clones", 0, 20.0, 300.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	shadow_clones_ability.priority = 9
	shadow_clones_ability.callback_name = "_ability_shadow_clones"
	phase3.add_ability(shadow_clones_ability)
	
	var void_bolt3 := BossAbility.create(
		"Void Barrage", 200, 2.0, 240.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.3
	)
	void_bolt3.priority = 4
	void_bolt3.is_tracking = true
	void_bolt3.projectile_speed = 250.0
	void_bolt3.projectile_count = 3
	void_bolt3.callback_name = "_ability_void_bolt"
	phase3.add_ability(void_bolt3)
	
	boss_data.phases.append(phase3)
	
	# Phase 4: Void Prison (40% - 20%)
	var phase4 := BossPhase.create(3, "Void Prison", 0.40)
	phase4.set_modifiers({"damage_mult": 1.5, "attack_speed_mult": 1.3})
	
	var void_prison := BossAbility.create(
		"Void Prison", 150, 15.0, 200.0,
		BossAbility.AreaType.CIRCLE, Vector2(48, 48), 2.0
	)
	void_prison.priority = 10
	void_prison.callback_name = "_ability_void_prison"
	phase4.add_ability(void_prison)
	
	var reality_tear2 := BossAbility.create(
		"Reality Tear", 280, 6.0, 180.0,
		BossAbility.AreaType.LINE, Vector2(180, 48), 1.2
	)
	reality_tear2.priority = 7
	reality_tear2.callback_name = "_ability_reality_tear"
	phase4.add_ability(reality_tear2)
	
	var void_rift2 := BossAbility.create(
		"Void Rift", 200, 8.0, 220.0,
		BossAbility.AreaType.CIRCLE, Vector2(80, 80), 1.2
	)
	void_rift2.priority = 6
	void_rift2.callback_name = "_ability_void_rift"
	phase4.add_ability(void_rift2)
	
	boss_data.phases.append(phase4)
	
	# Phase 5: Oblivion (20% - 0%)
	var phase5 := BossPhase.create(4, "Oblivion", 0.20)
	phase5.set_modifiers({"damage_mult": 2.0, "attack_speed_mult": 1.6, "speed_mult": 1.5})
	phase5.aura_damage = 30.0
	phase5.aura_range = 96.0
	
	var annihilate := BossAbility.create(
		"Annihilate", 350, 12.0, 250.0,
		BossAbility.AreaType.CIRCLE, Vector2(160, 160), 2.5
	)
	annihilate.priority = 10
	annihilate.callback_name = "_ability_annihilate"
	phase5.add_ability(annihilate)
	
	var reality_tear3 := BossAbility.create(
		"Reality Tear", 300, 5.0, 200.0,
		BossAbility.AreaType.LINE, Vector2(200, 56), 1.0
	)
	reality_tear3.priority = 7
	reality_tear3.callback_name = "_ability_reality_tear"
	phase5.add_ability(reality_tear3)
	
	var void_bolt4 := BossAbility.create(
		"Void Storm", 220, 1.5, 260.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.2
	)
	void_bolt4.priority = 4
	void_bolt4.is_tracking = true
	void_bolt4.projectile_speed = 280.0
	void_bolt4.projectile_count = 5
	void_bolt4.callback_name = "_ability_void_bolt"
	phase5.add_ability(void_bolt4)
	
	boss_data.phases.append(phase5)


# === Ability implementációk ===

func _ability_void_bolt(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var base_dir := global_position.direction_to(_current_target.global_position)
	var count := ability.projectile_count
	var spread := deg_to_rad(10.0)
	
	for i in count:
		var angle_offset := (float(i) - float(count - 1) / 2.0) * spread
		var dir := base_dir.rotated(angle_offset)
		
		var proj := Projectile.new()
		proj.setup(
			ability.damage * damage_multiplier,
			ability.projectile_speed,
			dir,
			"boss",
			Enums.DamageType.DARK,
		)
		proj.global_position = global_position + dir * 20
		proj.tracking_target = _current_target if ability.is_tracking else null
		get_parent().add_child(proj)


func _ability_shadow_strike(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	# Teleport mögé, majd ütés
	var behind_dir := _current_target.global_position.direction_to(global_position).rotated(PI)
	var teleport_pos := _current_target.global_position + behind_dir * 32
	
	# Eltűnés
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): global_position = teleport_pos)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	tween.tween_callback(func():
		var dist := global_position.distance_to(_current_target.global_position)
		if dist <= ability.range and is_instance_valid(_current_target):
			_deal_damage_to(_current_target, ability.damage)
	)


func _ability_void_rift(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	var target_pos := _current_target.global_position
	var radius := ability.area_size.x / 2.0
	
	# Void rift: tér-idő anomália, 5 mp-ig damage zóna + slow
	_spawn_void_zone(target_pos, radius, ability.damage, 5.0)


func _ability_reality_tear(ability: BossAbility) -> void:
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
			_apply_status_to(player, Enums.EffectType.SILENCE, 2.0)
	
	# Vizuális: sötét repedés
	var effect := Sprite2D.new()
	var img := Image.create(int(width), int(length), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.3, 0.0, 0.5, 0.6))
	effect.texture = ImageTexture.create_from_image(img)
	effect.global_position = global_position + dir * length / 2.0
	effect.rotation = dir.angle() + PI / 2.0
	get_parent().add_child(effect)
	
	var tween := effect.create_tween()
	tween.tween_property(effect, "modulate:a", 0.0, 0.8)
	tween.tween_callback(effect.queue_free)


func _ability_shadow_clones(ability: BossAbility) -> void:
	# Cleanup dead clones
	shadow_clones = shadow_clones.filter(func(c): return is_instance_valid(c) and c.current_hp > 0)
	
	if shadow_clones.size() >= MAX_CLONES:
		return
	
	var to_spawn := mini(2, MAX_CLONES - shadow_clones.size())
	
	for i in to_spawn:
		var clone_data := {
			"name": "Shadow Clone", "id": "void_clone", "hp": 8000,
			"damage": 100, "speed": 55.0, "attack_range": 64.0,
			"xp": 150, "color": Color(0.3, 0.1, 0.5, 0.7),
			"category": Enums.EnemyType.MELEE,
		}
		_spawn_summon(clone_data, i)
		# Az utolsó spawn summons-ba kerül
		if summons.size() > 0:
			shadow_clones.append(summons[-1])


func _ability_void_prison(ability: BossAbility) -> void:
	# Random player-t fog be (nem a fő target)
	var secondary := threat_table.get_secondary_target()
	if not secondary or not is_instance_valid(secondary):
		secondary = threat_table.get_random_target()
	if not secondary or not is_instance_valid(secondary):
		return
	
	# Prison: immobilize 4 mp
	_apply_status_to(secondary, Enums.EffectType.ROOT, 4.0)
	
	# Visual: lila börtön
	_spawn_prison_effect(secondary.global_position, 4.0)
	
	# Tick damage
	var tick_count := 0
	var tick_timer := Timer.new()
	tick_timer.wait_time = 1.0
	tick_timer.autostart = true
	tick_timer.timeout.connect(func():
		tick_count += 1
		if is_instance_valid(secondary):
			_deal_damage_to(secondary, ability.damage)
		if tick_count >= 4:
			tick_timer.queue_free()
	)
	add_child(tick_timer)


func _ability_annihilate(ability: BossAbility) -> void:
	var radius := ability.area_size.x / 2.0
	
	# Charge-up visual
	var charge_effect := _spawn_void_charge(global_position, 2.0)
	
	var timer := get_tree().create_timer(2.0)
	timer.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			var dist := player.global_position.distance_to(global_position)
			if dist <= radius:
				var falloff := 1.0 - (dist / radius) * 0.5
				_deal_damage_to(player, ability.damage * falloff)
				_apply_status_to(player, Enums.EffectType.SILENCE, 3.0)
	)


# === Segéd metódusok ===

func _spawn_void_zone(center: Vector2, radius: float, damage_per_tick: float, duration: float) -> void:
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
	effect.set("color", Color(0.3, 0.0, 0.5, 0.3))
	
	get_parent().add_child(effect)
	
	var tick := Timer.new()
	tick.wait_time = 1.0
	tick.autostart = true
	tick.timeout.connect(func():
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(center) <= radius:
				_deal_damage_to(player, damage_per_tick * 0.3)
				_apply_status_to(player, Enums.EffectType.SLOW, 1.5)
	)
	effect.add_child(tick)
	
	var life := Timer.new()
	life.wait_time = duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(effect.queue_free)
	effect.add_child(life)


func _spawn_prison_effect(pos: Vector2, duration: float) -> void:
	var effect := Node2D.new()
	effect.global_position = pos
	
	var script_text := """
extends Node2D
var radius: float = 20.0
var color: Color = Color(0.5, 0.1, 0.8, 0.6)
func _draw():
	draw_arc(Vector2.ZERO, radius, 0, TAU, 16, color, 2.0)
	draw_arc(Vector2.ZERO, radius * 0.6, 0, TAU, 12, color * 0.7, 1.5)
"""
	var script := GDScript.new()
	script.source_code = script_text
	script.reload()
	effect.set_script(script)
	
	get_parent().add_child(effect)
	
	var life := Timer.new()
	life.wait_time = duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(effect.queue_free)
	effect.add_child(life)


func _spawn_void_charge(center: Vector2, duration: float) -> Node2D:
	var effect := Node2D.new()
	effect.global_position = center
	
	var script_text := """
extends Node2D
var radius: float = 8.0
var max_radius: float = 80.0
var grow_speed: float = 40.0
var color: Color = Color(0.4, 0.0, 0.6, 0.5)
func _process(delta):
	radius = minf(radius + grow_speed * delta, max_radius)
	queue_redraw()
func _draw():
	draw_circle(Vector2.ZERO, radius, color)
"""
	var script := GDScript.new()
	script.source_code = script_text
	script.reload()
	effect.set_script(script)
	
	get_parent().add_child(effect)
	
	var life := Timer.new()
	life.wait_time = duration
	life.one_shot = true
	life.autostart = true
	life.timeout.connect(effect.queue_free)
	effect.add_child(life)
	
	return effect

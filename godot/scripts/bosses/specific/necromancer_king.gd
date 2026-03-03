## NecromancerKing - Dungeon Boss 1: Crypt of the Fallen
## 3 fázisos boss, undead summon, dark shield, curse field, bone storm
class_name NecromancerKing
extends BossBase

var dark_shield_hp: int = 0
var dark_shield_active: bool = false
var bone_storm_active: bool = false


func _init() -> void:
	boss_data = BossData.new()
	boss_data.boss_name = "Necromancer King"
	boss_data.boss_id = "necromancer_king"
	boss_data.tier = 2
	boss_data.base_hp = 5000
	boss_data.armor = 8
	boss_data.damage = 40
	boss_data.speed = 50.0
	boss_data.attack_speed = 1.0
	boss_data.recommended_level_min = 15
	boss_data.recommended_level_max = 20
	boss_data.required_players = 1
	boss_data.sprite_size = Vector2(64, 64)
	boss_data.collision_size = Vector2(40, 40)
	boss_data.biome = Enums.BiomeType.RUINS
	boss_data.sprite_color = Color(0.3, 0.15, 0.4)
	boss_data.loot_table = BossLoot.create_loot_table_tier2("necromancer_king")
	
	_setup_phases()


func _setup_phases() -> void:
	# Phase 1: Summoner (100%-60%)
	var phase1 := BossPhase.create(0, "Summoner", 1.0)
	
	var summon_undead := BossAbility.create(
		"Summon Undead", 0, 12.0, 400.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	summon_undead.priority = 9
	summon_undead.summon_count = 4
	summon_undead.summon_data = {
		"name": "Skeleton Warrior", "id": "skeleton_warrior", "hp": 30,
		"damage": 12, "armor": 2, "speed": 55.0, "attack_range": 32.0,
		"xp": 8, "color": Color(0.7, 0.7, 0.6),
		"category": Enums.EnemyType.MELEE,
	}
	summon_undead.callback_name = "_ability_summon_undead"
	phase1.add_ability(summon_undead)
	
	var death_bolt := BossAbility.create(
		"Death Bolt", 50, 3.0, 256.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	death_bolt.priority = 6
	death_bolt.is_tracking = true
	death_bolt.projectile_speed = 120.0
	death_bolt.callback_name = "_ability_death_bolt"
	phase1.add_ability(death_bolt)
	
	var dark_shield := BossAbility.create(
		"Dark Shield", 0, 20.0, 999.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	dark_shield.priority = 10
	dark_shield.callback_name = "_ability_dark_shield"
	phase1.add_ability(dark_shield)
	
	boss_data.phases.append(phase1)
	
	# Phase 2: Curse Master (60%-30%)
	var phase2 := BossPhase.create(1, "Curse Master", 0.6)
	
	# Korábbi ability-k (death bolt x2)
	var summon_undead2 := summon_undead.duplicate() if summon_undead is RefCounted else BossAbility.create(
		"Summon Undead", 0, 12.0, 400.0, BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	summon_undead2 = BossAbility.create("Summon Undead", 0, 12.0, 400.0, BossAbility.AreaType.NONE, Vector2.ZERO, 0.0)
	summon_undead2.priority = 9
	summon_undead2.summon_count = 4
	summon_undead2.summon_data = summon_undead.summon_data
	summon_undead2.callback_name = "_ability_summon_undead"
	phase2.add_ability(summon_undead2)
	
	var death_bolt2 := BossAbility.create(
		"Death Bolt x2", 50, 3.0, 256.0,
		BossAbility.AreaType.NONE, Vector2.ZERO, 0.0
	)
	death_bolt2.priority = 6
	death_bolt2.is_tracking = true
	death_bolt2.projectile_speed = 120.0
	death_bolt2.projectile_count = 2
	death_bolt2.callback_name = "_ability_death_bolt"
	phase2.add_ability(death_bolt2)
	
	var curse_field := BossAbility.create(
		"Curse Field", 0, 15.0, 400.0,
		BossAbility.AreaType.RECT, Vector2(256, 256), 2.0
	)
	curse_field.priority = 8
	curse_field.callback_name = "_ability_curse_field"
	phase2.add_ability(curse_field)
	
	boss_data.phases.append(phase2)
	
	# Phase 3: Rage Mode (30%-0%)
	var phase3 := BossPhase.create(2, "Rage Mode", 0.3)
	phase3.set_modifiers({"attack_speed_mult": 1.5})
	phase3.special_callback = "_start_bone_storm"
	
	var summon_undead3 := BossAbility.create("Summon Undead", 0, 10.0, 400.0, BossAbility.AreaType.NONE, Vector2.ZERO, 0.0)
	summon_undead3.priority = 9
	summon_undead3.summon_count = 6
	summon_undead3.summon_data = {
		"name": "Empowered Skeleton", "id": "emp_skeleton", "hp": 60,
		"damage": 24, "armor": 4, "speed": 60.0, "attack_range": 32.0,
		"xp": 15, "color": Color(0.8, 0.7, 0.5),
		"category": Enums.EnemyType.MELEE,
	}
	summon_undead3.callback_name = "_ability_summon_undead"
	phase3.add_ability(summon_undead3)
	
	var death_bolt3 := BossAbility.create("Death Bolt x2", 50, 2.5, 256.0, BossAbility.AreaType.NONE, Vector2.ZERO, 0.0)
	death_bolt3.priority = 6
	death_bolt3.is_tracking = true
	death_bolt3.projectile_speed = 140.0
	death_bolt3.projectile_count = 2
	death_bolt3.callback_name = "_ability_death_bolt"
	phase3.add_ability(death_bolt3)
	
	var curse_field3 := BossAbility.create("Curse Field", 0, 12.0, 400.0, BossAbility.AreaType.RECT, Vector2(256, 256), 1.5)
	curse_field3.priority = 8
	curse_field3.callback_name = "_ability_curse_field"
	phase3.add_ability(curse_field3)
	
	boss_data.phases.append(phase3)


# === Phase callbacks ===

func _start_bone_storm() -> void:
	bone_storm_active = true


# === Custom take_damage override (dark shield) ===

func take_damage(amount: int, attacker: Node = null) -> void:
	if dark_shield_active:
		dark_shield_hp -= amount
		_show_damage_number(0, true)
		if dark_shield_hp <= 0:
			dark_shield_active = false
			sprite.modulate = Color.WHITE
		return
	
	super.take_damage(amount, attacker)


# === Custom physics process (bone storm) ===

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if bone_storm_active and fight_started and current_state != BossState.DEAD:
		_aura_timer += delta
		if _aura_timer >= 0.5:
			_aura_timer -= 0.5
			for player in get_tree().get_nodes_in_group("player"):
				if player.global_position.distance_to(global_position) <= 128.0:
					_deal_damage_to(player, 20)
	
	# Halott summon-ok feltámasztása Phase 3-ban (10s-ként)
	if current_phase_index == 2 and fight_started:
		_revive_check(delta)

var _revive_timer: float = 0.0

func _revive_check(delta: float) -> void:
	_revive_timer += delta
	if _revive_timer >= 10.0:
		_revive_timer = 0.0
		# Ha van hely, idézz fel új summon-t
		if get_active_summon_count() < 10:
			var data := {
				"name": "Risen Skeleton", "id": "risen_skeleton", "hp": 40,
				"damage": 15, "armor": 2, "speed": 50.0, "attack_range": 32.0,
				"xp": 5, "color": Color(0.6, 0.6, 0.5),
				"category": Enums.EnemyType.MELEE,
			}
			_spawn_summon(data, 0)


# === Custom ability implementációk ===

func _ability_summon_undead(ability: BossAbility) -> void:
	if get_active_summon_count() >= 10:
		return
	
	var to_spawn := mini(ability.summon_count, 10 - get_active_summon_count())
	for i in to_spawn:
		_spawn_summon(ability.summon_data, i)


func _ability_death_bolt(ability: BossAbility) -> void:
	if not _current_target or not is_instance_valid(_current_target):
		return
	
	for i in ability.projectile_count:
		var proj := Projectile.new()
		var dir := global_position.direction_to(_current_target.global_position)
		# Kicsi szög offset több lövedéknél
		if ability.projectile_count > 1:
			dir = dir.rotated(deg_to_rad(-10 + 20 * i / float(ability.projectile_count - 1)))
		
		proj.setup(
			ability.damage * damage_multiplier,
			ability.projectile_speed,
			dir, "boss", Enums.DamageType.DARK
		)
		proj.global_position = global_position
		proj.tracking_target = _current_target
		
		# Lila szín
		if proj.has_node("Sprite2D"):
			proj.get_node("Sprite2D").modulate = Color(0.5, 0.2, 0.8)
		
		get_parent().add_child(proj)


func _ability_dark_shield(ability: BossAbility) -> void:
	if dark_shield_active:
		return
	if get_active_summon_count() == 0:
		return  # Csak ha vannak summon-ok
	
	dark_shield_active = true
	dark_shield_hp = 500
	sprite.modulate = Color(0.5, 0.3, 0.8, 0.8)


func _ability_curse_field(ability: BossAbility) -> void:
	# Az aréna felét átkozzuk: random oldal
	var arena_center := global_position
	var offset := Vector2(128 if randf() > 0.5 else -128, 0)
	var field_center := arena_center + offset
	var field_size := Vector2(256, 256)
	
	# Vizuális
	var effect := Node2D.new()
	effect.global_position = field_center
	effect.z_index = -1
	
	var curse_sprite := Sprite2D.new()
	var img := Image.create(int(field_size.x), int(field_size.y), false, Image.FORMAT_RGBA8)
	img.fill(Color(0.4, 0.1, 0.5, 0.2))
	curse_sprite.texture = ImageTexture.create_from_image(img)
	effect.add_child(curse_sprite)
	get_parent().add_child(effect)
	
	# Debuff logika: 8 másodpercig
	var duration := 8.0
	var timer_node := Timer.new()
	timer_node.wait_time = 1.0
	timer_node.autostart = true
	var ticks := 0
	timer_node.timeout.connect(func():
		ticks += 1
		if ticks >= int(duration):
			effect.queue_free()
			return
		for player in get_tree().get_nodes_in_group("player"):
			var diff := player.global_position - field_center
			if abs(diff.x) <= field_size.x / 2.0 and abs(diff.y) <= field_size.y / 2.0:
				_apply_status_to(player, Enums.EffectType.WEAKNESS, 2.0)
				_apply_status_to(player, Enums.EffectType.SLOW, 2.0)
	)
	effect.add_child(timer_node)

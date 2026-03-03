## EliteEnemy - Elite enemy extension az EnemyBase-hez
## Affix-ek kezelése, vizuális kiemelés, extra képességek
class_name EliteEnemy
extends EnemyBase

var affixes: Array[int] = []
var elite_tier: int = 1  # 1 = 1 affix, 2 = 2 affix, 3 = 3 affix

# Affix state
var _shield_hp: int = 0
var _shield_max: int = 0
var _shield_active: bool = false
var _shield_cooldown: float = 0.0
var _enrage_active: bool = false
var _enrage_cooldown: float = 0.0
var _enrage_timer: float = 0.0
var _teleport_cooldown: float = 0.0
var _summon_cooldown: float = 0.0
var _trail_timer: float = 0.0
var _frozen_aura_timer: float = 0.0
var _elite_summons: Array[Node] = []


func setup_elite(tier: int) -> void:
	elite_tier = tier
	affixes = EliteAffixSystem.roll_affixes(tier)
	
	# HP és XP bonus
	var hp_mult := 1.0 + tier * 0.5  # +50%/tier
	var xp_mult := 1.0 + tier * 0.75
	
	if enemy_data:
		enemy_data.base_hp = int(enemy_data.base_hp * hp_mult)
		enemy_data.base_xp = int(enemy_data.base_xp * xp_mult)
	
	# Vizuális jelzés
	_apply_elite_visuals()


func _apply_elite_visuals() -> void:
	# Sprite-ot sárgás-narancs szegéllyel jelöljük
	if sprite:
		var tint := Color.WHITE
		for affix in affixes:
			tint = tint.lerp(EliteAffixSystem.get_affix_color(affix), 0.3)
		sprite.modulate = tint
	
	# Név frissítés
	if enemy_data:
		enemy_data.enemy_name = EliteAffixSystem.get_elite_name(enemy_data.enemy_name, affixes)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	if current_hp <= 0:
		return
	
	_process_affixes(delta)


func _process_affixes(delta: float) -> void:
	for affix in affixes:
		match affix:
			EliteAffixSystem.EliteAffix.SHIELDED:
				_process_shield(delta)
			EliteAffixSystem.EliteAffix.ENRAGED:
				_process_enrage(delta)
			EliteAffixSystem.EliteAffix.TELEPORTER:
				_process_teleport(delta)
			EliteAffixSystem.EliteAffix.SUMMONER:
				_process_summoner(delta)
			EliteAffixSystem.EliteAffix.POISONOUS:
				_process_poison_trail(delta)
			EliteAffixSystem.EliteAffix.FROZEN:
				_process_frozen_aura(delta)
			EliteAffixSystem.EliteAffix.BERSERKER:
				_process_berserker()


func take_damage(amount: int) -> void:
	# Shield check
	if _shield_active and EliteAffixSystem.EliteAffix.SHIELDED in affixes:
		_shield_hp -= amount
		if _shield_hp <= 0:
			_shield_active = false
			sprite.modulate.a = 1.0
		return
	
	# Thorns
	if EliteAffixSystem.EliteAffix.THORNS in affixes:
		var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.THORNS)
		var reflect := int(amount * config.get("reflect_percent", 0.15))
		if reflect > 0:
			# Reflect damage to nearest player
			var nearest := _get_nearest_player()
			if nearest and nearest.has_method("take_damage"):
				nearest.take_damage(reflect)
	
	super.take_damage(amount)
	
	# Vampiric heal
	if EliteAffixSystem.EliteAffix.VAMPIRIC in affixes:
		var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.VAMPIRIC)
		var heal_amt := int(amount * config.get("lifesteal_percent", 0.2))
		current_hp = mini(current_hp + heal_amt, _get_max_hp())


func _on_death() -> void:
	# Explosive affix
	if EliteAffixSystem.EliteAffix.EXPLOSIVE in affixes:
		var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.EXPLOSIVE)
		var radius: float = config.get("explosion_radius", 64.0)
		var damage := int(_get_max_hp() * config.get("explosion_damage_percent", 0.5))
		
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(global_position) <= radius:
				if player.has_method("take_damage"):
					player.take_damage(damage)
		
		# Explosion visual
		var effect := Sprite2D.new()
		var img := Image.create(int(radius * 2), int(radius * 2), false, Image.FORMAT_RGBA8)
		img.fill(Color(1.0, 0.5, 0.0, 0.6))
		effect.texture = ImageTexture.create_from_image(img)
		effect.global_position = global_position
		get_parent().add_child(effect)
		
		var tween := effect.create_tween()
		tween.tween_property(effect, "scale", Vector2(1.5, 1.5), 0.3)
		tween.parallel().tween_property(effect, "modulate:a", 0.0, 0.3)
		tween.tween_callback(effect.queue_free)
	
	# Clean summons
	for s in _elite_summons:
		if is_instance_valid(s):
			s.queue_free()
	
	super._on_death()


# === Affix processors ===

func _process_shield(delta: float) -> void:
	if _shield_active:
		return
	
	var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.SHIELDED)
	_shield_cooldown -= delta
	if _shield_cooldown <= 0:
		_shield_active = true
		_shield_max = int(_get_max_hp() * config.get("shield_amount", 50) / 100.0)
		_shield_hp = _shield_max
		_shield_cooldown = config.get("shield_cooldown", 15.0)
		sprite.modulate = Color(0.5, 0.7, 1.0, 0.8)


func _process_enrage(delta: float) -> void:
	var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.ENRAGED)
	
	if _enrage_active:
		_enrage_timer -= delta
		if _enrage_timer <= 0:
			_enrage_active = false
			# Reset modifiers
			sprite.modulate = Color.WHITE
	else:
		_enrage_cooldown -= delta
		if _enrage_cooldown <= 0:
			_enrage_active = true
			_enrage_timer = config.get("enrage_duration", 5.0)
			_enrage_cooldown = config.get("enrage_cooldown", 20.0)
			sprite.modulate = Color(1.5, 0.5, 0.3)


func _process_teleport(delta: float) -> void:
	var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.TELEPORTER)
	_teleport_cooldown -= delta
	if _teleport_cooldown <= 0:
		_teleport_cooldown = config.get("teleport_cooldown", 8.0)
		var target := _get_nearest_player()
		if target:
			# Teleport a target közelébe
			var offset := Vector2(randf_range(-48, 48), randf_range(-48, 48))
			global_position = target.global_position + offset


func _process_summoner(delta: float) -> void:
	var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.SUMMONER)
	_summon_cooldown -= delta
	
	# Clean invalid summons
	_elite_summons = _elite_summons.filter(func(s): return is_instance_valid(s))
	
	if _summon_cooldown <= 0 and _elite_summons.size() < config.get("max_summons", 4):
		_summon_cooldown = config.get("summon_cooldown", 12.0)
		for i in config.get("summon_count", 2):
			_spawn_elite_minion(config, i)


func _spawn_elite_minion(config: Dictionary, index: int) -> void:
	var minion := EnemyBase.new()
	var data := EnemyData.new()
	data.enemy_name = "Summoned Minion"
	data.enemy_id = "elite_minion"
	data.enemy_category = Enums.EnemyType.SWARM
	data.base_hp = config.get("summon_hp", 15)
	data.base_damage = config.get("summon_damage", 5)
	data.base_speed = 60.0
	data.attack_range = 24.0
	data.detection_range = 200.0
	data.base_xp = 2
	data.sprite_color = Color(0.5, 0.3, 0.7)
	
	minion.enemy_data = data
	minion.enemy_level = enemy_level
	
	var offset := Vector2(cos(TAU * index / 2.0) * 32, sin(TAU * index / 2.0) * 32)
	minion.global_position = global_position + offset
	
	get_parent().add_child(minion)
	_elite_summons.append(minion)


func _process_poison_trail(delta: float) -> void:
	var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.POISONOUS)
	_trail_timer += delta
	if _trail_timer >= config.get("trail_interval", 1.0):
		_trail_timer = 0.0
		_spawn_poison_trail(config)


func _spawn_poison_trail(config: Dictionary) -> void:
	var pool := Area2D.new()
	pool.global_position = global_position
	pool.collision_layer = 0
	pool.collision_mask = 1 << (Constants.LAYER_PLAYER_PHYSICS - 1)
	pool.z_index = -1
	
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	pool.add_child(shape)
	
	var pool_sprite := Sprite2D.new()
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.2, 0.6, 0.1, 0.3))
	pool_sprite.texture = ImageTexture.create_from_image(img)
	pool.add_child(pool_sprite)
	
	get_parent().add_child(pool)
	
	# Damage on contact
	var dmg: float = config.get("trail_damage", 5.0)
	pool.body_entered.connect(func(body):
		if body.is_in_group("player") and body.has_method("take_damage"):
			body.take_damage(int(dmg))
	)
	
	# Auto-remove
	var timer := Timer.new()
	timer.wait_time = config.get("trail_duration", 3.0)
	timer.one_shot = true
	timer.autostart = true
	timer.timeout.connect(pool.queue_free)
	pool.add_child(timer)


func _process_frozen_aura(delta: float) -> void:
	var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.FROZEN)
	_frozen_aura_timer += delta
	if _frozen_aura_timer >= 1.0:
		_frozen_aura_timer = 0.0
		var radius: float = config.get("slow_aura_radius", 80.0)
		for player in get_tree().get_nodes_in_group("player"):
			if player.global_position.distance_to(global_position) <= radius:
				var sem := player.get_node_or_null("StatusEffectManager")
				if sem and sem is StatusEffectManager:
					var effect := StatusEffect.new()
					effect.effect_type = Enums.EffectType.SLOW
					effect.duration = 2.0
					sem.add_effect(effect)


func _process_berserker() -> void:
	var config := EliteAffixSystem.get_affix_config(EliteAffixSystem.EliteAffix.BERSERKER)
	var hp_pct := float(current_hp) / float(max(1, _get_max_hp()))
	if hp_pct <= config.get("threshold", 0.3):
		# Damage és speed boost
		sprite.modulate = Color(1.5, 0.3, 0.3)


func _get_nearest_player() -> Node:
	var nearest: Node = null
	var nearest_dist := 99999.0
	for player in get_tree().get_nodes_in_group("player"):
		var dist := global_position.distance_to(player.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = player
	return nearest


func _get_max_hp() -> int:
	if enemy_data:
		return DamageCalculator.scale_hp(enemy_data.base_hp, enemy_level)
	return 100

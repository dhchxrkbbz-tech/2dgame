## Player - Fő játékos karakter (CharacterBody2D)
## 8-irányú mozgás, Stardew Valley stílusú top-down nézet
extends CharacterBody2D

# === Statisztikák ===
@export var player_class: Enums.PlayerClass = Enums.PlayerClass.ASSASSIN

# Alap stat-ok (class alapján beállítva)
var max_hp: int = 80
var current_hp: int = 80
var max_mana: int = 60
var current_mana: int = 60
var base_damage: int = 12
var move_speed: float = 130.0
var armor: int = 5
var level: int = 1
var current_xp: int = 0
var skill_points: int = 0

# Crit stats
var crit_chance: float = 0.05
var crit_multiplier: float = 1.5

# Mana regen
var mana_regen_rate: float = 2.0  # per second
var mana_regen_timer: float = 0.0

# Combat state
var is_alive: bool = true
var is_attacking: bool = false
var is_dodging: bool = false
var is_invincible: bool = false
var can_act: bool = true
var dodge_cooldown_timer: float = 0.0  # Plan 21: dodge cooldown

# Combat components
var hitbox: HitboxComponent = null
var status_effects: StatusEffectManager = null

# Class system
var class_instance: ClassBase = null

# Irány tracking
var last_direction: Vector2 = Vector2.DOWN
var current_anim_direction: String = "south"

# Node referenciák
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var hurtbox: Area2D = $Hurtbox


func _ready() -> void:
	_init_stats()
	_setup_combat()
	GameManager.register_player(self)
	add_to_group("player")


func _init_stats() -> void:
	var stats: Dictionary = Constants.CLASS_BASE_STATS.get(player_class, {})
	if stats.is_empty():
		push_error("Player: Invalid class!")
		return
	
	max_hp = stats.get("hp", 80)
	current_hp = max_hp
	max_mana = stats.get("mana", 60)
	current_mana = max_mana
	base_damage = stats.get("base_damage", 12)
	move_speed = stats.get("speed", 130.0)
	armor = stats.get("armor", 5)
	crit_chance = stats.get("crit_chance", 0.05)
	crit_multiplier = stats.get("crit_multiplier", 1.5)
	
	# Mana regen class alapján (Plan 21 §2.6)
	match player_class:
		Enums.PlayerClass.ASSASSIN:
			mana_regen_rate = Constants.BASE_MANA_REGEN_ASSASSIN
		Enums.PlayerClass.TANK:
			mana_regen_rate = Constants.BASE_MANA_REGEN_TANK
		Enums.PlayerClass.MAGE:
			mana_regen_rate = Constants.BASE_MANA_REGEN_MAGE
	
	# Class instance létrehozás
	_init_class_instance()


func _init_class_instance() -> void:
	match player_class:
		Enums.PlayerClass.ASSASSIN:
			var assassin_cls = load("res://scripts/classes/assassin.gd")
			if assassin_cls:
				class_instance = assassin_cls.new(self)
		Enums.PlayerClass.TANK:
			var tank_cls = load("res://scripts/classes/tank.gd")
			if tank_cls:
				class_instance = tank_cls.new(self)
		Enums.PlayerClass.MAGE:
			var mage_cls = load("res://scripts/classes/mage.gd")
			if mage_cls:
				class_instance = mage_cls.new(self)


func _process_movement(_delta: float, speed_mult: float = 1.0) -> void:
	var direction := InputManager.move_direction
	
	if direction != Vector2.ZERO:
		last_direction = direction
		velocity = direction * move_speed * speed_mult
	else:
		velocity = velocity.move_toward(Vector2.ZERO, move_speed * 0.5)
	
	move_and_slide()
	
	# Sprite flip az X-tengely mentén (4 irányos sprite-hoz)
	_update_sprite_direction()


func _process_dodge(_delta: float) -> void:
	# Dodge közben fix irányba mozog
	velocity = last_direction * move_speed * Constants.DODGE_SPEED_MULTIPLIER
	move_and_slide()


func _update_sprite_direction() -> void:
	## 4 irányú sprite flip logika
	if last_direction.x < -0.1:
		sprite.flip_h = true
	elif last_direction.x > 0.1:
		sprite.flip_h = false
	
	# 4 irányos animáció név meghatározás
	if abs(last_direction.y) > abs(last_direction.x):
		current_anim_direction = "south" if last_direction.y > 0 else "north"
	else:
		current_anim_direction = "east"  # flip_h kezeli a west-et


func _update_animation() -> void:
	if not animation_player:
		return
	
	var anim_name: String
	
	if is_attacking:
		anim_name = "attack_" + current_anim_direction
	elif InputManager.is_moving():
		anim_name = "walk_" + current_anim_direction
	else:
		anim_name = "idle_" + current_anim_direction
	
	# Csak akkor váltson, ha más animáció kell
	if animation_player.has_animation(anim_name) and animation_player.current_animation != anim_name:
		animation_player.play(anim_name)


func _unhandled_input(event: InputEvent) -> void:
	if not is_alive or not can_act:
		return
	
	# Dodge / Roll (Plan 21: dodge cooldown)
	if event.is_action_pressed("dodge") and not is_dodging and dodge_cooldown_timer <= 0:
		_start_dodge()
	
	# Alap attack (LMB)
	if event.is_action_pressed("attack") and not is_attacking:
		_start_attack()
	
	# Skill használat (Plan 21 §5.1: 4 regular + 1 ultimate)
	if class_instance:
		if event.is_action_pressed("skill_1"):
			class_instance.use_skill(0)
		elif event.is_action_pressed("skill_2"):
			class_instance.use_skill(1)
		elif event.is_action_pressed("skill_3"):
			class_instance.use_skill(2)
		elif event.is_action_pressed("skill_4"):
			class_instance.use_skill(3)
		elif event.is_action_pressed("ultimate"):
			class_instance.use_ultimate()
	
	# Item pickup (E / interact)
	if event.is_action_pressed("interact"):
		_try_pickup_nearby_item()


func _start_dodge() -> void:
	is_dodging = true
	is_invincible = true
	
	# Dodge irány: ha mozog, abba az irányba, különben az utolsó irányba
	if InputManager.is_moving():
		last_direction = InputManager.move_direction
	
	# Dodge timer
	var dodge_timer := get_tree().create_timer(Constants.DODGE_DURATION)
	dodge_timer.timeout.connect(_end_dodge)


func _end_dodge() -> void:
	is_dodging = false
	is_invincible = false
	velocity = Vector2.ZERO
	dodge_cooldown_timer = Constants.DODGE_COOLDOWN  # Plan 21 §2.2: 0.8s cooldown


func _start_attack() -> void:
	is_attacking = true
	
	# Hitbox aktiválás az irány felé
	if hitbox:
		hitbox.activate(0.3, base_damage)
		# Hitbox pozicionálás a nézeti irány felé
		hitbox.position = last_direction * 20.0
	
	# Attack animáció timer
	var attack_timer := get_tree().create_timer(0.4)
	attack_timer.timeout.connect(_end_attack)


func _end_attack() -> void:
	is_attacking = false


# === Combat Setup ===

func _setup_combat() -> void:
	# Hitbox component
	hitbox = HitboxComponent.new()
	hitbox.collision_layer = Constants.COLLISION_LAYERS["player_hitbox"]
	hitbox.collision_mask = Constants.COLLISION_LAYERS["enemy_hurtbox"]
	hitbox.one_shot = false
	
	# Hitbox shape (méret class alapján)
	var hitbox_shape := CollisionShape2D.new()
	var shape := CircleShape2D.new()
	shape.radius = 16.0
	hitbox_shape.shape = shape
	hitbox.add_child(hitbox_shape)
	
	add_child(hitbox)
	hitbox.hit_landed.connect(_on_hit_landed)
	
	# Status effect manager
	status_effects = StatusEffectManager.new()
	add_child(status_effects)
	status_effects.effect_applied.connect(func(et): EventBus.status_effect_applied.emit(self, et, 0.0))
	status_effects.effect_removed.connect(func(et): EventBus.status_effect_removed.emit(self, et))


func _on_hit_landed(target: Node2D) -> void:
	if target.has_method("take_damage"):
		var result := DamageCalculator.calculate_damage(base_damage, 0, Enums.DamageType.PHYSICAL, crit_chance, crit_multiplier, 1.0)
		target.take_damage(result["damage"], Enums.DamageType.PHYSICAL)
		
		# Critical hit signal
		if result["is_crit"]:
			EventBus.critical_hit.emit(self, target, result["damage"])
		
		# Damage number megjelenítés
		if get_tree().current_scene.has_node("EffectLayer"):
			DamageNumber.spawn(
				get_tree().current_scene.get_node("EffectLayer"),
				target.global_position,
				result["damage"],
				result["is_crit"]
			)


# === HP kezelés ===

func take_damage(amount: float, damage_type: Enums.DamageType = Enums.DamageType.PHYSICAL) -> void:
	if not is_alive or is_invincible:
		return
	
	# Damage calculation armor-ral
	var effective_armor := armor
	if status_effects:
		effective_armor = int(effective_armor * (1.0 + status_effects.get_total_armor_modifier()))
	
	var result := DamageCalculator.calculate_damage(int(amount), effective_armor, damage_type, 0.0, 1.0, 0.0)
	var final_damage: int = result["damage"]
	
	current_hp -= final_damage
	current_hp = maxi(current_hp, 0)
	
	EventBus.damage_dealt.emit(null, self, final_damage, damage_type)
	EventBus.hud_update_requested.emit()
	
	# Damage number
	if get_tree().current_scene.has_node("EffectLayer"):
		DamageNumber.spawn(
			get_tree().current_scene.get_node("EffectLayer"),
			global_position,
			final_damage,
			false,
			damage_type
		)
	
	# Invincibility frames
	_start_iframes()
	
	if current_hp <= 0:
		_die()


func heal(amount: int) -> void:
	if not is_alive:
		return
	current_hp = mini(current_hp + amount, max_hp)
	EventBus.hud_update_requested.emit()


func _start_iframes() -> void:
	is_invincible = true
	invincibility_timer.start(Constants.IFRAMES_DURATION)
	# Vizuális feedback: villogás
	_flash_sprite()


func _on_invincibility_timer_timeout() -> void:
	is_invincible = false
	sprite.modulate = Color.WHITE


func _flash_sprite() -> void:
	## Sprite villogás a sérthetetlenség alatt
	var tween := create_tween()
	tween.set_loops(3)
	tween.tween_property(sprite, "modulate:a", 0.3, 0.05)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.05)


func _die() -> void:
	is_alive = false
	can_act = false
	velocity = Vector2.ZERO
	EventBus.player_died.emit(self)
	
	# Death animáció: fade out + collapse
	var death_tween := create_tween()
	death_tween.tween_property(sprite, "modulate", Color(0.5, 0.0, 0.0, 0.5), 0.5)
	death_tween.tween_property(sprite, "scale", Vector2(1.0, 0.3), 0.3)
	
	# Gold veszteség: 5% a jelenlegi gold-ból (Plan 21 §2.11)
	var gold_penalty := 0
	if has_node("/root/EconomyManager"):
		var currency_mgr = get_node("/root/EconomyManager").currency_manager
		if currency_mgr:
			gold_penalty = int(currency_mgr.get_gold() * Constants.DEATH_GOLD_PENALTY_PERCENT)
			if gold_penalty > 0:
				currency_mgr.spend_gold(gold_penalty)
				EventBus.show_notification.emit("Lost %d gold on death!" % gold_penalty, Enums.NotificationType.WARNING if "WARNING" in Enums.NotificationType else Enums.NotificationType.LEVEL_UP)
	
	# Respawn timer (Plan 21 §2.11)
	var respawn_timer := get_tree().create_timer(Constants.RESPAWN_TIMER)
	respawn_timer.timeout.connect(_respawn)


func _respawn() -> void:
	# Respawn: legutóbbi spawn pozíció vagy world origin
	var respawn_pos := Vector2.ZERO
	if GameManager.has_method("get_respawn_position"):
		respawn_pos = GameManager.get_respawn_position()
	
	global_position = respawn_pos
	
	# HP/Mana visszaállítás (Plan 21 §2.11: 50%)
	current_hp = int(max_hp * Constants.RESPAWN_HP_PERCENT)
	current_mana = int(max_mana * Constants.RESPAWN_MANA_PERCENT)
	
	# Állapot reset
	is_alive = true
	can_act = true
	is_attacking = false
	is_dodging = false
	is_invincible = false
	
	# Vizuális reset
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2.ONE
	
	# Rövid sérthetetlenség respawn után (Plan 21 §2.11)
	is_invincible = true
	var invuln_timer := get_tree().create_timer(Constants.RESPAWN_INVINCIBILITY_DURATION)
	invuln_timer.timeout.connect(func(): is_invincible = false)
	
	# Villogás jelzi a sérthetetlenséget
	var flash_tween := create_tween()
	flash_tween.set_loops(10)
	flash_tween.tween_property(sprite, "modulate:a", 0.4, 0.15)
	flash_tween.tween_property(sprite, "modulate:a", 1.0, 0.15)
	
	EventBus.hud_update_requested.emit()
	EventBus.show_notification.emit("Respawned!", Enums.NotificationType.LEVEL_UP)


# === Mana kezelés ===

func use_mana(amount: int) -> bool:
	if current_mana >= amount:
		current_mana -= amount
		EventBus.hud_update_requested.emit()
		return true
	return false


func restore_mana(amount: int) -> void:
	current_mana = mini(current_mana + amount, max_mana)
	EventBus.hud_update_requested.emit()


# === XP és Level ===

func gain_xp(amount: int) -> void:
	current_xp += amount
	EventBus.xp_gained.emit(self, amount)
	
	var xp_needed := Constants.get_xp_for_level(level + 1)
	while current_xp >= xp_needed and level < Constants.MAX_LEVEL:
		current_xp -= xp_needed
		_level_up()
		xp_needed = Constants.get_xp_for_level(level + 1)
	
	EventBus.hud_update_requested.emit()


func _level_up() -> void:
	level += 1
	
	# Stat növekedés class alapján
	var stats: Dictionary = Constants.CLASS_BASE_STATS.get(player_class, {})
	max_hp += Constants.HP_PER_LEVEL_BASE + int(stats.get("hp_per_level", 5))
	current_hp = max_hp  # Full heal level up-nál
	max_mana += Constants.MANA_PER_LEVEL_BASE + int(stats.get("mana_per_level", 3))
	current_mana = max_mana
	
	# Plan 21 §2.3: +3 stat points per level
	# stat_points += Constants.STAT_POINTS_PER_LEVEL  # TODO: stat allokáció UI
	
	# Plan 21 FIX #1: 1 skill point per level (Lv2-50 = 49 total)
	skill_points += Constants.SKILL_POINTS_PER_LEVEL
	if class_instance and class_instance.skill_manager:
		class_instance.skill_manager.available_skill_points = skill_points
	
	EventBus.player_leveled_up.emit(self, level)
	EventBus.show_notification.emit("Level Up! Level %d" % level, Enums.NotificationType.LEVEL_UP)


# === Item Pickup ===

func _try_pickup_nearby_item() -> void:
	var items := get_tree().get_nodes_in_group("dropped_items")
	var closest_item: Node2D = null
	var closest_dist: float = 48.0  # Pickup range
	
	for item in items:
		if not is_instance_valid(item):
			continue
		var dist := global_position.distance_to(item.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_item = item
	
	if closest_item and closest_item.has_method("pickup_requested"):
		closest_item.pickup_requested(self)


# === Status Effect kezelés ===

# === Consumable használat ===

func use_consumable(item: ItemInstance) -> bool:
	if not item or not item.base_item:
		return false
	if item.base_item.item_type != Enums.ItemType.CONSUMABLE:
		return false
	
	var item_id: String = item.base_item.item_id if item.base_item else ""
	
	# Potion effektek
	match item_id:
		"potion_hp_small":
			heal(50)
			EventBus.show_notification.emit("Healed 50 HP", Enums.NotificationType.LEVEL_UP)
		"potion_hp_medium":
			heal(150)
			EventBus.show_notification.emit("Healed 150 HP", Enums.NotificationType.LEVEL_UP)
		"potion_hp_large":
			heal(400)
			EventBus.show_notification.emit("Healed 400 HP", Enums.NotificationType.LEVEL_UP)
		"potion_hp_super":
			heal(max_hp)
			EventBus.show_notification.emit("Full HP Restored!", Enums.NotificationType.LEVEL_UP)
		"potion_mp_small":
			restore_mana(30)
			EventBus.show_notification.emit("Restored 30 Mana", Enums.NotificationType.LEVEL_UP)
		"potion_mp_medium":
			restore_mana(80)
			EventBus.show_notification.emit("Restored 80 Mana", Enums.NotificationType.LEVEL_UP)
		"potion_mp_large":
			restore_mana(200)
			EventBus.show_notification.emit("Restored 200 Mana", Enums.NotificationType.LEVEL_UP)
		"potion_mp_super":
			restore_mana(max_mana)
			EventBus.show_notification.emit("Full Mana Restored!", Enums.NotificationType.LEVEL_UP)
		"potion_fire_resist":
			if status_effects:
				var effect := StatusEffect.create(Enums.EffectType.ARMOR_UP, 120.0, 30.0, self)
				status_effects.apply_effect(effect)
			EventBus.show_notification.emit("+30% Fire Resistance (120s)", Enums.NotificationType.LEVEL_UP)
		"potion_ice_resist":
			if status_effects:
				var effect := StatusEffect.create(Enums.EffectType.ARMOR_UP, 120.0, 30.0, self)
				status_effects.apply_effect(effect)
			EventBus.show_notification.emit("+30% Ice Resistance (120s)", Enums.NotificationType.LEVEL_UP)
		"poison_coat_basic":
			if status_effects:
				var effect := StatusEffect.create(Enums.EffectType.DAMAGE_UP, 60.0, 15.0, self)
				status_effects.apply_effect(effect)
			EventBus.show_notification.emit("+15% Poison Damage (60s)", Enums.NotificationType.LEVEL_UP)
		"damage_scroll":
			if status_effects:
				var effect := StatusEffect.create(Enums.EffectType.DAMAGE_UP, 180.0, 20.0, self)
				status_effects.apply_effect(effect)
			EventBus.show_notification.emit("+20% Damage (180s)", Enums.NotificationType.LEVEL_UP)
		"defense_scroll":
			if status_effects:
				var effect := StatusEffect.create(Enums.EffectType.ARMOR_UP, 180.0, 25.0, self)
				status_effects.apply_effect(effect)
			EventBus.show_notification.emit("+25 Armor (180s)", Enums.NotificationType.LEVEL_UP)
		_:
			# Ismeretlen consumable - alap heal
			heal(20)
	
	# Mennyiség csökkentés inventory-ban
	if has_node("/root/EconomyManager"):
		var inv_mgr = get_node("/root/EconomyManager").inventory_manager
		if inv_mgr and item.base_item:
			inv_mgr.consume_item(item.base_item.item_id, 1)
	
	return true


# === Equipment stat alkalmazás (set bonus-szal) ===

func apply_equipment_stats() -> void:
	if not has_node("/root/EconomyManager"):
		return
	var inv_mgr = get_node("/root/EconomyManager").inventory_manager
	if not inv_mgr:
		return
	
	# Alap stat-ok class-ból
	_init_stats()
	
	# Level-alapú stat növekedés
	if level > 1:
		var stats: Dictionary = Constants.CLASS_BASE_STATS.get(player_class, {})
		max_hp += stats.get("hp_per_level", 5) * (level - 1)
		max_mana += stats.get("mana_per_level", 3) * (level - 1)
	
	# Equipment stat-ok összegyűjtése
	var equip_stats := inv_mgr.get_total_equipment_stats()
	for key in equip_stats:
		match key:
			"flat_damage":
				base_damage += int(equip_stats[key])
			"flat_hp", "max_hp":
				max_hp += int(equip_stats[key])
			"flat_armor", "armor":
				armor += int(equip_stats[key])
			"mana", "max_mana":
				max_mana += int(equip_stats[key])
			"move_speed", "movement_speed":
				move_speed += equip_stats[key]
	
	# Branch passive bonusok alkalmazása (Plan 21 §5.2)
	if class_instance:
		var branch_bonuses: Dictionary = class_instance.get_all_branch_passives()
		for key in branch_bonuses:
			match key:
				"crit_chance_bonus":
					crit_chance += branch_bonuses[key]
				"dodge_chance":
					pass  # Dodge chance handled in dodge logic
				"dot_damage_bonus", "dot_duration_bonus":
					pass  # Handled in damage_calculator
				"lifesteal_bonus":
					pass  # Handled in combat hit logic
				"hp_bonus_percent":
					max_hp = int(max_hp * (1.0 + branch_bonuses[key]))
				"armor_bonus_percent":
					armor = int(armor * (1.0 + branch_bonuses[key]))
				"block_chance_bonus":
					pass  # Handled in damage_calculator
				"threat_generation_bonus":
					pass  # Handled in threat/aggro system
				"reflect_damage_percent":
					pass  # Handled in hurtbox
				"hp_regen_bonus":
					pass  # Handled in regen tick
				"spell_damage_bonus":
					pass  # Handled in damage_calculator
				"mana_cost_reduction":
					pass  # Handled in skill_manager
				"slow_effectiveness", "freeze_duration_bonus":
					pass  # Handled in status_effect_manager
				"heal_power_bonus":
					pass  # Handled in healing calculations
				"shield_strength_bonus":
					pass  # Handled in health_component shield
	
	# Set bonus-ok keresése
	var equipped_sets: Dictionary = {}
	for slot in inv_mgr.equipment:
		var item: ItemInstance = inv_mgr.equipment[slot]
		if item and item.base_item and item.base_item.has_method("get_set_id"):
			var set_id: String = item.base_item.get_set_id()
			if not set_id.is_empty():
				equipped_sets[set_id] = equipped_sets.get(set_id, 0) + 1
		elif item and "set_id" in item and not item.set_id.is_empty():
			equipped_sets[item.set_id] = equipped_sets.get(item.set_id, 0) + 1
	
	# Set bonus stat-ok alkalmazása
	if not equipped_sets.is_empty():
		var active_bonuses := SetItemData.get_active_bonuses(equipped_sets)
		for bonus in active_bonuses:
			var stats: Dictionary = bonus.get("stats", {})
			for key in stats:
				match key:
					"stealth_duration", "stealth_damage", "poison_damage":
						pass  # Speciális kezelés a combat rendszerben
					"armor":
						armor += int(stats[key])
					"max_hp":
						max_hp += int(stats[key])
					"damage":
						base_damage += int(stats[key])
	
	# HP/Mana nem csökkenhet a max alá
	current_hp = mini(current_hp, max_hp)
	current_mana = mini(current_mana, max_mana)
	
	EventBus.hud_update_requested.emit()


func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# Dodge cooldown timer
	if dodge_cooldown_timer > 0:
		dodge_cooldown_timer -= delta
	
	# Mana regen (Plan 21 §2.6)
	if current_mana < max_mana:
		mana_regen_timer += delta
		if mana_regen_timer >= 1.0:
			mana_regen_timer -= 1.0
			restore_mana(int(mana_regen_rate))
	
	# Class system update
	if class_instance:
		class_instance.update(delta)
	
	# Status effect speed módosító
	var speed_mult := 1.0
	if status_effects:
		speed_mult = 1.0 + status_effects.get_total_speed_modifier()
		can_act = status_effects.can_act()
	
	# Weather gameplay módosító (move speed + damage)
	var weather_speed_mod := _get_weather_speed_modifier()
	speed_mult *= weather_speed_mod
	
	if not can_act:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if is_dodging:
		_process_dodge(delta)
		return
	
	_process_movement(delta, speed_mult)
	_update_animation()


## Weather rendszerből move speed módosító lekérdezése
func _get_weather_speed_modifier() -> float:
	# Próbáljuk a GameManager-ből lekérni a weather rendszert
	if GameManager.has_method("get_weather_system"):
		var weather_sys = GameManager.get_weather_system()
		if weather_sys and weather_sys.has_method("get_move_speed_modifier"):
			return weather_sys.get_move_speed_modifier()
	# Fallback: globális WeatherSystem keresése
	var weather_node = get_node_or_null("/root/WeatherSystem")
	if weather_node and weather_node.has_method("get_move_speed_modifier"):
		return weather_node.get_move_speed_modifier()
	return 1.0


## Weather damage módosító lekérdezése (combat-hoz)
func get_weather_damage_modifier() -> float:
	if GameManager.has_method("get_weather_system"):
		var weather_sys = GameManager.get_weather_system()
		if weather_sys:
			var mods := weather_sys.get_modifiers()
			return mods.get("damage", 1.0)
	var weather_node = get_node_or_null("/root/WeatherSystem")
	if weather_node and weather_node.has_method("get_modifiers"):
		var mods := weather_node.get_modifiers()
		return mods.get("damage", 1.0)
	return 1.0

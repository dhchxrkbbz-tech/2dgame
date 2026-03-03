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

# Combat state
var is_alive: bool = true
var is_attacking: bool = false
var is_dodging: bool = false
var is_invincible: bool = false
var can_act: bool = true

# Combat components
var hitbox: HitboxComponent = null
var status_effects: StatusEffectManager = null

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
	
	# Dodge / Roll
	if event.is_action_pressed("dodge") and not is_dodging:
		_start_dodge()
	
	# Alap attack (LMB)
	if event.is_action_pressed("attack") and not is_attacking:
		_start_attack()
	
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
		var result := DamageCalculator.calculate_damage(base_damage, 0, Enums.DamageType.PHYSICAL, 0.05, 1.5, 0.0)
		target.take_damage(result["damage"], Enums.DamageType.PHYSICAL)
		
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
	# TODO: Death animáció + respawn logika


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
	max_hp += stats.get("hp_per_level", 5)
	current_hp = max_hp  # Full heal level up-nál
	max_mana += stats.get("mana_per_level", 3)
	current_mana = max_mana
	
	# Skill pont minden 2. szinten
	if level % 2 == 0:
		skill_points += 1
	
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

func _physics_process(delta: float) -> void:
	if not is_alive:
		return
	
	# Status effect speed módosító
	var speed_mult := 1.0
	if status_effects:
		speed_mult = 1.0 + status_effects.get_total_speed_modifier()
		can_act = status_effects.can_act()
	
	if not can_act:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if is_dodging:
		_process_dodge(delta)
		return
	
	_process_movement(delta, speed_mult)
	_update_animation()

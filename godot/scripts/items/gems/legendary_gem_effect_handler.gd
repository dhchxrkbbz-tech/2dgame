## LegendaryGemEffectHandler - Legendary gem effektek futásidejű kezelése
## Figyeli az EventBus jelzéseket és aktiválja a megfelelő gem hatásokat
class_name LegendaryGemEffectHandler
extends Node

## Aktív legendary gem-ek nyilvántartása
var _active_gems: Array[Dictionary] = []
# [ { "gem_id": String, "data": LegendaryGemData, "cooldown_timer": float, "stacks": int } ]

## Tulajdonos player referencia
var _owner: Node = null


func _init(owner: Node = null) -> void:
	_owner = owner


func _ready() -> void:
	_connect_signals()


func _process(delta: float) -> void:
	_update_cooldowns(delta)
	_update_timed_effects(delta)


## Signálok bekötése
func _connect_signals() -> void:
	EventBus.entity_killed.connect(_on_entity_killed)
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.critical_hit.connect(_on_critical_hit)
	EventBus.player_died.connect(_on_player_died)


## Legendary gem regisztrálása (equip-kor)
func register_gem(gem: GemInstance) -> void:
	if not gem or not gem.is_legendary:
		return
	var data := LegendaryGemDatabase.get_gem(gem.legendary_id)
	if not data:
		return

	# Ne legyen duplikált
	for entry in _active_gems:
		if entry.gem_id == gem.legendary_id:
			return

	_active_gems.append({
		"gem_id": gem.legendary_id,
		"data": data,
		"cooldown_timer": 0.0,
		"stacks": 0,
		"effect_timer": 0.0,
		"active": false,
	})


## Legendary gem eltávolítása (unequip-kor)
func unregister_gem(gem_id: String) -> void:
	_active_gems = _active_gems.filter(func(e): return e.gem_id != gem_id)


## Összes gem eltávolítása
func clear_all() -> void:
	_active_gems.clear()


## Cooldown frissítés
func _update_cooldowns(delta: float) -> void:
	for entry in _active_gems:
		if entry.cooldown_timer > 0:
			entry.cooldown_timer -= delta


## Időzített effektek frissítése (pl. Devastation stackek lejárása)
func _update_timed_effects(delta: float) -> void:
	for entry in _active_gems:
		if entry.effect_timer > 0:
			entry.effect_timer -= delta
			if entry.effect_timer <= 0:
				entry.stacks = 0
				entry.active = false


## Cooldown ellenőrzés
func _is_on_cooldown(entry: Dictionary) -> bool:
	return entry.cooldown_timer > 0


## Cooldown indítása
func _start_cooldown(entry: Dictionary) -> void:
	var data: LegendaryGemData = entry.data
	if data.cooldown > 0:
		entry.cooldown_timer = data.cooldown


# ══════════════════════════════════════════════
# TRIGGER HANDLEREK
# ══════════════════════════════════════════════

## Entity megölése
func _on_entity_killed(killer: Node, _victim: Node) -> void:
	if killer != _owner:
		return

	for entry in _active_gems:
		if _is_on_cooldown(entry):
			continue
		var data: LegendaryGemData = entry.data
		if data.trigger != LegendaryGemData.EffectTrigger.ON_KILL:
			continue

		match entry.gem_id:
			"gem_of_devastation":
				_handle_devastation(entry)
			"gem_of_shadows":
				_handle_shadows(entry)


## Sebzés okozása (attack trigger)
func _on_damage_dealt(source: Node, target: Node, _amount: float, _type) -> void:
	if source != _owner:
		return

	for entry in _active_gems:
		if _is_on_cooldown(entry):
			continue
		var data: LegendaryGemData = entry.data
		if data.trigger != LegendaryGemData.EffectTrigger.ON_ATTACK:
			continue

		match entry.gem_id:
			"gem_of_chaos":
				_handle_chaos(entry, target)
			"gem_of_the_storm":
				_handle_storm(entry, target)


## Kritikus találat
func _on_critical_hit(source: Node, _target: Node, _amount: float) -> void:
	if source != _owner:
		return

	for entry in _active_gems:
		if _is_on_cooldown(entry):
			continue
		var data: LegendaryGemData = entry.data
		if data.trigger != LegendaryGemData.EffectTrigger.ON_CRIT:
			continue

		match entry.gem_id:
			"gem_of_the_leech":
				_handle_leech(entry)


## Player halál
func _on_player_died(player: Node) -> void:
	if player != _owner:
		return

	for entry in _active_gems:
		if _is_on_cooldown(entry):
			continue
		var data: LegendaryGemData = entry.data
		if data.trigger != LegendaryGemData.EffectTrigger.ON_DEATH:
			continue

		match entry.gem_id:
			"gem_of_resurrection":
				_handle_resurrection(entry)


# ══════════════════════════════════════════════
# EGYEDI GEM EFFEKT IMPLEMENTÁCIÓK
# ══════════════════════════════════════════════

## Gem of Devastation: +5% damage stack per kill (max 10×, 10s)
func _handle_devastation(entry: Dictionary) -> void:
	var params: Dictionary = entry.data.effect_params
	var max_stacks: int = params.get("max_stacks", 10)
	entry.stacks = mini(entry.stacks + 1, max_stacks)
	entry.effect_timer = params.get("duration", 10.0)
	entry.active = true
	# A tényleges damage bónusz a player stat rendszeren keresztül érvényesül


## Gem of Shadows: 2s invisibility on kill
func _handle_shadows(entry: Dictionary) -> void:
	var params: Dictionary = entry.data.effect_params
	entry.active = true
	entry.effect_timer = params.get("invisibility_duration", 2.0)
	_start_cooldown(entry)
	# Player invisibility aktiválás
	if _owner:
		# Vizuális: félig átlátszó
		if _owner.has_node("Sprite2D"):
			var sprite: Sprite2D = _owner.get_node("Sprite2D")
			var tween := _owner.create_tween()
			tween.tween_property(sprite, "modulate:a", 0.15, 0.2)
			tween.tween_interval(entry.effect_timer - 0.4)
			tween.tween_property(sprite, "modulate:a", 1.0, 0.2)
		# Collision: ellenségek nem látják
		if _owner.has_method("set_stealth"):
			_owner.set_stealth(true)
			var stealth_timer := _owner.get_tree().create_timer(entry.effect_timer)
			stealth_timer.timeout.connect(func(): 
				if is_instance_valid(_owner) and _owner.has_method("set_stealth"):
					_owner.set_stealth(false)
			)
		EventBus.show_notification.emit("Shadow Cloak activated!", Enums.NotificationType.LEVEL_UP)


## Gem of Chaos: 10% chance random elemental burst
func _handle_chaos(entry: Dictionary, target: Node) -> void:
	var params: Dictionary = entry.data.effect_params
	if randf() >= params.get("proc_chance", 0.10):
		return
	_start_cooldown(entry)
	# Elemental burst effekt spawning a target pozíciójánál
	if not target or not is_instance_valid(target):
		return
	var elements := [Enums.DamageType.FIRE, Enums.DamageType.ICE, Enums.DamageType.LIGHTNING, Enums.DamageType.POISON]
	var chosen_element: Enums.DamageType = elements[randi() % elements.size()]
	var burst_damage: float = params.get("burst_damage", 50.0)
	# AoE-ként hat a target körüli ellenségekre
	var aoe_radius: float = params.get("aoe_radius", 64.0)
	var enemies := target.get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.global_position.distance_to(target.global_position) <= aoe_radius:
			if enemy.has_method("take_damage"):
				enemy.take_damage(burst_damage, chosen_element)
	# Vizuális feedback - AOE effekt
	var aoe_scene := preload("res://scenes/effects/aoe_effect.tscn")
	if aoe_scene:
		var aoe := aoe_scene.instantiate()
		aoe.global_position = target.global_position
		target.get_tree().current_scene.add_child(aoe)
	EventBus.show_notification.emit("Chaos Burst!", Enums.NotificationType.LEVEL_UP)


## Gem of the Storm: 20% chain lightning
func _handle_storm(entry: Dictionary, target: Node) -> void:
	var params: Dictionary = entry.data.effect_params
	if randf() >= params.get("proc_chance", 0.20):
		return
	_start_cooldown(entry)
	# Chain lightning effekt: ugrik a közelben lévő ellenségekre
	if not target or not is_instance_valid(target):
		return
	var chain_count: int = params.get("chain_count", 3)
	var chain_range: float = params.get("chain_range", 96.0)
	var chain_damage: float = params.get("chain_damage", 30.0)
	var damage_decay: float = params.get("damage_decay", 0.8)  # Minden ugrásnál 80%-ra csökken
	var hit_targets: Array[Node] = [target]
	var current_target: Node = target
	var current_damage: float = chain_damage
	# Első target sebzés
	if current_target.has_method("take_damage"):
		current_target.take_damage(current_damage, Enums.DamageType.LIGHTNING)
	# Chain-ek
	for i in range(chain_count):
		current_damage *= damage_decay
		var enemies := current_target.get_tree().get_nodes_in_group("enemies")
		var closest_enemy: Node = null
		var closest_dist: float = chain_range
		for enemy in enemies:
			if not is_instance_valid(enemy) or enemy in hit_targets:
				continue
			var dist := enemy.global_position.distance_to(current_target.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_enemy = enemy
		if not closest_enemy:
			break
		hit_targets.append(closest_enemy)
		if closest_enemy.has_method("take_damage"):
			closest_enemy.take_damage(current_damage, Enums.DamageType.LIGHTNING)
		# Vizuális: projectile a két target között
		var proj_scene := preload("res://scenes/effects/projectile.tscn")
		if proj_scene and is_instance_valid(current_target):
			var proj := proj_scene.instantiate()
			proj.global_position = current_target.global_position
			current_target.get_tree().current_scene.add_child(proj)
		current_target = closest_enemy


## Gem of the Leech: crit → heal 5% max HP
func _handle_leech(entry: Dictionary) -> void:
	var params: Dictionary = entry.data.effect_params
	var heal_percent: float = params.get("heal_percent", 0.05)
	# Player max HP lekérdezés és heal alkalmazás
	if _owner and is_instance_valid(_owner):
		var max_hp: float = 100.0
		if "max_hp" in _owner:
			max_hp = float(_owner.max_hp)
		var heal_amount := int(max_hp * heal_percent)
		if _owner.has_method("heal"):
			_owner.heal(heal_amount)
		_start_cooldown(entry)


## Gem of Resurrection: revive on death
func _handle_resurrection(entry: Dictionary) -> void:
	var params: Dictionary = entry.data.effect_params
	var revive_hp: float = params.get("revive_hp_percent", 0.3)
	_start_cooldown(entry)
	# Player revive mechanika - megakadályozza a halált
	if _owner and is_instance_valid(_owner):
		# HP visszaállítás a revive százalékra
		var max_hp: float = 100.0
		if "max_hp" in _owner:
			max_hp = float(_owner.max_hp)
		var revive_amount := int(max_hp * revive_hp)
		
		# Állapot reset
		if "is_alive" in _owner:
			_owner.is_alive = true
		if "can_act" in _owner:
			_owner.can_act = true
		if "current_hp" in _owner:
			_owner.current_hp = revive_amount
		
		# Rövid sérthetetlenség (3s)
		if "is_invincible" in _owner:
			_owner.is_invincible = true
			var invuln_timer := _owner.get_tree().create_timer(3.0)
			invuln_timer.timeout.connect(func():
				if is_instance_valid(_owner) and "is_invincible" in _owner:
					_owner.is_invincible = false
			)
		
		# Vizuális: golden flash
		if _owner.has_node("Sprite2D"):
			var sprite: Sprite2D = _owner.get_node("Sprite2D")
			sprite.modulate = Color.WHITE
			sprite.scale = Vector2.ONE
			var tween := _owner.create_tween()
			tween.tween_property(sprite, "modulate", Color(1.0, 0.85, 0.0), 0.3)
			tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)
		
		EventBus.hud_update_requested.emit()
		EventBus.show_notification.emit("Resurrection Gem activated! Revived with %d%% HP!" % int(revive_hp * 100), Enums.NotificationType.LEVEL_UP)


# ══════════════════════════════════════════════
# LEKÉRDEZÉSEK (stat rendszer integrációhoz)
# ══════════════════════════════════════════════

## Devastation stack bónusz lekérdezése
func get_devastation_bonus() -> float:
	for entry in _active_gems:
		if entry.gem_id == "gem_of_devastation" and entry.active:
			var per_stack: float = entry.data.effect_params.get("damage_per_stack", 5.0)
			return entry.stacks * per_stack / 100.0
	return 0.0


## Fortitude aktív? (HP < 30%)
func is_fortitude_active(current_hp_ratio: float) -> bool:
	for entry in _active_gems:
		if entry.gem_id == "gem_of_fortitude":
			var threshold: float = entry.data.effect_params.get("hp_threshold", 0.3)
			return current_hp_ratio < threshold
	return false


## Fortitude damage reduction
func get_fortitude_reduction() -> float:
	for entry in _active_gems:
		if entry.gem_id == "gem_of_fortitude":
			if is_fortitude_active(0.0):  # A hívónak kell átadnia a valódi HP ratio-t
				return entry.data.effect_params.get("damage_reduction", 0.25)
	return 0.0


## Összes passzív stat bónusz (Greed, Vampirism, Colossus, Precision, Eternity)
func get_passive_stat_bonuses() -> Dictionary:
	var bonuses: Dictionary = {}
	for entry in _active_gems:
		var data: LegendaryGemData = entry.data
		if data.trigger == LegendaryGemData.EffectTrigger.PASSIVE:
			var stat_bonuses: Dictionary = data.get_stat_bonuses()
			for key in stat_bonuses:
				bonuses[key] = bonuses.get(key, 0.0) + stat_bonuses[key]
	return bonuses


## Thorns damage reflection lekérdezés
func get_thorns_reflect() -> float:
	for entry in _active_gems:
		if entry.gem_id == "gem_of_thorns":
			return entry.data.effect_params.get("reflect_percent", 0.15)
	return 0.0


## Van-e resurrection gem érvényes cooldown-nal?
func has_resurrection_available() -> bool:
	for entry in _active_gems:
		if entry.gem_id == "gem_of_resurrection" and not _is_on_cooldown(entry):
			return true
	return false

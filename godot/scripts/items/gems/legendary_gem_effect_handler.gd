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
	# TODO: Player invisibility aktiválás


## Gem of Chaos: 10% chance random elemental burst
func _handle_chaos(entry: Dictionary, target: Node) -> void:
	var params: Dictionary = entry.data.effect_params
	if randf() >= params.get("proc_chance", 0.10):
		return
	_start_cooldown(entry)
	# TODO: Elemental burst effekt spawning a target pozíciójánál


## Gem of the Storm: 20% chain lightning
func _handle_storm(entry: Dictionary, target: Node) -> void:
	var params: Dictionary = entry.data.effect_params
	if randf() >= params.get("proc_chance", 0.20):
		return
	_start_cooldown(entry)
	# TODO: Chain lightning effekt spawning


## Gem of the Leech: crit → heal 5% max HP
func _handle_leech(entry: Dictionary) -> void:
	var params: Dictionary = entry.data.effect_params
	var heal_percent: float = params.get("heal_percent", 0.05)
	# TODO: Player max HP lekérdezés és heal alkalmazás
	if _owner and _owner.has_method("heal"):
		var max_hp: float = _owner.get("max_hp") if _owner.get("max_hp") else 100.0
		_owner.call("heal", max_hp * heal_percent)


## Gem of Resurrection: revive on death
func _handle_resurrection(entry: Dictionary) -> void:
	var params: Dictionary = entry.data.effect_params
	var revive_hp: float = params.get("revive_hp_percent", 0.3)
	_start_cooldown(entry)
	# TODO: Player revive mechanika


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

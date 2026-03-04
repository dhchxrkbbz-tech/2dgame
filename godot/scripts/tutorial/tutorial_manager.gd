## TutorialManager - Tutorial és onboarding rendszer (Autoload singleton)
## Felelős: trigger tracking, first-time detection, popup megjelenítés,
## kontextus-érzékeny tippek, tutorial állapot mentés/betöltés
extends Node

# =============================================================================
#  SIGNALS
# =============================================================================
signal tutorial_shown(trigger_id: String)
signal tutorial_dismissed(trigger_id: String)
signal all_tutorials_completed()

# =============================================================================
#  ÁLLAPOT
# =============================================================================
## Már látott tutorial trigger-ek (mentődik)
var tutorials_seen: Dictionary = {}

## Tutorial popup-ok engedélyezve (Settings-ből állítható)
var tutorials_enabled: bool = true

## Kontextus tipp cooldown-ok (nem mentődik)
var _context_cooldowns: Dictionary = {}

## Aktuálisan megjelenített popup referencia
var _current_popup: Control = null

## Várakozó tutorial queue (combat közben halasztás)
var _tutorial_queue: Array[String] = []

## Combat állapot követés
var _is_in_combat: bool = false

## Player referencia (mozgás detekció)
var _player_ref: Node = null
var _player_has_moved: bool = false

## Tutorial overlay CanvasLayer
var _canvas_layer: CanvasLayer = null


# =============================================================================
#  INICIALIZÁLÁS
# =============================================================================
func _ready() -> void:
	_setup_canvas_layer()
	_connect_signals()


func _setup_canvas_layer() -> void:
	_canvas_layer = CanvasLayer.new()
	_canvas_layer.layer = 95  # SceneManager (100) alatt, de gameplay felett
	_canvas_layer.name = "TutorialOverlay"
	add_child(_canvas_layer)


func _connect_signals() -> void:
	# === Player események ===
	EventBus.player_spawned.connect(_on_player_spawned)
	EventBus.player_died.connect(_on_player_died)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.player_skill_unlocked.connect(_on_player_skill_unlocked)
	
	# === Combat események ===
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.entity_killed.connect(_on_entity_killed)
	EventBus.critical_hit.connect(_on_critical_hit)
	EventBus.skill_used.connect(_on_skill_used)
	
	# === Loot események ===
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.gold_collected.connect(_on_gold_collected)
	EventBus.item_equipped.connect(_on_item_equipped)
	
	# === Dungeon események ===
	EventBus.dungeon_entered.connect(_on_dungeon_entered)
	EventBus.boss_fight_started.connect(_on_boss_fight_started)
	
	# === Világ események ===
	EventBus.biome_entered.connect(_on_biome_entered)
	EventBus.gathering_started.connect(_on_gathering_started)
	EventBus.weather_changed.connect(_on_weather_changed)
	
	# === Quest események ===
	EventBus.quest_accepted.connect(_on_quest_accepted)
	
	# === Economy események ===
	EventBus.item_sold.connect(_on_item_sold)
	EventBus.crafting_completed.connect(_on_crafting_completed)
	EventBus.enhancement_attempted.connect(_on_enhancement_attempted)
	
	# === Gem események ===
	EventBus.gem_picked_up.connect(_on_gem_picked_up)
	EventBus.gem_socketed.connect(_on_gem_socketed)
	
	# === UI események ===
	EventBus.screen_opened.connect(_on_screen_opened)
	EventBus.inventory_full.connect(_on_inventory_full)
	
	# === Multiplayer ===
	EventBus.player_connected.connect(_on_player_connected)


func _process(delta: float) -> void:
	# Mozgás detekció tutorial auto-dismiss-hez
	_check_player_movement()
	
	# Kontextus tipp cooldown-ok frissítése
	_update_context_cooldowns(delta)
	
	# Queue feldolgozás (ha nincs combat és van várakozó)
	if not _is_in_combat and not _tutorial_queue.is_empty() and _current_popup == null:
		var next_id := _tutorial_queue.pop_front() as String
		_show_popup(next_id)


# =============================================================================
#  FŐ API
# =============================================================================

## Tutorial megjelenítése ha még nem látta a játékos
func show_tutorial_if_new(trigger_id: String) -> bool:
	if not tutorials_enabled:
		return false
	if trigger_id in tutorials_seen:
		return false
	
	# Megjelöljük látottnak
	tutorials_seen[trigger_id] = true
	
	# Combat közben queue-ba tesszük (nem zavarjuk a harcot)
	var tutorial_content := TutorialData.get_tutorial(trigger_id)
	var priority: int = tutorial_content.get("priority", 5)
	
	if _is_in_combat and priority < 8:
		_tutorial_queue.append(trigger_id)
		return true
	
	_show_popup(trigger_id)
	tutorial_shown.emit(trigger_id)
	return true


## Kontextus-érzékeny tipp megjelenítése (cooldown-nal)
func show_contextual_tip(tip_id: String) -> bool:
	if not tutorials_enabled:
		return false
	
	# Cooldown ellenőrzés
	if tip_id in _context_cooldowns and _context_cooldowns[tip_id] > 0.0:
		return false
	
	var tip_content := TutorialData.get_tutorial(tip_id)
	if tip_content.is_empty():
		return false
	
	# Cooldown beállítás
	var cooldown: float = tip_content.get("cooldown", 60.0)
	_context_cooldowns[tip_id] = cooldown
	
	_show_popup(tip_id)
	return true


## Minden tutorial resetelése (development / settings)
func reset_all_tutorials() -> void:
	tutorials_seen.clear()
	_context_cooldowns.clear()
	_tutorial_queue.clear()
	print("TutorialManager: All tutorials reset")


## Tutorial skip (tapasztalt játékos) - mindent megjelöl látottnak
func skip_all_tutorials() -> void:
	for trigger_id in TutorialData.get_all_trigger_ids():
		tutorials_seen[trigger_id] = true
	print("TutorialManager: All tutorials skipped")


## Aktuális popup bezárása
func dismiss_current() -> void:
	if _current_popup and is_instance_valid(_current_popup):
		var trigger_id: String = _current_popup.get_meta("trigger_id", "")
		_current_popup.dismiss()
		_current_popup = null
		tutorial_dismissed.emit(trigger_id)


# =============================================================================
#  POPUP MEGJELENÍTÉS
# =============================================================================

func _show_popup(trigger_id: String) -> void:
	var content := TutorialData.get_tutorial(trigger_id)
	if content.is_empty():
		push_warning("TutorialManager: No content for trigger: " + trigger_id)
		return
	
	# Ha van aktív popup, előbb bezárjuk (vagy queue-ba tesszük)
	if _current_popup and is_instance_valid(_current_popup):
		# Ha az új fontosabb, lecseréljük
		var current_priority: int = _current_popup.get_meta("priority", 0)
		var new_priority: int = content.get("priority", 5)
		if new_priority <= current_priority:
			_tutorial_queue.append(trigger_id)
			return
		_current_popup.dismiss()
	
	# Popup létrehozása
	var popup := TutorialPopup.new()
	popup.setup(trigger_id, content)
	popup.set_meta("trigger_id", trigger_id)
	popup.set_meta("priority", content.get("priority", 5))
	popup.popup_dismissed.connect(_on_popup_dismissed)
	
	_canvas_layer.add_child(popup)
	_current_popup = popup
	
	# Auto-dismiss: ha a tartalom „auto_dismiss_on" mezőt tartalmaz
	if content.has("auto_dismiss_on"):
		_setup_auto_dismiss(content["auto_dismiss_on"])


func _on_popup_dismissed() -> void:
	_current_popup = null
	# Következő a queue-ból
	if not _tutorial_queue.is_empty():
		# Kis késleltetés a következő popup előtt
		get_tree().create_timer(0.5).timeout.connect(func():
			if not _tutorial_queue.is_empty() and _current_popup == null:
				var next_id := _tutorial_queue.pop_front() as String
				_show_popup(next_id)
		)
	else:
		# Ellenőrizzük, hogy minden tutorial kész-e
		_check_all_completed()


func _setup_auto_dismiss(condition: String) -> void:
	match condition:
		"player_moved":
			_player_has_moved = false
			# A _process-ben figyeljük


func _check_player_movement() -> void:
	if _current_popup == null:
		return
	if not _current_popup.has_meta("trigger_id"):
		return
	if _current_popup.get_meta("trigger_id") != TutorialData.FIRST_MOVEMENT:
		return
	
	if _player_ref and is_instance_valid(_player_ref):
		if _player_ref.velocity.length() > 0.1:
			if not _player_has_moved:
				_player_has_moved = true
				# Kis késleltetés, aztán dismiss
				get_tree().create_timer(1.0).timeout.connect(func():
					if _current_popup and _current_popup.get_meta("trigger_id", "") == TutorialData.FIRST_MOVEMENT:
						dismiss_current()
				)


func _update_context_cooldowns(delta: float) -> void:
	for key in _context_cooldowns:
		if _context_cooldowns[key] > 0.0:
			_context_cooldowns[key] -= delta


func _check_all_completed() -> void:
	var all_ids := TutorialData.get_all_trigger_ids()
	for trigger_id in all_ids:
		if trigger_id not in tutorials_seen:
			return
	all_tutorials_completed.emit()


# =============================================================================
#  SIGNAL HANDLEREK - Automatikus trigger detekció
# =============================================================================

func _on_player_spawned(player) -> void:
	_player_ref = player
	_is_in_combat = false
	# Első tutorial: mozgás (kis késleltetéssel, hadd nézze körbe)
	get_tree().create_timer(1.5).timeout.connect(func():
		show_tutorial_if_new(TutorialData.FIRST_MOVEMENT)
	)


func _on_player_died(_player) -> void:
	show_tutorial_if_new(TutorialData.FIRST_DEATH)


func _on_player_leveled_up(_player, _new_level: int) -> void:
	show_tutorial_if_new(TutorialData.FIRST_LEVEL_UP)


func _on_player_skill_unlocked(_player, _skill_id: String) -> void:
	# Skill use tutorial-hoz: rövid delay
	get_tree().create_timer(2.0).timeout.connect(func():
		show_tutorial_if_new(TutorialData.FIRST_SKILL_USE)
	)


func _on_damage_dealt(source, target, _amount: float, _damage_type) -> void:
	_is_in_combat = true
	
	# Első combat detekció
	if source and source.is_in_group("player"):
		show_tutorial_if_new(TutorialData.FIRST_COMBAT)
	
	# Első sérülés (játékos kapja)
	if target and target.is_in_group("player"):
		show_tutorial_if_new(TutorialData.FIRST_DAMAGE_TAKEN)
	
	# Alacsony HP kontextus tipp
	if target and target.is_in_group("player") and target.has_method("get_health_percent"):
		if target.get_health_percent() < 0.3:
			show_contextual_tip(TutorialData.CONTEXT_LOW_HP)


func _on_entity_killed(_killer, victim) -> void:
	if victim and victim.is_in_group("enemy"):
		show_tutorial_if_new(TutorialData.FIRST_ENEMY_KILL)
		
		# Elite detekció
		if victim.has_method("is_elite") or (victim.get("is_elite") == true):
			show_tutorial_if_new(TutorialData.FIRST_ELITE_ENEMY)
	
	# Combat állapot: kis késleltetéssel peace
	get_tree().create_timer(3.0).timeout.connect(func():
		_is_in_combat = false
	)


func _on_critical_hit(_source, _target, _amount: float) -> void:
	# Nincs külön tutorial, de lehetne
	pass


func _on_skill_used(_player, _skill_id: String) -> void:
	show_tutorial_if_new(TutorialData.FIRST_SKILL_USE)


func _on_item_picked_up(_item_instance) -> void:
	show_tutorial_if_new(TutorialData.FIRST_ITEM_PICKUP)
	
	# TODO: Rare item detekció (ha van rarity info)
	# if _item_instance.rarity >= Enums.ItemRarity.RARE:
	#     show_tutorial_if_new(TutorialData.FIRST_RARE_ITEM)


func _on_gold_collected(_amount: int) -> void:
	# Gold pickup-hoz nem kell külön tutorial
	pass


func _on_item_equipped(_player, _item_data, _slot) -> void:
	show_tutorial_if_new(TutorialData.FIRST_EQUIPMENT)


func _on_dungeon_entered(_dungeon_data: Dictionary) -> void:
	show_tutorial_if_new(TutorialData.FIRST_DUNGEON_ENTER)


func _on_boss_fight_started(_boss_id: String) -> void:
	show_tutorial_if_new(TutorialData.FIRST_BOSS_FIGHT)


func _on_biome_entered(_player, _biome: Enums.BiomeType) -> void:
	show_tutorial_if_new(TutorialData.FIRST_BIOME_TRANSITION)


func _on_gathering_started(_node_type) -> void:
	show_tutorial_if_new(TutorialData.FIRST_GATHERING)


func _on_weather_changed(_weather) -> void:
	pass


func _on_quest_accepted(_quest_id: String) -> void:
	show_tutorial_if_new(TutorialData.FIRST_QUEST_ACCEPT)


func _on_item_sold(_player, _item_data: Dictionary, _price: int) -> void:
	show_tutorial_if_new(TutorialData.FIRST_SHOP_VISIT)


func _on_crafting_completed(_recipe_id: String, _success: bool) -> void:
	show_tutorial_if_new(TutorialData.FIRST_CRAFTING)


func _on_enhancement_attempted(_item_uuid: String, _level: int, _success: bool) -> void:
	show_tutorial_if_new(TutorialData.FIRST_ENHANCEMENT)


func _on_gem_picked_up(_gem_instance) -> void:
	show_tutorial_if_new(TutorialData.FIRST_GEM_FOUND)


func _on_gem_socketed(_item_uuid: String, _gem_type) -> void:
	show_tutorial_if_new(TutorialData.FIRST_GEM_SOCKET)


func _on_screen_opened(screen_name: String) -> void:
	match screen_name:
		"inventory":
			show_tutorial_if_new(TutorialData.FIRST_INVENTORY_OPEN)
		"skill_tree":
			show_tutorial_if_new(TutorialData.FIRST_SKILL_TREE_OPEN)
		"map":
			show_tutorial_if_new(TutorialData.FIRST_MAP_OPEN)


func _on_inventory_full() -> void:
	show_contextual_tip(TutorialData.CONTEXT_FULL_INVENTORY)


func _on_player_connected(_peer_id: int) -> void:
	show_tutorial_if_new(TutorialData.FIRST_MULTIPLAYER)


# =============================================================================
#  MENTÉS / BETÖLTÉS (SaveManager integráció)
# =============================================================================

## Szerializáció mentéshez
func serialize() -> Dictionary:
	return {
		"tutorials_seen": tutorials_seen.duplicate(),
		"tutorials_enabled": tutorials_enabled,
	}


## Deserializáció betöltéshez
func deserialize(data: Dictionary) -> void:
	if data.has("tutorials_seen"):
		tutorials_seen = data["tutorials_seen"]
	if data.has("tutorials_enabled"):
		tutorials_enabled = data["tutorials_enabled"]
	print("TutorialManager: Loaded %d seen tutorials" % tutorials_seen.size())

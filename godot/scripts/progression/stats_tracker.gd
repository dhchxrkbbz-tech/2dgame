## StatsTracker - Játékos statisztikák nyilvántartása (Autoload singleton)
## Trackeli a combat, economy, exploration és multiplayer statokat
extends Node

# === Statisztika tároló ===
var _stats: Dictionary = {}

# === Unique set-ek (ismétlődés nélkül) ===
var _unique_sets: Dictionary = {}  # "bosses_killed" → ["boss_1", "boss_2", ...]


func _ready() -> void:
	_init_default_stats()
	_connect_signals()
	print("StatsTracker: Inicializálva")


# ==========================================================================
#  ALAPÉRTELMEZETT STATOK
# ==========================================================================

func _init_default_stats() -> void:
	# Combat
	_set_default("total_enemies_killed", 0)
	_set_default("total_bosses_killed", 0)
	_set_default("total_elite_killed", 0)
	_set_default("total_damage_dealt", 0)
	_set_default("total_damage_taken", 0)
	_set_default("total_deaths", 0)
	_set_default("highest_combo", 0)
	_set_default("fastest_dungeon_clear", 0.0)
	_set_default("most_kills_session", 0)
	_set_default("total_critical_hits", 0)
	_set_default("boss_no_hit_kills", 0)
	
	# Economy
	_set_default("total_gold_earned", 0)
	_set_default("total_gold_spent", 0)
	_set_default("total_items_crafted", 0)
	_set_default("total_resources_gathered", 0)
	_set_default("total_marketplace_sales", 0)
	_set_default("total_marketplace_purchases", 0)
	_set_default("total_enhancements_attempted", 0)
	_set_default("total_enhancements_succeeded", 0)
	_set_default("total_gems_combined", 0)
	
	# Exploration
	_set_default("chunks_explored", 0)
	_set_default("biomes_discovered", 0)
	_set_default("dungeons_completed", 0)
	_set_default("secret_rooms_found", 0)
	_set_default("pois_discovered", 0)
	_set_default("waypoints_activated", 0)
	_set_default("chests_opened", 0)
	_set_default("night_chunks_explored", 0)
	_set_default("weather_types_seen", 0)
	
	# Loot
	_set_default("rare_items_found", 0)
	_set_default("epic_items_found", 0)
	_set_default("legendary_items_found", 0)
	_set_default("gem_types_collected", 0)
	_set_default("total_items_picked_up", 0)
	
	# Progression
	_set_default("total_skill_points_spent", 0)
	_set_default("achievements_unlocked", 0)
	_set_default("world_events_participated", 0)
	
	# Multiplayer
	_set_default("total_coop_sessions", 0)
	_set_default("total_healing_done_to_others", 0)
	_set_default("total_coop_boss_kills", 0)
	
	# Session
	_set_default("total_play_time", 0.0)  # Másodpercben
	_set_default("session_kills", 0)
	
	# Unique sets
	_unique_sets["unique_bosses_killed"] = []
	_unique_sets["unique_biomes_visited"] = []
	_unique_sets["unique_weather_seen"] = []
	_unique_sets["unique_npcs_talked"] = []
	_unique_sets["unique_gem_types"] = []


func _set_default(stat_name: String, default_value) -> void:
	if not _stats.has(stat_name):
		_stats[stat_name] = default_value


# ==========================================================================
#  SIGNAL CSATLAKOZÁSOK
# ==========================================================================

func _connect_signals() -> void:
	# Combat
	EventBus.entity_killed.connect(_on_entity_killed)
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.player_died.connect(_on_player_died)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.critical_hit.connect(_on_critical_hit)
	
	# Economy
	EventBus.gold_collected.connect(_on_gold_collected)
	EventBus.item_sold.connect(_on_item_sold)
	EventBus.item_bought.connect(_on_item_bought)
	EventBus.crafting_completed.connect(_on_crafting_completed)
	EventBus.enhancement_attempted.connect(_on_enhancement_attempted)
	EventBus.gem_combined.connect(_on_gem_combined)
	EventBus.marketplace_listing_sold.connect(_on_marketplace_sold)
	
	# Exploration
	EventBus.chunk_loaded.connect(_on_chunk_loaded)
	EventBus.biome_entered.connect(_on_biome_entered)
	EventBus.dungeon_exited.connect(_on_dungeon_completed)
	EventBus.dungeon_secret_room_found.connect(_on_secret_room_found)
	EventBus.dungeon_chest_opened.connect(_on_chest_opened)
	EventBus.weather_changed.connect(_on_weather_changed)
	
	# Loot
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.gem_picked_up.connect(_on_gem_picked_up)
	
	# Gathering
	EventBus.gathering_completed.connect(_on_gathering_completed)
	
	# Progression
	EventBus.skill_point_allocated.connect(_on_skill_allocated)
	
	# Waypoints
	EventBus.waypoint_discovered.connect(_on_waypoint_discovered)
	
	# Multiplayer
	EventBus.player_connected.connect(_on_player_connected)
	
	# Dialogue
	EventBus.dialogue_started.connect(_on_dialogue_started)
	
	# World events
	EventBus.world_event_ended.connect(_on_world_event_ended)


# ==========================================================================
#  STAT KEZELÉS API
# ==========================================================================

## Stat lekérdezés
func get_stat(stat_name: String) -> Variant:
	return _stats.get(stat_name, 0)


## Stat beállítás fix értékre
func set_stat(stat_name: String, value: Variant) -> void:
	_stats[stat_name] = value
	EventBus.stat_updated.emit(stat_name, value)


## Stat növelés
func increment_stat(stat_name: String, amount: int = 1) -> void:
	if not _stats.has(stat_name):
		_stats[stat_name] = 0
	_stats[stat_name] += amount
	EventBus.stat_updated.emit(stat_name, _stats[stat_name])


## Stat max értéke (ha az új érték nagyobb, felülírjuk)
func update_max(stat_name: String, value) -> void:
	if not _stats.has(stat_name) or value > _stats[stat_name]:
		_stats[stat_name] = value
		EventBus.stat_updated.emit(stat_name, value)


## Unique set hozzáadás (nem duplikál)
func add_unique(set_name: String, entry: String) -> int:
	if not _unique_sets.has(set_name):
		_unique_sets[set_name] = []
	if entry not in _unique_sets[set_name]:
		_unique_sets[set_name].append(entry)
	return _unique_sets[set_name].size()


## Unique set méret lekérdezés
func get_unique_count(set_name: String) -> int:
	if not _unique_sets.has(set_name):
		return 0
	return _unique_sets[set_name].size()


# ==========================================================================
#  EVENT HANDLER-EK
# ==========================================================================

func _on_entity_killed(_killer, victim) -> void:
	increment_stat("total_enemies_killed", 1)
	increment_stat("session_kills", 1)
	
	# Session most kills frissítés
	update_max("most_kills_session", get_stat("session_kills"))
	
	# Elite tracking
	if victim and victim.has_method("get_enemy_type"):
		if victim.get_enemy_type() == Enums.EnemyType.ELITE:
			increment_stat("total_elite_killed", 1)


func _on_damage_dealt(source, _target, amount: float, _dtype) -> void:
	if source == GameManager.player:
		increment_stat("total_damage_dealt", int(amount))
	elif _target == GameManager.player:
		increment_stat("total_damage_taken", int(amount))


func _on_player_died(_player) -> void:
	increment_stat("total_deaths", 1)


func _on_boss_defeated(boss_id: String) -> void:
	increment_stat("total_bosses_killed", 1)
	var unique_count := add_unique("unique_bosses_killed", boss_id)
	set_stat("unique_boss_kills", unique_count)


func _on_critical_hit(_source, _target, _amount: float) -> void:
	increment_stat("total_critical_hits", 1)


func _on_gold_collected(amount: int) -> void:
	increment_stat("total_gold_earned", amount)


func _on_item_sold(_player, _item_data: Dictionary, price: int) -> void:
	increment_stat("total_gold_earned", price)


func _on_item_bought(_player, _item_data: Dictionary, price: int) -> void:
	increment_stat("total_gold_spent", price)


func _on_crafting_completed(_recipe_id: String, success: bool) -> void:
	if success:
		increment_stat("total_items_crafted", 1)


func _on_enhancement_attempted(_item_uuid: String, _level: int, success: bool) -> void:
	increment_stat("total_enhancements_attempted", 1)
	if success:
		increment_stat("total_enhancements_succeeded", 1)


func _on_gem_combined(_gem_type: Enums.GemType, _tier: Enums.GemTier) -> void:
	increment_stat("total_gems_combined", 1)


func _on_marketplace_sold(_listing_id: String) -> void:
	increment_stat("total_marketplace_sales", 1)


func _on_chunk_loaded(_chunk_pos: Vector2i) -> void:
	increment_stat("chunks_explored", 1)


func _on_biome_entered(_player, biome: Enums.BiomeType) -> void:
	var count := add_unique("unique_biomes_visited", str(biome))
	set_stat("biomes_discovered", count)


func _on_dungeon_completed() -> void:
	increment_stat("dungeons_completed", 1)


func _on_secret_room_found(_room_index: int) -> void:
	increment_stat("secret_rooms_found", 1)


func _on_chest_opened(_chest_data: Dictionary) -> void:
	increment_stat("chests_opened", 1)


func _on_weather_changed(weather: Enums.WeatherType) -> void:
	var count := add_unique("unique_weather_seen", str(weather))
	set_stat("weather_types_seen", count)


func _on_item_picked_up(item_instance) -> void:
	increment_stat("total_items_picked_up", 1)
	
	# Rarity tracking
	var rarity: int = -1
	if item_instance is Dictionary:
		rarity = item_instance.get("rarity", -1)
	elif item_instance and item_instance.has_method("get_rarity"):
		rarity = item_instance.get_rarity()
	
	if rarity >= Enums.Rarity.RARE:
		increment_stat("rare_items_found", 1)
	if rarity >= Enums.Rarity.EPIC:
		increment_stat("epic_items_found", 1)
	if rarity >= Enums.Rarity.LEGENDARY:
		increment_stat("legendary_items_found", 1)


func _on_gem_picked_up(gem_instance: RefCounted) -> void:
	if gem_instance and gem_instance.has_method("get_gem_type"):
		var count := add_unique("unique_gem_types", str(gem_instance.get_gem_type()))
		set_stat("gem_types_collected", count)


func _on_gathering_completed(_node_type: Enums.GatheringNodeType, yield_amount: int) -> void:
	increment_stat("total_resources_gathered", yield_amount)


func _on_skill_allocated(_skill_id: String, _new_rank: int) -> void:
	increment_stat("total_skill_points_spent", 1)


func _on_waypoint_discovered(_wp_id: String, _wp_name: String) -> void:
	increment_stat("waypoints_activated", 1)


func _on_player_connected(_peer_id: int) -> void:
	increment_stat("total_coop_sessions", 1)


func _on_dialogue_started(npc_id: String) -> void:
	var count := add_unique("unique_npcs_talked", npc_id)
	set_stat("unique_npcs_talked", count)


func _on_world_event_ended(_event_type: int, _rewards: Dictionary) -> void:
	increment_stat("world_events_participated", 1)


# ==========================================================================
#  PLAY TIME TRACKING
# ==========================================================================

func _process(delta: float) -> void:
	if GameManager.is_playing():
		_stats["total_play_time"] = _stats.get("total_play_time", 0.0) + delta


## Játékidő formázott szöveg
func get_formatted_play_time() -> String:
	var total_seconds: float = _stats.get("total_play_time", 0.0)
	var hours: int = int(total_seconds) / 3600
	var minutes: int = (int(total_seconds) % 3600) / 60
	var seconds: int = int(total_seconds) % 60
	return "%dh %dm %ds" % [hours, minutes, seconds]


# ==========================================================================
#  UI LEKÉRDEZÉS
# ==========================================================================

## Összes stat visszaadása kategóriánként
func get_all_stats() -> Dictionary:
	return {
		"combat": {
			"Total Enemies Killed": get_stat("total_enemies_killed"),
			"Total Bosses Killed": get_stat("total_bosses_killed"),
			"Total Elite Killed": get_stat("total_elite_killed"),
			"Total Damage Dealt": get_stat("total_damage_dealt"),
			"Total Damage Taken": get_stat("total_damage_taken"),
			"Total Deaths": get_stat("total_deaths"),
			"Highest Combo": get_stat("highest_combo"),
			"Fastest Dungeon Clear": _format_time(get_stat("fastest_dungeon_clear")),
			"Most Kills (Session)": get_stat("most_kills_session"),
			"Total Critical Hits": get_stat("total_critical_hits"),
		},
		"economy": {
			"Total Gold Earned": get_stat("total_gold_earned"),
			"Total Gold Spent": get_stat("total_gold_spent"),
			"Total Items Crafted": get_stat("total_items_crafted"),
			"Total Resources Gathered": get_stat("total_resources_gathered"),
			"Total Marketplace Sales": get_stat("total_marketplace_sales"),
			"Enhancements Attempted": get_stat("total_enhancements_attempted"),
			"Enhancements Succeeded": get_stat("total_enhancements_succeeded"),
			"Total Gems Combined": get_stat("total_gems_combined"),
		},
		"exploration": {
			"Chunks Explored": get_stat("chunks_explored"),
			"Biomes Discovered": "%d / 8" % get_stat("biomes_discovered"),
			"Dungeons Completed": get_stat("dungeons_completed"),
			"Secret Rooms Found": get_stat("secret_rooms_found"),
			"POIs Discovered": get_stat("pois_discovered"),
			"Waypoints Activated": get_stat("waypoints_activated"),
			"Chests Opened": get_stat("chests_opened"),
		},
		"loot": {
			"Total Items Picked Up": get_stat("total_items_picked_up"),
			"Rare Items Found": get_stat("rare_items_found"),
			"Epic Items Found": get_stat("epic_items_found"),
			"Legendary Items Found": get_stat("legendary_items_found"),
			"Gem Types Collected": "%d / 6" % get_stat("gem_types_collected"),
		},
		"multiplayer": {
			"Co-op Sessions": get_stat("total_coop_sessions"),
			"Healing Done (Others)": get_stat("total_healing_done_to_others"),
			"Co-op Boss Kills": get_stat("total_coop_boss_kills"),
		},
		"general": {
			"Total Play Time": get_formatted_play_time(),
			"Achievements Unlocked": get_stat("achievements_unlocked"),
			"World Events Participated": get_stat("world_events_participated"),
			"Skill Points Spent": get_stat("total_skill_points_spent"),
		},
	}


func _format_time(seconds: float) -> String:
	if seconds <= 0:
		return "N/A"
	var mins: int = int(seconds) / 60
	var secs: int = int(seconds) % 60
	return "%d:%02d" % [mins, secs]


# ==========================================================================
#  SESSION KEZELÉS
# ==========================================================================

## Session reset (új session indításakor)
func reset_session_stats() -> void:
	_stats["session_kills"] = 0


# ==========================================================================
#  MENTÉS / BETÖLTÉS
# ==========================================================================

func serialize() -> Dictionary:
	var data: Dictionary = {
		"stats": _stats.duplicate(),
		"unique_sets": {},
	}
	for set_name in _unique_sets:
		data["unique_sets"][set_name] = _unique_sets[set_name].duplicate()
	return data


func deserialize(data: Dictionary) -> void:
	if data.has("stats"):
		for key in data["stats"]:
			_stats[key] = data["stats"][key]
	
	if data.has("unique_sets"):
		for set_name in data["unique_sets"]:
			_unique_sets[set_name] = data["unique_sets"][set_name]
	
	print("StatsTracker: %d statisztika betöltve" % _stats.size())

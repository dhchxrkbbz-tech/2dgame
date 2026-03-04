## EndgameManager - Nightmare szintek, Paragon rendszer, difficulty scaling (Autoload singleton)
## Level 50 utáni endgame progresszió: Paragon pontok, Nightmare dungeon tier-ek
extends Node

# === Paragon rendszer ===
var paragon_level: int = 0
var paragon_xp: int = 0
var paragon_xp_to_next: int = 0

## Paragon stat bónuszok (felhalmozott)
var paragon_bonus_hp: int = 0
var paragon_bonus_damage: float = 0.0
var paragon_bonus_magic_find: float = 0.0

# === Nightmare rendszer ===
var current_nightmare_tier: Enums.NightmareTier = Enums.NightmareTier.NORMAL
var highest_nightmare_completed: int = 0  # Legmagasabb teljesített tier
var nightmare_keys: Dictionary = {}  # tier → darabszám

# === Difficulty ===
var current_difficulty: Enums.DifficultyLevel = Enums.DifficultyLevel.NORMAL
var is_new_game_plus: bool = false
var ng_plus_count: int = 0  # Hányadik NG+

# === Dungeon stats (per run) ===
var _dungeon_start_time: float = 0.0
var _dungeon_deaths: int = 0
var _dungeon_hits_taken: int = 0


func _ready() -> void:
	_connect_signals()
	print("EndgameManager: Inicializálva")


func _connect_signals() -> void:
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.xp_gained.connect(_on_xp_gained)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.dungeon_entered.connect(_on_dungeon_entered)
	EventBus.dungeon_exited.connect(_on_dungeon_exited)
	EventBus.player_died.connect(_on_player_died)
	EventBus.damage_dealt.connect(_on_damage_to_player)


# ==========================================================================
#  PARAGON RENDSZER
# ==========================================================================

## XP kezelés Level 50 felett
func _on_xp_gained(_player, amount: int) -> void:
	if not _is_max_level():
		return
	
	_add_paragon_xp(amount)


func _is_max_level() -> bool:
	var player := GameManager.player
	if not player:
		return false
	if player.has_method("get_level"):
		return player.get_level() >= Constants.MAX_LEVEL
	return false


func _add_paragon_xp(amount: int) -> void:
	paragon_xp += amount
	
	# XP requirement kiszámítása
	paragon_xp_to_next = _get_paragon_xp_requirement(paragon_level + 1)
	
	while paragon_xp >= paragon_xp_to_next:
		paragon_xp -= paragon_xp_to_next
		paragon_level += 1
		_apply_paragon_level_bonus()
		
		EventBus.paragon_level_gained.emit(paragon_level)
		
		EventBus.show_notification.emit(
			"PARAGON LEVEL %d!" % paragon_level,
			Enums.NotificationType.LEVEL_UP
		)
		
		# Achievement tracking
		if has_node("/root/AchievementManager"):
			AchievementManager.set_progress("paragon_level_reached", paragon_level)
		
		paragon_xp_to_next = _get_paragon_xp_requirement(paragon_level + 1)
		
		print("EndgameManager: Paragon Level %d elérve" % paragon_level)


## Paragon szinthez szükséges XP
func _get_paragon_xp_requirement(level: int) -> int:
	# Alap XP requirement = Level 50 XP, lassan növekszik
	var base := Constants.get_xp_for_level(Constants.MAX_LEVEL)
	return int(base * (1.0 + level * 0.1))


## Paragon szint bónusz alkalmazása
func _apply_paragon_level_bonus() -> void:
	# +1 HP minden szintért
	paragon_bonus_hp += Constants.PARAGON_HP_PER_POINT
	
	# +0.5% damage minden 10. szintért
	if paragon_level % 10 == 0:
		paragon_bonus_damage += Constants.PARAGON_DAMAGE_PER_10_POINTS
	
	# +0.3% magic find minden 5. szintért
	if paragon_level % 5 == 0:
		paragon_bonus_magic_find += Constants.PARAGON_MAGIC_FIND_PER_5_POINTS


## Teljes paragon stat bónuszok lekérdezése
func get_paragon_bonuses() -> Dictionary:
	return {
		"bonus_hp": paragon_bonus_hp,
		"bonus_damage_percent": paragon_bonus_damage,
		"bonus_magic_find_percent": paragon_bonus_magic_find,
		"paragon_level": paragon_level,
	}


# ==========================================================================
#  NIGHTMARE DUNGEON RENDSZER
# ==========================================================================

## Nightmare kulcs hozzáadása (boss loot)
func add_nightmare_key(tier: int) -> void:
	if not nightmare_keys.has(tier):
		nightmare_keys[tier] = 0
	nightmare_keys[tier] += 1
	print("EndgameManager: Nightmare Key (Tier %d) szerzett – összesen: %d" % [
		tier, nightmare_keys[tier]
	])


## Van-e nightmare kulcs adott tierhez?
func has_nightmare_key(tier: int) -> bool:
	return nightmare_keys.get(tier, 0) > 0


## Nightmare kulcs felhasználása
func use_nightmare_key(tier: int) -> bool:
	if not has_nightmare_key(tier):
		return false
	nightmare_keys[tier] -= 1
	if nightmare_keys[tier] <= 0:
		nightmare_keys.erase(tier)
	return true


## Nightmare dungeon belépés
func enter_nightmare_dungeon(tier: int) -> bool:
	if tier < 1 or tier > 5:
		push_warning("EndgameManager: Invalid nightmare tier: %d" % tier)
		return false
	
	if not use_nightmare_key(tier):
		EventBus.show_notification.emit(
			"Nightmare Key (Tier %d) szükséges!" % tier,
			Enums.NotificationType.WARNING
		)
		return false
	
	current_nightmare_tier = tier as Enums.NightmareTier
	EventBus.nightmare_tier_changed.emit(tier)
	
	print("EndgameManager: Nightmare %d dungeon elindítva" % tier)
	return true


## Nightmare scaling lekérdezés
func get_nightmare_scaling() -> Dictionary:
	var tier: int = current_nightmare_tier
	if tier <= 0:
		return {"enemy_hp": 0.0, "enemy_damage": 0.0, "magic_find": 0.0}
	return Constants.NIGHTMARE_SCALING.get(tier, {"enemy_hp": 0.0, "enemy_damage": 0.0, "magic_find": 0.0})


## Enemy HP szorzó (1.0 + bonus)
func get_enemy_hp_multiplier() -> float:
	var scaling := get_nightmare_scaling()
	var base := 1.0 + scaling.get("enemy_hp", 0.0)
	
	# Difficulty szorzó
	base *= _get_difficulty_multiplier("hp")
	
	# NG+ szorzó
	if is_new_game_plus:
		base *= 1.0 + (ng_plus_count * 0.5)
	
	return base


## Enemy damage szorzó
func get_enemy_damage_multiplier() -> float:
	var scaling := get_nightmare_scaling()
	var base := 1.0 + scaling.get("enemy_damage", 0.0)
	
	base *= _get_difficulty_multiplier("damage")
	
	if is_new_game_plus:
		base *= 1.0 + (ng_plus_count * 0.5)
	
	return base


## Magic find bónusz
func get_magic_find_bonus() -> float:
	var scaling := get_nightmare_scaling()
	var base := scaling.get("magic_find", 0.0)
	
	base += _get_difficulty_loot_bonus()
	base += paragon_bonus_magic_find
	
	return base


## Difficulty szorzó helper
func _get_difficulty_multiplier(stat_type: String) -> float:
	match current_difficulty:
		Enums.DifficultyLevel.HARD:
			return 1.3 if stat_type == "hp" else 1.3
		Enums.DifficultyLevel.NIGHTMARE:
			return 1.6 if stat_type == "hp" else 1.6
		Enums.DifficultyLevel.TORMENT:
			return 2.0 if stat_type == "hp" else 2.0
		_:
			return 1.0


func _get_difficulty_loot_bonus() -> float:
	match current_difficulty:
		Enums.DifficultyLevel.HARD:
			return 0.20
		Enums.DifficultyLevel.NIGHTMARE:
			return 0.40
		Enums.DifficultyLevel.TORMENT:
			return 0.60
		_:
			return 0.0


# ==========================================================================
#  NEW GAME+
# ==========================================================================

## NG+ indítása
func start_new_game_plus() -> void:
	is_new_game_plus = true
	ng_plus_count += 1
	
	EventBus.show_notification.emit(
		"NEW GAME+ (%d) ELINDULT!" % ng_plus_count,
		Enums.NotificationType.INFO
	)
	
	print("EndgameManager: New Game+ #%d elindítva" % ng_plus_count)


## Nehézség beállítása
func set_difficulty(difficulty: Enums.DifficultyLevel) -> void:
	current_difficulty = difficulty
	print("EndgameManager: Nehézség → %s" % Enums.DifficultyLevel.keys()[difficulty])


# ==========================================================================
#  EVENT HANDLER-EK
# ==========================================================================

func _on_player_leveled_up(_player, _new_level: int) -> void:
	pass  # Paragon XP a _on_xp_gained-ben kezelődik


func _on_boss_defeated(boss_id: String) -> void:
	# Nightmare key drop esély boss-oknál
	if current_nightmare_tier >= Enums.NightmareTier.NORMAL:
		var key_tier: int = mini(int(current_nightmare_tier) + 1, 5)
		var drop_chance := 0.5  # 50% esély
		if randf() < drop_chance:
			add_nightmare_key(key_tier)
			EventBus.show_notification.emit(
				"Nightmare Key (Tier %d) szerzett!" % key_tier,
				Enums.NotificationType.LOOT
			)
	
	# Achievement: nightmare completion tracking
	if current_nightmare_tier > Enums.NightmareTier.NORMAL:
		if int(current_nightmare_tier) > highest_nightmare_completed:
			highest_nightmare_completed = int(current_nightmare_tier)
		
		if has_node("/root/AchievementManager"):
			AchievementManager.set_progress(
				"nightmare_completed",
				highest_nightmare_completed
			)


func _on_dungeon_entered(_dungeon_data: Dictionary) -> void:
	_dungeon_start_time = Time.get_ticks_msec() / 1000.0
	_dungeon_deaths = 0
	_dungeon_hits_taken = 0


func _on_dungeon_exited() -> void:
	var clear_time := (Time.get_ticks_msec() / 1000.0) - _dungeon_start_time
	
	# Speed demon achievement
	if clear_time <= 300.0 and has_node("/root/AchievementManager"):
		AchievementManager.update_progress("dungeon_clear_time", 1)
	
	# No death achievement
	if _dungeon_deaths == 0 and has_node("/root/AchievementManager"):
		AchievementManager.update_progress("dungeon_no_death", 1)
	
	# Stats tracking
	if has_node("/root/StatsTracker"):
		var best: float = StatsTracker.get_stat("fastest_dungeon_clear")
		if best <= 0 or clear_time < best:
			StatsTracker.set_stat("fastest_dungeon_clear", clear_time)
	
	# Nightmare tier reset
	current_nightmare_tier = Enums.NightmareTier.NORMAL


func _on_player_died(_player) -> void:
	_dungeon_deaths += 1


func _on_damage_to_player(_source, target, _amount: float, _damage_type) -> void:
	if target == GameManager.player:
		_dungeon_hits_taken += 1


# ==========================================================================
#  MENTÉS / BETÖLTÉS
# ==========================================================================

func serialize() -> Dictionary:
	return {
		"paragon_level": paragon_level,
		"paragon_xp": paragon_xp,
		"paragon_bonus_hp": paragon_bonus_hp,
		"paragon_bonus_damage": paragon_bonus_damage,
		"paragon_bonus_magic_find": paragon_bonus_magic_find,
		"highest_nightmare_completed": highest_nightmare_completed,
		"nightmare_keys": nightmare_keys.duplicate(),
		"current_difficulty": current_difficulty,
		"is_new_game_plus": is_new_game_plus,
		"ng_plus_count": ng_plus_count,
	}


func deserialize(data: Dictionary) -> void:
	paragon_level = data.get("paragon_level", 0)
	paragon_xp = data.get("paragon_xp", 0)
	paragon_bonus_hp = data.get("paragon_bonus_hp", 0)
	paragon_bonus_damage = data.get("paragon_bonus_damage", 0.0)
	paragon_bonus_magic_find = data.get("paragon_bonus_magic_find", 0.0)
	highest_nightmare_completed = data.get("highest_nightmare_completed", 0)
	nightmare_keys = data.get("nightmare_keys", {})
	current_difficulty = data.get("current_difficulty", Enums.DifficultyLevel.NORMAL)
	is_new_game_plus = data.get("is_new_game_plus", false)
	ng_plus_count = data.get("ng_plus_count", 0)
	
	paragon_xp_to_next = _get_paragon_xp_requirement(paragon_level + 1)
	
	print("EndgameManager: Betöltve – Paragon %d, Nightmare %d, NG+ %s (%d)" % [
		paragon_level, highest_nightmare_completed,
		"IGEN" if is_new_game_plus else "NEM", ng_plus_count
	])

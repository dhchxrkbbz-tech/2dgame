## AudioManager - Teljes hang kezelés (Autoload singleton)
## Zene crossfade, SFX pool, spatial audio, ambient, UI, dinamikus zene rendszer
## Biome → zene mapping, combat/boss zene triggerek
extends Node

# =============================================================================
#  HANGERŐ BEÁLLÍTÁSOK
# =============================================================================
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var ambient_volume: float = 0.6
var ui_volume: float = 0.9

# =============================================================================
#  ZENE RENDSZER
# =============================================================================
# Két player a crossfade-hez
var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer
var _current_music_path: String = ""
var _music_crossfade_tween: Tween = null

# Dinamikus zene állapot
enum MusicState { NONE, EXPLORATION, COMBAT, BOSS, DUNGEON, MENU, VICTORY }
var _music_state: MusicState = MusicState.NONE
var _exploration_music_path: String = ""  # Visszatérésre mentjük
var _previous_music_state: MusicState = MusicState.NONE

# =============================================================================
#  SFX POOL
# =============================================================================
const MAX_SFX_PLAYERS: int = 20
var _sfx_pool: Array[AudioStreamPlayer] = []

# =============================================================================
#  UI SFX POOL (külön bus, nem kever a combat/skill SFX-ekkel)
# =============================================================================
const MAX_UI_SFX_PLAYERS: int = 5
var _ui_sfx_pool: Array[AudioStreamPlayer] = []

# =============================================================================
#  AMBIENT RENDSZER
# =============================================================================
var _ambient_player_a: AudioStreamPlayer
var _ambient_player_b: AudioStreamPlayer
var _active_ambient_player: AudioStreamPlayer
var _current_ambient_path: String = ""
var _ambient_crossfade_tween: Tween = null

# Kiegészítő ambient layer (pl. eső, szél az alap biome ambient fölött)
var _weather_ambient_player: AudioStreamPlayer
var _current_weather_ambient: String = ""

# =============================================================================
#  STREAM CACHE - preloaded streams elkerülik az ismételt load()-ot
# =============================================================================
var _stream_cache: Dictionary = {}
const MAX_CACHE_SIZE: int = 50

# =============================================================================
#  BIOME TRACKING
# =============================================================================
var _current_biome: Enums.BiomeType = Enums.BiomeType.STARTING_MEADOW
var _is_in_dungeon: bool = false
var _is_in_combat: bool = false
var _is_boss_fight: bool = false


# =============================================================================
#  INICIALIZÁLÁS
# =============================================================================
func _ready() -> void:
	_setup_music_players()
	_setup_sfx_pool()
	_setup_ui_sfx_pool()
	_setup_ambient_players()
	_connect_signals()
	
	# Audio bus-ok inicializálás (ha léteznek)
	_init_audio_buses()


func _setup_music_players() -> void:
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.bus = "Music"
	_music_player_a.name = "MusicPlayerA"
	add_child(_music_player_a)
	
	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.bus = "Music"
	_music_player_b.name = "MusicPlayerB"
	add_child(_music_player_b)
	
	_active_music_player = _music_player_a


func _setup_sfx_pool() -> void:
	for i in MAX_SFX_PLAYERS:
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		sfx_player.name = "SFXPlayer_%d" % i
		add_child(sfx_player)
		_sfx_pool.append(sfx_player)


func _setup_ui_sfx_pool() -> void:
	for i in MAX_UI_SFX_PLAYERS:
		var ui_player := AudioStreamPlayer.new()
		ui_player.bus = "UI"
		ui_player.name = "UISFXPlayer_%d" % i
		add_child(ui_player)
		_ui_sfx_pool.append(ui_player)


func _setup_ambient_players() -> void:
	_ambient_player_a = AudioStreamPlayer.new()
	_ambient_player_a.bus = "Ambient"
	_ambient_player_a.name = "AmbientPlayerA"
	add_child(_ambient_player_a)
	
	_ambient_player_b = AudioStreamPlayer.new()
	_ambient_player_b.bus = "Ambient"
	_ambient_player_b.name = "AmbientPlayerB"
	add_child(_ambient_player_b)
	
	_active_ambient_player = _ambient_player_a
	
	# Időjárás ambient player
	_weather_ambient_player = AudioStreamPlayer.new()
	_weather_ambient_player.bus = "Ambient"
	_weather_ambient_player.name = "WeatherAmbientPlayer"
	add_child(_weather_ambient_player)


func _init_audio_buses() -> void:
	# Ellenőrizzük, hogy léteznek-e a buszok, ha nem, warning
	for bus_name in ["Music", "SFX", "Ambient", "UI"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			push_warning("AudioManager: Audio bus '%s' not found! Add default_bus_layout.tres." % bus_name)


# =============================================================================
#  SIGNAL CSATLAKOZÁSOK - Dinamikus zene rendszer
# =============================================================================
func _connect_signals() -> void:
	# Biome → zene/ambient váltás
	EventBus.biome_entered.connect(_on_biome_entered)
	
	# Combat → combat zene
	# CombatManager közvetlenül hívja az AudioManager-t, de EventBus-on is hallgatjuk
	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.entity_killed.connect(_on_entity_killed)
	
	# Boss → boss zene
	EventBus.boss_fight_started.connect(_on_boss_fight_started)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	
	# Dungeon
	EventBus.dungeon_entered.connect(_on_dungeon_entered)
	EventBus.dungeon_exited.connect(_on_dungeon_exited)
	
	# Időjárás → ambient layer
	EventBus.weather_changed.connect(_on_weather_changed)
	
	# Day/night → ambient módosítás
	EventBus.day_night_changed.connect(_on_day_night_changed)
	
	# Player események
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.player_died.connect(_on_player_died)
	EventBus.critical_hit.connect(_on_critical_hit)
	
	# Loot események
	EventBus.item_picked_up.connect(_on_item_picked_up)
	EventBus.gold_collected.connect(_on_gold_collected)
	
	# Quest események
	EventBus.quest_accepted.connect(_on_quest_accepted)
	EventBus.quest_completed.connect(_on_quest_completed)
	
	# Inventory/equipment
	EventBus.item_equipped.connect(_on_item_equipped)
	EventBus.inventory_changed.connect(_on_inventory_changed)
	
	# Skill tree
	EventBus.skill_point_allocated.connect(_on_skill_point_allocated)
	
	# Crafting
	EventBus.crafting_completed.connect(_on_crafting_completed)
	EventBus.crafting_failed.connect(_on_crafting_failed)
	
	# Gem
	EventBus.gem_socketed.connect(_on_gem_socketed)
	
	# Dungeon environment
	EventBus.dungeon_chest_opened.connect(_on_chest_opened)
	EventBus.dungeon_trap_triggered.connect(_on_trap_triggered)
	EventBus.dungeon_secret_room_found.connect(_on_secret_room_found)
	
	# Enhancement
	EventBus.enhancement_attempted.connect(_on_enhancement_attempted)
	
	# Gathering
	EventBus.gathering_started.connect(_on_gathering_started)
	EventBus.gathering_completed.connect(_on_gathering_completed)
	
	# UI események
	EventBus.screen_opened.connect(_on_screen_opened)
	EventBus.screen_closed.connect(_on_screen_closed)
	EventBus.show_notification.connect(_on_notification_shown)


# =============================================================================
#  ZENE LEJÁTSZÁS (crossfade támogatás)
# =============================================================================
func play_music(music_path: String, crossfade_duration: float = 1.0) -> void:
	if music_path.is_empty():
		return
	if music_path == _current_music_path:
		return
	
	var stream := _load_stream(music_path)
	if not stream:
		push_warning("AudioManager: Music not found: " + music_path)
		return
	
	_current_music_path = music_path
	
	# Előző crossfade leállítása
	if _music_crossfade_tween and _music_crossfade_tween.is_valid():
		_music_crossfade_tween.kill()
	
	var old_player := _active_music_player
	var new_player := _music_player_b if _active_music_player == _music_player_a else _music_player_a
	_active_music_player = new_player
	
	new_player.stream = stream
	new_player.volume_db = -80.0
	new_player.play()
	
	# Crossfade tween
	_music_crossfade_tween = create_tween()
	_music_crossfade_tween.set_parallel(true)
	_music_crossfade_tween.tween_property(old_player, "volume_db", -80.0, crossfade_duration)
	_music_crossfade_tween.tween_property(new_player, "volume_db", linear_to_db(music_volume), crossfade_duration)
	_music_crossfade_tween.finished.connect(func(): old_player.stop())


func stop_music(fade_duration: float = 0.5) -> void:
	_current_music_path = ""
	
	if _music_crossfade_tween and _music_crossfade_tween.is_valid():
		_music_crossfade_tween.kill()
	
	var tween := create_tween()
	tween.tween_property(_active_music_player, "volume_db", -80.0, fade_duration)
	tween.finished.connect(func(): _active_music_player.stop())


## Instant stop (boss intro rumble előtt, victory fanfare előtt)
func stop_music_instant() -> void:
	_current_music_path = ""
	if _music_crossfade_tween and _music_crossfade_tween.is_valid():
		_music_crossfade_tween.kill()
	_music_player_a.stop()
	_music_player_b.stop()


# =============================================================================
#  SFX LEJÁTSZÁS
# =============================================================================
func play_sfx(sfx_path: String, volume: float = 1.0) -> void:
	if sfx_path.is_empty():
		return
	var stream := _load_stream(sfx_path)
	if not stream:
		push_warning("AudioManager: SFX not found: " + sfx_path)
		return
	
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume * volume)
			player.play()
			return
	
	push_warning("AudioManager: SFX pool exhausted!")


func play_sfx_at_position(sfx_path: String, position: Vector2, volume: float = 1.0) -> void:
	if sfx_path.is_empty():
		return
	var stream := _load_stream(sfx_path)
	if not stream:
		return
	
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume * volume)
	player.global_position = position
	player.bus = "SFX"
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


## Randomizált pitch SFX (változatosabb hangzás)
func play_sfx_random_pitch(sfx_path: String, volume: float = 1.0, pitch_min: float = 0.9, pitch_max: float = 1.1) -> void:
	if sfx_path.is_empty():
		return
	var stream := _load_stream(sfx_path)
	if not stream:
		return
	
	for player in _sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume * volume)
			player.pitch_scale = randf_range(pitch_min, pitch_max)
			player.play()
			# Reset pitch after playing
			player.finished.connect(func(): player.pitch_scale = 1.0, CONNECT_ONE_SHOT)
			return


## Randomizált pozíciós SFX
func play_sfx_at_position_random_pitch(sfx_path: String, position: Vector2, volume: float = 1.0, pitch_min: float = 0.9, pitch_max: float = 1.1) -> void:
	if sfx_path.is_empty():
		return
	var stream := _load_stream(sfx_path)
	if not stream:
		return
	
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume * volume)
	player.pitch_scale = randf_range(pitch_min, pitch_max)
	player.global_position = position
	player.bus = "SFX"
	player.finished.connect(player.queue_free)
	add_child(player)
	player.play()


# =============================================================================
#  UI SFX LEJÁTSZÁS (külön bus)
# =============================================================================
func play_ui_sfx(sfx_path: String, volume: float = 1.0) -> void:
	if sfx_path.is_empty():
		return
	var stream := _load_stream(sfx_path)
	if not stream:
		return
	
	for player in _ui_sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(ui_volume * volume)
			player.play()
			return


# =============================================================================
#  AMBIENT RENDSZER
# =============================================================================
func play_ambient(ambient_path: String, crossfade_duration: float = 2.0) -> void:
	if ambient_path.is_empty():
		return
	if ambient_path == _current_ambient_path:
		return
	
	var stream := _load_stream(ambient_path)
	if not stream:
		push_warning("AudioManager: Ambient not found: " + ambient_path)
		return
	
	_current_ambient_path = ambient_path
	
	if _ambient_crossfade_tween and _ambient_crossfade_tween.is_valid():
		_ambient_crossfade_tween.kill()
	
	var old_player := _active_ambient_player
	var new_player := _ambient_player_b if _active_ambient_player == _ambient_player_a else _ambient_player_a
	_active_ambient_player = new_player
	
	new_player.stream = stream
	new_player.volume_db = -80.0
	new_player.play()
	
	_ambient_crossfade_tween = create_tween()
	_ambient_crossfade_tween.set_parallel(true)
	_ambient_crossfade_tween.tween_property(old_player, "volume_db", -80.0, crossfade_duration)
	_ambient_crossfade_tween.tween_property(new_player, "volume_db", linear_to_db(ambient_volume), crossfade_duration)
	_ambient_crossfade_tween.finished.connect(func(): old_player.stop())


func stop_ambient(fade_duration: float = 1.0) -> void:
	_current_ambient_path = ""
	if _ambient_crossfade_tween and _ambient_crossfade_tween.is_valid():
		_ambient_crossfade_tween.kill()
	var tween := create_tween()
	tween.tween_property(_active_ambient_player, "volume_db", -80.0, fade_duration)
	tween.finished.connect(func(): _active_ambient_player.stop())


## Időjárás ambient layer (eső, vihar, stb.)
func play_weather_ambient(weather_path: String, fade_in: float = 1.5) -> void:
	if weather_path.is_empty():
		stop_weather_ambient()
		return
	if weather_path == _current_weather_ambient:
		return
	
	var stream := _load_stream(weather_path)
	if not stream:
		return
	
	_current_weather_ambient = weather_path
	_weather_ambient_player.stream = stream
	_weather_ambient_player.volume_db = -80.0
	_weather_ambient_player.play()
	
	var tween := create_tween()
	tween.tween_property(_weather_ambient_player, "volume_db", linear_to_db(ambient_volume * 0.7), fade_in)


func stop_weather_ambient(fade_out: float = 1.0) -> void:
	_current_weather_ambient = ""
	if _weather_ambient_player.playing:
		var tween := create_tween()
		tween.tween_property(_weather_ambient_player, "volume_db", -80.0, fade_out)
		tween.finished.connect(func(): _weather_ambient_player.stop())


# =============================================================================
#  DINAMIKUS ZENE RENDSZER
# =============================================================================

## Exploration zenére váltás (biome-hoz illő)
func switch_to_exploration_music(biome: Enums.BiomeType = _current_biome) -> void:
	_music_state = MusicState.EXPLORATION
	_is_in_combat = false
	_is_boss_fight = false
	_exploration_music_path = AudioPaths.get_biome_music(biome)
	play_music(_exploration_music_path, 1.5)


## Combat zenére váltás
func switch_to_combat_music() -> void:
	if _music_state == MusicState.COMBAT or _music_state == MusicState.BOSS:
		return
	_previous_music_state = _music_state
	_music_state = MusicState.COMBAT
	_is_in_combat = true
	play_music(AudioPaths.MUSIC_COMBAT_THEME, 1.5)


## Combat vége → visszatérés exploration-re
func switch_from_combat_music() -> void:
	if _music_state != MusicState.COMBAT:
		return
	_is_in_combat = false
	if _is_in_dungeon:
		switch_to_dungeon_music()
	else:
		switch_to_exploration_music()


## Boss zene
func switch_to_boss_music() -> void:
	_previous_music_state = _music_state
	_music_state = MusicState.BOSS
	_is_boss_fight = true
	# Boss intro: instant stop → rumble → boss theme fade in
	stop_music_instant()
	play_sfx(AudioPaths.SFX_BOSS_INTRO_RUMBLE)
	# Kis késleltetés a rumble után
	get_tree().create_timer(1.0).timeout.connect(func():
		play_music(AudioPaths.MUSIC_BOSS_BATTLE, 1.0)
	)


## Boss legyőzve → victory fanfare → exploration
func play_victory_and_return() -> void:
	_music_state = MusicState.VICTORY
	_is_boss_fight = false
	stop_music_instant()
	play_music(AudioPaths.MUSIC_VICTORY_FANFARE, 0.0)
	# Victory fanfare után visszatérés (15-30 sec fanfare)
	get_tree().create_timer(20.0).timeout.connect(func():
		if _music_state == MusicState.VICTORY:
			if _is_in_dungeon:
				switch_to_dungeon_music()
			else:
				switch_to_exploration_music()
	)


## Dungeon zene
func switch_to_dungeon_music() -> void:
	_music_state = MusicState.DUNGEON
	_is_in_dungeon = true
	play_music(AudioPaths.MUSIC_DUNGEON_THEME, 1.5)
	play_ambient(AudioPaths.AMBIENT_DUNGEON, 2.0)


## Menü zene
func switch_to_menu_music() -> void:
	_music_state = MusicState.MENU
	stop_ambient(1.0)
	stop_weather_ambient(1.0)
	play_music(AudioPaths.MUSIC_MENU_THEME, 1.0)


# =============================================================================
#  SIGNAL HANDLEREK - Automatikus zene/SFX triggerelés
# =============================================================================

func _on_biome_entered(_player, biome: Enums.BiomeType) -> void:
	_current_biome = biome
	if not _is_in_combat and not _is_boss_fight and not _is_in_dungeon:
		switch_to_exploration_music(biome)
	# Ambient mindig frissül biome váltáskor
	if not _is_in_dungeon:
		play_ambient(AudioPaths.get_biome_ambient(biome), 2.0)


func _on_damage_dealt(_source, _target, _amount: float, _damage_type) -> void:
	# Combat zene indítás első sebzésre
	if not _is_in_combat and not _is_boss_fight:
		switch_to_combat_music()


func _on_entity_killed(_killer, _victim) -> void:
	# Enemy halál hang
	play_sfx_random_pitch(AudioPaths.SFX_DEATH_GENERIC, 0.8)


func _on_boss_fight_started(_boss_id: String) -> void:
	switch_to_boss_music()


func _on_boss_defeated(_boss_id: String) -> void:
	play_victory_and_return()


func _on_dungeon_entered(_dungeon_data: Dictionary) -> void:
	_is_in_dungeon = true
	if not _is_in_combat and not _is_boss_fight:
		switch_to_dungeon_music()


func _on_dungeon_exited() -> void:
	_is_in_dungeon = false
	if not _is_in_combat and not _is_boss_fight:
		switch_to_exploration_music()
		play_ambient(AudioPaths.get_biome_ambient(_current_biome), 2.0)


func _on_weather_changed(weather: Enums.WeatherType) -> void:
	match weather:
		Enums.WeatherType.RAIN:
			play_weather_ambient(AudioPaths.SFX_RAIN_LOOP)
		Enums.WeatherType.STORM:
			play_weather_ambient(AudioPaths.SFX_RAIN_LOOP)
			# Eseti mennydörgés
			_schedule_random_thunder()
		Enums.WeatherType.SNOW:
			play_weather_ambient(AudioPaths.SFX_WIND_HOWLING)
		Enums.WeatherType.CLEAR, Enums.WeatherType.FOG:
			stop_weather_ambient()
		_:
			stop_weather_ambient()


func _on_day_night_changed(is_night: bool) -> void:
	# Éjszaka: biome-specifikus éjjeli ambient (pl. tücskök rét biome-ban)
	if is_night and _current_biome == Enums.BiomeType.STARTING_MEADOW:
		play_sfx(AudioPaths.SFX_CRICKETS, 0.3)


func _on_player_leveled_up(_player, _new_level: int) -> void:
	play_sfx(AudioPaths.SFX_LEVEL_UP)


func _on_player_died(_player) -> void:
	play_sfx(AudioPaths.SFX_PLAYER_DEATH)


func _on_critical_hit(_source, _target, _amount: float) -> void:
	play_sfx_random_pitch(AudioPaths.SFX_CRITICAL_HIT, 1.0, 0.95, 1.05)


func _on_item_picked_up(_item_instance) -> void:
	play_ui_sfx(AudioPaths.SFX_ITEM_PICKUP)


func _on_gold_collected(_amount: int) -> void:
	play_ui_sfx(AudioPaths.SFX_GOLD_PICKUP, 0.8)


func _on_quest_accepted(_quest_id: String) -> void:
	play_ui_sfx(AudioPaths.SFX_QUEST_ACCEPT)


func _on_quest_completed(_quest_id: String) -> void:
	play_ui_sfx(AudioPaths.SFX_QUEST_COMPLETE)


func _on_item_equipped(_player, _item_data, _slot) -> void:
	play_ui_sfx(AudioPaths.SFX_ITEM_EQUIP)


func _on_inventory_changed() -> void:
	# Csendes — nem kell minden változásnál hang
	pass


func _on_skill_point_allocated(_skill_id: String, _new_rank: int) -> void:
	play_ui_sfx(AudioPaths.SFX_SKILL_UNLOCK)


func _on_crafting_completed(_recipe_id: String, _success: bool) -> void:
	play_ui_sfx(AudioPaths.SFX_CRAFT_ANVIL)


func _on_crafting_failed(_recipe_id: String) -> void:
	play_ui_sfx(AudioPaths.SFX_ERROR_BUZZ)


func _on_gem_socketed(_item_uuid: String, _gem_type) -> void:
	play_ui_sfx(AudioPaths.SFX_GEM_SOCKET)


func _on_chest_opened(_chest_data: Dictionary) -> void:
	play_sfx(AudioPaths.SFX_CHEST_OPEN)


func _on_trap_triggered(_trap_type: String, _position: Vector2) -> void:
	play_sfx(AudioPaths.SFX_TRAP_TRIGGER)


func _on_secret_room_found(_room_index: int) -> void:
	play_ui_sfx(AudioPaths.SFX_NOTIFICATION)


func _on_enhancement_attempted(_item_uuid: String, _level: int, success: bool) -> void:
	if success:
		play_ui_sfx(AudioPaths.SFX_CRAFT_ANVIL)
	else:
		play_ui_sfx(AudioPaths.SFX_ERROR_BUZZ)


func _on_gathering_started(_node_type) -> void:
	# A gathering típus alapján más hang
	if _node_type is int:
		match _node_type:
			Enums.GatheringNodeType.WOOD:
				play_sfx(AudioPaths.SFX_GATHERING_CHOP)
			Enums.GatheringNodeType.STONE, Enums.GatheringNodeType.ORE, \
			Enums.GatheringNodeType.CRYSTAL:
				play_sfx(AudioPaths.SFX_GATHERING_MINE)
			_:
				play_sfx(AudioPaths.SFX_GATHERING_PICK)
	else:
		play_sfx(AudioPaths.SFX_GATHERING_PICK)


func _on_gathering_completed(_node_type, _yield_amount: int) -> void:
	play_sfx(AudioPaths.SFX_ITEM_PICKUP, 0.8)


func _on_screen_opened(_screen_name: String) -> void:
	play_ui_sfx(AudioPaths.SFX_INVENTORY_OPEN, 0.7)


func _on_screen_closed(_screen_name: String) -> void:
	play_ui_sfx(AudioPaths.SFX_INVENTORY_CLOSE, 0.7)


func _on_notification_shown(_text: String, _type) -> void:
	play_ui_sfx(AudioPaths.SFX_NOTIFICATION, 0.6)


# =============================================================================
#  SEGÉDFUNKCIÓK
# =============================================================================

## Stream cache - elkerüli az ismételt load() hívásokat
## Automatikus .ogg → .wav fallback ha .ogg nem létezik (placeholder support)
func _load_stream(path: String) -> AudioStream:
	if path in _stream_cache:
		return _stream_cache[path]
	
	var actual_path := path
	
	# Ha .ogg nem létezik, próbáljuk .wav-ot (placeholder generátor .wav-ot hoz létre)
	if not ResourceLoader.exists(actual_path):
		if actual_path.ends_with(".ogg"):
			var wav_path := actual_path.replace(".ogg", ".wav")
			if ResourceLoader.exists(wav_path):
				actual_path = wav_path
			else:
				return null
		else:
			return null
	
	var stream := load(actual_path) as AudioStream
	if stream:
		if _stream_cache.size() >= MAX_CACHE_SIZE:
			# LRU-szerű: legrégebbit töröljük
			var first_key = _stream_cache.keys()[0]
			_stream_cache.erase(first_key)
		_stream_cache[path] = stream  # Eredeti path-hoz cache-eljük
	return stream


## Véletlenszerű mennydörgés ütemezése vihar közben
func _schedule_random_thunder() -> void:
	if _current_weather_ambient != AudioPaths.SFX_RAIN_LOOP:
		return
	var delay := randf_range(10.0, 30.0)
	get_tree().create_timer(delay).timeout.connect(func():
		if _current_weather_ambient == AudioPaths.SFX_RAIN_LOOP:
			play_sfx_random_pitch(AudioPaths.SFX_THUNDER, 0.7, 0.8, 1.2)
			_schedule_random_thunder()  # Következő mennydörgés
	)


## Combat music notify - CombatManager hívja közvetlenül
func notify_combat_started() -> void:
	switch_to_combat_music()


## Combat music notify - CombatManager hívja peace timer lejártakor
func notify_combat_ended() -> void:
	switch_from_combat_music()


# =============================================================================
#  HANGERŐ BEÁLLÍTÁSOK
# =============================================================================
func set_master_volume(vol: float) -> void:
	master_volume = clampf(vol, 0.0, 1.0)
	var idx := AudioServer.get_bus_index("Master")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(master_volume))


func set_music_volume(vol: float) -> void:
	music_volume = clampf(vol, 0.0, 1.0)
	if _active_music_player.playing:
		_active_music_player.volume_db = linear_to_db(music_volume)


func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)


func set_ambient_volume(vol: float) -> void:
	ambient_volume = clampf(vol, 0.0, 1.0)
	var idx := AudioServer.get_bus_index("Ambient")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(ambient_volume))


func set_ui_volume(vol: float) -> void:
	ui_volume = clampf(vol, 0.0, 1.0)
	var idx := AudioServer.get_bus_index("UI")
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(ui_volume))


## Összes hangerő mentés dictionary-ként (SaveManager-hez)
func get_volume_settings() -> Dictionary:
	return {
		"master": master_volume,
		"music": music_volume,
		"sfx": sfx_volume,
		"ambient": ambient_volume,
		"ui": ui_volume,
	}


## Hangerő betöltés dictionary-ből
func load_volume_settings(settings: Dictionary) -> void:
	if "master" in settings: set_master_volume(settings["master"])
	if "music" in settings: set_music_volume(settings["music"])
	if "sfx" in settings: set_sfx_volume(settings["sfx"])
	if "ambient" in settings: set_ambient_volume(settings["ambient"])
	if "ui" in settings: set_ui_volume(settings["ui"])


## Aktuális zene állapot (debug)
func get_music_state_name() -> String:
	match _music_state:
		MusicState.NONE: return "NONE"
		MusicState.EXPLORATION: return "EXPLORATION"
		MusicState.COMBAT: return "COMBAT"
		MusicState.BOSS: return "BOSS"
		MusicState.DUNGEON: return "DUNGEON"
		MusicState.MENU: return "MENU"
		MusicState.VICTORY: return "VICTORY"
		_: return "UNKNOWN"


## Stream cache törlése (scene váltáskor)
func clear_cache() -> void:
	_stream_cache.clear()

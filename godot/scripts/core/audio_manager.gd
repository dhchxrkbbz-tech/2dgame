## AudioManager - Hang kezelés (Autoload singleton)
## Zene crossfade, SFX pool, spatial audio
extends Node

# Hangerő beállítások
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0

# Zene lejátszók (crossfade-hez 2 kell)
var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer
var _current_music_path: String = ""

# SFX pool
const MAX_SFX_PLAYERS: int = 20
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_2d_pool: Array[AudioStreamPlayer2D] = []


func _ready() -> void:
	# Zene playerek létrehozása
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.bus = "Music"
	add_child(_music_player_a)
	
	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.bus = "Music"
	add_child(_music_player_b)
	
	_active_music_player = _music_player_a
	
	# SFX pool preallocation
	for i in MAX_SFX_PLAYERS:
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		_sfx_pool.append(sfx_player)


func play_music(music_path: String, crossfade_duration: float = 1.0) -> void:
	if music_path == _current_music_path:
		return
	
	_current_music_path = music_path
	var stream := load(music_path) as AudioStream
	if not stream:
		push_warning("AudioManager: Music not found: " + music_path)
		return
	
	var old_player := _active_music_player
	var new_player := _music_player_b if _active_music_player == _music_player_a else _music_player_a
	_active_music_player = new_player
	
	new_player.stream = stream
	new_player.volume_db = -80.0
	new_player.play()
	
	# Crossfade
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(old_player, "volume_db", -80.0, crossfade_duration)
	tween.tween_property(new_player, "volume_db", linear_to_db(music_volume), crossfade_duration)
	await tween.finished
	old_player.stop()


func stop_music(fade_duration: float = 0.5) -> void:
	_current_music_path = ""
	var tween := create_tween()
	tween.tween_property(_active_music_player, "volume_db", -80.0, fade_duration)
	await tween.finished
	_active_music_player.stop()


func play_sfx(sfx_path: String, volume: float = 1.0) -> void:
	var stream := load(sfx_path) as AudioStream
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
	var stream := load(sfx_path) as AudioStream
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


func set_master_volume(vol: float) -> void:
	master_volume = clampf(vol, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))


func set_music_volume(vol: float) -> void:
	music_volume = clampf(vol, 0.0, 1.0)
	_active_music_player.volume_db = linear_to_db(music_volume)


func set_sfx_volume(vol: float) -> void:
	sfx_volume = clampf(vol, 0.0, 1.0)

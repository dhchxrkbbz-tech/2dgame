## AudioPlaceholderGenerator - Placeholder audio fájlok generálása teszteléshez
## Futtatás: EditorScript-ként az Editorban, vagy egyszerűen add a scene-hez
## Ez a script PROCEDURÁLISAN generál mini .wav fájlokat, amelyek rövid szinusz/zaj hangot
## tartalmaznak, így a teljes audio rendszer tesztelhető VALÓDI hangfájlok nélkül.
##
## Használat:
##   1. Add hozzá egy Node-hoz a scene-ben
##   2. Futtasd a _ready()-t → legenerálja az összes placeholder-t
##   3. Töröld a Node-ot ha kész
@tool
class_name AudioPlaceholderGenerator
extends Node

## Generál-e automatikusan _ready()-ban
@export var auto_generate: bool = false

## Felülírja-e a már létező fájlokat
@export var overwrite_existing: bool = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return
	if auto_generate:
		generate_all_placeholders()


## Összes placeholder generálása
func generate_all_placeholders() -> void:
	print("=== AudioPlaceholderGenerator: Generálás indítása ===")
	var count := 0
	
	# Zene placeholder-ek (.ogg nem generálható code-ból könnyen, .wav-ot generálunk)
	# A rendszer .ogg-ot vár, de .wav import-ot is elfogad Godot-ban
	count += _generate_music_placeholders()
	count += _generate_combat_sfx_placeholders()
	count += _generate_skill_sfx_placeholders()
	count += _generate_ui_sfx_placeholders()
	count += _generate_environment_sfx_placeholders()
	count += _generate_ambient_placeholders()
	
	print("=== AudioPlaceholderGenerator: %d fájl generálva ===" % count)


## Szinusz hullám WAV generálása
func _generate_wav(path: String, duration_sec: float, frequency_hz: float, volume: float = 0.3) -> bool:
	if not overwrite_existing and FileAccess.file_exists(path):
		return false
	
	var sample_rate := 22050
	var num_samples := int(duration_sec * sample_rate)
	var data := PackedByteArray()
	
	# WAV header (44 byte)
	var data_size := num_samples * 2  # 16-bit mono
	var file_size := data_size + 36
	
	# RIFF header
	data.append_array("RIFF".to_ascii_buffer())
	data.append_array(_int32_to_bytes(file_size))
	data.append_array("WAVE".to_ascii_buffer())
	
	# fmt chunk
	data.append_array("fmt ".to_ascii_buffer())
	data.append_array(_int32_to_bytes(16))      # chunk size
	data.append_array(_int16_to_bytes(1))        # PCM format
	data.append_array(_int16_to_bytes(1))        # mono
	data.append_array(_int32_to_bytes(sample_rate))
	data.append_array(_int32_to_bytes(sample_rate * 2))  # byte rate
	data.append_array(_int16_to_bytes(2))        # block align
	data.append_array(_int16_to_bytes(16))       # bits per sample
	
	# data chunk
	data.append_array("data".to_ascii_buffer())
	data.append_array(_int32_to_bytes(data_size))
	
	# Audio data
	for i in num_samples:
		var t := float(i) / sample_rate
		var sample_val := sin(t * frequency_hz * TAU) * volume
		# Fade in/out (first/last 10% of samples)
		var fade_samples := int(num_samples * 0.1)
		if i < fade_samples:
			sample_val *= float(i) / fade_samples
		elif i > num_samples - fade_samples:
			sample_val *= float(num_samples - i) / fade_samples
		var sample_int := clampi(int(sample_val * 32767), -32768, 32767)
		data.append_array(_int16_to_bytes(sample_int))
	
	# Könyvtár biztosítás
	var dir_path := path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("AudioPlaceholderGenerator: Cannot write: " + path)
		return false
	
	file.store_buffer(data)
	file.close()
	print("  Generated: " + path)
	return true


## Zaj (white noise) WAV generálása (csapda, robbanás, stb.)
func _generate_noise_wav(path: String, duration_sec: float, volume: float = 0.2) -> bool:
	if not overwrite_existing and FileAccess.file_exists(path):
		return false
	
	var sample_rate := 22050
	var num_samples := int(duration_sec * sample_rate)
	var data := PackedByteArray()
	
	var data_size := num_samples * 2
	var file_size := data_size + 36
	
	data.append_array("RIFF".to_ascii_buffer())
	data.append_array(_int32_to_bytes(file_size))
	data.append_array("WAVE".to_ascii_buffer())
	data.append_array("fmt ".to_ascii_buffer())
	data.append_array(_int32_to_bytes(16))
	data.append_array(_int16_to_bytes(1))
	data.append_array(_int16_to_bytes(1))
	data.append_array(_int32_to_bytes(sample_rate))
	data.append_array(_int32_to_bytes(sample_rate * 2))
	data.append_array(_int16_to_bytes(2))
	data.append_array(_int16_to_bytes(16))
	data.append_array("data".to_ascii_buffer())
	data.append_array(_int32_to_bytes(data_size))
	
	for i in num_samples:
		var sample_val := (randf() * 2.0 - 1.0) * volume
		var fade_samples := int(num_samples * 0.1)
		if i < fade_samples:
			sample_val *= float(i) / fade_samples
		elif i > num_samples - fade_samples:
			sample_val *= float(num_samples - i) / fade_samples
		var sample_int := clampi(int(sample_val * 32767), -32768, 32767)
		data.append_array(_int16_to_bytes(sample_int))
	
	var dir_path := path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir_path)
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("AudioPlaceholderGenerator: Cannot write: " + path)
		return false
	
	file.store_buffer(data)
	file.close()
	print("  Generated (noise): " + path)
	return true


# === Placeholder generátor kategóriák ===

func _generate_music_placeholders() -> int:
	var count := 0
	# Zene: hosszabb szinusz, különböző frekvenciákkal
	# MEGJEGYZÉS: Godot .ogg-ot vár zenéhez, de a teszteléshez .wav is elfogadható
	# Ha .ogg kell, akkor külső tool-lal kell konvertálni
	var tracks := {
		"res://assets/audio/music/menu_theme.wav": [3.0, 220.0],       # A3 - melankolikus
		"res://assets/audio/music/peaceful_exploration.wav": [4.0, 330.0],  # E4 - nyugodt
		"res://assets/audio/music/dark_exploration.wav": [4.0, 165.0],     # E3 - sötét
		"res://assets/audio/music/hostile_lands.wav": [4.0, 146.8],        # D3 - fenyegető
		"res://assets/audio/music/combat_theme.wav": [3.0, 440.0],         # A4 - intenzív
		"res://assets/audio/music/dungeon_theme.wav": [4.0, 130.8],        # C3 - klausztrofóbikus
		"res://assets/audio/music/boss_battle.wav": [4.0, 185.0],          # F#3 - epikus
		"res://assets/audio/music/victory_fanfare.wav": [2.0, 523.2],      # C5 - diadalmas
	}
	for path in tracks:
		var params: Array = tracks[path]
		if _generate_wav(path, params[0], params[1], 0.15):
			count += 1
	return count


func _generate_combat_sfx_placeholders() -> int:
	var count := 0
	var sfx := {
		# Melee - magasabb frekvencia, rövid
		AudioPaths.SFX_SWORD_SWING: [0.15, 800.0],
		AudioPaths.SFX_SWORD_HIT_FLESH: [0.1, 400.0],
		AudioPaths.SFX_DAGGER_STAB: [0.08, 1000.0],
		AudioPaths.SFX_MACE_HIT: [0.12, 200.0],
		AudioPaths.SFX_AXE_CHOP: [0.15, 350.0],
		AudioPaths.SFX_SHIELD_BLOCK: [0.1, 500.0],
		AudioPaths.SFX_SHIELD_BASH: [0.12, 300.0],
		AudioPaths.SFX_FIST_PUNCH: [0.08, 250.0],
		# Ranged
		AudioPaths.SFX_ARROW_SHOOT: [0.1, 1200.0],
		AudioPaths.SFX_ARROW_HIT: [0.08, 600.0],
		AudioPaths.SFX_SPELL_CAST_GENERIC: [0.3, 700.0],
		AudioPaths.SFX_FIREBALL_LAUNCH: [0.2, 500.0],
		AudioPaths.SFX_FIREBALL_IMPACT: [0.15, 250.0],
		AudioPaths.SFX_ICE_SHARD: [0.12, 1500.0],
		AudioPaths.SFX_POISON_SPIT: [0.15, 400.0],
		# Impact
		AudioPaths.SFX_HIT_PLAYER: [0.1, 300.0],
		AudioPaths.SFX_HIT_ENEMY: [0.1, 350.0],
		AudioPaths.SFX_CRITICAL_HIT: [0.15, 600.0],
		AudioPaths.SFX_DODGE_WHOOSH: [0.2, 900.0],
		AudioPaths.SFX_DEATH_GENERIC: [0.3, 180.0],
		AudioPaths.SFX_PLAYER_DEATH: [0.5, 150.0],
		# Special
		AudioPaths.SFX_HEAL_SPELL: [0.3, 880.0],
		AudioPaths.SFX_BUFF_APPLY: [0.2, 660.0],
		AudioPaths.SFX_DEBUFF_APPLY: [0.2, 220.0],
		AudioPaths.SFX_LEVEL_UP: [0.5, 1046.5],
	}
	for path in sfx:
		var params: Array = sfx[path]
		if _generate_wav(path, params[0], params[1], 0.25):
			count += 1
	# AoE explosion as noise
	if _generate_noise_wav(AudioPaths.SFX_AOE_EXPLOSION, 0.3, 0.2):
		count += 1
	return count


func _generate_skill_sfx_placeholders() -> int:
	var count := 0
	var sfx := {
		AudioPaths.SFX_SHADOW_STEP: [0.15, 600.0],
		AudioPaths.SFX_SMOKE_BOMB: [0.2, 300.0],
		AudioPaths.SFX_POISON_APPLY: [0.25, 350.0],
		AudioPaths.SFX_BLOOD_SLASH: [0.12, 450.0],
		AudioPaths.SFX_TAUNT_SHOUT: [0.3, 180.0],
		AudioPaths.SFX_GROUND_SLAM: [0.25, 100.0],
		AudioPaths.SFX_CHAIN_PULL: [0.2, 500.0],
		AudioPaths.SFX_FORTIFY: [0.2, 400.0],
		AudioPaths.SFX_ARCANE_BLAST: [0.2, 700.0],
		AudioPaths.SFX_FROST_NOVA: [0.25, 1200.0],
		AudioPaths.SFX_HOLY_LIGHT: [0.3, 880.0],
		AudioPaths.SFX_TELEPORT: [0.15, 1500.0],
	}
	for path in sfx:
		var params: Array = sfx[path]
		if _generate_wav(path, params[0], params[1], 0.25):
			count += 1
	return count


func _generate_ui_sfx_placeholders() -> int:
	var count := 0
	var sfx := {
		AudioPaths.SFX_BUTTON_CLICK: [0.05, 800.0],
		AudioPaths.SFX_BUTTON_HOVER: [0.03, 1000.0],
		AudioPaths.SFX_INVENTORY_OPEN: [0.15, 600.0],
		AudioPaths.SFX_INVENTORY_CLOSE: [0.1, 500.0],
		AudioPaths.SFX_ITEM_PICKUP: [0.1, 1200.0],
		AudioPaths.SFX_ITEM_EQUIP: [0.12, 700.0],
		AudioPaths.SFX_ITEM_DROP: [0.1, 400.0],
		AudioPaths.SFX_GOLD_PICKUP: [0.08, 2000.0],
		AudioPaths.SFX_QUEST_ACCEPT: [0.2, 800.0],
		AudioPaths.SFX_QUEST_COMPLETE: [0.4, 1046.5],
		AudioPaths.SFX_NOTIFICATION: [0.15, 900.0],
		AudioPaths.SFX_ERROR_BUZZ: [0.15, 150.0],
		AudioPaths.SFX_SKILL_UNLOCK: [0.3, 1046.5],
	}
	for path in sfx:
		var params: Array = sfx[path]
		if _generate_wav(path, params[0], params[1], 0.2):
			count += 1
	return count


func _generate_environment_sfx_placeholders() -> int:
	var count := 0
	# Környezeti hangok - némelyik zaj-alapú
	var tone_sfx := {
		AudioPaths.SFX_THUNDER: [0.8, 80.0],
		AudioPaths.SFX_FIRE_CRACKLE: [0.5, 300.0],
		AudioPaths.SFX_WATER_DRIP: [0.1, 1500.0],
		AudioPaths.SFX_CROW_CAW: [0.3, 700.0],
		AudioPaths.SFX_CRICKETS: [0.5, 4000.0],
		AudioPaths.SFX_BOSS_INTRO_RUMBLE: [1.5, 50.0],
		AudioPaths.SFX_CHEST_OPEN: [0.2, 400.0],
		AudioPaths.SFX_DOOR_OPEN: [0.3, 300.0],
		AudioPaths.SFX_DOOR_LOCKED: [0.15, 200.0],
		AudioPaths.SFX_PORTAL_ACTIVATE: [0.4, 600.0],
		AudioPaths.SFX_TRAP_TRIGGER: [0.15, 500.0],
		AudioPaths.SFX_GATHERING_CHOP: [0.12, 350.0],
		AudioPaths.SFX_GATHERING_MINE: [0.15, 250.0],
		AudioPaths.SFX_GATHERING_PICK: [0.1, 450.0],
		AudioPaths.SFX_GEM_SOCKET: [0.2, 1200.0],
		AudioPaths.SFX_CRAFT_ANVIL: [0.2, 280.0],
	}
	for path in tone_sfx:
		var params: Array = tone_sfx[path]
		if _generate_wav(path, params[0], params[1], 0.2):
			count += 1
	# Noise-based
	var noise_sfx := [
		AudioPaths.SFX_WIND_LIGHT,
		AudioPaths.SFX_WIND_HOWLING,
		AudioPaths.SFX_RAIN_LOOP,
		AudioPaths.SFX_SWAMP_BUBBLES,
		AudioPaths.SFX_DUNGEON_AMBIENCE,
	]
	for path in noise_sfx:
		if _generate_noise_wav(path, 2.0, 0.1):
			count += 1
	return count


func _generate_ambient_placeholders() -> int:
	var count := 0
	var ambients := [
		AudioPaths.AMBIENT_MEADOW,
		AudioPaths.AMBIENT_FOREST,
		AudioPaths.AMBIENT_SWAMP,
		AudioPaths.AMBIENT_RUINS,
		AudioPaths.AMBIENT_MOUNTAINS,
		AudioPaths.AMBIENT_FROZEN,
		AudioPaths.AMBIENT_ASHLANDS,
		AudioPaths.AMBIENT_PLAGUE,
		AudioPaths.AMBIENT_DUNGEON,
	]
	for path in ambients:
		# Ambient .ogg-nek kellene lennie, de .wav-ot generálunk teszteléshez
		# Godot kezelni fogja mindkettőt
		var wav_path: String = path.replace(".ogg", ".wav")
		if _generate_noise_wav(wav_path, 5.0, 0.08):
			count += 1
	return count


# === Helper functions ===

func _int32_to_bytes(value: int) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.append(value & 0xFF)
	bytes.append((value >> 8) & 0xFF)
	bytes.append((value >> 16) & 0xFF)
	bytes.append((value >> 24) & 0xFF)
	return bytes


func _int16_to_bytes(value: int) -> PackedByteArray:
	var bytes := PackedByteArray()
	bytes.append(value & 0xFF)
	bytes.append((value >> 8) & 0xFF)
	return bytes

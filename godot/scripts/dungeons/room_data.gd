## RoomData - Resource: dungeon room konfigurációs adatok
## Biome-specifikus room paraméterek és tartalom definíciók
class_name RoomData
extends Resource

## Room típus (megegyezik DungeonRoom.RoomType-al)
@export var room_type: int = 0

## Room méret tartomány (tile-ban)
@export var min_size: Vector2i = Vector2i(8, 8)
@export var max_size: Vector2i = Vector2i(16, 12)

## Enemy konfiguráció
@export var min_enemies: int = 3
@export var max_enemies: int = 8
@export var elite_chance: float = 0.15
@export var wave_count_range: Vector2i = Vector2i(1, 3)

## Trap konfiguráció
@export var min_traps: int = 0
@export var max_traps: int = 4
@export var trap_types: Array[String] = []

## Chest konfiguráció
@export var chest_count_range: Vector2i = Vector2i(0, 1)
@export var chest_bonus_chance: float = 0.3
@export var mimic_chance: float = 0.2

## Cover elemek
@export var min_covers: int = 0
@export var max_covers: int = 3
@export var cover_types: Array[String] = ["pillar", "low_wall", "barrel"]

## Puzzle
@export var puzzle_types: Array[String] = []

## Loot szorzó
@export var loot_multiplier: float = 1.0

## Biome-specifikus adatok
@export var biome_hazard_type: String = ""
@export var hazard_density: float = 0.0

## Dekoráció szorzó
@export var decoration_density: float = 1.0


## Room típus-specifikus preset-ek
static func create_combat_preset(difficulty: int) -> RoomData:
	var data := RoomData.new()
	data.room_type = 0  # COMBAT
	data.min_size = Vector2i(10, 10)
	data.max_size = Vector2i(16, 12)
	
	# Difficulty scaling
	match difficulty:
		1, 2, 3:
			data.min_enemies = 3
			data.max_enemies = 4
			data.wave_count_range = Vector2i(1, 1)
			data.elite_chance = 0.05
		4, 5, 6:
			data.min_enemies = 4
			data.max_enemies = 5
			data.wave_count_range = Vector2i(1, 2)
			data.elite_chance = 0.10
		7, 8:
			data.min_enemies = 6
			data.max_enemies = 7
			data.wave_count_range = Vector2i(2, 3)
			data.elite_chance = 0.15
		_:
			data.min_enemies = 7
			data.max_enemies = 8
			data.wave_count_range = Vector2i(2, 3)
			data.elite_chance = 0.20
	
	data.chest_bonus_chance = 0.3
	data.min_covers = 1
	data.max_covers = 3
	return data


static func create_treasure_preset() -> RoomData:
	var data := RoomData.new()
	data.room_type = 1  # TREASURE
	data.min_size = Vector2i(8, 8)
	data.max_size = Vector2i(10, 10)
	data.min_enemies = 0
	data.max_enemies = 0
	data.chest_count_range = Vector2i(1, 3)
	data.mimic_chance = 0.2
	data.min_traps = 0
	data.max_traps = 3
	data.loot_multiplier = 1.5
	data.decoration_density = 1.5
	return data


static func create_puzzle_preset() -> RoomData:
	var data := RoomData.new()
	data.room_type = 2  # PUZZLE
	data.min_size = Vector2i(10, 10)
	data.max_size = Vector2i(14, 14)
	data.min_enemies = 0
	data.max_enemies = 0
	data.puzzle_types = ["switch_order", "pressure_plate", "light_beam", "symbol_match", "timed"]
	data.loot_multiplier = 1.3
	return data


static func create_trap_preset(difficulty: int) -> RoomData:
	var data := RoomData.new()
	data.room_type = 3  # TRAP
	data.min_size = Vector2i(10, 10)
	data.max_size = Vector2i(14, 12)
	data.min_enemies = 0
	data.max_enemies = 0
	
	match difficulty:
		1, 2, 3:
			data.min_traps = 4
			data.max_traps = 5
		4, 5, 6:
			data.min_traps = 5
			data.max_traps = 7
		_:
			data.min_traps = 6
			data.max_traps = 8
	
	data.trap_types = ["spike", "poison_gas", "fire_jet", "arrow", "falling_rocks", "pit", "curse_totem"]
	data.chest_count_range = Vector2i(1, 1)
	data.loot_multiplier = 1.2
	return data


static func create_safe_preset() -> RoomData:
	var data := RoomData.new()
	data.room_type = 4  # SAFE
	data.min_size = Vector2i(8, 8)
	data.max_size = Vector2i(8, 8)
	data.min_enemies = 0
	data.max_enemies = 0
	data.min_traps = 0
	data.max_traps = 0
	data.decoration_density = 1.2
	return data


static func create_boss_preset() -> RoomData:
	var data := RoomData.new()
	data.room_type = 5  # BOSS
	data.min_size = Vector2i(20, 16)
	data.max_size = Vector2i(24, 20)
	data.min_enemies = 1
	data.max_enemies = 1
	data.loot_multiplier = 3.0
	data.decoration_density = 1.5
	return data


static func create_secret_preset() -> RoomData:
	var data := RoomData.new()
	data.room_type = 6  # SECRET
	data.min_size = Vector2i(6, 6)
	data.max_size = Vector2i(8, 8)
	data.min_enemies = 0
	data.max_enemies = 0
	data.chest_count_range = Vector2i(1, 2)
	data.loot_multiplier = 2.5
	return data

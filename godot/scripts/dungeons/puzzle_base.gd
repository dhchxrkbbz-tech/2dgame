## PuzzleBase - Alap puzzle osztály
## Minden puzzle típus ebből származik
class_name PuzzleBase
extends Node2D

signal puzzle_completed(puzzle_type: String, room_index: int)
signal puzzle_failed(puzzle_type: String, room_index: int)
signal puzzle_reset(puzzle_type: String, room_index: int)

## Puzzle állapot
var puzzle_type: String = ""
var room_index: int = -1
var is_solved: bool = false
var is_active: bool = false

## Room referencia
var room: DungeonRoom = null

## Jutalom
var reward_chest_rarity: int = Enums.Rarity.UNCOMMON
var xp_bonus: float = 1.3  # +30% XP


## Inicializálás
func setup(p_room: DungeonRoom, p_puzzle_type: String) -> void:
	room = p_room
	room_index = p_room.room_index
	puzzle_type = p_puzzle_type
	is_active = true
	_build_puzzle()


## Override: puzzle felépítése
func _build_puzzle() -> void:
	pass


## Override: puzzle ellenőrzés
func check_solution() -> bool:
	return false


## Puzzle megoldás
func solve() -> void:
	if is_solved:
		return
	is_solved = true
	is_active = false
	
	if room:
		room.puzzle_data["solved"] = true
	
	puzzle_completed.emit(puzzle_type, room_index)
	EventBus.show_notification.emit("Puzzle Solved!", Enums.NotificationType.INFO)
	
	_on_solved()


## Override: megoldás utáni logika (spawn reward, stb.)
func _on_solved() -> void:
	pass


## Puzzle kudarc (rossz megoldás)
func fail() -> void:
	puzzle_failed.emit(puzzle_type, room_index)
	_on_failed()


## Override: kudarc utáni logika
func _on_failed() -> void:
	pass


## Puzzle reset
func reset_puzzle() -> void:
	is_solved = false
	is_active = true
	puzzle_reset.emit(puzzle_type, room_index)
	_on_reset()


## Override: reset logika
func _on_reset() -> void:
	pass


## Jutalom chest spawn
func spawn_reward_chest(world_pos: Vector2) -> void:
	var chest_data := {
		"rarity": reward_chest_rarity,
		"is_mimic": false,
		"world_pos": world_pos,
	}
	
	EventBus.show_notification.emit("Reward Chest appeared!", Enums.NotificationType.LOOT)
	# A tényleges chest-et a DungeonLootSpawner hozza létre

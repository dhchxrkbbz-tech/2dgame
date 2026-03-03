## LootDropper - Enemy-hez csatolható loot drop komponens
## Kezeli a drop esélyt, loot table-t, személyes loot generálást
class_name LootDropper
extends Node

@export var enemy_tier: String = "normal"  # "normal", "elite", "mini_boss", etc.
@export var enemy_level: int = 1
@export var custom_loot_table: LootTable = null
@export var boss_specific_drops: Array[String] = []  # legendary_id-k
@export var first_kill_bonus: bool = false  # +10% legendary chance

var _loot_table: LootTable = null


func _ready() -> void:
	_setup_loot_table()


func _setup_loot_table() -> void:
	if custom_loot_table:
		_loot_table = custom_loot_table
		return
	
	match enemy_tier:
		"normal", "caster":
			_loot_table = LootTable.create_normal_enemy()
		"elite":
			_loot_table = LootTable.create_elite_enemy()
		"rare_named":
			_loot_table = LootTable.create_elite_enemy()
			_loot_table.drop_count_range = Vector2i(2, 3)
		"mini_boss":
			_loot_table = LootTable.create_mini_boss()
		"dungeon_boss":
			_loot_table = LootTable.create_dungeon_boss()
		"world_boss":
			_loot_table = LootTable.create_world_boss()
		"raid_boss":
			_loot_table = LootTable.create_raid_boss()
		_:
			_loot_table = LootTable.create_normal_enemy()


## Fő loot generálás – hívd meg enemy halálakor
func drop_loot(drop_position: Vector2, magic_find: float = 0.0, player_count: int = 1) -> void:
	# Drop chance check (normál enemy-knél)
	var base_chance: float = LootGenerator.DROP_CHANCE.get(enemy_tier, 0.3)
	base_chance *= (1.0 + magic_find / 100.0)
	
	if enemy_tier in ["normal", "caster"] and randf() > base_chance:
		# Csak gold vagy semmi
		_drop_gold_only(drop_position)
		return
	
	# Személyes loot: minden player-nek külön
	if player_count > 1 and multiplayer.has_multiplayer_peer():
		_generate_personal_loot(drop_position, magic_find, player_count)
	else:
		_generate_single_loot(drop_position, magic_find)


## Egyetlen játékos loot generálás
func _generate_single_loot(pos: Vector2, magic_find: float) -> void:
	# First kill bonus
	var effective_mf := magic_find
	if first_kill_bonus:
		effective_mf += 100.0  # +10% legendary → extra MF
	
	# Loot table használat ha van
	if _loot_table:
		var loot := _loot_table.roll_loot(enemy_level, effective_mf)
		_spawn_loot(loot, pos)
	else:
		# Fallback: LootGenerator
		var items := LootGenerator.generate_enemy_loot(enemy_level, enemy_tier, effective_mf)
		for item in items:
			_spawn_item_drop(item, pos)
		
		var gold := LootGenerator.generate_gold(enemy_level, enemy_tier)
		if gold > 0:
			_spawn_gold_drop(gold, pos)
	
	# Boss-specifikus drop-ok
	for boss_drop_id in boss_specific_drops:
		if randf() < _get_boss_drop_chance():
			var legendary := LootGenerator.generate_legendary(enemy_level, boss_drop_id)
			if legendary:
				_spawn_item_drop(legendary, pos)
	
	# Material drop (ha nem a loot table kezeli)
	if not _loot_table or _loot_table.material_chance <= 0:
		var mat_drops := LootGenerator.generate_material_drop(enemy_level, enemy_tier)
		for mat in mat_drops:
			_spawn_item_drop(mat, pos)


## Multiplayer személyes loot
func _generate_personal_loot(pos: Vector2, magic_find: float, player_count: int) -> void:
	var peers := multiplayer.get_peers()
	var host_id := multiplayer.get_unique_id()
	
	# Host + peer-ek
	var all_ids: Array[int] = [host_id]
	for peer in peers:
		all_ids.append(peer)
	
	for player_id in all_ids:
		var items := LootGenerator.generate_enemy_loot(enemy_level, enemy_tier, magic_find)
		var gold := LootGenerator.generate_gold(enemy_level, enemy_tier)
		
		# RPC: csak az adott player-nek
		if player_id == multiplayer.get_unique_id():
			for item in items:
				_spawn_item_drop(item, pos, player_id)
			if gold > 0:
				_spawn_gold_drop(gold, pos, player_id)
		else:
			_rpc_send_loot.rpc_id(player_id, _serialize_items(items), gold, pos)


@rpc("authority", "call_remote", "reliable")
func _rpc_send_loot(serialized_items: Array, gold: int, pos: Vector2) -> void:
	for item_data in serialized_items:
		var item := ItemInstance.deserialize(item_data)
		if item:
			_spawn_item_drop(item, pos, multiplayer.get_unique_id())
	
	if gold > 0:
		_spawn_gold_drop(gold, pos, multiplayer.get_unique_id())


func _serialize_items(items: Array[ItemInstance]) -> Array:
	var result: Array = []
	for item in items:
		result.append(item.serialize())
	return result


## Loot spawning
func _spawn_loot(loot: Dictionary, pos: Vector2, owner_id: int = -1) -> void:
	var items: Array = loot.get("items", [])
	var gold: int = loot.get("gold", 0)
	var dark_essence: int = loot.get("dark_essence", 0)
	
	for item in items:
		_spawn_item_drop(item, pos, owner_id)
	
	if gold > 0:
		_spawn_gold_drop(gold, pos, owner_id)
	
	if dark_essence > 0:
		EventBus.emit_signal("currency_changed", Enums.CurrencyType.DARK_ESSENCE, dark_essence)


func _spawn_item_drop(item: ItemInstance, pos: Vector2, owner_id: int = -1) -> void:
	var drop := DroppedItem.create_item_drop(item, pos)
	drop._owner_id = owner_id
	
	# Loot filter check
	if LootManager and LootManager.has_method("should_show_drop"):
		if not LootManager.should_show_drop(item):
			drop.visible = false
	
	_add_to_world(drop)
	EventBus.emit_signal("item_dropped", item, pos)


func _spawn_gold_drop(amount: int, pos: Vector2, owner_id: int = -1) -> void:
	var drop := DroppedItem.create_gold_drop(amount, pos)
	drop._owner_id = owner_id
	_add_to_world(drop)


func _drop_gold_only(pos: Vector2) -> void:
	var gold := LootGenerator.generate_gold(enemy_level, enemy_tier)
	if gold > 0:
		_spawn_gold_drop(gold, pos)


func _add_to_world(node: Node2D) -> void:
	var world := get_tree().current_scene
	if world:
		world.call_deferred("add_child", node)


func _get_boss_drop_chance() -> float:
	match enemy_tier:
		"mini_boss": return 0.15
		"dungeon_boss": return 0.25
		"world_boss": return 0.40
		"raid_boss": return 0.60
		_: return 0.05

## UpgradeManager - Enhancement (+1→+10), Enchanting, Gem socketing
## Gear erősítés/javítás rendszer, gold sink mechanika
class_name UpgradeManager
extends Node

## Enchant pool: lehetséges enchant stat-ok
const ENCHANT_POOL: Array[Dictionary] = [
	{"stat": "crit_chance", "min_value": 3.0, "max_value": 15.0, "is_percent": true, "name": "Critical Strike"},
	{"stat": "lifesteal", "min_value": 2.0, "max_value": 8.0, "is_percent": true, "name": "Lifesteal"},
	{"stat": "armor", "min_value": 5.0, "max_value": 30.0, "is_percent": false, "name": "Armor"},
	{"stat": "dot_damage", "min_value": 5.0, "max_value": 25.0, "is_percent": true, "name": "DOT Damage"},
	{"stat": "movement_speed", "min_value": 3.0, "max_value": 10.0, "is_percent": true, "name": "Movement Speed"},
	{"stat": "cooldown_reduction", "min_value": 3.0, "max_value": 12.0, "is_percent": true, "name": "Cooldown Reduction"},
	{"stat": "max_hp", "min_value": 10.0, "max_value": 50.0, "is_percent": false, "name": "Maximum HP"},
	{"stat": "max_mana", "min_value": 5.0, "max_value": 30.0, "is_percent": false, "name": "Maximum Mana"},
	{"stat": "attack_speed", "min_value": 3.0, "max_value": 12.0, "is_percent": true, "name": "Attack Speed"},
	{"stat": "magic_find", "min_value": 2.0, "max_value": 10.0, "is_percent": true, "name": "Magic Find"},
]

## Referenciák
var currency_manager: CurrencyManager = null
var inventory_manager: InventoryManager = null


# ============================================================
#  ENHANCEMENT RENDSZER (+1 → +10)
# ============================================================

## Enhancement lehetőség ellenőrzés
func can_enhance(item: ItemInstance) -> bool:
	if not item or not item.base_item:
		return false
	# Csak gear-t lehet enhance-olni
	if item.base_item.item_type == Enums.ItemType.CONSUMABLE:
		return false
	if item.base_item.item_type == Enums.ItemType.MATERIAL:
		return false
	if item.enhancement_level >= 10:
		return false
	return true


## Enhancement költség lekérdezés
func get_enhancement_cost(item: ItemInstance) -> Dictionary:
	if not item:
		return {}
	var level := item.enhancement_level
	if level >= 10:
		return {}
	
	var gold := Constants.ENHANCEMENT_GOLD_COSTS[level]
	var materials := Constants.ENHANCEMENT_MATERIAL_COSTS[level]
	var dark_essence := 0
	
	# +9 és +10 Dark Essence-t is igényel
	if level >= 8:
		dark_essence = 5 + (level - 8) * 5  # +9: 5 DE, +10: 10 DE
	
	return {
		"gold": gold,
		"materials": materials,
		"dark_essence": dark_essence,
		"success_rate": Constants.ENHANCEMENT_SUCCESS_RATES[level],
	}


## Enhancement végrehajtás
func enhance_item(item: ItemInstance) -> Dictionary:
	if not can_enhance(item):
		return {"success": false, "reason": "cannot_enhance"}
	
	if not currency_manager:
		return {"success": false, "reason": "no_currency_manager"}
	
	var costs := get_enhancement_cost(item)
	var gold_cost: int = costs.get("gold", 0)
	var de_cost: int = costs.get("dark_essence", 0)
	
	# Gold ellenőrzés
	if not currency_manager.can_afford_gold(gold_cost):
		return {"success": false, "reason": "not_enough_gold"}
	
	# Dark Essence ellenőrzés
	if de_cost > 0 and not currency_manager.can_afford(Enums.CurrencyType.DARK_ESSENCE, de_cost):
		return {"success": false, "reason": "not_enough_dark_essence"}
	
	# Költségek levonása (mindig megtörténik!)
	currency_manager.spend_gold(gold_cost)
	if de_cost > 0:
		currency_manager.spend_dark_essence(de_cost)
	
	# Siker dobás
	var success_rate: float = costs.get("success_rate", 1.0)
	var success := randf() <= success_rate
	
	if success:
		item.enhancement_level += 1
		EventBus.enhancement_attempted.emit(item.uuid, item.enhancement_level, true)
		return {
			"success": true,
			"new_level": item.enhancement_level,
			"stat_bonus": item.enhancement_level * 0.05,
		}
	else:
		# Fail: material elvész, item NEM törik el
		EventBus.enhancement_attempted.emit(item.uuid, item.enhancement_level, false)
		return {
			"success": false,
			"reason": "enhancement_failed",
			"current_level": item.enhancement_level,
		}


# ============================================================
#  ENCHANTING RENDSZER
# ============================================================

## Enchant alkalmazása item-re
func enchant_item(item: ItemInstance, enchant_cost_gold: int = 200) -> Dictionary:
	if not item or not item.base_item:
		return {"success": false, "reason": "invalid_item"}
	
	if not currency_manager:
		return {"success": false, "reason": "no_currency_manager"}
	
	# Enchant slot ellenőrzés (max 2 enchant per item)
	var current_enchants := _count_enchants(item)
	if current_enchants >= 2:
		return {"success": false, "reason": "max_enchants_reached"}
	
	# Gold cost
	if not currency_manager.can_afford_gold(enchant_cost_gold):
		return {"success": false, "reason": "not_enough_gold"}
	
	currency_manager.spend_gold(enchant_cost_gold)
	
	# Random enchant kiválasztása (nem ismétlődő)
	var used_stats: Array[String] = []
	for affix_entry in item.affixes:
		var affix: AffixData = affix_entry.get("affix")
		if affix:
			used_stats.append(affix.stat_type)
	
	var available := ENCHANT_POOL.filter(func(e): return e["stat"] not in used_stats)
	if available.is_empty():
		return {"success": false, "reason": "no_available_enchants"}
	
	var selected: Dictionary = available[randi() % available.size()]
	var value := randf_range(selected["min_value"], selected["max_value"])
	
	# Affix hozzáadás
	var affix := AffixData.new()
	affix.affix_name = selected["name"]
	affix.affix_type = AffixData.AffixType.SUFFIX
	affix.stat_type = selected["stat"]
	affix.is_percent = selected["is_percent"]
	
	item.affixes.append({"affix": affix, "value": value})
	
	EventBus.enchant_applied.emit(item.uuid, selected["stat"])
	return {
		"success": true,
		"enchant_name": selected["name"],
		"stat": selected["stat"],
		"value": value,
		"is_percent": selected["is_percent"],
	}


## Enchant reroll (meglévő enchant újradobása)
func reroll_enchant(item: ItemInstance, affix_index: int, reroll_cost: int = 300) -> Dictionary:
	if not item or affix_index < 0 or affix_index >= item.affixes.size():
		return {"success": false, "reason": "invalid_params"}
	
	if not currency_manager or not currency_manager.can_afford_gold(reroll_cost):
		return {"success": false, "reason": "not_enough_gold"}
	
	currency_manager.spend_gold(reroll_cost)
	
	var old_affix_entry: Dictionary = item.affixes[affix_index]
	var old_affix: AffixData = old_affix_entry.get("affix")
	if not old_affix:
		return {"success": false, "reason": "invalid_affix"}
	
	# Új random enchant (lehet ugyanaz a stat, de új value)
	var pool_entry: Dictionary = {}
	for e in ENCHANT_POOL:
		if e["stat"] == old_affix.stat_type:
			pool_entry = e
			break
	
	if pool_entry.is_empty():
		# Ha nem találjuk a pool-ban, random újat adunk
		pool_entry = ENCHANT_POOL[randi() % ENCHANT_POOL.size()]
	
	var new_value := randf_range(pool_entry["min_value"], pool_entry["max_value"])
	item.affixes[affix_index]["value"] = new_value
	
	return {
		"success": true,
		"stat": old_affix.stat_type,
		"old_value": old_affix_entry.get("value", 0.0),
		"new_value": new_value,
	}


# ============================================================
#  GEM SOCKET RENDSZER
# ============================================================

## Gem behelyezés socket-be
func socket_gem(item: ItemInstance, socket_index: int, gem_item: ItemInstance) -> Dictionary:
	if not item or not item.base_item:
		return {"success": false, "reason": "invalid_item"}
	
	if not gem_item or not gem_item.base_item:
		return {"success": false, "reason": "invalid_gem"}
	
	if gem_item.base_item.item_type != Enums.ItemType.GEM:
		return {"success": false, "reason": "not_a_gem"}
	
	# Socket létezik?
	if socket_index < 0 or socket_index >= item.base_item.socket_count:
		return {"success": false, "reason": "invalid_socket"}
	
	# Socket slot inicializálás ha szükséges
	while item.sockets.size() < item.base_item.socket_count:
		item.sockets.append(null)
	
	# Socket foglalt?
	if item.sockets[socket_index] != null:
		return {"success": false, "reason": "socket_occupied"}
	
	# Gold cost
	if not currency_manager or not currency_manager.can_afford_gold(Constants.GEM_INSERT_COST):
		return {"success": false, "reason": "not_enough_gold"}
	
	currency_manager.spend_gold(Constants.GEM_INSERT_COST)
	
	# Gem behelyezés
	item.sockets[socket_index] = gem_item
	
	# Gem eltávolítás inventory-ból
	if inventory_manager:
		inventory_manager.remove_item_by_uuid(gem_item.uuid)
	
	EventBus.gem_socketed.emit(item.uuid, gem_item.rarity)
	return {"success": true, "socket_index": socket_index}


## Gem eltávolítása socket-ből
func unsocket_gem(item: ItemInstance, socket_index: int) -> Dictionary:
	if not item or not item.base_item:
		return {"success": false, "reason": "invalid_item"}
	
	if socket_index < 0 or socket_index >= item.sockets.size():
		return {"success": false, "reason": "invalid_socket"}
	
	if item.sockets[socket_index] == null:
		return {"success": false, "reason": "socket_empty"}
	
	# Gold cost
	if not currency_manager or not currency_manager.can_afford_gold(Constants.GEM_REMOVE_COST):
		return {"success": false, "reason": "not_enough_gold"}
	
	# Szabad hely ellenőrzés
	if not inventory_manager or not inventory_manager.has_free_slot():
		return {"success": false, "reason": "inventory_full"}
	
	currency_manager.spend_gold(Constants.GEM_REMOVE_COST)
	
	# Gem visszaadás
	var gem: ItemInstance = item.sockets[socket_index]
	item.sockets[socket_index] = null
	inventory_manager.add_item(gem)
	
	EventBus.gem_removed.emit(item.uuid, socket_index)
	return {"success": true, "gem": gem}


# ============================================================
#  STAT REROLL
# ============================================================

## Item stat reroll (drága, endgame feature)
func reroll_item_stats(item: ItemInstance, cost_gold: int = 500) -> Dictionary:
	if not item or not item.base_item:
		return {"success": false, "reason": "invalid_item"}
	
	if item.affixes.is_empty():
		return {"success": false, "reason": "no_affixes"}
	
	if not currency_manager or not currency_manager.can_afford_gold(cost_gold):
		return {"success": false, "reason": "not_enough_gold"}
	
	currency_manager.spend_gold(cost_gold)
	
	# Minden affix value újradobása
	for affix_entry in item.affixes:
		var affix: AffixData = affix_entry.get("affix")
		if affix:
			affix_entry["value"] = affix.roll_value(item.item_level)
	
	return {"success": true}


# ============================================================
#  SEGÉDFÜGGVÉNYEK
# ============================================================

func _count_enchants(item: ItemInstance) -> int:
	# Enchant-okat a SUFFIX típusú affix-ek számával számoljuk
	var count := 0
	for affix_entry in item.affixes:
		var affix: AffixData = affix_entry.get("affix")
		if affix and affix.affix_type == AffixData.AffixType.SUFFIX:
			count += 1
	return count

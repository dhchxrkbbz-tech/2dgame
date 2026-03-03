## SocketSystem - Gem behelyezés, eltávolítás, szinergia logika
## A 09_gem_system_plan.txt 4-5. és 10. fejezete alapján
class_name SocketSystem
extends RefCounted

## Szinergia bónuszok
const MATCHING_BONUS: float = 0.20    # +20% ha minden socket-ben azonos gem típus
const RAINBOW_BONUS: float = 0.05     # +5% All Stats ha 3+ különböző gem típus
const RAINBOW_MIN_TYPES: int = 3

## Socket count generálás rarity alapján
## Returns: socket szám az item-hez
static func generate_socket_count(rarity: Enums.Rarity) -> int:
	match rarity:
		Enums.Rarity.COMMON:
			return 0
		Enums.Rarity.UNCOMMON:
			# 30% esély 1-re
			return 1 if randf() < 0.30 else 0
		Enums.Rarity.RARE:
			# Garantált 1, 40% esély +1
			return 2 if randf() < 0.40 else 1
		Enums.Rarity.EPIC:
			# Garantált 1, +1 50%, +1 25%
			var count := 1
			if randf() < 0.50:
				count += 1
			if count >= 2 and randf() < 0.25:
				count += 1
			return count
		Enums.Rarity.LEGENDARY:
			# Garantált 2, +1 50%, +1 30%
			var count := 2
			if randf() < 0.50:
				count += 1
			if count >= 3 and randf() < 0.30:
				count += 1
			return count
		_:
			return 0


## Maximum socket szám rarity alapján
static func get_max_sockets(rarity: Enums.Rarity) -> int:
	match rarity:
		Enums.Rarity.COMMON: return 0
		Enums.Rarity.UNCOMMON: return 1
		Enums.Rarity.RARE: return 2
		Enums.Rarity.EPIC: return 3
		Enums.Rarity.LEGENDARY: return 4
		_: return 0


## Socket tömb inicializálása item-hez
static func initialize_sockets(item: ItemInstance) -> void:
	if not item or not item.base_item:
		return
	var count := item.base_item.socket_count
	if count <= 0:
		count = generate_socket_count(item.rarity)
	item.sockets.clear()
	item.sockets.resize(count)
	for i in count:
		item.sockets[i] = null


## Gem behelyezés socket-be
## Returns: true ha sikerült
static func insert_gem(item: ItemInstance, socket_index: int, gem: GemInstance) -> bool:
	if not item or not gem:
		return false
	if socket_index < 0 or socket_index >= item.sockets.size():
		return false
	if item.sockets[socket_index] != null:
		return false  # Socket foglalt

	# Legendary gem korlátozások
	if gem.is_legendary:
		if not item.base_item:
			return false
		if not GemStatTable.is_accessory_slot(item.base_item.equip_slot):
			return false  # Legendary csak accessory-ba
		if has_legendary_gem(item):
			return false  # Max 1 legendary per item

	item.sockets[socket_index] = gem
	_recalculate_item_gem_stats(item)

	EventBus.emit_signal("gem_socketed", item.uuid, gem.gem_type)
	return true


## Gem eltávolítás socket-ből (gold fizetéssel, gem megmarad)
## Returns: az eltávolított GemInstance, vagy null ha nem sikerült
static func remove_gem(item: ItemInstance, socket_index: int, pay_gold: bool = true) -> GemInstance:
	if not item:
		return null
	if socket_index < 0 or socket_index >= item.sockets.size():
		return null
	var gem: GemInstance = item.sockets[socket_index]
	if gem == null:
		return null

	if pay_gold:
		var cost := get_removal_cost(gem)
		# Economy rendszer ellenőrzés (ha elérhető)
		if Engine.has_singleton("PlayerEconomy") or true:
			# A tényleges gold levonás a hívó felelőssége
			pass

	item.sockets[socket_index] = null
	_recalculate_item_gem_stats(item)

	EventBus.emit_signal("gem_removed", item.uuid, socket_index)

	if pay_gold:
		return gem  # Gem visszakapva
	else:
		return null  # Gem elpusztul (destroy opció)


## Gem csere (swap): régi kikerül, új bekerül
## Returns: a régi GemInstance (removal cost-tal), vagy null
static func swap_gem(item: ItemInstance, socket_index: int, new_gem: GemInstance) -> GemInstance:
	if not item or not new_gem:
		return null
	if socket_index < 0 or socket_index >= item.sockets.size():
		return null

	var old_gem := remove_gem(item, socket_index, true)
	if not insert_gem(item, socket_index, new_gem):
		# Ha nem sikerült az új beszúrása, tegyük vissza a régit
		if old_gem:
			item.sockets[socket_index] = old_gem
			_recalculate_item_gem_stats(item)
		return null
	return old_gem


## Eltávolítási költség kiszámítása
static func get_removal_cost(gem: GemInstance) -> int:
	if not gem:
		return 0
	if gem.is_legendary:
		return 2000
	return 100 * (gem.gem_tier + 1)


## Van-e legendary gem az item-ben?
static func has_legendary_gem(item: ItemInstance) -> bool:
	if not item:
		return false
	for gem in item.sockets:
		if gem is GemInstance and gem.is_legendary:
			return true
	return false


## Socket bővítés lehetőség ellenőrzés (Jeweler NPC)
static func can_add_socket(item: ItemInstance) -> bool:
	if not item or not item.base_item:
		return false
	# Csak rare+ item-ek bővíthetőek
	if item.rarity < Enums.Rarity.RARE:
		return false
	var max_sockets := get_max_sockets(item.rarity)
	return item.sockets.size() < max_sockets


## Socket bővítés költsége
static func get_add_socket_cost(item: ItemInstance) -> Dictionary:
	if not item:
		return {"gold": 0, "dark_essence": 0}
	var current_count := item.sockets.size()
	return {
		"gold": 500 * (current_count + 1),
		"dark_essence": 1,
	}


## Socket bővítés végrehajtása
static func add_socket(item: ItemInstance) -> bool:
	if not can_add_socket(item):
		return false
	item.sockets.append(null)
	if item.base_item:
		item.base_item.socket_count = item.sockets.size()
	return true


## Matching bónusz ellenőrzés: minden socket-ben azonos gem típus?
static func get_matching_bonus(item: ItemInstance) -> float:
	if not item or item.sockets.size() < 2:
		return 0.0

	var filled_gems: Array[GemInstance] = []
	for gem in item.sockets:
		if gem is GemInstance and not gem.is_legendary:
			filled_gems.append(gem)

	if filled_gems.size() < 2:
		return 0.0

	var first_type: Enums.GemType = filled_gems[0].gem_type
	for gem in filled_gems:
		if gem.gem_type != first_type:
			return 0.0

	return MATCHING_BONUS


## Rainbow bónusz ellenőrzés: 3+ különböző gem típus?
static func get_rainbow_bonus(item: ItemInstance) -> float:
	if not item or item.sockets.size() < RAINBOW_MIN_TYPES:
		return 0.0

	var types: Array[int] = []
	for gem in item.sockets:
		if gem is GemInstance and not gem.is_legendary:
			if gem.gem_type not in types:
				types.append(gem.gem_type)

	if types.size() >= RAINBOW_MIN_TYPES:
		return RAINBOW_BONUS
	return 0.0


## Item gem stat-ok újraszámítása (matching/rainbow bónuszokkal)
static func _recalculate_item_gem_stats(item: ItemInstance) -> void:
	# Az ItemInstance.get_total_stats() automatikusan hívja a gem.get_stats()-ot
	# A szinergia bónuszokat itt jelezzük a rendszernek
	pass


## Összes socketed gem stat összesítése egy item-hez (szinergiákkal)
static func get_total_gem_stats(item: ItemInstance) -> Dictionary:
	if not item or not item.base_item:
		return {}

	var stats: Dictionary = {}
	var equip_slot: int = item.base_item.equip_slot

	for gem in item.sockets:
		if gem is GemInstance:
			var gem_stats := gem.get_stats(equip_slot)
			for key in gem_stats:
				stats[key] = stats.get(key, 0.0) + gem_stats[key]

	# Matching bónusz (+20% gem stat)
	var match_bonus := get_matching_bonus(item)
	if match_bonus > 0.0:
		for key in stats:
			stats[key] = stats[key] * (1.0 + match_bonus)

	# Rainbow bónusz (+5% All Stats)
	var rainbow := get_rainbow_bonus(item)
	if rainbow > 0.0:
		stats["all_stats_percent"] = stats.get("all_stats_percent", 0.0) + rainbow * 100.0

	return stats


## Socket állapot szöveges összefoglaló
static func get_socket_summary(item: ItemInstance) -> String:
	if not item or item.sockets.is_empty():
		return ""

	var filled := 0
	for gem in item.sockets:
		if gem != null:
			filled += 1

	var text := "Sockets: %d/%d\n" % [filled, item.sockets.size()]

	for i in item.sockets.size():
		var gem: GemInstance = item.sockets[i]
		if gem:
			text += "  [%d] %s\n" % [i + 1, gem.get_display_name()]
		else:
			text += "  [%d] (empty)\n" % [i + 1]

	var match_bonus := get_matching_bonus(item)
	if match_bonus > 0.0:
		text += "  Matching Bonus: +%d%% gem stats\n" % [int(match_bonus * 100)]

	var rainbow := get_rainbow_bonus(item)
	if rainbow > 0.0:
		text += "  Rainbow Bonus: +%d%% All Stats\n" % [int(rainbow * 100)]

	return text

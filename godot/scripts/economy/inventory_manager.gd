## InventoryManager - Inventory, Equipment és Stash kezelés
## Slot-alapú rendszer drag & drop támogatással
class_name InventoryManager
extends Node

# Inventory slot-ok (Array of ItemInstance or null)
var inventory: Array = []
var stash: Array = []
var equipment: Dictionary = {}  # EquipSlot → ItemInstance

var inventory_size: int = Constants.INVENTORY_DEFAULT_SIZE
var stash_size: int = Constants.STASH_DEFAULT_SIZE


func _ready() -> void:
	_init_slots()


func _init_slots() -> void:
	inventory.resize(inventory_size)
	inventory.fill(null)
	stash.resize(stash_size)
	stash.fill(null)
	
	# Equipment slot-ok inicializálás
	for slot in [
		Enums.EquipSlot.HELMET, Enums.EquipSlot.CHEST,
		Enums.EquipSlot.GLOVES, Enums.EquipSlot.BOOTS,
		Enums.EquipSlot.BELT, Enums.EquipSlot.SHOULDERS,
		Enums.EquipSlot.MAIN_HAND, Enums.EquipSlot.OFF_HAND,
		Enums.EquipSlot.AMULET, Enums.EquipSlot.RING_1,
		Enums.EquipSlot.RING_2, Enums.EquipSlot.CAPE
	]:
		equipment[slot] = null


# ============================================================
#  INVENTORY MŰVELETEK
# ============================================================

## Item hozzáadása inventory-hoz, true ha sikeres
func add_item(item: ItemInstance) -> bool:
	if not item:
		return false
	
	# Stackable item → próbálunk létező stack-hez adni
	if item.base_item and item.base_item.stackable:
		var max_stack := _get_max_stack(item)
		for i in inventory.size():
			var slot_item: ItemInstance = inventory[i]
			if slot_item and slot_item.base_item and slot_item.base_item.item_id == item.base_item.item_id:
				if slot_item.quantity < max_stack:
					var space := max_stack - slot_item.quantity
					var to_add := mini(item.quantity, space)
					slot_item.quantity += to_add
					item.quantity -= to_add
					if item.quantity <= 0:
						EventBus.inventory_changed.emit()
						return true
	
	# Szabad slot keresése
	var free_slot := _find_free_slot()
	if free_slot < 0:
		EventBus.inventory_full.emit()
		return false
	
	inventory[free_slot] = item
	EventBus.inventory_changed.emit()
	EventBus.item_picked_up.emit(item)
	return true


## Item eltávolítása index alapján
func remove_item_at(index: int) -> ItemInstance:
	if index < 0 or index >= inventory.size():
		return null
	var item: ItemInstance = inventory[index]
	inventory[index] = null
	if item:
		EventBus.inventory_changed.emit()
	return item


## Item eltávolítása UUID alapján
func remove_item_by_uuid(uuid: String) -> ItemInstance:
	for i in inventory.size():
		var item: ItemInstance = inventory[i]
		if item and item.uuid == uuid:
			inventory[i] = null
			EventBus.inventory_changed.emit()
			return item
	return null


## Item keresése UUID alapján
func find_item_by_uuid(uuid: String) -> ItemInstance:
	for item in inventory:
		if item and item.uuid == uuid:
			return item
	return null


## Item keresése base_item_id alapján (material keresés pl.)
func find_items_by_id(item_id: String) -> Array[ItemInstance]:
	var results: Array[ItemInstance] = []
	for item in inventory:
		if item and item.base_item and item.base_item.item_id == item_id:
			results.append(item)
	return results


## Anyag összeszámlálás (crafting ellenőrzéshez)
func count_item(item_id: String) -> int:
	var total := 0
	for item in inventory:
		if item and item.base_item and item.base_item.item_id == item_id:
			total += item.quantity
	return total


## Anyag felhasználás (craftinghoz - elvesz adott mennyiséget)
func consume_item(item_id: String, amount: int) -> bool:
	if count_item(item_id) < amount:
		return false
	
	var remaining := amount
	for i in inventory.size():
		if remaining <= 0:
			break
		var item: ItemInstance = inventory[i]
		if item and item.base_item and item.base_item.item_id == item_id:
			if item.quantity <= remaining:
				remaining -= item.quantity
				inventory[i] = null
			else:
				item.quantity -= remaining
				remaining = 0
	
	EventBus.inventory_changed.emit()
	return true


## Slot csere (drag & drop)
func swap_slots(from: int, to: int) -> void:
	if from < 0 or from >= inventory.size():
		return
	if to < 0 or to >= inventory.size():
		return
	
	var temp: ItemInstance = inventory[from]
	inventory[from] = inventory[to]
	inventory[to] = temp
	EventBus.inventory_changed.emit()


## Stack split
func split_stack(slot_index: int, amount: int) -> bool:
	if slot_index < 0 or slot_index >= inventory.size():
		return false
	var item: ItemInstance = inventory[slot_index]
	if not item or item.quantity <= amount:
		return false
	
	var free_slot := _find_free_slot()
	if free_slot < 0:
		EventBus.inventory_full.emit()
		return false
	
	# Új instance készítése
	var split_item := ItemInstance.new()
	split_item.base_item = item.base_item
	split_item.item_level = item.item_level
	split_item.rarity = item.rarity
	split_item.affixes = item.affixes.duplicate(true)
	split_item.sockets = item.sockets.duplicate()
	split_item.enhancement_level = item.enhancement_level
	split_item.quantity = amount
	
	item.quantity -= amount
	inventory[free_slot] = split_item
	EventBus.inventory_changed.emit()
	return true


## Van-e szabad hely?
func has_free_slot() -> bool:
	return _find_free_slot() >= 0


## Szabad slot-ok száma
func get_free_slot_count() -> int:
	var count := 0
	for slot in inventory:
		if slot == null:
			count += 1
	return count


## Inventory bővítés (gold sink)
func expand_inventory(extra_slots: int) -> void:
	inventory_size = mini(inventory_size + extra_slots, Constants.INVENTORY_MAX_SIZE)
	inventory.resize(inventory_size)


# ============================================================
#  EQUIPMENT MŰVELETEK
# ============================================================

## Item felszerelése
func equip_item(item: ItemInstance) -> ItemInstance:
	if not item or not item.base_item:
		return null
	
	var slot: int = item.base_item.equip_slot
	
	# Korábbi gear eltávolítása
	var old_item: ItemInstance = equipment.get(slot)
	equipment[slot] = item
	
	# Eltávolítás inventory-ból ha benne van
	for i in inventory.size():
		if inventory[i] == item:
			inventory[i] = null
			break
	
	# Régi gear visszarakása inventory-ba
	if old_item:
		add_item(old_item)
	
	EventBus.equipment_changed.emit(slot)
	EventBus.item_equipped.emit(null, item, slot)
	EventBus.inventory_changed.emit()
	return old_item


## Equipment levételre 
func unequip_item(slot: int) -> bool:
	var item: ItemInstance = equipment.get(slot)
	if not item:
		return false
	
	if not has_free_slot():
		EventBus.inventory_full.emit()
		return false
	
	equipment[slot] = null
	add_item(item)
	EventBus.equipment_changed.emit(slot)
	EventBus.item_unequipped.emit(null, slot)
	return true


## Felszerelt item lekérdezés
func get_equipped_item(slot: int) -> ItemInstance:
	return equipment.get(slot)


## Összes equipment stat összegyűjtése
func get_total_equipment_stats() -> Dictionary:
	var stats: Dictionary = {}
	for slot in equipment:
		var item: ItemInstance = equipment[slot]
		if item:
			var item_stats := item.get_total_stats()
			for key in item_stats:
				stats[key] = stats.get(key, 0.0) + item_stats[key]
	return stats


# ============================================================
#  STASH MŰVELETEK
# ============================================================

## Item áthelyezése stash-be
func move_to_stash(inventory_index: int) -> bool:
	var item: ItemInstance = inventory[inventory_index]
	if not item:
		return false
	
	var free := _find_free_stash_slot()
	if free < 0:
		return false
	
	inventory[inventory_index] = null
	stash[free] = item
	EventBus.inventory_changed.emit()
	EventBus.stash_changed.emit()
	return true


## Item áthelyezése stash-ből inventory-ba
func move_from_stash(stash_index: int) -> bool:
	var item: ItemInstance = stash[stash_index]
	if not item:
		return false
	
	var free := _find_free_slot()
	if free < 0:
		EventBus.inventory_full.emit()
		return false
	
	stash[stash_index] = null
	inventory[free] = item
	EventBus.stash_changed.emit()
	EventBus.inventory_changed.emit()
	return true


# ============================================================
#  RENDEZÉS
# ============================================================

## Inventory rendezés (rarity → type → level)
func sort_inventory() -> void:
	var items: Array[ItemInstance] = []
	for item in inventory:
		if item:
			items.append(item)
	
	items.sort_custom(func(a: ItemInstance, b: ItemInstance) -> bool:
		# Rarity csökkenő
		if a.rarity != b.rarity:
			return a.rarity > b.rarity
		# Type növekvő
		if a.base_item and b.base_item:
			if a.base_item.item_type != b.base_item.item_type:
				return a.base_item.item_type < b.base_item.item_type
		# Level csökkenő
		return a.item_level > b.item_level
	)
	
	inventory.fill(null)
	for i in items.size():
		if i < inventory.size():
			inventory[i] = items[i]
	
	EventBus.inventory_changed.emit()


# ============================================================
#  SEGÉDFÜGGVÉNYEK
# ============================================================

func _find_free_slot() -> int:
	for i in inventory.size():
		if inventory[i] == null:
			return i
	return -1


func _find_free_stash_slot() -> int:
	for i in stash.size():
		if stash[i] == null:
			return i
	return -1


func _get_max_stack(item: ItemInstance) -> int:
	if not item or not item.base_item:
		return 1
	if not item.base_item.stackable:
		return 1
	match item.base_item.item_type:
		Enums.ItemType.CONSUMABLE:
			return Constants.STACK_LIMIT_CONSUMABLE
		Enums.ItemType.MATERIAL:
			return Constants.STACK_LIMIT_MATERIAL
		_:
			return item.base_item.max_stack


# ============================================================
#  SERIALIZE / DESERIALIZE
# ============================================================

func serialize() -> Dictionary:
	var inv_data: Array = []
	for item in inventory:
		if item:
			inv_data.append(item.serialize())
		else:
			inv_data.append(null)
	
	var stash_data: Array = []
	for item in stash:
		if item:
			stash_data.append(item.serialize())
		else:
			stash_data.append(null)
	
	var equip_data: Dictionary = {}
	for slot in equipment:
		if equipment[slot]:
			equip_data[str(slot)] = equipment[slot].serialize()
	
	return {
		"inventory_size": inventory_size,
		"inventory": inv_data,
		"stash": stash_data,
		"equipment": equip_data,
	}


func deserialize(data: Dictionary) -> void:
	if data.has("inventory_size"):
		inventory_size = data["inventory_size"]
	
	_init_slots()
	
	# Inventory betöltés
	if data.has("inventory"):
		var inv_data: Array = data["inventory"]
		for i in mini(inv_data.size(), inventory.size()):
			if inv_data[i] != null:
				inventory[i] = _deserialize_item(inv_data[i])
	
	# Stash betöltés
	if data.has("stash"):
		var stash_data: Array = data["stash"]
		for i in mini(stash_data.size(), stash.size()):
			if stash_data[i] != null:
				stash[i] = _deserialize_item(stash_data[i])
	
	# Equipment betöltés
	if data.has("equipment"):
		var equip_data: Dictionary = data["equipment"]
		for slot_str in equip_data:
			var slot := int(slot_str)
			equipment[slot] = _deserialize_item(equip_data[slot_str])
	
	EventBus.inventory_changed.emit()


func _deserialize_item(data: Dictionary) -> ItemInstance:
	if not data:
		return null
	var item := ItemInstance.new()
	item.uuid = data.get("uuid", ItemInstance._generate_uuid())
	item.item_level = data.get("item_level", 1)
	item.rarity = data.get("rarity", Enums.Rarity.COMMON)
	item.enhancement_level = data.get("enhancement_level", 0)
	item.quantity = data.get("quantity", 1)
	
	# Base item keresése az ItemDatabase-ből
	var base_id: String = data.get("base_item_id", "")
	if not base_id.is_empty():
		item.base_item = ItemDatabase.get_item(base_id)
	
	# Affix-ek visszaállítása
	if data.has("affixes"):
		for affix_data in data["affixes"]:
			var affix := AffixData.new()
			affix.affix_name = affix_data.get("name", "")
			affix.affix_type = affix_data.get("type", 0)
			affix.stat_type = affix_data.get("stat", "")
			affix.is_percent = affix_data.get("is_percent", false)
			item.affixes.append({"affix": affix, "value": affix_data.get("value", 0.0)})
	
	return item

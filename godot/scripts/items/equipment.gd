## Equipment - Felszerelt gear kezelés
## 11 slot: Helmet, Chest, Gloves, Boots, Belt, Shoulders, MainHand, OffHand, Amulet, Ring1, Ring2, Cape
class_name Equipment
extends RefCounted

## Felszerelt item-ek slot szerint
var slots: Dictionary = {}  # { Enums.EquipSlot: ItemInstance }

## Set részvétel nyilvántartás
var _active_set_pieces: Dictionary = {}  # { set_id: count }


func _init() -> void:
	# Minden slot üres
	for slot_value in [
		Enums.EquipSlot.HELMET, Enums.EquipSlot.CHEST, Enums.EquipSlot.GLOVES,
		Enums.EquipSlot.BOOTS, Enums.EquipSlot.BELT, Enums.EquipSlot.SHOULDERS,
		Enums.EquipSlot.MAIN_HAND, Enums.EquipSlot.OFF_HAND,
		Enums.EquipSlot.AMULET, Enums.EquipSlot.RING_1, Enums.EquipSlot.RING_2,
		Enums.EquipSlot.CAPE
	]:
		slots[slot_value] = null


## Item felszerelés – visszaadja a korábban felszerelt item-et (vagy null)
func equip(item: ItemInstance) -> ItemInstance:
	if not item or not item.base_item:
		return null
	
	var slot: int = item.base_item.equip_slot
	
	# Ring kezelés: ha Ring1 foglalt, próbáld Ring2-be
	if slot == Enums.EquipSlot.RING_1 and slots.get(Enums.EquipSlot.RING_1) != null:
		if slots.get(Enums.EquipSlot.RING_2) == null:
			slot = Enums.EquipSlot.RING_2
	
	# Régi item
	var old_item: ItemInstance = slots.get(slot)
	
	# Felszerelés
	slots[slot] = item
	
	# Set tracking frissítés
	_recalculate_sets()
	
	EventBus.emit_signal("item_equipped", null, item, slot)
	EventBus.emit_signal("equipment_changed", slot)
	
	return old_item


## Item levétel slot alapján – visszaadja a levett item-et
func unequip(slot: int) -> ItemInstance:
	var item: ItemInstance = slots.get(slot)
	if not item:
		return null
	
	slots[slot] = null
	_recalculate_sets()
	
	EventBus.emit_signal("item_unequipped", null, slot)
	EventBus.emit_signal("equipment_changed", slot)
	
	return item


## Slot lekérdezés
func get_equipped(slot: int) -> ItemInstance:
	return slots.get(slot)


## Van-e valami ebben a slot-ban?
func is_slot_occupied(slot: int) -> bool:
	return slots.get(slot) != null


## Összes felszerelt item stat összesítés
func get_total_stats() -> Dictionary:
	var total: Dictionary = {}
	
	for slot in slots:
		var item: ItemInstance = slots[slot]
		if not item:
			continue
		
		var item_stats := item.get_total_stats()
		for key in item_stats:
			total[key] = total.get(key, 0.0) + item_stats[key]
	
	# Set bónuszok hozzáadása
	var set_bonuses := get_active_set_bonuses()
	for bonus in set_bonuses:
		var bonus_stats: Dictionary = bonus.get("stats", {})
		for key in bonus_stats:
			total[key] = total.get(key, 0.0) + bonus_stats[key]
	
	return total


## Aktív set bónuszok
func get_active_set_bonuses() -> Array[Dictionary]:
	return SetItemData.get_active_bonuses(_active_set_pieces)


## Set darabszám frissítés
func _recalculate_sets() -> void:
	_active_set_pieces.clear()
	
	for slot in slots:
		var item: ItemInstance = slots[slot]
		if not item:
			continue
		if item.set_id.is_empty():
			continue
		_active_set_pieces[item.set_id] = _active_set_pieces.get(item.set_id, 0) + 1


## Ellenőrzi, hogy egy item felszerelhető-e
func can_equip(item: ItemInstance, player_level: int, player_class: int) -> Dictionary:
	var result: Dictionary = {"can_equip": true, "reason": ""}
	
	if not item or not item.base_item:
		result["can_equip"] = false
		result["reason"] = "Invalid item"
		return result
	
	# Level check
	if item.base_item.required_level > player_level:
		result["can_equip"] = false
		result["reason"] = "Requires level %d" % item.base_item.required_level
		return result
	
	# Class check
	if item.base_item.required_class >= 0 and item.base_item.required_class != player_class:
		var class_names := ["Assassin", "Tank", "Mage"]
		var req_class_name: String = class_names[item.base_item.required_class] if item.base_item.required_class < class_names.size() else "Unknown"
		result["can_equip"] = false
		result["reason"] = "Requires: %s" % req_class_name
		return result
	
	# Item type check (only gear)
	if item.base_item.item_type in [Enums.ItemType.CONSUMABLE, Enums.ItemType.MATERIAL, Enums.ItemType.QUEST_ITEM]:
		result["can_equip"] = false
		result["reason"] = "Cannot equip this item type"
		return result
	
	return result


## Összes felszerelt item DPS
func get_total_dps() -> float:
	var weapon: ItemInstance = slots.get(Enums.EquipSlot.MAIN_HAND)
	if not weapon or not weapon.base_item:
		return 0.0
	
	var stats := weapon.get_total_stats()
	var phys_dmg: float = stats.get("physical_damage", 0.0)
	var atk_speed: float = 1.0 + stats.get("attack_speed", 0.0) / 100.0
	return phys_dmg * atk_speed


## Serialize
func serialize() -> Dictionary:
	var data: Dictionary = {}
	for slot in slots:
		if slots[slot]:
			data[str(slot)] = slots[slot].serialize()
		else:
			data[str(slot)] = null
	return data


## Deserialize
func deserialize(data: Dictionary) -> void:
	for key in data:
		var slot: int = int(key)
		if data[key] != null and data[key] is Dictionary:
			slots[slot] = ItemInstance.deserialize(data[key])
		else:
			slots[slot] = null
	_recalculate_sets()

## Inventory - Játékos inventory kezelés
## 6×8 = 48 slot grid + quick slot-ok consumable-nak
class_name Inventory
extends RefCounted

const GRID_COLS: int = 6
const GRID_ROWS: int = 8
const MAX_SLOTS: int = GRID_COLS * GRID_ROWS  # 48
const QUICK_SLOTS: int = 4

var items: Array = []  # Array[ItemInstance or null], MAX_SLOTS méretű
var quick_slots: Array = []  # Array[ItemInstance or null], QUICK_SLOTS méretű
var _owner_id: int = -1  # Multiplayer owner


func _init() -> void:
	items.resize(MAX_SLOTS)
	items.fill(null)
	quick_slots.resize(QUICK_SLOTS)
	quick_slots.fill(null)


## Item hozzáadás az inventoryhoz (első szabad helyre)
## Returns: true ha sikerült
func add_item(item: ItemInstance) -> bool:
	if not item:
		return false
	
	# Stackable item: keresés meglévő stack-hez
	if item.base_item and item.base_item.stackable:
		for i in items.size():
			if items[i] and items[i].base_item and items[i].base_item.item_id == item.base_item.item_id:
				var max_stack: int = item.base_item.max_stack
				if max_stack <= 1:
					max_stack = Constants.STACK_LIMIT_MATERIAL if item.base_item.item_type == Enums.ItemType.MATERIAL else Constants.STACK_LIMIT_CONSUMABLE
				if items[i].quantity < max_stack:
					var space := max_stack - items[i].quantity
					var to_add := mini(item.quantity, space)
					items[i].quantity += to_add
					item.quantity -= to_add
					if item.quantity <= 0:
						EventBus.emit_signal("inventory_changed")
						return true
	
	# Szabad hely keresés
	var slot := _find_free_slot()
	if slot < 0:
		EventBus.emit_signal("inventory_full")
		return false
	
	items[slot] = item
	EventBus.emit_signal("inventory_changed")
	return true


## Item eltávolítás slot indexből
func remove_item(slot: int) -> ItemInstance:
	if slot < 0 or slot >= MAX_SLOTS:
		return null
	var item: ItemInstance = items[slot]
	items[slot] = null
	EventBus.emit_signal("inventory_changed")
	return item


## Item eltávolítás UUID alapján
func remove_item_by_uuid(uuid: String) -> ItemInstance:
	for i in items.size():
		if items[i] and items[i].uuid == uuid:
			return remove_item(i)
	return null


## Item keresés UUID alapján
func find_item(uuid: String) -> ItemInstance:
	for item in items:
		if item and item.uuid == uuid:
			return item
	return null


## Item keresés slot alapján
func get_item(slot: int) -> ItemInstance:
	if slot < 0 or slot >= MAX_SLOTS:
		return null
	return items[slot]


## Item mozgatás egyik slotból a másikba
func move_item(from_slot: int, to_slot: int) -> bool:
	if from_slot < 0 or from_slot >= MAX_SLOTS:
		return false
	if to_slot < 0 or to_slot >= MAX_SLOTS:
		return false
	if from_slot == to_slot:
		return true
	
	# Swap
	var temp: ItemInstance = items[to_slot]
	items[to_slot] = items[from_slot]
	items[from_slot] = temp
	EventBus.emit_signal("inventory_changed")
	return true


## Quick slot beállítás
func set_quick_slot(quick_index: int, inventory_slot: int) -> void:
	if quick_index < 0 or quick_index >= QUICK_SLOTS:
		return
	if inventory_slot < 0 or inventory_slot >= MAX_SLOTS:
		quick_slots[quick_index] = null
		return
	
	var item: ItemInstance = items[inventory_slot]
	if item and item.base_item and item.base_item.item_type == Enums.ItemType.CONSUMABLE:
		quick_slots[quick_index] = item
	EventBus.emit_signal("inventory_changed")


## Quick slot használat (consumable felhasználás)
func use_quick_slot(quick_index: int) -> ItemInstance:
	if quick_index < 0 or quick_index >= QUICK_SLOTS:
		return null
	
	var item: ItemInstance = quick_slots[quick_index]
	if not item:
		return null
	
	# Quantity csökkentés
	item.quantity -= 1
	if item.quantity <= 0:
		# Eltávolítás az inventory-ból is
		for i in items.size():
			if items[i] == item:
				items[i] = null
				break
		quick_slots[quick_index] = null
	
	EventBus.emit_signal("inventory_changed")
	return item


## Van-e szabad hely?
func has_space() -> bool:
	return _find_free_slot() >= 0


## Szabad slot-ok száma
func free_slot_count() -> int:
	var count := 0
	for item in items:
		if item == null:
			count += 1
	return count


## Teli slot-ok száma
func used_slot_count() -> int:
	return MAX_SLOTS - free_slot_count()


## Szabad slot keresés
func _find_free_slot() -> int:
	for i in items.size():
		if items[i] == null:
			return i
	return -1


## Adott típusú item-ek lekérdezése
func get_items_by_type(item_type: int) -> Array[ItemInstance]:
	var result: Array[ItemInstance] = []
	for item in items:
		if item and item.base_item and item.base_item.item_type == item_type:
			result.append(item)
	return result


## Adott item_id-jű item keresés (material/consumable stackokhoz)
func get_item_count(item_id: String) -> int:
	var total := 0
	for item in items:
		if item and item.base_item and item.base_item.item_id == item_id:
			total += item.quantity
	return total


## Item-ek eltávolítása id és count alapján (crafting)
func consume_items(item_id: String, count: int) -> bool:
	var available := get_item_count(item_id)
	if available < count:
		return false
	
	var remaining := count
	for i in items.size():
		if remaining <= 0:
			break
		if items[i] and items[i].base_item and items[i].base_item.item_id == item_id:
			if items[i].quantity <= remaining:
				remaining -= items[i].quantity
				items[i] = null
			else:
				items[i].quantity -= remaining
				remaining = 0
	
	EventBus.emit_signal("inventory_changed")
	return true


## Rendezés rarity szerint (csökkenő)
func sort_by_rarity() -> void:
	var non_null: Array[ItemInstance] = []
	for item in items:
		if item:
			non_null.append(item)
	
	non_null.sort_custom(func(a, b): return a.rarity > b.rarity)
	
	items.fill(null)
	for i in non_null.size():
		items[i] = non_null[i]
	
	EventBus.emit_signal("inventory_changed")


## Rendezés típus szerint
func sort_by_type() -> void:
	var non_null: Array[ItemInstance] = []
	for item in items:
		if item:
			non_null.append(item)
	
	non_null.sort_custom(func(a, b):
		if not a.base_item or not b.base_item:
			return false
		if a.base_item.item_type != b.base_item.item_type:
			return a.base_item.item_type < b.base_item.item_type
		return a.rarity > b.rarity
	)
	
	items.fill(null)
	for i in non_null.size():
		items[i] = non_null[i]
	
	EventBus.emit_signal("inventory_changed")


## Serialize
func serialize() -> Dictionary:
	var data: Dictionary = {
		"items": [],
		"quick_slots": [],
	}
	for item in items:
		data["items"].append(item.serialize() if item else null)
	for qs in quick_slots:
		data["quick_slots"].append(qs.uuid if qs else "")
	return data


## Deserialize
func deserialize(data: Dictionary) -> void:
	items.fill(null)
	quick_slots.fill(null)
	
	var item_data_arr: Array = data.get("items", [])
	for i in mini(item_data_arr.size(), MAX_SLOTS):
		if item_data_arr[i] != null and item_data_arr[i] is Dictionary:
			items[i] = ItemInstance.deserialize(item_data_arr[i])
	
	# Quick slot-ok visszaállítása UUID alapján
	var qs_data: Array = data.get("quick_slots", [])
	for i in mini(qs_data.size(), QUICK_SLOTS):
		var uuid: String = qs_data[i] if qs_data[i] is String else ""
		if not uuid.is_empty():
			quick_slots[i] = find_item(uuid)

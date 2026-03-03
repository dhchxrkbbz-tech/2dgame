## Stash - NPC stash (Safe Room / város)
## Tabbed storage rendszer, bővíthető
class_name Stash
extends RefCounted

const SLOTS_PER_TAB: int = 48
const BASE_TABS: int = 2
const MAX_TABS: int = 6
const TAB_PRICES: Array[int] = [500, 1000, 2000, 4000]  # 3-6. tab ára

var tabs: Array = []  # Array of Array[ItemInstance or null]
var unlocked_tabs: int = BASE_TABS


func _init() -> void:
	for i in MAX_TABS:
		var tab: Array = []
		tab.resize(SLOTS_PER_TAB)
		tab.fill(null)
		tabs.append(tab)


## Tab vásárlás – returns ár, -1 ha nem vásárolható
func get_next_tab_price() -> int:
	var idx := unlocked_tabs - BASE_TABS
	if idx < 0 or idx >= TAB_PRICES.size():
		return -1
	return TAB_PRICES[idx]


## Tab feloldás
func unlock_tab() -> bool:
	if unlocked_tabs >= MAX_TABS:
		return false
	unlocked_tabs += 1
	EventBus.emit_signal("stash_changed")
	return true


## Item hozzáadás
func add_item(item: ItemInstance, tab_index: int = -1) -> bool:
	if not item:
		return false
	
	# Auto tab keresés ha nincs megadva
	if tab_index < 0:
		for t in unlocked_tabs:
			if _tab_has_space(t):
				tab_index = t
				break
	
	if tab_index < 0 or tab_index >= unlocked_tabs:
		return false
	
	var tab: Array = tabs[tab_index]
	
	# Stackable item: meglévő stack-hez
	if item.base_item and item.base_item.stackable:
		for i in tab.size():
			if tab[i] and tab[i].base_item and tab[i].base_item.item_id == item.base_item.item_id:
				var max_stack: int = item.base_item.max_stack
				if max_stack <= 1:
					max_stack = 99
				if tab[i].quantity < max_stack:
					var space := max_stack - tab[i].quantity
					var to_add := mini(item.quantity, space)
					tab[i].quantity += to_add
					item.quantity -= to_add
					if item.quantity <= 0:
						EventBus.emit_signal("stash_changed")
						return true
	
	# Szabad hely
	for i in tab.size():
		if tab[i] == null:
			tab[i] = item
			EventBus.emit_signal("stash_changed")
			return true
	
	return false


## Item eltávolítás
func remove_item(tab_index: int, slot: int) -> ItemInstance:
	if tab_index < 0 or tab_index >= unlocked_tabs:
		return null
	if slot < 0 or slot >= SLOTS_PER_TAB:
		return null
	
	var item: ItemInstance = tabs[tab_index][slot]
	tabs[tab_index][slot] = null
	EventBus.emit_signal("stash_changed")
	return item


## Item keresés
func get_item(tab_index: int, slot: int) -> ItemInstance:
	if tab_index < 0 or tab_index >= unlocked_tabs:
		return null
	if slot < 0 or slot >= SLOTS_PER_TAB:
		return null
	return tabs[tab_index][slot]


## Összes szabad hely
func total_free_slots() -> int:
	var count := 0
	for t in unlocked_tabs:
		for item in tabs[t]:
			if item == null:
				count += 1
	return count


func _tab_has_space(tab_index: int) -> bool:
	if tab_index >= unlocked_tabs:
		return false
	for item in tabs[tab_index]:
		if item == null:
			return true
	return false


## Serialize
func serialize() -> Dictionary:
	var data: Dictionary = {
		"unlocked_tabs": unlocked_tabs,
		"tabs": [],
	}
	for t in unlocked_tabs:
		var tab_data: Array = []
		for item in tabs[t]:
			tab_data.append(item.serialize() if item else null)
		data["tabs"].append(tab_data)
	return data


## Deserialize
func deserialize(data: Dictionary) -> void:
	unlocked_tabs = data.get("unlocked_tabs", BASE_TABS)
	var tab_data_arr: Array = data.get("tabs", [])
	for t in mini(tab_data_arr.size(), MAX_TABS):
		var tab_items: Array = tab_data_arr[t]
		for i in mini(tab_items.size(), SLOTS_PER_TAB):
			if tab_items[i] != null and tab_items[i] is Dictionary:
				tabs[t][i] = ItemInstance.deserialize(tab_items[i])
			else:
				tabs[t][i] = null

## LootFilter - Loot filter beállítások
## A játékos konfigurálhatja, mit lát a droppolt lootból
class_name LootFilter
extends RefCounted

## Rarity filter (ON/OFF)
var show_common: bool = true
var show_uncommon: bool = true
var show_rare: bool = true
var show_epic: bool = true  # Nem kapcsolható ki
var show_legendary: bool = true  # Nem kapcsolható ki

## Type filter
var show_weapons: bool = true
var show_armor: bool = true
var show_accessories: bool = true
var show_materials: bool = true
var show_consumables: bool = true
var show_gems: bool = true
var show_gold: bool = true

## Auto-pickup
var auto_pickup_gold: bool = true
var auto_pickup_materials: bool = false
var auto_pickup_consumables: bool = false

## Minimum rarity a megjelenítéshez (gyors szűrő)
var min_display_rarity: int = Enums.Rarity.COMMON


## Ellenőrzi, hogy egy item megjelenjen-e
func should_show(item: ItemInstance) -> bool:
	if not item:
		return false
	
	# Rarity check
	match item.rarity:
		Enums.Rarity.COMMON:
			if not show_common:
				return false
		Enums.Rarity.UNCOMMON:
			if not show_uncommon:
				return false
		Enums.Rarity.RARE:
			if not show_rare:
				return false
		Enums.Rarity.EPIC:
			pass  # Mindig látható
		Enums.Rarity.LEGENDARY:
			pass  # Mindig látható
	
	# Min rarity check
	if item.rarity < min_display_rarity:
		return false
	
	# Type check
	if item.base_item:
		match item.base_item.item_type:
			Enums.ItemType.WEAPON:
				if not show_weapons:
					return false
			Enums.ItemType.ARMOR:
				if not show_armor:
					return false
			Enums.ItemType.ACCESSORY:
				if not show_accessories:
					return false
			Enums.ItemType.MATERIAL:
				if not show_materials:
					return false
			Enums.ItemType.CONSUMABLE:
				if not show_consumables:
					return false
			Enums.ItemType.GEM:
				if not show_gems:
					return false
	
	return true


## Ellenőrzi, hogy auto-pickup kell-e
func should_auto_pickup(item: ItemInstance) -> bool:
	if not item:
		return false
	
	if not item.base_item:
		return false
	
	match item.base_item.item_type:
		Enums.ItemType.MATERIAL:
			return auto_pickup_materials
		Enums.ItemType.CONSUMABLE:
			return auto_pickup_consumables
	
	return false


## Preset: korai játék (mindent mutat)
func set_early_game() -> void:
	show_common = true
	show_uncommon = true
	show_rare = true
	min_display_rarity = Enums.Rarity.COMMON


## Preset: mid-game (common rejtett)
func set_mid_game() -> void:
	show_common = false
	show_uncommon = true
	show_rare = true
	min_display_rarity = Enums.Rarity.UNCOMMON


## Preset: endgame (uncommon- rejtett)
func set_endgame() -> void:
	show_common = false
	show_uncommon = false
	show_rare = true
	min_display_rarity = Enums.Rarity.RARE
	auto_pickup_materials = true
	auto_pickup_consumables = true


## Serialize
func serialize() -> Dictionary:
	return {
		"show_common": show_common,
		"show_uncommon": show_uncommon,
		"show_rare": show_rare,
		"show_weapons": show_weapons,
		"show_armor": show_armor,
		"show_accessories": show_accessories,
		"show_materials": show_materials,
		"show_consumables": show_consumables,
		"show_gems": show_gems,
		"show_gold": show_gold,
		"auto_pickup_gold": auto_pickup_gold,
		"auto_pickup_materials": auto_pickup_materials,
		"auto_pickup_consumables": auto_pickup_consumables,
		"min_display_rarity": min_display_rarity,
	}


## Deserialize
func deserialize(data: Dictionary) -> void:
	show_common = data.get("show_common", true)
	show_uncommon = data.get("show_uncommon", true)
	show_rare = data.get("show_rare", true)
	show_weapons = data.get("show_weapons", true)
	show_armor = data.get("show_armor", true)
	show_accessories = data.get("show_accessories", true)
	show_materials = data.get("show_materials", true)
	show_consumables = data.get("show_consumables", true)
	show_gems = data.get("show_gems", true)
	show_gold = data.get("show_gold", true)
	auto_pickup_gold = data.get("auto_pickup_gold", true)
	auto_pickup_materials = data.get("auto_pickup_materials", false)
	auto_pickup_consumables = data.get("auto_pickup_consumables", false)
	min_display_rarity = data.get("min_display_rarity", Enums.Rarity.COMMON)

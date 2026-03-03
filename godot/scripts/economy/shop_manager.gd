## ShopManager - NPC Shop kezelés (vétel, eladás, repair)
## Több shop típus, árazás, buy-back lista
class_name ShopManager
extends Node

## Shop adatbázis: shop_id → ShopData
var _shops: Dictionary = {}

## Aktív shop
var _active_shop: ShopData = null

## Buy-back lista (utolsó 10 eladott item)
var _buyback_list: Array[Dictionary] = []  # [{"item": ItemInstance, "price": int}]
const MAX_BUYBACK: int = 10

## Referenciák
var currency_manager: CurrencyManager = null
var inventory_manager: InventoryManager = null


func _ready() -> void:
	_init_shops()


## Shop adatbázis inicializálás
func _init_shops() -> void:
	# === GENERAL STORE ===
	var general := ShopData.create("general_store", "General Store", Enums.ShopType.GENERAL_STORE, "Merchant")
	general.items = [
		{"item_id": "health_potion_small", "price": 25, "stock": -1},
		{"item_id": "health_potion_medium", "price": 75, "stock": -1},
		{"item_id": "mana_potion_small", "price": 25, "stock": -1},
		{"item_id": "mana_potion_medium", "price": 75, "stock": -1},
		{"item_id": "basic_tool", "price": 30, "stock": -1},
		{"item_id": "crystal_vial", "price": 15, "stock": 20},
		{"item_id": "torch", "price": 5, "stock": -1},
		{"item_id": "rope", "price": 10, "stock": -1},
	]
	general.npc_portrait_color = Color(0.8, 0.7, 0.5)
	_shops["general_store"] = general
	
	# === BLACKSMITH ===
	var blacksmith := ShopData.create("blacksmith", "Blacksmith", Enums.ShopType.BLACKSMITH, "Grumm the Smith")
	blacksmith.items = [
		{"item_id": "iron_sword", "price": 80, "stock": 5},
		{"item_id": "iron_dagger", "price": 60, "stock": 5},
		{"item_id": "iron_staff", "price": 90, "stock": 3},
		{"item_id": "iron_chestplate", "price": 120, "stock": 3},
		{"item_id": "iron_helm", "price": 70, "stock": 3},
		{"item_id": "iron_boots", "price": 50, "stock": 5},
		{"item_id": "leather_gloves", "price": 40, "stock": 5},
	]
	blacksmith.npc_portrait_color = Color(0.6, 0.4, 0.3)
	_shops["blacksmith"] = blacksmith
	
	# === ALCHEMIST ===
	var alchemist := ShopData.create("alchemist", "Alchemy Shop", Enums.ShopType.ALCHEMIST, "Zelda the Alchemist")
	alchemist.items = [
		{"item_id": "health_potion_small", "price": 20, "stock": -1},
		{"item_id": "health_potion_medium", "price": 60, "stock": -1},
		{"item_id": "health_potion_large", "price": 150, "stock": 10},
		{"item_id": "mana_potion_small", "price": 20, "stock": -1},
		{"item_id": "mana_potion_medium", "price": 60, "stock": -1},
		{"item_id": "poison_coat_basic", "price": 80, "stock": 10},
		{"item_id": "damage_scroll", "price": 100, "stock": 5},
		{"item_id": "defense_scroll", "price": 100, "stock": 5},
	]
	alchemist.npc_portrait_color = Color(0.3, 0.7, 0.4)
	_shops["alchemist"] = alchemist
	
	# === ENCHANTER ===
	var enchanter := ShopData.create("enchanter", "Enchanter", Enums.ShopType.ENCHANTER, "Archmage Thorin")
	enchanter.items = [
		{"item_id": "enchant_scroll_crit", "price": 300, "stock": 3},
		{"item_id": "enchant_scroll_lifesteal", "price": 350, "stock": 3},
		{"item_id": "enchant_scroll_armor", "price": 250, "stock": 3},
		{"item_id": "enchant_scroll_speed", "price": 300, "stock": 3},
	]
	enchanter.npc_portrait_color = Color(0.3, 0.3, 0.8)
	_shops["enchanter"] = enchanter
	
	# === RELIC VENDOR (weekly rotating) ===
	var relic := ShopData.create("relic_vendor", "Relic Vendor", Enums.ShopType.RELIC_VENDOR, "The Ancient One")
	relic.is_rotating = true
	relic.rotation_count = 4
	relic.rotation_pool = [
		{"item_id": "legendary_amulet_01", "price": 100, "currency": Enums.CurrencyType.RELIC_FRAGMENT},
		{"item_id": "legendary_ring_01", "price": 80, "currency": Enums.CurrencyType.RELIC_FRAGMENT},
		{"item_id": "legendary_sword_01", "price": 150, "currency": Enums.CurrencyType.RELIC_FRAGMENT},
		{"item_id": "legendary_chest_01", "price": 120, "currency": Enums.CurrencyType.RELIC_FRAGMENT},
		{"item_id": "legendary_helm_01", "price": 90, "currency": Enums.CurrencyType.RELIC_FRAGMENT},
		{"item_id": "legendary_boots_01", "price": 70, "currency": Enums.CurrencyType.RELIC_FRAGMENT},
		{"item_id": "heirloom_xp_boost", "price": 200, "currency": Enums.CurrencyType.RELIC_FRAGMENT},
		{"item_id": "legendary_gem_box", "price": 250, "currency": Enums.CurrencyType.RELIC_FRAGMENT},
	]
	relic.npc_portrait_color = Color(0.6, 0.2, 0.6)
	_shops["relic_vendor"] = relic


## Shop megnyitása
func open_shop(shop_id: String) -> bool:
	var shop: ShopData = _shops.get(shop_id)
	if not shop:
		push_warning("ShopManager: Unknown shop: %s" % shop_id)
		return false
	
	_active_shop = shop
	
	# Rotating shop frissítés
	if shop.is_rotating:
		_refresh_rotating_stock(shop)
	
	var shop_data := {
		"shop_id": shop.shop_id,
		"shop_name": shop.shop_name,
		"npc_name": shop.npc_name,
		"items": shop.items,
	}
	EventBus.shop_opened.emit(shop.shop_type, shop_data)
	return true


## Shop bezárása
func close_shop() -> void:
	_active_shop = null
	EventBus.shop_closed.emit()


## Item vásárlás
func buy_item(shop_item_index: int) -> bool:
	if not _active_shop or not currency_manager or not inventory_manager:
		return false
	
	if shop_item_index < 0 or shop_item_index >= _active_shop.items.size():
		return false
	
	var shop_item: Dictionary = _active_shop.items[shop_item_index]
	var item_id: String = shop_item.get("item_id", "")
	var price: int = shop_item.get("price", 0)
	var stock: int = shop_item.get("stock", -1)
	var currency_type: int = shop_item.get("currency", Enums.CurrencyType.GOLD)
	
	# Stock ellenőrzés
	if stock == 0:
		return false
	
	# Pénz ellenőrzés
	if not currency_manager.can_afford(currency_type, price):
		return false
	
	# Szabad hely ellenőrzés
	if not inventory_manager.has_free_slot():
		EventBus.inventory_full.emit()
		return false
	
	# Vásárlás végrehajtás
	currency_manager.spend_currency(currency_type, price)
	
	# Stock csökkentés
	if stock > 0:
		_active_shop.items[shop_item_index]["stock"] = stock - 1
	
	# Item létrehozása
	var item_data: ItemData = ItemDatabase.get_item(item_id)
	var instance := ItemInstance.new()
	if item_data:
		instance.base_item = item_data
		instance.item_level = item_data.item_level
		instance.rarity = item_data.rarity
	else:
		# Fallback: generált item
		instance = LootGenerator.generate_item(1, Enums.Rarity.COMMON)
	
	instance.quantity = 1
	inventory_manager.add_item(instance)
	
	EventBus.item_bought.emit(null, {"item_id": item_id, "price": price}, price)
	return true


## Item eladás NPC-nek
func sell_item(inventory_index: int) -> bool:
	if not _active_shop or not currency_manager or not inventory_manager:
		return false
	
	var item: ItemInstance = inventory_manager.inventory[inventory_index]
	if not item:
		return false
	
	# Eladási ár: base sell price × NPC multiplier
	var sell_price := int(item.get_sell_price() * Constants.NPC_SELL_MULTIPLIER)
	sell_price = maxi(1, sell_price)
	
	# Item eltávolítás
	var removed := inventory_manager.remove_item_at(inventory_index)
	if not removed:
		return false
	
	# Gold hozzáadás
	currency_manager.add_gold(sell_price)
	
	# Buy-back listához adás
	_buyback_list.push_front({"item": removed, "price": int(sell_price / Constants.NPC_SELL_MULTIPLIER)})
	if _buyback_list.size() > MAX_BUYBACK:
		_buyback_list.resize(MAX_BUYBACK)
	
	EventBus.item_sold.emit(null, {"item_id": removed.base_item.item_id if removed.base_item else ""}, sell_price)
	return true


## Buy-back (visszavásárlás)
func buyback_item(buyback_index: int) -> bool:
	if buyback_index < 0 or buyback_index >= _buyback_list.size():
		return false
	
	var entry: Dictionary = _buyback_list[buyback_index]
	var item: ItemInstance = entry.get("item")
	var price: int = entry.get("price", 0)
	
	if not currency_manager.can_afford_gold(price):
		return false
	
	if not inventory_manager.has_free_slot():
		EventBus.inventory_full.emit()
		return false
	
	currency_manager.spend_gold(price)
	inventory_manager.add_item(item)
	_buyback_list.remove_at(buyback_index)
	return true


## Repair szolgáltatás (gear javítás gold-ért)
func repair_all_equipment() -> int:
	if not currency_manager or not inventory_manager:
		return 0
	
	var total_cost := 0
	for slot in inventory_manager.equipment:
		var item: ItemInstance = inventory_manager.equipment[slot]
		if item and item.base_item:
			var cost := item.item_level * Constants.REPAIR_COST_PER_LEVEL
			cost = int(cost * (1.0 + item.enhancement_level * 0.1))
			total_cost += cost
	
	if total_cost > 0 and currency_manager.spend_gold(total_cost):
		return total_cost
	return 0


## Rotating stock frissítés (Relic Vendor weekly)
func _refresh_rotating_stock(shop: ShopData) -> void:
	if shop.rotation_pool.is_empty():
		return
	
	# Seed a hét száma alapján (deterministic weekly rotation)
	var week_number := int(Time.get_unix_time_from_system() / 604800.0)
	var rng := RandomNumberGenerator.new()
	rng.seed = week_number
	
	var pool := shop.rotation_pool.duplicate()
	shop.items.clear()
	
	for i in mini(shop.rotation_count, pool.size()):
		var idx := rng.randi_range(0, pool.size() - 1)
		var selected: Dictionary = pool[idx].duplicate()
		selected["stock"] = 1  # Rotating item-ek egyszer vásárolhatók
		shop.items.append(selected)
		pool.remove_at(idx)


## Shop lekérdezés
func get_shop(shop_id: String) -> ShopData:
	return _shops.get(shop_id)


func get_active_shop() -> ShopData:
	return _active_shop


func get_buyback_list() -> Array[Dictionary]:
	return _buyback_list


func is_shop_open() -> bool:
	return _active_shop != null

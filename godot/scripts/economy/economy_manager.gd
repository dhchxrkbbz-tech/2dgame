## EconomyManager - Fő gazdasági rendszer singleton (Autoload)
## Összeköti a currency, inventory, crafting, shop, marketplace, upgrade, profession alrendszereket
extends Node

# === Alrendszerek ===
var currency_manager: CurrencyManager = null
var inventory_manager: InventoryManager = null
var crafting_manager: CraftingManager = null
var shop_manager: ShopManager = null
var marketplace_manager: MarketplaceManager = null
var upgrade_manager: UpgradeManager = null
var profession_manager: ProfessionManager = null


func _ready() -> void:
	_init_subsystems()
	_connect_signals()
	print("EconomyManager: Initialized")


func _init_subsystems() -> void:
	# CurrencyManager
	currency_manager = CurrencyManager.new()
	currency_manager.name = "CurrencyManager"
	add_child(currency_manager)
	
	# InventoryManager
	inventory_manager = InventoryManager.new()
	inventory_manager.name = "InventoryManager"
	add_child(inventory_manager)
	
	# ProfessionManager
	profession_manager = ProfessionManager.new()
	profession_manager.name = "ProfessionManager"
	add_child(profession_manager)
	
	# CraftingManager (currency + inventory referenciák)
	crafting_manager = CraftingManager.new()
	crafting_manager.name = "CraftingManager"
	crafting_manager.currency_manager = currency_manager
	crafting_manager.inventory_manager = inventory_manager
	crafting_manager.profession_manager = profession_manager
	add_child(crafting_manager)
	
	# ShopManager
	shop_manager = ShopManager.new()
	shop_manager.name = "ShopManager"
	shop_manager.currency_manager = currency_manager
	shop_manager.inventory_manager = inventory_manager
	add_child(shop_manager)
	
	# MarketplaceManager
	marketplace_manager = MarketplaceManager.new()
	marketplace_manager.name = "MarketplaceManager"
	marketplace_manager.currency_manager = currency_manager
	marketplace_manager.inventory_manager = inventory_manager
	add_child(marketplace_manager)
	
	# UpgradeManager
	upgrade_manager = UpgradeManager.new()
	upgrade_manager.name = "UpgradeManager"
	upgrade_manager.currency_manager = currency_manager
	upgrade_manager.inventory_manager = inventory_manager
	add_child(upgrade_manager)


func _connect_signals() -> void:
	# Enemy kill → gold drop kezelés (loot_generator-rel)
	EventBus.entity_killed.connect(_on_entity_killed)


# ============================================================
#  GYORS HOZZÁFÉRÉS (Shortcut metódusok)
# ============================================================

## Gold lekérdezés
func get_gold() -> int:
	return currency_manager.get_gold()


## Gold hozzáadás
func add_gold(amount: int) -> void:
	currency_manager.add_gold(amount)


## Gold elköltés
func spend_gold(amount: int) -> bool:
	return currency_manager.spend_gold(amount)


## Item hozzáadás inventory-hoz
func add_item(item: ItemInstance) -> bool:
	return inventory_manager.add_item(item)


## Item felszerelés
func equip_item(item: ItemInstance) -> ItemInstance:
	return inventory_manager.equip_item(item)


## Skill reset cost (gold sink)
func pay_skill_reset() -> bool:
	var cost := Constants.SKILL_RESET_BASE_COST
	return currency_manager.spend_gold(cost)


## Fast travel cost (gold sink)
func pay_fast_travel(distance_factor: float = 1.0) -> bool:
	var cost := int(Constants.FAST_TRAVEL_BASE_COST * distance_factor)
	return currency_manager.spend_gold(cost)


## Repair all equipment
func repair_equipment() -> int:
	return shop_manager.repair_all_equipment()


# ============================================================
#  EVENT HANDLERS
# ============================================================

func _on_entity_killed(_killer: Variant, victim: Variant) -> void:
	# Gold generálás enemy kill-ből
	if victim and victim.has_method("get_enemy_tier"):
		var tier: String = victim.get_enemy_tier()
		var level: int = victim.get("level") if victim.get("level") else 1
		var gold := LootGenerator.generate_gold(level, tier)
		if gold > 0:
			currency_manager.add_gold(gold)


# ============================================================
#  SAVE / LOAD
# ============================================================

func serialize() -> Dictionary:
	return {
		"currency": currency_manager.serialize(),
		"inventory": inventory_manager.serialize(),
		"professions": profession_manager.serialize(),
		"marketplace": marketplace_manager.serialize(),
	}


func deserialize(data: Dictionary) -> void:
	if data.has("currency"):
		currency_manager.deserialize(data["currency"])
	if data.has("inventory"):
		inventory_manager.deserialize(data["inventory"])
	if data.has("professions"):
		profession_manager.deserialize(data["professions"])
	if data.has("marketplace"):
		marketplace_manager.deserialize(data["marketplace"])


# ============================================================
#  DEBUG
# ============================================================

## Debug: Gold hozzáadás (console parancs)
func debug_add_gold(amount: int) -> void:
	currency_manager.add_gold(amount)
	print("DEBUG: Added %d gold (total: %d)" % [amount, get_gold()])


## Debug: Item generálás
func debug_generate_item(level: int = 10, rarity: int = Enums.Rarity.RARE) -> void:
	var item := LootGenerator.generate_item(level, rarity)
	if inventory_manager.add_item(item):
		print("DEBUG: Generated %s" % item.get_display_name())
	else:
		print("DEBUG: Inventory full!")


## Debug: Összes currency kiírás
func debug_print_currencies() -> void:
	print("=== CURRENCIES ===")
	print("  Gold: %d" % currency_manager.get_gold())
	print("  Dark Essence: %d" % currency_manager.get_dark_essence())
	print("  Relic Fragments: %d" % currency_manager.get_relic_fragments())
	print("  Sink/Source ratio (gold): %.2f" % currency_manager.get_sink_source_ratio(Enums.CurrencyType.GOLD))


## Debug: Inventory tartalom
func debug_print_inventory() -> void:
	print("=== INVENTORY (%d/%d) ===" % [
		inventory_manager.inventory_size - inventory_manager.get_free_slot_count(),
		inventory_manager.inventory_size
	])
	for i in inventory_manager.inventory.size():
		var item: ItemInstance = inventory_manager.inventory[i]
		if item:
			print("  [%d] %s (Lv%d, x%d)" % [i, item.get_display_name(), item.item_level, item.quantity])

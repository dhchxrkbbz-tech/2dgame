## ShopDatabase - Összes NPC shop regisztrálása
## Plan 16 szekció 10.2 és 14 alapján
class_name ShopDatabase
extends RefCounted

static var _shops: Dictionary = {}  # shop_id -> ShopData
static var _initialized: bool = false


static func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	_register_general_store()
	_register_blacksmith()
	_register_alchemist()
	_register_enchanter()
	_register_relic_vendor()
	_register_traveling_merchant()


static func get_shop(shop_id: String) -> ShopData:
	initialize()
	return _shops.get(shop_id, null)


static func get_all_shops() -> Array[ShopData]:
	initialize()
	var result: Array[ShopData] = []
	for key in _shops:
		result.append(_shops[key])
	return result


static func get_shops_by_type(shop_type: int) -> Array[ShopData]:
	initialize()
	var result: Array[ShopData] = []
	for key in _shops:
		if _shops[key].shop_type == shop_type:
			result.append(_shops[key])
	return result


# =================== GENERAL STORE ===================

static func _register_general_store() -> void:
	var shop := ShopData.create("general_store", "General Store", Enums.ShopType.GENERAL_STORE, "Marcus")
	shop.npc_portrait_color = Color(0.6, 0.5, 0.3)
	shop.items = [
		# Health Potions
		{"item_id": "potion_hp_small", "price": 10, "stock": -1},
		{"item_id": "potion_hp_medium", "price": 40, "stock": -1},
		{"item_id": "potion_hp_large", "price": 120, "stock": -1},
		{"item_id": "potion_hp_super", "price": 300, "stock": -1},
		# Mana Potions
		{"item_id": "potion_mp_small", "price": 10, "stock": -1},
		{"item_id": "potion_mp_medium", "price": 40, "stock": -1},
		{"item_id": "potion_mp_large", "price": 120, "stock": -1},
		{"item_id": "potion_mp_super", "price": 300, "stock": -1},
		# Scrolls
		{"item_id": "scroll_town", "price": 25, "stock": -1},
		{"item_id": "scroll_identify", "price": 15, "stock": -1},
		# Antidote
		{"item_id": "potion_antidote", "price": 30, "stock": -1},
		# Basic crafting mats
		{"item_id": "mat_iron_ore", "price": 8, "stock": 20},
		{"item_id": "mat_leather", "price": 6, "stock": 20},
	]
	_shops[shop.shop_id] = shop


# =================== BLACKSMITH ===================

static func _register_blacksmith() -> void:
	var shop := ShopData.create("blacksmith", "Blacksmith", Enums.ShopType.BLACKSMITH, "Gromm")
	shop.npc_portrait_color = Color(0.5, 0.3, 0.2)
	shop.items = [
		# Tier 1-3 fegyverek
		{"item_id": "sword_t1", "price": 50, "stock": 3},
		{"item_id": "sword_t2", "price": 200, "stock": 2},
		{"item_id": "sword_t3", "price": 600, "stock": 1},
		{"item_id": "dagger_t1", "price": 40, "stock": 3},
		{"item_id": "dagger_t2", "price": 180, "stock": 2},
		{"item_id": "dagger_t3", "price": 550, "stock": 1},
		{"item_id": "axe_t1", "price": 55, "stock": 3},
		{"item_id": "axe_t2", "price": 220, "stock": 2},
		{"item_id": "axe_t3", "price": 650, "stock": 1},
		{"item_id": "staff_t1", "price": 45, "stock": 3},
		{"item_id": "staff_t2", "price": 190, "stock": 2},
		{"item_id": "wand_t1", "price": 40, "stock": 3},
		{"item_id": "wand_t2", "price": 170, "stock": 2},
		# Tier 1-3 páncélok
		{"item_id": "helm_t1", "price": 30, "stock": 3},
		{"item_id": "helm_t2", "price": 120, "stock": 2},
		{"item_id": "chest_t1", "price": 60, "stock": 3},
		{"item_id": "chest_t2", "price": 240, "stock": 2},
		{"item_id": "gloves_t1", "price": 25, "stock": 3},
		{"item_id": "boots_t1", "price": 25, "stock": 3},
		{"item_id": "belt_t1", "price": 20, "stock": 3},
		{"item_id": "shoulders_t1", "price": 30, "stock": 3},
		# Repair anyagok
		{"item_id": "mat_iron_ore", "price": 8, "stock": 50},
	]
	_shops[shop.shop_id] = shop


# =================== ALCHEMIST ===================

static func _register_alchemist() -> void:
	var shop := ShopData.create("alchemist", "Alchemist", Enums.ShopType.ALCHEMIST, "Elara")
	shop.npc_portrait_color = Color(0.3, 0.6, 0.4)
	shop.items = [
		# Elixirek
		{"item_id": "elixir_str", "price": 150, "stock": 5},
		{"item_id": "elixir_def", "price": 150, "stock": 5},
		{"item_id": "elixir_speed", "price": 150, "stock": 5},
		# Resist potionok
		{"item_id": "potion_fire_resist", "price": 100, "stock": 5},
		{"item_id": "potion_ice_resist", "price": 100, "stock": 5},
		{"item_id": "potion_poison_resist", "price": 100, "stock": 5},
		{"item_id": "potion_antidote", "price": 25, "stock": -1},
		# XP boost
		{"item_id": "potion_xp_boost", "price": 300, "stock": 3},
		# Crafting herbs
		{"item_id": "mat_swamp_moss", "price": 12, "stock": 10},
		{"item_id": "mat_poison_gland", "price": 25, "stock": 5},
	]
	_shops[shop.shop_id] = shop


# =================== ENCHANTER ===================

static func _register_enchanter() -> void:
	var shop := ShopData.create("enchanter", "Enchanter", Enums.ShopType.ENCHANTER, "Arcana")
	shop.npc_portrait_color = Color(0.5, 0.3, 0.8)
	shop.items = [
		# Enchanting materials
		{"item_id": "mat_enchant_dust", "price": 30, "stock": 20},
		{"item_id": "mat_soul_fragment", "price": 60, "stock": 10},
		{"item_id": "mat_soul_gem", "price": 200, "stock": 3},
		# Gem related
		{"item_id": "mat_mountain_crystal", "price": 80, "stock": 5},
		# Kiegészítők
		{"item_id": "amulet_t2", "price": 300, "stock": 2},
		{"item_id": "ring_t2", "price": 250, "stock": 2},
		{"item_id": "cape_t2", "price": 280, "stock": 2},
	]
	_shops[shop.shop_id] = shop


# =================== RELIC VENDOR ===================

static func _register_relic_vendor() -> void:
	var shop := ShopData.create("relic_vendor", "Relic Vendor", Enums.ShopType.RELIC_VENDOR, "The Collector")
	shop.npc_portrait_color = Color(0.8, 0.6, 0.1)
	shop.is_rotating = true
	shop.rotation_count = 4
	# A rotating pool-ból random választ hetente
	shop.rotation_pool = [
		{"item_id": "amulet_t4", "price": 5000, "stock": 1},
		{"item_id": "ring_t4", "price": 4500, "stock": 1},
		{"item_id": "cape_t4", "price": 4800, "stock": 1},
		{"item_id": "helm_t6", "price": 6000, "stock": 1},
		{"item_id": "chest_t6", "price": 8000, "stock": 1},
		{"item_id": "sword_t6", "price": 7000, "stock": 1},
		{"item_id": "staff_t6", "price": 7000, "stock": 1},
		{"item_id": "dagger_t6", "price": 6500, "stock": 1},
		{"item_id": "mat_dragonscale", "price": 3000, "stock": 2},
		{"item_id": "mat_moonstone", "price": 2500, "stock": 2},
		{"item_id": "mat_void_crystal", "price": 5000, "stock": 1},
		{"item_id": "mat_phoenix_feather", "price": 5500, "stock": 1},
	]
	_shops[shop.shop_id] = shop


# =================== TRAVELING MERCHANT ===================

static func _register_traveling_merchant() -> void:
	var shop := ShopData.create("traveling_merchant", "Traveling Merchant", Enums.ShopType.GENERAL_STORE, "Kazimir")
	shop.npc_portrait_color = Color(0.4, 0.5, 0.6)
	shop.is_rotating = true
	shop.rotation_count = 6
	shop.rotation_pool = [
		# Random ritka itemek, mid-high tier
		{"item_id": "sword_t5", "price": 4000, "stock": 1},
		{"item_id": "dagger_t5", "price": 3500, "stock": 1},
		{"item_id": "axe_t5", "price": 4200, "stock": 1},
		{"item_id": "staff_t5", "price": 3800, "stock": 1},
		{"item_id": "wand_t5", "price": 3400, "stock": 1},
		{"item_id": "helm_t5", "price": 2800, "stock": 1},
		{"item_id": "chest_t5", "price": 4500, "stock": 1},
		{"item_id": "amulet_t3", "price": 2000, "stock": 1},
		{"item_id": "ring_t3", "price": 1800, "stock": 1},
		{"item_id": "cape_t3", "price": 1900, "stock": 1},
		# Ritka anyagok
		{"item_id": "mat_shadow_silk", "price": 40, "stock": 5},
		{"item_id": "mat_demon_shard", "price": 80, "stock": 3},
		{"item_id": "mat_frost_shard", "price": 100, "stock": 3},
		{"item_id": "mat_ember_core", "price": 120, "stock": 2},
		# Speciális consumable
		{"item_id": "potion_xp_boost", "price": 250, "stock": 2},
		{"item_id": "elixir_str", "price": 120, "stock": 3},
		{"item_id": "elixir_def", "price": 120, "stock": 3},
		{"item_id": "elixir_speed", "price": 120, "stock": 3},
	]
	_shops[shop.shop_id] = shop

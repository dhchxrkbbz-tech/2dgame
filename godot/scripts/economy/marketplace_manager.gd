## MarketplaceManager - Piactér logika (Auction House)
## Listing, keresés, vásárlás, fee-k, lejárat kezelés
class_name MarketplaceManager
extends Node

## Aktív listing-ek: listing_id → MarketplaceListing
var _listings: Dictionary = {}

## Tranzakció log
var _transaction_log: Array[Dictionary] = []

## Lejárat ellenőrző timer
var _expiry_timer: Timer = null

## Referenciák
var currency_manager: CurrencyManager = null
var inventory_manager: InventoryManager = null


func _ready() -> void:
	_expiry_timer = Timer.new()
	_expiry_timer.wait_time = 60.0  # percenként ellenőrzés
	_expiry_timer.timeout.connect(_check_expired_listings)
	_expiry_timer.autostart = true
	add_child(_expiry_timer)


## Listing létrehozása
func create_listing(item_uuid: String, price: int, currency_type: int = Enums.CurrencyType.GOLD) -> bool:
	if not currency_manager or not inventory_manager:
		return false
	
	if price <= 0:
		return false
	
	# Item keresése az inventory-ban
	var item := inventory_manager.find_item_by_uuid(item_uuid)
	if not item:
		return false
	
	# Listing fee kiszámítása és levonása
	var listing_fee := int(price * Constants.MARKETPLACE_LISTING_FEE)
	listing_fee = maxi(1, listing_fee)
	
	if not currency_manager.can_afford(currency_type, listing_fee):
		return false
	
	# Fee levonás
	currency_manager.spend_currency(currency_type, listing_fee)
	
	# Item eltávolítása inventory-ból
	var removed := inventory_manager.remove_item_by_uuid(item_uuid)
	if not removed:
		# Fee visszaadás ha sikertelen
		currency_manager.add_currency(currency_type, listing_fee)
		return false
	
	# Listing létrehozása
	var listing := MarketplaceListing.create(
		_get_player_id(),
		_get_player_name(),
		removed,
		price,
		currency_type
	)
	
	_listings[listing.listing_id] = listing
	EventBus.marketplace_listing_created.emit(listing.listing_id)
	return true


## Listing vásárlása
func buy_listing(listing_id: String) -> bool:
	if not currency_manager or not inventory_manager:
		return false
	
	var listing: MarketplaceListing = _listings.get(listing_id)
	if not listing or listing.status != Enums.ListingStatus.ACTIVE:
		return false
	
	if listing.is_expired():
		_expire_listing(listing)
		return false
	
	# Nem vásárolhatod meg a saját listing-ed
	if listing.seller_id == _get_player_id():
		return false
	
	# Szabad hely ellenőrzés
	if not inventory_manager.has_free_slot():
		EventBus.inventory_full.emit()
		return false
	
	# Ár + tranzakciós díj
	var total_cost := listing.price
	if not currency_manager.can_afford(listing.currency_type, total_cost):
		return false
	
	# Vásárlás végrehajtás
	currency_manager.spend_currency(listing.currency_type, total_cost)
	
	# Tranzakciós díj számítás (az eladó kapja az árat - fee)
	var transaction_fee := int(listing.price * Constants.MARKETPLACE_TRANSACTION_FEE)
	var seller_receives := listing.price - transaction_fee
	
	# Ha az eladó az aktuális játékos (solo/host), gold hozzáadás
	if listing.seller_id == _get_player_id():
		currency_manager.add_currency(listing.currency_type, seller_receives)
	
	# Item átadás a vevőnek
	inventory_manager.add_item(listing.item)
	
	# Listing lezárás
	listing.status = Enums.ListingStatus.SOLD
	
	# Tranzakció log
	_transaction_log.append({
		"listing_id": listing.listing_id,
		"buyer_id": _get_player_id(),
		"seller_id": listing.seller_id,
		"price": listing.price,
		"fee": transaction_fee,
		"timestamp": int(Time.get_unix_time_from_system()),
	})
	
	EventBus.marketplace_listing_sold.emit(listing_id)
	return true


## Listing visszavonása
func cancel_listing(listing_id: String) -> bool:
	if not inventory_manager:
		return false
	
	var listing: MarketplaceListing = _listings.get(listing_id)
	if not listing or listing.status != Enums.ListingStatus.ACTIVE:
		return false
	
	# Csak a saját listing-et vonhatod vissza
	if listing.seller_id != _get_player_id():
		return false
	
	# Item visszaadás
	if listing.item and inventory_manager.has_free_slot():
		inventory_manager.add_item(listing.item)
	
	listing.status = Enums.ListingStatus.CANCELLED
	EventBus.marketplace_listing_cancelled.emit(listing_id)
	return true


## Keresés a listing-ek között
func search_listings(filters: Dictionary = {}) -> Array[MarketplaceListing]:
	var results: Array[MarketplaceListing] = []
	
	for key in _listings:
		var listing: MarketplaceListing = _listings[key]
		if listing.status != Enums.ListingStatus.ACTIVE:
			continue
		if listing.is_expired():
			continue
		
		# Szűrők alkalmazása
		if not _matches_filters(listing, filters):
			continue
		
		results.append(listing)
	
	# Rendezés
	var sort_by: String = filters.get("sort_by", "price")
	match sort_by:
		"price":
			results.sort_custom(func(a, b): return a.price < b.price)
		"date":
			results.sort_custom(func(a, b): return a.listed_at > b.listed_at)
		"rarity":
			results.sort_custom(func(a, b):
				if a.item and b.item:
					return a.item.rarity > b.item.rarity
				return false
			)
	
	return results


## Saját listing-ek lekérdezése
func get_my_listings() -> Array[MarketplaceListing]:
	var results: Array[MarketplaceListing] = []
	var player_id := _get_player_id()
	
	for key in _listings:
		var listing: MarketplaceListing = _listings[key]
		if listing.seller_id == player_id and listing.status == Enums.ListingStatus.ACTIVE:
			results.append(listing)
	
	return results


## Szűrő ellenőrzés
func _matches_filters(listing: MarketplaceListing, filters: Dictionary) -> bool:
	if not listing.item or not listing.item.base_item:
		return true
	
	var item := listing.item
	var base := item.base_item
	
	# Kategória szűrő
	if filters.has("item_type"):
		if base.item_type != filters["item_type"]:
			return false
	
	# Rarity szűrő
	if filters.has("min_rarity"):
		if item.rarity < filters["min_rarity"]:
			return false
	
	# Level szűrő
	if filters.has("min_level"):
		if item.item_level < filters["min_level"]:
			return false
	if filters.has("max_level"):
		if item.item_level > filters["max_level"]:
			return false
	
	# Ár szűrő
	if filters.has("min_price"):
		if listing.price < filters["min_price"]:
			return false
	if filters.has("max_price"):
		if listing.price > filters["max_price"]:
			return false
	
	# Név keresés
	if filters.has("search_text"):
		var search: String = filters["search_text"].to_lower()
		if not item.get_display_name().to_lower().contains(search):
			return false
	
	return true


## Lejárt listing-ek ellenőrzése
func _check_expired_listings() -> void:
	for key in _listings.keys():
		var listing: MarketplaceListing = _listings[key]
		if listing.status == Enums.ListingStatus.ACTIVE and listing.is_expired():
			_expire_listing(listing)


func _expire_listing(listing: MarketplaceListing) -> void:
	listing.status = Enums.ListingStatus.EXPIRED
	
	# Item visszaadás az eladónak (ha ő az aktuális játékos)
	if listing.seller_id == _get_player_id() and listing.item:
		if inventory_manager and inventory_manager.has_free_slot():
			inventory_manager.add_item(listing.item)
	
	EventBus.marketplace_listing_expired.emit(listing.listing_id)


## Player ID segédfüggvények (multiplayer kompatibilis)
func _get_player_id() -> String:
	return str(multiplayer.get_unique_id()) if multiplayer.has_multiplayer_peer() else "local_player"


func _get_player_name() -> String:
	return "Player"  # TODO: PlayerManager-ből lekérdezés


## Serialize
func serialize() -> Dictionary:
	var listings_data: Array = []
	for key in _listings:
		listings_data.append(_listings[key].serialize())
	return {
		"listings": listings_data,
		"transaction_log": _transaction_log,
	}


func deserialize(data: Dictionary) -> void:
	# Listing-ek betöltése
	if data.has("listings"):
		_listings.clear()
		for listing_data in data["listings"]:
			var listing := MarketplaceListing.new()
			listing.listing_id = listing_data.get("listing_id", "")
			listing.seller_id = listing_data.get("seller_id", "")
			listing.seller_name = listing_data.get("seller_name", "")
			listing.price = listing_data.get("price", 0)
			listing.currency_type = listing_data.get("currency_type", Enums.CurrencyType.GOLD)
			listing.listed_at = listing_data.get("listed_at", 0)
			listing.expires_at = listing_data.get("expires_at", 0)
			listing.status = listing_data.get("status", Enums.ListingStatus.ACTIVE)
			# Item deserialize (egyszerűsített)
			if listing_data.has("item") and not listing_data["item"].is_empty():
				listing.item = _deserialize_item(listing_data["item"])
			_listings[listing.listing_id] = listing
	
	if data.has("transaction_log"):
		_transaction_log = data["transaction_log"]


func _deserialize_item(data: Dictionary) -> ItemInstance:
	var item := ItemInstance.new()
	item.uuid = data.get("uuid", ItemInstance._generate_uuid())
	item.item_level = data.get("item_level", 1)
	item.rarity = data.get("rarity", Enums.Rarity.COMMON)
	item.enhancement_level = data.get("enhancement_level", 0)
	item.quantity = data.get("quantity", 1)
	var base_id: String = data.get("base_item_id", "")
	if not base_id.is_empty():
		item.base_item = ItemDatabase.get_item(base_id)
	return item

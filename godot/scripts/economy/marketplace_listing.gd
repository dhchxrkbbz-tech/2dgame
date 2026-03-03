## MarketplaceListing - Marketplace listing adatok
class_name MarketplaceListing
extends RefCounted

var listing_id: String = ""
var seller_id: String = ""
var seller_name: String = ""
var item: ItemInstance = null
var price: int = 0
var currency_type: int = Enums.CurrencyType.GOLD
var listed_at: int = 0  # unix timestamp
var expires_at: int = 0
var status: int = Enums.ListingStatus.ACTIVE


func _init() -> void:
	listing_id = "%x%x" % [randi(), Time.get_ticks_msec()]


static func create(
	p_seller_id: String,
	p_seller_name: String,
	p_item: ItemInstance,
	p_price: int,
	p_currency: int = Enums.CurrencyType.GOLD
) -> MarketplaceListing:
	var listing := MarketplaceListing.new()
	listing.seller_id = p_seller_id
	listing.seller_name = p_seller_name
	listing.item = p_item
	listing.price = p_price
	listing.currency_type = p_currency
	listing.listed_at = int(Time.get_unix_time_from_system())
	listing.expires_at = listing.listed_at + Constants.MARKETPLACE_LISTING_DURATION
	listing.status = Enums.ListingStatus.ACTIVE
	return listing


func is_expired() -> bool:
	return int(Time.get_unix_time_from_system()) >= expires_at


func get_time_remaining() -> int:
	return maxi(0, expires_at - int(Time.get_unix_time_from_system()))


func serialize() -> Dictionary:
	return {
		"listing_id": listing_id,
		"seller_id": seller_id,
		"seller_name": seller_name,
		"item": item.serialize() if item else {},
		"price": price,
		"currency_type": currency_type,
		"listed_at": listed_at,
		"expires_at": expires_at,
		"status": status,
	}

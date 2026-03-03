## ShopData - NPC shop inventory definíció (Resource)
class_name ShopData
extends Resource

@export var shop_id: String = ""
@export var shop_name: String = ""
@export var shop_type: int = Enums.ShopType.GENERAL_STORE
@export var npc_name: String = ""
@export var npc_portrait_color: Color = Color.WHITE  # Placeholder szín

## Shop inventory: [{"item_id": "...", "price": 100, "currency": CurrencyType.GOLD, "stock": -1}]
## stock = -1 → végtelen
@export var items: Array[Dictionary] = []

## Rotating stock (Relic Vendor): hetente változik
@export var is_rotating: bool = false
@export var rotation_pool: Array[Dictionary] = []
@export var rotation_count: int = 4  # hány item jelenik meg egyszerre


static func create(p_id: String, p_name: String, p_type: int, p_npc: String) -> ShopData:
	var data := ShopData.new()
	data.shop_id = p_id
	data.shop_name = p_name
	data.shop_type = p_type
	data.npc_name = p_npc
	return data

## ShopUI - NPC Shop interfész
## Vásárlás, eladás, buy-back, NPC portrait
extends Control

var _shop_panel: PanelContainer = null
var _items_container: VBoxContainer = null
var _buyback_container: VBoxContainer = null
var _npc_name_label: Label = null
var _player_gold_label: Label = null
var _tab_container: TabContainer = null
var _is_visible: bool = false

var _economy: Node = null
var _shop_mgr: ShopManager = null
var _inv_mgr: InventoryManager = null
var _cur_mgr: CurrencyManager = null


func _ready() -> void:
	_economy = get_node_or_null("/root/EconomyManager")
	if _economy:
		_shop_mgr = _economy.shop_manager
		_inv_mgr = _economy.inventory_manager
		_cur_mgr = _economy.currency_manager
	
	_build_ui()
	_connect_signals()
	visible = false


func _build_ui() -> void:
	_shop_panel = PanelContainer.new()
	_shop_panel.custom_minimum_size = Vector2(280, 250)
	_shop_panel.anchors_preset = Control.PRESET_CENTER
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.06, 0.95)
	style.border_color = Color(0.6, 0.5, 0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	_shop_panel.add_theme_stylebox_override("panel", style)
	add_child(_shop_panel)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	_shop_panel.add_child(main_vbox)
	
	# Header
	var header := HBoxContainer.new()
	main_vbox.add_child(header)
	
	_npc_name_label = Label.new()
	_npc_name_label.text = "Shop"
	_npc_name_label.add_theme_font_size_override("font_size", 11)
	_npc_name_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	header.add_child(_npc_name_label)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	
	_player_gold_label = Label.new()
	_player_gold_label.text = "Gold: 0"
	_player_gold_label.add_theme_font_size_override("font_size", 9)
	_player_gold_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	header.add_child(_player_gold_label)
	
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.add_theme_font_size_override("font_size", 9)
	close_btn.pressed.connect(_close)
	header.add_child(close_btn)
	
	# Tab konténer: Buy / Sell / Buyback
	_tab_container = TabContainer.new()
	_tab_container.custom_minimum_size = Vector2(0, 180)
	main_vbox.add_child(_tab_container)
	
	# Buy tab
	var buy_scroll := ScrollContainer.new()
	buy_scroll.name = "Buy"
	_items_container = VBoxContainer.new()
	_items_container.add_theme_constant_override("separation", 2)
	buy_scroll.add_child(_items_container)
	_tab_container.add_child(buy_scroll)
	
	# Sell tab
	var sell_scroll := ScrollContainer.new()
	sell_scroll.name = "Sell"
	var sell_container := VBoxContainer.new()
	sell_container.name = "SellItems"
	sell_container.add_theme_constant_override("separation", 2)
	sell_scroll.add_child(sell_container)
	_tab_container.add_child(sell_scroll)
	
	# Buyback tab
	var buyback_scroll := ScrollContainer.new()
	buyback_scroll.name = "Buyback"
	_buyback_container = VBoxContainer.new()
	_buyback_container.add_theme_constant_override("separation", 2)
	buyback_scroll.add_child(_buyback_container)
	_tab_container.add_child(buyback_scroll)


func _connect_signals() -> void:
	EventBus.shop_opened.connect(_on_shop_opened)
	EventBus.shop_closed.connect(_on_shop_closed)
	EventBus.currency_changed.connect(_on_currency_changed)


func _on_shop_opened(_shop_type: Enums.ShopType, shop_data: Dictionary) -> void:
	_npc_name_label.text = shop_data.get("npc_name", "Shop")
	visible = true
	_is_visible = true
	_refresh_buy_tab(shop_data.get("items", []))
	_refresh_sell_tab()
	_refresh_buyback_tab()
	_update_gold_display()


func _on_shop_closed() -> void:
	visible = false
	_is_visible = false


func _on_currency_changed(_type: Enums.CurrencyType, _amount: int) -> void:
	if _is_visible:
		_update_gold_display()


func _update_gold_display() -> void:
	if _cur_mgr:
		_player_gold_label.text = "Gold: %s" % Utils.format_number(_cur_mgr.get_gold())


func _refresh_buy_tab(shop_items: Array) -> void:
	# Korábbi elemek törlése
	for child in _items_container.get_children():
		child.queue_free()
	
	for i in shop_items.size():
		var item_data: Dictionary = shop_items[i]
		var stock: int = item_data.get("stock", -1)
		if stock == 0:
			continue
		
		var row := _create_shop_item_row(
			item_data.get("item_id", "???"),
			item_data.get("price", 0),
			stock,
			"Buy"
		)
		row.get_node("ActionBtn").pressed.connect(_on_buy_pressed.bind(i))
		_items_container.add_child(row)


func _refresh_sell_tab() -> void:
	if not _inv_mgr:
		return
	
	var sell_container := _tab_container.get_node("Sell/SellItems")
	if not sell_container:
		return
	
	for child in sell_container.get_children():
		child.queue_free()
	
	for i in _inv_mgr.inventory.size():
		var item: ItemInstance = _inv_mgr.inventory[i]
		if not item or not item.base_item:
			continue
		
		var sell_price := int(item.get_sell_price() * Constants.NPC_SELL_MULTIPLIER)
		var row := _create_shop_item_row(
			item.get_display_name(),
			sell_price,
			item.quantity,
			"Sell"
		)
		row.get_node("ActionBtn").pressed.connect(_on_sell_pressed.bind(i))
		sell_container.add_child(row)


func _refresh_buyback_tab() -> void:
	if not _shop_mgr:
		return
	
	for child in _buyback_container.get_children():
		child.queue_free()
	
	var buyback := _shop_mgr.get_buyback_list()
	for i in buyback.size():
		var entry: Dictionary = buyback[i]
		var item: ItemInstance = entry.get("item")
		var price: int = entry.get("price", 0)
		if not item:
			continue
		
		var row := _create_shop_item_row(
			item.get_display_name(),
			price,
			1,
			"Buy"
		)
		row.get_node("ActionBtn").pressed.connect(_on_buyback_pressed.bind(i))
		_buyback_container.add_child(row)


func _create_shop_item_row(item_name: String, price: int, stock: int, action_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	
	var name_label := Label.new()
	name_label.text = item_name
	name_label.add_theme_font_size_override("font_size", 8)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	
	var price_label := Label.new()
	price_label.text = "%d g" % price
	price_label.add_theme_font_size_override("font_size", 8)
	price_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	row.add_child(price_label)
	
	if stock > 0:
		var stock_label := Label.new()
		stock_label.text = "×%d" % stock
		stock_label.add_theme_font_size_override("font_size", 8)
		stock_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		row.add_child(stock_label)
	
	var btn := Button.new()
	btn.name = "ActionBtn"
	btn.text = action_text
	btn.add_theme_font_size_override("font_size", 8)
	btn.custom_minimum_size = Vector2(35, 0)
	row.add_child(btn)
	
	return row


func _on_buy_pressed(index: int) -> void:
	if _shop_mgr and _shop_mgr.buy_item(index):
		_refresh_sell_tab()
		if _shop_mgr.get_active_shop():
			_refresh_buy_tab(_shop_mgr.get_active_shop().items)


func _on_sell_pressed(inventory_index: int) -> void:
	if _shop_mgr and _shop_mgr.sell_item(inventory_index):
		_refresh_sell_tab()
		_refresh_buyback_tab()


func _on_buyback_pressed(buyback_index: int) -> void:
	if _shop_mgr and _shop_mgr.buyback_item(buyback_index):
		_refresh_sell_tab()
		_refresh_buyback_tab()


func _close() -> void:
	if _shop_mgr:
		_shop_mgr.close_shop()

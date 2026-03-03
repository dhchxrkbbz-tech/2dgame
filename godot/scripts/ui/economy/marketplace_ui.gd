## MarketplaceUI - Auction House / Marketplace kezelőfelület
## Listázás, keresés, szűrés, vásárlás
extends Control

var _panel: PanelContainer = null
var _tab_container: TabContainer = null
var _search_input: LineEdit = null
var _search_button: Button = null

# Browse tab
var _browse_list: VBoxContainer = null
var _filter_type: OptionButton = null
var _filter_rarity: OptionButton = null
var _sort_option: OptionButton = null
var _price_min: SpinBox = null
var _price_max: SpinBox = null

# My Listings tab
var _my_listings_list: VBoxContainer = null

# Create Listing tab
var _listing_item_list: VBoxContainer = null
var _listing_price_input: SpinBox = null
var _listing_currency: OptionButton = null
var _listing_summary: Label = null
var _create_listing_button: Button = null

var _selected_listing_item: ItemInstance = null
var _is_visible: bool = false
var _economy: Node = null


func _ready() -> void:
	_economy = get_node_or_null("/root/EconomyManager")
	_build_ui()
	_connect_signals()
	visible = false


func toggle() -> void:
	_is_visible = !_is_visible
	visible = _is_visible
	if _is_visible:
		_refresh_all()
		EventBus.screen_opened.emit("marketplace")
	else:
		EventBus.screen_closed.emit("marketplace")


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(420, 280)
	_panel.anchors_preset = Control.PRESET_CENTER
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.06, 0.1, 0.95)
	style.border_color = Color(0.5, 0.3, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	_panel.add_child(main_vbox)
	
	# Title
	var title := Label.new()
	title.text = "Marketplace"
	title.add_theme_font_size_override("font_size", 12)
	title.add_theme_color_override("font_color", Color(0.6, 0.4, 0.9))
	main_vbox.add_child(title)
	
	# TabContainer
	_tab_container = TabContainer.new()
	_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(_tab_container)
	
	_build_browse_tab()
	_build_my_listings_tab()
	_build_create_listing_tab()


func _build_browse_tab() -> void:
	var browse := VBoxContainer.new()
	browse.name = "Browse"
	_tab_container.add_child(browse)
	
	# Search bar
	var search_hbox := HBoxContainer.new()
	search_hbox.add_theme_constant_override("separation", 4)
	browse.add_child(search_hbox)
	
	_search_input = LineEdit.new()
	_search_input.placeholder_text = "Search items..."
	_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_search_input.add_theme_font_size_override("font_size", 8)
	search_hbox.add_child(_search_input)
	
	_search_button = Button.new()
	_search_button.text = "Search"
	_search_button.add_theme_font_size_override("font_size", 8)
	_search_button.pressed.connect(_on_search_pressed)
	search_hbox.add_child(_search_button)
	
	# Filters
	var filter_hbox := HBoxContainer.new()
	filter_hbox.add_theme_constant_override("separation", 4)
	browse.add_child(filter_hbox)
	
	_filter_type = OptionButton.new()
	_filter_type.add_theme_font_size_override("font_size", 7)
	_filter_type.add_item("All Types", 0)
	for type_name in ["Weapon", "Armor", "Consumable", "Material", "Gem"]:
		_filter_type.add_item(type_name)
	filter_hbox.add_child(_filter_type)
	
	_filter_rarity = OptionButton.new()
	_filter_rarity.add_theme_font_size_override("font_size", 7)
	_filter_rarity.add_item("All Rarity", 0)
	for rarity_name in ["Common", "Magic", "Rare", "Legendary", "Unique"]:
		_filter_rarity.add_item(rarity_name)
	filter_hbox.add_child(_filter_rarity)
	
	_sort_option = OptionButton.new()
	_sort_option.add_theme_font_size_override("font_size", 7)
	for sort_name in ["Price: Low", "Price: High", "Newest", "Rarity"]:
		_sort_option.add_item(sort_name)
	filter_hbox.add_child(_sort_option)
	
	# Price range
	var price_hbox := HBoxContainer.new()
	price_hbox.add_theme_constant_override("separation", 4)
	browse.add_child(price_hbox)
	
	var min_label := Label.new()
	min_label.text = "Min:"
	min_label.add_theme_font_size_override("font_size", 7)
	price_hbox.add_child(min_label)
	
	_price_min = SpinBox.new()
	_price_min.min_value = 0
	_price_min.max_value = 9999999
	_price_min.add_theme_font_size_override("font_size", 7)
	price_hbox.add_child(_price_min)
	
	var max_label := Label.new()
	max_label.text = "Max:"
	max_label.add_theme_font_size_override("font_size", 7)
	price_hbox.add_child(max_label)
	
	_price_max = SpinBox.new()
	_price_max.min_value = 0
	_price_max.max_value = 9999999
	_price_max.value = 9999999
	_price_max.add_theme_font_size_override("font_size", 7)
	price_hbox.add_child(_price_max)
	
	# Results
	var results_scroll := ScrollContainer.new()
	results_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	browse.add_child(results_scroll)
	
	_browse_list = VBoxContainer.new()
	_browse_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_browse_list.add_theme_constant_override("separation", 2)
	results_scroll.add_child(_browse_list)


func _build_my_listings_tab() -> void:
	var my_tab := VBoxContainer.new()
	my_tab.name = "My Listings"
	_tab_container.add_child(my_tab)
	
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	my_tab.add_child(scroll)
	
	_my_listings_list = VBoxContainer.new()
	_my_listings_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_my_listings_list.add_theme_constant_override("separation", 2)
	scroll.add_child(_my_listings_list)


func _build_create_listing_tab() -> void:
	var create_tab := VBoxContainer.new()
	create_tab.name = "Sell Item"
	_tab_container.add_child(create_tab)
	
	var item_label := Label.new()
	item_label.text = "Select item to list:"
	item_label.add_theme_font_size_override("font_size", 8)
	create_tab.add_child(item_label)
	
	var item_scroll := ScrollContainer.new()
	item_scroll.custom_minimum_size = Vector2(0, 100)
	create_tab.add_child(item_scroll)
	
	_listing_item_list = VBoxContainer.new()
	_listing_item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_listing_item_list.add_theme_constant_override("separation", 2)
	item_scroll.add_child(_listing_item_list)
	
	# Price input
	var price_hbox := HBoxContainer.new()
	price_hbox.add_theme_constant_override("separation", 4)
	create_tab.add_child(price_hbox)
	
	var price_label := Label.new()
	price_label.text = "Price:"
	price_label.add_theme_font_size_override("font_size", 8)
	price_hbox.add_child(price_label)
	
	_listing_price_input = SpinBox.new()
	_listing_price_input.min_value = 1
	_listing_price_input.max_value = 9999999
	_listing_price_input.value = 100
	_listing_price_input.add_theme_font_size_override("font_size", 8)
	_listing_price_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_listing_price_input.value_changed.connect(_on_price_changed)
	price_hbox.add_child(_listing_price_input)
	
	_listing_currency = OptionButton.new()
	_listing_currency.add_theme_font_size_override("font_size", 7)
	_listing_currency.add_item("Gold")
	_listing_currency.add_item("Dark Essence")
	_listing_currency.add_item("Relic Fragment")
	price_hbox.add_child(_listing_currency)
	
	# Summary
	_listing_summary = Label.new()
	_listing_summary.text = "Select an item to list"
	_listing_summary.add_theme_font_size_override("font_size", 7)
	_listing_summary.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	create_tab.add_child(_listing_summary)
	
	_create_listing_button = Button.new()
	_create_listing_button.text = "Create Listing"
	_create_listing_button.add_theme_font_size_override("font_size", 9)
	_create_listing_button.disabled = true
	_create_listing_button.pressed.connect(_on_create_listing)
	create_tab.add_child(_create_listing_button)


func _connect_signals() -> void:
	EventBus.marketplace_listing_sold.connect(func(_l): _refresh_all())
	EventBus.marketplace_listing_cancelled.connect(func(_l): _refresh_all())


func _on_search_pressed() -> void:
	_refresh_browse()


func _refresh_all() -> void:
	_refresh_browse()
	_refresh_my_listings()
	_refresh_sell_tab()


func _refresh_browse() -> void:
	if not _economy:
		return
	
	for child in _browse_list.get_children():
		child.queue_free()
	
	var mp: Node = _economy.marketplace_manager
	if not mp:
		return
	
	var filters := {}
	if _filter_type.selected > 0:
		filters["item_type"] = _filter_type.selected - 1
	if _filter_rarity.selected > 0:
		filters["rarity"] = _filter_rarity.selected - 1
	if _price_min.value > 0:
		filters["min_price"] = int(_price_min.value)
	if _price_max.value < 9999999:
		filters["max_price"] = int(_price_max.value)
	
	var search_text := _search_input.text.strip_edges()
	if search_text != "":
		filters["search_text"] = search_text
	
	var sort_modes := ["price_asc", "price_desc", "newest", "rarity"]
	var sort_mode: String = sort_modes[_sort_option.selected] if _sort_option.selected < sort_modes.size() else "price_asc"
	
	var listings: Array = mp.search_listings(filters, sort_mode)
	
	for listing in listings:
		_add_browse_listing_row(listing)
	
	if listings.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No listings found."
		empty_label.add_theme_font_size_override("font_size", 8)
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		_browse_list.add_child(empty_label)


func _add_browse_listing_row(listing) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	_browse_list.add_child(row)
	
	var name_label := Label.new()
	name_label.text = listing.item.get_display_name() if listing.item else "???"
	name_label.add_theme_font_size_override("font_size", 8)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Rarity színezés
	var rarity_colors := {
		0: Color(0.7, 0.7, 0.7),  # Common
		1: Color(0.3, 0.5, 1.0),  # Magic
		2: Color(1.0, 1.0, 0.2),  # Rare
		3: Color(1.0, 0.5, 0.0),  # Legendary
		4: Color(0.6, 0.0, 0.8),  # Unique
	}
	if listing.item:
		var rarity_val: int = listing.item.rarity if listing.item.rarity is int else 0
		name_label.add_theme_color_override("font_color", rarity_colors.get(rarity_val, Color.WHITE))
	row.add_child(name_label)
	
	var price_label := Label.new()
	var currency_names := ["G", "DE", "RF"]
	var currency_idx: int = listing.currency_type if listing.currency_type is int else 0
	price_label.text = "%d %s" % [listing.price, currency_names[clampi(currency_idx, 0, 2)]]
	price_label.add_theme_font_size_override("font_size", 8)
	price_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	row.add_child(price_label)
	
	var seller_label := Label.new()
	seller_label.text = listing.seller_name
	seller_label.add_theme_font_size_override("font_size", 7)
	seller_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	row.add_child(seller_label)
	
	var buy_btn := Button.new()
	buy_btn.text = "Buy"
	buy_btn.add_theme_font_size_override("font_size", 8)
	buy_btn.pressed.connect(_on_buy_listing.bind(listing))
	row.add_child(buy_btn)


func _on_buy_listing(listing) -> void:
	if not _economy:
		return
	
	var mp: Node = _economy.marketplace_manager
	if mp and mp.buy_listing(listing.listing_id, "player"):
		_refresh_all()


func _refresh_my_listings() -> void:
	if not _economy:
		return
	
	for child in _my_listings_list.get_children():
		child.queue_free()
	
	var mp: Node = _economy.marketplace_manager
	if not mp:
		return
	
	for listing in mp.active_listings:
		if listing.seller_id != "player":
			continue
		
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 4)
		_my_listings_list.add_child(row)
		
		var name_label := Label.new()
		name_label.text = listing.item.get_display_name() if listing.item else "???"
		name_label.add_theme_font_size_override("font_size", 8)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		
		var price_label := Label.new()
		price_label.text = "%d G" % listing.price
		price_label.add_theme_font_size_override("font_size", 8)
		price_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
		row.add_child(price_label)
		
		var cancel_btn := Button.new()
		cancel_btn.text = "Cancel"
		cancel_btn.add_theme_font_size_override("font_size", 8)
		cancel_btn.pressed.connect(func(): mp.cancel_listing(listing.listing_id, "player"); _refresh_all())
		row.add_child(cancel_btn)


func _refresh_sell_tab() -> void:
	if not _economy:
		return
	
	for child in _listing_item_list.get_children():
		child.queue_free()
	
	_selected_listing_item = null
	_create_listing_button.disabled = true
	
	var inv: Node = _economy.inventory_manager
	if not inv:
		return
	
	for item in inv.inventory:
		if item == null:
			continue
		
		var btn := Button.new()
		btn.text = item.get_display_name()
		btn.add_theme_font_size_override("font_size", 8)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_select_listing_item.bind(item))
		_listing_item_list.add_child(btn)


func _on_select_listing_item(item: ItemInstance) -> void:
	_selected_listing_item = item
	_create_listing_button.disabled = false
	_update_listing_summary()


func _on_price_changed(_value: float) -> void:
	_update_listing_summary()


func _update_listing_summary() -> void:
	if _selected_listing_item == null:
		_listing_summary.text = "Select an item to list"
		return
	
	var price := int(_listing_price_input.value)
	var fee := int(price * Constants.MARKETPLACE_LISTING_FEE)
	_listing_summary.text = "Listing: %s for %d Gold (Fee: %d Gold)" % [
		_selected_listing_item.get_display_name(), price, fee
	]


func _on_create_listing() -> void:
	if not _economy or _selected_listing_item == null:
		return
	
	var mp: Node = _economy.marketplace_manager
	if not mp:
		return
	
	var price := int(_listing_price_input.value)
	var currency: int = _listing_currency.selected
	
	if mp.create_listing(_selected_listing_item, price, "player", "Player", currency):
		# Eltávolítjuk az inventoryból
		var inv: Node = _economy.inventory_manager
		if inv:
			inv.remove_item(_selected_listing_item)
		_selected_listing_item = null
		_refresh_all()

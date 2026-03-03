## UpgradeUI - Enhancement, Enchanting és Gem socketing UI
## Gear erősítés felület, siker/kudarc animáció
extends Control

var _panel: PanelContainer = null
var _item_info_label: RichTextLabel = null
var _enhance_button: Button = null
var _enchant_button: Button = null
var _cost_label: Label = null
var _result_label: Label = null
var _selected_item: ItemInstance = null
var _is_visible: bool = false

var _economy: Node = null
var _upgrade_mgr: UpgradeManager = null
var _inv_mgr: InventoryManager = null


func _ready() -> void:
	_economy = get_node_or_null("/root/EconomyManager")
	if _economy:
		_upgrade_mgr = _economy.upgrade_manager
		_inv_mgr = _economy.inventory_manager
	
	_build_ui()
	_connect_signals()
	visible = false


func open_upgrade_ui() -> void:
	_is_visible = true
	visible = true
	_selected_item = null
	_refresh_item_list()
	_clear_detail()
	EventBus.screen_opened.emit("upgrade")


func close_upgrade_ui() -> void:
	_is_visible = false
	visible = false
	_selected_item = null
	EventBus.screen_closed.emit("upgrade")


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(300, 220)
	_panel.anchors_preset = Control.PRESET_CENTER
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.06, 0.95)
	style.border_color = Color(0.5, 0.3, 0.6)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	_panel.add_theme_stylebox_override("panel", style)
	add_child(_panel)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 4)
	_panel.add_child(main_vbox)
	
	# Header
	var header := HBoxContainer.new()
	main_vbox.add_child(header)
	
	var title := Label.new()
	title.text = "Upgrade Station"
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.8, 0.6, 0.9))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.add_theme_font_size_override("font_size", 9)
	close_btn.pressed.connect(close_upgrade_ui)
	header.add_child(close_btn)
	
	# Content
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(content)
	
	# Item lista (bal)
	var item_scroll := ScrollContainer.new()
	item_scroll.custom_minimum_size = Vector2(100, 0)
	content.add_child(item_scroll)
	
	var _item_list := VBoxContainer.new()
	_item_list.name = "ItemList"
	_item_list.add_theme_constant_override("separation", 2)
	item_scroll.add_child(_item_list)
	
	# Detail panel (jobb)
	var detail_vbox := VBoxContainer.new()
	detail_vbox.add_theme_constant_override("separation", 4)
	detail_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(detail_vbox)
	
	_item_info_label = RichTextLabel.new()
	_item_info_label.bbcode_enabled = true
	_item_info_label.fit_content = true
	_item_info_label.custom_minimum_size = Vector2(0, 80)
	_item_info_label.add_theme_font_size_override("normal_font_size", 8)
	detail_vbox.add_child(_item_info_label)
	
	_cost_label = Label.new()
	_cost_label.text = ""
	_cost_label.add_theme_font_size_override("font_size", 8)
	_cost_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	detail_vbox.add_child(_cost_label)
	
	# Gombok
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 4)
	detail_vbox.add_child(btn_row)
	
	_enhance_button = Button.new()
	_enhance_button.text = "Enhance"
	_enhance_button.add_theme_font_size_override("font_size", 9)
	_enhance_button.pressed.connect(_on_enhance_pressed)
	_enhance_button.disabled = true
	btn_row.add_child(_enhance_button)
	
	_enchant_button = Button.new()
	_enchant_button.text = "Enchant"
	_enchant_button.add_theme_font_size_override("font_size", 9)
	_enchant_button.pressed.connect(_on_enchant_pressed)
	_enchant_button.disabled = true
	btn_row.add_child(_enchant_button)
	
	# Eredmény kijelzés
	_result_label = Label.new()
	_result_label.text = ""
	_result_label.add_theme_font_size_override("font_size", 9)
	main_vbox.add_child(_result_label)


func _connect_signals() -> void:
	EventBus.enhancement_attempted.connect(_on_enhancement_result)
	EventBus.enchant_applied.connect(_on_enchant_result)
	EventBus.inventory_changed.connect(_on_inventory_changed)


func _refresh_item_list() -> void:
	var item_list := _panel.get_node_or_null("VBoxContainer/HBoxContainer/ScrollContainer/ItemList")
	if not item_list:
		# Fallback keresés
		for child in get_children():
			# Megkeressük az ItemList node-ot a fában
			pass
		return
	
	for child in item_list.get_children():
		child.queue_free()
	
	if not _inv_mgr:
		return
	
	# Equipment-ek megjelenítése
	for slot in _inv_mgr.equipment:
		var item: ItemInstance = _inv_mgr.equipment[slot]
		if item and _upgrade_mgr and _upgrade_mgr.can_enhance(item):
			var btn := Button.new()
			btn.text = item.get_display_name().substr(0, 12)
			btn.add_theme_font_size_override("font_size", 7)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.pressed.connect(_on_item_selected.bind(item))
			item_list.add_child(btn)
	
	# Inventory gear-ek
	for i in _inv_mgr.inventory.size():
		var item: ItemInstance = _inv_mgr.inventory[i]
		if item and item.base_item and _upgrade_mgr and _upgrade_mgr.can_enhance(item):
			var btn := Button.new()
			btn.text = item.get_display_name().substr(0, 12)
			btn.add_theme_font_size_override("font_size", 7)
			btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.pressed.connect(_on_item_selected.bind(item))
			item_list.add_child(btn)


func _on_item_selected(item: ItemInstance) -> void:
	_selected_item = item
	_show_item_details(item)


func _show_item_details(item: ItemInstance) -> void:
	_item_info_label.text = item.get_tooltip_text()
	
	if _upgrade_mgr and _upgrade_mgr.can_enhance(item):
		var costs := _upgrade_mgr.get_enhancement_cost(item)
		_cost_label.text = "Enhance +%d → +%d: %d gold (%d%% success)" % [
			item.enhancement_level,
			item.enhancement_level + 1,
			costs.get("gold", 0),
			int(costs.get("success_rate", 1.0) * 100),
		]
		if costs.get("dark_essence", 0) > 0:
			_cost_label.text += " + %d DE" % costs["dark_essence"]
		_enhance_button.disabled = false
	else:
		_cost_label.text = "Max enhancement reached (+10)"
		_enhance_button.disabled = true
	
	_enchant_button.disabled = false
	_result_label.text = ""


func _clear_detail() -> void:
	_item_info_label.text = "Select an item to upgrade"
	_cost_label.text = ""
	_enhance_button.disabled = true
	_enchant_button.disabled = true
	_result_label.text = ""


func _on_enhance_pressed() -> void:
	if not _selected_item or not _upgrade_mgr:
		return
	
	var result := _upgrade_mgr.enhance_item(_selected_item)
	if result.get("success", false):
		_result_label.text = "Enhancement SUCCESS! → +%d" % result.get("new_level", 0)
		_result_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	else:
		var reason: String = result.get("reason", "unknown")
		match reason:
			"enhancement_failed":
				_result_label.text = "Enhancement FAILED! Materials lost."
				_result_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
			"not_enough_gold":
				_result_label.text = "Not enough gold!"
				_result_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
			"not_enough_dark_essence":
				_result_label.text = "Not enough Dark Essence!"
				_result_label.add_theme_color_override("font_color", Color(0.6, 0.0, 0.8))
			_:
				_result_label.text = "Cannot enhance: %s" % reason
				_result_label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4))
	
	_show_item_details(_selected_item)


func _on_enchant_pressed() -> void:
	if not _selected_item or not _upgrade_mgr:
		return
	
	var result := _upgrade_mgr.enchant_item(_selected_item)
	if result.get("success", false):
		var value: float = result.get("value", 0)
		var is_pct: bool = result.get("is_percent", false)
		var val_text := "%.1f%%" % value if is_pct else "%d" % int(value)
		_result_label.text = "Enchanted: +%s %s" % [val_text, result.get("enchant_name", "")]
		_result_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	else:
		var reason: String = result.get("reason", "unknown")
		_result_label.text = "Enchant failed: %s" % reason.replace("_", " ")
		_result_label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4))
	
	_show_item_details(_selected_item)


func _on_enhancement_result(_item_uuid: String, _level: int, _success: bool) -> void:
	if _is_visible:
		_refresh_item_list()


func _on_enchant_result(_item_uuid: String, _enchant_type: String) -> void:
	if _is_visible:
		_refresh_item_list()


func _on_inventory_changed() -> void:
	if _is_visible:
		_refresh_item_list()

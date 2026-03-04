## TradeUI - Játékosok közötti kereskedés UI
## Direkt player-to-player trade, twin panel, confirm delay
extends Control

const TRADE_CONFIRM_DELAY: float = 3.0  # Anti-scam confirm delay

var _panel: PanelContainer = null
var _my_items: VBoxContainer = null
var _their_items: VBoxContainer = null
var _my_gold_input: SpinBox = null
var _confirm_button: Button = null
var _cancel_button: Button = null
var _status_label: Label = null

var _my_offered_items: Array[ItemInstance] = []
var _my_offered_gold: int = 0
var _their_offered_items: Array[ItemInstance] = []
var _their_offered_gold: int = 0
var _my_confirmed: bool = false
var _their_confirmed: bool = false
var _confirm_timer: Timer = null

var _is_visible: bool = false
var _economy: Node = null


func _ready() -> void:
	_economy = get_node_or_null("/root/EconomyManager")
	_build_ui()
	_connect_signals()
	visible = false


func open_trade() -> void:
	_is_visible = true
	visible = true
	_reset_trade()
	EventBus.screen_opened.emit("trade")


func close_trade() -> void:
	_is_visible = false
	visible = false
	_reset_trade()
	EventBus.trade_cancelled.emit()
	EventBus.screen_closed.emit("trade")


func _reset_trade() -> void:
	_my_offered_items.clear()
	_their_offered_items.clear()
	_my_offered_gold = 0
	_their_offered_gold = 0
	_my_confirmed = false
	_their_confirmed = false
	if _confirm_timer:
		_confirm_timer.stop()
	_update_ui()


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(350, 200)
	_panel.anchors_preset = Control.PRESET_CENTER
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.06, 0.95)
	style.border_color = Color(0.3, 0.6, 0.4)
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
	title.text = "Trade"
	title.add_theme_font_size_override("font_size", 11)
	title.add_theme_color_override("font_color", Color(0.5, 0.9, 0.6))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	# Twin panels
	var trade_hbox := HBoxContainer.new()
	trade_hbox.add_theme_constant_override("separation", 8)
	trade_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(trade_hbox)
	
	# My side
	var my_vbox := VBoxContainer.new()
	my_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	trade_hbox.add_child(my_vbox)
	
	var my_label := Label.new()
	my_label.text = "Your Offer"
	my_label.add_theme_font_size_override("font_size", 9)
	my_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	my_vbox.add_child(my_label)
	
	var my_scroll := ScrollContainer.new()
	my_scroll.custom_minimum_size = Vector2(0, 100)
	my_vbox.add_child(my_scroll)
	
	_my_items = VBoxContainer.new()
	_my_items.add_theme_constant_override("separation", 2)
	my_scroll.add_child(_my_items)
	
	_my_gold_input = SpinBox.new()
	_my_gold_input.min_value = 0
	_my_gold_input.max_value = 999999
	_my_gold_input.prefix = "Gold: "
	_my_gold_input.add_theme_font_size_override("font_size", 8)
	my_vbox.add_child(_my_gold_input)
	
	# Separator
	var sep := VSeparator.new()
	trade_hbox.add_child(sep)
	
	# Their side
	var their_vbox := VBoxContainer.new()
	their_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	trade_hbox.add_child(their_vbox)
	
	var their_label := Label.new()
	their_label.text = "Their Offer"
	their_label.add_theme_font_size_override("font_size", 9)
	their_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.6))
	their_vbox.add_child(their_label)
	
	var their_scroll := ScrollContainer.new()
	their_scroll.custom_minimum_size = Vector2(0, 100)
	their_vbox.add_child(their_scroll)
	
	_their_items = VBoxContainer.new()
	_their_items.add_theme_constant_override("separation", 2)
	their_scroll.add_child(_their_items)
	
	# Bottom buttons
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 8)
	main_vbox.add_child(bottom)
	
	_status_label = Label.new()
	_status_label.text = "Waiting..."
	_status_label.add_theme_font_size_override("font_size", 8)
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(_status_label)
	
	_confirm_button = Button.new()
	_confirm_button.text = "Accept"
	_confirm_button.add_theme_font_size_override("font_size", 9)
	_confirm_button.pressed.connect(_on_confirm_pressed)
	bottom.add_child(_confirm_button)
	
	_cancel_button = Button.new()
	_cancel_button.text = "Cancel"
	_cancel_button.add_theme_font_size_override("font_size", 9)
	_cancel_button.pressed.connect(close_trade)
	bottom.add_child(_cancel_button)
	
	# Confirm timer
	_confirm_timer = Timer.new()
	_confirm_timer.one_shot = true
	_confirm_timer.wait_time = TRADE_CONFIRM_DELAY
	_confirm_timer.timeout.connect(_on_confirm_timer_timeout)
	add_child(_confirm_timer)


func _connect_signals() -> void:
	EventBus.trade_completed.connect(_on_trade_completed)


func _on_confirm_pressed() -> void:
	_my_confirmed = true
	_my_offered_gold = int(_my_gold_input.value)
	_status_label.text = "Waiting for other player... (%.0fs)" % TRADE_CONFIRM_DELAY
	_confirm_button.disabled = true
	_confirm_timer.start()


func _on_confirm_timer_timeout() -> void:
	if _my_confirmed and _their_confirmed:
		_execute_trade()
	elif _my_confirmed:
		_status_label.text = "Other player hasn't confirmed yet."
		_confirm_button.disabled = false
		_my_confirmed = false


func _execute_trade() -> void:
	if not _economy:
		_status_label.text = "Trade failed: No economy manager"
		return
	
	var inv_mgr: InventoryManager = _economy.inventory_manager if _economy else null
	var cur_mgr: CurrencyManager = _economy.currency_manager if _economy else null
	
	if not inv_mgr or not cur_mgr:
		_status_label.text = "Trade failed: Missing managers"
		return
	
	# Validáció: van-e elég hely az érkező itemeknek?
	var incoming_count := _their_offered_items.size()
	var outgoing_count := _my_offered_items.size()
	var net_slot_change := incoming_count - outgoing_count
	
	if net_slot_change > 0:
		var free_slots := 0
		for i in inv_mgr.inventory.size():
			if inv_mgr.inventory[i] == null:
				free_slots += 1
		if free_slots < net_slot_change:
			_status_label.text = "Trade failed: Not enough inventory space"
			_my_confirmed = false
			_confirm_button.disabled = false
			return
	
	# Gold validáció
	if _my_offered_gold > 0:
		if not cur_mgr.can_afford_gold(_my_offered_gold):
			_status_label.text = "Trade failed: Not enough gold"
			_my_confirmed = false
			_confirm_button.disabled = false
			return
	
	# === Trade végrehajtás ===
	# 1. Saját itemek eltávolítása
	for item in _my_offered_items:
		if item and item.base_item:
			inv_mgr.remove_item_by_uuid(item.uuid)
	
	# 2. Saját gold levonás
	if _my_offered_gold > 0:
		cur_mgr.spend_gold(_my_offered_gold)
	
	# 3. Kapott itemek hozzáadása
	for item in _their_offered_items:
		if item:
			inv_mgr.add_item(item)
	
	# 4. Kapott gold hozzáadása
	if _their_offered_gold > 0:
		cur_mgr.add_gold(_their_offered_gold)
	
	_status_label.text = "Trade complete!"
	EventBus.trade_completed.emit(_my_offered_items, _their_offered_items)
	EventBus.hud_update_requested.emit()
	
	await get_tree().create_timer(1.5).timeout
	close_trade()


func _on_trade_completed(_a, _b) -> void:
	pass


func _update_ui() -> void:
	if not _is_visible:
		return
	
	# My items frissítés
	for child in _my_items.get_children():
		child.queue_free()
	
	for item in _my_offered_items:
		var label := Label.new()
		label.text = item.get_display_name()
		label.add_theme_font_size_override("font_size", 8)
		_my_items.add_child(label)
	
	# Their items frissítés
	for child in _their_items.get_children():
		child.queue_free()
	
	for item in _their_offered_items:
		var label := Label.new()
		label.text = item.get_display_name()
		label.add_theme_font_size_override("font_size", 8)
		_their_items.add_child(label)

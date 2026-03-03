## InventoryUI - Inventory és Equipment UI panel
## 30 slot grid, drag & drop, tooltip, equipment slot-ok
extends Control

const SLOT_SIZE: int = 36
const SLOT_PADDING: int = 2
const GRID_COLUMNS: int = 6  # 6 oszlop × 5 sor = 30 slot

var _inventory_grid: GridContainer = null
var _equipment_panel: VBoxContainer = null
var _slot_buttons: Array[Button] = []
var _equip_buttons: Dictionary = {}  # EquipSlot → Button
var _tooltip_panel: PanelContainer = null
var _tooltip_label: RichTextLabel = null
var _dragging_index: int = -1
var _is_visible: bool = false

# Referenciák
var _economy: Node = null
var _inv_mgr: InventoryManager = null


func _ready() -> void:
	_economy = get_node_or_null("/root/EconomyManager")
	if _economy:
		_inv_mgr = _economy.inventory_manager
	
	_build_ui()
	_connect_signals()
	visible = false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		toggle_visibility()


func toggle_visibility() -> void:
	_is_visible = not _is_visible
	visible = _is_visible
	if _is_visible:
		_refresh_all()
		EventBus.screen_opened.emit("inventory")
	else:
		EventBus.screen_closed.emit("inventory")


func _build_ui() -> void:
	# Háttér panel
	var bg := PanelContainer.new()
	bg.custom_minimum_size = Vector2(320, 280)
	bg.anchors_preset = Control.PRESET_CENTER
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.06, 0.95)
	style.border_color = Color(0.5, 0.4, 0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(8)
	bg.add_theme_stylebox_override("panel", style)
	add_child(bg)
	
	var main_hbox := HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 8)
	bg.add_child(main_hbox)
	
	# === Equipment panel (bal) ===
	_equipment_panel = VBoxContainer.new()
	_equipment_panel.add_theme_constant_override("separation", 2)
	main_hbox.add_child(_equipment_panel)
	
	var equip_label := Label.new()
	equip_label.text = "Equipment"
	equip_label.add_theme_font_size_override("font_size", 9)
	equip_label.add_theme_color_override("font_color", Color(0.8, 0.7, 0.4))
	_equipment_panel.add_child(equip_label)
	
	var equip_slots := [
		[Enums.EquipSlot.HELMET, "Helm"],
		[Enums.EquipSlot.CHEST, "Chest"],
		[Enums.EquipSlot.GLOVES, "Gloves"],
		[Enums.EquipSlot.BOOTS, "Boots"],
		[Enums.EquipSlot.BELT, "Belt"],
		[Enums.EquipSlot.SHOULDERS, "Shoulders"],
		[Enums.EquipSlot.MAIN_HAND, "Weapon"],
		[Enums.EquipSlot.OFF_HAND, "Off-Hand"],
		[Enums.EquipSlot.AMULET, "Amulet"],
		[Enums.EquipSlot.RING_1, "Ring 1"],
		[Enums.EquipSlot.RING_2, "Ring 2"],
		[Enums.EquipSlot.CAPE, "Cape"],
	]
	
	for slot_info in equip_slots:
		var slot_id: int = slot_info[0]
		var slot_name: String = slot_info[1]
		var btn := _create_slot_button(slot_name, Color(0.15, 0.12, 0.1))
		btn.pressed.connect(_on_equipment_slot_pressed.bind(slot_id))
		btn.mouse_entered.connect(_on_equipment_slot_hover.bind(slot_id))
		btn.mouse_exited.connect(_hide_tooltip)
		_equipment_panel.add_child(btn)
		_equip_buttons[slot_id] = btn
	
	# === Inventory grid (jobb) ===
	var inv_vbox := VBoxContainer.new()
	inv_vbox.add_theme_constant_override("separation", 4)
	main_hbox.add_child(inv_vbox)
	
	var inv_header := HBoxContainer.new()
	inv_vbox.add_child(inv_header)
	
	var inv_label := Label.new()
	inv_label.text = "Inventory"
	inv_label.add_theme_font_size_override("font_size", 9)
	inv_label.add_theme_color_override("font_color", Color(0.8, 0.7, 0.4))
	inv_header.add_child(inv_label)
	
	var sort_btn := Button.new()
	sort_btn.text = "Sort"
	sort_btn.add_theme_font_size_override("font_size", 8)
	sort_btn.pressed.connect(_on_sort_pressed)
	inv_header.add_child(sort_btn)
	
	_inventory_grid = GridContainer.new()
	_inventory_grid.columns = GRID_COLUMNS
	_inventory_grid.add_theme_constant_override("h_separation", SLOT_PADDING)
	_inventory_grid.add_theme_constant_override("v_separation", SLOT_PADDING)
	inv_vbox.add_child(_inventory_grid)
	
	# Slot-ok létrehozása
	var slot_count := Constants.INVENTORY_DEFAULT_SIZE
	for i in slot_count:
		var btn := _create_slot_button("", Color(0.12, 0.1, 0.08))
		btn.pressed.connect(_on_inventory_slot_pressed.bind(i))
		btn.mouse_entered.connect(_on_inventory_slot_hover.bind(i))
		btn.mouse_exited.connect(_hide_tooltip)
		_inventory_grid.add_child(btn)
		_slot_buttons.append(btn)
	
	# === Tooltip ===
	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.visible = false
	_tooltip_panel.z_index = 100
	var tooltip_style := StyleBoxFlat.new()
	tooltip_style.bg_color = Color(0.05, 0.05, 0.05, 0.95)
	tooltip_style.border_color = Color(0.5, 0.4, 0.2)
	tooltip_style.set_border_width_all(1)
	tooltip_style.set_content_margin_all(4)
	_tooltip_panel.add_theme_stylebox_override("panel", tooltip_style)
	
	_tooltip_label = RichTextLabel.new()
	_tooltip_label.bbcode_enabled = true
	_tooltip_label.fit_content = true
	_tooltip_label.custom_minimum_size = Vector2(150, 0)
	_tooltip_label.add_theme_font_size_override("normal_font_size", 8)
	_tooltip_panel.add_child(_tooltip_label)
	add_child(_tooltip_panel)


func _create_slot_button(text: String, bg_color: Color) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	btn.text = text
	btn.add_theme_font_size_override("font_size", 7)
	
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = Color(0.4, 0.35, 0.25)
	style.set_border_width_all(1)
	style.set_corner_radius_all(2)
	btn.add_theme_stylebox_override("normal", style)
	
	return btn


func _connect_signals() -> void:
	EventBus.inventory_changed.connect(_refresh_all)
	EventBus.equipment_changed.connect(_on_equipment_changed)


func _refresh_all() -> void:
	if not _inv_mgr:
		return
	
	# Inventory slot-ok frissítése
	for i in _slot_buttons.size():
		var btn: Button = _slot_buttons[i]
		var item: ItemInstance = _inv_mgr.inventory[i] if i < _inv_mgr.inventory.size() else null
		_update_slot_button(btn, item)
	
	# Equipment slot-ok frissítése
	for slot_id in _equip_buttons:
		var btn: Button = _equip_buttons[slot_id]
		var item: ItemInstance = _inv_mgr.get_equipped_item(slot_id)
		_update_equip_button(btn, slot_id, item)


func _update_slot_button(btn: Button, item: ItemInstance) -> void:
	if item and item.base_item:
		var short_name := item.base_item.item_name
		if short_name.length() > 5:
			short_name = short_name.substr(0, 4) + "."
		btn.text = short_name
		if item.quantity > 1:
			btn.text += "\n×%d" % item.quantity
		
		# Rarity szín a border-re
		var style: StyleBoxFlat = btn.get_theme_stylebox("normal").duplicate()
		style.border_color = item.get_rarity_color()
		style.set_border_width_all(2)
		btn.add_theme_stylebox_override("normal", style)
	else:
		btn.text = ""
		var style: StyleBoxFlat = btn.get_theme_stylebox("normal").duplicate()
		style.border_color = Color(0.4, 0.35, 0.25)
		style.set_border_width_all(1)
		btn.add_theme_stylebox_override("normal", style)


func _update_equip_button(btn: Button, slot_id: int, item: ItemInstance) -> void:
	if item and item.base_item:
		btn.text = item.base_item.item_name.substr(0, 6)
		var style: StyleBoxFlat = btn.get_theme_stylebox("normal").duplicate()
		style.border_color = item.get_rarity_color()
		style.set_border_width_all(2)
		btn.add_theme_stylebox_override("normal", style)
	else:
		# Slot neve visszaállítás placeholder-nek
		var names := {
			Enums.EquipSlot.HELMET: "Helm", Enums.EquipSlot.CHEST: "Chest",
			Enums.EquipSlot.GLOVES: "Gloves", Enums.EquipSlot.BOOTS: "Boots",
			Enums.EquipSlot.BELT: "Belt", Enums.EquipSlot.SHOULDERS: "Shld",
			Enums.EquipSlot.MAIN_HAND: "Weapon", Enums.EquipSlot.OFF_HAND: "Off",
			Enums.EquipSlot.AMULET: "Amulet", Enums.EquipSlot.RING_1: "Ring1",
			Enums.EquipSlot.RING_2: "Ring2", Enums.EquipSlot.CAPE: "Cape",
		}
		btn.text = names.get(slot_id, "?")


# ============================================================
#  INTERAKCIÓK
# ============================================================

func _on_inventory_slot_pressed(index: int) -> void:
	if not _inv_mgr:
		return
	var item: ItemInstance = _inv_mgr.inventory[index] if index < _inv_mgr.inventory.size() else null
	if not item:
		return
	
	# Jobb klikk → context menu (egyszerűsítve: bal klikk = equip/use)
	if item.base_item:
		match item.base_item.item_type:
			Enums.ItemType.WEAPON, Enums.ItemType.ARMOR, Enums.ItemType.ACCESSORY:
				_inv_mgr.equip_item(item)
			Enums.ItemType.CONSUMABLE:
				_use_consumable(index)
			_:
				pass  # Material, quest item stb.


func _on_equipment_slot_pressed(slot_id: int) -> void:
	if not _inv_mgr:
		return
	_inv_mgr.unequip_item(slot_id)


func _on_equipment_changed(_slot: Enums.EquipSlot) -> void:
	_refresh_all()


func _on_sort_pressed() -> void:
	if _inv_mgr:
		_inv_mgr.sort_inventory()


func _use_consumable(index: int) -> void:
	var item: ItemInstance = _inv_mgr.inventory[index]
	if not item or not item.base_item:
		return
	# TODO: Consumable hatás alkalmazás a player-re
	# Egyelőre egyszerű eltávolítás
	if item.quantity > 1:
		item.quantity -= 1
	else:
		_inv_mgr.remove_item_at(index)
	EventBus.inventory_changed.emit()


# ============================================================
#  TOOLTIP
# ============================================================

func _on_inventory_slot_hover(index: int) -> void:
	if not _inv_mgr:
		return
	var item: ItemInstance = _inv_mgr.inventory[index] if index < _inv_mgr.inventory.size() else null
	if item:
		_show_tooltip(item)
	else:
		_hide_tooltip()


func _on_equipment_slot_hover(slot_id: int) -> void:
	if not _inv_mgr:
		return
	var item := _inv_mgr.get_equipped_item(slot_id)
	if item:
		_show_tooltip(item)
	else:
		_hide_tooltip()


func _show_tooltip(item: ItemInstance) -> void:
	_tooltip_label.text = item.get_tooltip_text()
	_tooltip_label.text += "\nSell: %d gold" % int(item.get_sell_price() * Constants.NPC_SELL_MULTIPLIER)
	_tooltip_panel.visible = true
	_tooltip_panel.position = get_viewport().get_mouse_position() + Vector2(10, 10)


func _hide_tooltip() -> void:
	_tooltip_panel.visible = false

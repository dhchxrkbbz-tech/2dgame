## GemUI - Gem drag & drop, tooltip, socket vizualizáció
## A 09_gem_system_plan.txt 11.7 fejezete alapján
class_name GemUI
extends Control

## Jelenlegi kiválasztott gem (drag közben)
var dragged_gem: GemInstance = null
var drag_source_item: ItemInstance = null
var drag_source_socket: int = -1

## Aktív kombináló slot-ok (3 db)
var combine_slots: Array[GemInstance] = [null, null, null]

## Jeweler NPC nyitva?
var jeweler_open: bool = false

## Referenciák (scene-ben állítandó)
@export var socket_container: Container = null
@export var combine_container: Container = null
@export var combine_result_label: Label = null
@export var combine_button: Button = null
@export var gem_tooltip: PanelContainer = null
@export var gem_tooltip_label: RichTextLabel = null

# === Szignálok ===
signal gem_inserted(item: ItemInstance, socket_index: int, gem: GemInstance)
signal gem_removed_ui(item: ItemInstance, socket_index: int)
signal gems_combined(result_gem: GemInstance)
signal socket_added(item: ItemInstance)


func _ready() -> void:
	if combine_button:
		combine_button.pressed.connect(_on_combine_pressed)
	hide_tooltip()


# ══════════════════════════════════════════════
# SOCKET DISPLAY
# ══════════════════════════════════════════════

## Socket-ek megjelenítése egy item-hez
func display_sockets(item: ItemInstance) -> void:
	if not socket_container or not item:
		return

	# Régi tartalom törlése
	for child in socket_container.get_children():
		child.queue_free()

	for i in item.sockets.size():
		var socket_slot := _create_socket_slot(item, i)
		socket_container.add_child(socket_slot)


## Egyetlen socket slot UI elem létrehozása
func _create_socket_slot(item: ItemInstance, index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(40, 40)
	panel.tooltip_text = ""

	var gem: GemInstance = item.sockets[index] if index < item.sockets.size() else null

	# Háttér
	var bg := ColorRect.new()
	bg.custom_minimum_size = Vector2(36, 36)
	bg.color = Color(0.15, 0.15, 0.2, 0.8)
	panel.add_child(bg)

	if gem:
		# Gem szín négyzet
		var gem_rect := ColorRect.new()
		gem_rect.custom_minimum_size = Vector2(28, 28)
		gem_rect.position = Vector2(4, 4)
		gem_rect.color = gem.get_color()
		bg.add_child(gem_rect)

		# Tier jelzés (pontok)
		var tier_label := Label.new()
		tier_label.text = _get_tier_indicator(gem.gem_tier)
		tier_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		tier_label.position = Vector2(0, 28)
		tier_label.add_theme_font_size_override("font_size", 8)
		bg.add_child(tier_label)
	else:
		# Üres socket jelzés
		var empty_label := Label.new()
		empty_label.text = "◇"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 18)
		empty_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
		bg.add_child(empty_label)

	# Input kezelés
	panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				_on_socket_clicked(item, index)
			elif event.button_index == MOUSE_BUTTON_RIGHT:
				_on_socket_right_clicked(item, index)
	)

	panel.mouse_entered.connect(func():
		_show_socket_tooltip(item, index)
	)
	panel.mouse_exited.connect(func():
		hide_tooltip()
	)

	return panel


## Tier vizuális jelzés (◆ pontok száma)
func _get_tier_indicator(tier: Enums.GemTier) -> String:
	var count := tier + 1
	var indicator := ""
	for i in count:
		indicator += "◆"
	return indicator


# ══════════════════════════════════════════════
# DRAG & DROP
# ══════════════════════════════════════════════

## Gem drag indítás inventory-ból
func start_gem_drag(gem: GemInstance, source_item: ItemInstance = null, source_socket: int = -1) -> void:
	dragged_gem = gem
	drag_source_item = source_item
	drag_source_socket = source_socket


## Gem drop socket-be
func drop_gem_to_socket(item: ItemInstance, socket_index: int) -> bool:
	if not dragged_gem:
		return false

	var success := SocketSystem.insert_gem(item, socket_index, dragged_gem)
	if success:
		gem_inserted.emit(item, socket_index, dragged_gem)
		_clear_drag()
		display_sockets(item)
		return true
	return false


## Drag állapot törlése
func _clear_drag() -> void:
	dragged_gem = null
	drag_source_item = null
	drag_source_socket = -1


# ══════════════════════════════════════════════
# SOCKET CLICK KEZELÉS
# ══════════════════════════════════════════════

func _on_socket_clicked(item: ItemInstance, index: int) -> void:
	var gem: GemInstance = item.sockets[index] if index < item.sockets.size() else null

	if dragged_gem:
		# Ha van drag-olt gem, próbáljuk betenni
		if gem:
			# Socket foglalt → swap
			var old_gem := SocketSystem.swap_gem(item, index, dragged_gem)
			if old_gem:
				gem_inserted.emit(item, index, dragged_gem)
				_clear_drag()
				display_sockets(item)
		else:
			drop_gem_to_socket(item, index)
	elif gem:
		# Ha van gem a socket-ben, kijelöljük drag-ra
		start_gem_drag(gem, item, index)


func _on_socket_right_clicked(item: ItemInstance, index: int) -> void:
	var gem: GemInstance = item.sockets[index] if index < item.sockets.size() else null
	if gem and jeweler_open:
		# Jobb klikk Jeweler-nél → eltávolítás
		var cost := SocketSystem.get_removal_cost(gem)
		# TODO: Gold ellenőrzés és levonás az economy rendszeren keresztül
		var removed := SocketSystem.remove_gem(item, index, true)
		if removed:
			gem_removed_ui.emit(item, index)
			display_sockets(item)


# ══════════════════════════════════════════════
# GEM KOMBINÁLÁS UI
# ══════════════════════════════════════════════

## Gem hozzáadás a kombinálóhoz
func add_gem_to_combiner(gem: GemInstance) -> bool:
	for i in combine_slots.size():
		if combine_slots[i] == null:
			combine_slots[i] = gem
			_update_combine_preview()
			return true
	return false  # Mind foglalt


## Gem törlése a kombinálóból
func remove_gem_from_combiner(slot_index: int) -> GemInstance:
	if slot_index < 0 or slot_index >= combine_slots.size():
		return null
	var gem := combine_slots[slot_index]
	combine_slots[slot_index] = null
	_update_combine_preview()
	return gem


## Kombináló slot-ok ürítése
func clear_combiner() -> void:
	combine_slots = [null, null, null]
	_update_combine_preview()


## Kombináló preview frissítése
func _update_combine_preview() -> void:
	if not combine_result_label:
		return

	var filled: Array = combine_slots.filter(func(g): return g != null)
	if filled.size() < GemCombiner.GEMS_NEEDED:
		combine_result_label.text = "Place 3 identical gems to combine"
		if combine_button:
			combine_button.disabled = true
		return

	var preview := GemCombiner.get_combine_preview(filled)
	combine_result_label.text = preview

	var check := GemCombiner.can_combine(filled)
	if combine_button:
		combine_button.disabled = not check.can_combine


## Combine gomb megnyomása
func _on_combine_pressed() -> void:
	var filled: Array = combine_slots.filter(func(g): return g != null)
	var check := GemCombiner.can_combine(filled)
	if not check.can_combine:
		return

	var result := GemCombiner.combine(filled)
	if result:
		gems_combined.emit(result)
		clear_combiner()


# ══════════════════════════════════════════════
# TOOLTIP
# ══════════════════════════════════════════════

## Socket tooltip megjelenítése
func _show_socket_tooltip(item: ItemInstance, index: int) -> void:
	if not gem_tooltip or not gem_tooltip_label:
		return

	var gem: GemInstance = item.sockets[index] if index < item.sockets.size() else null
	if gem:
		var equip_slot := item.base_item.equip_slot if item.base_item else -1
		gem_tooltip_label.text = gem.get_tooltip_text(equip_slot)
	else:
		gem_tooltip_label.text = "Empty Socket\nDrag a gem here to socket it."

	gem_tooltip.visible = true
	gem_tooltip.global_position = get_global_mouse_position() + Vector2(16, 16)


## Gem tooltip megjelenítése (általános, inventory-ban)
func show_gem_tooltip(gem: GemInstance, equip_slot: int = -1) -> void:
	if not gem_tooltip or not gem_tooltip_label or not gem:
		return
	gem_tooltip_label.text = gem.get_tooltip_text(equip_slot)
	gem_tooltip.visible = true
	gem_tooltip.global_position = get_global_mouse_position() + Vector2(16, 16)


## Tooltip elrejtése
func hide_tooltip() -> void:
	if gem_tooltip:
		gem_tooltip.visible = false


# ══════════════════════════════════════════════
# JEWELER NPC INTERFACE
# ══════════════════════════════════════════════

## Jeweler megnyitása
func open_jeweler() -> void:
	jeweler_open = true
	visible = true


## Jeweler bezárása
func close_jeweler() -> void:
	jeweler_open = false
	_clear_drag()
	clear_combiner()
	visible = false


## Socket bővítés UI
func request_add_socket(item: ItemInstance) -> bool:
	if not SocketSystem.can_add_socket(item):
		return false

	var cost := SocketSystem.get_add_socket_cost(item)
	# TODO: Economy rendszer ellenőrzés + levonás

	if SocketSystem.add_socket(item):
		socket_added.emit(item)
		display_sockets(item)
		return true
	return false

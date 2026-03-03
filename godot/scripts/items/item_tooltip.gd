## ItemTooltip - Item tooltip UI generálás
## Részletes item információ megjelenítés rarity-színezéssel
class_name ItemTooltip
extends PanelContainer

var _item: ItemInstance = null
var _compare_item: ItemInstance = null  # Összehasonlításhoz (equipped)

@onready var _content: VBoxContainer
@onready var _name_label: RichTextLabel
@onready var _type_label: Label
@onready var _base_stats_label: RichTextLabel
@onready var _affix_stats_label: RichTextLabel
@onready var _set_label: RichTextLabel
@onready var _unique_label: RichTextLabel
@onready var _socket_label: RichTextLabel
@onready var _req_label: Label
@onready var _price_label: Label


func _ready() -> void:
	_create_ui()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func _create_ui() -> void:
	# Panel styling
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.12, 0.95)
	style.border_color = Color(0.3, 0.3, 0.4, 0.8)
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	add_theme_stylebox_override("panel", style)
	
	custom_minimum_size = Vector2(180, 0)
	
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 2)
	add_child(_content)
	
	# Item név (RichTextLabel rarity-színnel)
	_name_label = RichTextLabel.new()
	_name_label.bbcode_enabled = true
	_name_label.fit_content = true
	_name_label.scroll_active = false
	_name_label.custom_minimum_size.x = 170
	_name_label.add_theme_font_size_override("normal_font_size", 11)
	_content.add_child(_name_label)
	
	# Típus
	_type_label = Label.new()
	_type_label.add_theme_font_size_override("font_size", 8)
	_type_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	_content.add_child(_type_label)
	
	# Elválasztó
	_content.add_child(_create_separator())
	
	# Base stats
	_base_stats_label = RichTextLabel.new()
	_base_stats_label.bbcode_enabled = true
	_base_stats_label.fit_content = true
	_base_stats_label.scroll_active = false
	_base_stats_label.add_theme_font_size_override("normal_font_size", 9)
	_content.add_child(_base_stats_label)
	
	# Affix stats
	_affix_stats_label = RichTextLabel.new()
	_affix_stats_label.bbcode_enabled = true
	_affix_stats_label.fit_content = true
	_affix_stats_label.scroll_active = false
	_affix_stats_label.add_theme_font_size_override("normal_font_size", 9)
	_content.add_child(_affix_stats_label)
	
	# Set bónusz
	_set_label = RichTextLabel.new()
	_set_label.bbcode_enabled = true
	_set_label.fit_content = true
	_set_label.scroll_active = false
	_set_label.add_theme_font_size_override("normal_font_size", 9)
	_content.add_child(_set_label)
	
	# Unique property
	_unique_label = RichTextLabel.new()
	_unique_label.bbcode_enabled = true
	_unique_label.fit_content = true
	_unique_label.scroll_active = false
	_unique_label.add_theme_font_size_override("normal_font_size", 9)
	_content.add_child(_unique_label)
	
	# Socket-ok
	_socket_label = RichTextLabel.new()
	_socket_label.bbcode_enabled = true
	_socket_label.fit_content = true
	_socket_label.scroll_active = false
	_socket_label.add_theme_font_size_override("normal_font_size", 9)
	_content.add_child(_socket_label)
	
	# Requirements
	_req_label = Label.new()
	_req_label.add_theme_font_size_override("font_size", 8)
	_req_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	_content.add_child(_req_label)
	
	# Ár
	_price_label = Label.new()
	_price_label.add_theme_font_size_override("font_size", 8)
	_price_label.add_theme_color_override("font_color", Color(0.85, 0.75, 0.2))
	_content.add_child(_price_label)


## Tooltip megjelenítés egy itemhez
func show_item(item: ItemInstance, compare_to: ItemInstance = null) -> void:
	_item = item
	_compare_item = compare_to
	
	if not item:
		visible = false
		return
	
	_update_content()
	visible = true


## Tooltip elrejtés
func hide_tooltip() -> void:
	visible = false
	_item = null
	_compare_item = null


## Tartalom frissítés
func _update_content() -> void:
	if not _item:
		return
	
	var rarity_color := _get_rarity_color_hex(_item.rarity)
	
	# Név
	_name_label.clear()
	_name_label.append_text("[color=%s][b]%s[/b][/color]\n[color=#888888][%s][/color]" % [
		rarity_color,
		_item.get_display_name(),
		_get_rarity_name(_item.rarity),
	])
	
	# Típus + slot
	if _item.base_item:
		var type_name := _get_type_name(_item.base_item.item_type)
		var slot_name := _get_slot_name(_item.base_item.equip_slot)
		_type_label.text = "%s | %s" % [type_name, slot_name]
		_type_label.visible = true
	else:
		_type_label.visible = false
	
	# Base stats
	_base_stats_label.clear()
	if _item.base_item:
		if _item.base_item.base_damage > 0:
			_base_stats_label.append_text("[color=#ffffff]%d Damage[/color]\n" % _item.base_item.base_damage)
		if _item.base_item.base_armor > 0:
			_base_stats_label.append_text("[color=#ffffff]%d Armor[/color]\n" % _item.base_item.base_armor)
		if _item.base_item.base_hp > 0:
			_base_stats_label.append_text("[color=#ffffff]+%d Max HP[/color]\n" % _item.base_item.base_hp)
		if _item.base_item.base_mana > 0:
			_base_stats_label.append_text("[color=#ffffff]+%d Max Mana[/color]\n" % _item.base_item.base_mana)
	_base_stats_label.visible = _base_stats_label.get_parsed_text().length() > 0
	
	# Affix stats (zöld)
	_affix_stats_label.clear()
	for affix_entry in _item.affixes:
		var affix: AffixData = affix_entry.get("affix")
		var value: float = affix_entry.get("value", 0.0)
		if affix:
			var stat_text := affix.stat_type.replace("_", " ").capitalize()
			var value_text: String
			if affix.is_percent:
				value_text = "+%.1f%% %s" % [value, stat_text]
			else:
				value_text = "+%d %s" % [int(value), stat_text]
			
			# Összehasonlítás jelzés
			var compare_suffix := ""
			if _compare_item:
				var diff := _get_stat_diff(affix.stat_type, value)
				if diff > 0:
					compare_suffix = " [color=#00ff00](+%.1f)[/color]" % diff
				elif diff < 0:
					compare_suffix = " [color=#ff0000](%.1f)[/color]" % diff
			
			_affix_stats_label.append_text("[color=#00cc00]%s[/color]%s\n" % [value_text, compare_suffix])
	_affix_stats_label.visible = not _item.affixes.is_empty()
	
	# Set bónusz
	_set_label.clear()
	if not _item.set_id.is_empty():
		_set_label.append_text(SetItemData.get_set_tooltip(_item.set_id, 0))
	_set_label.visible = not _item.set_id.is_empty()
	
	# Unique property (narancs)
	_unique_label.clear()
	if not _item.unique_property.is_empty():
		var unique_name: String = _item.unique_property.get("name", "")
		var unique_desc: String = _item.unique_property.get("description", "")
		_unique_label.append_text("\n[color=#ff9900][b]%s[/b][/color]\n[color=#ffcc66]%s[/color]" % [unique_name, unique_desc])
	_unique_label.visible = not _item.unique_property.is_empty()
	
	# Socket-ok
	_socket_label.clear()
	if _item.base_item and _item.base_item.socket_count > 0:
		var filled := _item.sockets.filter(func(s): return s != null).size()
		var socket_text := "Sockets: "
		for i in _item.base_item.socket_count:
			if i < _item.sockets.size() and _item.sockets[i] != null:
				socket_text += "[●]"
			else:
				socket_text += "[○]"
			if i < _item.base_item.socket_count - 1:
				socket_text += " "
		_socket_label.append_text("[color=#aaaaaa]%s[/color]" % socket_text)
	_socket_label.visible = _item.base_item and _item.base_item.socket_count > 0
	
	# Requirements
	var req_text := ""
	if _item.base_item:
		req_text = "Requires Level %d" % _item.base_item.required_level
		if _item.base_item.required_class >= 0:
			var class_names := ["Assassin", "Tank", "Mage"]
			var cls: String = class_names[_item.base_item.required_class] if _item.base_item.required_class < class_names.size() else "?"
			req_text += "\nRequires: %s" % cls
		req_text += "\niLvl: %d" % _item.item_level
	_req_label.text = req_text
	_req_label.visible = not req_text.is_empty()
	
	# Sell price
	_price_label.text = "Sell: %d gold" % _item.get_sell_price()
	_price_label.visible = true
	
	# Rarity border frissítés
	var panel_style: StyleBoxFlat = get_theme_stylebox("panel").duplicate()
	panel_style.border_color = _get_rarity_color(_item.rarity)
	add_theme_stylebox_override("panel", panel_style)


func _get_stat_diff(stat_type: String, value: float) -> float:
	if not _compare_item:
		return 0.0
	var compare_stats := _compare_item.get_total_stats()
	var compare_value: float = compare_stats.get(stat_type, 0.0)
	return value - compare_value


func _create_separator() -> HSeparator:
	var sep := HSeparator.new()
	sep.add_theme_stylebox_override("separator", StyleBoxLine.new())
	return sep


func _get_rarity_color(rarity: int) -> Color:
	return Constants.RARITY_COLORS.get(rarity, Color.WHITE)


func _get_rarity_color_hex(rarity: int) -> String:
	var c := _get_rarity_color(rarity)
	return "#%02x%02x%02x" % [int(c.r * 255), int(c.g * 255), int(c.b * 255)]


func _get_rarity_name(rarity: int) -> String:
	match rarity:
		Enums.Rarity.COMMON: return "Common"
		Enums.Rarity.UNCOMMON: return "Uncommon"
		Enums.Rarity.RARE: return "Rare"
		Enums.Rarity.EPIC: return "Epic"
		Enums.Rarity.LEGENDARY: return "Legendary"
		_: return "Unknown"


func _get_type_name(item_type: int) -> String:
	match item_type:
		Enums.ItemType.WEAPON: return "Weapon"
		Enums.ItemType.ARMOR: return "Armor"
		Enums.ItemType.ACCESSORY: return "Accessory"
		Enums.ItemType.CONSUMABLE: return "Consumable"
		Enums.ItemType.MATERIAL: return "Material"
		Enums.ItemType.GEM: return "Gem"
		_: return "Item"


func _get_slot_name(slot: int) -> String:
	match slot:
		Enums.EquipSlot.HELMET: return "Helmet"
		Enums.EquipSlot.CHEST: return "Chest"
		Enums.EquipSlot.GLOVES: return "Gloves"
		Enums.EquipSlot.BOOTS: return "Boots"
		Enums.EquipSlot.BELT: return "Belt"
		Enums.EquipSlot.SHOULDERS: return "Shoulders"
		Enums.EquipSlot.MAIN_HAND: return "Main Hand"
		Enums.EquipSlot.OFF_HAND: return "Off Hand"
		Enums.EquipSlot.AMULET: return "Amulet"
		Enums.EquipSlot.RING_1: return "Ring"
		Enums.EquipSlot.RING_2: return "Ring"
		Enums.EquipSlot.CAPE: return "Cape"
		_: return "Unknown"


## Statikus factory: tooltip létrehozás
static func create() -> ItemTooltip:
	var tooltip := ItemTooltip.new()
	return tooltip

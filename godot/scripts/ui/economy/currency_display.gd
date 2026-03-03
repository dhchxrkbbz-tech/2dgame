## CurrencyDisplay - HUD valuta kijelző
## Gold, Dark Essence, Relic Fragment megjelenítés
extends Control

var _gold_label: Label = null
var _de_label: Label = null
var _rf_label: Label = null
var _container: HBoxContainer = null


func _ready() -> void:
	_build_ui()
	_connect_signals()
	_update_display()


func _build_ui() -> void:
	# Fő konténer
	_container = HBoxContainer.new()
	_container.add_theme_constant_override("separation", 12)
	add_child(_container)
	
	# Gold
	_gold_label = _create_currency_label(Color(1.0, 0.85, 0.0), "0")
	_container.add_child(_gold_label)
	
	# Dark Essence
	_de_label = _create_currency_label(Color(0.6, 0.0, 0.8), "0")
	_container.add_child(_de_label)
	
	# Relic Fragment
	_rf_label = _create_currency_label(Color(0.4, 0.6, 0.8), "0")
	_container.add_child(_rf_label)
	
	# Pozíció (jobb felső sarok)
	anchors_preset = Control.PRESET_TOP_RIGHT
	position = Vector2(-200, 8)


func _create_currency_label(icon_color: Color, initial_text: String) -> Label:
	var label := Label.new()
	label.text = initial_text
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", icon_color)
	return label


func _connect_signals() -> void:
	EventBus.currency_changed.connect(_on_currency_changed)


func _on_currency_changed(_type: Enums.CurrencyType, _amount: int) -> void:
	_update_display()


func _update_display() -> void:
	var economy = get_node_or_null("/root/EconomyManager")
	if not economy or not economy.currency_manager:
		return
	
	var cm: CurrencyManager = economy.currency_manager
	_gold_label.text = "G: %s" % Utils.format_number(cm.get_gold())
	_de_label.text = "DE: %s" % Utils.format_number(cm.get_dark_essence())
	_rf_label.text = "RF: %s" % Utils.format_number(cm.get_relic_fragments())

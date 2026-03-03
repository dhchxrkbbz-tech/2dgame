## CraftingUI - Crafting station interfész
## Recept lista, ingredient megjelenítés, progress bar, craft gomb
extends Control

var _panel: PanelContainer = null
var _recipe_list: VBoxContainer = null
var _detail_panel: VBoxContainer = null
var _craft_button: Button = null
var _progress_bar: ProgressBar = null
var _station_label: Label = null
var _selected_recipe: CraftingRecipe = null
var _is_visible: bool = false

var _economy: Node = null
var _craft_mgr: CraftingManager = null
var _cur_mgr: CurrencyManager = null
var _inv_mgr: InventoryManager = null

## Aktuális station típus
var _current_station: int = Enums.StationType.WORKBENCH


func _ready() -> void:
	_economy = get_node_or_null("/root/EconomyManager")
	if _economy:
		_craft_mgr = _economy.crafting_manager
		_cur_mgr = _economy.currency_manager
		_inv_mgr = _economy.inventory_manager
	
	_build_ui()
	_connect_signals()
	visible = false


func _process(_delta: float) -> void:
	if _is_visible and _craft_mgr and _craft_mgr.is_crafting():
		_progress_bar.value = _craft_mgr.get_craft_progress() * 100.0


## Station megnyitása (kívülről hívható)
func open_station(station_type: int) -> void:
	_current_station = station_type
	_station_label.text = _get_station_name(station_type)
	_is_visible = true
	visible = true
	_refresh_recipe_list()
	_clear_detail_panel()
	EventBus.screen_opened.emit("crafting")


func close_station() -> void:
	_is_visible = false
	visible = false
	_selected_recipe = null
	EventBus.screen_closed.emit("crafting")


func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(320, 240)
	_panel.anchors_preset = Control.PRESET_CENTER
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.08, 0.06, 0.95)
	style.border_color = Color(0.5, 0.4, 0.2)
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
	
	_station_label = Label.new()
	_station_label.text = "Crafting"
	_station_label.add_theme_font_size_override("font_size", 11)
	_station_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	_station_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_station_label)
	
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.add_theme_font_size_override("font_size", 9)
	close_btn.pressed.connect(close_station)
	header.add_child(close_btn)
	
	# Content (recept lista + details)
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(content)
	
	# Recept lista (bal)
	var recipe_scroll := ScrollContainer.new()
	recipe_scroll.custom_minimum_size = Vector2(120, 0)
	content.add_child(recipe_scroll)
	
	_recipe_list = VBoxContainer.new()
	_recipe_list.add_theme_constant_override("separation", 2)
	recipe_scroll.add_child(_recipe_list)
	
	# Detail panel (jobb)
	_detail_panel = VBoxContainer.new()
	_detail_panel.add_theme_constant_override("separation", 4)
	_detail_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(_detail_panel)
	
	# Progress bar + Craft gomb (alul)
	var bottom := VBoxContainer.new()
	main_vbox.add_child(bottom)
	
	_progress_bar = ProgressBar.new()
	_progress_bar.custom_minimum_size = Vector2(0, 12)
	_progress_bar.value = 0
	_progress_bar.show_percentage = false
	bottom.add_child(_progress_bar)
	
	_craft_button = Button.new()
	_craft_button.text = "Craft"
	_craft_button.add_theme_font_size_override("font_size", 10)
	_craft_button.pressed.connect(_on_craft_pressed)
	_craft_button.disabled = true
	bottom.add_child(_craft_button)


func _connect_signals() -> void:
	EventBus.crafting_completed.connect(_on_crafting_completed)
	EventBus.inventory_changed.connect(_on_inventory_changed)


func _refresh_recipe_list() -> void:
	for child in _recipe_list.get_children():
		child.queue_free()
	
	if not _craft_mgr:
		return
	
	var prof_levels: Dictionary = {}
	if _economy and _economy.profession_manager:
		prof_levels = _economy.profession_manager.get_all_levels()
	
	var recipes := _craft_mgr.get_available_recipes(_current_station, prof_levels)
	
	for recipe in recipes:
		var btn := Button.new()
		btn.text = recipe.recipe_name
		btn.add_theme_font_size_override("font_size", 8)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		# Szín jelzés craftolhatóság alapján
		var can_craft := _craft_mgr.can_craft(recipe.recipe_id)
		if can_craft:
			btn.add_theme_color_override("font_color", Color(0.8, 0.9, 0.8))
		else:
			btn.add_theme_color_override("font_color", Color(0.5, 0.4, 0.4))
		
		btn.pressed.connect(_on_recipe_selected.bind(recipe))
		_recipe_list.add_child(btn)


func _on_recipe_selected(recipe: CraftingRecipe) -> void:
	_selected_recipe = recipe
	_show_recipe_details(recipe)


func _show_recipe_details(recipe: CraftingRecipe) -> void:
	_clear_detail_panel()
	
	# Recept név
	var title := Label.new()
	title.text = recipe.recipe_name
	title.add_theme_font_size_override("font_size", 10)
	title.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	_detail_panel.add_child(title)
	
	# Hozzávalók
	var ing_label := Label.new()
	ing_label.text = "Ingredients:"
	ing_label.add_theme_font_size_override("font_size", 8)
	ing_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	_detail_panel.add_child(ing_label)
	
	for ingredient in recipe.ingredients:
		var item_id: String = ingredient.get("item_id", "")
		var count: int = ingredient.get("count", 1)
		var have: int = _inv_mgr.count_item(item_id) if _inv_mgr else 0
		
		var line := Label.new()
		line.text = "  %s: %d/%d" % [item_id.replace("_", " ").capitalize(), have, count]
		line.add_theme_font_size_override("font_size", 8)
		line.add_theme_color_override("font_color", Color(0.5, 0.9, 0.5) if have >= count else Color(0.9, 0.4, 0.4))
		_detail_panel.add_child(line)
	
	# Költség
	if recipe.gold_cost > 0:
		var gold_line := Label.new()
		gold_line.text = "  Gold: %d" % recipe.gold_cost
		gold_line.add_theme_font_size_override("font_size", 8)
		gold_line.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		_detail_panel.add_child(gold_line)
	
	if recipe.dark_essence_cost > 0:
		var de_line := Label.new()
		de_line.text = "  Dark Essence: %d" % recipe.dark_essence_cost
		de_line.add_theme_font_size_override("font_size", 8)
		de_line.add_theme_color_override("font_color", Color(0.6, 0.0, 0.8))
		_detail_panel.add_child(de_line)
	
	# Siker esély
	if recipe.success_rate < 1.0:
		var rate_label := Label.new()
		rate_label.text = "Success: %d%%" % int(recipe.success_rate * 100)
		rate_label.add_theme_font_size_override("font_size", 8)
		rate_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.3))
		_detail_panel.add_child(rate_label)
	
	# Crafting idő
	var time_label := Label.new()
	time_label.text = "Time: %.1fs" % recipe.crafting_time
	time_label.add_theme_font_size_override("font_size", 8)
	_detail_panel.add_child(time_label)
	
	# Craft gomb engedélyezés
	_craft_button.disabled = not (_craft_mgr and _craft_mgr.can_craft(recipe.recipe_id))


func _clear_detail_panel() -> void:
	for child in _detail_panel.get_children():
		child.queue_free()
	_craft_button.disabled = true
	_progress_bar.value = 0


func _on_craft_pressed() -> void:
	if not _selected_recipe or not _craft_mgr:
		return
	
	if _craft_mgr.start_craft(_selected_recipe.recipe_id):
		_craft_button.disabled = true


func _on_crafting_completed(recipe_id: String, success: bool) -> void:
	_progress_bar.value = 0
	
	if _is_visible:
		_refresh_recipe_list()
		if _selected_recipe and _selected_recipe.recipe_id == recipe_id:
			_show_recipe_details(_selected_recipe)
	
	# Notification
	if success:
		EventBus.show_notification.emit("Crafting complete!", Enums.NotificationType.INFO)
	else:
		EventBus.show_notification.emit("Crafting failed! Materials lost.", Enums.NotificationType.WARNING)


func _on_inventory_changed() -> void:
	if _is_visible:
		_refresh_recipe_list()
		if _selected_recipe:
			_show_recipe_details(_selected_recipe)


func _get_station_name(station_type: int) -> String:
	match station_type:
		Enums.StationType.ANVIL: return "Anvil (Blacksmith)"
		Enums.StationType.ALCHEMY_TABLE: return "Alchemy Table"
		Enums.StationType.ENCHANTING_TABLE: return "Enchanting Table"
		Enums.StationType.WORKBENCH: return "Workbench"
		Enums.StationType.RUNE_ALTAR: return "Rune Altar"
		_: return "Crafting Station"

## LanguageSettingsUI - Nyelvválasztás fül
## Magyar / English nyelvek közt váltás
class_name LanguageSettingsUI
extends VBoxContainer

signal settings_changed()


func _ready() -> void:
	name = "Language"
	_build_ui()


func _build_ui() -> void:
	# Cím
	var title := Label.new()
	title.text = tr("SETTINGS_LANGUAGE_SELECT")
	title.add_theme_font_size_override("font_size", AccessibilityManager.get_scaled_font_size(14))
	add_child(title)
	
	var sep := HSeparator.new()
	add_child(sep)
	
	# Nyelv választó
	var hbox := HBoxContainer.new()
	
	var label := Label.new()
	label.text = tr("SETTINGS_LANGUAGE")
	label.custom_minimum_size = Vector2(150, 0)
	hbox.add_child(label)
	
	var option_btn := OptionButton.new()
	option_btn.name = "LanguageOption"
	
	for lang in LocalizationManager.SUPPORTED_LANGUAGES:
		option_btn.add_item(lang["native_name"])
	
	option_btn.selected = LocalizationManager.get_language_index()
	option_btn.item_selected.connect(_on_language_selected)
	hbox.add_child(option_btn)
	
	add_child(hbox)
	
	# Megjegyzés
	var note := Label.new()
	note.text = "A nyelv változtatása azonnali, nem kell újraindítás.\nLanguage change is immediate, no restart needed."
	note.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	note.add_theme_font_size_override("font_size", AccessibilityManager.get_scaled_font_size(9))
	add_child(note)
	
	# Jövőbeli nyelvek
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	add_child(spacer)
	
	var future_label := Label.new()
	future_label.text = "Future languages / Tervezett nyelvek:"
	future_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	add_child(future_label)
	
	var future_list := Label.new()
	future_list.text = "  • Deutsch (DE)\n  • Español (ES)\n  • 日本語 (JA)"
	future_list.add_theme_color_override("font_color", Color(0.4, 0.4, 0.4))
	add_child(future_list)


func _on_language_selected(index: int) -> void:
	LocalizationManager.set_language_by_index(index)
	settings_changed.emit()
	
	# UI újraépítés szükséges a nyelv váltás után
	# Az egész settings menü újraépül
	_request_ui_rebuild()


func _request_ui_rebuild() -> void:
	# A szülő settings UI-nak szólunk, hogy újra kell építenie
	var parent := get_parent()
	while parent:
		if parent is SettingsUI:
			# A settings UI fog újra felépülni
			parent.rebuild_ui()
			return
		parent = parent.get_parent()

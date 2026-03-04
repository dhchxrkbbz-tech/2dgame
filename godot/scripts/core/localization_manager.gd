## LocalizationManager - Lokalizációs rendszer (Autoload singleton)
## Nyelvválasztás, tr() wrapper, számformázás, dátumformázás
extends Node

# === Signalok ===
signal language_changed(locale: String)

# === Támogatott nyelvek ===
const SUPPORTED_LANGUAGES: Array[Dictionary] = [
	{"code": "hu", "name": "Magyar", "native_name": "Magyar"},
	{"code": "en", "name": "English", "native_name": "English"},
]

# === Jelenlegi nyelv ===
var current_locale: String = "hu"  # Alapértelmezett: magyar

# === Mechanika kulcsszavak konzisztens fordítása ===
const MECHANIC_TERMS: Dictionary = {
	"Damage": "Sebzés",
	"Armor": "Páncél",
	"Health": "Életerő",
	"Mana": "Mana",
	"Cooldown": "Visszatöltés",
	"Critical": "Kritikus",
	"Dodge": "Kitérés",
	"Block": "Blokkolás",
	"Stun": "Bénítás",
	"Freeze": "Fagyasztás",
	"Poison": "Mérgezés",
	"Buff": "Erősítés",
	"Debuff": "Gyengítés",
}

# Settings save path
const LOCALE_SETTINGS_PATH: String = "user://locale.cfg"


func _ready() -> void:
	_load_locale()
	_apply_locale()


# === Nyelv váltás ===
func set_language(locale_code: String) -> void:
	if locale_code == current_locale:
		return
	
	# Ellenőrizzük, hogy támogatott-e
	var supported := false
	for lang in SUPPORTED_LANGUAGES:
		if lang["code"] == locale_code:
			supported = true
			break
	
	if not supported:
		push_warning("LocalizationManager: Unsupported locale: %s" % locale_code)
		return
	
	current_locale = locale_code
	_apply_locale()
	_save_locale()
	language_changed.emit(locale_code)


func _apply_locale() -> void:
	TranslationServer.set_locale(current_locale)


func get_current_language_name() -> String:
	for lang in SUPPORTED_LANGUAGES:
		if lang["code"] == current_locale:
			return lang["native_name"]
	return current_locale


func get_language_index() -> int:
	for i in range(SUPPORTED_LANGUAGES.size()):
		if SUPPORTED_LANGUAGES[i]["code"] == current_locale:
			return i
	return 0


func set_language_by_index(index: int) -> void:
	if index >= 0 and index < SUPPORTED_LANGUAGES.size():
		set_language(SUPPORTED_LANGUAGES[index]["code"])


# === Szöveg segédfüggvények ===
func localize(key: String, params: Dictionary = {}) -> String:
	## Lokalizált szöveg lekérése paraméterekkel
	## Használat: LocalizationManager.localize("NOTIFICATION_LEVEL_UP", {"level": 5})
	var text := tr(key)
	
	# Paraméterek behelyettesítése
	for param_key in params:
		text = text.replace("{%s}" % param_key, str(params[param_key]))
	
	return text


func localize_number(number: float, decimals: int = 0) -> String:
	## Szám formázás nyelv szerint
	## EN: 1,000.50  |  HU: 1 000,50
	var formatted: String
	
	if decimals > 0:
		formatted = "%.*f" % [decimals, number]
	else:
		formatted = str(int(number))
	
	match current_locale:
		"hu":
			# Magyar: szóköz ezres elválasztó, vessző tizedes
			formatted = _format_number_hu(number, decimals)
		"en":
			# Angol: vessző ezres elválasztó, pont tizedes
			formatted = _format_number_en(number, decimals)
	
	return formatted


func _format_number_hu(number: float, decimals: int) -> String:
	var is_negative := number < 0
	number = absf(number)
	var int_part := int(number)
	var int_str := str(int_part)
	
	# Ezres elválasztó (szóköz)
	var result := ""
	var count := 0
	for i in range(int_str.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = " " + result
		result = int_str[i] + result
		count += 1
	
	# Tizedes rész
	if decimals > 0:
		var frac := number - int(number)
		var frac_str := str(int(frac * pow(10, decimals)))
		while frac_str.length() < decimals:
			frac_str = "0" + frac_str
		result += "," + frac_str
	
	if is_negative:
		result = "-" + result
	return result


func _format_number_en(number: float, decimals: int) -> String:
	var is_negative := number < 0
	number = absf(number)
	var int_part := int(number)
	var int_str := str(int_part)
	
	# Ezres elválasztó (vessző)
	var result := ""
	var count := 0
	for i in range(int_str.length() - 1, -1, -1):
		if count > 0 and count % 3 == 0:
			result = "," + result
		result = int_str[i] + result
		count += 1
	
	# Tizedes rész
	if decimals > 0:
		var frac := number - int(number)
		var frac_str := str(int(frac * pow(10, decimals)))
		while frac_str.length() < decimals:
			frac_str = "0" + frac_str
		result += "." + frac_str
	
	if is_negative:
		result = "-" + result
	return result


func localize_date(datetime: Dictionary) -> String:
	## Dátum formázás nyelv szerint
	## EN: MM/DD/YYYY  |  HU: YYYY.MM.DD
	var year := str(datetime.get("year", 2026))
	var month := str(datetime.get("month", 1)).pad_zeros(2)
	var day := str(datetime.get("day", 1)).pad_zeros(2)
	
	match current_locale:
		"hu":
			return "%s.%s.%s" % [year, month, day]
		"en":
			return "%s/%s/%s" % [month, day, year]
		_:
			return "%s-%s-%s" % [year, month, day]


func get_mechanic_term(english_term: String) -> String:
	## Mechanika kulcsszó fordítása
	if current_locale == "en":
		return english_term
	return MECHANIC_TERMS.get(english_term, english_term)


# === Nyelv beállítás mentés/betöltés ===
func _save_locale() -> void:
	var config := ConfigFile.new()
	config.set_value("locale", "language", current_locale)
	config.save(LOCALE_SETTINGS_PATH)


func _load_locale() -> void:
	var config := ConfigFile.new()
	if config.load(LOCALE_SETTINGS_PATH) == OK:
		current_locale = config.get_value("locale", "language", "hu")
	else:
		# Próbáljuk meg az OS nyelvet felismerni
		var os_locale := OS.get_locale_language()
		if os_locale == "hu":
			current_locale = "hu"
		else:
			current_locale = "en"

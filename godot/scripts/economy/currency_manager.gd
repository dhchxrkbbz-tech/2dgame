## CurrencyManager - Valuta kezelés (Gold, Dark Essence, Relic Fragment)
## Hozzáadás, elvétel, ellenőrzés minden pénznemhez
class_name CurrencyManager
extends Node

# Aktuális egyenlegek
var _currencies: Dictionary = {
	Enums.CurrencyType.GOLD: 0,
	Enums.CurrencyType.DARK_ESSENCE: 0,
	Enums.CurrencyType.RELIC_FRAGMENT: 0,
}

# Összesített statisztikák (tracking)
var _total_earned: Dictionary = {
	Enums.CurrencyType.GOLD: 0,
	Enums.CurrencyType.DARK_ESSENCE: 0,
	Enums.CurrencyType.RELIC_FRAGMENT: 0,
}

var _total_spent: Dictionary = {
	Enums.CurrencyType.GOLD: 0,
	Enums.CurrencyType.DARK_ESSENCE: 0,
	Enums.CurrencyType.RELIC_FRAGMENT: 0,
}


func _ready() -> void:
	# Gold collected signal kezelése
	EventBus.gold_collected.connect(_on_gold_collected)


## Valuta lekérdezése
func get_currency(type: Enums.CurrencyType) -> int:
	return _currencies.get(type, 0)


func get_gold() -> int:
	return get_currency(Enums.CurrencyType.GOLD)


func get_dark_essence() -> int:
	return get_currency(Enums.CurrencyType.DARK_ESSENCE)


func get_relic_fragments() -> int:
	return get_currency(Enums.CurrencyType.RELIC_FRAGMENT)


## Valuta hozzáadása
func add_currency(type: Enums.CurrencyType, amount: int) -> void:
	if amount <= 0:
		return
	_currencies[type] = _currencies.get(type, 0) + amount
	_total_earned[type] = _total_earned.get(type, 0) + amount
	_emit_currency_signal(type)


func add_gold(amount: int) -> void:
	add_currency(Enums.CurrencyType.GOLD, amount)


func add_dark_essence(amount: int) -> void:
	add_currency(Enums.CurrencyType.DARK_ESSENCE, amount)


func add_relic_fragments(amount: int) -> void:
	add_currency(Enums.CurrencyType.RELIC_FRAGMENT, amount)


## Valuta elvétele - false ha nincs elég
func spend_currency(type: Enums.CurrencyType, amount: int) -> bool:
	if amount <= 0:
		return true
	if _currencies.get(type, 0) < amount:
		return false
	_currencies[type] -= amount
	_total_spent[type] = _total_spent.get(type, 0) + amount
	_emit_currency_signal(type)
	return true


func spend_gold(amount: int) -> bool:
	return spend_currency(Enums.CurrencyType.GOLD, amount)


func spend_dark_essence(amount: int) -> bool:
	return spend_currency(Enums.CurrencyType.DARK_ESSENCE, amount)


func spend_relic_fragments(amount: int) -> bool:
	return spend_currency(Enums.CurrencyType.RELIC_FRAGMENT, amount)


## Van-e elég valuta?
func can_afford(type: Enums.CurrencyType, amount: int) -> bool:
	return _currencies.get(type, 0) >= amount


func can_afford_gold(amount: int) -> bool:
	return can_afford(Enums.CurrencyType.GOLD, amount)


## Több valuta egyidejű ellenőrzése: {"gold": 100, "dark_essence": 20}
func can_afford_multi(costs: Dictionary) -> bool:
	for type in costs:
		if not can_afford(type, costs[type]):
			return false
	return true


## Több valuta egyidejű költése
func spend_multi(costs: Dictionary) -> bool:
	if not can_afford_multi(costs):
		return false
	for type in costs:
		spend_currency(type, costs[type])
	return true


## Egyenleg monitor - sink/source arány
func get_sink_source_ratio(type: Enums.CurrencyType) -> float:
	var earned: int = _total_earned.get(type, 0)
	if earned == 0:
		return 0.0
	return float(_total_spent.get(type, 0)) / float(earned)


## Emit megfelelő signal
func _emit_currency_signal(type: Enums.CurrencyType) -> void:
	var amount := _currencies.get(type, 0)
	EventBus.currency_changed.emit(type, amount)
	match type:
		Enums.CurrencyType.GOLD:
			EventBus.gold_changed.emit(null, amount)
		Enums.CurrencyType.DARK_ESSENCE:
			EventBus.dark_essence_changed.emit(amount)
		Enums.CurrencyType.RELIC_FRAGMENT:
			EventBus.relic_fragments_changed.emit(amount)


## Gold pickup kezelés
func _on_gold_collected(amount: int) -> void:
	add_gold(amount)


## Serialize (mentés)
func serialize() -> Dictionary:
	return {
		"currencies": {
			"gold": _currencies[Enums.CurrencyType.GOLD],
			"dark_essence": _currencies[Enums.CurrencyType.DARK_ESSENCE],
			"relic_fragment": _currencies[Enums.CurrencyType.RELIC_FRAGMENT],
		},
		"total_earned": {
			"gold": _total_earned[Enums.CurrencyType.GOLD],
			"dark_essence": _total_earned[Enums.CurrencyType.DARK_ESSENCE],
			"relic_fragment": _total_earned[Enums.CurrencyType.RELIC_FRAGMENT],
		},
		"total_spent": {
			"gold": _total_spent[Enums.CurrencyType.GOLD],
			"dark_essence": _total_spent[Enums.CurrencyType.DARK_ESSENCE],
			"relic_fragment": _total_spent[Enums.CurrencyType.RELIC_FRAGMENT],
		},
	}


## Deserialize (betöltés)
func deserialize(data: Dictionary) -> void:
	if data.has("currencies"):
		var c: Dictionary = data["currencies"]
		_currencies[Enums.CurrencyType.GOLD] = c.get("gold", 0)
		_currencies[Enums.CurrencyType.DARK_ESSENCE] = c.get("dark_essence", 0)
		_currencies[Enums.CurrencyType.RELIC_FRAGMENT] = c.get("relic_fragment", 0)
	if data.has("total_earned"):
		var e: Dictionary = data["total_earned"]
		_total_earned[Enums.CurrencyType.GOLD] = e.get("gold", 0)
		_total_earned[Enums.CurrencyType.DARK_ESSENCE] = e.get("dark_essence", 0)
		_total_earned[Enums.CurrencyType.RELIC_FRAGMENT] = e.get("relic_fragment", 0)
	if data.has("total_spent"):
		var s: Dictionary = data["total_spent"]
		_total_spent[Enums.CurrencyType.GOLD] = s.get("gold", 0)
		_total_spent[Enums.CurrencyType.DARK_ESSENCE] = s.get("dark_essence", 0)
		_total_spent[Enums.CurrencyType.RELIC_FRAGMENT] = s.get("relic_fragment", 0)
	
	# Frissítjük a UI-t
	for type in _currencies:
		_emit_currency_signal(type)

## LoadingTips - Betöltő képernyő tipp rendszer
## ~30 véletlenszerű tipp a loading screen Hint label-jéhez
## Használat: LoadingTips.get_random_tip() → String
class_name LoadingTips
extends RefCounted

# =============================================================================
#  TIPP POOL
# =============================================================================
## Kategorizált tippek - gameplay, combat, crafting, exploration, stb.
static var _tips: Array[String] = [
	# --- Mozgás & Felfedezés ---
	"Használd a [SHIFT] gombot a sprinteléshez, de figyelj a stamina sávra!",
	"A sötétebb területeken erősebb ellenségek leselkednek – készülj fel!",
	"Fedezd fel a rejtett szobákat a dungeon falai mentén.",
	"A különböző biome-okban eltérő loot és ellenségek várnak.",
	"A ködös területek gyakran értékes titkokat rejtenek.",
	
	# --- Harc ---
	"Dodge-olj a támadások elől a [SPACE] billentyűvel.",
	"Az ellenségek támadás előtt általában jelzést adnak – figyeld a mintákat!",
	"A boss harcban tanuld meg a fázis-átmenetek jeleit.",
	"Kombináld a különböző skill-eket a maximális sebzésért.",
	"Az elit ellenségek erősebbek, de jobb lootot dobnak.",
	
	# --- Felszerelés & Loot ---
	"A ritka tárgyak arany kerettel jelennek meg – ne hagyd ki!",
	"Rendszeresen ellenőrizd a felszerelésed – egy jobb kard sokat számít.",
	"A gem-ek beillesztése extra bónuszokat ad a fegyverednek.",
	"A legendás tárgyak egyedi képességekkel rendelkeznek.",
	"A mimic ládák veszélyesek, de értékes lootot rejtenek!",
	
	# --- Crafting & Gazdaság ---
	"A crafting állomásoknál kombináld a nyersanyagokat új tárgyakért.",
	"Az NPC kereskedőknél eladhatsz felesleges tárgyakat aranyért.",
	"Gyűjts alapanyagokat a világban – minden biome-nak saját erőforrásai vannak.",
	"A magasabb szintű receptek jobb felszerelést adnak.",
	
	# --- Osztályok & Skillek ---
	"Minden karakter osztálynak egyedi skill fája van – kísérletezz!",
	"A passzív skillek folyamatosan működnek – ne feledd fejleszteni őket.",
	"Az aktív skillek cooldown-nal rendelkeznek – tervezd a használatukat!",
	"Skillpontokat szintlépéskor kapsz – használd bölcsen.",
	
	# --- Multiplayer ---
	"Hívd meg barátaidat kooperatív dungeon futásokra!",
	"Csapatban a nehezebb dungeon-ok is könnyebben teljesíthetők.",
	"A party tagok közös lootot kapnak – nem kell versengeni.",
	
	# --- Quest & Story ---
	"Beszélgess az NPC-kkel – hasznos információkat és questeket kaphatsz.",
	"A fő quest vonal vezet végig a történeten – kövesd a jelölőket.",
	"A napi és heti kihívások extra jutalmakat adnak.",
	"A mellékquestek gyakran egyedi tárgyakat és titkokat rejtenek.",
	
	# --- Általános tippek ---
	"Rendszeresen mentsd a játékot – az autosave is segít, de a manuális mentés biztonságosabb.",
	"A beállításoknál testreszabhatod a hangot, grafikát és irányítást.",
]

# Utolsó tipp index (ne ismételje közvetlenül)
static var _last_tip_index: int = -1


# =============================================================================
#  API
# =============================================================================

## Visszaad egy véletlenszerű tippet (nem ismétli az utolsót)
static func get_random_tip() -> String:
	if _tips.is_empty():
		return "Sok sikert az Ashenfall világában!"
	
	var index := randi() % _tips.size()
	
	# Ne ismételjük az utolsó tippet
	if _tips.size() > 1:
		while index == _last_tip_index:
			index = randi() % _tips.size()
	
	_last_tip_index = index
	return _tips[index]


## Visszaad egy kategória-specifikus tippet
static func get_tip_by_category(category: String) -> String:
	var category_ranges := {
		"exploration": [0, 4],
		"combat": [5, 9],
		"loot": [10, 14],
		"crafting": [15, 18],
		"class": [19, 22],
		"multiplayer": [23, 25],
		"quest": [26, 29],
		"general": [30, 31]
	}
	
	if not category in category_ranges:
		return get_random_tip()
	
	var range_data: Array = category_ranges[category]
	var start: int = range_data[0]
	var end: int = mini(range_data[1], _tips.size() - 1)
	
	if start >= _tips.size():
		return get_random_tip()
	
	var index := start + (randi() % (end - start + 1))
	return _tips[index]


## Visszaadja az összes tippet (pl. settings scroll-hoz)
static func get_all_tips() -> Array[String]:
	return _tips


## Új tipp hozzáadása (extensibility)
static func add_tip(tip: String) -> void:
	if not tip in _tips:
		_tips.append(tip)

## TutorialData - Tutorial tartalom definíciók
## Minden tutorial trigger-hez tartozó szöveg, ikon, pozíció, stb.
class_name TutorialData
extends RefCounted

# =============================================================================
#  TUTORIAL TRIGGER ID-K
# =============================================================================
# Ezek a string ID-k használandók a TutorialManager-ben

const FIRST_MOVEMENT := "first_movement"
const FIRST_INTERACTION := "first_interaction"
const FIRST_COMBAT := "first_combat"
const FIRST_DAMAGE_TAKEN := "first_damage_taken"
const FIRST_ENEMY_KILL := "first_enemy_kill"
const FIRST_ITEM_PICKUP := "first_item_pickup"
const FIRST_EQUIPMENT := "first_equipment"
const FIRST_LEVEL_UP := "first_level_up"
const FIRST_SKILL_USE := "first_skill_use"
const FIRST_ULTIMATE := "first_ultimate"
const FIRST_SHOP_VISIT := "first_shop_visit"
const FIRST_CRAFTING := "first_crafting"
const FIRST_DUNGEON_ENTER := "first_dungeon_enter"
const FIRST_BOSS_FIGHT := "first_boss_fight"
const FIRST_GEM_FOUND := "first_gem_found"
const FIRST_RARE_ITEM := "first_rare_item"
const FIRST_ELITE_ENEMY := "first_elite_enemy"
const FIRST_DEATH := "first_death"
const FIRST_MULTIPLAYER := "first_multiplayer"
const FIRST_GATHERING := "first_gathering"
const FIRST_MAP_OPEN := "first_map_open"
const FIRST_QUEST_ACCEPT := "first_quest_accept"
const FIRST_BIOME_TRANSITION := "first_biome_transition"
const FIRST_ENHANCEMENT := "first_enhancement"
const FIRST_GEM_SOCKET := "first_gem_socket"
const FIRST_DODGE := "first_dodge"
const FIRST_INVENTORY_OPEN := "first_inventory_open"
const FIRST_SKILL_TREE_OPEN := "first_skill_tree_open"


# =============================================================================
#  TUTORIAL TARTALMAK
# =============================================================================
# Minden tutorial entry egy Dictionary:
#   title: String - cím (rövid, nagy betű)
#   text: String - leírás (2-3 sor max)
#   key_hint: String - billentyű jelzés (opcionális)
#   icon: String - ikon neve (opcionális, placeholder)
#   duration: float - mennyi ideig látszik (másodperc, 0 = manuális bezárás)
#   position: String - "top", "bottom", "center" (hol jelenik meg)
#   priority: int - magasabb = fontosabb, combat közben a magasabb priority jelenik meg

static var tutorials: Dictionary = {
	FIRST_MOVEMENT: {
		"title": "MOZGÁS",
		"text": "Használd a [WASD] billentyűket a mozgáshoz.\nA karaktered 8 irányba mozoghat.",
		"key_hint": "WASD",
		"icon": "movement",
		"duration": 0.0,  # Eltűnik ha mozog
		"position": "center",
		"priority": 10,
		"auto_dismiss_on": "player_moved",
	},
	FIRST_INTERACTION: {
		"title": "INTERAKCIÓ",
		"text": "Nyomd meg az [E] gombot az NPC-kkel,\nládákkal és tárgyakkal való interakcióhoz.",
		"key_hint": "E",
		"icon": "interact",
		"duration": 8.0,
		"position": "top",
		"priority": 9,
	},
	FIRST_COMBAT: {
		"title": "HARC",
		"text": "Támadás: [Bal egérgomb]\nCélozz az ellenségre és kattints a támadáshoz!",
		"key_hint": "LMB",
		"icon": "combat",
		"duration": 8.0,
		"position": "top",
		"priority": 8,
	},
	FIRST_DAMAGE_TAKEN: {
		"title": "SÉRÜLÉS",
		"text": "Sebzést kaptál! Figyelj az életerő sávodra.\nHasználj [Space] kitérést a támadások elkerüléséhez!",
		"key_hint": "Space",
		"icon": "health",
		"duration": 8.0,
		"position": "top",
		"priority": 7,
	},
	FIRST_DODGE: {
		"title": "KITÉRÉS",
		"text": "Kitérés közben sérthetetlen vagy (iframes).\nHasználd bölcsen – van visszatöltési ideje!",
		"key_hint": "Space",
		"icon": "dodge",
		"duration": 6.0,
		"position": "top",
		"priority": 7,
	},
	FIRST_ENEMY_KILL: {
		"title": "ELSŐ GYŐZELEM!",
		"text": "Legyőzted az első ellenséget!\nTapasztalati pontot (XP) és zsákmányt kapsz érte.",
		"key_hint": "",
		"icon": "xp",
		"duration": 6.0,
		"position": "top",
		"priority": 6,
	},
	FIRST_ITEM_PICKUP: {
		"title": "ZSÁKMÁNY",
		"text": "Sétálj a tárgyra vagy nyomd meg [E] a felvételhez.\nNyisd meg a táskád [I] gombbal a megtekintéshez!",
		"key_hint": "E / I",
		"icon": "loot",
		"duration": 8.0,
		"position": "top",
		"priority": 6,
	},
	FIRST_INVENTORY_OPEN: {
		"title": "FELSZERELÉS",
		"text": "A bal oldalon a tárgyaid, jobb oldalon a felszerelésed.\nHúzd a tárgyakat a megfelelő slot-ba!",
		"key_hint": "I",
		"icon": "inventory",
		"duration": 10.0,
		"position": "bottom",
		"priority": 5,
	},
	FIRST_EQUIPMENT: {
		"title": "FELSZERELVE!",
		"text": "A felszerelt tárgyak növelik a statjaidat.\nFigyelj a tárgy szintjére és ritkaságára!",
		"key_hint": "",
		"icon": "equip",
		"duration": 6.0,
		"position": "top",
		"priority": 5,
	},
	FIRST_LEVEL_UP: {
		"title": "SZINTLÉPÉS!",
		"text": "Gratulálunk! Skill pontot kaptál!\nNyisd meg a Skill Tree-t [K] gombbal.",
		"key_hint": "K",
		"icon": "levelup",
		"duration": 10.0,
		"position": "center",
		"priority": 9,
	},
	FIRST_SKILL_TREE_OPEN: {
		"title": "KÉPESSÉG FA",
		"text": "Válassz képességeket a 3 ág egyikéből.\nKattints egy feloldható képességre a befektetéshez!",
		"key_hint": "",
		"icon": "skilltree",
		"duration": 10.0,
		"position": "bottom",
		"priority": 5,
	},
	FIRST_SKILL_USE: {
		"title": "KÉPESSÉG HASZNÁLAT",
		"text": "Aktív képességek: [1] [2] [3] [4] gombok.\nMindegyiknek van mana költsége és visszatöltési ideje.",
		"key_hint": "1-4",
		"icon": "skill",
		"duration": 8.0,
		"position": "top",
		"priority": 7,
	},
	FIRST_ULTIMATE: {
		"title": "ULTIMATE KÉPESSÉG",
		"text": "Ultimate: [R] gomb – erőteljes, de hosszú cooldown.\nHasználd a megfelelő pillanatban!",
		"key_hint": "R",
		"icon": "ultimate",
		"duration": 8.0,
		"position": "top",
		"priority": 7,
	},
	FIRST_SHOP_VISIT: {
		"title": "KERESKEDŐ",
		"text": "Vásárolhatsz és eladhatsz tárgyakat az NPC-knél.\nA javítás megóvja a felszerelésed elhasználódástól.",
		"key_hint": "",
		"icon": "shop",
		"duration": 8.0,
		"position": "bottom",
		"priority": 4,
	},
	FIRST_CRAFTING: {
		"title": "KÉZMŰVES ÁLLOMÁS",
		"text": "Receptek és alapanyagok kellenek a készítéshez.\nMagasabb szintű profession jobb tárgyakat készíthet.",
		"key_hint": "",
		"icon": "crafting",
		"duration": 10.0,
		"position": "bottom",
		"priority": 4,
	},
	FIRST_DUNGEON_ENTER: {
		"title": "DUNGEON",
		"text": "Beleléptél egy dungeon-ba! Zárt szobákban harcra készülj.\nKeress rejtett szobákat és óvakodj a csapdáktól!",
		"key_hint": "",
		"icon": "dungeon",
		"duration": 10.0,
		"position": "top",
		"priority": 8,
	},
	FIRST_BOSS_FIGHT: {
		"title": "BOSS HARC!",
		"text": "A boss-ok erős ellenségek fázisokkal.\nFigyelj a telegraph jelzésekre – mutatják a támadás területét!",
		"key_hint": "",
		"icon": "boss",
		"duration": 10.0,
		"position": "top",
		"priority": 10,
	},
	FIRST_GEM_FOUND: {
		"title": "GEM TALÁLT!",
		"text": "A gem-ek extra statokat adnak ha socket-be helyezed.\nA stat a gem típusától és a slot-tól függ.",
		"key_hint": "",
		"icon": "gem",
		"duration": 8.0,
		"position": "top",
		"priority": 5,
	},
	FIRST_GEM_SOCKET: {
		"title": "GEM BEHELYEZÉS",
		"text": "Gem socket-be helyezéshez nyisd meg a felszerelés infót.\n3 azonos gem kombinálható 1 magasabb szintűvé!",
		"key_hint": "",
		"icon": "gem",
		"duration": 8.0,
		"position": "top",
		"priority": 5,
	},
	FIRST_RARE_ITEM: {
		"title": "RITKA TÁRGY!",
		"text": "Ez a tárgy extra tulajdonságokkal (affix) rendelkezik!\nRitkaság: Szürke < Zöld < Kék < Lila < Narancs",
		"key_hint": "",
		"icon": "rarity",
		"duration": 8.0,
		"position": "top",
		"priority": 6,
	},
	FIRST_ELITE_ENEMY: {
		"title": "ELIT ELLENSÉG!",
		"text": "Az elit ellenségeknek izzó aurájuk van és különleges\nképességeik. Nehezebb, de jobb zsákmányt adnak!",
		"key_hint": "",
		"icon": "elite",
		"duration": 8.0,
		"position": "top",
		"priority": 7,
	},
	FIRST_DEATH: {
		"title": "MEGHALTÁL",
		"text": "Ne csüggedj! A halálnak enyhe büntetése van.\nA legközelebbi biztonságos pontnál éledsz újra.",
		"key_hint": "",
		"icon": "death",
		"duration": 10.0,
		"position": "center",
		"priority": 10,
	},
	FIRST_MULTIPLAYER: {
		"title": "TÖBBJÁTÉKOS MÓD",
		"text": "Host: te indítod a világot.\nJoin: csatlakozol egy másik játékos világához.\nMax 4 játékos kooperatív kaland!",
		"key_hint": "",
		"icon": "multiplayer",
		"duration": 10.0,
		"position": "center",
		"priority": 5,
	},
	FIRST_GATHERING: {
		"title": "NYERSANYAG GYŰJTÉS",
		"text": "A világban található fa, kő és növény node-ok\nszedhetők. A professzió szinted javul a gyakorlással!",
		"key_hint": "E",
		"icon": "gathering",
		"duration": 8.0,
		"position": "top",
		"priority": 4,
	},
	FIRST_MAP_OPEN: {
		"title": "TÉRKÉP",
		"text": "A térkép mutatja a felfedezett területeket és a POI-kat.\nA piros pont a te pozíciód!",
		"key_hint": "M",
		"icon": "map",
		"duration": 8.0,
		"position": "bottom",
		"priority": 4,
	},
	FIRST_QUEST_ACCEPT: {
		"title": "KÜLDETÉS ELFOGADVA",
		"text": "A küldetések nyomon követhetők a Quest Log-ban.\nKövesd a célokat a jutalom megszerzéséhez!",
		"key_hint": "",
		"icon": "quest",
		"duration": 8.0,
		"position": "top",
		"priority": 5,
	},
	FIRST_BIOME_TRANSITION: {
		"title": "ÚJ TERÜLET",
		"text": "Új biome-ba léptél! A nehézség területenként változik.\nFigyelj az ellenségek szintjére!",
		"key_hint": "",
		"icon": "biome",
		"duration": 6.0,
		"position": "top",
		"priority": 5,
	},
	FIRST_ENHANCEMENT: {
		"title": "TÁRGY FEJLESZTÉS",
		"text": "A kovácsnál fejlesztheted a felszerelésed +1-től +10-ig.\nVigyázz: magasabb szinten sikertelen lehet a fejlesztés!",
		"key_hint": "",
		"icon": "enhance",
		"duration": 8.0,
		"position": "bottom",
		"priority": 4,
	},
}


# =============================================================================
#  KONTEXTUS-ÉRZÉKENY TIPPEK (nem first-time, hanem szituáció-alapú)
# =============================================================================
# Ezek ismétlődhetnek, de ritkán (cooldown-nal)

const CONTEXT_LOW_HP := "context_low_hp"
const CONTEXT_FULL_INVENTORY := "context_full_inventory"
const CONTEXT_HIGH_LEVEL_AREA := "context_high_level_area"
const CONTEXT_UNUSED_SKILL_POINTS := "context_unused_skill_points"
const CONTEXT_UNEQUIPPED_ITEMS := "context_unequipped_items"

static var contextual_tips: Dictionary = {
	CONTEXT_LOW_HP: {
		"title": "ALACSONY ÉLETERŐ",
		"text": "Az életerőd alacsony! Használj gyógyítót\nvagy húzódj vissza biztonságos területre.",
		"icon": "health",
		"duration": 5.0,
		"position": "top",
		"priority": 3,
		"cooldown": 120.0,  # 2 percenként max
	},
	CONTEXT_FULL_INVENTORY: {
		"title": "TELE TÁSKA",
		"text": "A táskád megtelt! Adj el vagy dobj el tárgyakat,\nhogy helyet csinálj az újaknak.",
		"icon": "inventory",
		"duration": 5.0,
		"position": "top",
		"priority": 3,
		"cooldown": 60.0,
	},
	CONTEXT_HIGH_LEVEL_AREA: {
		"title": "VESZÉLYES TERÜLET",
		"text": "Az ellenségek szintje jóval magasabb nálad!\nFontold meg a visszavonulást.",
		"icon": "danger",
		"duration": 5.0,
		"position": "top",
		"priority": 4,
		"cooldown": 180.0,
	},
	CONTEXT_UNUSED_SKILL_POINTS: {
		"title": "ELÉRHETÖ SKILL PONT",
		"text": "Van elköltetlen skill pontod!\nNyisd meg a Skill Tree-t [K] gombbal.",
		"key_hint": "K",
		"icon": "skilltree",
		"duration": 6.0,
		"position": "top",
		"priority": 2,
		"cooldown": 300.0,
	},
	CONTEXT_UNEQUIPPED_ITEMS: {
		"title": "JOBB FELSZERELÉS",
		"text": "Jobb tárgyaid vannak a táskádban!\nNyisd meg az Inventory-t [I] a felszereléséhez.",
		"key_hint": "I",
		"icon": "equip",
		"duration": 6.0,
		"position": "top",
		"priority": 2,
		"cooldown": 300.0,
	},
}


# =============================================================================
#  HELPER
# =============================================================================

## Visszaadja a tutorial tartalmat az ID alapján
static func get_tutorial(trigger_id: String) -> Dictionary:
	if trigger_id in tutorials:
		return tutorials[trigger_id]
	if trigger_id in contextual_tips:
		return contextual_tips[trigger_id]
	return {}


## Összes first-time trigger ID lista
static func get_all_trigger_ids() -> Array[String]:
	var ids: Array[String] = []
	for key in tutorials:
		ids.append(key)
	return ids

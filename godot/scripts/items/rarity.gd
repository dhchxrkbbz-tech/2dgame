## Rarity - Rarity rendszer és szín/név definíciók
class_name Rarity
extends RefCounted

# === Rarity nevek ===
const RARITY_NAMES: Dictionary = {
	Enums.Rarity.COMMON: "Common",
	Enums.Rarity.UNCOMMON: "Uncommon",
	Enums.Rarity.RARE: "Rare",
	Enums.Rarity.EPIC: "Epic",
	Enums.Rarity.LEGENDARY: "Legendary",
}

# === Rarity sell price szorzók ===
const SELL_MULTIPLIER: Dictionary = {
	Enums.Rarity.COMMON: 1.0,
	Enums.Rarity.UNCOMMON: 2.0,
	Enums.Rarity.RARE: 5.0,
	Enums.Rarity.EPIC: 15.0,
	Enums.Rarity.LEGENDARY: 50.0,
}

# === Rarity disassemble anyag mennyiség ===
const DISASSEMBLE_MATERIALS: Dictionary = {
	Enums.Rarity.COMMON: 1,
	Enums.Rarity.UNCOMMON: 2,
	Enums.Rarity.RARE: 5,
	Enums.Rarity.EPIC: 10,
	Enums.Rarity.LEGENDARY: 25,
}


static func get_name(rarity: Enums.Rarity) -> String:
	return RARITY_NAMES.get(rarity, "Unknown")


static func get_color(rarity: Enums.Rarity) -> Color:
	return Constants.RARITY_COLORS.get(rarity, Color.WHITE)


static func get_sell_multiplier(rarity: Enums.Rarity) -> float:
	return SELL_MULTIPLIER.get(rarity, 1.0)


static func get_disassemble_amount(rarity: Enums.Rarity) -> int:
	return DISASSEMBLE_MATERIALS.get(rarity, 1)


## Item base price kiszámítása rarity és level alapján
static func calculate_base_price(rarity: Enums.Rarity, item_level: int) -> int:
	var base: int = 5 + item_level * 3
	return int(base * get_sell_multiplier(rarity))


## Rarity összehasonlítás (magasabb = jobb)
static func is_higher(a: Enums.Rarity, b: Enums.Rarity) -> bool:
	return int(a) > int(b)

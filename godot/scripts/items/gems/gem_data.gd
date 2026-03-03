## GemData - Resource: gem alap adatok
## Egy gem típusának leírása (nem konkrét példány)
class_name GemData
extends Resource

## Gem elnevezések típusonként
const GEM_TYPE_NAMES: Dictionary = {
	Enums.GemType.RUBY: "Ruby",
	Enums.GemType.EMERALD: "Emerald",
	Enums.GemType.SAPPHIRE: "Sapphire",
	Enums.GemType.AMETHYST: "Amethyst",
	Enums.GemType.TOPAZ: "Topaz",
	Enums.GemType.DIAMOND: "Diamond",
	Enums.GemType.LEGENDARY: "Legendary",
}

## Gem tier elnevezések
const GEM_TIER_NAMES: Dictionary = {
	Enums.GemTier.CHIPPED: "Chipped",
	Enums.GemTier.FLAWED: "Flawed",
	Enums.GemTier.NORMAL: "Normal",
	Enums.GemTier.FLAWLESS: "Flawless",
	Enums.GemTier.PERFECT: "Perfect",
	Enums.GemTier.RADIANT: "Radiant",
}

## Gem típus színek (UI megjelenítéshez)
const GEM_TYPE_COLORS: Dictionary = {
	Enums.GemType.RUBY: Color(0.9, 0.15, 0.15),       # Piros
	Enums.GemType.EMERALD: Color(0.1, 0.8, 0.2),      # Zöld
	Enums.GemType.SAPPHIRE: Color(0.15, 0.3, 0.9),    # Kék
	Enums.GemType.AMETHYST: Color(0.6, 0.1, 0.85),    # Lila
	Enums.GemType.TOPAZ: Color(0.95, 0.8, 0.1),       # Sárga
	Enums.GemType.DIAMOND: Color(0.9, 0.95, 1.0),     # Fehér/átlátszó
	Enums.GemType.LEGENDARY: Color(1.0, 0.6, 0.0),    # Narancs izzó
}

@export var gem_id: String = ""
@export var gem_type: Enums.GemType = Enums.GemType.RUBY
@export var gem_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null

## Ember-readable teljes név generálás
static func get_full_name(gem_type: Enums.GemType, gem_tier: Enums.GemTier) -> String:
	var tier_name: String = GEM_TIER_NAMES.get(gem_tier, "Unknown")
	var type_name: String = GEM_TYPE_NAMES.get(gem_type, "Unknown")
	return "%s %s" % [tier_name, type_name]


## Gem típus szín lekérdezés
static func get_gem_color(gem_type: Enums.GemType) -> Color:
	return GEM_TYPE_COLORS.get(gem_type, Color.WHITE)


## NPC eladási ár kiszámítása (tier × 50 gold)
static func get_sell_price(gem_tier: Enums.GemTier) -> int:
	return (gem_tier + 1) * 50

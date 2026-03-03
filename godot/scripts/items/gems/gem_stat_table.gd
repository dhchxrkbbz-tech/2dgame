## GemStatTable - Gem stat értékek tier + slot kombinációnként
## A 09_gem_system_plan.txt 7. fejezet táblázatai alapján
class_name GemStatTable
extends RefCounted

## Slot kategóriák gem stat lookuphoz
enum SlotCategory {
	WEAPON,
	ARMOR,
	ACCESSORY,
}

## Stat tábla struktúra:
## { GemType: { SlotCategory: { GemTier: {"stat": String, "value": float, "is_percent": bool} } } }
static var _stat_table: Dictionary = {}
static var _initialized: bool = false


## Inicializálás (lazy, első híváskor)
static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	_build_stat_table()


## Stat lookup: adott gem típus + tier + slot kategóriához
static func get_stat(gem_type: Enums.GemType, gem_tier: Enums.GemTier, slot_cat: SlotCategory) -> Dictionary:
	_ensure_initialized()
	var type_data: Dictionary = _stat_table.get(gem_type, {})
	var slot_data: Dictionary = type_data.get(slot_cat, {})
	return slot_data.get(gem_tier, {"stat": "", "value": 0.0, "is_percent": false})


## Item equip slot → SlotCategory konverzió
static func get_slot_category(equip_slot: int) -> SlotCategory:
	match equip_slot:
		Enums.EquipSlot.MAIN_HAND, Enums.EquipSlot.OFF_HAND:
			return SlotCategory.WEAPON
		Enums.EquipSlot.HELMET, Enums.EquipSlot.CHEST, Enums.EquipSlot.GLOVES, \
		Enums.EquipSlot.BOOTS, Enums.EquipSlot.SHOULDERS:
			return SlotCategory.ARMOR
		Enums.EquipSlot.BELT, Enums.EquipSlot.AMULET, Enums.EquipSlot.RING_1, \
		Enums.EquipSlot.RING_2, Enums.EquipSlot.CAPE:
			return SlotCategory.ACCESSORY
		_:
			return SlotCategory.ARMOR


## Accessory slot ellenőrzés (legendary gem-ek ide mehetnek)
static func is_accessory_slot(equip_slot: int) -> bool:
	return get_slot_category(equip_slot) == SlotCategory.ACCESSORY


## Teljes stat tábla felépítése a terv alapján
static func _build_stat_table() -> void:
	# ── RUBY (Physical Damage) ──
	_stat_table[Enums.GemType.RUBY] = {
		SlotCategory.WEAPON: {
			Enums.GemTier.CHIPPED:  {"stat": "physical_damage", "value": 3.0, "is_percent": false},
			Enums.GemTier.FLAWED:   {"stat": "physical_damage", "value": 6.0, "is_percent": false},
			Enums.GemTier.NORMAL:   {"stat": "physical_damage", "value": 10.0, "is_percent": false},
			Enums.GemTier.FLAWLESS: {"stat": "physical_damage", "value": 16.0, "is_percent": false},
			Enums.GemTier.PERFECT:  {"stat": "physical_damage", "value": 24.0, "is_percent": false},
			Enums.GemTier.RADIANT:  {"stat": "physical_damage", "value": 35.0, "is_percent": false},
		},
		SlotCategory.ARMOR: {
			Enums.GemTier.CHIPPED:  {"stat": "max_hp", "value": 5.0, "is_percent": false},
			Enums.GemTier.FLAWED:   {"stat": "max_hp", "value": 10.0, "is_percent": false},
			Enums.GemTier.NORMAL:   {"stat": "max_hp", "value": 20.0, "is_percent": false},
			Enums.GemTier.FLAWLESS: {"stat": "max_hp", "value": 35.0, "is_percent": false},
			Enums.GemTier.PERFECT:  {"stat": "max_hp", "value": 55.0, "is_percent": false},
			Enums.GemTier.RADIANT:  {"stat": "max_hp", "value": 80.0, "is_percent": false},
		},
		SlotCategory.ACCESSORY: {
			Enums.GemTier.CHIPPED:  {"stat": "damage_percent", "value": 1.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "damage_percent", "value": 2.0, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "damage_percent", "value": 3.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "damage_percent", "value": 5.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "damage_percent", "value": 7.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "damage_percent", "value": 10.0, "is_percent": true},
		},
	}

	# ── EMERALD (Critical) ──
	_stat_table[Enums.GemType.EMERALD] = {
		SlotCategory.WEAPON: {
			Enums.GemTier.CHIPPED:  {"stat": "crit_chance", "value": 1.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "crit_chance", "value": 1.5, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "crit_chance", "value": 2.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "crit_chance", "value": 3.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "crit_chance", "value": 4.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "crit_chance", "value": 5.0, "is_percent": true},
		},
		SlotCategory.ARMOR: {
			Enums.GemTier.CHIPPED:  {"stat": "armor", "value": 2.0, "is_percent": false},
			Enums.GemTier.FLAWED:   {"stat": "armor", "value": 4.0, "is_percent": false},
			Enums.GemTier.NORMAL:   {"stat": "armor", "value": 7.0, "is_percent": false},
			Enums.GemTier.FLAWLESS: {"stat": "armor", "value": 11.0, "is_percent": false},
			Enums.GemTier.PERFECT:  {"stat": "armor", "value": 16.0, "is_percent": false},
			Enums.GemTier.RADIANT:  {"stat": "armor", "value": 22.0, "is_percent": false},
		},
		SlotCategory.ACCESSORY: {
			Enums.GemTier.CHIPPED:  {"stat": "crit_damage", "value": 5.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "crit_damage", "value": 8.0, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "crit_damage", "value": 12.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "crit_damage", "value": 18.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "crit_damage", "value": 25.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "crit_damage", "value": 35.0, "is_percent": true},
		},
	}

	# ── SAPPHIRE (Defense) ──
	_stat_table[Enums.GemType.SAPPHIRE] = {
		SlotCategory.WEAPON: {
			Enums.GemTier.CHIPPED:  {"stat": "slow_on_hit", "value": 2.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "slow_on_hit", "value": 3.0, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "slow_on_hit", "value": 5.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "slow_on_hit", "value": 7.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "slow_on_hit", "value": 10.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "slow_on_hit", "value": 14.0, "is_percent": true},
		},
		SlotCategory.ARMOR: {
			Enums.GemTier.CHIPPED:  {"stat": "armor", "value": 3.0, "is_percent": false},
			Enums.GemTier.FLAWED:   {"stat": "armor", "value": 6.0, "is_percent": false},
			Enums.GemTier.NORMAL:   {"stat": "armor", "value": 10.0, "is_percent": false},
			Enums.GemTier.FLAWLESS: {"stat": "armor", "value": 16.0, "is_percent": false},
			Enums.GemTier.PERFECT:  {"stat": "armor", "value": 24.0, "is_percent": false},
			Enums.GemTier.RADIANT:  {"stat": "armor", "value": 34.0, "is_percent": false},
		},
		SlotCategory.ACCESSORY: {
			Enums.GemTier.CHIPPED:  {"stat": "max_hp", "value": 5.0, "is_percent": false},
			Enums.GemTier.FLAWED:   {"stat": "max_hp", "value": 12.0, "is_percent": false},
			Enums.GemTier.NORMAL:   {"stat": "max_hp", "value": 20.0, "is_percent": false},
			Enums.GemTier.FLAWLESS: {"stat": "max_hp", "value": 35.0, "is_percent": false},
			Enums.GemTier.PERFECT:  {"stat": "max_hp", "value": 55.0, "is_percent": false},
			Enums.GemTier.RADIANT:  {"stat": "max_hp", "value": 80.0, "is_percent": false},
		},
	}

	# ── AMETHYST (Lifesteal) ──
	_stat_table[Enums.GemType.AMETHYST] = {
		SlotCategory.WEAPON: {
			Enums.GemTier.CHIPPED:  {"stat": "lifesteal", "value": 1.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "lifesteal", "value": 1.5, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "lifesteal", "value": 2.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "lifesteal", "value": 3.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "lifesteal", "value": 4.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "lifesteal", "value": 6.0, "is_percent": true},
		},
		SlotCategory.ARMOR: {
			Enums.GemTier.CHIPPED:  {"stat": "hp_regen", "value": 1.0, "is_percent": false},
			Enums.GemTier.FLAWED:   {"stat": "hp_regen", "value": 2.0, "is_percent": false},
			Enums.GemTier.NORMAL:   {"stat": "hp_regen", "value": 3.0, "is_percent": false},
			Enums.GemTier.FLAWLESS: {"stat": "hp_regen", "value": 5.0, "is_percent": false},
			Enums.GemTier.PERFECT:  {"stat": "hp_regen", "value": 8.0, "is_percent": false},
			Enums.GemTier.RADIANT:  {"stat": "hp_regen", "value": 12.0, "is_percent": false},
		},
		SlotCategory.ACCESSORY: {
			Enums.GemTier.CHIPPED:  {"stat": "heal_effectiveness", "value": 2.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "heal_effectiveness", "value": 4.0, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "heal_effectiveness", "value": 6.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "heal_effectiveness", "value": 9.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "heal_effectiveness", "value": 12.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "heal_effectiveness", "value": 16.0, "is_percent": true},
		},
	}

	# ── TOPAZ (Elemental) ──
	_stat_table[Enums.GemType.TOPAZ] = {
		SlotCategory.WEAPON: {
			Enums.GemTier.CHIPPED:  {"stat": "elemental_damage", "value": 3.0, "is_percent": false},
			Enums.GemTier.FLAWED:   {"stat": "elemental_damage", "value": 6.0, "is_percent": false},
			Enums.GemTier.NORMAL:   {"stat": "elemental_damage", "value": 10.0, "is_percent": false},
			Enums.GemTier.FLAWLESS: {"stat": "elemental_damage", "value": 16.0, "is_percent": false},
			Enums.GemTier.PERFECT:  {"stat": "elemental_damage", "value": 24.0, "is_percent": false},
			Enums.GemTier.RADIANT:  {"stat": "elemental_damage", "value": 35.0, "is_percent": false},
		},
		SlotCategory.ARMOR: {
			Enums.GemTier.CHIPPED:  {"stat": "elemental_resist", "value": 3.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "elemental_resist", "value": 5.0, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "elemental_resist", "value": 8.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "elemental_resist", "value": 12.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "elemental_resist", "value": 16.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "elemental_resist", "value": 22.0, "is_percent": true},
		},
		SlotCategory.ACCESSORY: {
			Enums.GemTier.CHIPPED:  {"stat": "gold_find", "value": 5.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "gold_find", "value": 8.0, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "gold_find", "value": 12.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "gold_find", "value": 18.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "gold_find", "value": 25.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "gold_find", "value": 35.0, "is_percent": true},
		},
	}

	# ── DIAMOND (Damage Reduction) ──
	_stat_table[Enums.GemType.DIAMOND] = {
		SlotCategory.WEAPON: {
			Enums.GemTier.CHIPPED:  {"stat": "all_damage", "value": 1.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "all_damage", "value": 2.0, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "all_damage", "value": 3.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "all_damage", "value": 4.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "all_damage", "value": 6.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "all_damage", "value": 8.0, "is_percent": true},
		},
		SlotCategory.ARMOR: {
			Enums.GemTier.CHIPPED:  {"stat": "damage_reduction", "value": 1.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "damage_reduction", "value": 2.0, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "damage_reduction", "value": 3.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "damage_reduction", "value": 4.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "damage_reduction", "value": 6.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "damage_reduction", "value": 8.0, "is_percent": true},
		},
		SlotCategory.ACCESSORY: {
			Enums.GemTier.CHIPPED:  {"stat": "magic_find", "value": 3.0, "is_percent": true},
			Enums.GemTier.FLAWED:   {"stat": "magic_find", "value": 5.0, "is_percent": true},
			Enums.GemTier.NORMAL:   {"stat": "magic_find", "value": 8.0, "is_percent": true},
			Enums.GemTier.FLAWLESS: {"stat": "magic_find", "value": 12.0, "is_percent": true},
			Enums.GemTier.PERFECT:  {"stat": "magic_find", "value": 17.0, "is_percent": true},
			Enums.GemTier.RADIANT:  {"stat": "magic_find", "value": 24.0, "is_percent": true},
		},
	}


## Stat szöveges leírás tooltip-hoz
static func get_stat_description(gem_type: Enums.GemType, gem_tier: Enums.GemTier, slot_cat: SlotCategory) -> String:
	var stat_info := get_stat(gem_type, gem_tier, slot_cat)
	if stat_info.stat.is_empty():
		return ""
	var stat_name: String = stat_info.stat.replace("_", " ").capitalize()
	if stat_info.is_percent:
		return "+%.1f%% %s" % [stat_info.value, stat_name]
	else:
		return "+%d %s" % [int(stat_info.value), stat_name]


## Összes slot kategória stat leírása (tooltip-hoz)
static func get_all_slot_descriptions(gem_type: Enums.GemType, gem_tier: Enums.GemTier) -> Dictionary:
	return {
		"weapon": get_stat_description(gem_type, gem_tier, SlotCategory.WEAPON),
		"armor": get_stat_description(gem_type, gem_tier, SlotCategory.ARMOR),
		"accessory": get_stat_description(gem_type, gem_tier, SlotCategory.ACCESSORY),
	}

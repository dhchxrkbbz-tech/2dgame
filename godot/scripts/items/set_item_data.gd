## SetItemData - Set item definíciók és set bónuszok
## A plan 12. fejezetében leírt összes set implementálása
class_name SetItemData
extends RefCounted

static var _sets: Dictionary = {}
static var _initialized: bool = false


static func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	_register_assassin_sets()
	_register_tank_sets()
	_register_mage_sets()


static func get_set(set_id: String) -> Dictionary:
	initialize()
	return _sets.get(set_id, {})


static func get_all_set_ids() -> Array[String]:
	initialize()
	var ids: Array[String] = []
	for key in _sets:
		ids.append(key)
	return ids


## Aktív set bónuszok kiszámítása az equipped set darabok alapján
static func get_active_bonuses(equipped_set_pieces: Dictionary) -> Array[Dictionary]:
	initialize()
	var bonuses: Array[Dictionary] = []
	
	# equipped_set_pieces: { set_id: count }
	for set_id in equipped_set_pieces:
		var count: int = equipped_set_pieces[set_id]
		var set_def: Dictionary = _sets.get(set_id, {})
		if set_def.is_empty():
			continue
		
		var set_bonuses: Array = set_def.get("bonuses", [])
		for bonus in set_bonuses:
			if count >= bonus.get("required_pieces", 99):
				bonuses.append({
					"set_id": set_id,
					"set_name": set_def.get("name", ""),
					"required": bonus.get("required_pieces", 0),
					"description": bonus.get("description", ""),
					"stats": bonus.get("stats", {}),
					"special": bonus.get("special", ""),
				})
	
	return bonuses


## Set tooltip szöveg generálás
static func get_set_tooltip(set_id: String, equipped_count: int) -> String:
	initialize()
	var set_def: Dictionary = _sets.get(set_id, {})
	if set_def.is_empty():
		return ""
	
	var text := "[color=green]%s[/color]\n" % set_def.get("name", "")
	var pieces: Dictionary = set_def.get("pieces", {})
	text += "(%d/%d)\n" % [equipped_count, pieces.size()]
	
	var bonuses: Array = set_def.get("bonuses", [])
	for bonus in bonuses:
		var req: int = bonus.get("required_pieces", 0)
		var active := equipped_count >= req
		var color := "green" if active else "gray"
		text += "\n[color=%s](%d) %s[/color]" % [color, req, bonus.get("description", "")]
	
	return text


# =================== REGISTRATION ===================

static func _reg(set_id: String, data: Dictionary) -> void:
	_sets[set_id] = data


# === ASSASSIN SET-EK ===

static func _register_assassin_sets() -> void:
	# Shadow's Embrace (Shadow Branch)
	_reg("shadows_embrace", {
		"name": "Shadow's Embrace",
		"class": Enums.PlayerClass.ASSASSIN,
		"pieces": {
			"helmet": {"name": "Shadow Hood", "slot": Enums.EquipSlot.HELMET},
			"chest": {"name": "Shadow Garb", "slot": Enums.EquipSlot.CHEST},
			"gloves": {"name": "Shadow Grips", "slot": Enums.EquipSlot.GLOVES},
			"boots": {"name": "Shadow Treads", "slot": Enums.EquipSlot.BOOTS},
			"weapon": {"name": "Shadow Fang", "slot": Enums.EquipSlot.MAIN_HAND},
		},
		"bonuses": [
			{
				"required_pieces": 2,
				"description": "+15% Stealth Duration",
				"stats": {"stealth_duration": 15.0},
				"special": "",
			},
			{
				"required_pieces": 4,
				"description": "Shadow Step no cooldown for 3s after killing an enemy",
				"stats": {},
				"special": "shadow_step_reset_on_kill",
			},
			{
				"required_pieces": 5,
				"description": "+30% Damage from Stealth",
				"stats": {"stealth_damage": 30.0},
				"special": "",
			},
		],
	})
	
	# Venomweave (Poison Branch)
	_reg("venomweave", {
		"name": "Venomweave",
		"class": Enums.PlayerClass.ASSASSIN,
		"pieces": {
			"helmet": {"name": "Venomweave Mask", "slot": Enums.EquipSlot.HELMET},
			"chest": {"name": "Venomweave Tunic", "slot": Enums.EquipSlot.CHEST},
			"gloves": {"name": "Venomweave Wraps", "slot": Enums.EquipSlot.GLOVES},
			"belt": {"name": "Venomweave Sash", "slot": Enums.EquipSlot.BELT},
			"weapon": {"name": "Venomweave Stiletto", "slot": Enums.EquipSlot.MAIN_HAND},
		},
		"bonuses": [
			{
				"required_pieces": 2,
				"description": "+20% Poison Damage",
				"stats": {"poison_damage": 20.0},
				"special": "",
			},
			{
				"required_pieces": 4,
				"description": "Poison spreads to nearby enemies (3 tiles)",
				"stats": {},
				"special": "poison_spread",
			},
			{
				"required_pieces": 5,
				"description": "Poison ticks deal 2% of enemy max HP",
				"stats": {},
				"special": "poison_percent_hp",
			},
		],
	})
	
	# Bloodbound (Blood Branch)
	_reg("bloodbound", {
		"name": "Bloodbound",
		"class": Enums.PlayerClass.ASSASSIN,
		"pieces": {
			"chest": {"name": "Bloodbound Vest", "slot": Enums.EquipSlot.CHEST},
			"gloves": {"name": "Bloodbound Claws", "slot": Enums.EquipSlot.GLOVES},
			"boots": {"name": "Bloodbound Boots", "slot": Enums.EquipSlot.BOOTS},
			"ring": {"name": "Bloodbound Ring", "slot": Enums.EquipSlot.RING_1},
			"weapon": {"name": "Bloodbound Blade", "slot": Enums.EquipSlot.MAIN_HAND},
		},
		"bonuses": [
			{
				"required_pieces": 2,
				"description": "+10% Lifesteal",
				"stats": {"lifesteal": 10.0},
				"special": "",
			},
			{
				"required_pieces": 4,
				"description": "Below 30% HP → +50% Damage",
				"stats": {},
				"special": "low_hp_damage_boost",
			},
			{
				"required_pieces": 5,
				"description": "Killing an enemy while below 30% HP → full heal",
				"stats": {},
				"special": "low_hp_kill_heal",
			},
		],
	})


# === TANK SET-EK ===

static func _register_tank_sets() -> void:
	# Bulwark's Pride (Guardian Branch)
	_reg("bulwarks_pride", {
		"name": "Bulwark's Pride",
		"class": Enums.PlayerClass.TANK,
		"pieces": {
			"helmet": {"name": "Bulwark Helm", "slot": Enums.EquipSlot.HELMET},
			"chest": {"name": "Bulwark Plate", "slot": Enums.EquipSlot.CHEST},
			"gloves": {"name": "Bulwark Gauntlets", "slot": Enums.EquipSlot.GLOVES},
			"boots": {"name": "Bulwark Greaves", "slot": Enums.EquipSlot.BOOTS},
			"offhand": {"name": "Bulwark Shield", "slot": Enums.EquipSlot.OFF_HAND},
		},
		"bonuses": [
			{
				"required_pieces": 2,
				"description": "+20% Block Chance",
				"stats": {"block_chance": 20.0},
				"special": "",
			},
			{
				"required_pieces": 4,
				"description": "Blocking an attack reflects 30% damage",
				"stats": {},
				"special": "block_reflect",
			},
			{
				"required_pieces": 5,
				"description": "+50% Max HP, take 10% less damage",
				"stats": {"max_hp": 50.0, "damage_reduction": 10.0},
				"special": "",
			},
		],
	})
	
	# Warlord's Fury (Warbringer Branch)
	_reg("warlords_fury", {
		"name": "Warlord's Fury",
		"class": Enums.PlayerClass.TANK,
		"pieces": {
			"helmet": {"name": "Warlord's Crown", "slot": Enums.EquipSlot.HELMET},
			"chest": {"name": "Warlord's Plate", "slot": Enums.EquipSlot.CHEST},
			"belt": {"name": "Warlord's Girdle", "slot": Enums.EquipSlot.BELT},
			"boots": {"name": "Warlord's Boots", "slot": Enums.EquipSlot.BOOTS},
			"weapon": {"name": "Warlord's Cleaver", "slot": Enums.EquipSlot.MAIN_HAND},
		},
		"bonuses": [
			{
				"required_pieces": 2,
				"description": "+15% AoE Damage",
				"stats": {"aoe_damage": 15.0},
				"special": "",
			},
			{
				"required_pieces": 4,
				"description": "War Cry also taunts and stuns for 1s",
				"stats": {},
				"special": "war_cry_stun",
			},
			{
				"required_pieces": 5,
				"description": "Ground Slam creates fire trail (DOT)",
				"stats": {},
				"special": "ground_slam_fire",
			},
		],
	})
	
	# Divine Light (Paladin Branch)
	_reg("divine_light", {
		"name": "Divine Light",
		"class": Enums.PlayerClass.TANK,
		"pieces": {
			"helmet": {"name": "Crown of Light", "slot": Enums.EquipSlot.HELMET},
			"chest": {"name": "Radiant Plate", "slot": Enums.EquipSlot.CHEST},
			"gloves": {"name": "Blessed Gauntlets", "slot": Enums.EquipSlot.GLOVES},
			"amulet": {"name": "Holy Pendant", "slot": Enums.EquipSlot.AMULET},
			"offhand": {"name": "Divine Aegis", "slot": Enums.EquipSlot.OFF_HAND},
		},
		"bonuses": [
			{
				"required_pieces": 2,
				"description": "+15% Heal Effectiveness",
				"stats": {"heal_effectiveness": 15.0},
				"special": "",
			},
			{
				"required_pieces": 4,
				"description": "Blessing Aura range doubled",
				"stats": {},
				"special": "aura_range_double",
			},
			{
				"required_pieces": 5,
				"description": "Divine Protection also heals for 20% max HP",
				"stats": {},
				"special": "divine_protection_heal",
			},
		],
	})


# === MAGE/HEALER SET-EK ===

static func _register_mage_sets() -> void:
	# Arcane Dominion (Arcane Branch)
	_reg("arcane_dominion", {
		"name": "Arcane Dominion",
		"class": Enums.PlayerClass.MAGE,
		"pieces": {
			"helmet": {"name": "Arcane Diadem", "slot": Enums.EquipSlot.HELMET},
			"chest": {"name": "Arcane Vestments", "slot": Enums.EquipSlot.CHEST},
			"ring": {"name": "Arcane Band", "slot": Enums.EquipSlot.RING_1},
			"boots": {"name": "Arcane Slippers", "slot": Enums.EquipSlot.BOOTS},
			"weapon": {"name": "Arcane Scepter", "slot": Enums.EquipSlot.MAIN_HAND},
		},
		"bonuses": [
			{
				"required_pieces": 2,
				"description": "+15% Spell Damage",
				"stats": {"spell_damage": 15.0},
				"special": "",
			},
			{
				"required_pieces": 4,
				"description": "Teleport leaves behind Arcane explosion",
				"stats": {},
				"special": "teleport_explosion",
			},
			{
				"required_pieces": 5,
				"description": "Arcane Collapse cooldown -50%",
				"stats": {"arcane_collapse_cdr": 50.0},
				"special": "",
			},
		],
	})
	
	# Frozen Heart (Frost Branch)
	_reg("frozen_heart", {
		"name": "Frozen Heart",
		"class": Enums.PlayerClass.MAGE,
		"pieces": {
			"helmet": {"name": "Frozen Crown", "slot": Enums.EquipSlot.HELMET},
			"chest": {"name": "Frozen Robes", "slot": Enums.EquipSlot.CHEST},
			"gloves": {"name": "Frozen Grasp", "slot": Enums.EquipSlot.GLOVES},
			"belt": {"name": "Frozen Chain", "slot": Enums.EquipSlot.BELT},
			"weapon": {"name": "Frozen Shard Staff", "slot": Enums.EquipSlot.MAIN_HAND},
		},
		"bonuses": [
			{
				"required_pieces": 2,
				"description": "+20% Frost Damage",
				"stats": {"ice_damage": 20.0},
				"special": "",
			},
			{
				"required_pieces": 4,
				"description": "Enemies frozen by Frost Nova take +30% damage",
				"stats": {},
				"special": "frozen_vulnerability",
			},
			{
				"required_pieces": 5,
				"description": "Blizzard now follows the player",
				"stats": {},
				"special": "blizzard_follow",
			},
		],
	})

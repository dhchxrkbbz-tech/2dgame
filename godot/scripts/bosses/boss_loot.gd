## BossLoot - Boss loot generálás és drop
class_name BossLoot
extends RefCounted

## Loot table formátum:
## {
##   "guaranteed": [{"type": "gold", "amount_min": 100, "amount_max": 200}, ...],
##   "rare": [{"type": "item", "item_id": "necro_staff", "rarity": 3, "chance": 0.20}, ...],
##   "ultra_rare": [{"type": "cosmetic", "item_id": "bone_crown", "chance": 0.03}, ...]
## }


static func generate_drops(loot_table: Dictionary, boss_pos: Vector2, player_count: int = 1) -> Array[Dictionary]:
	var drops: Array[Dictionary] = []
	
	# Guaranteed drops
	var guaranteed: Array = loot_table.get("guaranteed", [])
	for entry in guaranteed:
		var drop := _process_guaranteed(entry)
		if not drop.is_empty():
			drops.append(drop)
	
	# Rare drops - per player count bonus
	var rare_bonus := 1.0 + (player_count - 1) * 0.1  # +10% esély playerenként
	var rare: Array = loot_table.get("rare", [])
	for entry in rare:
		var chance: float = entry.get("chance", 0.15) * rare_bonus
		if randf() < chance:
			drops.append(_process_item_drop(entry))
	
	# Ultra rare drops
	var ultra_rare: Array = loot_table.get("ultra_rare", [])
	for entry in ultra_rare:
		var chance: float = entry.get("chance", 0.03)
		if randf() < chance:
			drops.append(_process_item_drop(entry))
	
	return drops


static func _process_guaranteed(entry: Dictionary) -> Dictionary:
	match entry.get("type", ""):
		"gold":
			var amount := randi_range(entry.get("amount_min", 10), entry.get("amount_max", 50))
			return {"type": "gold", "amount": amount}
		"material":
			var amount := randi_range(entry.get("amount_min", 1), entry.get("amount_max", 5))
			return {"type": "material", "item_id": entry.get("item_id", "unknown"), "amount": amount, "name": entry.get("name", "Material")}
		"xp":
			return {"type": "xp", "amount": entry.get("amount", 100)}
		_:
			return entry


static func _process_item_drop(entry: Dictionary) -> Dictionary:
	return {
		"type": entry.get("type", "item"),
		"item_id": entry.get("item_id", "unknown"),
		"rarity": entry.get("rarity", Enums.Rarity.RARE),
		"name": entry.get("name", entry.get("item_id", "Item")),
	}


static func drop_loot_at(drops: Array[Dictionary], boss_pos: Vector2) -> void:
	var index := 0
	for drop in drops:
		var offset := Vector2(
			cos(TAU * index / max(drops.size(), 1)) * 32,
			sin(TAU * index / max(drops.size(), 1)) * 32
		)
		var drop_pos := boss_pos + offset
		EventBus.item_dropped.emit(drop, drop_pos)
		index += 1


static func create_loot_table_tier1(boss_id: String) -> Dictionary:
	match boss_id:
		"cursed_treant":
			return {
				"guaranteed": [
					{"type": "gold", "amount_min": 30, "amount_max": 80},
					{"type": "material", "item_id": "treant_bark", "name": "Treant Bark", "amount_min": 2, "amount_max": 5},
					{"type": "xp", "amount": 150},
				],
				"rare": [
					{"type": "item", "item_id": "nature_staff", "name": "Nature Staff", "rarity": Enums.Rarity.UNCOMMON, "chance": 0.25},
					{"type": "item", "item_id": "root_shield", "name": "Root Shield", "rarity": Enums.Rarity.RARE, "chance": 0.15},
				],
				"ultra_rare": [
					{"type": "item", "item_id": "treant_heart", "name": "Heart of the Forest", "rarity": Enums.Rarity.EPIC, "chance": 0.05},
				],
			}
		"plague_rat_king":
			return {
				"guaranteed": [
					{"type": "gold", "amount_min": 25, "amount_max": 70},
					{"type": "material", "item_id": "toxic_gland", "name": "Toxic Gland", "amount_min": 2, "amount_max": 4},
					{"type": "xp", "amount": 120},
				],
				"rare": [
					{"type": "item", "item_id": "plague_dagger", "name": "Plague Dagger", "rarity": Enums.Rarity.UNCOMMON, "chance": 0.25},
					{"type": "item", "item_id": "rat_king_crown", "name": "Rat King Crown", "rarity": Enums.Rarity.RARE, "chance": 0.15},
				],
				"ultra_rare": [
					{"type": "item", "item_id": "plague_heart", "name": "Plague Heart", "rarity": Enums.Rarity.EPIC, "chance": 0.04},
				],
			}
		"frozen_sentinel":
			return {
				"guaranteed": [
					{"type": "gold", "amount_min": 40, "amount_max": 100},
					{"type": "material", "item_id": "frost_crystal", "name": "Frost Crystal", "amount_min": 3, "amount_max": 6},
					{"type": "xp", "amount": 200},
				],
				"rare": [
					{"type": "item", "item_id": "ice_hammer", "name": "Glacial Hammer", "rarity": Enums.Rarity.RARE, "chance": 0.20},
					{"type": "item", "item_id": "sentinel_core", "name": "Sentinel Core", "rarity": Enums.Rarity.RARE, "chance": 0.15},
				],
				"ultra_rare": [
					{"type": "item", "item_id": "frozen_heart", "name": "Frozen Heart", "rarity": Enums.Rarity.EPIC, "chance": 0.05},
				],
			}
		"shadow_stalker":
			return {
				"guaranteed": [
					{"type": "gold", "amount_min": 35, "amount_max": 90},
					{"type": "material", "item_id": "dark_essence", "name": "Dark Essence", "amount_min": 2, "amount_max": 5},
					{"type": "xp", "amount": 180},
				],
				"rare": [
					{"type": "item", "item_id": "shadow_blade", "name": "Shadow Blade", "rarity": Enums.Rarity.RARE, "chance": 0.20},
					{"type": "item", "item_id": "stalker_fang", "name": "Stalker Fang", "rarity": Enums.Rarity.RARE, "chance": 0.15},
				],
				"ultra_rare": [
					{"type": "item", "item_id": "shadow_cloak", "name": "Cloak of Shadows", "rarity": Enums.Rarity.EPIC, "chance": 0.04},
				],
			}
		_:
			return {"guaranteed": [{"type": "gold", "amount_min": 20, "amount_max": 50}], "rare": [], "ultra_rare": []}


static func create_loot_table_tier2(boss_id: String) -> Dictionary:
	match boss_id:
		"necromancer_king":
			return {
				"guaranteed": [
					{"type": "gold", "amount_min": 100, "amount_max": 200},
					{"type": "material", "item_id": "dark_essence", "name": "Dark Essence", "amount_min": 20, "amount_max": 50},
					{"type": "material", "item_id": "bone_fragment", "name": "Bone Fragment", "amount_min": 5, "amount_max": 10},
					{"type": "xp", "amount": 500},
				],
				"rare": [
					{"type": "item", "item_id": "necro_staff", "name": "Necromancer Staff", "rarity": Enums.Rarity.EPIC, "chance": 0.20},
					{"type": "item", "item_id": "death_lord_helm", "name": "Death Lord Helm", "rarity": Enums.Rarity.EPIC, "chance": 0.15},
					{"type": "item", "item_id": "death_lord_chest", "name": "Death Lord Chestplate", "rarity": Enums.Rarity.EPIC, "chance": 0.15},
					{"type": "item", "item_id": "death_lord_boots", "name": "Death Lord Boots", "rarity": Enums.Rarity.EPIC, "chance": 0.15},
					{"type": "item", "item_id": "crypt_key", "name": "Crypt Key", "rarity": Enums.Rarity.RARE, "chance": 0.30},
				],
				"ultra_rare": [
					{"type": "cosmetic", "item_id": "bone_crown", "name": "Bone Crown", "chance": 0.03},
					{"type": "cosmetic", "item_id": "undead_pet", "name": "Undead Minion Pet", "chance": 0.02},
				],
			}
		"spider_matriarch":
			return {
				"guaranteed": [
					{"type": "gold", "amount_min": 80, "amount_max": 180},
					{"type": "material", "item_id": "spider_silk", "name": "Spider Silk", "amount_min": 15, "amount_max": 30},
					{"type": "xp", "amount": 400},
				],
				"rare": [
					{"type": "item", "item_id": "spider_fang_dagger", "name": "Spider Fang Dagger", "rarity": Enums.Rarity.EPIC, "chance": 0.20},
					{"type": "item", "item_id": "webweaver_armor", "name": "Webweaver Armor", "rarity": Enums.Rarity.EPIC, "chance": 0.15},
					{"type": "item", "item_id": "spider_eye_gem", "name": "Spider Eye Gem", "rarity": Enums.Rarity.RARE, "chance": 0.25},
				],
				"ultra_rare": [
					{"type": "cosmetic", "item_id": "spider_pet", "name": "Spiderling Pet", "chance": 0.03},
				],
			}
		"infernal_warden":
			return {
				"guaranteed": [
					{"type": "gold", "amount_min": 120, "amount_max": 250},
					{"type": "material", "item_id": "ember_core", "name": "Ember Core", "amount_min": 10, "amount_max": 20},
					{"type": "xp", "amount": 600},
				],
				"rare": [
					{"type": "item", "item_id": "infernal_blade", "name": "Infernal Blade", "rarity": Enums.Rarity.EPIC, "chance": 0.20},
					{"type": "item", "item_id": "warden_heart", "name": "Warden Heart", "rarity": Enums.Rarity.LEGENDARY, "chance": 0.08},
					{"type": "item", "item_id": "ember_gem", "name": "Ember Gem", "rarity": Enums.Rarity.RARE, "chance": 0.25},
				],
				"ultra_rare": [
					{"type": "item", "item_id": "fire_elemental", "name": "Fire Elemental Summon", "rarity": Enums.Rarity.LEGENDARY, "chance": 0.03},
				],
			}
		"forgotten_construct":
			return {
				"guaranteed": [
					{"type": "gold", "amount_min": 100, "amount_max": 220},
					{"type": "material", "item_id": "ancient_gear", "name": "Ancient Gear", "amount_min": 8, "amount_max": 15},
					{"type": "xp", "amount": 550},
				],
				"rare": [
					{"type": "item", "item_id": "construct_core", "name": "Construct Core", "rarity": Enums.Rarity.EPIC, "chance": 0.20},
					{"type": "item", "item_id": "ancient_blueprint", "name": "Ancient Blueprint", "rarity": Enums.Rarity.RARE, "chance": 0.30},
					{"type": "item", "item_id": "vault_key", "name": "Vault Key", "rarity": Enums.Rarity.RARE, "chance": 0.25},
				],
				"ultra_rare": [
					{"type": "cosmetic", "item_id": "mecha_pet", "name": "Mechanical Pet", "chance": 0.03},
				],
			}
		_:
			return {"guaranteed": [{"type": "gold", "amount_min": 80, "amount_max": 150}], "rare": [], "ultra_rare": []}


## Tier 3 (World Bosses) – Plan 16
static func create_loot_table_tier3(boss_id: String) -> Dictionary:
	return {
		"guaranteed": [
			{"type": "gold", "amount_min": 500, "amount_max": 1500},
			{"type": "material", "item_id": "mat_rare_essence", "name": "Rare Essence", "amount_min": 5, "amount_max": 10},
			{"type": "material", "item_id": "mat_legendary_essence", "name": "Legendary Essence", "amount_min": 1, "amount_max": 3},
			{"type": "xp", "amount": 2000},
		],
		"rare": [
			{"type": "item", "rarity": Enums.Rarity.LEGENDARY, "chance": 0.15, "item_id": boss_id + "_weapon", "name": boss_id + " Weapon"},
			{"type": "item", "rarity": Enums.Rarity.EPIC, "chance": 0.25, "item_id": boss_id + "_armor", "name": boss_id + " Armor"},
			{"type": "set_piece", "chance": 0.20, "item_id": boss_id + "_set", "name": boss_id + " Set Piece"},
		],
		"ultra_rare": [
			{"type": "item", "rarity": Enums.Rarity.LEGENDARY, "chance": 0.05, "item_id": boss_id + "_unique", "name": boss_id + " Unique"},
			{"type": "cosmetic", "item_id": boss_id + "_title", "name": boss_id + " Slayer Title", "chance": 0.10},
		],
	}


## Tier 4 (Raid Bosses) – Plan 16
static func create_loot_table_tier4(boss_id: String) -> Dictionary:
	return {
		"guaranteed": [
			{"type": "gold", "amount_min": 2000, "amount_max": 5000},
			{"type": "material", "item_id": "mat_legendary_essence", "name": "Legendary Essence", "amount_min": 5, "amount_max": 10},
			{"type": "material", "item_id": "mat_aetherium_shard", "name": "Aetherium Shard", "amount_min": 1, "amount_max": 3},
			{"type": "material", "item_id": "mat_god_essence", "name": "God Essence", "amount_min": 1, "amount_max": 2},
			{"type": "xp", "amount": 5000},
			{"type": "item", "rarity": Enums.Rarity.LEGENDARY, "chance": 1.0, "item_id": boss_id + "_legendary1", "name": boss_id + " Legendary Drop 1"},
			{"type": "item", "rarity": Enums.Rarity.LEGENDARY, "chance": 1.0, "item_id": boss_id + "_legendary2", "name": boss_id + " Legendary Drop 2"},
		],
		"rare": [
			{"type": "set_piece", "chance": 0.50, "item_id": boss_id + "_set", "name": boss_id + " Set Piece"},
			{"type": "item", "rarity": Enums.Rarity.LEGENDARY, "chance": 0.30, "item_id": boss_id + "_weapon", "name": boss_id + " Exclusive Weapon"},
		],
		"ultra_rare": [
			{"type": "cosmetic", "item_id": boss_id + "_cosmetic", "name": boss_id + " Cosmetic", "chance": 0.15},
			{"type": "cosmetic", "item_id": boss_id + "_title", "name": boss_id + " Conqueror Title", "chance": 0.25},
			{"type": "item", "rarity": Enums.Rarity.LEGENDARY, "chance": 0.05, "item_id": boss_id + "_mythic", "name": boss_id + " Mythic Artifact"},
		],
	}

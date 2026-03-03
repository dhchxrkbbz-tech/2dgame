## LootGenerator - Item generáló rendszer
## Rarity rolling, affix generálás, loot table feldolgozás
class_name LootGenerator
extends RefCounted

## Rarity súlyok enemy tier alapján [Common, Uncommon, Rare, Epic, Legendary]
const RARITY_WEIGHTS := {
	"normal": [70.0, 22.0, 7.0, 0.9, 0.1],
	"caster": [65.0, 25.0, 8.0, 1.8, 0.2],
	"elite": [30.0, 40.0, 22.0, 7.0, 1.0],
	"rare_named": [10.0, 30.0, 40.0, 17.0, 3.0],
	"mini_boss": [5.0, 25.0, 40.0, 25.0, 5.0],
	"dungeon_boss": [0.0, 15.0, 40.0, 35.0, 10.0],
	"world_boss": [0.0, 5.0, 30.0, 45.0, 20.0],
	"raid_boss": [0.0, 0.0, 20.0, 50.0, 30.0],
}

## Drop esélyek
const DROP_CHANCE := {
	"normal": 0.30,
	"caster": 0.35,
	"elite": 0.80,
	"rare_named": 1.0,
	"mini_boss": 1.0,
	"dungeon_boss": 1.0,
	"world_boss": 1.0,
	"raid_boss": 1.0,
}

## Drop count range-ek
const DROP_COUNT := {
	"normal": Vector2i(0, 1),
	"caster": Vector2i(0, 1),
	"elite": Vector2i(1, 2),
	"rare_named": Vector2i(2, 3),
	"mini_boss": Vector2i(2, 4),
	"dungeon_boss": Vector2i(3, 5),
	"world_boss": Vector2i(4, 6),
	"raid_boss": Vector2i(5, 8),
}


## Generál egy teljes item-et adott rarity-vel és level-lel
static func generate_item(item_level: int, rarity: int = -1, magic_find: float = 0.0, tier: String = "normal") -> ItemInstance:
	AffixData.initialize_pools()
	
	var instance := ItemInstance.new()
	instance.item_level = item_level
	
	# Rarity rolling ha nincs megadva
	if rarity < 0:
		rarity = _roll_rarity(tier, magic_find)
	instance.rarity = rarity
	
	# Base item generálás
	instance.base_item = _generate_base_item(item_level, rarity)
	
	# Affix rolling rarity alapján
	var affix_count := _get_affix_count(rarity)
	var prefix_count := affix_count.x
	var suffix_count := affix_count.y
	
	var used_stats: Array[String] = []
	
	for i in prefix_count:
		var affix := AffixData.roll_random_prefix(used_stats)
		if affix:
			var value := affix.roll_value(item_level)
			instance.affixes.append({"affix": affix, "value": value})
			used_stats.append(affix.stat_type)
	
	for i in suffix_count:
		var affix := AffixData.roll_random_suffix(used_stats)
		if affix:
			var value := affix.roll_value(item_level)
			instance.affixes.append({"affix": affix, "value": value})
			used_stats.append(affix.stat_type)
	
	# Socket-ek (rare+ item-eknek)
	if rarity >= Enums.Rarity.RARE:
		instance.base_item.socket_count = randi_range(0, mini(rarity - 1, 3))
	
	return instance


## Rarity roll Magic Find módosítóval
static func _roll_rarity(tier: String, magic_find: float) -> int:
	var weights: Array = RARITY_WEIGHTS.get(tier, RARITY_WEIGHTS["normal"]).duplicate()
	var mf_mult := 1.0 + magic_find / 100.0
	
	# MF modifiers (higher rarity → stronger MF scaling)
	if weights.size() >= 5:
		weights[1] *= mf_mult       # Uncommon
		weights[2] *= mf_mult       # Rare
		weights[3] *= mf_mult * mf_mult  # Epic (MF²)
		weights[4] *= mf_mult * mf_mult * mf_mult  # Legendary (MF³)
		# Legendary hard cap: 5%
		var total: float = 0
		for w in weights:
			total += w
		if weights[4] / total > 0.05:
			weights[4] = total * 0.05 / (1.0 - 0.05)
	
	return Utils.weighted_random(weights)


## Affix count: Vector2i(prefix_count, suffix_count)
static func _get_affix_count(rarity: int) -> Vector2i:
	match rarity:
		Enums.Rarity.COMMON: return Vector2i(0, 0)
		Enums.Rarity.UNCOMMON:
			return Vector2i(1, 0) if randf() > 0.5 else Vector2i(0, 1)
		Enums.Rarity.RARE:
			return Vector2i(1, 1) if randf() > 0.5 else Vector2i(1, 2)
		Enums.Rarity.EPIC:
			return Vector2i(2, 1) if randf() > 0.5 else Vector2i(2, 2)
		Enums.Rarity.LEGENDARY:
			return Vector2i(2, 2)
		_: return Vector2i(0, 0)


## Base item generálás – ItemDatabase-ből ha lehetséges
static func _generate_base_item(item_level: int, rarity: int) -> ItemData:
	# Próbáljuk az ItemDatabase-ből venni
	var db_item := ItemDatabase.get_random_item_for_level(item_level)
	if db_item:
		db_item.rarity = rarity
		db_item.item_level = item_level
		db_item.required_level = maxi(1, item_level - 3)
		# Rarity-alapú stat scaling
		db_item.base_damage = _scale_stat(db_item.base_damage, item_level, rarity) if db_item.base_damage > 0 else 0
		db_item.base_armor = _scale_stat(db_item.base_armor, item_level, rarity) if db_item.base_armor > 0 else 0
		db_item.base_hp = _scale_stat(db_item.base_hp, item_level, rarity) if db_item.base_hp > 0 else 0
		db_item.sell_price = _calc_sell_price(item_level, rarity)
		return db_item
	
	# Fallback: generikus item
	var item := ItemData.new()
	var types := ["weapon", "armor", "accessory"]
	var type_choice := types[randi() % types.size()]
	
	match type_choice:
		"weapon":
			item.item_type = Enums.ItemType.WEAPON
			item.equip_slot = Enums.EquipSlot.MAIN_HAND
			var weapons := ["Sword", "Dagger", "Staff", "Axe", "Mace", "Wand", "Bow"]
			item.item_name = weapons[randi() % weapons.size()]
			item.base_damage = _scale_stat(8, item_level, rarity)
			item.icon_color = Color(0.8, 0.6, 0.4)
		"armor":
			var armor_slots := [Enums.EquipSlot.HELMET, Enums.EquipSlot.CHEST, Enums.EquipSlot.GLOVES, Enums.EquipSlot.BOOTS, Enums.EquipSlot.BELT]
			var armor_names := ["Helm", "Chestplate", "Gauntlets", "Greaves", "Belt"]
			var idx := randi() % armor_slots.size()
			item.item_type = Enums.ItemType.ARMOR
			item.equip_slot = armor_slots[idx]
			item.item_name = armor_names[idx]
			item.base_armor = _scale_stat(5, item_level, rarity)
			item.base_hp = _scale_stat(10, item_level, rarity)
			item.icon_color = Color(0.5, 0.5, 0.6)
		"accessory":
			var acc_slots := [Enums.EquipSlot.AMULET, Enums.EquipSlot.RING_1, Enums.EquipSlot.CAPE]
			var acc_names := ["Amulet", "Ring", "Cape"]
			var idx := randi() % acc_slots.size()
			item.item_type = Enums.ItemType.ACCESSORY
			item.equip_slot = acc_slots[idx]
			item.item_name = acc_names[idx]
			item.base_hp = _scale_stat(5, item_level, rarity)
			item.icon_color = Color(0.7, 0.5, 0.8)
	
	item.item_id = "%s_%d_%d" % [item.item_name.to_lower(), item_level, randi() % 1000]
	item.item_level = item_level
	item.required_level = maxi(1, item_level - 3)
	item.rarity = rarity
	item.sell_price = _calc_sell_price(item_level, rarity)
	
	return item


static func _scale_stat(base: int, level: int, rarity: int) -> int:
	var level_mult := 1.0 + (level - 1) * 0.06
	var rarity_bonus := [0.0, 0.15, 0.30, 0.50, 0.80]
	var bonus := rarity_bonus[rarity] if rarity < rarity_bonus.size() else 0.0
	return int(base * level_mult * (1.0 + bonus))


static func _calc_sell_price(level: int, rarity: int) -> int:
	var base := 1 + level
	var mult := [1, 2, 5, 15, 50]
	var m := mult[rarity] if rarity < mult.size() else 1
	return base * m


## Loot generálás enemy tier-ből
static func generate_enemy_loot(enemy_level: int, tier: String = "normal", magic_find: float = 0.0) -> Array[ItemInstance]:
	var items: Array[ItemInstance] = []
	
	var drop_chance: float = DROP_CHANCE.get(tier, 0.3)
	drop_chance *= (1.0 + magic_find / 100.0)
	
	if randf() > drop_chance:
		return items
	
	var count_range: Vector2i = DROP_COUNT.get(tier, Vector2i(0, 1))
	var count := randi_range(count_range.x, count_range.y)
	
	for i in count:
		var item_level := enemy_level + randi_range(-2, 2)
		item_level = maxi(1, item_level)
		var item := generate_item(item_level, -1, magic_find, tier)
		items.append(item)
	
	return items


## Gold amount generálás
static func generate_gold(enemy_level: int, tier: String = "normal") -> int:
	var base := enemy_level * 2
	match tier:
		"normal": return randi_range(1, base)
		"elite": return randi_range(base, base * 3)
		"mini_boss": return randi_range(base * 2, base * 5)
		"dungeon_boss": return randi_range(base * 5, base * 10)
		"world_boss": return randi_range(base * 10, base * 20)
		"raid_boss": return randi_range(base * 20, base * 40)
		_: return randi_range(1, base)


## Material drop generálás
static func generate_material_drop(enemy_level: int, tier: String = "normal") -> Array[ItemInstance]:
	var items: Array[ItemInstance] = []
	var mat_chance: float = 0.0
	var mat_count: Vector2i = Vector2i(1, 1)
	
	match tier:
		"normal":
			mat_chance = 0.40
			mat_count = Vector2i(1, 3)
		"elite":
			mat_chance = 0.30
			mat_count = Vector2i(1, 2)
		"mini_boss", "dungeon_boss":
			mat_chance = 0.50
			mat_count = Vector2i(1, 2)
		"world_boss", "raid_boss":
			mat_chance = 0.30
			mat_count = Vector2i(1, 1)
		_:
			mat_chance = 0.40
			mat_count = Vector2i(1, 3)
	
	if randf() > mat_chance:
		return items
	
	var mats := ItemDatabase.get_items_by_type(Enums.ItemType.MATERIAL)
	var valid_mats: Array[ItemData] = []
	for mat in mats:
		if mat.required_level <= enemy_level + 5:
			valid_mats.append(mat)
	
	if valid_mats.is_empty():
		return items
	
	var count := randi_range(mat_count.x, mat_count.y)
	var chosen_mat: ItemData = valid_mats[randi() % valid_mats.size()]
	
	var instance := ItemInstance.new()
	instance.base_item = chosen_mat
	instance.item_level = chosen_mat.item_level
	instance.rarity = Enums.Rarity.COMMON
	instance.quantity = count
	items.append(instance)
	
	return items


## Chest loot generálás
## chest_type: "common", "uncommon", "rare", "boss", "secret"
static func generate_chest_loot(chest_type: String, dungeon_level: int, magic_find: float = 0.0) -> Dictionary:
	var result: Dictionary = {"items": [] as Array[ItemInstance], "gold": 0}
	
	var rarity_weights: Array = []
	var item_count := Vector2i(1, 1)
	var gold_range := Vector2i(10, 30)
	
	match chest_type:
		"common":
			rarity_weights = [60.0, 30.0, 9.0, 1.0, 0.0]
			item_count = Vector2i(1, 3)
			gold_range = Vector2i(10, 30)
		"uncommon":
			rarity_weights = [30.0, 40.0, 25.0, 5.0, 0.0]
			item_count = Vector2i(1, 2)
			gold_range = Vector2i(20, 50)
		"rare":
			rarity_weights = [5.0, 25.0, 45.0, 20.0, 5.0]
			item_count = Vector2i(1, 1)
			gold_range = Vector2i(50, 100)
		"boss":
			rarity_weights = [0.0, 10.0, 40.0, 35.0, 15.0]
			item_count = Vector2i(2, 3)
			gold_range = Vector2i(100, 300)
		"secret":
			rarity_weights = [0.0, 10.0, 35.0, 40.0, 15.0]
			item_count = Vector2i(1, 2)
			gold_range = Vector2i(50, 150)
		_:
			rarity_weights = [60.0, 30.0, 9.0, 1.0, 0.0]
			item_count = Vector2i(1, 2)
			gold_range = Vector2i(10, 30)
	
	# Apply magic find
	var mf_mult := 1.0 + magic_find / 100.0
	if rarity_weights.size() >= 5:
		rarity_weights[1] *= mf_mult
		rarity_weights[2] *= mf_mult
		rarity_weights[3] *= mf_mult * mf_mult
		rarity_weights[4] *= mf_mult * mf_mult * mf_mult
	
	# Items
	var count := randi_range(item_count.x, item_count.y)
	for i in count:
		var rarity := Utils.weighted_random(rarity_weights)
		var item_level := dungeon_level + randi_range(-1, 2)
		item_level = maxi(1, item_level)
		var item := generate_item(item_level, rarity, magic_find)
		result["items"].append(item)
	
	# Material bonus (uncommon+)
	if chest_type in ["uncommon", "secret"]:
		var mat_drop := generate_material_drop(dungeon_level, "elite")
		for mat in mat_drop:
			result["items"].append(mat)
	
	# Gold
	result["gold"] = randi_range(gold_range.x, gold_range.y)
	
	return result


## Legendary item generálás speciális tulajdonsággal
static func generate_legendary(item_level: int, legendary_id: String = "") -> ItemInstance:
	var instance := generate_item(item_level, Enums.Rarity.LEGENDARY)
	
	# Legendary unique property
	if not legendary_id.is_empty():
		var legendary_def := LegendaryData.get_legendary(legendary_id)
		if legendary_def:
			instance.base_item.item_name = legendary_def.get("name", instance.base_item.item_name)
			instance.unique_property = legendary_def.get("unique_property", {})
			# Fix stats from legendary def
			if legendary_def.has("fixed_stats"):
				instance.affixes.clear()
				for stat_key in legendary_def["fixed_stats"]:
					var affix := AffixData.new()
					affix.affix_name = ""
					affix.stat_type = stat_key
					affix.is_percent = "%" in str(legendary_def["fixed_stats"][stat_key])
					instance.affixes.append({"affix": affix, "value": float(legendary_def["fixed_stats"][stat_key])})
	
	return instance


## Set item generálás
static func generate_set_item(set_id: String, slot: String, item_level: int) -> ItemInstance:
	var set_def := SetItemData.get_set(set_id)
	if not set_def:
		return generate_item(item_level, Enums.Rarity.EPIC)
	
	var instance := generate_item(item_level, Enums.Rarity.EPIC)
	instance.set_id = set_id
	
	var piece := set_def.get("pieces", {}).get(slot, {})
	if piece:
		instance.base_item.item_name = piece.get("name", instance.base_item.item_name)
	
	return instance

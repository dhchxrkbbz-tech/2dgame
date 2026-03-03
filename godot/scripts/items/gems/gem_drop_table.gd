## GemDropTable - Gem drop logika enemy-k, boss-ok, chest-ek alapján
## A 09_gem_system_plan.txt 9. fejezete alapján
class_name GemDropTable
extends RefCounted

## Normál gem típusok (legendary nélkül)
const NORMAL_GEM_TYPES: Array[int] = [
	Enums.GemType.RUBY,
	Enums.GemType.EMERALD,
	Enums.GemType.SAPPHIRE,
	Enums.GemType.AMETHYST,
	Enums.GemType.TOPAZ,
	Enums.GemType.DIAMOND,
]


## Gem drop roll normál enemy-hez
## 5% chance Chipped gem
static func roll_normal_enemy_drop() -> GemInstance:
	if randf() > 0.05:
		return null
	return _create_random_gem(Enums.GemTier.CHIPPED)


## Gem drop roll elite enemy-hez
## 15% chance Chipped/Flawed (70/30)
static func roll_elite_enemy_drop() -> GemInstance:
	if randf() > 0.15:
		return null
	var tier: Enums.GemTier
	if randf() < 0.70:
		tier = Enums.GemTier.CHIPPED
	else:
		tier = Enums.GemTier.FLAWED
	return _create_random_gem(tier)


## Gem drop roll boss-hoz tier alapján
## Returns: Array[GemInstance] (normál gem + opcionális legendary)
static func roll_boss_drop(boss_tier: int) -> Array:
	var drops: Array = []

	match boss_tier:
		1:  # T1 Mini Boss: 50% Flawed/Normal (60/40)
			if randf() < 0.50:
				var tier := Enums.GemTier.FLAWED if randf() < 0.60 else Enums.GemTier.NORMAL
				drops.append(_create_random_gem(tier))

		2:  # T2 Dungeon Boss: 80% Normal/Flawless (60/40)
			if randf() < 0.80:
				var tier := Enums.GemTier.NORMAL if randf() < 0.60 else Enums.GemTier.FLAWLESS
				drops.append(_create_random_gem(tier))

		3:  # T3 World Boss: 100% Flawless/Perfect (60/40) + 5% Legendary
			var tier := Enums.GemTier.FLAWLESS if randf() < 0.60 else Enums.GemTier.PERFECT
			drops.append(_create_random_gem(tier))
			if randf() < 0.05:
				drops.append(_create_random_legendary())

		4:  # T4 Raid Boss: 100% Perfect/Radiant (60/40) + 10% Legendary
			var tier := Enums.GemTier.PERFECT if randf() < 0.60 else Enums.GemTier.RADIANT
			drops.append(_create_random_gem(tier))
			if randf() < 0.10:
				drops.append(_create_random_legendary())

	return drops


## Gem drop roll dungeon chest-hez
## 10% chance Chipped-Normal gem (tier-függő)
static func roll_dungeon_chest_drop(dungeon_tier: int) -> GemInstance:
	if randf() > 0.10:
		return null

	var max_gem_tier: Enums.GemTier
	match dungeon_tier:
		1: max_gem_tier = Enums.GemTier.CHIPPED
		2: max_gem_tier = Enums.GemTier.FLAWED
		3: max_gem_tier = Enums.GemTier.NORMAL
		4: max_gem_tier = Enums.GemTier.FLAWLESS
		_: max_gem_tier = Enums.GemTier.CHIPPED

	var tier: Enums.GemTier = randi_range(0, max_gem_tier) as Enums.GemTier
	return _create_random_gem(tier)


## Secret room chest: 1% esély legendary gem-re
static func roll_secret_room_drop() -> GemInstance:
	if randf() < 0.01:
		return _create_random_legendary()
	return null


## Gem mining node drop (Mountains biome gyakoribb)
static func roll_mining_drop(is_mountains: bool = false, mining_level: int = 1) -> GemInstance:
	var base_chance := 0.20 if is_mountains else 0.05
	# Mining level bónusz: +10% quality / level
	var quality_bonus := mining_level * 0.10

	if randf() > base_chance:
		return null

	# Alap Chipped, de mining level növeli a quality-t
	var max_tier := Enums.GemTier.CHIPPED
	if quality_bonus >= 0.5:
		max_tier = Enums.GemTier.FLAWED
	if quality_bonus >= 1.0:
		max_tier = Enums.GemTier.NORMAL
	if quality_bonus >= 2.0:
		max_tier = Enums.GemTier.FLAWLESS

	var tier: Enums.GemTier = randi_range(0, max_tier) as Enums.GemTier
	return _create_random_gem(tier)


## Segéd: random normál gem létrehozás
static func _create_random_gem(tier: Enums.GemTier) -> GemInstance:
	var type_index := randi() % NORMAL_GEM_TYPES.size()
	var gem_type: Enums.GemType = NORMAL_GEM_TYPES[type_index] as Enums.GemType
	return GemInstance.create_normal(gem_type, tier)


## Segéd: random legendary gem létrehozás
static func _create_random_legendary() -> GemInstance:
	var leg_data := LegendaryGemDatabase.get_random_gem()
	if not leg_data:
		return null
	return GemInstance.create_legendary(leg_data.gem_id)

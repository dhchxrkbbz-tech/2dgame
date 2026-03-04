## Globális konstansok - Autoload singleton
extends Node

# === Tile és chunk ===
const TILE_SIZE: int = 32
const CHUNK_SIZE: int = 16  # tile-okban
const CHUNK_PIXEL_SIZE: int = TILE_SIZE * CHUNK_SIZE  # 512

# === Viewport ===
const VIEWPORT_SIZE: Vector2i = Vector2i(640, 360)

# === Multiplayer ===
const MAX_PLAYERS: int = 4
const TICK_RATE: int = 20  # szerver tick/sec

# === Player ===
const MAX_LEVEL: int = 50
## Plan 16: 1 skill point per level (Lv2-50 = 49 total), replaces old per-2-levels
const MAX_SKILL_POINTS: int = 49
const PLAYER_SPRITE_SIZE: Vector2i = Vector2i(32, 48)

# === Movement ===
const BASE_SPEED_ASSASSIN: float = 130.0
const BASE_SPEED_TANK: float = 90.0
const BASE_SPEED_MAGE: float = 100.0

# === Combat ===
const GLOBAL_COOLDOWN: float = 0.5  # GCD másodpercben
const CDR_CAP: float = 0.40  # 40% max cooldown reduction
const MIN_DAMAGE: int = 1
const ARMOR_EFFECTIVENESS: float = 0.5  # armor reduces 50% of its value
const IFRAMES_DURATION: float = 0.3  # invincibility frames

# === Dodge ===
const DODGE_SPEED_MULTIPLIER: float = 2.5
const DODGE_DURATION: float = 0.3
const DODGE_COOLDOWN: float = 0.8  # Plan 21: cooldown between dodges

# === Camera ===
const CAMERA_SMOOTHING_SPEED: float = 5.0
const CAMERA_ZOOM: Vector2 = Vector2(1.0, 1.0)

# === UI ===
const TOOLTIP_DELAY: float = 0.3
const DAMAGE_NUMBER_DURATION: float = 1.0
const DAMAGE_NUMBER_RISE: float = 50.0

# === XP rendszer ===
## Képlet: xp_for_level = floor(100 * (level ^ 1.8))
## Lv1→2: 100, Lv10: ~5180, Lv25: ~43100, Lv50: ~227000
## Összesen 1→50: ~2,500,000 XP (40-60 óra normál tempóval)
const BASE_XP_COEFFICIENT: int = 100
const XP_EXPONENT: float = 1.8

# === Stat növekedés szintenként ===
const STAT_POINTS_PER_LEVEL: int = 3  # Szabadon elosztható STR/DEX/INT/VIT
const SKILL_POINTS_PER_LEVEL: int = 1  # 1 skill pont szintenként (Lv2-50 = 49)
const HP_PER_LEVEL_BASE: int = 15      # +15 HP base per level
const HP_PER_VIT: float = 2.0          # +VIT×2 HP bonus
const MANA_PER_LEVEL_BASE: int = 8     # +8 mana base per level
const MANA_PER_INT: float = 1.5        # +INT×1.5 mana bonus
const DAMAGE_SCALE_STR: float = 0.5    # STR×0.5 melee damage
const DAMAGE_SCALE_DEX: float = 0.5    # DEX×0.5 ranged damage
const DAMAGE_SCALE_INT: float = 0.8    # INT×0.8 spell damage
const RESPEC_COST_PER_LEVEL: int = 1000  # Respec ár = level × 1000 Gold

# === Loot ===
const ITEM_PICKUP_RANGE: float = 48.0  # pixel

# === Death & Respawn (Plan 21 §2.11) ===
const DEATH_GOLD_PENALTY_PERCENT: float = 0.05  # 5% of total gold
const RESPAWN_TIMER: float = 5.0  # seconds
const RESPAWN_HP_PERCENT: float = 0.5  # 50% of max
const RESPAWN_MANA_PERCENT: float = 0.5  # 50% of max
const RESPAWN_INVINCIBILITY_DURATION: float = 3.0  # seconds

# === Combo System (Plan 21 §2.8) ===
const COMBO_TIMEOUT: float = 3.0  # seconds between kills to maintain combo
const COMBAT_TIMEOUT: float = 5.0  # seconds without damage → peace state
const COMBO_XP_MULT_3: float = 1.1   # combo 3-4
const COMBO_XP_MULT_5: float = 1.25  # combo 5-9
const COMBO_XP_MULT_10: float = 1.5  # combo 10+

# === Mana regen ===
const BASE_MANA_REGEN_ASSASSIN: float = 2.0
const BASE_MANA_REGEN_TANK: float = 1.5
const BASE_MANA_REGEN_MAGE: float = 3.0

# === Save ===
const AUTOSAVE_INTERVAL: float = 300.0  # 5 perc
const MAX_SAVE_SLOTS: int = 3

# === Collision layers ===
const LAYER_PLAYER_PHYSICS: int = 1
const LAYER_ENEMY_PHYSICS: int = 2
const LAYER_WALL: int = 3
const LAYER_PLAYER_HITBOX: int = 4
const LAYER_PLAYER_HURTBOX: int = 5
const LAYER_ENEMY_HITBOX: int = 6
const LAYER_ENEMY_HURTBOX: int = 7
const LAYER_PROJECTILE: int = 8
const LAYER_DETECTION: int = 9
const LAYER_INTERACTION: int = 10

# === Economy ===
const INVENTORY_DEFAULT_SIZE: int = 30
const INVENTORY_MAX_SIZE: int = 60
const STASH_DEFAULT_SIZE: int = 50
const STACK_LIMIT_CONSUMABLE: int = 99
const STACK_LIMIT_MATERIAL: int = 99
const STACK_LIMIT_GEAR: int = 1

const NPC_SELL_MULTIPLIER: float = 0.35  # Játékos ennyi %-ot kap vissza
const NPC_BUY_MULTIPLIER: float = 1.0    # NPC-nél ennyiért vesz

const MARKETPLACE_LISTING_FEE: float = 0.02    # 2%
const MARKETPLACE_TRANSACTION_FEE: float = 0.05  # 5%
const MARKETPLACE_LISTING_DURATION: int = 172800  # 48 óra secben

const GEM_INSERT_COST: int = 0      # Ingyenes behelyezés
const GEM_REMOVE_COST: int = 200
const GEM_REMOVE_COST_PER_TIER: int = 100  # 100 × (tier + 1) eltávolítási ár
const GEM_LEGENDARY_REMOVE_COST: int = 2000  # Legendary gem eltávolítási ár
const GEM_COMBINE_COUNT: int = 3  # 3 gem kell kombináláshoz
const GEM_COMBINE_GOLD_COSTS: Array[int] = [50, 200, 500, 1500, 5000]  # Tier 1→2, 2→3, stb.
const GEM_COMBINE_NEEDS_RELIC: Array[bool] = [false, false, false, false, true]  # Tier 5→6 relic kell
const GEM_ADD_SOCKET_BASE_COST: int = 500  # Socket bővítés alap ára
const GEM_ADD_SOCKET_DARK_ESSENCE: int = 1  # Dark Essence ár socket bővítéshez
const GEM_MATCHING_BONUS: float = 0.20  # +20% ha minden socket azonos gem
const GEM_RAINBOW_BONUS: float = 0.05  # +5% All Stats ha 3+ különböző gem
const GEM_RAINBOW_MIN_TYPES: int = 3  # Minimum különböző gem típus rainbow bónuszhoz

# Gem tier NPC sell prices (tier_index + 1) × 50
const GEM_SELL_PRICE_MULTIPLIER: int = 50

# Gem drop %-ok
const GEM_DROP_NORMAL_ENEMY: float = 0.05   # 5%
const GEM_DROP_ELITE_ENEMY: float = 0.15    # 15%
const GEM_DROP_DUNGEON_CHEST: float = 0.10  # 10%
const GEM_DROP_SECRET_ROOM_LEGENDARY: float = 0.01  # 1%

# Gem mining
const GEM_MINING_CHANCE_MOUNTAINS: float = 0.20
const GEM_MINING_CHANCE_OTHER: float = 0.05
const GEM_MINING_QUALITY_PER_LEVEL: float = 0.10

const REPAIR_COST_PER_LEVEL: int = 5
const FAST_TRAVEL_BASE_COST: int = 20
const FAST_TRAVEL_COST_PER_CHUNK: int = 2
const FAST_TRAVEL_COOLDOWN: float = 30.0
const FAST_TRAVEL_TELEPORT_DURATION: float = 2.0
const SKILL_RESET_BASE_COST: int = 500

# === Achievement ===
const ACHIEVEMENT_POPUP_DURATION: float = 3.0

# === World Events ===
const WORLD_EVENT_MIN_INTERVAL: float = 1800.0  # 30 perc
const WORLD_EVENT_MAX_INTERVAL: float = 3600.0  # 60 perc
const WORLD_EVENT_COOLDOWN_PER_TYPE: float = 600.0  # 10 perc típusonként

# === Endgame / Paragon ===
const PARAGON_HP_PER_POINT: int = 1
const PARAGON_DAMAGE_PER_10_POINTS: float = 0.005  # 0.5%
const PARAGON_MAGIC_FIND_PER_5_POINTS: float = 0.003  # 0.3%

# === Nightmare dungeon scaling (Plan 21 §2.9) ===
const NIGHTMARE_SCALING: Dictionary = {
	1: {"enemy_hp": 0.25, "enemy_damage": 0.25, "magic_find": 0.25},
	2: {"enemy_hp": 0.60, "enemy_damage": 0.50, "magic_find": 0.60},
	3: {"enemy_hp": 1.00, "enemy_damage": 0.80, "magic_find": 1.00},
	4: {"enemy_hp": 1.80, "enemy_damage": 1.20, "magic_find": 1.80},
	5: {"enemy_hp": 3.00, "enemy_damage": 2.00, "magic_find": 3.00},
}

# Enhancement success rate-ek (+1 → +10)
const ENHANCEMENT_SUCCESS_RATES: Array[float] = [
	1.0, 1.0, 1.0, 1.0, 1.0,  # +1 to +5: 100%
	0.8, 0.6, 0.4,             # +6 to +8
	0.2,                       # +9
	0.1                        # +10
]

# Enhancement cost szorzók (gold, material)
const ENHANCEMENT_GOLD_COSTS: Array[int] = [
	50, 80, 120, 180, 300,     # +1 to +5
	500, 800, 1200,            # +6 to +8
	1600,                      # +9
	2000                       # +10
]

const ENHANCEMENT_MATERIAL_COSTS: Array[int] = [
	5, 8, 12, 18, 25,
	35, 50, 70,
	85,
	100
]

# Gathering tool szorzók [speed, yield]
const TOOL_TIER_MULTIPLIERS: Dictionary = {
	Enums.ToolTier.BASIC: {"speed": 1.0, "yield": 1.0},
	Enums.ToolTier.IRON: {"speed": 1.3, "yield": 1.2},
	Enums.ToolTier.STEEL: {"speed": 1.5, "yield": 1.5},
	Enums.ToolTier.LEGENDARY: {"speed": 2.0, "yield": 2.0},
}

# Gathering node adatok: {yield_min, yield_max, respawn_sec}
const GATHERING_NODE_DATA: Dictionary = {
	Enums.GatheringNodeType.WOOD: {"yield_min": 3, "yield_max": 8, "respawn": 300, "channel_time": 2.0},
	Enums.GatheringNodeType.STONE: {"yield_min": 3, "yield_max": 8, "respawn": 300, "channel_time": 2.5},
	Enums.GatheringNodeType.ORE: {"yield_min": 2, "yield_max": 5, "respawn": 480, "channel_time": 3.0},
	Enums.GatheringNodeType.HERB: {"yield_min": 1, "yield_max": 4, "respawn": 180, "channel_time": 1.5},
	Enums.GatheringNodeType.CRYSTAL: {"yield_min": 1, "yield_max": 3, "respawn": 600, "channel_time": 3.0},
	Enums.GatheringNodeType.DARK_ROOT: {"yield_min": 1, "yield_max": 3, "respawn": 480, "channel_time": 2.5},
	Enums.GatheringNodeType.BONE: {"yield_min": 2, "yield_max": 5, "respawn": 300, "channel_time": 2.0},
	Enums.GatheringNodeType.EMBER_COAL: {"yield_min": 2, "yield_max": 4, "respawn": 480, "channel_time": 2.5},
}

# Profession max level
const PROFESSION_MAX_LEVEL: int = 50
const MAX_GATHERING_PROFESSIONS: int = 2
const MAX_CRAFTING_PROFESSIONS: int = 2

# === Rarity színek ===
const RARITY_COLORS: Dictionary = {
	Enums.Rarity.COMMON: Color(0.8, 0.8, 0.8),        # Szürke
	Enums.Rarity.MAGIC: Color(0.0, 0.8, 0.0),         # Zöld (volt UNCOMMON)
	Enums.Rarity.RARE: Color(0.0, 0.4, 1.0),          # Kék
	Enums.Rarity.EPIC: Color(0.6, 0.0, 0.8),          # Lila
	Enums.Rarity.LEGENDARY: Color(1.0, 0.6, 0.0),     # Narancs
	Enums.Rarity.SET: Color(0.0, 0.9, 0.0),           # Zöld (set)
	Enums.Rarity.UNIQUE: Color(0.85, 0.5, 0.1),       # Sötét narancs
}

# === Gem színek ===
const GEM_COLORS: Dictionary = {
	Enums.GemType.RUBY: Color(0.9, 0.15, 0.15),       # Piros
	Enums.GemType.EMERALD: Color(0.1, 0.8, 0.2),      # Zöld
	Enums.GemType.SAPPHIRE: Color(0.15, 0.3, 0.9),    # Kék
	Enums.GemType.AMETHYST: Color(0.6, 0.1, 0.85),    # Lila
	Enums.GemType.TOPAZ: Color(0.95, 0.8, 0.1),       # Sárga
	Enums.GemType.DIAMOND: Color(0.9, 0.95, 1.0),     # Fehér
	Enums.GemType.LEGENDARY: Color(1.0, 0.6, 0.0),    # Narancs izzó
}

# === Gem tier nevek ===
const GEM_TIER_NAMES: Array[String] = [
	"Chipped", "Flawed", "Normal", "Flawless", "Perfect", "Radiant"
]

# === Class alap statisztikák (Level 1) ===
const CLASS_BASE_STATS: Dictionary = {
	Enums.PlayerClass.ASSASSIN: {
		"hp": 80,
		"mana": 60,
		"base_damage": 12,
		"speed": 130.0,
		"armor": 5,
		"crit_chance": 0.08,
		"crit_multiplier": 1.5,
		"mana_per_level": 3,
		"hp_per_level": 5,
	},
	Enums.PlayerClass.TANK: {
		"hp": 150,
		"mana": 40,
		"base_damage": 8,
		"speed": 90.0,
		"armor": 15,
		"block_chance": 0.10,
		"threat_multiplier": 1.3,
		"mana_per_level": 2,
		"hp_per_level": 10,
	},
	Enums.PlayerClass.MAGE: {
		"hp": 60,
		"mana": 120,
		"base_damage": 15,
		"speed": 100.0,
		"armor": 3,
		"spell_crit": 0.06,
		"mana_regen": 3.0,
		"mana_per_level": 5,
		"hp_per_level": 3,
	},
}

# === XP tábla generálás ===
## Plan 16 képlet: floor(100 * (level ^ 1.8))
static func get_xp_for_level(level: int) -> int:
	if level <= 1:
		return 0
	return int(floor(BASE_XP_COEFFICIENT * pow(float(level), XP_EXPONENT)))

# === Dungeon ===
const DUNGEON_WIDTH: int = 80      # Dungeon szélesség tile-okban
const DUNGEON_HEIGHT: int = 60     # Dungeon magasság tile-okban
const DUNGEON_VISION_RADIUS: int = 8  # Fog of War sugár tile-okban
const DUNGEON_STAT_BONUS: float = 0.2  # +20% enemy stat dungeon-ben
const DUNGEON_ELITE_CHANCE: float = 0.15  # 15% elite esély dungeon-ben
const DUNGEON_MIMIC_CHANCE: float = 0.2   # 20% mimic esély treasure room-ban
const DUNGEON_SECRET_ROOM_CHANCE: float = 0.3  # 30% secret room generálás
const DUNGEON_TRAP_CORRIDOR_CHANCE: float = 0.1  # 10% csapda a folyosón
const DUNGEON_CHEST_CORRIDOR_CHANCE: float = 0.05  # 5% láda a folyosón

# Dungeon tier config: {rooms_min, rooms_max, floors, has_boss, boss_tier}
const DUNGEON_TIER_CONFIG: Dictionary = {
	1: {"rooms_min": 8, "rooms_max": 10, "floors": 1, "has_boss": true, "boss_tier": 1},
	2: {"rooms_min": 12, "rooms_max": 16, "floors": 1, "has_boss": true, "boss_tier": 2},
	3: {"rooms_min": 16, "rooms_max": 20, "floors": 2, "has_boss": true, "boss_tier": 2},
	4: {"rooms_min": 20, "rooms_max": 25, "floors": 3, "has_boss": true, "boss_tier": 4},
}

# Dungeon biome → difficulty mapping
const DUNGEON_BIOME_DIFFICULTY: Dictionary = {
	Enums.BiomeType.STARTING_MEADOW: 1,
	Enums.BiomeType.CURSED_FOREST: 3,
	Enums.BiomeType.DARK_SWAMP: 4,
	Enums.BiomeType.RUINS: 5,
	Enums.BiomeType.MOUNTAINS: 6,
	Enums.BiomeType.FROZEN_WASTES: 7,
	Enums.BiomeType.ASHLANDS: 8,
	Enums.BiomeType.PLAGUE_LANDS: 9,
}

# === Branch Passive Bonuses (Plan 21 §5.2) ===
# Per-point bonuses when allocating skills in a branch
const BRANCH_PASSIVES: Dictionary = {
	# Assassin
	Enums.SkillBranch.SHADOW: {"crit_chance": 0.01, "dodge_chance": 0.005},
	Enums.SkillBranch.POISON: {"dot_damage": 0.02, "dot_duration": 0.01},
	Enums.SkillBranch.BLOOD: {"lifesteal": 0.01, "hp_bonus": 0.02},
	# Tank
	Enums.SkillBranch.GUARDIAN: {"armor": 0.03, "block_chance": 0.01},
	Enums.SkillBranch.WARBRINGER: {"damage": 0.02, "threat_generation": 0.05},
	Enums.SkillBranch.PALADIN: {"heal_power": 0.02, "holy_damage": 0.015},
	# Mage
	Enums.SkillBranch.ARCANE: {"spell_damage": 0.03, "mana_cost_reduction": 0.01},
	Enums.SkillBranch.FROST: {"slow_effectiveness": 0.02, "freeze_duration": 0.01},
	Enums.SkillBranch.HOLY: {"heal_power": 0.03, "shield_strength": 0.02},
}

# === Boss Enrage Timers (Plan 21 §10.7) ===
const BOSS_ENRAGE_TIMERS: Dictionary = {
	1: 240.0,  # T1: ~4 min
	2: 360.0,  # T2: ~6 min
	3: 300.0,  # T3: 5 min
	4: 480.0,  # T4: 8 min
}

# === Boss HP Multiplayer Scaling (Plan 21 §3.4) ===
const BOSS_HP_MULTIPLAYER: Dictionary = {
	1: 1.0,
	2: 1.8,
	3: 2.5,
	4: 3.2,
}

# === Elite Enemy Scaling (Plan 21 §3.6) ===
const ELITE_HP_MULT: float = 3.0
const ELITE_DAMAGE_MULT: float = 1.5
const ELITE_ARMOR_MULT: float = 2.0
const ELITE_SPEED_MULT: float = 1.1
const ELITE_XP_MULT: float = 3.0
const ELITE_LOOT_CHANCE: float = 0.80
const ELITE_GOLD_MULT: float = 2.0
const NORMAL_LOOT_CHANCE: float = 0.30

# === Enemy Scaling Rates (Plan 21 §3.3) ===
const ENEMY_HP_SCALE_RATE: float = 0.15    # +15% per level
const ENEMY_DAMAGE_SCALE_RATE: float = 0.12  # +12% per level
const ENEMY_ARMOR_SCALE_RATE: float = 0.10  # +10% per level
const ENEMY_XP_SCALE_RATE: float = 0.20    # +20% per level

# === Multiplayer Enemy Scaling (Plan 21 §3.7) ===
const ENEMY_HP_PER_PLAYER: float = 0.5  # +50% HP per additional player

# === Consumable Values (Plan 21 §4.9) ===
const POTION_HP_SMALL: int = 50
const POTION_HP_MEDIUM: int = 150
const POTION_HP_LARGE: int = 400
const POTION_MP_SMALL: int = 30
const POTION_MP_MEDIUM: int = 80
const POTION_MP_LARGE: int = 200

# === Biome Level Ranges (Plan 21 §14.3) ===
const BIOME_LEVEL_RANGES: Dictionary = {
	Enums.BiomeType.STARTING_MEADOW: {"min": 1, "max": 8},
	Enums.BiomeType.CURSED_FOREST: {"min": 12, "max": 20},
	Enums.BiomeType.DARK_SWAMP: {"min": 28, "max": 36},
	Enums.BiomeType.RUINS: {"min": 6, "max": 14},
	Enums.BiomeType.MOUNTAINS: {"min": 24, "max": 32},
	Enums.BiomeType.FROZEN_WASTES: {"min": 18, "max": 26},
	Enums.BiomeType.ASHLANDS: {"min": 34, "max": 42},
	Enums.BiomeType.PLAGUE_LANDS: {"min": 42, "max": 50},
}

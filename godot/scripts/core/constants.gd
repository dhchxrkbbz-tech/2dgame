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
const SKILL_POINTS_PER_2_LEVELS: int = 1
const MAX_SKILL_POINTS: int = 25
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

# === Camera ===
const CAMERA_SMOOTHING_SPEED: float = 5.0
const CAMERA_ZOOM: Vector2 = Vector2(1.0, 1.0)

# === UI ===
const TOOLTIP_DELAY: float = 0.3
const DAMAGE_NUMBER_DURATION: float = 1.0
const DAMAGE_NUMBER_RISE: float = 50.0

# === XP rendszer ===
const BASE_XP_PER_LEVEL: int = 100
const XP_GROWTH_FACTOR: float = 1.15

# === Loot ===
const ITEM_PICKUP_RANGE: float = 48.0  # pixel

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
const SKILL_RESET_BASE_COST: int = 500

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
	Enums.Rarity.UNCOMMON: Color(0.0, 0.8, 0.0),      # Zöld
	Enums.Rarity.RARE: Color(0.0, 0.4, 1.0),          # Kék
	Enums.Rarity.EPIC: Color(0.6, 0.0, 0.8),          # Lila
	Enums.Rarity.LEGENDARY: Color(1.0, 0.6, 0.0),     # Narancs
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
static func get_xp_for_level(level: int) -> int:
	if level <= 1:
		return 0
	return int(BASE_XP_PER_LEVEL * pow(XP_GROWTH_FACTOR, level - 1))

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

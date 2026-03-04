## Globális enum definíciók az Ashenfall projekthez
class_name Enums

# === Játék állapotok ===
enum GameState {
	MENU,
	LOADING,
	PLAYING,
	PAUSED,
	GAME_OVER
}

# === Osztályok ===
enum PlayerClass {
	ASSASSIN,
	TANK,
	MAGE
}

# === Skill branch-ek ===
enum SkillBranch {
	# Assassin
	SHADOW,
	POISON,
	BLOOD,
	# Tank
	GUARDIAN,
	WARBRINGER,
	PALADIN,
	# Mage
	ARCANE,
	FROST,
	HOLY
}

# === Skill típusok ===
enum SkillType {
	PROJECTILE,
	AOE,
	MELEE,
	BUFF,
	DEBUFF,
	HEAL,
	SUMMON,
	TELEPORT,
	TOGGLE,
	PASSIVE,
	CHANNEL,
	TRANSFORMATION
}

# === Célzás típusok ===
enum TargetType {
	SELF,
	SINGLE_ENEMY,
	SINGLE_ALLY,
	AOE_GROUND,
	AOE_SELF,
	DIRECTIONAL,
	NONE
}

# === Sebzés típusok ===
enum DamageType {
	PHYSICAL,
	ARCANE,
	FROST,
	HOLY,
	POISON,
	BLOOD,
	SHADOW,
	TRUE_DAMAGE
}

# === Status effect típusok ===
enum EffectType {
	# DOT
	POISON_DOT,
	BURN_DOT,
	BLEED_DOT,
	# CC
	SLOW,
	ROOT,
	STUN,
	FREEZE,
	BLIND,
	# Buff
	ATTACK_SPEED_UP,
	DAMAGE_UP,
	ARMOR_UP,
	SPEED_UP,
	LIFESTEAL,
	SHIELD,
	HP_REGEN,
	MANA_REGEN,
	# Debuff
	ARMOR_DOWN,
	DAMAGE_DOWN,
	ACCURACY_DOWN,
	VULNERABILITY
}

# === Item rarity ===
enum Rarity {
	COMMON,
	MAGIC,       # Plan 21: MAGIC (volt UNCOMMON)
	RARE,
	EPIC,
	LEGENDARY,
	SET,         # Plan 21: Set item rarity
	UNIQUE       # Plan 21: Unique item rarity
}

# === Equipment slot-ok ===
enum EquipSlot {
	HELMET,
	CHEST,
	GLOVES,
	BOOTS,
	BELT,
	SHOULDERS,
	MAIN_HAND,
	OFF_HAND,
	AMULET,
	RING_1,
	RING_2,
	CAPE
}

# === Item típusok ===
enum ItemType {
	WEAPON,
	ARMOR,
	ACCESSORY,
	CONSUMABLE,
	MATERIAL,
	GEM,
	QUEST_ITEM
}

# === Enemy típusok ===
enum EnemyType {
	MELEE,
	RANGED,
	CASTER,
	ELITE,
	BOSS
}

# === Enemy al-típusok ===
enum EnemySubType {
	NORMAL = 0,
	CHARGER = 1,   # Charge-ol, nagy sebesség
	BRUTE = 2,     # Lassú, nagy damage + HP
	SWARMER = 3,   # Boids mozgás, gyors, alacsony HP
	SNIPER = 4,    # Nagyon nagy range, telegraph
}

# === Biome típusok ===
enum BiomeType {
	STARTING_MEADOW,
	CURSED_FOREST,
	DARK_SWAMP,
	RUINS,
	MOUNTAINS,
	FROZEN_WASTES,
	ASHLANDS,
	PLAGUE_LANDS
}

# === Időjárás ===
enum WeatherType {
	CLEAR,
	RAIN,
	STORM,
	FOG,
	SNOW,
	ASH_FALL
}

# === Notification típusok ===
enum NotificationType {
	INFO,
	WARNING,
	ERROR,
	LOOT,
	LEVEL_UP,
	ACHIEVEMENT
}

# === Scene transition típusok ===
enum TransitionType {
	FADE,
	SLIDE,
	NONE
}

# === Gem típusok ===
enum GemType {
	RUBY,
	SAPPHIRE,
	EMERALD,
	TOPAZ,
	AMETHYST,
	DIAMOND,
	LEGENDARY
}

# === Gem tier ===
enum GemTier {
	CHIPPED,
	FLAWED,
	NORMAL,
	FLAWLESS,
	PERFECT,
	RADIANT
}

# === Mozgás irányok ===
enum Direction {
	NORTH,
	NORTHEAST,
	EAST,
	SOUTHEAST,
	SOUTH,
	SOUTHWEST,
	WEST,
	NORTHWEST
}

# === Valuta típusok ===
enum CurrencyType {
	GOLD,
	DARK_ESSENCE,
	RELIC_FRAGMENT
}

# === Crafting station típusok ===
enum StationType {
	ANVIL,
	ALCHEMY_TABLE,
	ENCHANTING_TABLE,
	WORKBENCH,
	RUNE_ALTAR
}

# === Profession típusok ===
enum ProfessionType {
	# Gathering
	MINING,
	HERBALISM,
	WOODCUTTING,
	SCAVENGING,
	# Crafting
	BLACKSMITHING,
	ALCHEMY,
	ENCHANTING,
	ENGINEERING
}

# === Marketplace listing állapotok ===
enum ListingStatus {
	ACTIVE,
	SOLD,
	EXPIRED,
	CANCELLED
}

# === Gathering node típusok ===
enum GatheringNodeType {
	WOOD,
	STONE,
	ORE,
	HERB,
	CRYSTAL,
	DARK_ROOT,
	BONE,
	EMBER_COAL
}

# === Shop típusok ===
enum ShopType {
	GENERAL_STORE,
	BLACKSMITH,
	ALCHEMIST,
	ENCHANTER,
	RELIC_VENDOR,
	TRAVELING_MERCHANT
}

# === Gathering tool tier ===
enum ToolTier {
	BASIC,
	IRON,
	STEEL,
	LEGENDARY
}

# === Dungeon tier ===
enum DungeonTier {
	SMALL = 1,    # 8-10 szoba, 1 floor
	MEDIUM = 2,   # 12-16 szoba, 1 floor
	LARGE = 3,    # 16-20 szoba, 2 floor
	RAID = 4      # 20-25 szoba, 3 floor
}

# === Dungeon room típusok ===
enum DungeonRoomType {
	ENTRANCE,
	COMBAT,
	TREASURE,
	PUZZLE,
	TRAP,
	SAFE,
	BOSS,
	SECRET
}

# === Dungeon door states ===
enum DoorState {
	OPEN,
	CLOSED,
	LOCKED,
	SEALED
}

# === Achievement kategóriák ===
enum AchievementCategory {
	COMBAT,
	EXPLORATION,
	LOOT_ECONOMY,
	PROGRESSION,
	SOCIAL,
	STORY
}

# === World Event típusok ===
enum WorldEventType {
	CORRUPTION_SURGE,
	INVASION,
	WORLD_BOSS_SPAWN,
	TREASURE_HUNT,
	GATHERING_BLESSING,
	BLOOD_MOON
}

# === Nightmare szintek ===
enum NightmareTier {
	NORMAL = 0,
	NIGHTMARE_1 = 1,
	NIGHTMARE_2 = 2,
	NIGHTMARE_3 = 3,
	NIGHTMARE_4 = 4,
	NIGHTMARE_5 = 5
}

# === Nehézségi szintek ===
enum DifficultyLevel {
	NORMAL,
	HARD,
	NIGHTMARE,
	TORMENT
}

# === Puzzle types ===
enum PuzzleType {
	SWITCH_ORDER,
	PRESSURE_PLATE,
	LIGHT_BEAM,
	SYMBOL_MATCH,
	TIMED_CHALLENGE
}

# === Trap types ===
enum TrapType {
	SPIKE,
	POISON_GAS,
	FIRE_JET,
	ARROW,
	FALLING_ROCKS,
	PIT,
	CURSE_TOTEM
}

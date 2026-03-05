using UnityEngine;
using System.Collections.Generic;

namespace Ashenfall
{
    public static class Constants
    {
        // === Tile & Chunk ===
        public const int TileSize = 32;
        public const int ChunkSize = 16;
        public const int ChunkPixelSize = TileSize * ChunkSize; // 512

        // === Viewport ===
        public const int ViewportWidth = 640;
        public const int ViewportHeight = 360;

        // === Multiplayer ===
        public const int MaxPlayers = 4;
        public const int TickRate = 20;

        // === Player ===
        public const int MaxLevel = 50;
        public const int MaxSkillPoints = 49;

        // === Movement ===
        public const float BaseSpeedAssassin = 130f;
        public const float BaseSpeedTank = 90f;
        public const float BaseSpeedMage = 100f;

        // === Combat ===
        public const float GlobalCooldown = 0.5f;
        public const float CdrCap = 0.40f;
        public const int MinDamage = 1;
        public const float ArmorEffectiveness = 0.5f;
        public const float IFramesDuration = 0.3f;

        // === Dodge ===
        public const float DodgeSpeedMultiplier = 2.5f;
        public const float DodgeDuration = 0.3f;
        public const float DodgeCooldown = 0.8f;

        // === Camera ===
        public const float CameraSmoothingSpeed = 5f;

        // === UI ===
        public const float TooltipDelay = 0.3f;
        public const float DamageNumberDuration = 1f;
        public const float DamageNumberRise = 50f;

        // === XP (formula: floor(100 * level^1.8)) ===
        public const int BaseXpCoefficient = 100;
        public const float XpExponent = 1.8f;

        // === Stat growth per level ===
        public const int StatPointsPerLevel = 3;
        public const int SkillPointsPerLevel = 1;
        public const int HpPerLevelBase = 15;
        public const float HpPerVit = 2f;
        public const int ManaPerLevelBase = 8;
        public const float ManaPerInt = 1.5f;
        public const float DamageScaleStr = 0.5f;
        public const float DamageScaleDex = 0.5f;
        public const float DamageScaleInt = 0.8f;
        public const int RespecCostPerLevel = 1000;

        // === Loot ===
        public const float ItemPickupRange = 48f;

        // === Death & Respawn ===
        public const float DeathGoldPenaltyPercent = 0.05f;
        public const float RespawnTimer = 5f;
        public const float RespawnHpPercent = 0.5f;
        public const float RespawnManaPercent = 0.5f;
        public const float RespawnInvincibilityDuration = 3f;

        // === Combo ===
        public const float ComboTimeout = 3f;
        public const float CombatTimeout = 5f;
        public const float ComboXpMult3 = 1.1f;
        public const float ComboXpMult5 = 1.25f;
        public const float ComboXpMult10 = 1.5f;

        // === Mana regen ===
        public const float BaseManaRegenAssassin = 2f;
        public const float BaseManaRegenTank = 1.5f;
        public const float BaseManaRegenMage = 3f;

        // === Save ===
        public const float AutosaveInterval = 300f;
        public const int MaxSaveSlots = 3;

        // === Physics Layers (Unity layer indices) ===
        public const int LayerPlayerPhysics = 6;
        public const int LayerEnemyPhysics = 7;
        public const int LayerWall = 8;
        public const int LayerPlayerHitbox = 9;
        public const int LayerPlayerHurtbox = 10;
        public const int LayerEnemyHitbox = 11;
        public const int LayerEnemyHurtbox = 12;
        public const int LayerProjectile = 13;
        public const int LayerDetection = 14;
        public const int LayerInteraction = 15;

        // === Economy ===
        public const int InventoryDefaultSize = 30;
        public const int InventoryMaxSize = 60;
        public const int StashDefaultSize = 50;
        public const int StackLimitConsumable = 99;
        public const int StackLimitMaterial = 99;
        public const int StackLimitGear = 1;
        public const float NpcSellMultiplier = 0.35f;
        public const float NpcBuyMultiplier = 1f;
        public const float MarketplaceListingFee = 0.02f;
        public const float MarketplaceTransactionFee = 0.05f;
        public const int MarketplaceListingDuration = 172800; // 48h

        // === Gems ===
        public const int GemInsertCost = 0;
        public const int GemRemoveCost = 200;
        public const int GemRemoveCostPerTier = 100;
        public const int GemLegendaryRemoveCost = 2000;
        public const int GemCombineCount = 3;
        public const int GemAddSocketBaseCost = 500;
        public const int GemAddSocketDarkEssence = 1;
        public const float GemMatchingBonus = 0.20f;
        public const float GemRainbowBonus = 0.05f;
        public const int GemRainbowMinTypes = 3;
        public const int GemSellPriceMultiplier = 50;
        public const float GemDropNormalEnemy = 0.05f;
        public const float GemDropEliteEnemy = 0.15f;
        public const float GemDropDungeonChest = 0.10f;
        public const float GemDropSecretRoomLegendary = 0.01f;
        public const float GemMiningChanceMountains = 0.20f;
        public const float GemMiningChanceOther = 0.05f;
        public const float GemMiningQualityPerLevel = 0.10f;

        public static readonly int[] GemCombineGoldCosts = { 50, 200, 500, 1500, 5000 };
        public static readonly bool[] GemCombineNeedsRelic = { false, false, false, false, true };

        // === Professions ===
        public const int ProfessionMaxLevel = 50;
        public const int MaxGatheringProfessions = 2;
        public const int MaxCraftingProfessions = 2;

        // === Fast Travel ===
        public const int FastTravelBaseCost = 20;
        public const int FastTravelCostPerChunk = 2;
        public const float FastTravelCooldown = 30f;
        public const float FastTravelTeleportDuration = 2f;
        public const int SkillResetBaseCost = 500;
        public const int RepairCostPerLevel = 5;

        // === Achievement ===
        public const float AchievementPopupDuration = 3f;

        // === World Events ===
        public const float WorldEventMinInterval = 1800f;
        public const float WorldEventMaxInterval = 3600f;
        public const float WorldEventCooldownPerType = 600f;

        // === Endgame / Paragon ===
        public const int ParagonHpPerPoint = 1;
        public const float ParagonDamagePer10Points = 0.005f;
        public const float ParagonMagicFindPer5Points = 0.003f;

        // === Dungeon ===
        public const int DungeonWidth = 80;
        public const int DungeonHeight = 60;
        public const int DungeonVisionRadius = 8;
        public const float DungeonStatBonus = 0.2f;
        public const float DungeonEliteChance = 0.15f;
        public const float DungeonMimicChance = 0.2f;
        public const float DungeonSecretRoomChance = 0.3f;
        public const float DungeonTrapCorridorChance = 0.1f;
        public const float DungeonChestCorridorChance = 0.05f;

        // === Elite Enemy ===
        public const float EliteHpMult = 3f;
        public const float EliteDamageMult = 1.5f;
        public const float EliteArmorMult = 2f;
        public const float EliteSpeedMult = 1.1f;
        public const float EliteXpMult = 3f;
        public const float EliteLootChance = 0.80f;
        public const float EliteGoldMult = 2f;
        public const float NormalLootChance = 0.30f;

        // === Enemy Scaling ===
        public const float EnemyHpScaleRate = 0.15f;
        public const float EnemyDamageScaleRate = 0.12f;
        public const float EnemyArmorScaleRate = 0.10f;
        public const float EnemyXpScaleRate = 0.20f;
        public const float EnemyHpPerPlayer = 0.5f;

        // === Consumables ===
        public const int PotionHpSmall = 50;
        public const int PotionHpMedium = 150;
        public const int PotionHpLarge = 400;
        public const int PotionMpSmall = 30;
        public const int PotionMpMedium = 80;
        public const int PotionMpLarge = 200;

        // === Enhancement ===
        public static readonly float[] EnhancementSuccessRates =
            { 1f, 1f, 1f, 1f, 1f, 0.8f, 0.6f, 0.4f, 0.2f, 0.1f };
        public static readonly int[] EnhancementGoldCosts =
            { 50, 80, 120, 180, 300, 500, 800, 1200, 1600, 2000 };
        public static readonly int[] EnhancementMaterialCosts =
            { 5, 8, 12, 18, 25, 35, 50, 70, 85, 100 };

        // === Rarity Colors ===
        public static readonly Dictionary<Rarity, Color> RarityColors = new()
        {
            { Rarity.Common, new Color(0.8f, 0.8f, 0.8f) },
            { Rarity.Uncommon, new Color(0f, 0.8f, 0f) },
            { Rarity.Rare, new Color(0f, 0.4f, 1f) },
            { Rarity.Epic, new Color(0.6f, 0f, 0.8f) },
            { Rarity.Legendary, new Color(1f, 0.6f, 0f) },
            { Rarity.Set, new Color(0f, 0.9f, 0f) },
            { Rarity.Unique, new Color(0.85f, 0.5f, 0.1f) }
        };

        // === Gem Colors ===
        public static readonly Dictionary<GemType, Color> GemColors = new()
        {
            { GemType.Ruby, new Color(0.9f, 0.15f, 0.15f) },
            { GemType.Emerald, new Color(0.1f, 0.8f, 0.2f) },
            { GemType.Sapphire, new Color(0.15f, 0.3f, 0.9f) },
            { GemType.Amethyst, new Color(0.6f, 0.1f, 0.85f) },
            { GemType.Topaz, new Color(0.95f, 0.8f, 0.1f) },
            { GemType.Diamond, new Color(0.9f, 0.95f, 1f) },
            { GemType.Legendary, new Color(1f, 0.6f, 0f) }
        };

        public static readonly string[] GemTierNames =
            { "Chipped", "Flawed", "Normal", "Flawless", "Perfect", "Radiant" };

        // === Biome Level Ranges ===
        public static readonly Dictionary<BiomeType, (int min, int max)> BiomeLevelRanges = new()
        {
            { BiomeType.StartingMeadow, (1, 8) },
            { BiomeType.Ruins, (6, 14) },
            { BiomeType.CursedForest, (12, 20) },
            { BiomeType.FrozenWastes, (18, 26) },
            { BiomeType.Mountains, (24, 32) },
            { BiomeType.DarkSwamp, (28, 36) },
            { BiomeType.Ashlands, (34, 42) },
            { BiomeType.PlagueLands, (42, 50) }
        };

        // === Boss Enrage Timers ===
        public static readonly Dictionary<int, float> BossEnrageTimers = new()
        {
            { 1, 240f }, { 2, 360f }, { 3, 300f }, { 4, 480f }
        };

        // === Boss HP Multiplayer Scaling ===
        public static readonly Dictionary<int, float> BossHpMultiplayer = new()
        {
            { 1, 1f }, { 2, 1.8f }, { 3, 2.5f }, { 4, 3.2f }
        };

        // === Nightmare Scaling ===
        public static readonly Dictionary<int, (float enemyHp, float enemyDamage, float magicFind)> NightmareScaling = new()
        {
            { 1, (0.25f, 0.25f, 0.25f) },
            { 2, (0.60f, 0.50f, 0.60f) },
            { 3, (1.00f, 0.80f, 1.00f) },
            { 4, (1.80f, 1.20f, 1.80f) },
            { 5, (3.00f, 2.00f, 3.00f) }
        };

        // === XP Calculation ===
        public static int GetXpForLevel(int level)
        {
            if (level <= 1) return 0;
            return Mathf.FloorToInt(BaseXpCoefficient * Mathf.Pow(level, XpExponent));
        }
    }
}

namespace Ashenfall
{
    public enum GameState
    {
        Menu,
        Loading,
        Playing,
        Paused,
        GameOver
    }

    public enum PlayerClass
    {
        Assassin,
        Tank,
        Mage
    }

    public enum SkillBranch
    {
        // Assassin
        Shadow,
        Poison,
        Blood,
        // Tank
        Guardian,
        Warbringer,
        Paladin,
        // Mage
        Arcane,
        Frost,
        Holy
    }

    public enum SkillType
    {
        Projectile,
        Aoe,
        Melee,
        Buff,
        Debuff,
        Heal,
        Summon,
        Teleport,
        Toggle,
        Passive,
        Channel,
        Transformation
    }

    public enum TargetType
    {
        Self,
        SingleEnemy,
        SingleAlly,
        AoeGround,
        AoeSelf,
        Directional,
        None
    }

    public enum DamageType
    {
        Physical,
        Arcane,
        Frost,
        Holy,
        Poison,
        Blood,
        Shadow,
        TrueDamage,
        Fire,
        Ice,
        Lightning,
        Dark,
        Nature
    }

    public enum EffectType
    {
        // DOT
        PoisonDot,
        BurnDot,
        BleedDot,
        // CC
        Slow,
        Root,
        Stun,
        Freeze,
        Blind,
        // Buff
        AttackSpeedUp,
        DamageUp,
        ArmorUp,
        SpeedUp,
        Lifesteal,
        Shield,
        HpRegen,
        ManaRegen,
        // Debuff
        ArmorDown,
        DamageDown,
        AccuracyDown,
        Vulnerability,
        PoisonDebuff,
        Silence,
        Weakness
    }

    public enum Rarity
    {
        Common,
        Uncommon,
        Rare,
        Epic,
        Legendary,
        Set,
        Unique
    }

    public enum EquipSlot
    {
        Helmet,
        Chest,
        Gloves,
        Boots,
        Belt,
        Shoulders,
        MainHand,
        OffHand,
        Amulet,
        Ring1,
        Ring2,
        Cape
    }

    public enum ItemType
    {
        Weapon,
        Armor,
        Accessory,
        Consumable,
        Material,
        Gem,
        QuestItem
    }

    public enum EnemyType
    {
        Melee,
        Ranged,
        Caster,
        Elite,
        Boss,
        Swarm
    }

    public enum EnemySubType
    {
        Normal = 0,
        Charger = 1,
        Brute = 2,
        Swarmer = 3,
        Sniper = 4
    }

    public enum BiomeType
    {
        StartingMeadow,
        CursedForest,
        DarkSwamp,
        Ruins,
        Mountains,
        FrozenWastes,
        Ashlands,
        PlagueLands,
        VoidRift,
        AshMeadows,
        AncientRuins,
        HauntedMountains
    }

    public enum WeatherType
    {
        Clear,
        Rain,
        Storm,
        Fog,
        Snow,
        AshFall,
        Cloudy,
        AshStorm
    }

    public enum NotificationType
    {
        Info,
        Warning,
        Error,
        Loot,
        LevelUp,
        Achievement
    }

    public enum TransitionType
    {
        Fade,
        Slide,
        None
    }

    public enum GemType
    {
        Ruby,
        Sapphire,
        Emerald,
        Topaz,
        Amethyst,
        Diamond,
        Legendary
    }

    public enum GemTier
    {
        Chipped,
        Flawed,
        Normal,
        Flawless,
        Perfect,
        Radiant
    }

    public enum Direction
    {
        North,
        NorthEast,
        East,
        SouthEast,
        South,
        SouthWest,
        West,
        NorthWest
    }

    public enum CurrencyType
    {
        Gold,
        DarkEssence,
        RelicFragment
    }

    public enum StationType
    {
        Anvil,
        AlchemyTable,
        EnchantingTable,
        Workbench,
        RuneAltar
    }

    public enum ProfessionType
    {
        // Gathering
        Mining,
        Herbalism,
        Woodcutting,
        Scavenging,
        // Crafting
        Blacksmithing,
        Alchemy,
        Enchanting,
        Engineering
    }

    public enum ListingStatus
    {
        Active,
        Sold,
        Expired,
        Cancelled
    }

    public enum GatheringNodeType
    {
        Wood,
        Stone,
        Ore,
        Herb,
        Crystal,
        DarkRoot,
        Bone,
        EmberCoal
    }

    public enum ShopType
    {
        GeneralStore,
        Blacksmith,
        Alchemist,
        Enchanter,
        RelicVendor,
        TravelingMerchant
    }

    public enum ToolTier
    {
        Basic,
        Iron,
        Steel,
        Masterwork,
        Legendary
    }

    public enum DungeonTier
    {
        Small = 1,
        Medium = 2,
        Large = 3,
        Raid = 4
    }

    public enum DungeonRoomType
    {
        Entrance,
        Combat,
        Treasure,
        Puzzle,
        Trap,
        Safe,
        Boss,
        Secret
    }

    public enum DoorState
    {
        Open,
        Closed,
        Locked,
        Sealed
    }

    public enum AchievementCategory
    {
        Combat,
        Exploration,
        LootEconomy,
        Progression,
        Social,
        Story
    }

    public enum WorldEventType
    {
        CorruptionSurge,
        Invasion,
        WorldBossSpawn,
        TreasureHunt,
        GatheringBlessing,
        BloodMoon
    }

    public enum NightmareTier
    {
        Normal = 0,
        Nightmare1 = 1,
        Nightmare2 = 2,
        Nightmare3 = 3,
        Nightmare4 = 4,
        Nightmare5 = 5
    }

    public enum DifficultyLevel
    {
        Easy,
        Normal,
        Hard,
        Nightmare,
        Torment
    }

    public enum PuzzleType
    {
        SwitchOrder,
        PressurePlate,
        LightBeam,
        SymbolMatch,
        TimedChallenge
    }

    public enum TrapType
    {
        Spike,
        PoisonGas,
        FireJet,
        Arrow,
        FallingRocks,
        Pit,
        CurseTotem
    }

    public enum DayPhase
    {
        Dawn,
        Day,
        Dusk,
        Night
    }

    public enum NPCType
    {
        Merchant,
        QuestGiver,
        Service
    }
}

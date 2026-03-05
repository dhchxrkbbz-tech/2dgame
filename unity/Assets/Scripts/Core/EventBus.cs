using System;
using UnityEngine;

namespace Ashenfall
{
    /// <summary>
    /// Globális eseményrendszer – laza csatolás az alrendszerek között.
    /// Használat: EventBus.OnPlayerDied += handler;  /  EventBus.PlayerDied(player);
    /// </summary>
    public static class EventBus
    {
        // ============================================================
        //  Player
        // ============================================================
        public static event Action<GameObject> OnPlayerSpawned;
        public static event Action<GameObject> OnPlayerDied;
        public static event Action<GameObject, int> OnPlayerLeveledUp;
        public static event Action<GameObject, string> OnPlayerSkillUnlocked;
        public static event Action<PlayerClass> OnPlayerClassSelected;
        public static event Action<GameObject> OnPlayerStatsChanged;

        public static void PlayerSpawned(GameObject p) => OnPlayerSpawned?.Invoke(p);
        public static void PlayerDied(GameObject p) => OnPlayerDied?.Invoke(p);
        public static void PlayerLeveledUp(GameObject p, int lvl) => OnPlayerLeveledUp?.Invoke(p, lvl);
        public static void PlayerSkillUnlocked(GameObject p, string id) => OnPlayerSkillUnlocked?.Invoke(p, id);
        public static void PlayerClassSelected(PlayerClass c) => OnPlayerClassSelected?.Invoke(c);
        public static void PlayerStatsChanged(GameObject p) => OnPlayerStatsChanged?.Invoke(p);

        // ============================================================
        //  Combat
        // ============================================================
        public static event Action<GameObject, GameObject, float, DamageType> OnDamageDealt;
        public static event Action<GameObject, GameObject> OnEntityKilled;
        public static event Action<GameObject, EffectType, float> OnStatusEffectApplied;
        public static event Action<GameObject, EffectType> OnStatusEffectRemoved;
        public static event Action<GameObject, GameObject, float> OnCriticalHit;

        public static void DamageDealt(GameObject src, GameObject tgt, float amt, DamageType dt) => OnDamageDealt?.Invoke(src, tgt, amt, dt);
        public static void EntityKilled(GameObject killer, GameObject victim) => OnEntityKilled?.Invoke(killer, victim);
        public static void StatusEffectApplied(GameObject tgt, EffectType et, float dur) => OnStatusEffectApplied?.Invoke(tgt, et, dur);
        public static void StatusEffectRemoved(GameObject tgt, EffectType et) => OnStatusEffectRemoved?.Invoke(tgt, et);
        public static void CriticalHit(GameObject src, GameObject tgt, float amt) => OnCriticalHit?.Invoke(src, tgt, amt);

        // ============================================================
        //  Skill
        // ============================================================
        public static event Action<GameObject, string> OnSkillUsed;
        public static event Action<string, float> OnSkillCooldownStarted;
        public static event Action<string> OnSkillCooldownFinished;
        public static event Action OnSkillTreeOpened;
        public static event Action OnSkillTreeClosed;
        public static event Action<string, int> OnSkillPointAllocated;

        public static void SkillUsed(GameObject p, string id) => OnSkillUsed?.Invoke(p, id);
        public static void SkillCooldownStarted(string id, float dur) => OnSkillCooldownStarted?.Invoke(id, dur);
        public static void SkillCooldownFinished(string id) => OnSkillCooldownFinished?.Invoke(id);
        public static void SkillTreeOpened() => OnSkillTreeOpened?.Invoke();
        public static void SkillTreeClosed() => OnSkillTreeClosed?.Invoke();
        public static void SkillPointAllocated(string id, int rank) => OnSkillPointAllocated?.Invoke(id, rank);

        // ============================================================
        //  Loot & Items
        // ============================================================
        public static event Action<object, Vector2> OnItemDropped;
        public static event Action<object> OnItemPickedUp;
        public static event Action<GameObject, object, EquipSlot> OnItemEquipped;
        public static event Action<GameObject, EquipSlot> OnItemUnequipped;
        public static event Action<int> OnGoldCollected;

        public static void ItemDropped(object data, Vector2 pos) => OnItemDropped?.Invoke(data, pos);
        public static void ItemPickedUp(object inst) => OnItemPickedUp?.Invoke(inst);
        public static void ItemEquipped(GameObject p, object data, EquipSlot s) => OnItemEquipped?.Invoke(p, data, s);
        public static void ItemUnequipped(GameObject p, EquipSlot s) => OnItemUnequipped?.Invoke(p, s);
        public static void GoldCollected(int amt) => OnGoldCollected?.Invoke(amt);

        // ============================================================
        //  Economy
        // ============================================================
        public static event Action<GameObject, int> OnGoldChanged;
        public static event Action<CurrencyType, int> OnCurrencyChanged;
        public static event Action<int> OnDarkEssenceChanged;
        public static event Action<int> OnRelicFragmentsChanged;

        public static void GoldChanged(GameObject p, int amt) => OnGoldChanged?.Invoke(p, amt);
        public static void CurrencyChanged(CurrencyType t, int amt) => OnCurrencyChanged?.Invoke(t, amt);
        public static void DarkEssenceChanged(int amt) => OnDarkEssenceChanged?.Invoke(amt);
        public static void RelicFragmentsChanged(int amt) => OnRelicFragmentsChanged?.Invoke(amt);

        // ============================================================
        //  Inventory
        // ============================================================
        public static event Action OnInventoryChanged;
        public static event Action OnInventoryFull;
        public static event Action OnStashChanged;
        public static event Action<EquipSlot> OnEquipmentChanged;

        public static void InventoryChanged() => OnInventoryChanged?.Invoke();
        public static void InventoryFull() => OnInventoryFull?.Invoke();
        public static void StashChanged() => OnStashChanged?.Invoke();
        public static void EquipmentChanged(EquipSlot s) => OnEquipmentChanged?.Invoke(s);

        // ============================================================
        //  Crafting & Upgrade
        // ============================================================
        public static event Action<string> OnCraftingStarted;
        public static event Action<string, bool> OnCraftingCompleted;
        public static event Action<string, int, bool> OnEnhancementAttempted;
        public static event Action<string, GemType> OnGemSocketed;
        public static event Action<string, int> OnGemRemoved;

        public static void CraftingStarted(string id) => OnCraftingStarted?.Invoke(id);
        public static void CraftingCompleted(string id, bool ok) => OnCraftingCompleted?.Invoke(id, ok);
        public static void EnhancementAttempted(string uuid, int lvl, bool ok) => OnEnhancementAttempted?.Invoke(uuid, lvl, ok);
        public static void GemSocketed(string uuid, GemType gt) => OnGemSocketed?.Invoke(uuid, gt);
        public static void GemRemoved(string uuid, int idx) => OnGemRemoved?.Invoke(uuid, idx);

        // ============================================================
        //  World
        // ============================================================
        public static event Action<Vector2Int> OnChunkLoaded;
        public static event Action<Vector2Int> OnChunkUnloaded;
        public static event Action<GameObject, BiomeType> OnBiomeEntered;
        public static event Action<bool> OnDayNightChanged;
        public static event Action<WeatherType> OnWeatherChanged;

        public static void ChunkLoaded(Vector2Int pos) => OnChunkLoaded?.Invoke(pos);
        public static void ChunkUnloaded(Vector2Int pos) => OnChunkUnloaded?.Invoke(pos);
        public static void BiomeEntered(GameObject p, BiomeType b) => OnBiomeEntered?.Invoke(p, b);
        public static void DayNightChanged(bool isNight) => OnDayNightChanged?.Invoke(isNight);
        public static void WeatherChanged(WeatherType w) => OnWeatherChanged?.Invoke(w);

        // ============================================================
        //  Dungeon
        // ============================================================
        public static event Action<object> OnDungeonEntered;
        public static event Action OnDungeonExited;
        public static event Action<int> OnRoomCleared;
        public static event Action<int, int> OnDungeonRoomEntered;
        public static event Action<int> OnDungeonRoomSealed;
        public static event Action<int> OnDungeonRoomUnsealed;
        public static event Action<string, Vector2> OnDungeonTrapTriggered;
        public static event Action<string, int> OnDungeonPuzzleSolved;
        public static event Action<int, int> OnDungeonWaveStarted;
        public static event Action<int, int> OnDungeonWaveCompleted;

        public static void DungeonEntered(object data) => OnDungeonEntered?.Invoke(data);
        public static void DungeonExited() => OnDungeonExited?.Invoke();
        public static void RoomCleared(int idx) => OnRoomCleared?.Invoke(idx);
        public static void DungeonRoomEntered(int idx, int type) => OnDungeonRoomEntered?.Invoke(idx, type);
        public static void DungeonRoomSealed(int idx) => OnDungeonRoomSealed?.Invoke(idx);
        public static void DungeonRoomUnsealed(int idx) => OnDungeonRoomUnsealed?.Invoke(idx);
        public static void DungeonTrapTriggered(string t, Vector2 pos) => OnDungeonTrapTriggered?.Invoke(t, pos);
        public static void DungeonPuzzleSolved(string t, int idx) => OnDungeonPuzzleSolved?.Invoke(t, idx);
        public static void DungeonWaveStarted(int room, int wave) => OnDungeonWaveStarted?.Invoke(room, wave);
        public static void DungeonWaveCompleted(int room, int wave) => OnDungeonWaveCompleted?.Invoke(room, wave);

        // ============================================================
        //  Boss
        // ============================================================
        public static event Action<string> OnBossFightStarted;
        public static event Action<string, int> OnBossPhaseChanged;
        public static event Action<string> OnBossDefeated;
        public static event Action<string> OnBossEnraged;

        public static void BossFightStarted(string id) => OnBossFightStarted?.Invoke(id);
        public static void BossPhaseChanged(string id, int phase) => OnBossPhaseChanged?.Invoke(id, phase);
        public static void BossDefeated(string id) => OnBossDefeated?.Invoke(id);
        public static void BossEnraged(string id) => OnBossEnraged?.Invoke(id);

        // ============================================================
        //  Quest
        // ============================================================
        public static event Action<string> OnQuestAccepted;
        public static event Action<string> OnQuestCompleted;
        public static event Action<string, int, int, int> OnQuestProgressUpdated;
        public static event Action<string> OnQuestTurnedIn;
        public static event Action<string> OnQuestAbandoned;

        public static void QuestAccepted(string id) => OnQuestAccepted?.Invoke(id);
        public static void QuestCompleted(string id) => OnQuestCompleted?.Invoke(id);
        public static void QuestProgressUpdated(string id, int obj, int cur, int tgt) => OnQuestProgressUpdated?.Invoke(id, obj, cur, tgt);
        public static void QuestTurnedIn(string id) => OnQuestTurnedIn?.Invoke(id);
        public static void QuestAbandoned(string id) => OnQuestAbandoned?.Invoke(id);

        // ============================================================
        //  Dialogue
        // ============================================================
        public static event Action<string> OnDialogueStarted;
        public static event Action<string> OnDialogueEnded;

        public static void DialogueStarted(string npcId) => OnDialogueStarted?.Invoke(npcId);
        public static void DialogueEnded(string npcId) => OnDialogueEnded?.Invoke(npcId);

        // ============================================================
        //  Multiplayer
        // ============================================================
        public static event Action<int> OnPlayerConnected;
        public static event Action<int> OnPlayerDisconnected;
        public static event Action<string, string> OnChatMessageReceived;

        public static void PlayerConnected(int peerId) => OnPlayerConnected?.Invoke(peerId);
        public static void PlayerDisconnected(int peerId) => OnPlayerDisconnected?.Invoke(peerId);
        public static void ChatMessageReceived(string sender, string msg) => OnChatMessageReceived?.Invoke(sender, msg);

        // ============================================================
        //  UI & Notification
        // ============================================================
        public static event Action<string, NotificationType> OnShowNotification;
        public static event Action<object> OnTooltipRequested;
        public static event Action OnTooltipHidden;
        public static event Action<string> OnScreenOpened;
        public static event Action<string> OnScreenClosed;
        public static event Action OnHudUpdateRequested;

        public static void ShowNotification(string text, NotificationType t) => OnShowNotification?.Invoke(text, t);
        public static void TooltipRequested(object data) => OnTooltipRequested?.Invoke(data);
        public static void TooltipHidden() => OnTooltipHidden?.Invoke();
        public static void ScreenOpened(string name) => OnScreenOpened?.Invoke(name);
        public static void ScreenClosed(string name) => OnScreenClosed?.Invoke(name);
        public static void HudUpdateRequested() => OnHudUpdateRequested?.Invoke();

        // ============================================================
        //  XP
        // ============================================================
        public static event Action<GameObject, int> OnXpGained;
        public static event Action<int, int> OnXpBarUpdated;

        public static void XpGained(GameObject p, int amt) => OnXpGained?.Invoke(p, amt);
        public static void XpBarUpdated(int cur, int max) => OnXpBarUpdated?.Invoke(cur, max);

        // ============================================================
        //  Achievement
        // ============================================================
        public static event Action<string, object> OnAchievementUnlocked;
        public static event Action<string, int, int> OnAchievementProgressUpdated;

        public static void AchievementUnlocked(string id, object data) => OnAchievementUnlocked?.Invoke(id, data);
        public static void AchievementProgressUpdated(string id, int cur, int tgt) => OnAchievementProgressUpdated?.Invoke(id, cur, tgt);

        // ============================================================
        //  World Events
        // ============================================================
        public static event Action<int, object> OnWorldEventStarted;
        public static event Action<int, object> OnWorldEventEnded;

        public static void WorldEventStarted(int type, object data) => OnWorldEventStarted?.Invoke(type, data);
        public static void WorldEventEnded(int type, object data) => OnWorldEventEnded?.Invoke(type, data);

        // ============================================================
        //  Endgame / Paragon
        // ============================================================
        public static event Action<int> OnNightmareTierChanged;
        public static event Action<int> OnParagonLevelGained;

        public static void NightmareTierChanged(int tier) => OnNightmareTierChanged?.Invoke(tier);
        public static void ParagonLevelGained(int lvl) => OnParagonLevelGained?.Invoke(lvl);

        // ============================================================
        //  Fast Travel
        // ============================================================
        public static event Action<string, string> OnWaypointDiscovered;
        public static event Action<string> OnFastTravelStarted;
        public static event Action<string> OnFastTravelCompleted;

        public static void WaypointDiscovered(string id, string name) => OnWaypointDiscovered?.Invoke(id, name);
        public static void FastTravelStarted(string destId) => OnFastTravelStarted?.Invoke(destId);
        public static void FastTravelCompleted(string destId) => OnFastTravelCompleted?.Invoke(destId);

        // ============================================================
        //  Audio
        // ============================================================
        public static event Action<string> OnPlaySfx;
        public static event Action<string> OnPlayMusic;
        public static event Action OnStopMusic;

        public static void PlaySfx(string name) => OnPlaySfx?.Invoke(name);
        public static void PlayMusic(string name) => OnPlayMusic?.Invoke(name);
        public static void StopMusic() => OnStopMusic?.Invoke();

        // ============================================================
        //  Save / Load
        // ============================================================
        public static event Action<int> OnGameSaved;
        public static event Action<int> OnGameLoaded;

        public static void GameSaved(int slot) => OnGameSaved?.Invoke(slot);
        public static void GameLoaded(int slot) => OnGameLoaded?.Invoke(slot);
    }
}

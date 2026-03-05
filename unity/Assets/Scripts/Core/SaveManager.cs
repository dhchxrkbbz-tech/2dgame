using System;
using System.IO;
using UnityEngine;
using Newtonsoft.Json;

namespace Ashenfall
{
    [Serializable]
    public class SaveData
    {
        public string playerName = "";
        public PlayerClass playerClass = PlayerClass.Assassin;
        public int level = 1;
        public int xp;
        public int gold;
        public int darkEssence;
        public int relicFragments;
        public float playTimeSeconds;
        public string currentBiome = "StartingMeadow";
        public float positionX;
        public float positionY;
        public string timestamp;

        // Extensible: további adatok itt bővíthetők
    }

    public class SaveManager : SingletonBase<SaveManager>
    {
        private float _autosaveTimer;
        private int _currentSlot = -1;

        public SaveData CurrentSave { get; private set; }

        private string GetSavePath(int slot) =>
            Path.Combine(Application.persistentDataPath, $"save_slot_{slot}.json");

        private string AutosavePath =>
            Path.Combine(Application.persistentDataPath, "autosave.json");

        protected override void OnSingletonAwake()
        {
            CurrentSave = new SaveData();
        }

        private void Update()
        {
            if (GameManager.Instance == null) return;
            if (GameManager.Instance.CurrentState != GameState.Playing) return;

            CurrentSave.playTimeSeconds += Time.unscaledDeltaTime;

            _autosaveTimer += Time.unscaledDeltaTime;
            if (_autosaveTimer >= Constants.AutosaveInterval)
            {
                _autosaveTimer = 0f;
                Autosave();
            }
        }

        public bool Save(int slot)
        {
            if (slot < 0 || slot >= Constants.MaxSaveSlots) return false;

            CurrentSave.timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            var json = JsonConvert.SerializeObject(CurrentSave, Formatting.Indented);

            try
            {
                File.WriteAllText(GetSavePath(slot), json);
                _currentSlot = slot;
                EventBus.GameSaved(slot);
                Debug.Log($"[SaveManager] Slot {slot} mentve.");
                return true;
            }
            catch (Exception e)
            {
                Debug.LogError($"[SaveManager] Mentés hiba slot {slot}: {e.Message}");
                return false;
            }
        }

        public bool Load(int slot)
        {
            if (slot < 0 || slot >= Constants.MaxSaveSlots) return false;

            var path = GetSavePath(slot);
            if (!File.Exists(path)) return false;

            try
            {
                var json = File.ReadAllText(path);
                CurrentSave = JsonConvert.DeserializeObject<SaveData>(json);
                _currentSlot = slot;
                EventBus.GameLoaded(slot);
                Debug.Log($"[SaveManager] Slot {slot} betöltve.");
                return true;
            }
            catch (Exception e)
            {
                Debug.LogError($"[SaveManager] Betöltés hiba slot {slot}: {e.Message}");
                return false;
            }
        }

        public void Autosave()
        {
            CurrentSave.timestamp = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            var json = JsonConvert.SerializeObject(CurrentSave, Formatting.Indented);
            try
            {
                File.WriteAllText(AutosavePath, json);
                Debug.Log("[SaveManager] Autosave kész.");
            }
            catch (Exception e)
            {
                Debug.LogError($"[SaveManager] Autosave hiba: {e.Message}");
            }
        }

        public bool SlotExists(int slot) => File.Exists(GetSavePath(slot));

        public SaveData PeekSlot(int slot)
        {
            var path = GetSavePath(slot);
            if (!File.Exists(path)) return null;

            try
            {
                var json = File.ReadAllText(path);
                return JsonConvert.DeserializeObject<SaveData>(json);
            }
            catch
            {
                return null;
            }
        }

        public bool DeleteSlot(int slot)
        {
            var path = GetSavePath(slot);
            if (!File.Exists(path)) return false;

            File.Delete(path);
            Debug.Log($"[SaveManager] Slot {slot} törölve.");
            return true;
        }

        public void NewGame(string playerName, PlayerClass playerClass)
        {
            CurrentSave = new SaveData
            {
                playerName = playerName,
                playerClass = playerClass,
                level = 1,
                xp = 0,
                gold = 0,
                darkEssence = 0,
                relicFragments = 0,
                playTimeSeconds = 0f,
                currentBiome = "StartingMeadow",
                positionX = 0f,
                positionY = 0f
            };
            _currentSlot = -1;
        }
    }
}

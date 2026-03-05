using System.Collections.Generic;
using UnityEngine;

namespace Ashenfall
{
    public class LocalizationManager : SingletonBase<LocalizationManager>
    {
        private Dictionary<string, Dictionary<string, string>> _translations = new();
        private string _currentLanguage = "hu";

        private const string PrefKeyLanguage = "settings_language";
        private const string TranslationsPath = "Data/translations";

        public string CurrentLanguage => _currentLanguage;

        protected override void OnSingletonAwake()
        {
            _currentLanguage = PlayerPrefs.GetString(PrefKeyLanguage, "hu");
            LoadTranslations();
        }

        private void LoadTranslations()
        {
            _translations.Clear();

            var csvAsset = Resources.Load<TextAsset>("Data/translations");
            if (csvAsset == null)
            {
                // Fallback: try Localization folder
                csvAsset = Resources.Load<TextAsset>("../Localization/translations");
            }

            if (csvAsset == null)
            {
                Debug.LogWarning("[LocalizationManager] translations.csv not found in Resources.");
                return;
            }

            ParseCsv(csvAsset.text);
            Debug.Log($"[LocalizationManager] {_translations.Count} kulcs betöltve, nyelv: {_currentLanguage}");
        }

        private void ParseCsv(string csvText)
        {
            var lines = csvText.Split('\n');
            if (lines.Length < 2) return;

            // Header: keys,hu,en
            var headers = ParseCsvLine(lines[0]);
            var langIndices = new Dictionary<string, int>();
            for (int i = 1; i < headers.Length; i++)
            {
                var lang = headers[i].Trim().ToLower();
                if (!string.IsNullOrEmpty(lang))
                    langIndices[lang] = i;
            }

            for (int i = 1; i < lines.Length; i++)
            {
                var line = lines[i].Trim();
                if (string.IsNullOrEmpty(line)) continue;

                var cols = ParseCsvLine(line);
                if (cols.Length < 2) continue;

                var key = cols[0].Trim();
                if (string.IsNullOrEmpty(key)) continue;

                if (!_translations.ContainsKey(key))
                    _translations[key] = new Dictionary<string, string>();

                foreach (var kvp in langIndices)
                {
                    if (kvp.Value < cols.Length)
                        _translations[key][kvp.Key] = cols[kvp.Value].Trim();
                }
            }
        }

        private string[] ParseCsvLine(string line)
        {
            var result = new List<string>();
            bool inQuotes = false;
            var current = new System.Text.StringBuilder();

            for (int i = 0; i < line.Length; i++)
            {
                char c = line[i];
                if (c == '"')
                {
                    inQuotes = !inQuotes;
                }
                else if (c == ',' && !inQuotes)
                {
                    result.Add(current.ToString());
                    current.Clear();
                }
                else
                {
                    current.Append(c);
                }
            }
            result.Add(current.ToString());
            return result.ToArray();
        }

        public string Translate(string key)
        {
            if (_translations.TryGetValue(key, out var langs))
            {
                if (langs.TryGetValue(_currentLanguage, out var text))
                    return text;
                if (langs.TryGetValue("en", out var fallback))
                    return fallback;
            }
            return $"[{key}]";
        }

        /// <summary>Shorthand: LocalizationManager.Instance.T("KEY")</summary>
        public string T(string key) => Translate(key);

        public void SetLanguage(string langCode)
        {
            _currentLanguage = langCode.ToLower();
            PlayerPrefs.SetString(PrefKeyLanguage, _currentLanguage);
            PlayerPrefs.Save();
            Debug.Log($"[LocalizationManager] Nyelv váltva: {_currentLanguage}");
        }

        public string[] GetAvailableLanguages()
        {
            var langs = new HashSet<string>();
            foreach (var kvp in _translations)
            {
                foreach (var lang in kvp.Value.Keys)
                    langs.Add(lang);
            }
            var result = new string[langs.Count];
            langs.CopyTo(result);
            return result;
        }
    }
}

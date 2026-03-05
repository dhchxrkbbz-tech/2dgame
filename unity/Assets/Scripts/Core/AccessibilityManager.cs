using UnityEngine;

namespace Ashenfall
{
    public enum ColorblindMode
    {
        None,
        Protanopia,
        Deuteranopia,
        Tritanopia
    }

    public class AccessibilityManager : SingletonBase<AccessibilityManager>
    {
        // === Settings ===
        public ColorblindMode ColorblindMode { get; private set; } = ColorblindMode.None;
        public float TextSizeMultiplier { get; private set; } = 1f;
        public bool ScreenShakeEnabled { get; private set; } = true;
        public bool ShowDamageNumbers { get; private set; } = true;
        public bool ShowHealthBars { get; private set; } = true;
        public bool ShowTutorials { get; private set; } = true;
        public float GameSpeed { get; private set; } = 1f;
        public bool SubtitlesEnabled { get; private set; } = true;
        public bool AutoAimEnabled { get; private set; } = false;

        private const string PrefKeyColorblind = "accessibility_colorblind";
        private const string PrefKeyTextSize = "accessibility_textsize";
        private const string PrefKeyScreenShake = "accessibility_screenshake";
        private const string PrefKeyDamageNumbers = "accessibility_damagenumbers";
        private const string PrefKeyHealthBars = "accessibility_healthbars";
        private const string PrefKeyTutorials = "accessibility_tutorials";
        private const string PrefKeyGameSpeed = "accessibility_gamespeed";
        private const string PrefKeySubtitles = "accessibility_subtitles";
        private const string PrefKeyAutoAim = "accessibility_autoaim";

        protected override void OnSingletonAwake()
        {
            LoadSettings();
        }

        public void SetColorblindMode(ColorblindMode mode)
        {
            ColorblindMode = mode;
            PlayerPrefs.SetInt(PrefKeyColorblind, (int)mode);
            // TODO: Apply post-processing shader when implemented
        }

        public void SetTextSizeMultiplier(float mult)
        {
            TextSizeMultiplier = Mathf.Clamp(mult, 0.75f, 2f);
            PlayerPrefs.SetFloat(PrefKeyTextSize, TextSizeMultiplier);
        }

        public void SetScreenShake(bool enabled)
        {
            ScreenShakeEnabled = enabled;
            PlayerPrefs.SetInt(PrefKeyScreenShake, enabled ? 1 : 0);
        }

        public void SetShowDamageNumbers(bool enabled)
        {
            ShowDamageNumbers = enabled;
            PlayerPrefs.SetInt(PrefKeyDamageNumbers, enabled ? 1 : 0);
        }

        public void SetShowHealthBars(bool enabled)
        {
            ShowHealthBars = enabled;
            PlayerPrefs.SetInt(PrefKeyHealthBars, enabled ? 1 : 0);
        }

        public void SetShowTutorials(bool enabled)
        {
            ShowTutorials = enabled;
            PlayerPrefs.SetInt(PrefKeyTutorials, enabled ? 1 : 0);
        }

        public void SetGameSpeed(float speed)
        {
            GameSpeed = Mathf.Clamp(speed, 0.5f, 2f);
            PlayerPrefs.SetFloat(PrefKeyGameSpeed, GameSpeed);
            if (GameManager.Instance?.CurrentState == GameState.Playing)
                Time.timeScale = GameSpeed;
        }

        public void SetSubtitles(bool enabled)
        {
            SubtitlesEnabled = enabled;
            PlayerPrefs.SetInt(PrefKeySubtitles, enabled ? 1 : 0);
        }

        public void SetAutoAim(bool enabled)
        {
            AutoAimEnabled = enabled;
            PlayerPrefs.SetInt(PrefKeyAutoAim, enabled ? 1 : 0);
        }

        private void LoadSettings()
        {
            ColorblindMode = (ColorblindMode)PlayerPrefs.GetInt(PrefKeyColorblind, 0);
            TextSizeMultiplier = PlayerPrefs.GetFloat(PrefKeyTextSize, 1f);
            ScreenShakeEnabled = PlayerPrefs.GetInt(PrefKeyScreenShake, 1) == 1;
            ShowDamageNumbers = PlayerPrefs.GetInt(PrefKeyDamageNumbers, 1) == 1;
            ShowHealthBars = PlayerPrefs.GetInt(PrefKeyHealthBars, 1) == 1;
            ShowTutorials = PlayerPrefs.GetInt(PrefKeyTutorials, 1) == 1;
            GameSpeed = PlayerPrefs.GetFloat(PrefKeyGameSpeed, 1f);
            SubtitlesEnabled = PlayerPrefs.GetInt(PrefKeySubtitles, 1) == 1;
            AutoAimEnabled = PlayerPrefs.GetInt(PrefKeyAutoAim, 0) == 1;
        }

        public void ResetToDefaults()
        {
            SetColorblindMode(ColorblindMode.None);
            SetTextSizeMultiplier(1f);
            SetScreenShake(true);
            SetShowDamageNumbers(true);
            SetShowHealthBars(true);
            SetShowTutorials(true);
            SetGameSpeed(1f);
            SetSubtitles(true);
            SetAutoAim(false);
        }
    }
}

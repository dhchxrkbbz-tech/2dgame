using UnityEngine;
using UnityEngine.InputSystem;

namespace Ashenfall
{
    public class InputManager : SingletonBase<InputManager>
    {
        public Vector2 MoveInput { get; private set; }
        public Vector2 AimDirection { get; private set; }
        public bool AttackPressed { get; private set; }
        public bool DodgePressed { get; private set; }
        public bool InteractPressed { get; private set; }
        public bool PotionPressed { get; private set; }
        public bool PausePressed { get; private set; }
        public bool InventoryPressed { get; private set; }
        public bool SkillTreePressed { get; private set; }
        public bool MapPressed { get; private set; }
        public bool UltimatePressed { get; private set; }

        // Skill hotkeys (1-5)
        public bool[] SkillPressed { get; private set; } = new bool[5];

        private Camera _mainCamera;

        protected override void OnSingletonAwake()
        {
            _mainCamera = Camera.main;
        }

        private void Update()
        {
            // Reset per-frame flags
            AttackPressed = false;
            DodgePressed = false;
            InteractPressed = false;
            PotionPressed = false;
            PausePressed = false;
            InventoryPressed = false;
            SkillTreePressed = false;
            MapPressed = false;
            UltimatePressed = false;
            for (int i = 0; i < 5; i++) SkillPressed[i] = false;

            // Movement (WASD)
            float h = 0f, v = 0f;
            if (Keyboard.current != null)
            {
                if (Keyboard.current.wKey.isPressed) v += 1f;
                if (Keyboard.current.sKey.isPressed) v -= 1f;
                if (Keyboard.current.aKey.isPressed) h -= 1f;
                if (Keyboard.current.dKey.isPressed) h += 1f;
            }

            // Gamepad fallback
            if (Gamepad.current != null)
            {
                var stick = Gamepad.current.leftStick.ReadValue();
                if (stick.sqrMagnitude > 0.01f)
                {
                    h = stick.x;
                    v = stick.y;
                }
            }

            MoveInput = new Vector2(h, v).normalized;

            // Aim direction (mouse)
            if (Mouse.current != null && _mainCamera != null)
            {
                var mouseScreen = Mouse.current.position.ReadValue();
                var mouseWorld = _mainCamera.ScreenToWorldPoint(new Vector3(mouseScreen.x, mouseScreen.y, 0f));
                AimDirection = ((Vector2)mouseWorld).normalized;
            }

            // Keys
            if (Keyboard.current != null)
            {
                if (Keyboard.current.spaceKey.wasPressedThisFrame) DodgePressed = true;
                if (Keyboard.current.eKey.wasPressedThisFrame) InteractPressed = true;
                if (Keyboard.current.qKey.wasPressedThisFrame) PotionPressed = true;
                if (Keyboard.current.escapeKey.wasPressedThisFrame) PausePressed = true;
                if (Keyboard.current.iKey.wasPressedThisFrame || Keyboard.current.tabKey.wasPressedThisFrame) InventoryPressed = true;
                if (Keyboard.current.kKey.wasPressedThisFrame) SkillTreePressed = true;
                if (Keyboard.current.mKey.wasPressedThisFrame) MapPressed = true;
                if (Keyboard.current.rKey.wasPressedThisFrame) UltimatePressed = true;

                // Skill hotkeys 1-5
                if (Keyboard.current.digit1Key.wasPressedThisFrame) SkillPressed[0] = true;
                if (Keyboard.current.digit2Key.wasPressedThisFrame) SkillPressed[1] = true;
                if (Keyboard.current.digit3Key.wasPressedThisFrame) SkillPressed[2] = true;
                if (Keyboard.current.digit4Key.wasPressedThisFrame) SkillPressed[3] = true;
                if (Keyboard.current.digit5Key.wasPressedThisFrame) SkillPressed[4] = true;
            }

            // Mouse attack
            if (Mouse.current != null && Mouse.current.leftButton.wasPressedThisFrame)
                AttackPressed = true;

            // Pause toggle
            if (PausePressed && GameManager.Instance != null)
                GameManager.Instance.TogglePause();
        }
    }
}

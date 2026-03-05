using UnityEngine;

namespace Ashenfall
{
    public class GameManager : SingletonBase<GameManager>
    {
        public GameState CurrentState { get; private set; } = GameState.Menu;
        public PlayerClass SelectedClass { get; private set; } = PlayerClass.Assassin;
        public DifficultyLevel Difficulty { get; set; } = DifficultyLevel.Normal;
        public NightmareTier CurrentNightmareTier { get; set; } = NightmareTier.Normal;

        protected override void OnSingletonAwake()
        {
            Application.targetFrameRate = 60;
        }

        public void ChangeState(GameState newState)
        {
            if (CurrentState == newState) return;

            var prevState = CurrentState;
            CurrentState = newState;

            switch (newState)
            {
                case GameState.Menu:
                    Time.timeScale = 1f;
                    break;
                case GameState.Loading:
                    break;
                case GameState.Playing:
                    Time.timeScale = 1f;
                    break;
                case GameState.Paused:
                    Time.timeScale = 0f;
                    break;
                case GameState.GameOver:
                    Time.timeScale = 0f;
                    break;
            }

            Debug.Log($"[GameManager] State: {prevState} → {newState}");
        }

        public void SelectClass(PlayerClass playerClass)
        {
            SelectedClass = playerClass;
            EventBus.PlayerClassSelected(playerClass);
        }

        public void TogglePause()
        {
            if (CurrentState == GameState.Playing)
                ChangeState(GameState.Paused);
            else if (CurrentState == GameState.Paused)
                ChangeState(GameState.Playing);
        }

        public void StartGame()
        {
            ChangeState(GameState.Loading);
        }

        public void GameOver()
        {
            ChangeState(GameState.GameOver);
        }

        public void ReturnToMenu()
        {
            ChangeState(GameState.Menu);
        }
    }
}

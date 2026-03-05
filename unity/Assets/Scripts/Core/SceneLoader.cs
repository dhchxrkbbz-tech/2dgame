using System;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Ashenfall
{
    public class SceneLoader : SingletonBase<SceneLoader>
    {
        public event Action<float> OnLoadProgress;
        public event Action OnLoadComplete;

        public string CurrentSceneName => SceneManager.GetActiveScene().name;

        public void LoadScene(string sceneName, TransitionType transition = TransitionType.Fade)
        {
            StartCoroutine(LoadSceneAsync(sceneName, transition));
        }

        private IEnumerator LoadSceneAsync(string sceneName, TransitionType transition)
        {
            GameManager.Instance.ChangeState(GameState.Loading);
            EventBus.ScreenOpened("loading_screen");

            var op = SceneManager.LoadSceneAsync(sceneName);
            op.allowSceneActivation = false;

            while (op.progress < 0.9f)
            {
                OnLoadProgress?.Invoke(op.progress);
                yield return null;
            }

            OnLoadProgress?.Invoke(1f);
            op.allowSceneActivation = true;

            yield return op;

            EventBus.ScreenClosed("loading_screen");
            GameManager.Instance.ChangeState(GameState.Playing);
            OnLoadComplete?.Invoke();
        }

        public void LoadSceneAdditive(string sceneName)
        {
            SceneManager.LoadSceneAsync(sceneName, LoadSceneMode.Additive);
        }

        public void UnloadScene(string sceneName)
        {
            SceneManager.UnloadSceneAsync(sceneName);
        }
    }
}

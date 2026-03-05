using UnityEngine;

namespace Ashenfall
{
    /// <summary>
    /// Alap osztály minden manager singletonhoz.
    /// Használat: public class GameManager : SingletonBase&lt;GameManager&gt; { }
    /// Automatikusan DontDestroyOnLoad, és biztosítja, hogy csak egy példány legyen.
    /// </summary>
    public abstract class SingletonBase<T> : MonoBehaviour where T : MonoBehaviour
    {
        private static T _instance;
        private static readonly object _lock = new();
        private static bool _applicationIsQuitting;

        public static T Instance
        {
            get
            {
                if (_applicationIsQuitting)
                    return null;

                lock (_lock)
                {
                    if (_instance != null)
                        return _instance;

                    _instance = FindFirstObjectByType<T>();

                    if (_instance != null)
                        return _instance;

                    var go = new GameObject($"[{typeof(T).Name}]");
                    _instance = go.AddComponent<T>();
                    return _instance;
                }
            }
        }

        protected virtual void Awake()
        {
            if (_instance != null && _instance != this)
            {
                Destroy(gameObject);
                return;
            }

            _instance = this as T;
            DontDestroyOnLoad(gameObject);
            OnSingletonAwake();
        }

        protected virtual void OnDestroy()
        {
            if (_instance == this)
            {
                _applicationIsQuitting = true;
                OnSingletonDestroy();
            }
        }

        /// <summary>Override this instead of Awake().</summary>
        protected virtual void OnSingletonAwake() { }

        /// <summary>Override this instead of OnDestroy().</summary>
        protected virtual void OnSingletonDestroy() { }
    }
}

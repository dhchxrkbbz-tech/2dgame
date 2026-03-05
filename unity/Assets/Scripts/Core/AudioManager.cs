using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

namespace Ashenfall
{
    public class AudioManager : SingletonBase<AudioManager>
    {
        [SerializeField] private AudioMixerGroup musicGroup;
        [SerializeField] private AudioMixerGroup sfxGroup;
        [SerializeField] private AudioMixerGroup ambientGroup;
        [SerializeField] private AudioMixerGroup uiGroup;

        private AudioSource _musicSource;
        private AudioSource _ambientSource;
        private readonly Queue<AudioSource> _sfxPool = new();
        private const int SfxPoolSize = 16;

        public float MasterVolume { get; private set; } = 1f;
        public float MusicVolume { get; private set; } = 0.7f;
        public float SfxVolume { get; private set; } = 1f;
        public float AmbientVolume { get; private set; } = 0.5f;
        public float UiVolume { get; private set; } = 0.8f;

        protected override void OnSingletonAwake()
        {
            _musicSource = CreateAudioSource("Music", true);
            _ambientSource = CreateAudioSource("Ambient", true);

            for (int i = 0; i < SfxPoolSize; i++)
            {
                var src = CreateAudioSource($"SFX_{i}", false);
                _sfxPool.Enqueue(src);
            }

            EventBus.OnPlaySfx += PlaySfxByName;
            EventBus.OnPlayMusic += PlayMusicByName;
            EventBus.OnStopMusic += StopMusic;
        }

        protected override void OnSingletonDestroy()
        {
            EventBus.OnPlaySfx -= PlaySfxByName;
            EventBus.OnPlayMusic -= PlayMusicByName;
            EventBus.OnStopMusic -= StopMusic;
        }

        private AudioSource CreateAudioSource(string name, bool loop)
        {
            var go = new GameObject(name);
            go.transform.SetParent(transform);
            var src = go.AddComponent<AudioSource>();
            src.loop = loop;
            src.playOnAwake = false;
            return src;
        }

        public void PlaySfxByName(string clipName)
        {
            var clip = Resources.Load<AudioClip>($"Audio/SFX/{clipName}");
            if (clip != null) PlaySfx(clip);
        }

        public void PlaySfx(AudioClip clip, float volumeScale = 1f)
        {
            if (clip == null) return;

            var src = GetPooledSource();
            src.clip = clip;
            src.volume = SfxVolume * MasterVolume * volumeScale;
            if (sfxGroup != null) src.outputAudioMixerGroup = sfxGroup;
            src.Play();
        }

        public void PlayMusicByName(string clipName)
        {
            var clip = Resources.Load<AudioClip>($"Audio/Music/{clipName}");
            if (clip != null) PlayMusic(clip);
        }

        public void PlayMusic(AudioClip clip, float fadeTime = 1f)
        {
            if (clip == null) return;
            _musicSource.clip = clip;
            _musicSource.volume = MusicVolume * MasterVolume;
            if (musicGroup != null) _musicSource.outputAudioMixerGroup = musicGroup;
            _musicSource.Play();
        }

        public void StopMusic()
        {
            _musicSource.Stop();
        }

        public void PlayAmbient(AudioClip clip)
        {
            if (clip == null) return;
            _ambientSource.clip = clip;
            _ambientSource.volume = AmbientVolume * MasterVolume;
            if (ambientGroup != null) _ambientSource.outputAudioMixerGroup = ambientGroup;
            _ambientSource.Play();
        }

        public void SetMasterVolume(float vol)
        {
            MasterVolume = Mathf.Clamp01(vol);
            UpdateVolumes();
        }

        public void SetMusicVolume(float vol)
        {
            MusicVolume = Mathf.Clamp01(vol);
            _musicSource.volume = MusicVolume * MasterVolume;
        }

        public void SetSfxVolume(float vol)
        {
            SfxVolume = Mathf.Clamp01(vol);
        }

        public void SetAmbientVolume(float vol)
        {
            AmbientVolume = Mathf.Clamp01(vol);
            _ambientSource.volume = AmbientVolume * MasterVolume;
        }

        private void UpdateVolumes()
        {
            _musicSource.volume = MusicVolume * MasterVolume;
            _ambientSource.volume = AmbientVolume * MasterVolume;
        }

        private AudioSource GetPooledSource()
        {
            foreach (var src in _sfxPool)
            {
                if (!src.isPlaying)
                    return src;
            }
            // All busy, reuse oldest
            var reused = _sfxPool.Dequeue();
            _sfxPool.Enqueue(reused);
            return reused;
        }
    }
}

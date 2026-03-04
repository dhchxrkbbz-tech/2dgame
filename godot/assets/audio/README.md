# Ashenfall Audio Assets

Ez a mappa tartalmazza az összes audio fájlt.

## Könyvtár struktúra

```
audio/
├── music/          - Zene track-ek (.ogg, loop)
│   ├── menu_theme.ogg
│   ├── peaceful_exploration.ogg
│   ├── dark_exploration.ogg
│   ├── hostile_lands.ogg
│   ├── combat_theme.ogg
│   ├── dungeon_theme.ogg
│   ├── boss_battle.ogg
│   └── victory_fanfare.ogg
├── sfx/            - Hangeffektek (.wav)
│   ├── combat/     - Harci hangok (25-30 db)
│   ├── skills/     - Skill hangok (15-20 db)
│   ├── ui/         - UI hangok (10-15 db)
│   └── environment/ - Környezeti hangok (10-15 db)
└── ambient/        - Biome ambient loop-ok (.ogg)
```

## Formátumok

- **Zene**: `.ogg` (Ogg Vorbis) - loop támogatás, jó minőség / kis méret
- **SFX**: `.wav` - gyors betöltés, nincs dekódolási késés
- **Ambient**: `.ogg` - háttérben folyamatosan loopol

## Beszerzési források

### Zene
1. AI generált: Suno AI, Udio, Stable Audio
2. Royalty-free: OpenGameArt.org, Incompetech, Pixabay Music
3. Asset Store: itch.io music packs

### SFX
1. jsfxr / ChipTone (retro pixel art stílushoz)
2. Freesound.org (CC licensz)
3. Kenney.nl (CC0 game asset pack-ek)

## Hiányzó fájlok

Az AudioManager `push_warning()` üzenettel jelzi ha egy hang fájl hiányzik,
de nem crash-el. A játék futtatható hang fájlok nélkül is.

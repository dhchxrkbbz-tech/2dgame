# ASHENFALL – Unity Master Plan

## Státusz
Engine migráció Godot 4.6 → Unity 6 LTS (URP, C#)
Godot kód archiválva: `godot-archive` helyi branch

---

## Fázisok és prioritások

### FÁZIS 1 – Alap (Core Foundation)
> Cél: Unity projekt működőképes, minden manager singleton él, eseményrendszer kész

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 1.1 | **Unity Architecture** | 10_GODOT_ARCHITECTURE | TELJES | MonoBehaviour singleton-ok, ScriptableObject, Assembly Definition |
| 1.2 | **EventBus** | 10 (event_bus.gd) | TELJES | C# static events / System.Action delegate rendszer |
| 1.3 | **GameManager** | 10 (game_manager.gd) | RÉSZBEN | State machine (Menu/Playing/Paused/GameOver) |
| 1.4 | **InputManager** | 10 (input_manager.gd) | TELJES | Unity Input System (PlayerInput + InputActions) |
| 1.5 | **SaveManager** | 10 (save_manager.gd) | RÉSZBEN | JSON serialize (Newtonsoft.Json) + PlayerPrefs |
| 1.6 | **AudioManager** | 13_AUDIO | RÉSZBEN | Unity AudioMixer + AudioSource pooling |
| 1.7 | **SceneManager** | 10 (scene_manager.gd) | TELJES | UnityEngine.SceneManagement + async loading |
| 1.8 | **Constants/Enums** | 10 (constants.gd, enums.gd) | MINIMÁLIS | C# enum + static class |

**Fájlok (becsült): ~15 C# szkript**
**Eredmény**: Működő Unity projekt alap, minden manager singleton elérhető

---

### FÁZIS 2 – Játékos és harc (Player & Combat)
> Cél: Játékos mozog, támad, van HP/mana, damage number, alap harc működik

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 2.1 | **Player Controller** | 21_COMBAT + player.gd | TELJES | Rigidbody2D + PlayerInput |
| 2.2 | **Combat Manager** | 21_COMBAT_SYSTEM | RÉSZBEN | Damage formula, combo, combat state |
| 2.3 | **Health Component** | 21 (health_component.gd) | TELJES | MonoBehaviour component |
| 2.4 | **Hitbox/Hurtbox** | 21 (hitbox/hurtbox) | TELJES | Collider2D + trigger events |
| 2.5 | **Damage Calculator** | 21 (damage_calculator.gd) | MINIMÁLIS | Statikus C# class (formula) |
| 2.6 | **Status Effects** | 21 (status_effect*.gd) | RÉSZBEN | ScriptableObject-based |
| 2.7 | **Projectile System** | 21 (projectile.gd) | RÉSZBEN | Rigidbody2D + object pooling |
| 2.8 | **Skill System** | 01_SKILL_TREE | RÉSZBEN | C# abstract SkillBase, ScriptableObject data |
| 2.9 | **Class System** | 01 (class_base.gd) | RÉSZBEN | C# inheritance (Assassin/Mage/Tank) |
| 2.10 | **Camera** | player_camera.gd | TELJES | Cinemachine 2D follow |

**Fájlok (becsült): ~25 C# szkript**
**Eredmény**: Játszható karakter, harcolni tud, skilleket használhat

---

### FÁZIS 3 – Világ (World Generation)
> Cél: Procedurális világ generálódik, biome-ok, chunk streaming, nap/éjszaka

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 3.1 | **World Generator** | 02_PROCEDURAL_WORLD | RÉSZBEN | Perlin noise (Unity.Mathematics), Tilemap |
| 3.2 | **Chunk Manager** | 02 (chunk_manager.gd) | TELJES | Unity Tilemap chunk loading/unloading |
| 3.3 | **Biome Data** | 02 (biome_data.gd) | MINIMÁLIS | ScriptableObject biome definíciók |
| 3.4 | **Day/Night Cycle** | 02 (day_night_cycle.gd) | TELJES | URP Global Volume + Light2D |
| 3.5 | **Weather System** | 02 (weather_system.gd) | TELJES | ParticleSystem + URP post-processing |
| 3.6 | **Minimap** | 02 (minimap_manager.gd) | TELJES | RenderTexture + 2nd Camera |
| 3.7 | **POI Generator** | 02 (poi_generator.gd) | MINIMÁLIS | C# procedurális elhelyezés |

**Fájlok (becsült): ~15 C# szkript**
**Eredmény**: Generált világ, chunk streaming, biome-ok, nap/éj ciklus

---

### FÁZIS 4 – Ellenségek és AI (Enemy AI)
> Cél: Ellenségek spawnolnak, behaviour tree AI-val harcolnak

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 4.1 | **Behaviour Tree** | 06_ENEMY_AI (BT) | RÉSZBEN | C# custom BT (Selector/Sequence/Action/Condition) |
| 4.2 | **Enemy Base** | 06 (enemy_base.gd) | TELJES | MonoBehaviour + Rigidbody2D |
| 4.3 | **Detection System** | 06 (detection_system.gd) | RÉSZBEN | Physics2D.OverlapCircle + raycast |
| 4.4 | **Spawner** | 06 (enemy_spawner.gd) | RÉSZBEN | Object pooling + spawn zones |
| 4.5 | **Elite System** | 06 (elite_affix_system.gd) | MINIMÁLIS | C# affix modifiers |
| 4.6 | **Pack AI** | 06 (pack_ai.gd) | MINIMÁLIS | C# pack coordination |
| 4.7 | **Pathfinding** | 06 (NavigationServer2D) | TELJES | A* Pathfinding Project / NavMesh |

**Fájlok (becsült): ~20 C# szkript**
**Eredmény**: Működő ellenség AI, spawn, pack harc

---

### FÁZIS 5 – Dungeonok (Dungeon Generation)
> Cél: BSP dungeon generálás, szobák, csapdák, rejtvények, fog of war

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 5.1 | **BSP Generator** | 07_DUNGEON | MINIMÁLIS | C# BSP algoritmus |
| 5.2 | **Room Factory** | 07 (room_factory.gd) | RÉSZBEN | Prefab-based rooms |
| 5.3 | **Tilemap Painter** | 07 (tilemap_painter) | TELJES | Unity Tilemap API |
| 5.4 | **Trap System** | 07 (trap_system.gd) | RÉSZBEN | MonoBehaviour traps |
| 5.5 | **Puzzle System** | 07 (puzzle_base.gd) | RÉSZBEN | MonoBehaviour base + 5 típus |
| 5.6 | **Wave Spawner** | 07 (wave_spawner.gd) | RÉSZBEN | Coroutine-based waves |
| 5.7 | **Fog of War** | 07 (fog_of_war.gd) | TELJES | Shader Graph / RenderTexture |

**Fájlok (becsült): ~15 C# szkript**
**Eredmény**: Generált dungeon-ök, csapdák, rejtvények, köd

---

### FÁZIS 6 – Loot és gazdaság (Loot & Economy)
> Cél: Tárgyak generálódnak, inventory, bolt, crafting, gem rendszer

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 6.1 | **Item System** | 08_LOOT_SYSTEM | RÉSZBEN | ScriptableObject items |
| 6.2 | **Inventory** | 04_ECONOMY | RÉSZBEN | C# grid inventory |
| 6.3 | **Loot Generator** | 08 (loot_generator) | MINIMÁLIS | C# procedurális item gen |
| 6.4 | **Gem System** | 09_GEM_SYSTEM | MINIMÁLIS | C# socket + gem data |
| 6.5 | **Economy Manager** | 04 (economy_manager) | MINIMÁLIS | C# currency tracking |
| 6.6 | **Crafting** | 04 (crafting_manager) | RÉSZBEN | UI + recipe system |
| 6.7 | **Shop System** | 04 (shop_manager) | RÉSZBEN | UI + buy/sell logic |
| 6.8 | **Marketplace** | 04 (marketplace) | RÉSZBEN | Listing + UI |

**Fájlok (becsült): ~20 C# szkript**
**Eredmény**: Teljes item/loot pipeline, bolt, crafting

---

### FÁZIS 7 – Bossok (Boss System)
> Cél: Multi-fázisú bossok, telegraph, loot table

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 7.1 | **Boss Base** | 03_BOSS_DESIGN | RÉSZBEN | MonoBehaviour + state machine |
| 7.2 | **Phase System** | 03 (boss_phase.gd) | MINIMÁLIS | C# phase controller |
| 7.3 | **Telegraph** | 03 (boss_telegraph) | RÉSZBEN | SpriteRenderer warning zones |
| 7.4 | **Threat Table** | 03 (boss_threat) | MINIMÁLIS | C# aggro system |
| 7.5 | **Specific Bosses** | 03 (12 boss) | RÉSZBEN | 12 egyedi C# implementáció |

**Fájlok (becsült): ~20 C# szkript**

---

### FÁZIS 8 – UI (User Interface)
> Cél: HUD, inventory UI, skill tree, beállítások, dialogue, stb.

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 8.1 | **HUD** | - | TELJES | Canvas + TextMeshPro |
| 8.2 | **Main Menu** | - | TELJES | Canvas UI |
| 8.3 | **Inventory UI** | 04 | TELJES | Canvas grid layout |
| 8.4 | **Skill Tree UI** | 01 | TELJES | Canvas + node visualization |
| 8.5 | **Settings** | 17_ACCESSIBILITY | TELJES | Canvas + PlayerPrefs |
| 8.6 | **Dialogue UI** | 12_QUEST | TELJES | Canvas + typewriter effect |
| 8.7 | **Quest Log** | 12 | TELJES | Canvas list |
| 8.8 | **Tooltip System** | - | TELJES | Canvas follow mouse |

**Fájlok (becsült): ~20 C# szkript**

---

### FÁZIS 9 – Küldetések és sztori (Quests & Story)
> Cél: 20 fő küldetés, napi/heti, NPC párbeszédek

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 9.1 | **Quest Manager** | 12_QUEST_STORY | RÉSZBEN | C# quest state machine |
| 9.2 | **Dialogue Manager** | 12 | RÉSZBEN | C# + JSON dialogue trees |
| 9.3 | **NPC System** | 12 | RÉSZBEN | MonoBehaviour interactable |

---

### FÁZIS 10 – Multiplayer (Networking)
> Cél: 4 fős co-op, host-authoritative, sync

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 10.1 | **Network Manager** | 05_NETWORKING | TELJES | Unity Netcode for GameObjects / Mirror |
| 10.2 | **Sync System** | 05 (sync_manager) | TELJES | NetworkVariable + ClientRpc/ServerRpc |
| 10.3 | **Lobby** | 05 (lobby_manager) | TELJES | Unity Lobby + Relay (vagy LAN) |
| 10.4 | **Anti-Cheat** | 05 (anti_cheat) | RÉSZBEN | Server-side validation |
| 10.5 | **Chat** | 05 (chat_system) | RÉSZBEN | NetworkVariable string |

---

### FÁZIS 11 – Progresszió és endgame
> Cél: Achievement-ek, Paragon, NG+, világ események

| # | Rendszer | Forrás plan | Godot-specifikus? | Unity megoldás |
|---|---------|-------------|-------------------|----------------|
| 11.1 | **Achievement Manager** | 15_ACHIEVEMENT | MINIMÁLIS | C# event-based tracking |
| 11.2 | **Stats Tracker** | 15 | MINIMÁLIS | C# dictionary counters |
| 11.3 | **Endgame Manager** | 15 | MINIMÁLIS | C# paragon + NG+ logic |
| 11.4 | **Fast Travel** | - | RÉSZBEN | Waypoint prefab system |

---

### FÁZIS 12 – Shaderek (Visual Effects)
> Cél: 8 shader újraírása Unity ShaderGraph-ban

| # | Shader | Eredeti | Unity megoldás |
|---|--------|---------|----------------|
| 12.1 | Day/Night | day_night.gdshader | URP Light2D + Global Volume |
| 12.2 | Water | water.gdshader | ShaderGraph (UV scroll, noise) |
| 12.3 | Fog of War | fog_of_war.gdshader | RenderTexture + ShaderGraph |
| 12.4 | Palette Swap | palette_swap.gdshader | ShaderGraph (color remap) |
| 12.5 | Corruption | corruption.gdshader | ShaderGraph (distortion + tint) |
| 12.6 | Colorblind | colorblind.gdshader | URP Renderer Feature / post-process |
| 12.7 | Elite Aura | elite_aura.gdshader | ShaderGraph (pulse glow) |
| 12.8 | Rarity Border | rarity_border.gdshader | ShaderGraph (color border) |

---

### FÁZIS 13 – Tutorial, Lokalizáció, Akadálymentesség
> Cél: Bevezető, nyelvek, accessibility

| # | Rendszer | Forrás plan |
|---|---------|-------------|
| 13.1 | Tutorial Manager | 14_TUTORIAL |
| 13.2 | Localization | 17_ACCESSIBILITY_LOCALIZATION |
| 13.3 | Accessibility | 17 (colorblind, text size, stb.) |

---

### FÁZIS 14 – Polish, QA, Build
> Cél: Optimalizálás, hibakeresés, build

| # | Rendszer | Forrás plan |
|---|---------|-------------|
| 14.1 | Performance | 18_POLISH_QA |
| 14.2 | Bug fixing | 18 |
| 14.3 | Build pipeline | - |

---

## Jelenlegi fókusz

**>>> FÁZIS 1: Core Foundation <<<**

Miért ezzel kezdünk:
- Minden más rendszer erre épül (EventBus, GameManager, SaveManager, stb.)
- Singleton manager mintát kell először kialakítani
- Input System konfigurálás szükséges a játékos mozgáshoz
- Hibamentes alap = gyorsabb fejlesztés később

---

## Régi plan fájlok állapota

| Plan fájl | Engine-függő? | Teendő |
|-----------|--------------|--------|
| 00_MASTER_PLAN | IGEN (Godot ref) | Lecserélve → UNITY_MASTER_PLAN.md |
| 01_SKILL_TREE | Részben | Game design OK, GDScript kódrészletek cserélendők |
| 02_PROCEDURAL_WORLD | Részben | Noise/BSP logic OK, Godot API cserélendő |
| 03_BOSS_DESIGN | Részben | Design OK, Godot node ref cserélendő |
| 04_ECONOMY_SYSTEM | Minimálisan | Design OK |
| 05_NETWORKING | IGEN (ENet) | Netcode for GameObjects / Mirror kell |
| 06_ENEMY_AI | Részben | BT logic OK, NavigationServer2D cserélendő |
| 07_DUNGEON_GENERATION | Részben | BSP OK, TileMap API cserélendő |
| 08_LOOT_SYSTEM | Minimálisan | Design OK |
| 09_GEM_SYSTEM | Minimálisan | Design OK |
| 10_GODOT_ARCHITECTURE | TELJES | Lecserélve → FÁZIS 1 |
| 11_ROADMAP | Igen | Új ütemterv szükséges |
| 12_QUEST_STORY | Minimálisan | Design + JSON OK |
| 13_AUDIO | Nem | OK |
| 14_TUTORIAL | Részben | UI cserélendő |
| 15_ACHIEVEMENT_ENDGAME | Minimálisan | OK |
| 16_GAME_DATA_BALANCE | Nem | Tisztán adat, OK |
| 17_ACCESSIBILITY | Részben | Shader/UI cserélendő |
| 18_POLISH_QA | Részben | Unity-specifikus QA kell |
| 19_VISUAL_ART | Nem | Asset pipeline OK |
| 20_AUDIO_MASTER | Nem | OK |
| 21_COMBAT_SYSTEM | Részben | Damage formula OK, Godot API cserélendő |

---

## Becsült C# fájlszám összesen: ~180-200 szkript
## Becsült fejlesztési idő: fázisonként 1-3 session

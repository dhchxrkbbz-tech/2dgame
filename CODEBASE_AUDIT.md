# Ashenfall — Comprehensive Codebase Audit

**Project:** Ashenfall (2D Top-Down ARPG)  
**Engine:** Godot 4.x  
**Language:** GDScript  
**Total Files:** 269 `.gd` files across 18 directories  
**Path:** `godot/scripts/`

---

## Summary Statistics

| Directory | Files | Total Lines | Largest File |
|-----------|-------|-------------|--------------|
| ai/ | 30 | ~4,599 | enemy_base.gd (1,068) |
| bosses/ | 23 | ~5,379 | void_emperor.gd (628) |
| classes/ | 9 | ~2,157 | skill_database.gd (1,108) |
| combat/ | 10 | ~1,090 | health_component.gd (177) |
| core/ | 15 | ~3,967 | audio_manager.gd (812) |
| dialogue/ | 4 | ~512 | dialogue_manager.gd (402) |
| dungeons/ | 33 | ~6,536 | dungeon_manager.gd (728) |
| economy/ | 13 | ~3,390 | crafting_manager.gd (662) |
| items/ | 32 | ~6,277 | legendary_data.gd (643) |
| main/ | 1 | 231 | game_world.gd (231) |
| multiplayer/ | 21 | ~3,344 | inventory_sync.gd (255) |
| player/ | 2 | 782 | player.gd (719) |
| professions/ | 10 | ~1,073 | gathering_database.gd (365) |
| progression/ | 7 | ~2,396 | world_event_manager.gd (471) |
| quest/ | 5 | ~1,295 | quest_manager.gd (733) |
| tutorial/ | 6 | ~1,525 | tutorial_manager.gd (445) |
| ui/ | 28 | ~5,532 | marketplace_ui.gd (459) |
| world/ | 20 | ~4,291 | poi_generator.gd (356) |
| **TOTAL** | **269** | **~54,376** | |

---

## 1. `scripts/ai/` — Enemy AI & Behaviour (30 files)

### Root (12 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `attack_manager.gd` | Node | 430 | Enemy attack handler: pattern selection, telegraph timing, summon tracking |
| `attack_pattern.gd` | Resource | 311 | Attack pattern data: damage, cooldown, range, projectile, AoE config |
| `bt_builder.gd` | RefCounted | 385 | Builds behaviour trees per enemy archetype (Melee/Ranged/Caster/Swarmer/Brute/Charger) |
| `detection_system.gd` | Node | 246 | Enemy detection/aggro system with LOS, threat, states (UNAWARE→SUSPICIOUS→ALERT→CHASING→LEASH) |
| `elite_affix_system.gd` | RefCounted | 125 | Elite enemy modifiers: SHIELDED, VAMPIRIC, THORNS, ENRAGED, SUMMONER, etc. |
| `elite_enemy.gd` | EnemyBase | 309 | Elite enemy with affix management, shield, enrage, teleport, summon |
| `enemy_base.gd` | CharacterBody2D | 1,068 | **Largest AI file.** Base enemy class: HP, movement, AI states, combat, knockback, drops |
| `enemy_data.gd` | Resource | 53 | Enemy stat definitions resource (name, type, base stats, biome, rewards) |
| `enemy_database.gd` | RefCounted | 287 | Central enemy registry and per-biome spawn tables |
| `enemy_spawner.gd` | Node | 125 | World enemy spawning integrated with chunk system |
| `pack_ai.gd` | RefCounted | 206 | Pack/swarm behaviour: Leader/Flanker/Support roles, boids flocking |
| `spawn_table.gd` | RefCounted | 54 | Biome-specific spawn entry definitions with weights |

### `ai/behaviour_tree/` (7 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `behaviour_tree.gd` | Node | 127 | BT root with BTStatus enum and blackboard dictionary |
| `bt_node.gd` | RefCounted | 80 | Base BT node with Status enum (SUCCESS/FAILURE/RUNNING), `tick()` |
| `bt_action.gd` | BTNode | 89 | Action leaf node calling a Callable |
| `bt_condition.gd` | BTNode | 65 | Condition leaf node (bool → SUCCESS/FAILURE) |
| `bt_decorator.gd` | BTNode | 160 | Decorator types: Inverter, Repeater, Cooldown, Limiter, RandomChance |
| `bt_selector.gd` | BTNode | 39 | Selector composite (OR logic — first success wins) |
| `bt_sequence.gd` | BTNode | 38 | Sequence composite (AND logic — all must succeed) |

### `ai/specific/` (11 files — biome-specific attack pattern definitions)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `ashlands_ai.gd` | RefCounted | 140 | Flame Imp, Fire Elemental, Ash Golem, Magma Worm attack patterns |
| `elemental_ai.gd` | RefCounted | 147 | Fire/Ice/Rock Elemental attack patterns |
| `forest_ai.gd` | RefCounted | 142 | Giant Spider, Poison Archer, Dark Witch patterns |
| `frozen_ai.gd` | RefCounted | 106 | Ice Wolf, Frost Mage, Ice Golem patterns |
| `meadow_ai.gd` | RefCounted | 106 | Forest Slime, Wild Boar, Bandit patterns |
| `mountain_ai.gd` | RefCounted | 112 | Mountain Goat, Harpy, Yeti patterns |
| `plague_ai.gd` | RefCounted | 143 | Plague Zombie, Plague Rat, Abomination patterns |
| `skeleton_ai.gd` | RefCounted | 56 | Skeleton Warrior/Archer patterns |
| `spider_ai.gd` | RefCounted | 30 | Venomous Bite, Web Shot patterns |
| `swamp_ai.gd` | RefCounted | 114 | Swamp Lurker, Toxic Frog, Vine Creeper patterns |
| `undead_ai.gd` | RefCounted | 149 | Wraith (necro), Ghost (phase), Death Knight patterns |

---

## 2. `scripts/bosses/` — Boss System (23 files)

### Root (9 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `boss_ability.gd` | RefCounted | 59 | Boss ability definition: area, telegraph, summon, phase restriction |
| `boss_base.gd` | CharacterBody2D | 760 | Base boss class: multi-phase, telegraph, enrage, threat table |
| `boss_data.gd` | Resource | 25 | Boss stats resource (name, tier, HP, armor, damage, phases, loot) |
| `boss_database.gd` | RefCounted | 259 | All boss registration and biome-based boss selection |
| `boss_health_bar.gd` | CanvasLayer | 148 | Boss HP bar UI at screen top |
| `boss_loot.gd` | RefCounted | 259 | Boss loot generation (guaranteed / rare / ultra_rare pools) |
| `boss_phase.gd` | RefCounted | 39 | Phase data: HP threshold, abilities, stat modifiers, aura |
| `boss_telegraph.gd` | Node2D | 129 | Attack telegraph visuals (circle, line, cone, rectangle) |
| `boss_threat_table.gd` | RefCounted | 100 | Aggro/threat system for multiplayer boss encounters |

### `bosses/specific/` (14 boss implementations — all extend BossBase)

| File | Tier | HP | Level | Lines | Summary |
|------|------|----|-------|-------|---------|
| `plague_rat_king.gd` | T1 | 600 | 5–8 | 178 | Summons plague rats, poison clouds |
| `cursed_treant.gd` | T1 | 800 | 5–8 | 189 | Root/vine attacks, nature-themed |
| `shadow_stalker.gd` | T1 | 500 | 8–12 | 271 | Stealth mechanics, shadow clones |
| `frozen_sentinel.gd` | T1 | 1,200 | 8–12 | 153 | Ice attacks, freeze AoE |
| `ash_warden.gd` | T1 | 1,500 | 5–8 | 203 | Fire attacks, flame pillars |
| `swamp_hydra.gd` | T1 | 15,000 | 26–30 | 278 | Multi-head regeneration boss |
| `spider_matriarch.gd` | T2 | 4,000 | 12–16 | 339 | Web/egg mechanics, spider summons |
| `necromancer_king.gd` | T2 | 5,000 | 15–20 | 279 | Undead summoning, life drain |
| `volcanic_overlord.gd` | T2 | 35,000 | 34–38 | 358 | Magma/meteor attacks, terrain fire |
| `ancient_dragon.gd` | T3 | 120,000 | 45–48 | 379 | 4-player required, breath attacks |
| `riftlord.gd` | T3 | 100,000 | 50 | 304 | Portal mechanics, dimensional shifts |
| `void_weaver.gd` | T3 | 150,000 | 48–50 | 447 | Shadow clone mechanics |
| `ashen_god.gd` | T4 Raid | 500,000 | 50+ | 460 | 6 phases, 4-player mandatory |
| `void_emperor.gd` | T4 Raid | 800,000 | 50+ | 628 | **FINAL BOSS.** 8 phases, 4-player mandatory |

---

## 3. `scripts/classes/` — Player Class System (9 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `class_base.gd` | RefCounted | 99 | Base class with SkillManager, UltimateManager, branches |
| `assassin.gd` | ClassBase | 52 | Shadow/Poison/Blood branches, crit passives |
| `tank.gd` | ClassBase | 49 | Guardian/Warbringer/Paladin branches, block/threat passives |
| `mage.gd` | ClassBase | 49 | Arcane/Frost/Holy branches, spell crit/mana regen passives |
| `skill_data.gd` | Resource | 85 | Skill definition: damage, cooldown, mana cost, damage type |
| `skill_database.gd` | RefCounted | 1,108 | **Largest.** All 45 skills (3 classes × 3 branches × 5 skills) |
| `skill_manager.gd` | RefCounted | 350 | 4 equipped skill slots, cooldowns, GCD, skill point allocation |
| `skill_tree.gd` | RefCounted | 157 | Skill tree logic: 3 branches × (4 skills + 1 ultimate) |
| `ultimate_manager.gd` | RefCounted | 208 | Ultimate skill management, transform state tracking |

---

## 4. `scripts/combat/` — Combat System (10 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `combat_manager.gd` | Node | 113 | Combat state tracking, threat, kill count, combo system |
| `damage_calculator.gd` | RefCounted | 78 | Damage formula: armor reduction, crit, elemental resistance |
| `damage_number.gd` | Node2D | 81 | Floating damage number display with tween animation |
| `health_component.gd` | Node | 177 | Reusable HP component with shield and regen |
| `hitbox_component.gd` | Area2D | 93 | Damage-dealing area with knockback, status effects |
| `hurtbox_component.gd` | Area2D | 34 | Damage-receiving area with invincibility frames |
| `projectile.gd` | Area2D | 140 | Projectile system: homing, pierce, AoE on impact |
| `status_effect.gd` | RefCounted | 113 | Status effect instance: DOT, CC, buff/debuff, stacking |
| `status_effect_manager.gd` | Node | 129 | Status effect lifecycle: tick, CC check, stat aggregation |
| `telegraph.gd` | Node2D | 132 | AoE telegraph warning visuals (circle/rect/line/cone) |

---

## 5. `scripts/core/` — Engine Core & Autoloads (15 files)

| File | Extends | Lines | Autoload | Summary |
|------|---------|-------|----------|---------|
| `accessibility_manager.gd` | Node | 373 | ✅ | Colorblind modes, text size, difficulty, game speed |
| `audio_manager.gd` | Node | 812 | ✅ | **Largest.** Music crossfade, SFX pool, biome/dynamic music |
| `audio_paths.gd` | RefCounted | 173 | — | All audio file path constants (8 music, 25+ SFX) |
| `audio_placeholder_generator.gd` | Node | 347 | — | `@tool` script generating placeholder .wav files procedurally |
| `constants.gd` | Node | 397 | ✅ | Global constants: tile size 32, chunk 16, max level 50, combat values |
| `debug_console.gd` | CanvasLayer | 133 | — | Dev console opened with F12 |
| `enums.gd` | class_name Enums | 384 | — | All game enums: GameState, PlayerClass, BiomeType, DamageType, etc. |
| `event_bus.gd` | Node | 215 | ✅ | Global signal bus for decoupled communication |
| `game_manager.gd` | Node | 86 | ✅ | Game state management, pause, debug mode |
| `input_manager.gd` | Node | 545 | ✅ | WASD, mouse, gamepad input with rebinding |
| `localization_manager.gd` | Node | 219 | ✅ | Hungarian/English localization from CSV |
| `placeholder_sprites.gd` | Node | 118 | — | Colored rectangle textures as placeholders |
| `save_manager.gd` | Node | 326 | ✅ | JSON save system, 3 slots, autosave |
| `scene_manager.gd` | Node | 78 | ✅ | Scene transitions with fade effects |
| `utils.gd` | Node | 92 | — | Helper functions: tile/world conversion, distance |

---

## 6. `scripts/dialogue/` — Dialogue System (4 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `dialogue_data.gd` | Resource | 39 | Dialogue sequence definition |
| `dialogue_line.gd` | Resource | 38 | Single dialogue line with response options |
| `dialogue_manager.gd` | Node | 402 | Dialogue playback, quest integration (Autoload) |
| `dialogue_response.gd` | Resource | 33 | Player response option with action triggers |

---

## 7. `scripts/dungeons/` — Procedural Dungeons (33 files)

### Root (19 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `bsp_generator.gd` | RefCounted | 210 | Binary space partitioning room generation |
| `chest_system.gd` | Node | 224 | Chest/mimic/fountain management |
| `corridor_builder.gd` | RefCounted | 222 | L-shaped corridor generation with traps/torches |
| `door_controller.gd` | Node | 250 | Door states: open/closed/locked/sealed/boss-sealed |
| `dungeon_enemy_spawner.gd` | Node | 271 | Dungeon enemy spawning with +20% stat bonus |
| `dungeon_entrance.gd` | Node2D | 89 | World dungeon entry point POI |
| `dungeon_generator.gd` | Node | 521 | Full dungeon generation with tier-based configs |
| `dungeon_loot_spawner.gd` | Node | 314 | Chest placement and loot roll per room |
| `dungeon_manager.gd` | Node | 728 | **Largest.** Dungeon entry/exit, instance management |
| `dungeon_minimap.gd` | Control | 156 | Dungeon minimap rendering with room visibility |
| `dungeon_room.gd` | RefCounted | 157 | Room data: 8 types (COMBAT/TREASURE/PUZZLE/TRAP/SAFE/BOSS/SECRET/ENTRANCE) |
| `dungeon_tilemap_painter.gd` | RefCounted | 159 | TileMap painting from generated dungeon data |
| `dungeon_wave_spawner.gd` | Node | 359 | Wave-based enemy spawning per room |
| `fog_of_war.gd` | Node2D | 195 | Dynamic fog of war with vision radius |
| `puzzle_base.gd` | Node2D | 98 | Base puzzle class with completion signal |
| `room_data.gd` | Resource | 172 | Room configuration resources |
| `room_factory.gd` | RefCounted | 170 | Room node builder from DungeonRoom data |
| `trap_data.gd` | Resource | 151 | Trap type definitions (spike, poison_gas, fire_jet, etc.) |
| `trap_system.gd` | Node | 207 | Trap system with 7+ trap types, activation/deactivation |

### `dungeons/puzzles/` (6 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `puzzle_system.gd` | Node | 269 | Puzzle orchestrator (switch/pressure/light/symbol/timed) |
| `switch_puzzle.gd` | PuzzleBase | 135 | Switch order puzzle |
| `symbol_match_puzzle.gd` | PuzzleBase | 185 | Memory matching puzzle |
| `timed_challenge_puzzle.gd` | PuzzleBase | 222 | Time-limit challenges |
| `pressure_plate_puzzle.gd` | PuzzleBase | 151 | Pressure plates + movable blocks |
| `light_beam_puzzle.gd` | PuzzleBase | 231 | Light beam + mirror reflection |

### `dungeons/biome_themes/` (8 files — all extend BiomeThemeBase)

| File | Lines | Theme Name | Hazard |
|------|-------|------------|--------|
| `biome_theme_base.gd` | 80 | (base class) | Ambient color, hazards, decorations |
| `theme_ashlands.gd` | 137 | "Molten Forge" | Lava hazards |
| `theme_cursed_forest.gd` | 79 | "Witch's Hollow" | Darkness |
| `theme_dark_swamp.gd` | 85 | "Sunken Temple" | Swamp slow |
| `theme_frozen_wastes.gd` | 113 | "Frost Citadel" | Ice slide |
| `theme_plague_lands.gd` | 165 | "Plague Sanctum" | Corruption stacks |
| `theme_mountains.gd` | 109 | "Deep Mine" | Falling rocks |
| `theme_ruins.gd` | 95 | "Ancient Crypt" | Skeleton respawn |

---

## 8. `scripts/economy/` — Economy & Crafting (13 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `crafting_manager.gd` | Node | 662 | **Largest.** Crafting logic with recipe database |
| `crafting_recipe.gd` | Resource | 55 | Recipe definition: ingredients, station, profession |
| `currency_manager.gd` | Node | 188 | Gold / Dark Essence / Relic Fragment tracking |
| `economy_manager.gd` | Node | 194 | Main economy singleton (Autoload), connects all subsystems |
| `gathering_node.gd` | Area2D | 318 | World resource nodes (wood, ore, herb) |
| `inventory_manager.gd` | Node | 460 | Inventory, equipment, stash management |
| `marketplace_listing.gd` | RefCounted | 59 | Auction house listing data structure |
| `marketplace_manager.gd` | Node | 315 | Marketplace / auction house logic |
| `profession_manager.gd` | Node | 197 | Profession XP/levels (max 2 gathering + 2 crafting) |
| `shop_data.gd` | Resource | 30 | NPC shop inventory definition |
| `shop_database.gd` | RefCounted | 207 | All NPC shop registrations |
| `shop_manager.gd` | Node | 312 | NPC shop buy/sell/repair/buyback |
| `upgrade_manager.gd` | Node | 343 | Enhancement (+1→+10), enchanting, gem socketing |

---

## 9. `scripts/items/` — Loot & Item System (32 files)

### Root (22 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `affix.gd` | RefCounted | 73 | Affix (prefix/suffix) definition |
| `affix_data.gd` | RefCounted | 100 | Affix rolling with item level scaling |
| `affix_pool.gd` | RefCounted | 104 | Prefix/suffix pool management |
| `dropped_item.gd` | Node2D | 203 | World loot pickup with auto-pickup, bobbing animation |
| `drop_display.gd` | Node2D | 130 | Rarity-based visual effects (glow, particles) |
| `equipment.gd` | RefCounted | 182 | 12 equipment slots, set tracking |
| `inventory.gd` | RefCounted | 277 | 6×8=48 slot grid + 4 quick slots |
| `item_base.gd` | Node2D | 96 | Physical item in world |
| `item_data.gd` | Resource | 30 | Base item definition with stats, sockets |
| `item_database.gd` | RefCounted | 407 | All base item registry |
| `item_generator.gd` | RefCounted | 323 | Item generation with rarity/affix rolling |
| `item_instance.gd` | RefCounted | 236 | Concrete item instance with affixes, gems, enhancement level |
| `item_tooltip.gd` | PanelContainer | 321 | Rich item tooltip UI with BBCode |
| `legendary_data.gd` | RefCounted | 643 | **Largest.** 30 legendary item definitions |
| `loot_dropper.gd` | Node | 193 | Enemy loot drop component |
| `loot_filter.gd` | RefCounted | 160 | Player loot filter settings |
| `loot_generator.gd` | RefCounted | 377 | Item generation with rarity weights per tier |
| `loot_manager.gd` | Node | 183 | Global loot management (Autoload) |
| `loot_table.gd` | RefCounted | 315 | Loot table definition with pool entries |
| `rarity.gd` | RefCounted | 58 | Rarity names, colors, sell multipliers |
| `set_item_data.gd` | RefCounted | 360 | Set item definitions and set bonuses |
| `stash.gd` | RefCounted | 149 | NPC stash with tabs, expandable storage |

### `items/gems/` (10 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `gem_data.gd` | Resource | 59 | Gem type names (Ruby/Emerald/Sapphire/Amethyst/Topaz/Diamond), colors, tier names |
| `gem_instance.gd` | RefCounted | 166 | Gem instance with type + tier (Chipped→Radiant, 6 tiers) |
| `gem_stat_table.gd` | RefCounted | 245 | Gem stats per type + tier + equipment slot |
| `gem_drop_table.gd` | RefCounted | 129 | Gem drop logic per enemy type |
| `gem_combiner.gd` | RefCounted | 187 | 3 same gems → next tier upgrade |
| `gem_ui.gd` | Control | 319 | Gem drag & drop, socket visualization |
| `legendary_gem_data.gd` | Resource | 61 | Legendary gem definitions with effect triggers |
| `legendary_gem_database.gd` | RefCounted | 150 | Legendary gem registry and lookup |
| `legendary_gem_effect_handler.gd` | Node | 404 | Runtime legendary gem effect handling (ON_KILL, ON_CRIT, PASSIVE) |
| `socket_system.gd` | RefCounted | 291 | Gem insertion, removal, synergy bonuses (+20% matching, +5% rainbow) |

---

## 10. `scripts/main/` — Main Game Scene (1 file)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `game_world.gd` | Node2D | 231 | Main gameplay scene: entity/projectile/effect layers, procedural world, player spawning |

---

## 11. `scripts/multiplayer/` — Networking (21 files)

### Root (10 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `anti_cheat.gd` | Node | 183 | Host-side validation: speed, range, cooldown, position checks |
| `chat_system.gd` | Node | 155 | RPC chat with channels (GLOBAL/PARTY/WHISPER/SYSTEM/TRADE), flood protection |
| `connection_manager.gd` | Node | 85 | Host/Client connection creation, timeout handling |
| `lobby_manager.gd` | Node | 205 | Lobby system: player list, ready state, class selection, game start |
| `network_manager.gd` | Node | 197 | **Main multiplayer singleton (Autoload).** ENet, host-authoritative, max 4 co-op, 20 tick/s |
| `network_stats.gd` | Node | 168 | Network stats: ping, packet loss, bandwidth, tick rate |
| `quest_sync.gd` | Node | 233 | Quest progress sharing in co-op mode |
| `reconnect_handler.gd` | Node | 88 | Client-side reconnection flow (5 attempts, 3s delay) |
| `session_manager.gd` | Node | 183 | Session lifecycle: auto-save (5min), disconnect handling, 5min reconnect window |
| `sync_manager.gd` | Node | 82 | Central sync coordinator — instantiates all sub-sync managers |

### `multiplayer/prediction/` (3 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `client_prediction.gd` | Node | 88 | Client-side movement prediction with server reconciliation |
| `input_buffer.gd` | Node | 69 | Timestamped input history for replay and reconciliation |
| `interpolation.gd` | Node | 112 | Remote entity interpolation with 100ms delay, snapshot buffer |

### `multiplayer/sync/` (8 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `animation_sync.gd` | Node | 135 | Animation state sync (name only — minimal bandwidth) |
| `combat_sync.gd` | Node | 212 | Damage, skill cast, buff/debuff sync; host-authoritative |
| `enemy_sync.gd` | Node | 201 | Enemy AI state sync (host runs AI, clients get visuals) |
| `inventory_sync.gd` | Node | 255 | **Largest sync.** Inventory state sync with server-side validation |
| `loot_sync.gd` | Node | 121 | Personal loot sync (each player gets own drops, invisible to others) |
| `player_sync.gd` | Node | 225 | Player position/state sync with client prediction + interpolation |
| `projectile_sync.gd` | Node | 130 | Projectile spawn sync (host handles hit detection) |
| `world_sync.gd` | Node | 98 | Seed-based deterministic world, only delta modifications synced |

---

## 12. `scripts/player/` — Player Character (2 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `player.gd` | CharacterBody2D | 719 | **Main player.** 8-directional movement, 3 classes, combat, skills, XP, death/respawn |
| `player_camera.gd` | Camera2D | 63 | Smooth follow camera with zoom (1x–4x) and screen shake |

---

## 13. `scripts/professions/` — Profession System (10 files)

### Root (2 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `gathering_database.gd` | RefCounted | 365 | All gathering node definitions for mining/herbalism/woodcutting/fishing |
| `profession_base.gd` | RefCounted | 78 | Base profession class: XP gain, leveling, 1.2× XP growth per level |

### `professions/crafting/` (4 files — all extend ProfessionBase)

| File | Lines | Summary |
|------|-------|---------|
| `alchemy.gd` | 76 | Potions, poisons, brews |
| `blacksmithing.gd` | 103 | Weapons and armor crafting |
| `enchanting.gd` | 84 | Enchantments, runes, gem handling |
| `tailoring.gd` | 70 | Cloth armor, cloaks |

### `professions/gathering/` (4 files — all extend ProfessionBase)

| File | Lines | Summary |
|------|-------|---------|
| `herbalism.gd` | 66 | Herb/Dark Root gathering (Dark Root req. level 20) |
| `mining.gd` | 84 | Stone/Ore (lvl 5)/Crystal (lvl 15)/Ember Coal (lvl 25) |
| `skinning.gd` | 93 | Scavenging from bone nodes and enemy corpses |
| `woodcutting.gd` | 54 | Wood gathering from trees |

---

## 14. `scripts/progression/` — Endgame & Achievements (7 files)

| File | Extends | Lines | Autoload | Summary |
|------|---------|-------|----------|---------|
| `achievement_data.gd` | RefCounted | 121 | — | Achievement data structure: category, condition, rewards, hidden flag |
| `achievement_manager.gd` | Node | 442 | ✅ | Achievement tracking from EventBus signals, popup queue |
| `endgame_manager.gd` | Node | 374 | ✅ | Paragon levels (post-50), Nightmare dungeon tiers, NG+ system |
| `fast_travel.gd` | Node | 317 | ✅ | Waypoint discovery, cooldown-based teleportation |
| `stats_tracker.gd` | Node | 452 | ✅ | **Largest.** Player statistics: combat, economy, exploration, multiplayer |
| `world_event_data.gd` | RefCounted | 219 | — | World event data: type, position, radius, duration, participants |
| `world_event_manager.gd` | Node | 471 | ✅ | Random world event generation: corruption surge, invasion, treasure hunt |

---

## 15. `scripts/quest/` — Quest System (5 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `daily_quest_generator.gd` | Node | 300 | Daily (3/day, 6AM reset) and weekly quest generation from JSON templates |
| `quest_data.gd` | Resource | 98 | Quest definition: 8 types (MAIN/SIDE/BOUNTY/DUNGEON/GATHERING/DAILY/WEEKLY/EXPLORATION) |
| `quest_manager.gd` | Node | 733 | **Largest.** Central quest lifecycle (Autoload): accept/track/complete/turn-in, max 15 active |
| `quest_objective.gd` | Resource | 91 | Objective types: KILL/COLLECT/GATHER/REACH/TALK/CLEAR/CRAFT/EXPLORE/SURVIVE/ESCORT/USE_SKILL |
| `quest_rewards.gd` | Resource | 73 | Reward package: XP, gold, dark essence, items, skill points, reputation |

---

## 16. `scripts/tutorial/` — Tutorial & Onboarding (6 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `loading_screen_tips.gd` | CanvasLayer | 26 | Loading screen script, sets random tip on Hint label |
| `loading_tips.gd` | RefCounted | 121 | ~30 categorized gameplay tips (HU language) |
| `tutorial_data.gd` | RefCounted | 391 | Tutorial content: 20+ trigger IDs (first_movement, first_combat, first_boss, etc.) |
| `tutorial_highlight.gd` | Control | 261 | UI element highlight: golden frame pulse, arrow indicator, dim overlay |
| `tutorial_manager.gd` | Node | 445 | **Largest.** Tutorial system (Autoload): trigger tracking, popup queue, save/load |
| `tutorial_popup.gd` | Control | 281 | Tutorial popup UI: slide-in animation, auto-dismiss, key hints |

---

## 17. `scripts/ui/` — User Interface (28 files)

### Root (17 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `accessibility_settings_ui.gd` | VBoxContainer | 224 | Accessibility settings tab: colorblind, text size, screen shake |
| `controls_settings_ui.gd` | VBoxContainer | 236 | Key rebinding settings tab |
| `dialogue_ui.gd` | CanvasLayer | 197 | NPC dialogue display with typewriter effect, portrait |
| `gamepad_prompt_ui.gd` | Control | 71 | Controller/keyboard prompt auto-switching (Xbox layout) |
| `health_bar.gd` | Control | 109 | HP bar: green/yellow/red color, shield display, damage trail |
| `hud.gd` | Control | 136 | Player HUD: HP, Mana, XP bars, level, gold |
| `language_settings_ui.gd` | VBoxContainer | 85 | Language selection tab (Magyar / English) |
| `mana_bar.gd` | Control | 80 | Mana bar with regen pulse visualization |
| `minimap.gd` | Control | 151 | World minimap: player/enemy/NPC dots, biome colors, POI markers |
| `notification_ui.gd` | CanvasLayer | 145 | Pop-up notifications: loot, level up, achievement (max 5 visible) |
| `quest_log_ui.gd` | Control | 315 | Quest list with Active/Completed/Daily tabs, detail panel |
| `quest_tracker.gd` | Control | 197 | HUD mini quest tracker (right side, max 3 quests) |
| `settings_ui.gd` | Control | 283 | Settings menu with tabbed layout (audio, video, controls, etc.) |
| `skill_tree_ui.gd` | Control | 219 | Skill tree 3-branch visualization with point allocation |
| `subtitle_system.gd` | CanvasLayer | 131 | Subtitle and environmental sound captions |
| `tooltip_system.gd` | CanvasLayer | 173 | Generic tooltip with mouse follow, fade animation |
| `xp_bar.gd` | Control | 95 | XP bar with level-up glow animation |

### `ui/economy/` (7 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `crafting_ui.gd` | Control | 278 | Crafting station: recipe list, ingredients, progress bar |
| `currency_display.gd` | Control | 65 | HUD display: Gold, Dark Essence, Relic Fragments |
| `inventory_ui.gd` | Control | 322 | Inventory grid (6×5 = 30 slots) + equipment panel, drag & drop |
| `marketplace_ui.gd` | Control | 459 | **Largest UI.** Auction house: browse, filter, search, create listings |
| `shop_ui.gd` | Control | 265 | NPC shop: buy/sell/buyback tabs |
| `trade_ui.gd` | Control | 287 | Player-to-player trade: twin panel, 3s anti-scam confirm delay |
| `upgrade_ui.gd` | Control | 280 | Enhancement/enchanting/gem socketing interface |

### `ui/multiplayer/` (4 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `connection_ui.gd` | Control | 128 | Host/Join menu, IP/port input, connecting overlay |
| `disconnect_popup.gd` | Control | 56 | Disconnection overlay with reconnect button |
| `lobby_ui.gd` | Control | 162 | Lobby: player slots, class selection, ready/start buttons |
| `network_stats_overlay.gd` | CanvasLayer | 46 | Debug network stats (F3): ping, packet loss, tick rate |

---

## 18. `scripts/world/` — Procedural World Generation (20 files)

| File | Extends | Lines | Summary |
|------|---------|-------|---------|
| `biome_data.gd` | Resource | 91 | Biome properties: noise ranges, difficulty, loot bonus, level range |
| `biome_resolver.gd` | Node | 286 | Rule-based biome selection from noise values (height/temp/corruption/moisture) |
| `chunk.gd` | Node2D | 152 | Visual chunk: TileMap + containers for enemies/resources/decorations |
| `chunk_data.gd` | RefCounted | 188 | 16×16 chunk data: tile biomes, decorations, enemies, POIs, walkability |
| `chunk_manager.gd` | Node | 312 | Chunk lifecycle: load (3), simulate (5), unload (7) radii, background gen queue |
| `day_night_cycle.gd` | Node | 135 | Day/night cycle: 20min real = 1 game day, 4 phases (Dawn/Day/Dusk/Night) |
| `dungeon_placer.gd` | Node | 151 | Dungeon entrance spawn in world based on biome difficulty + distance |
| `environment_manager.gd` | Node | 203 | Biome ambient tint, weather particles, day/night CanvasModulate |
| `minimap_manager.gd` | Node | 194 | Minimap data generation: biome colors, POIs, fog of war |
| `noise_manager.gd` | Node | 133 | FastNoiseLite wrapper: 5 noise layers (height/temp/corruption/moisture/detail) |
| `npc_system.gd` | Node | 219 | NPC management: merchants, quest givers, service providers |
| `poi_generator.gd` | Node | 356 | **Largest.** POI placement: towns, villages, dungeons, boss arenas, shrines, caves |
| `resource_node.gd` | StaticBody2D | 218 | Gatherable resource node with profession integration, respawn timer |
| `road_generator.gd` | Node | 230 | A* road network between POIs (main + side roads, terrain cost) |
| `test_map.gd` | Node2D | 38 | Simple 20×20 test map for development |
| `tile_rules.gd` | Node | 169 | Tile selection: biome-specific ground/road colors, auto-tile rules |
| `weather_system.gd` | Node | 187 | Biome-specific weather (Clear/Cloudy/Rain/Snow/Fog/Sandstorm/Ash) |
| `world_generator.gd` | Node | 139 | World generation pipeline: noise → biome → POI → road → dungeon |
| `world_manager.gd` | Node | 335 | **Main world singleton (Autoload).** Orchestrates all world subsystems |
| `world_tileset_builder.gd` | RefCounted | 236 | Programmatic TileSet generation with placeholder sprites |

---

## Architecture Overview

### Autoload Singletons (13)
1. `GameManager` — Game state, pause
2. `EventBus` — Global signal bus
3. `Constants` — Global constants
4. `AudioManager` — Music + SFX
5. `InputManager` — Input handling
6. `SaveManager` — Save/load
7. `SceneManager` — Scene transitions
8. `AccessibilityManager` — Accessibility
9. `LocalizationManager` — i18n (HU/EN)
10. `DialogueManager` — Dialogue playback
11. `EconomyManager` — Economy hub
12. `NetworkManager` — Multiplayer
13. `WorldManager` — World generation

### Design Patterns
- **Component-based:** `HealthComponent`, `HitboxComponent`, `HurtboxComponent`
- **Resource-based data:** `ItemData`, `SkillData`, `QuestData`, `BossData`, `EnemyData`, `BiomeData`
- **Behaviour Trees:** Full BT implementation (Selector/Sequence/Decorator/Action/Condition)
- **Event-driven:** `EventBus` signal bus for decoupled systems
- **Host-authoritative multiplayer:** Server validates all combat, inventory, movement

### Key Game Parameters
- **Max Level:** 50 (then Paragon)
- **Tile Size:** 32px
- **Chunk Size:** 16×16 tiles
- **Max Players:** 4 co-op
- **Network Tick Rate:** 20/s (50ms)
- **Classes:** Assassin, Tank, Mage (3 branches each, 5 skills + ultimate per branch)
- **Biomes:** 8 (Meadow, Cursed Forest, Dark Swamp, Ancient Ruins, Mountains, Frozen Wastes, Plague Lands, Ashlands)
- **Boss Tiers:** T1 (solo) → T2 (group) → T3 (4-player) → T4 (raid)

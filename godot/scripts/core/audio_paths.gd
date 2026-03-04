## AudioPaths - Állandók az összes audio fájl útvonalához
## Használat: AudioManager.play_sfx(AudioPaths.SFX_SWORD_SWING)
class_name AudioPaths
extends RefCounted

# =============================================================================
#  ZENE TRACK-EK (8 track)
# =============================================================================
const MUSIC_MENU_THEME := "res://assets/audio/music/menu_theme.ogg"
const MUSIC_PEACEFUL_EXPLORATION := "res://assets/audio/music/peaceful_exploration.ogg"
const MUSIC_DARK_EXPLORATION := "res://assets/audio/music/dark_exploration.ogg"
const MUSIC_HOSTILE_LANDS := "res://assets/audio/music/hostile_lands.ogg"
const MUSIC_COMBAT_THEME := "res://assets/audio/music/combat_theme.ogg"
const MUSIC_DUNGEON_THEME := "res://assets/audio/music/dungeon_theme.ogg"
const MUSIC_BOSS_BATTLE := "res://assets/audio/music/boss_battle.ogg"
const MUSIC_VICTORY_FANFARE := "res://assets/audio/music/victory_fanfare.ogg"

# =============================================================================
#  COMBAT SFX (25-30 db)
# =============================================================================
# Melee
const SFX_SWORD_SWING := "res://assets/audio/sfx/combat/sword_swing.wav"
const SFX_SWORD_HIT_FLESH := "res://assets/audio/sfx/combat/sword_hit_flesh.wav"
const SFX_DAGGER_STAB := "res://assets/audio/sfx/combat/dagger_stab.wav"
const SFX_MACE_HIT := "res://assets/audio/sfx/combat/mace_hit.wav"
const SFX_AXE_CHOP := "res://assets/audio/sfx/combat/axe_chop.wav"
const SFX_SHIELD_BLOCK := "res://assets/audio/sfx/combat/shield_block.wav"
const SFX_SHIELD_BASH := "res://assets/audio/sfx/combat/shield_bash.wav"
const SFX_FIST_PUNCH := "res://assets/audio/sfx/combat/fist_punch.wav"

# Ranged
const SFX_ARROW_SHOOT := "res://assets/audio/sfx/combat/arrow_shoot.wav"
const SFX_ARROW_HIT := "res://assets/audio/sfx/combat/arrow_hit.wav"
const SFX_SPELL_CAST_GENERIC := "res://assets/audio/sfx/combat/spell_cast_generic.wav"
const SFX_FIREBALL_LAUNCH := "res://assets/audio/sfx/combat/fireball_launch.wav"
const SFX_FIREBALL_IMPACT := "res://assets/audio/sfx/combat/fireball_impact.wav"
const SFX_ICE_SHARD := "res://assets/audio/sfx/combat/ice_shard.wav"
const SFX_POISON_SPIT := "res://assets/audio/sfx/combat/poison_spit.wav"

# Impact
const SFX_HIT_PLAYER := "res://assets/audio/sfx/combat/hit_player.wav"
const SFX_HIT_ENEMY := "res://assets/audio/sfx/combat/hit_enemy.wav"
const SFX_CRITICAL_HIT := "res://assets/audio/sfx/combat/critical_hit.wav"
const SFX_DODGE_WHOOSH := "res://assets/audio/sfx/combat/dodge_whoosh.wav"
const SFX_DEATH_GENERIC := "res://assets/audio/sfx/combat/death_generic.wav"
const SFX_PLAYER_DEATH := "res://assets/audio/sfx/combat/player_death.wav"

# Special
const SFX_AOE_EXPLOSION := "res://assets/audio/sfx/combat/aoe_explosion.wav"
const SFX_HEAL_SPELL := "res://assets/audio/sfx/combat/heal_spell.wav"
const SFX_BUFF_APPLY := "res://assets/audio/sfx/combat/buff_apply.wav"
const SFX_DEBUFF_APPLY := "res://assets/audio/sfx/combat/debuff_apply.wav"
const SFX_LEVEL_UP := "res://assets/audio/sfx/combat/level_up.wav"

# =============================================================================
#  SKILL SFX (15-20 db)
# =============================================================================
# Assassin
const SFX_SHADOW_STEP := "res://assets/audio/sfx/skills/shadow_step.wav"
const SFX_SMOKE_BOMB := "res://assets/audio/sfx/skills/smoke_bomb.wav"
const SFX_POISON_APPLY := "res://assets/audio/sfx/skills/poison_apply.wav"
const SFX_BLOOD_SLASH := "res://assets/audio/sfx/skills/blood_slash.wav"

# Tank
const SFX_TAUNT_SHOUT := "res://assets/audio/sfx/skills/taunt_shout.wav"
const SFX_GROUND_SLAM := "res://assets/audio/sfx/skills/ground_slam.wav"
const SFX_CHAIN_PULL := "res://assets/audio/sfx/skills/chain_pull.wav"
const SFX_FORTIFY := "res://assets/audio/sfx/skills/fortify.wav"

# Mage
const SFX_ARCANE_BLAST := "res://assets/audio/sfx/skills/arcane_blast.wav"
const SFX_FROST_NOVA := "res://assets/audio/sfx/skills/frost_nova.wav"
const SFX_HOLY_LIGHT := "res://assets/audio/sfx/skills/holy_light.wav"
const SFX_TELEPORT := "res://assets/audio/sfx/skills/teleport.wav"

# =============================================================================
#  UI SFX (10-15 db)
# =============================================================================
const SFX_BUTTON_CLICK := "res://assets/audio/sfx/ui/button_click.wav"
const SFX_BUTTON_HOVER := "res://assets/audio/sfx/ui/button_hover.wav"
const SFX_INVENTORY_OPEN := "res://assets/audio/sfx/ui/inventory_open.wav"
const SFX_INVENTORY_CLOSE := "res://assets/audio/sfx/ui/inventory_close.wav"
const SFX_ITEM_PICKUP := "res://assets/audio/sfx/ui/item_pickup.wav"
const SFX_ITEM_EQUIP := "res://assets/audio/sfx/ui/item_equip.wav"
const SFX_ITEM_DROP := "res://assets/audio/sfx/ui/item_drop.wav"
const SFX_GOLD_PICKUP := "res://assets/audio/sfx/ui/gold_pickup.wav"
const SFX_QUEST_ACCEPT := "res://assets/audio/sfx/ui/quest_accept.wav"
const SFX_QUEST_COMPLETE := "res://assets/audio/sfx/ui/quest_complete.wav"
const SFX_NOTIFICATION := "res://assets/audio/sfx/ui/notification.wav"
const SFX_ERROR_BUZZ := "res://assets/audio/sfx/ui/error_buzz.wav"
const SFX_SKILL_UNLOCK := "res://assets/audio/sfx/ui/skill_unlock.wav"

# =============================================================================
#  AMBIENT / ENVIRONMENT SFX (10-15 db)
# =============================================================================
const SFX_WIND_LIGHT := "res://assets/audio/sfx/environment/wind_light.wav"
const SFX_WIND_HOWLING := "res://assets/audio/sfx/environment/wind_howling.wav"
const SFX_RAIN_LOOP := "res://assets/audio/sfx/environment/rain_loop.wav"
const SFX_THUNDER := "res://assets/audio/sfx/environment/thunder.wav"
const SFX_FIRE_CRACKLE := "res://assets/audio/sfx/environment/fire_crackle.wav"
const SFX_WATER_DRIP := "res://assets/audio/sfx/environment/water_drip.wav"
const SFX_SWAMP_BUBBLES := "res://assets/audio/sfx/environment/swamp_bubbles.wav"
const SFX_CROW_CAW := "res://assets/audio/sfx/environment/crow_caw.wav"
const SFX_CRICKETS := "res://assets/audio/sfx/environment/crickets.wav"
const SFX_DUNGEON_AMBIENCE := "res://assets/audio/sfx/environment/dungeon_ambience.wav"
const SFX_BOSS_INTRO_RUMBLE := "res://assets/audio/sfx/environment/boss_intro_rumble.wav"

# =============================================================================
#  EGYÉB SFX (5-10 db)
# =============================================================================
const SFX_CHEST_OPEN := "res://assets/audio/sfx/environment/chest_open.wav"
const SFX_DOOR_OPEN := "res://assets/audio/sfx/environment/door_open.wav"
const SFX_DOOR_LOCKED := "res://assets/audio/sfx/environment/door_locked.wav"
const SFX_PORTAL_ACTIVATE := "res://assets/audio/sfx/environment/portal_activate.wav"
const SFX_TRAP_TRIGGER := "res://assets/audio/sfx/environment/trap_trigger.wav"
const SFX_GATHERING_CHOP := "res://assets/audio/sfx/environment/gathering_chop.wav"
const SFX_GATHERING_MINE := "res://assets/audio/sfx/environment/gathering_mine.wav"
const SFX_GATHERING_PICK := "res://assets/audio/sfx/environment/gathering_pick.wav"
const SFX_GEM_SOCKET := "res://assets/audio/sfx/environment/gem_socket.wav"
const SFX_CRAFT_ANVIL := "res://assets/audio/sfx/environment/craft_anvil.wav"

# =============================================================================
#  AMBIENT LOOP-OK (biome-onként)
# =============================================================================
const AMBIENT_MEADOW := "res://assets/audio/ambient/meadow_ambient.ogg"
const AMBIENT_FOREST := "res://assets/audio/ambient/forest_ambient.ogg"
const AMBIENT_SWAMP := "res://assets/audio/ambient/swamp_ambient.ogg"
const AMBIENT_RUINS := "res://assets/audio/ambient/ruins_ambient.ogg"
const AMBIENT_MOUNTAINS := "res://assets/audio/ambient/mountains_ambient.ogg"
const AMBIENT_FROZEN := "res://assets/audio/ambient/frozen_ambient.ogg"
const AMBIENT_ASHLANDS := "res://assets/audio/ambient/ashlands_ambient.ogg"
const AMBIENT_PLAGUE := "res://assets/audio/ambient/plague_ambient.ogg"
const AMBIENT_DUNGEON := "res://assets/audio/ambient/dungeon_ambient.ogg"

# =============================================================================
#  BIOME → ZENE MAPPING
# =============================================================================
## Visszaadja a megfelelő exploration zenét a biome típushoz
static func get_biome_music(biome: Enums.BiomeType) -> String:
	match biome:
		Enums.BiomeType.STARTING_MEADOW:
			return MUSIC_PEACEFUL_EXPLORATION
		Enums.BiomeType.CURSED_FOREST, Enums.BiomeType.DARK_SWAMP, Enums.BiomeType.RUINS:
			return MUSIC_DARK_EXPLORATION
		Enums.BiomeType.MOUNTAINS, Enums.BiomeType.FROZEN_WASTES, \
		Enums.BiomeType.ASHLANDS, Enums.BiomeType.PLAGUE_LANDS:
			return MUSIC_HOSTILE_LANDS
		_:
			return MUSIC_PEACEFUL_EXPLORATION


## Visszaadja a biome ambient hangját
static func get_biome_ambient(biome: Enums.BiomeType) -> String:
	match biome:
		Enums.BiomeType.STARTING_MEADOW:
			return AMBIENT_MEADOW
		Enums.BiomeType.CURSED_FOREST:
			return AMBIENT_FOREST
		Enums.BiomeType.DARK_SWAMP:
			return AMBIENT_SWAMP
		Enums.BiomeType.RUINS:
			return AMBIENT_RUINS
		Enums.BiomeType.MOUNTAINS:
			return AMBIENT_MOUNTAINS
		Enums.BiomeType.FROZEN_WASTES:
			return AMBIENT_FROZEN
		Enums.BiomeType.ASHLANDS:
			return AMBIENT_ASHLANDS
		Enums.BiomeType.PLAGUE_LANDS:
			return AMBIENT_PLAGUE
		_:
			return AMBIENT_MEADOW

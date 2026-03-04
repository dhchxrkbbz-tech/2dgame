## BatchExport - Központi batch export tool
## Ez a script az összes generátort meghívja és PNG-be exportálja az összes sprite-ot.
## Futtatás: Godot editorban hozz létre egy Node-ot ezzel a scripttel és hívd meg az export_all()-t.
@tool
class_name BatchExport
extends Node

const EXPORT_BASE := "res://assets/generated/"

## Teljes export: az összes generátor meghívása
static func export_all() -> void:
	var start := Time.get_ticks_msec()
	print("=" .repeat(60))
	print("  ASHENFALL - Batch Asset Export")
	print("=" .repeat(60))
	print("")

	# Könyvtárak létrehozása
	_ensure_dirs()

	# 1. Karakterek
	print("[1/10] Karakter sprite-ok...")
	AssassinGenerator.export_all(EXPORT_BASE)
	TankGenerator.export_all(EXPORT_BASE)
	MageGenerator.export_all(EXPORT_BASE)

	# 2. Ellenségek (8 biome)
	print("[2/10] Ellenség sprite-ok (8 biome)...")
	AshenWastesEnemies.export_all(EXPORT_BASE)
	CorruptedForestEnemies.export_all(EXPORT_BASE)
	CrystalCavernsEnemies.export_all(EXPORT_BASE)
	FrozenPeaksEnemies.export_all(EXPORT_BASE)
	ShadowMarshEnemies.export_all(EXPORT_BASE)
	VolcanicDepthsEnemies.export_all(EXPORT_BASE)
	NecroticRuinsEnemies.export_all(EXPORT_BASE)
	VoidRealmEnemies.export_all(EXPORT_BASE)

	# 3. Bossok (3 tier)
	print("[3/10] Boss sprite-ok...")
	Tier1Bosses.export_all(EXPORT_BASE)
	Tier2Bosses.export_all(EXPORT_BASE)
	Tier3_4Bosses.export_all(EXPORT_BASE)

	# 4. NPC-k
	print("[4/10] NPC sprite-ok...")
	NpcGenerator.export_all(EXPORT_BASE)

	# 5. Tileset-ek
	print("[5/10] Tileset-ek...")
	WorldTilesetGenerator.export_all(EXPORT_BASE)
	DungeonTilesetGenerator.export_all(EXPORT_BASE)

	# 6. Propok
	print("[6/10] Propok...")
	WorldPropsGenerator.export_all(EXPORT_BASE)
	DungeonPropsGenerator.export_all(EXPORT_BASE)

	# 7. Ikonok
	print("[7/10] Ikonok...")
	ItemIconGenerator.export_all(EXPORT_BASE)
	SkillIconGenerator.export_all(EXPORT_BASE)
	GemIconGenerator.export_all(EXPORT_BASE)
	HudIconGenerator.export_all(EXPORT_BASE)

	# 8. VFX / Effektek
	print("[8/10] VFX effektek...")
	VfxGenerator.export_all(EXPORT_BASE)
	CombatVfxGenerator.export_all(EXPORT_BASE)
	ParticleTextures.export_all(EXPORT_BASE)

	# 9. UI elemek
	print("[9/10] UI elemek...")
	UIElementGenerator.export_all(EXPORT_BASE)

	# 10. Misc ikonok
	print("[10/10] Misc ikonok...")
	MiscIconGenerator.export_all(EXPORT_BASE)

	var elapsed := (Time.get_ticks_msec() - start) / 1000.0
	print("")
	print("=" .repeat(60))
	print("  Export kész! Idő: %.2f mp" % elapsed)
	print("  Kimeneti mappa: %s" % EXPORT_BASE)
	print("=" .repeat(60))

## Szükséges könyvtárak létrehozása
static func _ensure_dirs() -> void:
	var dirs := [
		"characters/assassin", "characters/tank", "characters/mage",
		"enemies/ashen_wastes", "enemies/corrupted_forest", "enemies/crystal_caverns",
		"enemies/frozen_peaks", "enemies/shadow_marsh", "enemies/volcanic_depths",
		"enemies/necrotic_ruins", "enemies/void_realm",
		"bosses/tier1", "bosses/tier2", "bosses/tier3", "bosses/tier4",
		"npcs",
		"tilesets/world", "tilesets/dungeon",
		"props/world", "props/dungeon",
		"icons/items/weapons", "icons/items/armor", "icons/items/accessories",
		"icons/items/consumables", "icons/items/crafting",
		"icons/skills", "icons/gems/normal", "icons/gems/legendary",
		"icons/hud/currency", "icons/hud/stats", "icons/hud/status",
		"icons/misc/minimap", "icons/misc/tutorial",
		"icons/misc/achievements/combat", "icons/misc/achievements/exploration",
		"icons/misc/achievements/progression", "icons/misc/achievements/social",
		"icons/misc/achievements/crafting", "icons/misc/achievements/story",
		"icons/misc/achievements/collection",
		"icons/misc/controller", "icons/misc/keyboard",
		"effects/skills", "effects/combat", "effects/combat/dmg_font", "effects/particles",
		"ui/panels", "ui/bars", "ui/hud", "ui/dialog", "ui/tooltip",
		"ui/buttons", "ui/skill_tree", "ui/misc",
	]
	for d in dirs:
		var full_path := EXPORT_BASE + d
		DirAccess.make_dir_recursive_absolute(full_path)

## Csak egy kategóriát exportál (teszteléshez)
static func export_category(category: String) -> void:
	_ensure_dirs()
	match category:
		"characters":
			AssassinGenerator.export_all(EXPORT_BASE)
			TankGenerator.export_all(EXPORT_BASE)
			MageGenerator.export_all(EXPORT_BASE)
		"enemies":
			AshenWastesEnemies.export_all(EXPORT_BASE)
			CorruptedForestEnemies.export_all(EXPORT_BASE)
			CrystalCavernsEnemies.export_all(EXPORT_BASE)
			FrozenPeaksEnemies.export_all(EXPORT_BASE)
			ShadowMarshEnemies.export_all(EXPORT_BASE)
			VolcanicDepthsEnemies.export_all(EXPORT_BASE)
			NecroticRuinsEnemies.export_all(EXPORT_BASE)
			VoidRealmEnemies.export_all(EXPORT_BASE)
		"bosses":
			Tier1Bosses.export_all(EXPORT_BASE)
			Tier2Bosses.export_all(EXPORT_BASE)
			Tier3_4Bosses.export_all(EXPORT_BASE)
		"npcs":
			NpcGenerator.export_all(EXPORT_BASE)
		"tilesets":
			WorldTilesetGenerator.export_all(EXPORT_BASE)
			DungeonTilesetGenerator.export_all(EXPORT_BASE)
		"props":
			WorldPropsGenerator.export_all(EXPORT_BASE)
			DungeonPropsGenerator.export_all(EXPORT_BASE)
		"icons":
			ItemIconGenerator.export_all(EXPORT_BASE)
			SkillIconGenerator.export_all(EXPORT_BASE)
			GemIconGenerator.export_all(EXPORT_BASE)
			HudIconGenerator.export_all(EXPORT_BASE)
		"vfx":
			VfxGenerator.export_all(EXPORT_BASE)
			CombatVfxGenerator.export_all(EXPORT_BASE)
			ParticleTextures.export_all(EXPORT_BASE)
		"ui":
			UIElementGenerator.export_all(EXPORT_BASE)
		"misc":
			MiscIconGenerator.export_all(EXPORT_BASE)
		_:
			push_error("Unknown category: " + category)

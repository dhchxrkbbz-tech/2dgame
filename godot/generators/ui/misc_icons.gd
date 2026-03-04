## MiscIconGenerator - Vegyes ikonok (~122 db)
## Minimap ikonok(14), tutorial ikonok(8), achievement ikonok(~70), controller prompt(30)
class_name MiscIconGenerator
extends PixelArtBase

# ==================== MINIMAP IKONOK (16×16) ====================
static func gen_minimap_icon(icon_type: String) -> Image:
	var img := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match icon_type:
		"player":
			# Zöld háromszög felfelé
			fill_rect(img, 7, 4, 2, 8, Color(0.20, 0.85, 0.20))
			fill_rect(img, 6, 6, 4, 6, Color(0.20, 0.85, 0.20))
			fill_rect(img, 5, 8, 6, 4, Color(0.20, 0.85, 0.20))
		"enemy":
			draw_circle(img, 8, 8, 4, Color(0.85, 0.15, 0.10))
		"boss":
			draw_circle(img, 8, 8, 5, Color(0.85, 0.15, 0.10))
			draw_circle_outline(img, 8, 8, 6, Color(1.0, 0.30, 0.20))
		"npc":
			draw_circle(img, 8, 8, 4, Color(0.20, 0.60, 0.85))
		"quest_npc":
			draw_circle(img, 8, 8, 4, Color(0.85, 0.75, 0.15))
			_set_pixel_safe(img, 8, 5, Color(1.0, 1.0, 0.50))
		"shop":
			fill_rect(img, 4, 6, 8, 8, Color(0.65, 0.50, 0.15))
			fill_rect(img, 6, 4, 4, 4, Color(0.70, 0.55, 0.20))
		"portal":
			draw_circle_outline(img, 8, 8, 5, Color(0.50, 0.20, 0.80))
			draw_circle(img, 8, 8, 2, Color(0.60, 0.30, 0.90))
		"dungeon":
			fill_rect(img, 4, 4, 8, 8, Color(0.30, 0.28, 0.24))
			fill_rect(img, 6, 10, 4, 4, Color(0.20, 0.18, 0.14))
		"chest":
			fill_rect(img, 4, 6, 8, 6, Color(0.60, 0.45, 0.10))
			fill_rect(img, 4, 6, 8, 2, Color(0.65, 0.50, 0.15))
		"waypoint":
			draw_circle(img, 8, 8, 5, Color(0.30, 0.70, 0.40, 0.6))
			draw_circle(img, 8, 8, 2, Color(0.40, 0.85, 0.50))
		"party_member":
			draw_circle(img, 8, 8, 4, Color(0.15, 0.75, 0.15))
		"objective":
			_set_pixel_safe(img, 8, 4, Color(1.0, 0.90, 0.20))
			fill_rect(img, 7, 5, 2, 5, Color(1.0, 0.85, 0.15))
			_set_pixel_safe(img, 8, 12, Color(1.0, 0.85, 0.15))
		"resource":
			draw_circle(img, 8, 8, 3, Color(0.50, 0.80, 0.30))
		"danger_zone":
			draw_circle_outline(img, 8, 8, 6, Color(0.85, 0.20, 0.10, 0.5))
			draw_line_px(img, 4, 4, 12, 12, Color(0.85, 0.20, 0.10))
			draw_line_px(img, 12, 4, 4, 12, Color(0.85, 0.20, 0.10))
	return img

# ==================== TUTORIAL IKONOK (32×32) ====================
static func gen_tutorial_icon(tutorial_type: String) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	draw_circle(img, 16, 16, 14, Color(0.08, 0.06, 0.04, 0.85))
	draw_circle_outline(img, 16, 16, 14, Color(0.60, 0.50, 0.18))
	match tutorial_type:
		"move":
			# WASD nyilak
			_set_pixel_safe(img, 16, 10, Color(0.85, 0.80, 0.70))
			_set_pixel_safe(img, 12, 16, Color(0.85, 0.80, 0.70))
			_set_pixel_safe(img, 16, 22, Color(0.85, 0.80, 0.70))
			_set_pixel_safe(img, 20, 16, Color(0.85, 0.80, 0.70))
			draw_circle(img, 16, 16, 2, Color(0.65, 0.55, 0.20))
		"attack":
			# Kard szimbólum
			fill_rect(img, 15, 8, 2, 12, Color(0.70, 0.68, 0.60))
			fill_rect(img, 12, 18, 8, 2, Color(0.50, 0.35, 0.12))
		"skill":
			# Csillag
			draw_circle(img, 16, 16, 4, Color(0.40, 0.65, 0.90))
			for i in range(4):
				var angle := i * PI / 2.0
				_set_pixel_safe(img, int(16 + cos(angle) * 8), int(16 + sin(angle) * 8), Color(0.40, 0.65, 0.90))
		"inventory":
			# Táska
			fill_rect(img, 10, 12, 12, 10, Color(0.45, 0.30, 0.12))
			fill_rect(img, 12, 8, 8, 6, Color(0.50, 0.35, 0.15))
		"quest":
			# Felkiáltójel
			fill_rect(img, 14, 8, 4, 10, Color(0.85, 0.75, 0.15))
			fill_rect(img, 14, 20, 4, 4, Color(0.85, 0.75, 0.15))
		"map":
			# Térkép
			fill_rect(img, 8, 10, 16, 12, Color(0.75, 0.68, 0.50))
			draw_line_px(img, 10, 14, 18, 18, Color(0.50, 0.35, 0.15))
			_set_pixel_safe(img, 18, 18, Color(0.85, 0.15, 0.10))
		"dodge":
			# Nyíl oldalra
			draw_line_px(img, 10, 16, 22, 16, Color(0.40, 0.75, 0.85))
			fill_rect(img, 18, 12, 2, 8, Color(0.40, 0.75, 0.85))
			_set_pixel_safe(img, 20, 14, Color(0.40, 0.75, 0.85))
			_set_pixel_safe(img, 20, 18, Color(0.40, 0.75, 0.85))
		"interact":
			# Kéz szimbólum
			fill_rect(img, 12, 10, 8, 12, Color(0.75, 0.60, 0.45))
			fill_rect(img, 10, 14, 4, 4, Color(0.75, 0.60, 0.45))
	return img

# ==================== ACHIEVEMENT IKONOK (32×32) ====================
const ACHIEVEMENT_CATEGORIES := {
	"combat": {"color": Color(0.70, 0.15, 0.10), "items": ["first_kill", "100_kills", "1000_kills", "elite_slayer", "boss_slayer", "no_damage_boss", "combo_master", "crit_streak", "dodge_master", "tank_expert"]},
	"exploration": {"color": Color(0.20, 0.60, 0.30), "items": ["first_biome", "all_biomes", "secret_area", "100_rooms", "dungeon_clear", "full_map", "treasure_hunter", "fastest_clear"]},
	"progression": {"color": Color(0.60, 0.50, 0.15), "items": ["level_10", "level_25", "level_50", "max_level", "first_skill", "full_tree", "all_classes", "prestige"]},
	"social": {"color": Color(0.30, 0.50, 0.80), "items": ["first_party", "full_party", "trade_100", "guild_join", "pvp_win", "coop_boss"]},
	"crafting": {"color": Color(0.50, 0.35, 0.15), "items": ["first_craft", "100_crafts", "legendary_craft", "all_recipes", "master_smith", "gem_master"]},
	"story": {"color": Color(0.55, 0.20, 0.60), "items": ["prologue", "act1", "act2", "act3", "final_boss", "true_ending", "all_dialogues", "lore_master"]},
	"collection": {"color": Color(0.70, 0.60, 0.10), "items": ["10_legendaries", "full_set", "all_gems", "bestiary_25", "bestiary_full", "all_npcs", "completionist"]},
}

static func gen_achievement_icon(category: String, index: int) -> Image:
	var img := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	var col: Color = ACHIEVEMENT_CATEGORIES.get(category, ACHIEVEMENT_CATEGORIES["combat"])["color"]
	# Háttér
	img.fill(Color(0.06, 0.05, 0.04))
	# Kategória-színű keret
	draw_circle_outline(img, 16, 16, 14, col)
	draw_circle_outline(img, 16, 16, 13, col.darkened(0.2))
	# Szimbólum (egyszerű, index alapján variált)
	var rng := RandomNumberGenerator.new()
	rng.seed = index * 1234 + category.hash()
	match category:
		"combat":
			# Kard variáns
			var angle := float(index) * 0.3
			draw_line_px(img, int(16 + cos(angle) * 8), int(16 + sin(angle) * 8), int(16 - cos(angle) * 8), int(16 - sin(angle) * 8), col)
			draw_circle(img, 16, 16, 3, col.lightened(0.2))
		"exploration":
			# Iránytű / lépés
			draw_circle_outline(img, 16, 16, 8, col)
			_set_pixel_safe(img, 16, 8 + index, col.lightened(0.3))
		"progression":
			# Felfelé nyíl + szám
			fill_rect(img, 14, 8, 4, 12, col)
			fill_rect(img, 12, 10, 8, 2, col)
			_set_pixel_safe(img, 16, 7, col.lightened(0.3))
		"social":
			# Emberek
			draw_circle(img, 12, 12, 3 + index % 2, col)
			draw_circle(img, 20, 14, 3, col)
		"crafting":
			# Kalapács
			fill_rect(img, 14, 14, 4, 10, col)
			fill_rect(img, 10, 10, 12, 6, col.lightened(0.1))
		"story":
			# Könyv
			fill_rect(img, 8, 8, 16, 16, col.darkened(0.2))
			fill_rect(img, 10, 10, 12, 12, col)
			fill_rect(img, 16, 8, 1, 16, col.lightened(0.2))
		"collection":
			# Csillag
			draw_circle(img, 16, 16, 4 + index % 3, col)
			for a in range(5):
				var rad := a * 2.0 * PI / 5.0 - PI / 2.0
				_set_pixel_safe(img, int(16 + cos(rad) * 8), int(16 + sin(rad) * 8), col.lightened(0.3))
	return img

# ==================== CONTROLLER PROMPT IKONOK (24×24) ====================
static func gen_controller_icon(button_type: String) -> Image:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match button_type:
		"a_button":
			draw_circle(img, 12, 12, 9, Color(0.20, 0.65, 0.20))
			draw_circle_outline(img, 12, 12, 9, Color(0.25, 0.70, 0.25))
		"b_button":
			draw_circle(img, 12, 12, 9, Color(0.70, 0.15, 0.10))
			draw_circle_outline(img, 12, 12, 9, Color(0.75, 0.20, 0.15))
		"x_button":
			draw_circle(img, 12, 12, 9, Color(0.15, 0.35, 0.70))
			draw_circle_outline(img, 12, 12, 9, Color(0.20, 0.40, 0.75))
		"y_button":
			draw_circle(img, 12, 12, 9, Color(0.75, 0.65, 0.10))
			draw_circle_outline(img, 12, 12, 9, Color(0.80, 0.70, 0.15))
		"lb":
			fill_rect(img, 2, 6, 20, 12, Color(0.30, 0.28, 0.25))
			fill_rect(img, 4, 8, 16, 8, Color(0.35, 0.33, 0.28))
		"rb":
			fill_rect(img, 2, 6, 20, 12, Color(0.30, 0.28, 0.25))
			fill_rect(img, 4, 8, 16, 8, Color(0.35, 0.33, 0.28))
		"lt":
			fill_rect(img, 4, 2, 16, 18, Color(0.30, 0.28, 0.25))
			fill_rect(img, 6, 4, 12, 14, Color(0.35, 0.33, 0.28))
		"rt":
			fill_rect(img, 4, 2, 16, 18, Color(0.30, 0.28, 0.25))
			fill_rect(img, 6, 4, 12, 14, Color(0.35, 0.33, 0.28))
		"start":
			fill_rect(img, 6, 8, 12, 8, Color(0.40, 0.38, 0.35))
			fill_rect(img, 8, 10, 2, 4, Color(0.60, 0.58, 0.52))
			fill_rect(img, 12, 10, 2, 4, Color(0.60, 0.58, 0.52))
		"select":
			fill_rect(img, 6, 8, 12, 8, Color(0.40, 0.38, 0.35))
			fill_rect(img, 8, 11, 8, 2, Color(0.60, 0.58, 0.52))
		"dpad_up":
			fill_rect(img, 8, 2, 8, 20, Color(0.30, 0.28, 0.25))
			fill_rect(img, 2, 8, 20, 8, Color(0.30, 0.28, 0.25))
			fill_rect(img, 9, 3, 6, 6, Color(0.50, 0.48, 0.42))
		"dpad_down":
			fill_rect(img, 8, 2, 8, 20, Color(0.30, 0.28, 0.25))
			fill_rect(img, 2, 8, 20, 8, Color(0.30, 0.28, 0.25))
			fill_rect(img, 9, 15, 6, 6, Color(0.50, 0.48, 0.42))
		"dpad_left":
			fill_rect(img, 8, 2, 8, 20, Color(0.30, 0.28, 0.25))
			fill_rect(img, 2, 8, 20, 8, Color(0.30, 0.28, 0.25))
			fill_rect(img, 3, 9, 6, 6, Color(0.50, 0.48, 0.42))
		"dpad_right":
			fill_rect(img, 8, 2, 8, 20, Color(0.30, 0.28, 0.25))
			fill_rect(img, 2, 8, 20, 8, Color(0.30, 0.28, 0.25))
			fill_rect(img, 15, 9, 6, 6, Color(0.50, 0.48, 0.42))
		"lstick":
			draw_circle(img, 12, 12, 8, Color(0.28, 0.26, 0.24))
			draw_circle(img, 12, 12, 5, Color(0.35, 0.33, 0.30))
			draw_circle_outline(img, 12, 12, 8, Color(0.38, 0.36, 0.32))
		"rstick":
			draw_circle(img, 12, 12, 8, Color(0.28, 0.26, 0.24))
			draw_circle(img, 12, 12, 5, Color(0.35, 0.33, 0.30))
			draw_circle_outline(img, 12, 12, 8, Color(0.38, 0.36, 0.32))
	return img

# --- Keyboard input prompt (24×24) ---
static func gen_key_icon(key_label: String) -> Image:
	var img := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	# Gomb háttér
	fill_rect(img, 2, 2, 20, 18, Color(0.25, 0.24, 0.22))
	fill_rect(img, 3, 3, 18, 16, Color(0.32, 0.30, 0.28))
	fill_rect(img, 2, 18, 20, 4, Color(0.20, 0.19, 0.17))
	# Keret
	fill_rect(img, 2, 2, 20, 1, Color(0.40, 0.38, 0.35))
	fill_rect(img, 2, 21, 20, 1, Color(0.15, 0.14, 0.12))
	return img

static func get_minimap_icon_types() -> Array:
	return ["player", "enemy", "boss", "npc", "quest_npc", "shop", "portal", "dungeon", "chest", "waypoint", "party_member", "objective", "resource", "danger_zone"]

static func get_tutorial_types() -> Array:
	return ["move", "attack", "skill", "inventory", "quest", "map", "dodge", "interact"]

static func get_controller_buttons() -> Array:
	return ["a_button", "b_button", "x_button", "y_button", "lb", "rb", "lt", "rt", "start", "select", "dpad_up", "dpad_down", "dpad_left", "dpad_right", "lstick", "rstick"]

static func export_all(base_path: String) -> void:
	var path := base_path + "icons/misc/"
	# Minimap
	for mt in get_minimap_icon_types():
		save_png(gen_minimap_icon(mt), path + "minimap/%s.png" % mt)
	# Tutorial
	for tt in get_tutorial_types():
		save_png(gen_tutorial_icon(tt), path + "tutorial/%s.png" % tt)
	# Achievement
	for cat in ACHIEVEMENT_CATEGORIES.keys():
		var items: Array = ACHIEVEMENT_CATEGORIES[cat]["items"]
		for i in range(items.size()):
			save_png(gen_achievement_icon(cat, i), path + "achievements/%s/%s.png" % [cat, items[i]])
	# Controller
	for cb in get_controller_buttons():
		save_png(gen_controller_icon(cb), path + "controller/%s.png" % cb)
	# Keyboard prompt template
	for key in ["W", "A", "S", "D", "E", "Q", "R", "F", "Tab", "Esc", "Space", "Shift", "Ctrl", "1"]:
		save_png(gen_key_icon(key), path + "keyboard/key_%s.png" % key.to_lower())
	print("  ✓ Misc icons exported to: ", path)

## UIElementGenerator - UI elemek (~90 db)
## Inventory panel, equipment panel, HP/Mana/XP bar, skill bar, dialog box, tooltip, button, skill tree BG stb.
class_name UIElementGenerator
extends PixelArtBase

const UI_BG := Color(0.08, 0.06, 0.05, 0.92)
const UI_BORDER := Color(0.35, 0.28, 0.18)
const UI_ACCENT := Color(0.65, 0.55, 0.20)
const UI_TEXT := Color(0.85, 0.80, 0.70)
const UI_DARK := Color(0.04, 0.03, 0.02, 0.95)

# --- Panel (általános keret) ---
static func gen_panel(w: int, h: int, title_bar: bool) -> Image:
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(UI_BG)
	# Keret
	fill_rect(img, 0, 0, w, 2, UI_BORDER)
	fill_rect(img, 0, h - 2, w, 2, UI_BORDER)
	fill_rect(img, 0, 0, 2, h, UI_BORDER)
	fill_rect(img, w - 2, 0, 2, h, UI_BORDER)
	# Sarok díszek
	fill_rect(img, 0, 0, 4, 4, UI_ACCENT)
	fill_rect(img, w - 4, 0, 4, 4, UI_ACCENT)
	fill_rect(img, 0, h - 4, 4, 4, UI_ACCENT)
	fill_rect(img, w - 4, h - 4, 4, 4, UI_ACCENT)
	if title_bar:
		fill_rect(img, 2, 2, w - 4, 16, UI_BORDER.darkened(0.15))
		fill_rect(img, 2, 16, w - 4, 2, UI_ACCENT)
	return img

# --- Inventory panel (9×6 grid, 320×240) ---
static func gen_inventory_panel() -> Image:
	var img := gen_panel(320, 240, true)
	# Grid (9 oszlop × 6 sor)
	for gx in range(9):
		for gy in range(6):
			var x := 8 + gx * 34
			var y := 24 + gy * 34
			fill_rect(img, x, y, 32, 32, UI_DARK)
			fill_rect(img, x, y, 32, 1, UI_BORDER.darkened(0.1))
			fill_rect(img, x, y, 1, 32, UI_BORDER.darkened(0.1))
	return img

# --- Equipment panel (karakter + slot-ok, 200×280) ---
static func gen_equipment_panel() -> Image:
	var img := gen_panel(200, 280, true)
	# Karakter placeholder középen
	fill_rect(img, 60, 30, 80, 120, UI_DARK.lightened(0.05))
	draw_circle_outline(img, 100, 70, 15, UI_BORDER)
	# Slot pozíciók
	var slots := [
		Vector2i(10, 40),   # Sisak
		Vector2i(10, 80),   # Mellvért
		Vector2i(10, 120),  # Nadrág
		Vector2i(10, 160),  # Csizma
		Vector2i(155, 40),  # Kesztyű
		Vector2i(155, 80),  # Köpeny
		Vector2i(155, 120), # Gyűrű ​1
		Vector2i(155, 160), # Gyűrű 2
		Vector2i(60, 170),  # Fegyver
		Vector2i(110, 170), # Offhand
		Vector2i(85, 210),  # Amulett
	]
	for slot in slots:
		fill_rect(img, slot.x, slot.y, 32, 32, UI_DARK)
		fill_rect(img, slot.x, slot.y, 32, 1, UI_BORDER)
		fill_rect(img, slot.x, slot.y, 1, 32, UI_BORDER)
		fill_rect(img, slot.x + 31, slot.y, 1, 32, UI_BORDER)
		fill_rect(img, slot.x, slot.y + 31, 32, 1, UI_BORDER)
	return img

# --- HP bár (200×16) ---
static func gen_hp_bar(fill_pct: float) -> Image:
	var img := Image.create(200, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.06, 0.04, 0.04, 0.8))
	var filled := int(fill_pct * 196)
	fill_rect(img, 2, 2, filled, 12, Color(0.70, 0.10, 0.08))
	fill_rect(img, 2, 2, filled, 4, Color(0.85, 0.15, 0.10))
	# Keret
	fill_rect(img, 0, 0, 200, 1, UI_BORDER)
	fill_rect(img, 0, 15, 200, 1, UI_BORDER)
	fill_rect(img, 0, 0, 1, 16, UI_BORDER)
	fill_rect(img, 199, 0, 1, 16, UI_BORDER)
	return img

# --- Mana bár (200×16) ---
static func gen_mana_bar(fill_pct: float) -> Image:
	var img := Image.create(200, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.04, 0.04, 0.06, 0.8))
	var filled := int(fill_pct * 196)
	fill_rect(img, 2, 2, filled, 12, Color(0.10, 0.20, 0.70))
	fill_rect(img, 2, 2, filled, 4, Color(0.15, 0.30, 0.85))
	fill_rect(img, 0, 0, 200, 1, UI_BORDER)
	fill_rect(img, 0, 15, 200, 1, UI_BORDER)
	fill_rect(img, 0, 0, 1, 16, UI_BORDER)
	fill_rect(img, 199, 0, 1, 16, UI_BORDER)
	return img

# --- XP bár (300×10) ---
static func gen_xp_bar(fill_pct: float) -> Image:
	var img := Image.create(300, 10, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.04, 0.04, 0.04, 0.7))
	var filled := int(fill_pct * 296)
	fill_rect(img, 2, 2, filled, 6, Color(0.20, 0.55, 0.80))
	fill_rect(img, 2, 2, filled, 2, Color(0.30, 0.65, 0.90))
	fill_rect(img, 0, 0, 300, 1, UI_BORDER.darkened(0.2))
	fill_rect(img, 0, 9, 300, 1, UI_BORDER.darkened(0.2))
	return img

# --- Skill bar (8 slot, 320×40) ---
static func gen_skill_bar() -> Image:
	var img := Image.create(320, 40, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.06, 0.05, 0.04, 0.85))
	fill_rect(img, 0, 0, 320, 2, UI_BORDER)
	fill_rect(img, 0, 38, 320, 2, UI_BORDER)
	for i in range(8):
		var x := 4 + i * 39
		fill_rect(img, x, 4, 36, 36, UI_DARK)
		fill_rect(img, x, 4, 36, 1, UI_BORDER)
		fill_rect(img, x, 4, 1, 36, UI_BORDER)
		fill_rect(img, x + 35, 4, 1, 36, UI_BORDER)
		fill_rect(img, x, 39, 36, 1, UI_BORDER)
	return img

# --- Dialógus doboz (400×120) ---
static func gen_dialog_box() -> Image:
	var img := gen_panel(400, 120, false)
	# Karakter portré placeholder
	fill_rect(img, 8, 8, 80, 80, UI_DARK)
	draw_circle_outline(img, 48, 48, 30, UI_BORDER)
	# Szöveg terület
	fill_rect(img, 96, 8, 296, 80, Color(0.05, 0.04, 0.03, 0.5))
	# Név csík
	fill_rect(img, 96, 8, 180, 16, UI_BORDER.darkened(0.15))
	# Tovább nyíl
	_set_pixel_safe(img, 380, 100, UI_ACCENT)
	fill_rect(img, 378, 98, 2, 2, UI_ACCENT)
	fill_rect(img, 376, 96, 2, 2, UI_ACCENT)
	return img

# --- Tooltip keret (160×100) ---
static func gen_tooltip() -> Image:
	var img := Image.create(160, 100, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.05, 0.04, 0.03, 0.95))
	# Szegély
	fill_rect(img, 0, 0, 160, 1, UI_ACCENT)
	fill_rect(img, 0, 99, 160, 1, UI_ACCENT)
	fill_rect(img, 0, 0, 1, 100, UI_ACCENT)
	fill_rect(img, 159, 0, 1, 100, UI_ACCENT)
	# Név terület
	fill_rect(img, 4, 4, 152, 16, UI_BORDER.darkened(0.2))
	# Elválasztó vonal
	fill_rect(img, 8, 24, 144, 1, UI_ACCENT.darkened(0.3))
	return img

# --- Button (normal, hover, pressed - 120×32) ---
static func gen_button(state: String) -> Image:
	var img := Image.create(120, 32, false, Image.FORMAT_RGBA8)
	match state:
		"normal":
			img.fill(Color(0.15, 0.12, 0.08, 0.9))
			fill_rect(img, 0, 0, 120, 2, UI_BORDER)
			fill_rect(img, 0, 30, 120, 2, UI_BORDER.darkened(0.2))
		"hover":
			img.fill(Color(0.20, 0.16, 0.10, 0.9))
			fill_rect(img, 0, 0, 120, 2, UI_ACCENT)
			fill_rect(img, 0, 30, 120, 2, UI_ACCENT.darkened(0.2))
		"pressed":
			img.fill(Color(0.10, 0.08, 0.05, 0.9))
			fill_rect(img, 0, 0, 120, 2, UI_ACCENT.darkened(0.2))
			fill_rect(img, 0, 30, 120, 2, UI_ACCENT)
		"disabled":
			img.fill(Color(0.10, 0.10, 0.10, 0.6))
			fill_rect(img, 0, 0, 120, 2, Color(0.25, 0.25, 0.25))
			fill_rect(img, 0, 30, 120, 2, Color(0.20, 0.20, 0.20))
	fill_rect(img, 0, 0, 2, 32, UI_BORDER)
	fill_rect(img, 118, 0, 2, 32, UI_BORDER)
	return img

# --- Minimap keret (200×200) ---
static func gen_minimap_frame() -> Image:
	var img := Image.create(200, 200, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	# Keret
	for i in range(3):
		draw_circle_outline(img, 100, 100, 97 - i, UI_BORDER)
	# Sarkok
	fill_rect(img, 0, 0, 6, 6, UI_ACCENT)
	fill_rect(img, 194, 0, 6, 6, UI_ACCENT)
	fill_rect(img, 0, 194, 6, 6, UI_ACCENT)
	fill_rect(img, 194, 194, 6, 6, UI_ACCENT)
	return img

# --- Skill tree háttér (600×400) ---
static func gen_skill_tree_bg() -> Image:
	var img := Image.create(600, 400, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.04, 0.03, 0.02))
	# Háló / vonalak
	for x in range(0, 600, 40):
		fill_rect(img, x, 0, 1, 400, Color(0.10, 0.08, 0.06))
	for y in range(0, 400, 40):
		fill_rect(img, 0, y, 600, 1, Color(0.10, 0.08, 0.06))
	# Dekoratív sarkok
	for corner in [Vector2i(0, 0), Vector2i(592, 0), Vector2i(0, 392), Vector2i(592, 392)]:
		fill_rect(img, corner.x, corner.y, 8, 8, UI_ACCENT)
	# Szegély
	fill_rect(img, 0, 0, 600, 2, UI_BORDER)
	fill_rect(img, 0, 398, 600, 2, UI_BORDER)
	fill_rect(img, 0, 0, 2, 400, UI_BORDER)
	fill_rect(img, 598, 0, 2, 400, UI_BORDER)
	return img

# --- Skill tree node (unlocked, locked, active — 48×48) ---
static func gen_skill_node(state: String) -> Image:
	var img := Image.create(48, 48, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	match state:
		"locked":
			draw_circle(img, 24, 24, 20, Color(0.12, 0.10, 0.08))
			draw_circle_outline(img, 24, 24, 20, Color(0.25, 0.22, 0.18))
			# Lakat szimbólum
			fill_rect(img, 20, 20, 8, 8, Color(0.30, 0.28, 0.24))
		"unlocked":
			draw_circle(img, 24, 24, 20, Color(0.15, 0.12, 0.08))
			draw_circle_outline(img, 24, 24, 20, UI_BORDER)
			draw_circle(img, 24, 24, 16, Color(0.08, 0.06, 0.04))
		"active":
			draw_circle(img, 24, 24, 20, Color(0.18, 0.14, 0.06))
			draw_circle_outline(img, 24, 24, 20, UI_ACCENT)
			draw_circle_outline(img, 24, 24, 18, UI_ACCENT.darkened(0.2))
			draw_circle(img, 24, 24, 16, Color(0.10, 0.08, 0.04))
		"maxed":
			draw_circle(img, 24, 24, 20, Color(0.20, 0.16, 0.04))
			draw_circle_outline(img, 24, 24, 20, Color(0.85, 0.70, 0.15))
			draw_circle_outline(img, 24, 24, 19, Color(0.85, 0.70, 0.15))
			draw_circle(img, 24, 24, 16, Color(0.12, 0.10, 0.04))
	return img

# --- Tab gomb (80×28) ---
static func gen_tab_button(active: bool) -> Image:
	var img := Image.create(80, 28, false, Image.FORMAT_RGBA8)
	if active:
		img.fill(Color(0.12, 0.10, 0.06, 0.95))
		fill_rect(img, 0, 0, 80, 2, UI_ACCENT)
		fill_rect(img, 0, 0, 2, 28, UI_BORDER)
		fill_rect(img, 78, 0, 2, 28, UI_BORDER)
	else:
		img.fill(Color(0.06, 0.05, 0.04, 0.8))
		fill_rect(img, 0, 26, 80, 2, UI_BORDER)
		fill_rect(img, 0, 0, 2, 28, UI_BORDER.darkened(0.2))
		fill_rect(img, 78, 0, 2, 28, UI_BORDER.darkened(0.2))
	return img

# --- Scrollbar (12×200) ---
static func gen_scrollbar() -> Image:
	var img := Image.create(12, 200, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.06, 0.05, 0.04, 0.7))
	# Nyil fel
	fill_rect(img, 2, 2, 8, 12, UI_BORDER.darkened(0.1))
	_set_pixel_safe(img, 5, 4, UI_TEXT)
	_set_pixel_safe(img, 6, 4, UI_TEXT)
	# Nyil le
	fill_rect(img, 2, 186, 8, 12, UI_BORDER.darkened(0.1))
	_set_pixel_safe(img, 5, 194, UI_TEXT)
	_set_pixel_safe(img, 6, 194, UI_TEXT)
	# Thumb
	fill_rect(img, 2, 30, 8, 40, UI_BORDER)
	fill_rect(img, 3, 32, 6, 36, UI_BORDER.lightened(0.1))
	# Szegély
	fill_rect(img, 0, 0, 1, 200, UI_BORDER.darkened(0.2))
	fill_rect(img, 11, 0, 1, 200, UI_BORDER.darkened(0.2))
	return img

# --- Cooldown overlay (36×36, félkör maszk) ---
static func gen_cooldown_overlay(pct: float) -> Image:
	var img := Image.create(36, 36, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	# Sötétítés a pct alapján (0..1 = teljesen CD → kész)
	for y in range(36):
		for x in range(36):
			var angle := atan2(y - 18, x - 18)
			var norm_angle := fmod(angle + PI * 2.5, PI * 2.0) / (PI * 2.0)
			if norm_angle > pct:
				_set_pixel_safe(img, x, y, Color(0, 0, 0, 0.5))
	return img

static func export_all(base_path: String) -> void:
	var path := base_path + "ui/"
	# Panelek
	save_png(gen_inventory_panel(), path + "panels/inventory.png")
	save_png(gen_equipment_panel(), path + "panels/equipment.png")
	save_png(gen_panel(250, 300, true), path + "panels/quest_log.png")
	save_png(gen_panel(300, 250, true), path + "panels/crafting.png")
	save_png(gen_panel(280, 200, true), path + "panels/shop.png")
	save_png(gen_panel(200, 150, true), path + "panels/party.png")
	# Bárok
	save_png(gen_hp_bar(1.0), path + "bars/hp_full.png")
	save_png(gen_hp_bar(0.5), path + "bars/hp_half.png")
	save_png(gen_hp_bar(0.0), path + "bars/hp_empty.png")
	save_png(gen_mana_bar(1.0), path + "bars/mana_full.png")
	save_png(gen_mana_bar(0.5), path + "bars/mana_half.png")
	save_png(gen_mana_bar(0.0), path + "bars/mana_empty.png")
	save_png(gen_xp_bar(0.6), path + "bars/xp.png")
	# Skill bar
	save_png(gen_skill_bar(), path + "hud/skill_bar.png")
	# Dialógus
	save_png(gen_dialog_box(), path + "dialog/dialog_box.png")
	# Tooltip
	save_png(gen_tooltip(), path + "tooltip/tooltip_frame.png")
	# Gombok
	for state in ["normal", "hover", "pressed", "disabled"]:
		save_png(gen_button(state), path + "buttons/btn_%s.png" % state)
	# Tab
	save_png(gen_tab_button(true), path + "buttons/tab_active.png")
	save_png(gen_tab_button(false), path + "buttons/tab_inactive.png")
	# Minimap
	save_png(gen_minimap_frame(), path + "hud/minimap_frame.png")
	# Skill tree
	save_png(gen_skill_tree_bg(), path + "skill_tree/background.png")
	for state in ["locked", "unlocked", "active", "maxed"]:
		save_png(gen_skill_node(state), path + "skill_tree/node_%s.png" % state)
	# Scrollbar
	save_png(gen_scrollbar(), path + "misc/scrollbar.png")
	# Cooldown
	for i in range(5):
		save_png(gen_cooldown_overlay(float(i) / 4.0), path + "misc/cooldown_%d.png" % i)
	print("  ✓ UI elements exported to: ", path)

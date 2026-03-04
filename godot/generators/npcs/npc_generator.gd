## NPCGenerator - NPC sprite generátor (~20 NPC)
## 64×96 pixel, idle(4fr) + talk(4fr) animáció
class_name NPCGenerator
extends PixelArtBase

const W = 64
const H = 96
const SKIN   = Color(0.82, 0.68, 0.52)
const SKIN2  = Color(0.72, 0.58, 0.42)

# ── NPC színek ──
const NPC_COLORS := {
	"weapon_shop":     {"body": Color(0.45, 0.43, 0.40), "accent": Color(0.55, 0.50, 0.45), "hair": Color(0.25, 0.18, 0.10)},
	"armor_shop":      {"body": Color(0.50, 0.35, 0.18), "accent": Color(0.60, 0.42, 0.22), "hair": Color(0.30, 0.22, 0.12)},
	"general_shop":    {"body": Color(0.55, 0.45, 0.30), "accent": Color(0.70, 0.60, 0.40), "hair": Color(0.20, 0.15, 0.08)},
	"potion_shop":     {"body": Color(0.30, 0.18, 0.40), "accent": Color(0.25, 0.55, 0.25), "hair": Color(0.40, 0.35, 0.30)},
	"magic_shop":      {"body": Color(0.12, 0.10, 0.30), "accent": Color(0.35, 0.25, 0.60), "hair": Color(0.60, 0.58, 0.55)},
	"jeweler":         {"body": Color(0.50, 0.15, 0.30), "accent": Color(0.75, 0.60, 0.20), "hair": Color(0.15, 0.12, 0.08)},
	"blacksmith":      {"body": Color(0.30, 0.20, 0.10), "accent": Color(0.65, 0.55, 0.40), "hair": Color(0.20, 0.12, 0.06)},
	"enchanter":       {"body": Color(0.15, 0.12, 0.35), "accent": Color(0.40, 0.55, 0.85), "hair": Color(0.55, 0.50, 0.80)},
	"quest_giver_1":   {"body": Color(0.55, 0.30, 0.12), "accent": Color(0.70, 0.55, 0.25), "hair": Color(0.35, 0.25, 0.15)},
	"quest_giver_2":   {"body": Color(0.20, 0.35, 0.20), "accent": Color(0.30, 0.50, 0.30), "hair": Color(0.65, 0.60, 0.55)},
	"quest_giver_3":   {"body": Color(0.40, 0.20, 0.15), "accent": Color(0.60, 0.35, 0.25), "hair": Color(0.10, 0.08, 0.05)},
	"quest_giver_4":   {"body": Color(0.25, 0.25, 0.40), "accent": Color(0.45, 0.40, 0.60), "hair": Color(0.75, 0.72, 0.68)},
	"guard":           {"body": Color(0.50, 0.52, 0.55), "accent": Color(0.60, 0.58, 0.55), "hair": Color(0.25, 0.20, 0.15)},
	"scholar":         {"body": Color(0.35, 0.28, 0.18), "accent": Color(0.50, 0.42, 0.28), "hair": Color(0.45, 0.42, 0.38)},
	"traveler":        {"body": Color(0.40, 0.32, 0.20), "accent": Color(0.55, 0.45, 0.30), "hair": Color(0.30, 0.25, 0.18)},
	"fisherman":       {"body": Color(0.30, 0.38, 0.45), "accent": Color(0.45, 0.50, 0.55), "hair": Color(0.50, 0.45, 0.38)},
	"innkeeper":       {"body": Color(0.50, 0.35, 0.20), "accent": Color(0.65, 0.50, 0.30), "hair": Color(0.35, 0.28, 0.20)},
	"mysterious":      {"body": Color(0.08, 0.06, 0.12), "accent": Color(0.15, 0.10, 0.22), "hair": Color(0.08, 0.06, 0.12)},
	"waypoint":        {"body": Color(0.30, 0.50, 0.80), "accent": Color(0.60, 0.80, 1.00), "hair": Color(0.85, 0.90, 0.95)},
	"auctioneer":      {"body": Color(0.45, 0.20, 0.15), "accent": Color(0.75, 0.65, 0.20), "hair": Color(0.12, 0.10, 0.08)},
}

static func _draw_npc_base(img: Image, colors: Dictionary, breath: int) -> void:
	draw_shadow(img, 32, 90, 10, 3)
	# Lábak
	fill_rect(img, 20, 76 + breath, 8, 14, colors["body"].darkened(0.2))
	fill_rect(img, 36, 76 + breath, 8, 14, colors["body"].darkened(0.2))
	# Test
	fill_rect(img, 14, 30 + breath, 36, 48, colors["body"])
	# Gallér/vállak
	fill_rect(img, 10, 28 + breath, 44, 8, colors["accent"])
	# Karok
	fill_rect(img, 4, 32 + breath, 12, 24, colors["body"])
	fill_rect(img, 48, 32 + breath, 12, 24, colors["body"])
	# Fej
	fill_rect(img, 18, 4 + breath, 28, 26, SKIN)
	# Haj
	fill_rect(img, 16, 2 + breath, 32, 10, colors["hair"])
	# Szemek
	_set_pixel_safe(img, 26, 16 + breath, Color(0.15, 0.12, 0.08))
	_set_pixel_safe(img, 38, 16 + breath, Color(0.15, 0.12, 0.08))

static func _draw_item_weapon_shop(img: Image, breath: int) -> void:
	# Kalapács jobb kézben
	fill_rect(img, 52, 28 + breath, 4, 28, Color(0.45, 0.30, 0.15))
	fill_rect(img, 48, 24 + breath, 12, 8, Color(0.50, 0.48, 0.45))
	# Vas kötény
	fill_rect(img, 18, 34 + breath, 28, 36, Color(0.48, 0.46, 0.43))

static func _draw_item_armor_shop(img: Image, breath: int) -> void:
	# Mértékszalag
	draw_line_px(img, 6, 40 + breath, 20, 60 + breath, Color(0.85, 0.80, 0.20))
	# Bőrös kötény
	fill_rect(img, 18, 36 + breath, 28, 34, Color(0.55, 0.38, 0.20))

static func _draw_item_guard(img: Image, colors: Dictionary, breath: int) -> void:
	# Lándzsa
	fill_rect(img, 54, 4 + breath, 4, 82, Color(0.45, 0.30, 0.15))
	fill_rect(img, 52, 2 + breath, 8, 6, Color(0.60, 0.58, 0.55))
	# Páncél overlay
	fill_rect(img, 16, 32 + breath, 32, 20, Color(0.55, 0.57, 0.60))

static func _draw_item_scholar(img: Image, breath: int) -> void:
	# Könyv kezében
	fill_rect(img, 4, 48 + breath, 10, 14, Color(0.45, 0.15, 0.10))
	fill_rect(img, 5, 49 + breath, 8, 12, Color(0.85, 0.80, 0.70))

static func _draw_item_potion(img: Image, breath: int) -> void:
	# Lombik
	fill_rect(img, 50, 44 + breath, 8, 12, Color(0.70, 0.75, 0.80, 0.6))
	fill_rect(img, 52, 48 + breath, 4, 6, Color(0.30, 0.70, 0.25))

static func _draw_item_magic(img: Image, breath: int) -> void:
	# Rúnás kezek
	_set_pixel_safe(img, 6, 54 + breath, Color(0.40, 0.30, 0.80))
	_set_pixel_safe(img, 56, 54 + breath, Color(0.40, 0.30, 0.80))

static func _draw_item_jeweler(img: Image, breath: int) -> void:
	# Nagyítóüveg
	draw_circle_outline(img, 56, 48 + breath, 5, Color(0.75, 0.65, 0.20))
	fill_rect(img, 58, 52 + breath, 3, 8, Color(0.45, 0.30, 0.15))

static func _draw_item_blacksmith(img: Image, breath: int) -> void:
	# Kalapács + kötény
	fill_rect(img, 52, 30 + breath, 4, 26, Color(0.45, 0.30, 0.15))
	fill_rect(img, 48, 26 + breath, 12, 8, Color(0.40, 0.38, 0.35))
	fill_rect(img, 16, 34 + breath, 32, 38, Color(0.30, 0.20, 0.10))

static func _draw_item_enchanter(img: Image, breath: int) -> void:
	# Izzó kezek
	draw_circle(img, 8, 54 + breath, 3, Color(0.40, 0.55, 0.85, 0.5))
	draw_circle(img, 56, 54 + breath, 3, Color(0.40, 0.55, 0.85, 0.5))

static func _draw_item_traveler(img: Image, colors: Dictionary, breath: int) -> void:
	# Kalap
	fill_rect(img, 12, 0 + breath, 40, 6, colors["body"])
	fill_rect(img, 18, 0 + breath, 28, 4, colors["accent"])

static func _draw_item_fisherman(img: Image, breath: int) -> void:
	# Horgász bot
	fill_rect(img, 54, 6 + breath, 3, 60, Color(0.50, 0.35, 0.18))
	draw_line_px(img, 56, 6 + breath, 62, 12, Color(0.70, 0.68, 0.65))

static func _draw_item_innkeeper(img: Image, breath: int) -> void:
	# Sör-korsó
	fill_rect(img, 50, 46 + breath, 10, 12, Color(0.55, 0.40, 0.18))
	fill_rect(img, 60, 48 + breath, 4, 8, Color(0.55, 0.40, 0.18))
	fill_rect(img, 52, 44 + breath, 6, 4, Color(0.90, 0.85, 0.60))

static func _draw_item_mysterious(img: Image, breath: int) -> void:
	# Teljes kapucni (fej felülírás)
	fill_rect(img, 14, 2 + breath, 36, 28, Color(0.08, 0.06, 0.12))
	# Izzó szemek
	_set_pixel_safe(img, 26, 16 + breath, Color(0.60, 0.20, 0.80))
	_set_pixel_safe(img, 38, 16 + breath, Color(0.60, 0.20, 0.80))

static func _draw_item_waypoint(img: Image, breath: int) -> void:
	# Izzó aura
	draw_circle(img, 32, 48 + breath, 18, Color(0.60, 0.80, 1.00, 0.15))

static func _draw_item_auctioneer(img: Image, breath: int) -> void:
	# Kis kalapács
	fill_rect(img, 50, 44 + breath, 4, 16, Color(0.45, 0.30, 0.15))
	fill_rect(img, 48, 42 + breath, 8, 4, Color(0.55, 0.40, 0.20))

static func generate_npc(npc_name: String, anim: String, frame_idx: int) -> Image:
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	var colors: Dictionary = NPC_COLORS.get(npc_name, NPC_COLORS["general_shop"])
	var breath := get_breath_offset(frame_idx, 4) if anim == "idle" else 0
	var talk_offset := 0
	if anim == "talk":
		talk_offset = [0, -1, 0, 1][frame_idx % 4]

	_draw_npc_base(img, colors, breath + talk_offset)

	match npc_name:
		"weapon_shop":   _draw_item_weapon_shop(img, breath + talk_offset)
		"armor_shop":    _draw_item_armor_shop(img, breath + talk_offset)
		"guard":         _draw_item_guard(img, colors, breath + talk_offset)
		"scholar":       _draw_item_scholar(img, breath + talk_offset)
		"potion_shop":   _draw_item_potion(img, breath + talk_offset)
		"magic_shop":    _draw_item_magic(img, breath + talk_offset)
		"jeweler":       _draw_item_jeweler(img, breath + talk_offset)
		"blacksmith":    _draw_item_blacksmith(img, breath + talk_offset)
		"enchanter":     _draw_item_enchanter(img, breath + talk_offset)
		"traveler":      _draw_item_traveler(img, colors, breath + talk_offset)
		"fisherman":     _draw_item_fisherman(img, breath + talk_offset)
		"innkeeper":     _draw_item_innkeeper(img, breath + talk_offset)
		"mysterious":    _draw_item_mysterious(img, breath + talk_offset)
		"waypoint":      _draw_item_waypoint(img, breath + talk_offset)
		"auctioneer":    _draw_item_auctioneer(img, breath + talk_offset)

	draw_outline(img, Color.BLACK)
	return img

static func get_npc_names() -> Array:
	return NPC_COLORS.keys()

static func get_anim_config() -> Dictionary:
	return {
		"idle": {"frames": 4, "fps": 5, "loop": true},
		"talk": {"frames": 4, "fps": 6, "loop": true},
	}

static func export_all(base_path: String) -> void:
	var path := base_path + "npcs/"
	var anims := get_anim_config()
	for npc_name in get_npc_names():
		for anim_name in anims:
			var config: Dictionary = anims[anim_name]
			for i in range(config["frames"]):
				save_png(generate_npc(npc_name, anim_name, i), path + "%s/%s_%d.png" % [npc_name, anim_name, i])
	print("  ✓ NPCs exported to: ", path)

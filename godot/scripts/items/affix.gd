## Affix - Egyedi affix (prefix/suffix) definíció
## Stat módosítók item-ekre
class_name Affix
extends RefCounted

var affix_name: String = ""
var stat_type: String = ""  # flat_damage, percent_hp, crit_chance, stb.
var min_value: float = 0.0
var max_value: float = 0.0
var max_tier: int = 5
var min_level: int = 1
var is_prefix: bool = true

# === Típus szűrés ===
var valid_item_types: Array[Enums.ItemType] = [
	Enums.ItemType.WEAPON,
	Enums.ItemType.ARMOR,
	Enums.ItemType.ACCESSORY,
]


func _init(
	p_name: String = "",
	p_stat: String = "",
	p_min: float = 0.0,
	p_max: float = 0.0,
	p_tiers: int = 5
) -> void:
	affix_name = p_name
	stat_type = p_stat
	min_value = p_min
	max_value = p_max
	max_tier = p_tiers


## Tier-alapú érték generálás
func roll_value(tier: int) -> float:
	tier = clampi(tier, 1, max_tier)
	var tier_min: float = min_value + (max_value - min_value) * (float(tier - 1) / float(max_tier))
	var tier_max: float = min_value + (max_value - min_value) * (float(tier) / float(max_tier))
	return tier_min + randf() * (tier_max - tier_min)


## Érvényes-e az adott item típusra
func is_valid_for_type(item_type: Enums.ItemType) -> bool:
	return item_type in valid_item_types


## Affix instance generálás (konkrét értékkel)
func create_instance(tier: int) -> Dictionary:
	return {
		"affix_name": affix_name,
		"stat_type": stat_type,
		"value": roll_value(tier),
		"tier": tier,
		"is_prefix": is_prefix,
	}


## Display string
func get_display_text(value: float) -> String:
	var sign: String = "+" if value >= 0 else ""
	if stat_type.begins_with("percent") or stat_type in [
		"crit_chance", "crit_damage", "attack_speed", "move_speed",
		"lifesteal", "cooldown_reduction", "all_resist",
	]:
		return "%s%.1f%% %s" % [sign, value, _format_stat_name()]
	return "%s%d %s" % [sign, int(value), _format_stat_name()]


func _format_stat_name() -> String:
	return stat_type.replace("_", " ").capitalize()

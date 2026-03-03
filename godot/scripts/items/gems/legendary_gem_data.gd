## LegendaryGemData - Resource: egyedi legendary gem definíció
## Minden legendary gemnek saját egyedi passzív effektje van
class_name LegendaryGemData
extends Resource

@export var gem_id: String = ""
@export var gem_name: String = ""
@export var description: String = ""
@export var icon: Texture2D = null

## Effekt típus (milyen trigger aktiválja)
enum EffectTrigger {
	ON_KILL,          # Kill-kor
	ON_LOW_HP,        # HP < X% alatt
	ON_DODGE,         # Dodge/roll után
	ON_CRIT,          # Crit hit-kor
	ON_ATTACK,        # Bármely attack-kor
	ON_HIT_RECEIVED,  # Melee damage kapásnál
	ON_DEATH,         # Halálakor (revive)
	PASSIVE,          # Folyamatosan aktív
	ON_HEAL,          # Heal-kor
}

@export var trigger: EffectTrigger = EffectTrigger.PASSIVE

## Effekt paraméterek (gem-specifikus)
@export var effect_params: Dictionary = {}
# Példák:
#   Gem of Devastation: {"damage_per_stack": 5.0, "max_stacks": 10, "duration": 10.0}
#   Gem of Fortitude: {"hp_threshold": 0.3, "damage_reduction": 0.25}
#   Gem of Swiftness: {"attack_speed_bonus": 0.4, "duration": 3.0}

## Cooldown (ha van, másodpercben, 0 = nincs)
@export var cooldown: float = 0.0

## Removal cost (2000 gold a tervben)
@export var removal_cost: int = 2000

## Csak accessory slot-ba tehető
@export var accessory_only: bool = true


## Passzív stat bónuszok (ha van, pl. Gem of Greed: +50% Gold Find, -10% Max HP)
func get_stat_bonuses() -> Dictionary:
	return effect_params.get("stat_bonuses", {})


## Teljes tooltip szöveg
func get_tooltip_text() -> String:
	var text := gem_name + "\n"
	text += "[color=orange]Legendary Gem[/color]\n\n"
	text += description + "\n"

	if cooldown > 0:
		text += "\nCooldown: %ds" % int(cooldown)

	text += "\n\nOnly fits in Accessory sockets"
	text += "\nMax 1 per item"
	text += "\nRemoval cost: %d gold" % removal_cost
	return text

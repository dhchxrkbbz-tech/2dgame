## GemCombiner - Gem kombinálás (upgrade) logika
## 3× azonos gem típus + azonos tier → 1× következő tier + gold költség
## A 09_gem_system_plan.txt 6. fejezete alapján
class_name GemCombiner
extends RefCounted

## Kombináláshoz szükséges gem szám
const GEMS_NEEDED: int = 3

## Gold költségek tier szerint (index = jelenlegi tier)
const GOLD_COSTS: Array[int] = [50, 200, 500, 1500, 5000]

## Kell-e Relic Fragment? (index = jelenlegi tier)
const NEEDS_RELIC: Array[bool] = [false, false, false, false, true]

## Tier nevek UI-hoz
const TIER_NAMES: Array[String] = ["Chipped", "Flawed", "Normal", "Flawless", "Perfect", "Radiant"]


## Ellenőrzés: lehet-e kombinálni a megadott gem-eket?
static func can_combine(gems: Array, gold_available: int = 0, has_relic: bool = false) -> Dictionary:
	var result := {
		"can_combine": false,
		"reason": "",
		"gold_cost": 0,
		"needs_relic": false,
		"result_tier": -1,
		"result_type": -1,
	}

	if gems.size() != GEMS_NEEDED:
		result.reason = "Exactly %d gems required" % GEMS_NEEDED
		return result

	# Ellenőrzés: mind GemInstance, nem legendary
	for gem in gems:
		if not gem is GemInstance:
			result.reason = "Invalid gem"
			return result
		if gem.is_legendary:
			result.reason = "Legendary gems cannot be combined"
			return result

	# Azonos típus + tier ellenőrzés
	var first_gem: GemInstance = gems[0]
	var gem_type: Enums.GemType = first_gem.gem_type
	var gem_tier: int = first_gem.gem_tier

	for gem in gems:
		if gem.gem_type != gem_type:
			result.reason = "All gems must be the same type"
			return result
		if gem.gem_tier != gem_tier:
			result.reason = "All gems must be the same tier"
			return result

	# Max tier ellenőrzés (Radiant nem upgradolható tovább)
	if gem_tier >= Enums.GemTier.RADIANT:
		result.reason = "Already at maximum tier (Radiant)"
		return result

	# Költség ellenőrzés
	var gold_cost: int = GOLD_COSTS[gem_tier] if gem_tier < GOLD_COSTS.size() else 99999
	var needs_relic: bool = NEEDS_RELIC[gem_tier] if gem_tier < NEEDS_RELIC.size() else false

	result.gold_cost = gold_cost
	result.needs_relic = needs_relic
	result.result_tier = gem_tier + 1
	result.result_type = gem_type

	if gold_available > 0 and gold_available < gold_cost:
		result.reason = "Not enough gold (need %d)" % gold_cost
		return result

	if needs_relic and not has_relic:
		result.reason = "Requires 1 Relic Fragment"
		return result

	result.can_combine = true
	return result


## Kombinálás végrehajtása
## Returns: az új magasabb tier-ű GemInstance, vagy null ha nem sikerült
## FONTOS: a hívónak kell kezelni a gem-ek eltávolítását inventory-ból
##         és a gold/relic levonást!
static func combine(gems: Array) -> GemInstance:
	if gems.size() != GEMS_NEEDED:
		return null

	var first_gem: GemInstance = gems[0]
	if first_gem.gem_tier >= Enums.GemTier.RADIANT:
		return null

	var gem_type: Enums.GemType = first_gem.gem_type
	var new_tier: int = first_gem.gem_tier + 1

	# Validate
	for gem in gems:
		if not gem is GemInstance:
			return null
		if gem.gem_type != gem_type or gem.gem_tier != first_gem.gem_tier:
			return null
		if gem.is_legendary:
			return null

	# Új gem létrehozása
	var new_gem := GemInstance.create_normal(gem_type, new_tier as Enums.GemTier)
	
	# Vizuális feedback: EventBus-on keresztül jelzi a sikeres combine-t
	EventBus.gem_combined.emit(gem_type, new_tier)
	EventBus.show_notification.emit(
		"Gem upgraded to %s!" % TIER_NAMES[new_tier] if new_tier < TIER_NAMES.size() else "Gem upgraded!",
		Enums.NotificationType.LEVEL_UP
	)
	
	return new_gem


## Kombinálás UI-val (animáció + hang eseményekkel)
## Ez a függvény a UI oldalról hívódik, a combine() után
static func play_combine_effects(ui_node: Control, result_gem: GemInstance) -> void:
	if not ui_node or not is_instance_valid(ui_node):
		return
	
	# Flash effekt a UI-n
	var flash := ColorRect.new()
	flash.color = _get_gem_flash_color(result_gem.gem_tier)
	flash.size = ui_node.size
	flash.position = Vector2.ZERO
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_node.add_child(flash)
	
	var tween := ui_node.create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 0.8).from(1.0)
	tween.tween_callback(flash.queue_free)
	
	# Audio feedback
	EventBus.play_sfx.emit("gem_combine")


## Gem tier-hez tartozó flash szín
static func _get_gem_flash_color(tier: int) -> Color:
	match tier:
		0: return Color(0.7, 0.7, 0.7, 0.6)     # Chipped - szürke
		1: return Color(0.5, 0.8, 0.5, 0.6)     # Flawed - zöld
		2: return Color(0.5, 0.5, 1.0, 0.6)     # Normal - kék
		3: return Color(0.8, 0.5, 1.0, 0.6)     # Flawless - lila
		4: return Color(1.0, 0.8, 0.2, 0.6)     # Perfect - arany
		5: return Color(1.0, 0.4, 0.2, 0.8)     # Radiant - narancs
		_: return Color(1.0, 1.0, 1.0, 0.6)


## Hány alap gem (Chipped) kell egy adott tier-hez?
static func get_total_base_gems_needed(target_tier: Enums.GemTier) -> int:
	# 3^tier
	return int(pow(3, target_tier))


## Összes gold költség egy Chipped-ből target tier-re
static func get_total_gold_cost(target_tier: Enums.GemTier) -> int:
	var total := 0
	for tier in target_tier:
		var gems_at_tier := int(pow(3, target_tier - tier - 1))
		var cost_per_combine := GOLD_COSTS[tier] if tier < GOLD_COSTS.size() else 0
		total += gems_at_tier * cost_per_combine
	return total


## Kombinálás preview szöveg
static func get_combine_preview(gems: Array, gold: int = 0, has_relic: bool = false) -> String:
	var check := can_combine(gems, gold, has_relic)

	if not check.can_combine:
		return "Cannot combine: %s" % check.reason

	var type_name := GemData.GEM_TYPE_NAMES.get(check.result_type, "Unknown")
	var tier_name := TIER_NAMES[check.result_tier] if check.result_tier < TIER_NAMES.size() else "Unknown"
	var text := "Combine 3× %s → 1× %s %s\n" % [
		gems[0].get_display_name() if gems.size() > 0 else "?",
		tier_name, type_name
	]
	text += "Cost: %d gold" % check.gold_cost
	if check.needs_relic:
		text += " + 1 Relic Fragment"
	return text

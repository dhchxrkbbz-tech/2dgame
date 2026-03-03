## LegendaryGemDatabase - Összes legendary gem nyilvántartás és betöltés
## Autoload-ból vagy statikus hívással elérhető
class_name LegendaryGemDatabase
extends RefCounted

static var _gems: Dictionary = {}  # { gem_id: LegendaryGemData }
static var _initialized: bool = false


## Inicializálás (lazy)
static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	_register_all_gems()


## Legendary gem lekérdezés ID alapján
static func get_gem(gem_id: String) -> LegendaryGemData:
	_ensure_initialized()
	return _gems.get(gem_id)


## Összes legendary gem lekérdezés
static func get_all_gems() -> Array:
	_ensure_initialized()
	return _gems.values()


## Összes legendary gem ID
static func get_all_ids() -> Array:
	_ensure_initialized()
	return _gems.keys()


## Random legendary gem (boss drop-hoz)
static func get_random_gem() -> LegendaryGemData:
	_ensure_initialized()
	var ids := _gems.keys()
	if ids.is_empty():
		return null
	return _gems[ids[randi() % ids.size()]]


## Összes legendary gem regisztrálása a terv alapján
static func _register_all_gems() -> void:
	_register("gem_of_devastation", "Gem of Devastation",
		"Kills grant +5% damage (stacks up to 10×, lasts 10s).",
		LegendaryGemData.EffectTrigger.ON_KILL,
		{"damage_per_stack": 5.0, "max_stacks": 10, "duration": 10.0},
		0.0)

	_register("gem_of_fortitude", "Gem of Fortitude",
		"When HP < 30%: +25% Damage Reduction.",
		LegendaryGemData.EffectTrigger.ON_LOW_HP,
		{"hp_threshold": 0.3, "damage_reduction": 0.25, "stat_bonuses": {"damage_reduction": 25.0}},
		0.0)

	_register("gem_of_swiftness", "Gem of Swiftness",
		"After dodging: +40% attack speed for 3s.",
		LegendaryGemData.EffectTrigger.ON_DODGE,
		{"attack_speed_bonus": 0.4, "duration": 3.0},
		0.0)

	_register("gem_of_the_leech", "Gem of the Leech",
		"Critical hits heal 5% of max HP.",
		LegendaryGemData.EffectTrigger.ON_CRIT,
		{"heal_percent": 0.05},
		0.0)

	_register("gem_of_chaos", "Gem of Chaos",
		"Attacks have 10% chance to unleash a random elemental burst.",
		LegendaryGemData.EffectTrigger.ON_ATTACK,
		{"proc_chance": 0.10, "burst_damage_percent": 0.5},
		1.0)

	_register("gem_of_thorns", "Gem of Thorns",
		"Melee attackers receive 15% reflected damage.",
		LegendaryGemData.EffectTrigger.ON_HIT_RECEIVED,
		{"reflect_percent": 0.15},
		0.0)

	_register("gem_of_shadows", "Gem of Shadows",
		"Killing an enemy grants 2s invisibility (does not stack).",
		LegendaryGemData.EffectTrigger.ON_KILL,
		{"invisibility_duration": 2.0},
		5.0)

	_register("gem_of_resurrection", "Gem of Resurrection",
		"On death: revive once with 30% HP (300s cooldown).",
		LegendaryGemData.EffectTrigger.ON_DEATH,
		{"revive_hp_percent": 0.3},
		300.0)

	_register("gem_of_the_storm", "Gem of the Storm",
		"20% chance on attack to trigger chain lightning (hits 3 targets).",
		LegendaryGemData.EffectTrigger.ON_ATTACK,
		{"proc_chance": 0.20, "chain_targets": 3},
		0.5)

	_register("gem_of_eternity", "Gem of Eternity",
		"Cooldowns recover 15% faster.",
		LegendaryGemData.EffectTrigger.PASSIVE,
		{"cooldown_reduction": 0.15, "stat_bonuses": {"cooldown_reduction": 15.0}},
		0.0)

	_register("gem_of_greed", "Gem of Greed",
		"+50% Gold Find, but -10% Max HP.",
		LegendaryGemData.EffectTrigger.PASSIVE,
		{"stat_bonuses": {"gold_find": 50.0, "max_hp_percent": -10.0}},
		0.0)

	_register("gem_of_vampirism", "Gem of Vampirism",
		"All damage heals 3% as lifesteal, but -5% damage dealt.",
		LegendaryGemData.EffectTrigger.PASSIVE,
		{"lifesteal": 0.03, "damage_penalty": -0.05,
		 "stat_bonuses": {"lifesteal": 3.0, "damage_percent": -5.0}},
		0.0)

	_register("gem_of_the_colossus", "Gem of the Colossus",
		"+100 Max HP, but -10% Movement Speed.",
		LegendaryGemData.EffectTrigger.PASSIVE,
		{"stat_bonuses": {"max_hp": 100.0, "move_speed_percent": -10.0}},
		0.0)

	_register("gem_of_precision", "Gem of Precision",
		"+10% Critical Chance, but -15% Max HP.",
		LegendaryGemData.EffectTrigger.PASSIVE,
		{"stat_bonuses": {"crit_chance": 10.0, "max_hp_percent": -15.0}},
		0.0)

	_register("gem_of_convergence", "Gem of Convergence",
		"Heals grant 20% additional shield for 5s.",
		LegendaryGemData.EffectTrigger.ON_HEAL,
		{"shield_percent": 0.20, "shield_duration": 5.0},
		0.0)


## Belső segéd: legendary gem regisztrálás
static func _register(id: String, gem_name: String, desc: String,
		trigger: LegendaryGemData.EffectTrigger, params: Dictionary, cd: float) -> void:
	var data := LegendaryGemData.new()
	data.gem_id = id
	data.gem_name = gem_name
	data.description = desc
	data.trigger = trigger
	data.effect_params = params
	data.cooldown = cd
	_gems[id] = data

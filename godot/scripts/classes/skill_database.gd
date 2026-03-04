## SkillDatabase - Központi skill adatbázis mind a 45 skill-hez
## 3 class × 3 branch × 5 skill = 45 skill
## A 16_game_data_balance_plan.txt 2.3 szekció alapján
class_name SkillDatabase
extends RefCounted

static var _skills: Dictionary = {}  # skill_id -> SkillData
static var _initialized: bool = false


static func initialize() -> void:
	if _initialized:
		return
	_initialized = true
	_register_assassin_shadow()
	_register_assassin_blade()
	_register_assassin_poison()
	_register_tank_shield()
	_register_tank_warcry()
	_register_tank_fortify()
	_register_mage_fire()
	_register_mage_ice()
	_register_mage_arcane()


static func get_skill(skill_id: String) -> SkillData:
	initialize()
	return _skills.get(skill_id, null)


static func get_all_skills() -> Array[SkillData]:
	initialize()
	var result: Array[SkillData] = []
	for key in _skills:
		result.append(_skills[key])
	return result


static func get_skills_for_class(player_class: Enums.PlayerClass) -> Array[SkillData]:
	initialize()
	var result: Array[SkillData] = []
	for key in _skills:
		var skill: SkillData = _skills[key]
		if skill.player_class == player_class:
			result.append(skill)
	return result


static func get_skills_for_branch(branch: Enums.SkillBranch) -> Array[SkillData]:
	initialize()
	var result: Array[SkillData] = []
	for key in _skills:
		var skill: SkillData = _skills[key]
		if skill.branch == branch:
			result.append(skill)
	return result


static func _reg(data: Dictionary) -> void:
	var skill := SkillData.new()
	skill.skill_id = data.get("id", "")
	skill.skill_name = data.get("name", "")
	skill.description = data.get("description", "")
	skill.player_class = data.get("class", Enums.PlayerClass.ASSASSIN)
	skill.branch = data.get("branch", Enums.SkillBranch.SHADOW)
	skill.max_rank = data.get("max_rank", 5)
	skill.is_ultimate = data.get("is_ultimate", false)
	skill.base_damage_multiplier = data.get("damage_mult", 1.0)
	skill.base_cooldown = data.get("cooldown", 5.0)
	skill.base_mana_cost = data.get("mana_cost", 15.0)
	skill.base_duration = data.get("duration", 0.0)
	skill.skill_type = data.get("skill_type", Enums.SkillType.MELEE)
	skill.target_type = data.get("target_type", Enums.TargetType.SINGLE_ENEMY)
	skill.skill_range = data.get("range", 32.0)
	skill.aoe_radius = data.get("aoe_radius", 0.0)
	skill.damage_per_rank = data.get("damage_per_rank", 0.15)
	skill.cooldown_per_rank = data.get("cd_per_rank", 0.0)
	skill.duration_per_rank = data.get("dur_per_rank", 0.0)
	skill.mana_cost_per_rank = data.get("mana_per_rank", 0.0)
	skill.prerequisite_skill_id = data.get("prereq_id", "")
	skill.prerequisite_rank = data.get("prereq_rank", 1)
	skill.applies_effect = data.get("effect_type", -1)
	skill.effect_duration = data.get("effect_duration", 0.0)
	skill.effect_value = data.get("effect_value", 0.0)
	skill.hp_cost_percent = data.get("hp_cost", 0.0)
	skill.is_toggle = data.get("is_toggle", false)
	skill.mana_per_second = data.get("mana_per_sec", 0.0)
	skill.animation_name = data.get("anim", "")
	_skills[skill.skill_id] = skill


# ============================================================
# ASSASSIN – SHADOW BRANCH
# ============================================================

static func _register_assassin_shadow() -> void:
	# 1. Shadow Step (T1) – Teleport az ellenség mögé, +50% crit chance 2s
	_reg({
		"id": "shadow_step",
		"name": "Shadow Step",
		"description": "Teleport behind the enemy, gaining +50% crit chance for 2s.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.SHADOW,
		"damage_mult": 1.5,
		"cooldown": 8.0,
		"mana_cost": 20.0,
		"duration": 2.0,
		"skill_type": Enums.SkillType.TELEPORT,
		"target_type": Enums.TargetType.SINGLE_ENEMY,
		"range": 192.0,
		"damage_per_rank": 0.1,
		"cd_per_rank": 0.5,
		"effect_type": Enums.EffectType.ATTACK_SPEED_UP,
		"effect_duration": 2.0,
		"effect_value": 50.0,
		"anim": "shadow_step",
	})

	# 2. Smoke Bomb (T2) – AoE füst, miss 40%, stealth 3s
	_reg({
		"id": "smoke_bomb",
		"name": "Smoke Bomb",
		"description": "Throw a smoke bomb. Enemies inside miss 40% of attacks. Grants stealth for 3s.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.SHADOW,
		"damage_mult": 0.0,
		"cooldown": 12.0,
		"mana_cost": 30.0,
		"duration": 3.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 96.0,
		"damage_per_rank": 0.0,
		"cd_per_rank": 0.0,
		"dur_per_rank": 0.5,
		"effect_type": Enums.EffectType.ACCURACY_DOWN,
		"effect_duration": 3.0,
		"effect_value": 40.0,
		"prereq_id": "shadow_step",
		"prereq_rank": 2,
		"anim": "smoke_bomb",
	})

	# 3. Shadow Clone (T3) – Klón 8s-ig, 40% damage
	_reg({
		"id": "shadow_clone",
		"name": "Shadow Clone",
		"description": "Create a shadow clone that fights for 8s dealing 40% of your damage.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.SHADOW,
		"damage_mult": 0.4,
		"cooldown": 20.0,
		"mana_cost": 40.0,
		"duration": 8.0,
		"skill_type": Enums.SkillType.SUMMON,
		"target_type": Enums.TargetType.NONE,
		"damage_per_rank": 0.08,
		"dur_per_rank": 1.0,
		"prereq_id": "smoke_bomb",
		"prereq_rank": 2,
		"anim": "shadow_clone",
	})

	# 4. Assassinate (T4) – Hátulról 3x, elölről 1.8x
	_reg({
		"id": "assassinate",
		"name": "Assassinate",
		"description": "Strike with lethal precision. 3x damage from behind, 1.8x from front.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.SHADOW,
		"damage_mult": 3.0,
		"cooldown": 15.0,
		"mana_cost": 50.0,
		"skill_type": Enums.SkillType.MELEE,
		"target_type": Enums.TargetType.SINGLE_ENEMY,
		"range": 40.0,
		"damage_per_rank": 0.3,
		"prereq_id": "shadow_clone",
		"prereq_rank": 3,
		"anim": "assassinate",
	})

	# 5. Shadow Realm (T5 Ultimate) – 6s láthatatlanság, minden támadás crit
	_reg({
		"id": "shadow_realm",
		"name": "Shadow Realm",
		"description": "Enter the Shadow Realm for 6s. You are invisible and all attacks are critical hits.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.SHADOW,
		"is_ultimate": true,
		"damage_mult": 1.0,
		"cooldown": 60.0,
		"mana_cost": 80.0,
		"duration": 6.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.0,
		"cd_per_rank": 5.0,
		"prereq_id": "assassinate",
		"prereq_rank": 3,
		"anim": "shadow_realm",
	})


# ============================================================
# ASSASSIN – BLADE BRANCH (BLOOD in Enums)
# ============================================================

static func _register_assassin_blade() -> void:
	# 6. Blade Flurry (T1) – 5 gyors ütés, 0.4x per hit
	_reg({
		"id": "blade_flurry",
		"name": "Blade Flurry",
		"description": "Unleash 5 rapid strikes, each dealing 0.4x damage.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.BLOOD,
		"damage_mult": 0.4,
		"cooldown": 6.0,
		"mana_cost": 15.0,
		"skill_type": Enums.SkillType.MELEE,
		"target_type": Enums.TargetType.SINGLE_ENEMY,
		"range": 36.0,
		"damage_per_rank": 0.05,
		"anim": "blade_flurry",
	})

	# 7. Whirlwind Slash (T2) – 360° AoE, knockback
	_reg({
		"id": "whirlwind_slash",
		"name": "Whirlwind Slash",
		"description": "Spin in a 360° arc, hitting all nearby enemies with knockback.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.BLOOD,
		"damage_mult": 1.2,
		"cooldown": 10.0,
		"mana_cost": 25.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 80.0,
		"damage_per_rank": 0.15,
		"prereq_id": "blade_flurry",
		"prereq_rank": 2,
		"anim": "whirlwind_slash",
	})

	# 8. Blade Dance (T3) – 4s random teleport+slash
	_reg({
		"id": "blade_dance",
		"name": "Blade Dance",
		"description": "Dance between enemies for 4s, teleporting and slashing randomly.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.BLOOD,
		"damage_mult": 0.8,
		"cooldown": 18.0,
		"mana_cost": 45.0,
		"duration": 4.0,
		"skill_type": Enums.SkillType.CHANNEL,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 160.0,
		"damage_per_rank": 0.1,
		"dur_per_rank": 0.5,
		"prereq_id": "whirlwind_slash",
		"prereq_rank": 2,
		"anim": "blade_dance",
	})

	# 9. Execute (T4) – 30% HP alatt instant kill chance
	_reg({
		"id": "execute",
		"name": "Execute",
		"description": "Strike a weakened foe. 15% chance of instant kill below 30% HP. 2.5x damage.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.BLOOD,
		"damage_mult": 2.5,
		"cooldown": 12.0,
		"mana_cost": 35.0,
		"skill_type": Enums.SkillType.MELEE,
		"target_type": Enums.TargetType.SINGLE_ENEMY,
		"range": 40.0,
		"damage_per_rank": 0.25,
		"prereq_id": "blade_dance",
		"prereq_rank": 3,
		"anim": "execute",
	})

	# 10. Thousand Cuts (T5 Ultimate) – 3s 30 vágás
	_reg({
		"id": "thousand_cuts",
		"name": "Thousand Cuts",
		"description": "Unleash 30 slashes over 3s on random targets in range.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.BLOOD,
		"is_ultimate": true,
		"damage_mult": 0.5,
		"cooldown": 55.0,
		"mana_cost": 90.0,
		"duration": 3.0,
		"skill_type": Enums.SkillType.CHANNEL,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 192.0,
		"damage_per_rank": 0.05,
		"dur_per_rank": 0.0,
		"prereq_id": "execute",
		"prereq_rank": 3,
		"anim": "thousand_cuts",
	})


# ============================================================
# ASSASSIN – POISON BRANCH
# ============================================================

static func _register_assassin_poison() -> void:
	# 11. Envenom (T1) – Mérgezi a fegyvert 15s
	_reg({
		"id": "envenom",
		"name": "Envenom",
		"description": "Coat your weapon in poison for 15s, adding poison DoT to all attacks.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.POISON,
		"damage_mult": 0.0,
		"cooldown": 1.0,
		"mana_cost": 10.0,
		"duration": 15.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.12,
		"dur_per_rank": 3.0,
		"effect_type": Enums.EffectType.POISON_DOT,
		"effect_duration": 15.0,
		"effect_value": 12.0,
		"anim": "envenom",
	})

	# 12. Toxic Spray (T2) – Kúp alakú méreg
	_reg({
		"id": "toxic_spray",
		"name": "Toxic Spray",
		"description": "Spray a cone of poison, dealing damage and applying poison DoT.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.POISON,
		"damage_mult": 0.8,
		"cooldown": 8.0,
		"mana_cost": 25.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.DIRECTIONAL,
		"aoe_radius": 128.0,
		"damage_per_rank": 0.1,
		"effect_type": Enums.EffectType.POISON_DOT,
		"effect_duration": 4.0,
		"effect_value": 10.0,
		"prereq_id": "envenom",
		"prereq_rank": 2,
		"anim": "toxic_spray",
	})

	# 13. Pandemic (T3) – Méreg átterjed közeli ellenségekre
	_reg({
		"id": "pandemic",
		"name": "Pandemic",
		"description": "Your poison spreads to nearby enemies within 4 tiles.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.POISON,
		"damage_mult": 0.0,
		"cooldown": 14.0,
		"mana_cost": 35.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 128.0,
		"range": 128.0,
		"damage_per_rank": 0.0,
		"prereq_id": "toxic_spray",
		"prereq_rank": 2,
		"anim": "pandemic",
	})

	# 14. Venom Nova (T4) – Robbanó méregfelhő AoE
	_reg({
		"id": "venom_nova",
		"name": "Venom Nova",
		"description": "Unleash an explosive poison cloud dealing 2.0x damage + heavy DoT.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.POISON,
		"damage_mult": 2.0,
		"cooldown": 16.0,
		"mana_cost": 50.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 128.0,
		"damage_per_rank": 0.15,
		"effect_type": Enums.EffectType.POISON_DOT,
		"effect_duration": 6.0,
		"effect_value": 15.0,
		"prereq_id": "pandemic",
		"prereq_rank": 3,
		"anim": "venom_nova",
	})

	# 15. Plague Lord (T5 Ultimate) – 10s méreg 3x tick
	_reg({
		"id": "plague_lord",
		"name": "Plague Lord",
		"description": "For 10s all your poisons tick 3x faster on all enemies.",
		"class": Enums.PlayerClass.ASSASSIN,
		"branch": Enums.SkillBranch.POISON,
		"is_ultimate": true,
		"damage_mult": 0.0,
		"cooldown": 50.0,
		"mana_cost": 75.0,
		"duration": 10.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.0,
		"dur_per_rank": 2.0,
		"prereq_id": "venom_nova",
		"prereq_rank": 3,
		"anim": "plague_lord",
	})


# ============================================================
# TANK – SHIELD BRANCH (GUARDIAN in Enums)
# ============================================================

static func _register_tank_shield() -> void:
	# 16. Shield Bash (T1) – Stun 1.5s
	_reg({
		"id": "shield_bash",
		"name": "Shield Bash",
		"description": "Bash with your shield, dealing damage and stunning the target for 1.5s.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.GUARDIAN,
		"damage_mult": 1.0,
		"cooldown": 7.0,
		"mana_cost": 15.0,
		"skill_type": Enums.SkillType.MELEE,
		"target_type": Enums.TargetType.SINGLE_ENEMY,
		"range": 40.0,
		"damage_per_rank": 0.15,
		"effect_type": Enums.EffectType.STUN,
		"effect_duration": 1.5,
		"effect_value": 0.3,
		"anim": "shield_bash",
	})

	# 17. Shield Wall (T2) – 60% DR, -50% mozgás
	_reg({
		"id": "shield_wall",
		"name": "Shield Wall",
		"description": "Raise your shield for 4s, reducing damage taken by 60% but slowing movement by 50%.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.GUARDIAN,
		"damage_mult": 0.0,
		"cooldown": 15.0,
		"mana_cost": 30.0,
		"duration": 4.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.0,
		"dur_per_rank": 0.5,
		"effect_type": Enums.EffectType.SHIELD,
		"effect_duration": 4.0,
		"effect_value": 60.0,
		"prereq_id": "shield_bash",
		"prereq_rank": 2,
		"anim": "shield_wall",
	})

	# 18. Shield Charge (T3) – Roham előre, knockback
	_reg({
		"id": "shield_charge",
		"name": "Shield Charge",
		"description": "Charge forward with your shield, knocking back enemies in your path.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.GUARDIAN,
		"damage_mult": 1.5,
		"cooldown": 12.0,
		"mana_cost": 35.0,
		"skill_type": Enums.SkillType.MELEE,
		"target_type": Enums.TargetType.DIRECTIONAL,
		"range": 192.0,
		"damage_per_rank": 0.2,
		"prereq_id": "shield_wall",
		"prereq_rank": 2,
		"anim": "shield_charge",
	})

	# 19. Fortress (T4) – CC immunity, 20% reflect
	_reg({
		"id": "fortress",
		"name": "Fortress",
		"description": "Become an unshakable fortress for 6s. Immune to all CC effects, reflect 20% damage.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.GUARDIAN,
		"damage_mult": 0.0,
		"cooldown": 20.0,
		"mana_cost": 50.0,
		"duration": 6.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.0,
		"prereq_id": "shield_charge",
		"prereq_rank": 3,
		"anim": "fortress",
	})

	# 20. Aegis of the Ancients (T5 Ultimate) – Party-wide 50% DR + CC immunity
	_reg({
		"id": "aegis_of_ancients",
		"name": "Aegis of the Ancients",
		"description": "Grant all party members 50% damage reduction and CC immunity for 8s.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.GUARDIAN,
		"is_ultimate": true,
		"damage_mult": 0.0,
		"cooldown": 65.0,
		"mana_cost": 90.0,
		"duration": 8.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 256.0,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.5,
		"cd_per_rank": 3.0,
		"prereq_id": "fortress",
		"prereq_rank": 3,
		"anim": "aegis_of_ancients",
	})


# ============================================================
# TANK – WARCRY BRANCH (WARBRINGER in Enums)
# ============================================================

static func _register_tank_warcry() -> void:
	# 21. Taunt (T1) – AoE aggro 5s
	_reg({
		"id": "taunt",
		"name": "Taunt",
		"description": "Force all enemies within range to attack you for 5s.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.WARBRINGER,
		"damage_mult": 0.0,
		"cooldown": 8.0,
		"mana_cost": 10.0,
		"duration": 5.0,
		"skill_type": Enums.SkillType.DEBUFF,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 160.0,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.0,
		"anim": "taunt",
	})

	# 22. Battle Shout (T2) – Party +15% damage 10s
	_reg({
		"id": "battle_shout",
		"name": "Battle Shout",
		"description": "Let out a battle cry, granting +15% damage to all party members for 10s.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.WARBRINGER,
		"damage_mult": 0.0,
		"cooldown": 18.0,
		"mana_cost": 25.0,
		"duration": 10.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 256.0,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.0,
		"effect_type": Enums.EffectType.DAMAGE_UP,
		"effect_duration": 10.0,
		"effect_value": 15.0,
		"prereq_id": "taunt",
		"prereq_rank": 2,
		"anim": "battle_shout",
	})

	# 23. Intimidate (T3) – Ellenségek -25% damage, -20% speed
	_reg({
		"id": "intimidate",
		"name": "Intimidate",
		"description": "Intimidate nearby enemies, reducing their damage by 25% and speed by 20% for 6s.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.WARBRINGER,
		"damage_mult": 0.0,
		"cooldown": 14.0,
		"mana_cost": 30.0,
		"duration": 6.0,
		"skill_type": Enums.SkillType.DEBUFF,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 160.0,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.0,
		"effect_type": Enums.EffectType.DAMAGE_DOWN,
		"effect_duration": 6.0,
		"effect_value": 25.0,
		"prereq_id": "battle_shout",
		"prereq_rank": 2,
		"anim": "intimidate",
	})

	# 24. Berserker Rage (T4) – +40% dmg, +30% speed, -20% def
	_reg({
		"id": "berserker_rage",
		"name": "Berserker Rage",
		"description": "Enter a berserker rage for 12s: +40% damage, +30% speed, but -20% defense.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.WARBRINGER,
		"damage_mult": 0.0,
		"cooldown": 25.0,
		"mana_cost": 45.0,
		"duration": 12.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.0,
		"dur_per_rank": 2.0,
		"effect_type": Enums.EffectType.DAMAGE_UP,
		"effect_duration": 12.0,
		"effect_value": 40.0,
		"prereq_id": "intimidate",
		"prereq_rank": 3,
		"anim": "berserker_rage",
	})

	# 25. Avatar of War (T5 Ultimate) – 10s óriás forma, AoE
	_reg({
		"id": "avatar_of_war",
		"name": "Avatar of War",
		"description": "Transform into a giant warrior for 10s. All attacks deal AoE damage.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.WARBRINGER,
		"is_ultimate": true,
		"damage_mult": 2.0,
		"cooldown": 60.0,
		"mana_cost": 85.0,
		"duration": 10.0,
		"skill_type": Enums.SkillType.TRANSFORMATION,
		"target_type": Enums.TargetType.SELF,
		"aoe_radius": 96.0,
		"damage_per_rank": 0.2,
		"dur_per_rank": 2.0,
		"prereq_id": "berserker_rage",
		"prereq_rank": 3,
		"anim": "avatar_of_war",
	})


# ============================================================
# TANK – FORTIFY BRANCH (PALADIN in Enums)
# ============================================================

static func _register_tank_fortify() -> void:
	# 26. Iron Skin (T1) – +30% armor 8s
	_reg({
		"id": "iron_skin",
		"name": "Iron Skin",
		"description": "Harden your skin, gaining +30% armor for 8s.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.PALADIN,
		"damage_mult": 0.0,
		"cooldown": 10.0,
		"mana_cost": 15.0,
		"duration": 8.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.0,
		"effect_type": Enums.EffectType.ARMOR_UP,
		"effect_duration": 8.0,
		"effect_value": 30.0,
		"anim": "iron_skin",
	})

	# 27. Ground Slam (T2) – AoE, slow 40% 4s
	_reg({
		"id": "ground_slam",
		"name": "Ground Slam",
		"description": "Slam the ground, dealing AoE damage and slowing enemies by 40% for 4s.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.PALADIN,
		"damage_mult": 1.3,
		"cooldown": 10.0,
		"mana_cost": 25.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 96.0,
		"damage_per_rank": 0.15,
		"effect_type": Enums.EffectType.SLOW,
		"effect_duration": 4.0,
		"effect_value": 40.0,
		"prereq_id": "iron_skin",
		"prereq_rank": 2,
		"anim": "ground_slam",
	})

	# 28. Stone Pillar (T3) – Falat emel 8s
	_reg({
		"id": "stone_pillar",
		"name": "Stone Pillar",
		"description": "Raise stone pillars that block enemy movement for 8s.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.PALADIN,
		"damage_mult": 0.0,
		"cooldown": 16.0,
		"mana_cost": 35.0,
		"duration": 8.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_GROUND,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.5,
		"prereq_id": "ground_slam",
		"prereq_rank": 2,
		"anim": "stone_pillar",
	})

	# 29. Regeneration Aura (T4) – Party HP regen +3%/s
	_reg({
		"id": "regeneration_aura",
		"name": "Regeneration Aura",
		"description": "Emit a healing aura for 12s, granting +3% HP regen/s to all party members.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.PALADIN,
		"damage_mult": 0.0,
		"cooldown": 22.0,
		"mana_cost": 50.0,
		"duration": 12.0,
		"skill_type": Enums.SkillType.HEAL,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 192.0,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.0,
		"effect_type": Enums.EffectType.HP_REGEN,
		"effect_duration": 12.0,
		"effect_value": 3.0,
		"prereq_id": "stone_pillar",
		"prereq_rank": 3,
		"anim": "regen_aura",
	})

	# 30. Unbreakable (T5 Ultimate) – 8s nem halhat meg
	_reg({
		"id": "unbreakable",
		"name": "Unbreakable",
		"description": "For 8s you cannot die. HP cannot drop below 1.",
		"class": Enums.PlayerClass.TANK,
		"branch": Enums.SkillBranch.PALADIN,
		"is_ultimate": true,
		"damage_mult": 0.0,
		"cooldown": 70.0,
		"mana_cost": 80.0,
		"duration": 8.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.5,
		"cd_per_rank": 5.0,
		"prereq_id": "regeneration_aura",
		"prereq_rank": 3,
		"anim": "unbreakable",
	})


# ============================================================
# MAGE – FIRE BRANCH (ARCANE in Enums maps to Fire for plan)
# ============================================================

static func _register_mage_fire() -> void:
	# 31. Fireball (T1) – Projektil, kis AoE robbanás
	_reg({
		"id": "fireball",
		"name": "Fireball",
		"description": "Launch a fireball that explodes on impact, dealing AoE fire damage.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.ARCANE,
		"damage_mult": 1.2,
		"cooldown": 3.0,
		"mana_cost": 15.0,
		"skill_type": Enums.SkillType.PROJECTILE,
		"target_type": Enums.TargetType.DIRECTIONAL,
		"range": 256.0,
		"aoe_radius": 48.0,
		"damage_per_rank": 0.15,
		"effect_type": Enums.EffectType.BURN_DOT,
		"effect_duration": 3.0,
		"effect_value": 8.0,
		"anim": "fireball",
	})

	# 32. Flame Wave (T2) – Előre haladó tűz fal
	_reg({
		"id": "flame_wave",
		"name": "Flame Wave",
		"description": "Send a wave of fire forward, burning all enemies in its path.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.ARCANE,
		"damage_mult": 1.0,
		"cooldown": 8.0,
		"mana_cost": 30.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.DIRECTIONAL,
		"range": 256.0,
		"aoe_radius": 128.0,
		"damage_per_rank": 0.15,
		"effect_type": Enums.EffectType.BURN_DOT,
		"effect_duration": 3.0,
		"effect_value": 10.0,
		"prereq_id": "fireball",
		"prereq_rank": 2,
		"anim": "flame_wave",
	})

	# 33. Meteor (T3) – Égből hullő meteor, nagy AoE
	_reg({
		"id": "meteor",
		"name": "Meteor",
		"description": "Call down a meteor from the sky. Massive AoE damage after a short delay.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.ARCANE,
		"damage_mult": 2.5,
		"cooldown": 14.0,
		"mana_cost": 45.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_GROUND,
		"aoe_radius": 112.0,
		"damage_per_rank": 0.3,
		"effect_type": Enums.EffectType.BURN_DOT,
		"effect_duration": 4.0,
		"effect_value": 15.0,
		"prereq_id": "flame_wave",
		"prereq_rank": 2,
		"anim": "meteor",
	})

	# 34. Combustion (T4) – Égő ellenségek robbannak halálkor
	_reg({
		"id": "combustion",
		"name": "Combustion",
		"description": "For 15s, burning enemies explode on death dealing AoE fire damage.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.ARCANE,
		"damage_mult": 0.0,
		"cooldown": 20.0,
		"mana_cost": 40.0,
		"duration": 15.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.15,
		"dur_per_rank": 2.0,
		"prereq_id": "meteor",
		"prereq_rank": 3,
		"anim": "combustion",
	})

	# 35. Inferno (T5 Ultimate) – 8s tűzeső
	_reg({
		"id": "inferno",
		"name": "Inferno",
		"description": "Rain fire on a large area for 8s, devastating enemies within.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.ARCANE,
		"is_ultimate": true,
		"damage_mult": 0.8,
		"cooldown": 55.0,
		"mana_cost": 90.0,
		"duration": 8.0,
		"skill_type": Enums.SkillType.CHANNEL,
		"target_type": Enums.TargetType.AOE_GROUND,
		"aoe_radius": 192.0,
		"damage_per_rank": 0.1,
		"dur_per_rank": 1.0,
		"prereq_id": "combustion",
		"prereq_rank": 3,
		"anim": "inferno",
	})


# ============================================================
# MAGE – ICE BRANCH (FROST in Enums)
# ============================================================

static func _register_mage_ice() -> void:
	# 36. Ice Bolt (T1) – Jég projektil, slow 30%
	_reg({
		"id": "ice_bolt",
		"name": "Ice Bolt",
		"description": "Fire a bolt of ice dealing damage and slowing the target by 30% for 3s.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.FROST,
		"damage_mult": 1.0,
		"cooldown": 2.5,
		"mana_cost": 12.0,
		"skill_type": Enums.SkillType.PROJECTILE,
		"target_type": Enums.TargetType.DIRECTIONAL,
		"range": 224.0,
		"damage_per_rank": 0.1,
		"effect_type": Enums.EffectType.SLOW,
		"effect_duration": 3.0,
		"effect_value": 30.0,
		"anim": "ice_bolt",
	})

	# 37. Frost Nova (T2) – AoE freeze 2.5s
	_reg({
		"id": "frost_nova",
		"name": "Frost Nova",
		"description": "Unleash a nova of frost, freezing all nearby enemies for 2.5s.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.FROST,
		"damage_mult": 0.8,
		"cooldown": 12.0,
		"mana_cost": 30.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 112.0,
		"damage_per_rank": 0.1,
		"effect_type": Enums.EffectType.FREEZE,
		"effect_duration": 2.5,
		"effect_value": 0.3,
		"prereq_id": "ice_bolt",
		"prereq_rank": 2,
		"anim": "frost_nova",
	})

	# 38. Blizzard (T3) – Területi hóvihar 6s
	_reg({
		"id": "blizzard",
		"name": "Blizzard",
		"description": "Summon a blizzard on a target area for 6s, dealing continuous damage and slowing.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.FROST,
		"damage_mult": 0.5,
		"cooldown": 16.0,
		"mana_cost": 40.0,
		"duration": 6.0,
		"skill_type": Enums.SkillType.CHANNEL,
		"target_type": Enums.TargetType.AOE_GROUND,
		"aoe_radius": 128.0,
		"damage_per_rank": 0.1,
		"dur_per_rank": 0.5,
		"effect_type": Enums.EffectType.SLOW,
		"effect_duration": 2.0,
		"effect_value": 40.0,
		"prereq_id": "frost_nova",
		"prereq_rank": 2,
		"anim": "blizzard",
	})

	# 39. Ice Prison (T4) – Célpont befagyasztása 4s + damage
	_reg({
		"id": "ice_prison",
		"name": "Ice Prison",
		"description": "Encase a target in ice for 4s, dealing continuous damage while frozen.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.FROST,
		"damage_mult": 1.5,
		"cooldown": 18.0,
		"mana_cost": 45.0,
		"duration": 4.0,
		"skill_type": Enums.SkillType.DEBUFF,
		"target_type": Enums.TargetType.SINGLE_ENEMY,
		"range": 192.0,
		"damage_per_rank": 0.2,
		"dur_per_rank": 0.5,
		"effect_type": Enums.EffectType.FREEZE,
		"effect_duration": 4.0,
		"effect_value": 1.0,
		"prereq_id": "blizzard",
		"prereq_rank": 3,
		"anim": "ice_prison",
	})

	# 40. Absolute Zero (T5 Ultimate) – Freeze mindent 6s
	_reg({
		"id": "absolute_zero",
		"name": "Absolute Zero",
		"description": "Freeze everything in a massive radius for 6s. Frozen enemies shatter for bonus damage.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.FROST,
		"is_ultimate": true,
		"damage_mult": 2.0,
		"cooldown": 60.0,
		"mana_cost": 85.0,
		"duration": 6.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_SELF,
		"aoe_radius": 256.0,
		"damage_per_rank": 0.25,
		"dur_per_rank": 1.0,
		"effect_type": Enums.EffectType.FREEZE,
		"effect_duration": 6.0,
		"effect_value": 1.0,
		"prereq_id": "ice_prison",
		"prereq_rank": 3,
		"anim": "absolute_zero",
	})


# ============================================================
# MAGE – ARCANE BRANCH (HOLY in Enums)
# ============================================================

static func _register_mage_arcane() -> void:
	# 41. Arcane Missile (T1) – 3 auto-tracking lövedék
	_reg({
		"id": "arcane_missile",
		"name": "Arcane Missile",
		"description": "Launch 3 homing arcane missiles at the nearest enemy.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.HOLY,
		"damage_mult": 0.5,
		"cooldown": 4.0,
		"mana_cost": 15.0,
		"skill_type": Enums.SkillType.PROJECTILE,
		"target_type": Enums.TargetType.SINGLE_ENEMY,
		"range": 256.0,
		"damage_per_rank": 0.05,
		"anim": "arcane_missile",
	})

	# 42. Mana Shield (T2) – Damage mana-ból vonja
	_reg({
		"id": "mana_shield",
		"name": "Mana Shield",
		"description": "For 10s, damage is absorbed by mana instead of HP.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.HOLY,
		"damage_mult": 0.0,
		"cooldown": 15.0,
		"mana_cost": 20.0,
		"duration": 10.0,
		"skill_type": Enums.SkillType.BUFF,
		"target_type": Enums.TargetType.SELF,
		"damage_per_rank": 0.0,
		"dur_per_rank": 1.0,
		"effect_type": Enums.EffectType.SHIELD,
		"effect_duration": 10.0,
		"effect_value": 100.0,
		"prereq_id": "arcane_missile",
		"prereq_rank": 2,
		"anim": "mana_shield",
	})

	# 43. Teleport (T3) – Instant teleport, 2 charge
	_reg({
		"id": "teleport",
		"name": "Teleport",
		"description": "Instantly teleport to target location. 2 charges.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.HOLY,
		"damage_mult": 0.0,
		"cooldown": 8.0,
		"mana_cost": 20.0,
		"skill_type": Enums.SkillType.TELEPORT,
		"target_type": Enums.TargetType.AOE_GROUND,
		"range": 256.0,
		"damage_per_rank": 0.0,
		"cd_per_rank": 1.0,
		"prereq_id": "mana_shield",
		"prereq_rank": 2,
		"anim": "teleport",
	})

	# 44. Arcane Singularity (T4) – Fekete lyuk
	_reg({
		"id": "arcane_singularity",
		"name": "Arcane Singularity",
		"description": "Create a black hole that pulls enemies in, dealing continuous arcane damage.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.HOLY,
		"damage_mult": 0.8,
		"cooldown": 20.0,
		"mana_cost": 55.0,
		"duration": 4.0,
		"skill_type": Enums.SkillType.AOE,
		"target_type": Enums.TargetType.AOE_GROUND,
		"aoe_radius": 160.0,
		"damage_per_rank": 0.3,
		"dur_per_rank": 0.5,
		"prereq_id": "teleport",
		"prereq_rank": 3,
		"anim": "arcane_singularity",
	})

	# 45. Arcane Cataclysm (T5 Ultimate) – Masszív arcane robbanássorozat
	_reg({
		"id": "arcane_cataclysm",
		"name": "Arcane Cataclysm",
		"description": "Unleash a devastating series of arcane explosions over 5s in a massive area.",
		"class": Enums.PlayerClass.MAGE,
		"branch": Enums.SkillBranch.HOLY,
		"is_ultimate": true,
		"damage_mult": 1.5,
		"cooldown": 65.0,
		"mana_cost": 95.0,
		"duration": 5.0,
		"skill_type": Enums.SkillType.CHANNEL,
		"target_type": Enums.TargetType.AOE_GROUND,
		"aoe_radius": 320.0,
		"damage_per_rank": 0.15,
		"dur_per_rank": 0.5,
		"prereq_id": "arcane_singularity",
		"prereq_rank": 3,
		"anim": "arcane_cataclysm",
	})

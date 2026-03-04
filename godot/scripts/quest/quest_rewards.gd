## QuestRewards - Quest jutalmak Resource
## Jutalom csomag: XP, gold, tárgyak, skill pontok, stb.
class_name QuestRewards
extends Resource

@export var xp: int = 0
@export var gold: int = 0
@export var dark_essence: int = 0
@export var relic_fragments: int = 0
@export var items: Array[String] = []           ## Item ID-k (garantált)
@export var item_choices: Array[String] = []    ## Válassz egyet ezek közül
@export var skill_points: int = 0
@export var profession_xp: Dictionary = {}      ## {profession_type: xp_amount}
@export var reputation: int = 0                  ## Faction reputation
@export var unlock: String = ""                  ## Amit felold (terület, NPC, stb.)


## Jutalom szöveg lista (UI megjelenítéshez)
func get_reward_texts() -> Array[String]:
	var texts: Array[String] = []
	
	if xp > 0:
		texts.append("%d XP" % xp)
	if gold > 0:
		texts.append("%d Gold" % gold)
	if dark_essence > 0:
		texts.append("%d Dark Essence" % dark_essence)
	if relic_fragments > 0:
		texts.append("%d Relic Fragment" % relic_fragments)
	if skill_points > 0:
		texts.append("%d Skill Point%s" % [skill_points, "s" if skill_points > 1 else ""])
	if not items.is_empty():
		for item_id in items:
			texts.append("Item: %s" % item_id)
	if not item_choices.is_empty():
		texts.append("Choose 1 of %d items" % item_choices.size())
	if not unlock.is_empty():
		texts.append("Unlock: %s" % unlock)
	
	return texts


## Dictionary konverzió (mentéshez)
func to_dict() -> Dictionary:
	return {
		"xp": xp,
		"gold": gold,
		"dark_essence": dark_essence,
		"relic_fragments": relic_fragments,
		"items": items,
		"item_choices": item_choices,
		"skill_points": skill_points,
		"profession_xp": profession_xp,
		"reputation": reputation,
		"unlock": unlock,
	}


## Dictionary-ből létrehozás
static func from_dict(data: Dictionary) -> QuestRewards:
	var rewards := QuestRewards.new()
	rewards.xp = data.get("xp", 0)
	rewards.gold = data.get("gold", 0)
	rewards.dark_essence = data.get("dark_essence", 0)
	rewards.relic_fragments = data.get("relic_fragments", 0)
	rewards.items = data.get("items", [])
	rewards.item_choices = data.get("item_choices", [])
	rewards.skill_points = data.get("skill_points", 0)
	rewards.profession_xp = data.get("profession_xp", {})
	rewards.reputation = data.get("reputation", 0)
	rewards.unlock = data.get("unlock", "")
	return rewards

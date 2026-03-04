## NPCSystem - NPC kezelés és interakció rendszer
## Kereskedő, quest adó, craftolás NPC-k
class_name NPCSystem
extends Node

signal npc_interacted(npc_id: String, npc_type: Enums.NPCType)
signal dialogue_started(npc_id: String, dialogue_data: Dictionary)
signal dialogue_ended(npc_id: String)

# Aktív NPC-k nyilvántartása
var active_npcs: Dictionary = {}  # npc_id -> NPC node referencia
var npc_data_cache: Dictionary = {}

# NPC adatok biome-onként
const NPC_TEMPLATES: Dictionary = {
	"blacksmith": {
		"name": "Blacksmith",
		"type": "MERCHANT",  # Enums.NPCType
		"profession": "blacksmithing",
		"services": ["repair", "craft", "enhance"],
		"shop_tier": 1,
	},
	"alchemist": {
		"name": "Alchemist",
		"type": "MERCHANT",
		"profession": "alchemy",
		"services": ["buy", "sell", "craft"],
		"shop_tier": 1,
	},
	"enchanter": {
		"name": "Enchanter",
		"type": "MERCHANT",
		"profession": "enchanting",
		"services": ["enchant", "disenchant", "craft"],
		"shop_tier": 1,
	},
	"tailor": {
		"name": "Tailor",
		"type": "MERCHANT",
		"profession": "tailoring",
		"services": ["craft", "buy", "sell"],
		"shop_tier": 1,
	},
	"stash_keeper": {
		"name": "Stash Keeper",
		"type": "SERVICE",
		"services": ["stash"],
		"shop_tier": 0,
	},
	"marketplace_broker": {
		"name": "Marketplace Broker",
		"type": "SERVICE",
		"services": ["marketplace"],
		"shop_tier": 0,
	},
	"quest_giver": {
		"name": "Quest Giver",
		"type": "QUEST_GIVER",
		"services": ["quest"],
		"shop_tier": 0,
	},
}


func _ready() -> void:
	# EventBus-ra feliratkozás
	if EventBus.has_signal("npc_interaction_requested"):
		EventBus.npc_interaction_requested.connect(_on_interaction_requested)


## NPC regisztrálás (NPC scene hívja _ready-ben)
func register_npc(npc_id: String, npc_node: Node, template_id: String = "") -> void:
	active_npcs[npc_id] = npc_node
	
	if not template_id.is_empty() and template_id in NPC_TEMPLATES:
		npc_data_cache[npc_id] = NPC_TEMPLATES[template_id].duplicate(true)
		npc_data_cache[npc_id]["template_id"] = template_id


## NPC eltávolítás
func unregister_npc(npc_id: String) -> void:
	active_npcs.erase(npc_id)
	npc_data_cache.erase(npc_id)


## Interakció kezelése
func _on_interaction_requested(npc_id: String, player: Node) -> void:
	interact_with_npc(npc_id, player)


func interact_with_npc(npc_id: String, player: Node) -> void:
	if npc_id not in active_npcs:
		return
	
	var npc_node: Node = active_npcs[npc_id]
	var data: Dictionary = npc_data_cache.get(npc_id, {})
	var npc_type_str: String = data.get("type", "SERVICE")
	
	# NPC-nek fordulás a player felé
	if npc_node.has_method("face_towards"):
		npc_node.face_towards(player.global_position)
	
	var services: Array = data.get("services", [])
	
	if services.size() == 1:
		# Egyetlen szolgáltatás - azonnal nyitjuk
		_open_service(services[0], npc_id, player, data)
	else:
		# Több szolgáltatás - dialogue/menü
		var dialogue_data := {
			"npc_name": data.get("name", "NPC"),
			"npc_id": npc_id,
			"services": services,
			"greeting": _get_greeting(npc_type_str),
		}
		dialogue_started.emit(npc_id, dialogue_data)
		npc_interacted.emit(npc_id, Enums.NPCType.MERCHANT if npc_type_str == "MERCHANT" else Enums.NPCType.QUEST_GIVER)


func _open_service(service: String, npc_id: String, _player: Node, data: Dictionary) -> void:
	match service:
		"buy", "sell":
			EventBus.shop_opened.emit(npc_id, data.get("shop_tier", 1))
		"craft":
			EventBus.crafting_opened.emit(data.get("profession", ""))
		"repair":
			EventBus.repair_requested.emit()
		"enhance":
			EventBus.enhance_opened.emit()
		"enchant", "disenchant":
			EventBus.enchanting_opened.emit()
		"stash":
			EventBus.stash_opened.emit()
		"marketplace":
			EventBus.marketplace_opened.emit()
		"quest":
			# QuestManager-en és DialogueManager-en keresztül
			if has_node("/root/QuestManager") and has_node("/root/DialogueManager"):
				QuestManager.handle_quest_npc_interaction(npc_id)
			else:
				EventBus.quest_dialogue_opened.emit(npc_id)


func _get_greeting(npc_type: String) -> String:
	match npc_type:
		"MERCHANT":
			var greetings := [
				"Welcome, traveler. What do you need?",
				"I have the finest wares. Take a look.",
				"What can I do for you?",
			]
			return greetings[randi() % greetings.size()]
		"QUEST_GIVER":
			return "I have a task that needs doing..."
		_:
			return "How can I help you?"


## Legközelebbi NPC keresése
func find_nearest_npc(world_pos: Vector2, max_distance: float = 200.0) -> String:
	var nearest_id: String = ""
	var nearest_dist: float = max_distance
	
	for npc_id in active_npcs:
		var npc_node: Node = active_npcs[npc_id]
		if is_instance_valid(npc_node) and npc_node is Node2D:
			var dist: float = (npc_node as Node2D).global_position.distance_to(world_pos)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_id = npc_id
	
	return nearest_id


## NPC-k listája típus szerint
func get_npcs_by_type(npc_type: String) -> Array[String]:
	var result: Array[String] = []
	for npc_id in npc_data_cache:
		if npc_data_cache[npc_id].get("type", "") == npc_type:
			result.append(npc_id)
	return result


## Quest jelölők frissítése az NPC-ken (!, ?)
func update_quest_indicators() -> void:
	if not has_node("/root/QuestManager"):
		return
	
	for npc_id in active_npcs:
		var npc_node: Node = active_npcs[npc_id]
		if not is_instance_valid(npc_node):
			continue
		
		var indicator: String = get_quest_indicator_for_npc(npc_id)
		if npc_node.has_method("set_quest_indicator"):
			npc_node.set_quest_indicator(indicator)


## Quest indicator meghatározása egy NPC-hez
func get_quest_indicator_for_npc(npc_id: String) -> String:
	if not has_node("/root/QuestManager"):
		return ""
	
	# Van leadható quest? -> "?"
	for quest_id in QuestManager.active_quest_ids:
		if QuestManager.quest_database.has(quest_id):
			var quest: QuestData = QuestManager.quest_database[quest_id]
			if quest.turn_in_npc_id == npc_id:
				var state: int = QuestManager.quest_states.get(quest_id, 0)
				if state == QuestManager.QuestState.COMPLETE:
					return "?"
	
	# Van felvehető quest? -> "!"
	var available := QuestManager.get_available_quests_for_npc(npc_id)
	if not available.is_empty():
		return "!"
	
	return ""

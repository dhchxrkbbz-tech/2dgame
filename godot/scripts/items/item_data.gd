## ItemData - Alap item definíció (base item adatok)
class_name ItemData
extends Resource

@export var item_id: String = ""
@export var item_name: String = ""
@export var item_type: int = Enums.ItemType.WEAPON  # Enums.ItemType
@export var equip_slot: int = Enums.EquipSlot.MAIN_HAND  # Enums.EquipSlot 
@export var required_class: int = -1  # -1 = bármely class, Enums.PlayerClass
@export var item_level: int = 1
@export var required_level: int = 1
@export var rarity: int = Enums.Rarity.COMMON

# Base statisztikák
@export var base_damage: int = 0
@export var base_armor: int = 0
@export var base_hp: int = 0
@export var base_mana: int = 0
@export var base_speed: float = 0.0

# Speciális
@export var description: String = ""
@export var icon_color: Color = Color.WHITE
@export var stackable: bool = false
@export var max_stack: int = 1
@export var sell_price: int = 1

# Socket-ek
@export var socket_count: int = 0

## TrapData - Resource: csapda típus definíciók
## Minden csapda típus konfigurációja
class_name TrapData
extends Resource

@export var trap_id: String = ""
@export var trap_name: String = ""
@export var damage_percent: float = 0.15  # Max HP százaléka
@export var trigger_type: String = "pressure"  # pressure, proximity, timed, tripwire, step, aura
@export var cooldown: float = 3.0
@export var telegraph_time: float = 0.3  # Előjelzés ideje
@export var radius: float = 16.0
@export var effect_type: int = -1  # Enums.EffectType
@export var effect_duration: float = 3.0
@export var effect_value: float = 0.0
@export var is_visible: bool = true  # Látható-e alapesetben
@export var is_destroyable: bool = false  # Elpusztítható-e
@export var hp: int = 0  # Ha elpusztítható
@export var timed_interval: float = 3.0  # Timed trap-eknél
@export var timed_active_time: float = 1.0
@export var projectile_speed: float = 200.0  # Arrow trap
@export var sprite_color: Color = Color(0.5, 0.5, 0.5, 0.5)


## Előre definiált trap preset-ek
static func get_all_presets() -> Dictionary:
	return {
		"spike": _create_spike(),
		"poison_gas": _create_poison_gas(),
		"fire_jet": _create_fire_jet(),
		"arrow": _create_arrow(),
		"falling_rocks": _create_falling_rocks(),
		"pit": _create_pit(),
		"curse_totem": _create_curse_totem(),
	}


static func get_preset(trap_type: String) -> TrapData:
	var presets := get_all_presets()
	return presets.get(trap_type, _create_spike())


static func _create_spike() -> TrapData:
	var t := TrapData.new()
	t.trap_id = "spike"
	t.trap_name = "Spike Trap"
	t.damage_percent = 0.15
	t.trigger_type = "pressure"
	t.cooldown = 3.0
	t.telegraph_time = 0.3
	t.radius = 16.0
	t.sprite_color = Color(0.5, 0.5, 0.5, 0.5)
	return t


static func _create_poison_gas() -> TrapData:
	var t := TrapData.new()
	t.trap_id = "poison_gas"
	t.trap_name = "Poison Gas"
	t.damage_percent = 0.05  # /sec
	t.trigger_type = "proximity"
	t.radius = 48.0
	t.effect_type = Enums.EffectType.POISON_DOT
	t.effect_duration = 3.0
	t.sprite_color = Color(0.2, 0.8, 0.2, 0.3)
	return t


static func _create_fire_jet() -> TrapData:
	var t := TrapData.new()
	t.trap_id = "fire_jet"
	t.trap_name = "Fire Jet"
	t.damage_percent = 0.20
	t.trigger_type = "timed"
	t.timed_interval = 3.0
	t.timed_active_time = 1.0
	t.effect_type = Enums.EffectType.BURN_DOT
	t.effect_duration = 3.0
	t.sprite_color = Color(1.0, 0.3, 0.0, 0.4)
	return t


static func _create_arrow() -> TrapData:
	var t := TrapData.new()
	t.trap_id = "arrow"
	t.trap_name = "Arrow Trap"
	t.damage_percent = 0.10
	t.trigger_type = "tripwire"
	t.projectile_speed = 200.0
	t.sprite_color = Color(0.6, 0.4, 0.2, 0.5)
	return t


static func _create_falling_rocks() -> TrapData:
	var t := TrapData.new()
	t.trap_id = "falling_rocks"
	t.trap_name = "Falling Rocks"
	t.damage_percent = 0.25
	t.trigger_type = "proximity"
	t.radius = 32.0
	t.telegraph_time = 1.0
	t.effect_type = Enums.EffectType.STUN
	t.effect_duration = 1.5
	t.sprite_color = Color(0.4, 0.3, 0.2, 0.4)
	return t


static func _create_pit() -> TrapData:
	var t := TrapData.new()
	t.trap_id = "pit"
	t.trap_name = "Pit Trap"
	t.damage_percent = 0.30
	t.trigger_type = "step"
	t.is_visible = false
	t.sprite_color = Color(0.1, 0.1, 0.1, 0.2)
	return t


static func _create_curse_totem() -> TrapData:
	var t := TrapData.new()
	t.trap_id = "curse_totem"
	t.trap_name = "Curse Totem"
	t.damage_percent = 0.0
	t.trigger_type = "aura"
	t.radius = 64.0
	t.effect_type = Enums.EffectType.DAMAGE_DOWN
	t.effect_value = 20.0
	t.effect_duration = 5.0
	t.is_destroyable = true
	t.hp = 100
	t.sprite_color = Color(0.5, 0.0, 0.5, 0.5)
	return t


## Difficulty-alapú trap típus lista
static func get_trap_types_for_difficulty(difficulty: int) -> Array[String]:
	var types: Array[String] = ["spike", "arrow"]
	
	if difficulty >= 3:
		types.append("poison_gas")
	if difficulty >= 4:
		types.append("fire_jet")
	if difficulty >= 5:
		types.append("falling_rocks")
	if difficulty >= 6:
		types.append("pit")
	if difficulty >= 7:
		types.append("curse_totem")
	
	return types

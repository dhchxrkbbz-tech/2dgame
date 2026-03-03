## BTDecorator - Dekorátor node-ok gyűjteménye
## Egy gyerek node-ot módosít (inverter, repeater, cooldown, stb.)
class_name BTDecorator_Node
extends BTNode

enum DecoratorType {
	INVERTER,        # SUCCESS ↔ FAILURE
	SUCCEEDER,       # Mindig SUCCESS
	FAILER,          # Mindig FAILURE
	REPEATER,        # N-szer ismétli
	REPEAT_UNTIL_SUCCESS,
	REPEAT_UNTIL_FAILURE,
	COOLDOWN,        # Cooldown idővel
	LIMITER,         # Max N tick
	RANDOM_CHANCE,   # Véletlenszerű eséllyel futtat
}

var decorator_type: DecoratorType = DecoratorType.INVERTER

# Repeater
var repeat_count: int = 1
var current_repeat: int = 0

# Cooldown
var cooldown_time: float = 1.0
var cooldown_timer: float = 0.0

# Limiter
var max_ticks: int = 100
var current_ticks: int = 0

# Random chance
var chance: float = 0.5


func _init(type: DecoratorType, p_name: String = "Decorator") -> void:
	super(p_name)
	decorator_type = type


func _execute(delta: float, blackboard: Dictionary) -> Status:
	if children.is_empty():
		return Status.FAILURE
	
	match decorator_type:
		DecoratorType.INVERTER:
			return _inverter(delta, blackboard)
		DecoratorType.SUCCEEDER:
			return _succeeder(delta, blackboard)
		DecoratorType.FAILER:
			return _failer(delta, blackboard)
		DecoratorType.REPEATER:
			return _repeater(delta, blackboard)
		DecoratorType.REPEAT_UNTIL_SUCCESS:
			return _repeat_until(delta, blackboard, true)
		DecoratorType.REPEAT_UNTIL_FAILURE:
			return _repeat_until(delta, blackboard, false)
		DecoratorType.COOLDOWN:
			return _cooldown(delta, blackboard)
		DecoratorType.LIMITER:
			return _limiter(delta, blackboard)
		DecoratorType.RANDOM_CHANCE:
			return _random_chance(delta, blackboard)
	
	return Status.FAILURE


func _inverter(delta: float, blackboard: Dictionary) -> Status:
	var result := children[0].tick(delta, blackboard)
	match result:
		Status.SUCCESS: return Status.FAILURE
		Status.FAILURE: return Status.SUCCESS
		_: return result


func _succeeder(delta: float, blackboard: Dictionary) -> Status:
	children[0].tick(delta, blackboard)
	return Status.SUCCESS


func _failer(delta: float, blackboard: Dictionary) -> Status:
	children[0].tick(delta, blackboard)
	return Status.FAILURE


func _repeater(delta: float, blackboard: Dictionary) -> Status:
	var result := children[0].tick(delta, blackboard)
	if result != Status.RUNNING:
		current_repeat += 1
		if current_repeat >= repeat_count:
			current_repeat = 0
			return Status.SUCCESS
	return Status.RUNNING


func _repeat_until(delta: float, blackboard: Dictionary, until_success: bool) -> Status:
	var result := children[0].tick(delta, blackboard)
	if result == Status.RUNNING:
		return Status.RUNNING
	if until_success and result == Status.SUCCESS:
		return Status.SUCCESS
	if not until_success and result == Status.FAILURE:
		return Status.SUCCESS
	return Status.RUNNING


func _cooldown(delta: float, blackboard: Dictionary) -> Status:
	cooldown_timer -= delta
	if cooldown_timer > 0:
		return Status.FAILURE
	
	var result := children[0].tick(delta, blackboard)
	if result == Status.SUCCESS:
		cooldown_timer = cooldown_time
	return result


func _limiter(delta: float, blackboard: Dictionary) -> Status:
	current_ticks += 1
	if current_ticks > max_ticks:
		return Status.FAILURE
	return children[0].tick(delta, blackboard)


func _random_chance(delta: float, blackboard: Dictionary) -> Status:
	if randf() > chance:
		return Status.FAILURE
	return children[0].tick(delta, blackboard)


func reset() -> void:
	super()
	current_repeat = 0
	cooldown_timer = 0.0
	current_ticks = 0


## === Factory metódusok ===

static func inverter(p_name: String = "Inverter") -> BTDecorator_Node:
	return BTDecorator_Node.new(DecoratorType.INVERTER, p_name)


static func cooldown(cd: float, p_name: String = "Cooldown") -> BTDecorator_Node:
	var node := BTDecorator_Node.new(DecoratorType.COOLDOWN, p_name)
	node.cooldown_time = cd
	return node


static func repeater(count: int, p_name: String = "Repeater") -> BTDecorator_Node:
	var node := BTDecorator_Node.new(DecoratorType.REPEATER, p_name)
	node.repeat_count = count
	return node


static func random(ch: float, p_name: String = "Random") -> BTDecorator_Node:
	var node := BTDecorator_Node.new(DecoratorType.RANDOM_CHANCE, p_name)
	node.chance = ch
	return node

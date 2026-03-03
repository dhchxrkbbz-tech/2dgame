## BTAction - Akció node
## Callable-t hív ami BTNode.Status-t ad vissza
class_name BTAction_Node
extends BTNode

var action_func: Callable

# Opcionális: single-frame vs multi-frame akció
var is_instant: bool = false  # Ha true, egyből SUCCESS-t ad
var timeout: float = 0.0      # Max futási idő (0 = végtelen)
var elapsed_time: float = 0.0


func _init(callable: Callable, p_name: String = "Action", p_instant: bool = false) -> void:
	super(p_name)
	action_func = callable
	is_instant = p_instant


func _execute(delta: float, blackboard: Dictionary) -> Status:
	if not action_func.is_valid():
		return Status.FAILURE
	
	elapsed_time += delta
	
	# Timeout check
	if timeout > 0 and elapsed_time >= timeout:
		elapsed_time = 0.0
		return Status.FAILURE
	
	var result = action_func.call(delta, blackboard)
	
	# Callable visszatérhet int-tel (Status) vagy bool-lal
	if result is bool:
		elapsed_time = 0.0
		return Status.SUCCESS if result else Status.FAILURE
	elif result is int:
		if result != Status.RUNNING:
			elapsed_time = 0.0
		return result
	
	elapsed_time = 0.0
	return Status.SUCCESS


func reset() -> void:
	super()
	elapsed_time = 0.0


## === Gyakori akció factory-k ===

## Blackboard-ba ír
static func set_value(key: String, value: Variant) -> BTAction_Node:
	return BTAction_Node.new(
		func(_delta: float, bb: Dictionary) -> int:
			bb[key] = value
			return Status.SUCCESS,
		"Set:%s" % key,
		true
	)


## Várakozás
static func wait(duration: float) -> BTAction_Node:
	var node := BTAction_Node.new(
		func(delta: float, bb: Dictionary) -> int:
			var timer: float = bb.get("_wait_timer", 0.0)
			timer += delta
			bb["_wait_timer"] = timer
			if timer >= duration:
				bb.erase("_wait_timer")
				return Status.SUCCESS
			return Status.RUNNING,
		"Wait:%.1fs" % duration
	)
	return node


## Logolás (debug)
static func log_message(message: String) -> BTAction_Node:
	return BTAction_Node.new(
		func(_delta: float, _bb: Dictionary) -> int:
			print("[BT] %s" % message)
			return Status.SUCCESS,
		"Log:%s" % message,
		true
	)

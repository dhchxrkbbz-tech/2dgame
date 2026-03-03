## BTCondition - Feltétel node
## Callable-t hív, ami bool-t ad vissza → SUCCESS/FAILURE
class_name BTCondition_Node
extends BTNode

var condition_func: Callable
var negate: bool = false  # Invertálja-e az eredményt


func _init(callable: Callable, p_name: String = "Condition", p_negate: bool = false) -> void:
	super(p_name)
	condition_func = callable
	negate = p_negate


func _execute(_delta: float, blackboard: Dictionary) -> Status:
	if not condition_func.is_valid():
		return Status.FAILURE
	
	var result: bool = condition_func.call(blackboard)
	if negate:
		result = not result
	
	return Status.SUCCESS if result else Status.FAILURE


## === Gyakori feltétel factory-k ===

## Blackboard key létezik-e
static func has_key(key: String, p_name: String = "") -> BTCondition_Node:
	var name := p_name if not p_name.is_empty() else "Has:%s" % key
	return BTCondition_Node.new(
		func(bb: Dictionary) -> bool: return key in bb,
		name
	)


## Blackboard key értéke kisebb-e mint
static func less_than(key: String, value: float, p_name: String = "") -> BTCondition_Node:
	var name := p_name if not p_name.is_empty() else "%s<%.1f" % [key, value]
	return BTCondition_Node.new(
		func(bb: Dictionary) -> bool: return bb.get(key, 0.0) < value,
		name
	)


## Blackboard key értéke nagyobb-e mint
static func greater_than(key: String, value: float, p_name: String = "") -> BTCondition_Node:
	var name := p_name if not p_name.is_empty() else "%s>%.1f" % [key, value]
	return BTCondition_Node.new(
		func(bb: Dictionary) -> bool: return bb.get(key, 0.0) > value,
		name
	)


## Távolság check
static func distance_less_than(key_a: String, key_b: String, distance: float) -> BTCondition_Node:
	return BTCondition_Node.new(
		func(bb: Dictionary) -> bool:
			var pos_a: Vector2 = bb.get(key_a, Vector2.ZERO)
			var pos_b: Vector2 = bb.get(key_b, Vector2.ZERO)
			return pos_a.distance_to(pos_b) < distance,
		"Dist<%d" % int(distance)
	)

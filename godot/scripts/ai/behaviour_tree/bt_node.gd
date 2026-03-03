## BTNode - Behaviour Tree alap node (standalone verzió)
## Minden BT node ebből származik
class_name BTNode
extends RefCounted

enum Status {
	SUCCESS,
	FAILURE,
	RUNNING,
}

var children: Array[BTNode] = []
var parent: BTNode = null
var node_name: String = ""
var is_active: bool = false

# Debug
var last_status: Status = Status.FAILURE
var tick_count: int = 0


func _init(p_name: String = "") -> void:
	node_name = p_name


## Fő tick - minden frame-ben hívódik
func tick(delta: float, blackboard: Dictionary) -> Status:
	tick_count += 1
	is_active = true
	var result := _execute(delta, blackboard)
	last_status = result
	if result != Status.RUNNING:
		is_active = false
	return result


## Override-olandó a leszármazottakban
func _execute(_delta: float, _blackboard: Dictionary) -> Status:
	return Status.FAILURE


## Gyerek hozzáadása
func add_child_node(child: BTNode) -> BTNode:
	child.parent = self
	children.append(child)
	return self


## Gyerekek eltávolítása
func clear_children() -> void:
	for child in children:
		child.parent = null
	children.clear()


## Reset - rekurzív
func reset() -> void:
	is_active = false
	last_status = Status.FAILURE
	for child in children:
		child.reset()


## Debug string
func get_debug_info() -> String:
	var status_str: String
	match last_status:
		Status.SUCCESS: status_str = "SUCCESS"
		Status.FAILURE: status_str = "FAILURE"
		Status.RUNNING: status_str = "RUNNING"
	return "[%s] %s (ticks: %d)" % [status_str, node_name, tick_count]


## Debug fa kiírása
func get_tree_string(indent: int = 0) -> String:
	var text := "  ".repeat(indent) + get_debug_info() + "\n"
	for child in children:
		text += child.get_tree_string(indent + 1)
	return text

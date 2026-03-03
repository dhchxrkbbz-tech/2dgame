## BehaviourTree - Egyedi BT implementáció GDScript-ben
## Node típusok: Selector, Sequence, Condition, Action, Decorator
class_name BehaviourTree
extends Node

enum BTStatus {
	SUCCESS,
	FAILURE,
	RUNNING
}

var root_node: BTNode = null
var blackboard: Dictionary = {}


func _process(delta: float) -> void:
	if root_node:
		root_node.tick(delta, blackboard)


func setup(root: BTNode) -> void:
	root_node = root


# === BT Node alapok ===

class BTNode:
	var children: Array[BTNode] = []
	
	func tick(_delta: float, _bb: Dictionary) -> int:
		return BTStatus.FAILURE
	
	func add_child_node(child: BTNode) -> BTNode:
		children.append(child)
		return self


class BTSelector extends BTNode:
	## Gyerekeket sorban próbálja, az elsőnél megáll ami SUCCESS/RUNNING
	func tick(delta: float, bb: Dictionary) -> int:
		for child in children:
			var result := child.tick(delta, bb)
			if result != BTStatus.FAILURE:
				return result
		return BTStatus.FAILURE


class BTSequence extends BTNode:
	## Gyerekeket sorban futtatja, az elsőnél megáll ami FAILURE
	func tick(delta: float, bb: Dictionary) -> int:
		for child in children:
			var result := child.tick(delta, bb)
			if result != BTStatus.SUCCESS:
				return result
		return BTStatus.SUCCESS


class BTCondition extends BTNode:
	## Feltétel ellenőrzés
	var condition_func: Callable
	
	func _init(callable: Callable) -> void:
		condition_func = callable
	
	func tick(_delta: float, bb: Dictionary) -> int:
		if condition_func.call(bb):
			return BTStatus.SUCCESS
		return BTStatus.FAILURE


class BTAction extends BTNode:
	## Akció végrehajtás
	var action_func: Callable
	
	func _init(callable: Callable) -> void:
		action_func = callable
	
	func tick(delta: float, bb: Dictionary) -> int:
		return action_func.call(delta, bb)


class BTInverter extends BTNode:
	## Eredmény invertálás
	func tick(delta: float, bb: Dictionary) -> int:
		if children.is_empty():
			return BTStatus.FAILURE
		var result := children[0].tick(delta, bb)
		match result:
			BTStatus.SUCCESS: return BTStatus.FAILURE
			BTStatus.FAILURE: return BTStatus.SUCCESS
			_: return result


class BTCooldown extends BTNode:
	## Cooldown dekorátor - csak X másodpercenként engedi futni
	var cooldown: float
	var timer: float = 0.0
	
	func _init(cd: float) -> void:
		cooldown = cd
	
	func tick(delta: float, bb: Dictionary) -> int:
		timer -= delta
		if timer > 0:
			return BTStatus.FAILURE
		if children.is_empty():
			return BTStatus.FAILURE
		var result := children[0].tick(delta, bb)
		if result == BTStatus.SUCCESS:
			timer = cooldown
		return result


class BTRandomChance extends BTNode:
	## Random eséllyel futtat
	var chance: float
	
	func _init(ch: float) -> void:
		chance = ch
	
	func tick(delta: float, bb: Dictionary) -> int:
		if randf() > chance:
			return BTStatus.FAILURE
		if children.is_empty():
			return BTStatus.FAILURE
		return children[0].tick(delta, bb)

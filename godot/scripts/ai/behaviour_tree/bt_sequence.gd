## BTSequence - Sequence node (AND logika)
## Gyerekeket sorban futtatja, az elsőnél megáll ami FAILURE
## Ha minden gyerek SUCCESS → SUCCESS
class_name BTSequence_Node
extends BTNode

var current_child_index: int = 0
var resume_from_running: bool = true


func _init(p_name: String = "Sequence") -> void:
	super(p_name)


func _execute(delta: float, blackboard: Dictionary) -> Status:
	var start_index := current_child_index if resume_from_running else 0
	
	for i in range(start_index, children.size()):
		var result := children[i].tick(delta, blackboard)
		
		match result:
			Status.FAILURE:
				current_child_index = 0
				return Status.FAILURE
			Status.RUNNING:
				current_child_index = i
				return Status.RUNNING
			Status.SUCCESS:
				continue
	
	current_child_index = 0
	return Status.SUCCESS


func reset() -> void:
	super()
	current_child_index = 0

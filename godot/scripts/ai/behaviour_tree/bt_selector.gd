## BTSelector - Selector node (OR logika)
## Gyerekeket sorban próbálja, az elsőnél megáll ami SUCCESS/RUNNING
## Ha minden gyerek FAILURE → FAILURE
class_name BTSelector_Node
extends BTNode

## Az aktuálisan futó gyerek indexe (RUNNING állapot esetén)
var current_child_index: int = 0
var resume_from_running: bool = true  # Folytatja-e a RUNNING gyerektől


func _init(p_name: String = "Selector") -> void:
	super(p_name)


func _execute(delta: float, blackboard: Dictionary) -> Status:
	var start_index := current_child_index if resume_from_running else 0
	
	for i in range(start_index, children.size()):
		var result := children[i].tick(delta, blackboard)
		
		match result:
			Status.SUCCESS:
				current_child_index = 0
				return Status.SUCCESS
			Status.RUNNING:
				current_child_index = i
				return Status.RUNNING
			Status.FAILURE:
				continue
	
	current_child_index = 0
	return Status.FAILURE


func reset() -> void:
	super()
	current_child_index = 0

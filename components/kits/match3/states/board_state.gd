class_name BoardState extends MachineState

@export var board: BoardUI


func _enter_tree() -> void:
	if board == null:
		board = get_tree().get_first_node_in_group(BoardUI.group_name)

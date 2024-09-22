class_name WaitForInput extends BoardState



func enter() -> void:
	board.unlock()


func exit(_next_state: MachineState) -> void:
	board.lock()

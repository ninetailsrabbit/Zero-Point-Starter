class_name Consume extends BoardState

var sequences: Array[Sequence] = []

func exit(_next_state: MachineState):
	sequences.clear()


func enter() -> void:
	await board.sequence_consumer.consume_sequences(sequences)
	await get_tree().process_frame

	FSM.change_state_to("Fill")

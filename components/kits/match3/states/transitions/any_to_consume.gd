class_name AnyToConsumeTransition extends MachineTransition



func should_transition() -> bool:
	if parameters.has("matches"):
		var initial_sequences: Array[Sequence] = parameters["matches"] as Array[Sequence]
		
		if to_state is Consume:
			to_state.sequences = initial_sequences
			
			return true
		
	return false

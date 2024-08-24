class_name Idle extends GroundState



func physics_update(delta):
	super.physics_update(delta)
	
	decelerate(delta)
	
	if not actor.current_input_direction().is_zero_approx():
		FSM.change_state_to("Walk")
	
	detect_crouch()
	
	actor.move_and_slide()

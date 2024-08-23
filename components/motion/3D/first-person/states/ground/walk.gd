class_name Walk extends GroundState


func enter():
	actor.velocity.y = 0
	
	
	
func physics_update(delta):
	super.physics_update(delta)
	
	if actor.motion_input.input_direction.is_zero_approx():
		FSM.change_state_to("Idle")
	
	accelerate(delta)
	actor.move_and_slide()

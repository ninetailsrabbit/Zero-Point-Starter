class_name Idle extends GroundState



func physics_update(delta):
	super.physics_update(delta)

	actor.move_and_slide()

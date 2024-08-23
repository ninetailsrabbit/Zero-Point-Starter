class_name GroundState extends MachineState

@export var actor: FirstPersonController
@export var gravity_force: float = 9.8
@export var speed: float = 3.0
@export var side_speed: float = 2.5
@export var acceleration: float = 8.0
@export var friction: float = 10.0


func physics_update(delta):
	if not actor.is_grounded:
		apply_gravity(gravity_force, delta)

	if actor.is_falling():
		pass # TODO - IMPLEMENT FALLING STATE


func apply_gravity(force: float = gravity_force, delta: float = get_physics_process_delta_time()):
	actor.velocity += VectorHelper.up_direction_opposite_vector3(actor.up_direction) * force * delta

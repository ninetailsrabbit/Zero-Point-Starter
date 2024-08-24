class_name AirState extends MachineState


@export var actor: FirstPersonController
@export_group("Parameters")
@export var gravity_force: float = 9.8
@export var air_speed: float = 3.0
@export var air_side_speed: float = 2.5
@export var air_acceleration: float = 8.0
@export var air_friction: float = 10.0
@export var maximum_fall_velocity: float = 25.0
@export_group("Input actions")
@export var jump_input_action: String = "jump"



func physics_update(delta: float):
	apply_gravity(gravity_force, delta)
	limit_fall_velocity()


func apply_gravity(force: float = gravity_force, delta: float = get_physics_process_delta_time()):
	actor.velocity += VectorHelper.up_direction_opposite_vector3(actor.up_direction) * force * delta


func detect_jump() -> void:
	if actor.jump and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action):
		FSM.change_state_to("Jump")


func limit_fall_velocity() -> void:
	var up_direction_opposite = VectorHelper.up_direction_opposite_vector3(actor.up_direction)
	
	if up_direction_opposite in [Vector3.DOWN, Vector3.UP]:
		actor.velocity.y = max(sign(up_direction_opposite.y) * maximum_fall_velocity, actor.velocity.y)
	else:
		actor.velocity.x = max(sign(up_direction_opposite.x) * maximum_fall_velocity, actor.velocity.x)
		
	

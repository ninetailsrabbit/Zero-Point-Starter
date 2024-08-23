class_name GroundState extends MachineState

@export var actor: FirstPersonController
@export var gravity_force: float = 9.8
@export var speed: float = 3.0
@export var side_speed: float = 2.5
@export var acceleration: float = 8.0
@export var friction: float = 10.0

var current_speed: float = 0
func physics_update(delta):
	if not actor.is_grounded:
		apply_gravity(gravity_force, delta)

	if actor.is_falling():
		pass # TODO - IMPLEMENT FALLING STATE


func apply_gravity(force: float = gravity_force, delta: float = get_physics_process_delta_time()):
	actor.velocity += VectorHelper.up_direction_opposite_vector3(actor.up_direction) * force * delta


func accelerate(delta: float = get_physics_process_delta_time()) -> void:
	var direction = actor.current_input_direction()
	current_speed = get_speed()
	
	if acceleration > 0:
		actor.velocity = lerp(actor.velocity, direction * current_speed, clamp(acceleration * delta, 0, 1.0))
	else:
		actor.velocity = direction * current_speed


func decelerate(delta: float = get_physics_process_delta_time()) -> void:
	if friction > 0:
		actor.velocity = lerp(actor.velocity, Vector3.ZERO, clamp(friction * delta, 0, 1.0))
	else:
		actor.velocity = Vector3.ZERO


func get_speed() -> float:
	return side_speed if actor.motion_input.input_direction in [Vector2.RIGHT, Vector2.LEFT] else speed

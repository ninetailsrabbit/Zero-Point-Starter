class_name GroundState extends MachineState

@export var actor: FirstPersonController
@export_group("Parameters")
@export var gravity_force: float = 9.8
@export var speed: float = 3.0
@export var side_speed: float = 2.5
@export var acceleration: float = 8.0
@export var friction: float = 10.0
@export_group("Input actions")
@export var run_input_action: String = "run"
@export var jump_input_action: String = "jump"
@export var crouch_input_action: String = "crouch"
@export var crawl_input_action: String = "crawl"
@export_group("Animation")
@export var crouch_animation: String = "crouch"
@export var crawl_animation: String = "crawl"



var current_speed: float = 0
func physics_update(delta):
	if not actor.is_grounded:
		apply_gravity(gravity_force, delta)

	if actor.is_falling():
		FSM.change_state_to("Fall")


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


func detect_run() -> void:
	if actor.run and InputMap.has_action(run_input_action) and Input.is_action_pressed(run_input_action):
		FSM.change_state_to("Run")


func detect_slide() -> void:
	if actor.crouch and actor.slide and InputMap.has_action(crouch_input_action) and Input.is_action_pressed(crouch_input_action):
		FSM.change_state_to("Slide")
	

func detect_crouch() -> void:
	if actor.crouch and InputMap.has_action(crouch_input_action) and Input.is_action_pressed(crouch_input_action):
		FSM.change_state_to("Crouch")


func detect_crawl() -> void:
	if actor.crawl and InputMap.has_action(crawl_input_action) and Input.is_action_pressed(crawl_input_action):
		FSM.change_state_to("Crawl")


func detect_jump() -> void:
	if actor.jump and InputMap.has_action(jump_input_action) and Input.is_action_just_pressed(jump_input_action):
		FSM.change_state_to("Jump")

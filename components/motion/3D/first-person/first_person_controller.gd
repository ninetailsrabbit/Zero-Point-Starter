class_name FirstPersonController extends CharacterBody3D

@export var mouse_mode_switch_input_actions: Array[String] = ["ui_cancel"]

@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine
@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var camera: Camera3D = $Head/Eyes/Camera3D
@onready var ceil_shape_cast: ShapeCast3D = $Head/CeilShapeCast

var was_grounded: bool = false
var is_grounded: bool = false
var motion_input: TransformedInput

func _unhandled_input(event: InputEvent) -> void:
	if InputHelper.is_any_action_just_pressed(event, mouse_mode_switch_input_actions):
		switch_mouse_capture_mode()


func _ready() -> void:
	motion_input = TransformedInput.new(self)
	InputHelper.capture_mouse()


func _physics_process(delta: float) -> void:
	motion_input.update()
	
	was_grounded = is_grounded
	is_grounded = is_on_floor()
	


func is_falling() -> bool:
	var opposite_up_direction = VectorHelper.up_direction_opposite_vector3(up_direction)
	
	var opposite_to_gravity_vector: bool = (opposite_up_direction.is_equal_approx(Vector3.DOWN) and velocity.y < 0) \
		or (opposite_up_direction.is_equal_approx(Vector3.UP) and velocity.y > 0) \
		or (opposite_up_direction.is_equal_approx(Vector3.LEFT) and velocity.x < 0) \
		or (opposite_up_direction.is_equal_approx(Vector3.RIGHT) and velocity.x > 0)
	
	return not is_grounded and opposite_to_gravity_vector


func switch_mouse_capture_mode() -> void:
	if InputHelper.is_mouse_visible():
		InputHelper.capture_mouse()
	else:
		InputHelper.show_mouse_cursor()

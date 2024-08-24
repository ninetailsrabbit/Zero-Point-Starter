@icon("res://components/motion/3D/first-person/first_person_controller.svg")
class_name FirstPersonController extends CharacterBody3D

@export var mouse_mode_switch_input_actions: Array[String] = ["ui_cancel"]
@export_group("Mechanics")
@export var run: bool = true
@export var jump: bool = true
@export var crouch: bool = true
@export var crawl: bool = false
@export var slide: bool = true
@export var wall_run: bool = false
@export var wall_jump: bool = false
@export var wall_climb: bool = false
@export var surf: bool = false
@export var swim: bool = false
@export var stairs: bool = true

@onready var debug_ui: CanvasLayer = $DebugUI
@onready var finite_state_machine: FiniteStateMachine = $FiniteStateMachine
@onready var head: Node3D = $Head
@onready var eyes: Node3D = $Head/Eyes
@onready var camera: Camera3D = $Head/Eyes/Camera3D
@onready var ceil_shape_cast: ShapeCast3D = $Head/CeilShapeCast
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stand_collision_shape: CollisionShape3D = $StandCollisionShape
@onready var crouch_collision_shape: CollisionShape3D = $CrouchCollisionShape
@onready var crawl_collision_shape: CollisionShape3D = $CrawlCollisionShape

var was_grounded: bool = false
var is_grounded: bool = false
var motion_input: TransformedInput
var last_direction: Vector3 = Vector3.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if InputHelper.is_any_action_just_pressed(event, mouse_mode_switch_input_actions):
		switch_mouse_capture_mode()


func _ready() -> void:
	debug_ui.visible = OS.is_debug_build()
	
	motion_input = TransformedInput.new(self)
	InputHelper.capture_mouse()
	
	finite_state_machine.register_transitions([
		WalkToRunTransition.new(),
		RunToWalkTransition.new()
	])
	
	finite_state_machine.state_changed.connect(on_state_changed)
	

func _physics_process(_delta: float) -> void:
	motion_input.update()
	
	was_grounded = is_grounded
	is_grounded = is_on_floor()
	
	last_direction = current_input_direction()


func current_input_direction() -> Vector3:
	return motion_input.input_direction_horizontal_axis * head.basis.x + motion_input.input_direction_vertical_axis * head.basis.z


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


func _update_collisions_based_on_state(current_state: MachineState) -> void:
	match current_state.name:
		"Idle", "Walk", "Run":
			stand_collision_shape.disabled = false
			crouch_collision_shape.disabled = true
			crawl_collision_shape.disabled = true
		"Crouch", "Slide":
			stand_collision_shape.disabled = true
			crouch_collision_shape.disabled = false
			crawl_collision_shape.disabled = true
		"Crawl":
			stand_collision_shape.disabled = true
			crouch_collision_shape.disabled = true
			crawl_collision_shape.disabled = false
		_:
			stand_collision_shape.disabled = false
			crouch_collision_shape.disabled = true
			crawl_collision_shape.disabled = true


func on_state_changed(_from: MachineState, to: MachineState) -> void:
	_update_collisions_based_on_state(to)

	

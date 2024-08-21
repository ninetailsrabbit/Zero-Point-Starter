@icon("res://components/interaction/3D/interactor_3d.svg")
class_name MouseRayCastInterator3D extends Node3D

@export var origin_camera: Camera3D
@export var ray_length := 1000.0
@export var interact_mouse_button = MOUSE_BUTTON_LEFT
@export var input_action_to_cancel := "cancel_interact"

@onready var current_camera: Camera3D = origin_camera

var current_interactable: Interactable3D
var focused := false
var interacting := false
var mouse_position: Vector2 = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if is_processing() and current_camera is Camera3D and event is InputEventMouseButton:
		mouse_position = (event as InputEventMouseButton).position
		
		if interact_mouse_button == MOUSE_BUTTON_LEFT and InputHelper.is_mouse_left_click(event) \
			or interact_mouse_button == MOUSE_BUTTON_RIGHT and InputHelper.is_mouse_right_click(event):
				interact(current_interactable)
	
	if is_processing() and InputMap.has_action(input_action_to_cancel) and Input.is_action_just_pressed(input_action_to_cancel) and current_interactable is Interactable3D:
		cancel_interact(current_interactable)


func _ready() -> void:
	assert(current_camera is Camera3D, "MouseRayCastInterator3D: this node needs a Camera3D to create the mouse raycast")
	set_process_input(current_camera is Camera3D)
	set_process(current_camera is Camera3D)


func _process(_delta: float) -> void:
	var detected_interactable = get_detected_interactable()
	
	if detected_interactable:
		if current_interactable == null and not focused:
			focus(detected_interactable)
	else:
		if focused and not interacting and current_interactable:
			unfocus(current_interactable)


func get_detected_interactable():
	var world_space := get_world_3d().direct_space_state
	var from := origin_camera.project_ray_origin(mouse_position)
	var to := from + origin_camera.project_ray_normal(mouse_position) * ray_length
	
	var ray_query = PhysicsRayQueryParameters3D.create(
		from, 
		to, 
		GameGlobals.world_collision_layer | GameGlobals.enemies_collision_layer | GameGlobals.interactables_collision_layer
	)
	
	ray_query.collide_with_areas = true
	ray_query.collide_with_bodies = true
	
	var result := world_space.intersect_ray(ray_query)
	
	if InputHelper.is_mouse_visible() and result.has("collider") and result["collider"] is Interactable3D:
		return result.collider as Interactable3D
		
	return null


func interact(interactable: Interactable3D):
	if interactable:
		interacting = true
		
		interactable.interacted.emit(self)
	
	
func cancel_interact(interactable: Interactable3D = current_interactable):
	if interactable:
		interacting = false
		focused = false
		
		interactable.canceled_interaction.emit(self)


func focus(interactable: Interactable3D):
	current_interactable = interactable
	focused = true
	
	interactable.focused.emit(self)
	
	
func unfocus(interactable: Interactable3D = current_interactable):
	if interactable and focused:
		current_interactable = null
		focused = false
		interacting = false

		interactable.unfocused.emit(self)


func change_camera_to(new_camera: Camera3D) -> void:
	current_camera = new_camera


func return_to_original_camera() -> void:
	change_camera_to(origin_camera)


func enable() -> void:
	set_process(true)
	set_process_input(true)
	

func disable() -> void:
	set_process(false)
	set_process_input(false)
	

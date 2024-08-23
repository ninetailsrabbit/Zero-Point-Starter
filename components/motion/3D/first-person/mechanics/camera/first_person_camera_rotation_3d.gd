@icon("res://components/motion/3D/first-person/mechanics/camera/camera_movement.svg")
class_name FirstPersonCameraRotation3D extends Node3D

@export var actor: FirstPersonController
@export var head: Node3D
## Usually this node is the eyes inside the head node
@export var camera_pivot_point: Node3D
## 0 Means the rotation on the Y-axis is not limited
@export_range(0, 360, 1, "degrees") var camera_vertical_limit = 89
## 0 Means the rotation on the X-axis is not limited
@export_range(0, 360, 1, "degrees") var camera_horizontal_limit = 0
#@export var smooth_camera: bool = false
#@export var camera_smooth_factor: float = 2.0

@onready var current_vertical_limit: int:
	get:
		return current_vertical_limit
	set(value):
		current_vertical_limit = clamp(value, 0, 360)
		
@onready var current_horizontal_limit: int:
	get:
		return current_horizontal_limit
	set(value):
		current_horizontal_limit = clamp(value, 0, 360)
		

var mouse_sensitivity: float = 3.0
var locked: bool = false
var yAxis = 0.0
var xAxis = 0.0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and InputHelper.is_mouse_captured():
		var motion: InputEventMouseMotion = event.xformed_by(get_tree().root.get_final_transform())
		rotate_camera(motion)

		
func _ready() -> void:
	current_horizontal_limit = camera_horizontal_limit
	current_vertical_limit = camera_vertical_limit
	mouse_sensitivity = SettingsHandler.get_accessibility_section("mouse_sensitivity")
	
	GlobalGameEvents.mouse_sensitivity_changed.connect(on_mouse_sensitivity_changed)


func rotate_camera(event: InputEventMouseMotion) -> void:
	var mouse_sens = mouse_sensitivity / 1000 # radians/pixel, 3 becomes 0.003
	
	var twistInput = event.relative.x * mouse_sens ## Giro
	var pitchInput = event.relative.y * mouse_sens ## Cabeceo
	
	yAxis += twistInput
	xAxis += pitchInput
#		
	head.rotate_y(-twistInput)
	camera_pivot_point.rotate_x(-pitchInput)
	
	if current_horizontal_limit > 0:
		head.rotation_degrees.y = clamp(head.rotation_degrees.y, -current_horizontal_limit, current_horizontal_limit)
	
	if current_vertical_limit > 0:
		camera_pivot_point.rotation_degrees.x = clamp(camera_pivot_point.rotation_degrees.x, -current_vertical_limit, current_vertical_limit)
	
	head.orthonormalize()
	camera_pivot_point.orthonormalize()


func lock() -> void:
	set_process_input(false)
	locked = true

func unlock() -> void:
	set_process_input(true)
	locked = false


#region Camera rotation
func change_horizontal_rotation_limit(new_rotation: int) -> void:
	current_horizontal_limit = new_rotation
	
func change_vertical_rotation_limit(new_rotation: int) -> void:
	current_vertical_limit = new_rotation
	
func return_to_original_horizontal_rotation_limit() -> void:
	current_horizontal_limit = camera_horizontal_limit
	
func return_to_original_vertical_rotation_limit() -> void:
	current_vertical_limit = camera_vertical_limit
#endregion

func on_mouse_sensitivity_changed(new_value: float) -> void:
	mouse_sensitivity = new_value

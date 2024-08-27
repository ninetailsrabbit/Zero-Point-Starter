class_name ScanViewport3D extends Node3D

@export var blur_on_scan: bool = true

@onready var scan_camera: Camera3D = $Camera3D
@onready var marker_3d: Marker3D = $Marker3D
@onready var mouse_rotator_component_3d: MouseRotatorComponent3D = $MouseRotatorComponent3D


func _ready() -> void:
	if blur_on_scan:
		enable_blur()


func enable_blur() -> void:
	var camera_attributes: CameraAttributesPractical = scan_camera.attributes as CameraAttributesPractical
	
	if camera_attributes == null:
		scan_camera.attributes = CameraAttributesPractical.new()
		
	camera_attributes.dof_blur_far_enabled = true
		
	
func set_current_mouse_cursor(texture: Texture2D):
	CursorManager.change_cursor_to(texture)
	

func change_mouse_cursor(texture: Texture2D):
	mouse_rotator_component_3d.selected_cursor = texture


func change_mouse_rotate_cursor(texture: Texture2D):
	mouse_rotator_component_3d.selected_rotate_cursor = texture

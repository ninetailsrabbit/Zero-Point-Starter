class_name ScanViewport3D extends Node3D

@export var blur_on_scan: bool = true

@onready var scan_camera: Camera3D = $Camera3D
@onready var marker_3d: Marker3D = $Marker3D
@onready var mouse_rotator_component_3d: MouseRotatorComponent3D = $MouseRotatorComponent3D


	
func set_current_mouse_cursor(texture: Texture2D):
	CursorManager.change_cursor_to(texture)
	

func change_mouse_cursor(texture: Texture2D):
	mouse_rotator_component_3d.selected_cursor = texture


func change_mouse_rotate_cursor(texture: Texture2D):
	mouse_rotator_component_3d.selected_rotate_cursor = texture

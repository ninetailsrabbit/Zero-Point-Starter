@icon("res://components/camera/3D/free_look_camera.svg")
class_name FreeLookCamera3D extends Node3D

signal free_camera_enabled
signal free_camera_disabled

@export var camera: Camera3D
@export_range(0.01, 20.0, 0.01) var mouse_sensitivity := 3.0
@export var speed := 0.2:
	set(value):
		speed = clamp(value, min_speed, max_speed)
@export var min_speed := 0.2
@export var max_speed := 5.0
@export var speed_increase_per_step := 0.1
@export var toggle_activation_key := KEY_TAB
@export var move_forward_key := KEY_W
@export var move_back_key := KEY_S
@export var move_left_key := KEY_A
@export var move_right_key := KEY_D
@export var increment_speed_key := MOUSE_BUTTON_WHEEL_UP
@export var decrement_speed_key := MOUSE_BUTTON_WHEEL_DOWN

var previous_camera: Camera3D

var active := false:
	set(value):
		if value != active and is_node_ready():
			if value:
				free_camera_enabled.emit()
			else:
				free_camera_disabled.emit()
		active = value
		
var motion: Vector3
var view_motion: Vector2
var gimbal_base : Transform3D
var gimbal_pitch : Transform3D
var gimbal_yaw : Transform3D


func _ready():
	if camera == null:
		camera = get_parent() as Camera3D
		
	assert(camera is Camera3D, "FreeLookCamera3D: This node needs a camera to apply the free look movement")

	gimbal_base.origin = camera.global_transform.origin
	camera.current = active
	camera.set_as_top_level(true)
	
	free_camera_enabled.connect(on_free_camera_enabled)
	free_camera_disabled.connect(on_free_camera_disabled)


func _input(event):
	if active:
		if event is InputEventMouseMotion:
			view_motion += event.xformed_by(get_tree().root.get_final_transform()).relative
			
		if event is InputEventMouseButton:
			if event.button_index == increment_speed_key:
				speed += speed_increase_per_step
			if event.button_index == decrement_speed_key:
				speed -= speed_increase_per_step
			

	if event is InputEventKey:
			if event.keycode == toggle_activation_key and event.pressed:
				active = not active
				
				if not active:
					return
			
			var motion_value := int(event.pressed) # translate bool into 1 or 0
			
			match event.keycode:
				move_forward_key:
					motion.z = -motion_value
				move_back_key:
					motion.z = motion_value
				move_right_key:
					motion.x = motion_value
				move_left_key:
					motion.x = -motion_value


func _process(_delta):
	gimbal_base *= Transform3D(Basis(), camera.global_transform.basis * (motion * speed))

	gimbal_yaw = gimbal_yaw.rotated(Vector3.UP, view_motion.x * (mouse_sensitivity / 1000) * -1.0)
	gimbal_pitch = gimbal_pitch.rotated(Vector3.RIGHT, view_motion.y * (mouse_sensitivity / 1000) * -1.0)
	view_motion = Vector2()

	camera.global_transform = gimbal_base * (gimbal_yaw * gimbal_pitch)


func is_active() -> bool:
	return active
	
	
func on_free_camera_enabled():
	previous_camera = get_viewport().get_camera_3d()
	camera.make_current()
	set_process(true)
	set_process_input(true)

	
func on_free_camera_disabled():
	gimbal_base.origin = camera.global_transform.origin
	camera.current = false
	previous_camera.make_current()
	set_process(false)
	set_process_input(false)

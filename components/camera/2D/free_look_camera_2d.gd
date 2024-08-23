@icon("res://components/camera/2D/free_look_camera.svg")
class_name FreeLookCamera2D extends Node2D

signal free_camera_enabled
signal free_camera_disabled

@export var camera: Camera2D
@export_range(0.01, 20.0, 0.01) var mouse_sensitivity := 3.0
@export var speed := 50.0:
	set(value):
		speed = clamp(value, min_speed, max_speed)
@export var min_speed := 50.0
@export var max_speed := 100.0
@export var speed_increase_per_step := 10.0
@export var zoom := Vector2.ONE:
	set(value):
		zoom = clamp(value, min_zoom, max_zoom)
		
@export var min_zoom := Vector2.ONE * 0.01
@export var max_zoom := Vector2.ONE * 2
@export var zoom_increase_step := 0.05
@export var toggle_activation_key := KEY_TAB
@export var move_up_key := KEY_W
@export var move_down_key := KEY_S
@export var move_left_key := KEY_A
@export var move_right_key := KEY_D
@export var boost_speed_key := KEY_SHIFT
@export var increment_zoom_key := MOUSE_BUTTON_WHEEL_UP
@export var decrement_zoom_key := MOUSE_BUTTON_WHEEL_DOWN

var previous_camera: Camera2D
var direction := Vector2.ZERO
var current_speed := speed
var active := false:
	set(value):
		if value != active and is_node_ready():
			if value:
				free_camera_enabled.emit()
			else:
				free_camera_disabled.emit()
		active = value


func _input(event):
	if active:
		if event is InputEventMouseButton:
			if event.button_index == increment_zoom_key:
				camera.zoom += Vector2.ONE * zoom_increase_step
			if event.button_index == decrement_zoom_key:
				camera.zoom -= Vector2.ONE * zoom_increase_step
				
				
			
	
	if event is InputEventKey:
			if event.keycode == toggle_activation_key and event.pressed:
				active = not active
				
				if not active:
					return
			
			if event.keycode == boost_speed_key and event.is_pressed():
				speed += speed_increase_per_step
			
			match event.keycode:
				move_up_key:
					direction = Vector2.DOWN
				move_down_key:
					direction = Vector2.UP
				move_right_key:
					direction = Vector2.RIGHT
				move_left_key:
					direction = Vector2.LEFT
				_:
					direction = Vector2.ZERO
					
			camera.global_position += speed * direction
	else:
		speed -= speed_increase_per_step
		direction = Vector2.ZERO


func _ready():
	if camera == null:
		camera = get_parent() as Camera2D
		
	assert(camera is Camera2D, "FreeLookCamera2D: This node needs a camera to apply the free look movement")

	camera.set_as_top_level(true)
	camera.zoom = zoom
	
	free_camera_enabled.connect(on_free_camera_enabled)
	free_camera_disabled.connect(on_free_camera_disabled)


func _process(_delta):
	if active and camera.is_current():
		camera.global_position += speed * direction


func is_active() -> bool:
	return active
	
	
func on_free_camera_enabled():
	previous_camera = get_viewport().get_camera_2d()
	camera.make_current()
	set_process(true)
	set_process_input(true)

	
func on_free_camera_disabled():
	previous_camera.make_current()
	set_process(false)
	set_process_input(false)

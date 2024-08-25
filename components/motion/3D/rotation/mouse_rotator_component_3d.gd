@icon("res://components/motion/3D/rotation/3d_rotation_component.svg")
class_name MouseRotatorComponent3D extends Node

@export_range(0.01, 20.0, 0.01) var mouse_sensitivity := 6.0
@export var target: Node3D
@export var mouse_rotation_button = MOUSE_BUTTON_LEFT
@export var keep_pressed_to_rotate: bool = true
@export var reset_rotation_on_release := false
@export var default_cursor: CompressedTexture2D = Preloader.cursor_hand_thin_open
@export var default_rotate_cursor: CompressedTexture2D = Preloader.cursor_hand_thin_closed

var reset_rotation_tween: Tween
var selected_cursor: Texture2D
var selected_rotate_cursor: Texture2D

var original_rotation := Vector3.ZERO

func _input(event: InputEvent) -> void:
	if target:
		if event is InputEventMouseMotion and mouse_movement_detected(event):
			CursorManager.change_cursor_to(selected_rotate_cursor)
			var motion: InputEventMouseMotion = event.xformed_by(get_tree().root.get_final_transform())
			var mouse_sens: float = mouse_sensitivity / 1000.0
			
			target.rotate_x(motion.y * mouse_sens)
			target.rotate_y(motion.x * mouse_sens)
		
		if mouse_release_detected(event):
			CursorManager.change_cursor_to(selected_cursor)
			reset_target_rotation()
			

func mouse_movement_detected(event: InputEvent) -> bool:
	if not keep_pressed_to_rotate:
		return true
		
	return (mouse_rotation_button == MOUSE_BUTTON_LEFT and InputHelper.is_mouse_left_button_pressed(event)) \
			or (mouse_rotation_button == MOUSE_BUTTON_RIGHT and InputHelper.is_mouse_right_button_pressed(event))
			
			
func mouse_release_detected(event: InputEvent) -> bool:
	return (mouse_rotation_button == MOUSE_BUTTON_LEFT and not InputHelper.is_mouse_left_button_pressed(event)) \
			or (mouse_rotation_button == MOUSE_BUTTON_RIGHT and not InputHelper.is_mouse_right_button_pressed(event))
			
			
func reset_target_rotation() -> void:
	if target:
		if reset_rotation_on_release and not target.rotation.is_equal_approx(original_rotation) \
			and (reset_rotation_tween == null or (reset_rotation_tween and not reset_rotation_tween.is_running())):
				reset_rotation_tween = create_tween()
				reset_rotation_tween.tween_property(target, "rotation", original_rotation, 0.5).from(target.rotation)\
					.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

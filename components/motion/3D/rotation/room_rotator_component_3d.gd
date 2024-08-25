@icon("res://components/motion/3D/rotation/3d_rotation_component.svg")
class_name RoomRotatorComponent extends Node

@export var room: Node3D
@export var rotation_time := 0.45
@export var rotation_effect := RotationEffects.Smoothly
@export var input_action_rotate_left := "rotate_left"
@export var input_action_rotate_right := "rotate_right"

enum RotationEffects {
	Smoothly, ## Gradual rotation animation with easing for a natural feel.,
	Compressed ##  Faster rotation animation with linear transition for a more abrupt effect
}

var tween_movement: Tween

func _ready():
	if room == null:
		room = get_parent() as Node3D
		
	assert(room is Node3D, "RoomRotatorComponent3D: This component needs a Node3D room to apply the rotation.")
	
	
func _unhandled_input(_event: InputEvent):
	if InputHelper.action_just_pressed_and_exists(input_action_rotate_left):
		rotate_target(Vector2.LEFT)
		
	if InputHelper.action_just_pressed_and_exists(input_action_rotate_right):
		rotate_target(Vector2.RIGHT)


func rotate_target(direction: Vector2):
	match rotation_effect:
		RotationEffects.Smoothly:
			rotate_with_smoothly_effect(direction)
		RotationEffects.Compressed:
			rotate_with_compression_effect(direction)
		_:
			rotate_with_smoothly_effect(direction)
			
			
func rotate_with_compression_effect(direction: Vector2):
	if can_rotate(direction):
		tween_movement = create_tween()
		tween_movement.tween_property(room, "transform:basis", room.transform.basis.rotated(Vector3.UP, -sign(direction.x) * PI / 2), rotation_time)\
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
			
	
func rotate_with_smoothly_effect(direction: Vector2):
	if can_rotate(direction):
		tween_movement = create_tween()
		tween_movement.tween_property(room, "rotation_degrees:y", room.rotation_degrees.y + (-sign(direction.x) * rad_to_deg(PI / 2)), rotation_time)\
			.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
			
			
func can_rotate(direction: Vector2):
	return room and direction in [Vector2.LEFT, Vector2.RIGHT] and (tween_movement == null or tween_movement and !tween_movement.is_running())

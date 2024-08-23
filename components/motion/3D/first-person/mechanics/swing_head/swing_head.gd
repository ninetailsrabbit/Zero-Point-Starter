class_name SwingHead extends Node3D

@export var actor: FirstPersonController
@export var head: Node3D
@export_range(0, 360.0, 0.01) var swing_rotation_degrees = 1.5
@export var swing_lerp_factor = 5.0
@export var swing_lerp_recovery_factor = 7.5

var original_head_rotation = Vector3.ZERO


func _ready() -> void:
	original_head_rotation = head.rotation
	
	
func _physics_process(delta: float) -> void:
	if actor.is_grounded:
		var direction = actor.motion_input.input_direction
		
		if direction in [Vector2.RIGHT, Vector2.LEFT]:
			head.rotation.z = lerp_angle(head.rotation.z, -sign(direction.x) * deg_to_rad(swing_rotation_degrees), swing_lerp_factor * delta)
		else:
			head.rotation.z = lerp_angle(head.rotation.z, original_head_rotation.z, swing_lerp_recovery_factor * delta)

			

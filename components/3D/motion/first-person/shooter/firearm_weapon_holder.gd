class_name WeaponHolder extends Node3D

@export var first_person_controller: FirstPersonController
@export var camera_movement: FirstPersonCameraRotation3D
@export_group("Rotation")
@export var weapon_sway_amount: float = 0.25
@export var weapon_rotation_amount: float = 5.0
@export var invert_weapon_sway : bool = true
@export_group("Bob")
@export var enable_bob: bool = true
@export var bob_amount: float = 0.02
@export var bob_freq : float = 0.01
@export var bob_lerp_speed: float = 12.0

var original_position: Vector3

func _ready() -> void:
	original_position = position
	

func _physics_process(delta: float) -> void:
	# Weapon sway
	rotation.x = lerp_angle(rotation.x, camera_movement.last_mouse_input.y * deg_to_rad(weapon_sway_amount) * (-1 if invert_weapon_sway else 1), 10 * delta)
	rotation.y = lerp_angle(rotation.y, camera_movement.last_mouse_input.x * deg_to_rad(weapon_sway_amount) * (-1 if invert_weapon_sway else 1), 10 * delta)
	# Weapon tilt 
	rotation.z = lerp_angle(rotation.z, -first_person_controller.motion_input.input_direction.x * deg_to_rad(weapon_rotation_amount),  10 * delta)
	
	apply_bob(delta)

	
func apply_bob(delta: float) -> void:
	if enable_bob:
		if not first_person_controller.velocity.length() <= 0.1 and first_person_controller.is_grounded:
			position.y = lerp(position.y, original_position.y + sin(Time.get_ticks_msec() * bob_freq) * bob_amount, bob_lerp_speed * delta)
			position.x = lerp(position.x, original_position.x + sin(Time.get_ticks_msec() * bob_freq * 0.5) * bob_amount, bob_lerp_speed * delta)
		else:
			position.y = lerp(position.y, original_position.y, bob_lerp_speed * delta)
			position.x = lerp(position.x, original_position.x, bob_lerp_speed * delta)

class_name WeaponHolder extends Node3D

signal changed_weapon(from: FireArmWeapon, to: FireArmWeapon)

@export var first_person_controller: FirstPersonController
@export var camera_movement: FirstPersonCameraRotation3D
## The node that contains the Camera3D so when the recoil it's applied, the screen center changes and
## the recoil effect can be achieved
@export var recoil_node: Node3D
@export var current_weapon: FireArmWeapon:
	set(value):
		if current_weapon != value:
			
			if current_weapon and value:
				changed_weapon.emit(current_weapon, value)
			
			if value == null and current_weapon:
				if current_weapon.fired.is_connected(on_fired_weapon):
					current_weapon.fired.disconnect(on_fired_weapon)
				
			current_weapon = value
			
			if current_weapon:
				current_weapon_configuration = current_weapon.weapon_configuration
				if not current_weapon.fired.is_connected(on_fired_weapon):
					current_weapon.fired.connect(on_fired_weapon)
			
			set_physics_process(current_weapon is FireArmWeapon)
				
var original_position: Vector3
var recoil_target_rotation: Vector3
var current_recoil_target_rotation: Vector3
var current_weapon_configuration: WeaponConfiguration


func _ready() -> void:
	original_position = position
	
	if current_weapon:
		current_weapon_configuration = current_weapon.weapon_configuration
		
		if not current_weapon.fired.is_connected(on_fired_weapon):
			current_weapon.fired.connect(on_fired_weapon)

	set_physics_process(current_weapon is FireArmWeapon)
	

func _physics_process(delta: float) -> void:
	if current_weapon:
		# Weapon sway
		rotation.x = lerp_angle(rotation.x, camera_movement.last_mouse_input.y * deg_to_rad(current_weapon_configuration.weapon_sway_amount) * (-1 if current_weapon_configuration.invert_weapon_sway else 1), 10 * delta)
		rotation.y = lerp_angle(rotation.y, camera_movement.last_mouse_input.x * deg_to_rad(current_weapon_configuration.weapon_sway_amount) * (-1 if current_weapon_configuration.invert_weapon_sway else 1), 10 * delta)
		# Weapon tilt 
		rotation.z = lerp_angle(rotation.z, -first_person_controller.motion_input.input_direction.x * deg_to_rad(current_weapon_configuration.weapon_rotation_amount),  10 * delta)
		
		apply_bob(delta)
		apply_recoil(delta)


func apply_bob(delta: float) -> void:
	if current_weapon:
		
		if current_weapon_configuration.enable_bob:
			if not first_person_controller.velocity.length() <= 0.1 and first_person_controller.is_grounded:
				position.y = lerp(position.y, original_position.y + sin(Time.get_ticks_msec() * current_weapon_configuration.bob_freq) * current_weapon_configuration.bob_amount, current_weapon_configuration.bob_lerp_speed * delta)
				position.x = lerp(position.x, original_position.x + sin(Time.get_ticks_msec() * current_weapon_configuration.bob_freq * 0.5) * current_weapon_configuration.bob_amount, current_weapon_configuration.bob_lerp_speed * delta)
			else:
				position.y = lerp(position.y, original_position.y, current_weapon_configuration.bob_lerp_speed * delta)
				position.x = lerp(position.x, original_position.x, current_weapon_configuration.bob_lerp_speed * delta)


func apply_recoil(delta: float) -> void:
	if _recoil_can_be_applied():
		recoil_target_rotation = lerp(recoil_target_rotation, Vector3.ZERO, current_weapon_configuration.recoil_lerp_speed * delta)
		current_recoil_target_rotation = lerp(current_recoil_target_rotation, recoil_target_rotation, current_weapon_configuration.recoil_snap_amount * delta)
		recoil_node.basis = Quaternion.from_euler(current_recoil_target_rotation)


func add_recoil() -> void:
	if _recoil_can_be_applied():
		var recoil_amount: Vector3 = current_weapon_configuration.recoil_amount
		
		recoil_target_rotation += Vector3(
			recoil_amount.x, 
			randf_range(-recoil_amount.y, recoil_amount.y),
			randf_range(-recoil_amount.z, recoil_amount.z),
		)


func _recoil_can_be_applied() -> bool:
	return current_weapon and current_weapon.weapon_configuration.recoil_enabled and recoil_node


func on_fired_weapon() -> void:
	add_recoil()

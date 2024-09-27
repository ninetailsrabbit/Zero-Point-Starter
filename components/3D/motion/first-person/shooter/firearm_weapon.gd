@icon("res://assets/node_icons/weapon.svg")
class_name FireArmWeapon extends Node3D

signal fired
signal reloaded


@export var camera: CameraShake3D
@export_group("Weapon")
@export var weapon_resource: WeaponResource
@export_group("Muzzle")
@export var muzzle_marker: Marker3D
@export var muzzle_scene: PackedScene = preload("res://components/3D/motion/first-person/shooter/muzzle/muzzle_flash.tscn")
@export var muzzle_lifetime: float = 0.03
@export var muzzle_min_size: Vector2 = Vector2(0.05, 0.05)
@export var muzzle_max_size: Vector2 = Vector2(0.35, 0.35)
@export var muzzle_emit_on_ready: bool = true

var original_weapon_position: Vector3
var original_weapon_rotation: Vector3
var recoil_target_rotation: Vector3
var recoil_target_position: Vector3
var current_recoil_time: float = 1.0

var active: bool = true:
	set(value):
		if value != active:
			active = value
			
			set_physics_process(active)

var current_ammunition: int = 0


func _ready() -> void:
	original_weapon_position = position
	original_weapon_rotation = rotation
	recoil_target_rotation.y = rotation.y
	
	current_recoil_time = 1.0
	current_ammunition = weapon_resource.initial_ammunition
	

func _physics_process(delta: float) -> void:
	if InputMap.has_action("aim") and Input.is_action_pressed("aim"): ## TODO SUPER TEMPORARY, FIND A BETTER WAY TO CONFIGURE AIMING FOR EACH WEAPON
		position = position.slerp(Vector3(-get_parent().position.x, 0.1, position.z), 10 * delta)
	else:
		position = position.slerp(Vector3.ZERO, 10 * delta)
	
	## TODO - MANAGE THE SHOOT INPUT BASED ON WEAPON BURST TYPE
	if InputMap.has_action("shoot") and Input.is_action_pressed("shoot"):
		shoot()
		
	if current_recoil_time < 1:
		current_recoil_time += delta * weapon_resource.recoil_speed
		
		position.z = lerp(position.z, original_weapon_position.z + recoil_target_position.z, weapon_resource.recoil_lerp_speed * delta)
		rotation.z = lerp_angle(rotation.z, original_weapon_rotation.z + recoil_target_rotation.z, weapon_resource.recoil_lerp_speed * delta)
		rotation.x = lerp_angle(rotation.x, original_weapon_rotation.x + recoil_target_rotation.x, weapon_resource.recoil_lerp_speed * delta)
		
		recoil_target_rotation.z = weapon_resource.recoil_rotation_z.sample(current_recoil_time) * weapon_resource.recoil_amplitude.y
		recoil_target_rotation.x = weapon_resource.recoil_rotation_x.sample(current_recoil_time) * -weapon_resource.recoil_amplitude.x
		recoil_target_position.z = weapon_resource.recoil_position_z.sample(current_recoil_time) * weapon_resource.recoil_amplitude.z
		
		if InputMap.has_action("aim") and not Input.is_action_pressed("aim"): ## TODO SUPER TEMPORARY
			position = position.slerp(original_weapon_position, 10 * delta)
			rotation = rotation.slerp(original_weapon_rotation, 10 * delta)


## TODO - WORK IN PROGRESS TO ATTACH MORE COMPLEX BEHAVIORS
func shoot() -> void:
	if active and current_ammunition > 0:
		if camera:
			camera.trauma(weapon_resource.camera_shake_time, weapon_resource.camera_shake_magnitude)
		
		apply_recoil()
		muzzle_effect()
		fired.emit()


func hitscan() -> Dictionary:
	if camera:
		var screen_center: Vector2i = WindowManager.screen_center()
		var origin = camera.project_ray_origin(screen_center)
		var to: Vector3 = origin + camera.project_ray_normal(screen_center) * weapon_resource.fire_range
		
		var hitscan_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			origin, 
			to, 
			GameGlobals.world_collision_layer | GameGlobals.enemies_collision_layer | GameGlobals.interactables_collision_layer | GameGlobals.grabbables_collision_layer
		)
		
		hitscan_ray_query.collide_with_areas = false ## TODO - MAYBE WE NEED TO HIT AREAS IN THE FUTURE ALSO
		hitscan_ray_query.collide_with_bodies = true
		
		return get_world_3d().direct_space_state.intersect_ray(hitscan_ray_query)
		
	return {}
	
	
func apply_recoil():
	if weapon_resource and weapon_resource.recoil_enabled:
		weapon_resource.recoil_amplitude.y *= -1 if MathHelper.chance(0.5) else 1
		recoil_target_rotation.z = weapon_resource.recoil_rotation_z.sample(0) * weapon_resource.recoil_amplitude.y
		recoil_target_rotation.x = weapon_resource.recoil_rotation_x.sample(0) * -weapon_resource.recoil_amplitude.x
		recoil_target_position.z = weapon_resource.recoil_position_z.sample(0) * weapon_resource.recoil_amplitude.z
		
		current_recoil_time = 0
		

func muzzle_effect() -> void:
	if muzzle_scene:
		var muzzle = muzzle_scene.instantiate() as MuzzleFlash
		muzzle.particle_lifetime =  muzzle_lifetime
		muzzle.min_size =  muzzle_min_size
		muzzle.max_size =  muzzle_max_size
		muzzle.emit_on_ready = muzzle_emit_on_ready
		muzzle_marker.add_child(muzzle)

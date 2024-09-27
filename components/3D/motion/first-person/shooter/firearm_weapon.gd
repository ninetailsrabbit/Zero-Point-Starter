@icon("res://assets/node_icons/weapon.svg")
class_name FireArmWeapon extends Node3D

signal fired
signal reloaded


@export var camera: CameraShake3D
@export_group("Weapon")
@export var weapon_configuration: WeaponConfiguration
@export_group("Muzzle")
@export var muzzle_marker: Marker3D
@export var muzzle_scene: PackedScene = preload("res://components/3D/motion/first-person/shooter/muzzle/muzzle_flash.tscn")
@export var muzzle_lifetime: float = 0.03
@export var muzzle_min_size: Vector2 = Vector2(0.05, 0.05)
@export var muzzle_max_size: Vector2 = Vector2(0.35, 0.35)
@export var muzzle_emit_on_ready: bool = true

var original_weapon_position: Vector3
var original_weapon_rotation: Vector3

var active: bool = true:
	set(value):
		if value != active:
			active = value
			
			set_physics_process(active)

var current_ammunition: int = 0


func _ready() -> void:
	original_weapon_position = position
	original_weapon_rotation = rotation

	current_ammunition = weapon_configuration.initial_ammunition
	

func _physics_process(delta: float) -> void:
	if InputMap.has_action("aim") and Input.is_action_pressed("aim"): ## TODO SUPER TEMPORARY, FIND A BETTER WAY TO CONFIGURE AIMING FOR EACH WEAPON
		position = position.slerp(Vector3(-get_parent().position.x, 0.1, position.z), 10 * delta)
	else:
		position = position.slerp(Vector3.ZERO, 10 * delta)
	
	## TODO - MANAGE THE SHOOT INPUT BASED ON WEAPON BURST TYPE
	if InputMap.has_action("shoot") and Input.is_action_pressed("shoot"):
		shoot()
		

## TODO - WORK IN PROGRESS TO ATTACH MORE COMPLEX BEHAVIORS
func shoot() -> void:
	if active and current_ammunition > 0:
		if camera:
			camera.trauma(weapon_configuration.camera_shake_time, weapon_configuration.camera_shake_magnitude)
		
		muzzle_effect()
		fired.emit()


func hitscan() -> Dictionary:
	if camera:
		var screen_center: Vector2i = WindowManager.screen_center()
		var origin = camera.project_ray_origin(screen_center)
		var to: Vector3 = origin + camera.project_ray_normal(screen_center) * weapon_configuration.fire_range
		
		var hitscan_ray_query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
			origin, 
			to, 
			GameGlobals.world_collision_layer | GameGlobals.enemies_collision_layer | GameGlobals.interactables_collision_layer | GameGlobals.grabbables_collision_layer
		)
		
		## TODO - MAYBE WE NEED TO HIT AREAS IN THE FUTURE ALSO
		hitscan_ray_query.collide_with_areas = false 
		hitscan_ray_query.collide_with_bodies = true
		
		return get_world_3d().direct_space_state.intersect_ray(hitscan_ray_query)
		
	return {}
	

func muzzle_effect() -> void:
	if muzzle_scene:
		var muzzle = muzzle_scene.instantiate() as MuzzleFlash
		muzzle.particle_lifetime =  muzzle_lifetime
		muzzle.min_size =  muzzle_min_size
		muzzle.max_size =  muzzle_max_size
		muzzle.emit_on_ready = muzzle_emit_on_ready
		muzzle_marker.add_child(muzzle)

## ******  HOW TO ADD NEW WEAPONS  ******
## Create a scene with this node, add a Node3D as a child to apply the Recoil
## Add the weapon scene (the one that contain the model meshes) as a child of Recoil node
## Assign them to the exported variables
## Create a Marker3D to spawn muzzle in this weapon when shoot
## Create a Marker3D to spawn bullets in this weapon when shoot
@icon("res://assets/node_icons/weapon.svg")
class_name FireArmWeapon extends Node3D

signal stored
signal equipped
signal fired(target_hitscan: Dictionary)
signal reloaded
signal out_of_ammo

@export var camera: CameraShake3D
@export var recoil_node: Node3D
@export var current_weapon: FirearmWeaponMesh
@export var weapon_configuration: WeaponConfiguration
@export_group("Clipping")
@export var apply_viewmodel_fov: bool = true
@export var viewmodel_fov: float = 75.0
@export_group("Muzzle")
@export var muzzle_scene: PackedScene = Preloader.MuzzleFlashScene
@export var muzzle_lifetime: float = 0.03
@export var muzzle_min_size: Vector2 = Vector2(0.05, 0.05)
@export var muzzle_max_size: Vector2 = Vector2(0.35, 0.35)
@export var muzzle_emit_on_ready: bool = true
@export_group("Bullets")
@export var bullet_decal_scene: PackedScene = Preloader.BulletDecalScene
@export var bullet_trail_scene: PackedScene = Preloader.BulletTrailScene


var original_weapon_position: Vector3
var original_weapon_rotation: Vector3


var active: bool = true:
	set(value):
		if value != active:
			active = value
			
			set_physics_process(active)

var current_ammunition: int = 0
var hitscan_result: Dictionary = {}


func _ready() -> void:
	if current_weapon and apply_viewmodel_fov:
		setup_viewmodel_fov(viewmodel_fov)
		
	original_weapon_position = current_weapon.position
	original_weapon_rotation = current_weapon.rotation

	current_ammunition = weapon_configuration.initial_ammunition
	
	set_physics_process(active)
	

func _physics_process(delta: float) -> void:
	hitscan_result = hitscan()
	
	if InputMap.has_action("aim") and Input.is_action_pressed("aim"): ## TODO SUPER TEMPORARY, FIND A BETTER WAY TO CONFIGURE AIMING FOR EACH WEAPON
		position = position.lerp(Vector3(-get_parent().position.x, 0.1, position.z), 10 * delta)
	else:
		position = position.lerp(original_weapon_position, 10 * delta)
	
	match weapon_configuration.burst_type:
		weapon_configuration.BurstTypes.Single:
			if InputHelper.action_just_pressed_and_exists("shoot"):
				await shoot(hitscan_result)
		weapon_configuration.BurstTypes.BurstFire:
			if InputHelper.action_just_pressed_and_exists("shoot"):
				for i in range(weapon_configuration.number_of_shoots):
					await shoot(hitscan_result)
		weapon_configuration.BurstTypes.ThreeRoundBurst:
			if InputHelper.action_just_pressed_and_exists("shoot"):
				for i in range(3):
					await shoot(hitscan_result)
					
		weapon_configuration.BurstTypes.FiveRoundBurst:
			if InputHelper.action_just_pressed_and_exists("shoot"):
				for i in range(5):
					await shoot(hitscan_result)
		[weapon_configuration.BurstTypes.Automatic,
			weapon_configuration.BurstTypes.SemiAutomatic]:
			if InputHelper.action_pressed_and_exists("shoot"):
				await shoot(hitscan_result)
		

## TODO - WORK IN PROGRESS TO ATTACH MORE COMPLEX BEHAVIORS
func shoot(target_hitscan: Dictionary = hitscan_result) -> void:
	if active and current_ammunition > 0:
		
		if camera and weapon_configuration.camera_shake_enabled:
			camera.trauma(weapon_configuration.camera_shake_time, weapon_configuration.camera_shake_magnitude)
		
		muzzle_effect()
		bullet_decal(hitscan_result)
		bullet_trail()
		
		fired.emit(target_hitscan)
		await get_tree().create_timer(weapon_configuration.time_between_shoots).timeout
		

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
	if muzzle_scene and current_weapon.muzzle_marker:
		var muzzle = muzzle_scene.instantiate() as MuzzleFlash
		muzzle.particle_lifetime =  muzzle_lifetime
		muzzle.min_size =  muzzle_min_size
		muzzle.max_size =  muzzle_max_size
		muzzle.emit_on_ready = muzzle_emit_on_ready
		current_weapon.muzzle_marker.add_child(muzzle)
		

func bullet_decal(target_hitscan: Dictionary) -> void:
	if not target_hitscan.is_empty() and bullet_decal_scene:
		var bullet_hit_decal = bullet_decal_scene.instantiate() as SmartDecal
		var normal: Vector3 = target_hitscan.get("normal") as Vector3
		var collision_point: Vector3  = target_hitscan.get("position") as Vector3
		get_tree().root.add_child(bullet_hit_decal)
		bullet_hit_decal.global_position = collision_point
		bullet_hit_decal.adjust_to_normal(normal)
		
		
func bullet_trail() -> void:
	if bullet_trail_scene:
		var bullet_trail: BulletTrail = bullet_trail_scene.instantiate() as BulletTrail
		current_weapon.barrel_marker.add_child(bullet_trail)
	

func setup_viewmodel_fov(fov_value: float = viewmodel_fov) -> void:
	if current_weapon:
		for mesh_instance: MeshInstance3D in NodeTraversal.find_nodes_of_type(current_weapon, MeshInstance3D.new()):
			for surface in range(mesh_instance.mesh.get_surface_count()):
				var material = mesh_instance.get_active_material(surface)
				if material is ShaderMaterial:
					material.set_shader_parameter("viewmodel_fov", fov_value)

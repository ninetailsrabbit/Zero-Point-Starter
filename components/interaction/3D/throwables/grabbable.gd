class_name Grabbable3D extends RigidBody3D

const MaximumTransparency: int = 255
const GroupName: String = "grabbable"

enum GrabState {
	Neutral,
	Pull,
	Throw
}

signal pulled(grabber: Node3D)
signal throwed
signal dropped
signal focused
signal unfocused

@export var mesh_instance: MeshInstance3D
@export_group("Force")
## The initial pull power to attract and manipulate throwables
@export var pull_power := 7.5
## The initial throw power to apply force impulses to throwables
@export var throw_power := 10.0
## Rotation force to apply
@export var angular_power = 0.0
@export_group("Transparency")
@export var transparency_on_pull: bool = false
@export_range(0, 255, 1) var transparency_value_on_pull: int = MaximumTransparency
@export_group("Outline")
@export var outline_on_focus: bool = true
@export var outline_color: Color = Color.WHITE
@export var outline_width: float = 2.0
@export var outline_shader: Shader = preload("res://shaders/color/pixel_perfect_outline.gdshader")

var original_collision_layer :=  GameGlobals.throwables_collision_layer
var original_collision_mask := GameGlobals.world_collision_layer | GameGlobals.player_collision_layer | GameGlobals.enemies_collision_layer | GameGlobals.throwables_collision_layer
var original_gravity_scale: float  = gravity_scale
var original_transparency: int = MaximumTransparency
var outline_material: ShaderMaterial

var current_state: GrabState = GrabState.Neutral
var current_grabber: Node3D
var current_linear_velocity: Vector3 = Vector3.ZERO
var current_angular_velocity: Vector3 = Vector3.ZERO


func _enter_tree() -> void:
	focused.connect(on_focused)
	unfocused.connect(on_unfocused)
	
	collision_layer = original_collision_layer
	collision_mask = original_collision_mask
	
	add_to_group(GroupName)


func _ready() -> void:
	if mesh_instance == null:
		mesh_instance = NodeTraversal.first_node_of_type(self, MeshInstance3D.new())


func _integrate_forces(state: PhysicsDirectBodyState3D):
	if state_is_pull():
		state.linear_velocity = current_linear_velocity
		state.angular_velocity = current_angular_velocity
	
	elif state_is_throw() and state.linear_velocity.is_zero_approx():
		current_state = GrabState.Neutral
	
	
func pull(grabber: Node3D) -> void:
	if not state_is_pull() and current_grabber == null:
		current_state = GrabState.Pull
		current_grabber = grabber
		gravity_scale = 0.0
		sleeping = false
		
		if transparency_on_pull:
			_apply_transparency()

		pulled.emit(grabber)


func throw() -> void:
	if state_is_pull():
		gravity_scale = original_gravity_scale
	
		var impulse: Vector3 = Camera3DHelper.forward_direction(get_viewport().get_camera_3d()) * throw_power
		apply_impulse(impulse)
		
		current_state = GrabState.Throw
		current_grabber = null
		
		if transparency_on_pull:
			_recover_transparency()
			
		throwed.emit()


func drop() -> void:
	if state_is_pull():
		gravity_scale = original_gravity_scale
		
		var impulse: Vector3 = Camera3DHelper.forward_direction(get_viewport().get_camera_3d()) * Vector3.ZERO
		apply_impulse(impulse)
		
		current_state = GrabState.Neutral
		current_grabber = null
		
		if transparency_on_pull:
			_recover_transparency()
			
		dropped.emit()

	
func update_linear_velocity() -> void:
	if current_grabber:
		current_linear_velocity = (current_grabber.global_position - global_position) * pull_power


func update_angular_velocity() -> void:
	if current_grabber:
		var q1: Quaternion = global_basis.get_rotation_quaternion()
		var q2: Quaternion = current_grabber.global_basis.get_rotation_quaternion()

		# Quaternion that transforms q1 into q2
		var qt = q2 * q1.inverse()

		# Angle from quaternion
		var angle = 2 * acos(qt.w)

		# There are two distinct quaternions for any orientation.
		# Ensure we use the representation with the smallest angle.
		if angle > PI:
			qt = -qt
			angle = TAU - angle

		# Prevent divide by zero
		if angle < MathHelper.CommonEpsilon:
			current_angular_velocity = Vector3.ZERO
		else:
			# Axis from quaternion
			current_angular_velocity = (Vector3(qt.x, qt.y, qt.z) / sqrt(1 -qt.w * qt.w)) * angular_power


func state_is_throw() -> bool:
	return current_state == GrabState.Throw


func state_is_neutral() -> bool:
	return current_state == GrabState.Neutral


func state_is_pull() -> bool:
	return current_state == GrabState.Pull


func _apply_transparency():
	if transparency_value_on_pull == MaximumTransparency:
		return
		
	var material: StandardMaterial3D = mesh_instance.get_active_material(0)
	
	if material:
		original_transparency = material.albedo_color.a8
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.albedo_color.a8 = transparency_value_on_pull


func _recover_transparency():
	if transparency_value_on_pull == 255:
		return
		
	var material: StandardMaterial3D = mesh_instance.get_active_material(0)
	
	if material:
		material.albedo_color.a8  = original_transparency

	
func _apply_outline_shader() -> void:
	if outline_on_focus:
		var material: StandardMaterial3D = mesh_instance.get_active_material(0)
		
		if material and not material.next_pass:
			print("applying material")
			if not outline_material:
				outline_material = ShaderMaterial.new()
				outline_material.shader = outline_shader
				
			outline_material.set_shader_parameter("outline_color", outline_color)
			outline_material.set_shader_parameter("outline_width", outline_width)
			material.next_pass = outline_material

	
func _remove_outline_shader() -> void:
	if outline_on_focus:
		var material: StandardMaterial3D = mesh_instance.get_active_material(0)
		
		if material:
			material.next_pass = null
			

#region Signal callbacks
func on_focused() -> void:
	_apply_outline_shader()
	GlobalGameEvents.grabbable_focused.emit(self)


func on_unfocused() -> void:
	_remove_outline_shader()
	GlobalGameEvents.grabbable_unfocused.emit(self)

#endregion

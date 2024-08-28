class_name RoomMesh extends MeshInstance3D


var room_mesh_shape: ArrayMesh

#region Materials
var floor_material: Material
var ceil_material: Material
var front_wall_material: Material
var back_wall_material: Material
var right_wall_material: Material
var left_wall_material: Material
#endregion

#region Door slot materials
var front_wall_door_slot_material: Material
var back_wall_door_slot_material: Material
var right_wall_door_slot_material: Material
var left_wall_door_slot_material: Material
#endregion


func _ready() -> void:
	update_room_materials()


func update_room_materials() -> void:
	room_mesh_shape = mesh as ArrayMesh
	
	if room_mesh_shape:
		floor_material = get_surface_material("Floor")
		ceil_material = get_surface_material("Ceil")
		front_wall_material = get_surface_material("FrontWall")
		back_wall_material = get_surface_material("BackWall")
		left_wall_material = get_surface_material("RightWall")
		right_wall_material = get_surface_material("LeftWall")
		
		front_wall_door_slot_material = get_surface_material("FrontWallDoorSlot")
		back_wall_door_slot_material = get_surface_material("BackWallDoorSlot")
		left_wall_door_slot_material = get_surface_material("RightWallDoorSlot")
		right_wall_door_slot_material = get_surface_material("LeftWallDoorSlot")

#region Change materials
func change_material_on_floor(new_material: Material) -> RoomMesh:
	floor_material = new_material
	
	return self


func change_material_on_ceil(new_material: Material) -> RoomMesh:
	ceil_material = new_material
	
	return self


func change_material_on_walls(new_material: Material) -> RoomMesh:
	if front_wall_material:
		front_wall_material = new_material
		
	if back_wall_material:
		back_wall_material = new_material
		
	if right_wall_material:
		right_wall_material = new_material
		
	if left_wall_material:
		left_wall_material = new_material
		
	return self



func change_material_on_door_slots(new_material: Material) -> RoomMesh:
	if front_wall_material:
		front_wall_door_slot_material = new_material
		
	if back_wall_door_slot_material:
		back_wall_door_slot_material = new_material
		
	if right_wall_door_slot_material:
		right_wall_door_slot_material = new_material
		
	if left_wall_door_slot_material:
		left_wall_door_slot_material = new_material
		
	return self
#endregion

#region Getters
func get_surface_material(name: String):
	var surface_index: int = room_mesh_shape.surface_find_by_name(name)
	
	return null if surface_index == -1 else room_mesh_shape.surface_get_material(surface_index)
	

func wall_materials() -> Array[CSGBox3D]:
	var materials = []
	
	for wall in ArrayHelper.remove_falsy_values([front_wall_material, back_wall_material, right_wall_material, left_wall_material]):
		materials.append(wall as CSGBox3D)
	
	return materials


func door_slot_materials() -> Array[CSGBox3D]:
	var materials = []
	
	for door_slot in ArrayHelper.remove_falsy_values([front_wall_door_slot_material, back_wall_door_slot_material, right_wall_door_slot_material, left_wall_door_slot_material]):
		materials.append(door_slot as CSGBox3D)
	
	return materials
#endregion

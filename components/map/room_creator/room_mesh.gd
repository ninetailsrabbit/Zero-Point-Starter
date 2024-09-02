@tool
class_name RoomMesh extends MeshInstance3D

var room_mesh_shape: ArrayMesh
var sockets: Array[Marker3D] = []

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

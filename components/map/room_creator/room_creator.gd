@tool
class_name RoomCreator extends Node3D


signal created_csg_rooms(csg_rooms: Array[CSGRoom])
signal created_rooms(rooms: Array)

# Boolean variables that behave as tool buttons
@export var create_new_room: bool = false:
	set(value):
		create_csg_rooms()
@export var clear_generated_rooms: bool = false:
	set(value):
		clear_rooms_in_scene_tree()
@export var clear_last_generated_rooms: bool = false:
	set(value):
		clear_last_generated_rooms_in_scene_tree()
@export var generate_final_mesh: bool = false:
	set(value):
		create_csg_rooms()
@export_group("Parameters")
@export var room_parameters: RoomParameters
@export var generate_mesh_per_room: bool = true
@export var generate_materials: bool = true
@export var include_ceil : bool = true;
@export var include_floor : bool = true;
@export var include_right_wall : bool = true;
@export var include_left_wall : bool = true;
@export var include_front_wall : bool = true;
@export var include_back_wall : bool = true;
@export_group("Collisions")
@export var generate_collisions: bool = true
@export var available_collisions: AvailableCollisions = AvailableCollisions.Trimesh
@export var create_static_body: bool = true
@export var clean_collision: bool = true
@export var simplified_collision: bool = false


enum AvailableCollisions {
	Convex, # Basic shapes
	Trimesh, # More complex shapes that contains csg operations as substraction
}

var wall_rotations: Dictionary = {
	"FrontWall": {"FrontWall": PI, "BackWall": 0, "RightWall": PI / 2, "LeftWall": -PI / 2},
	"BackWall": {"FrontWall": 0, "BackWall": PI, "RightWall": -PI / 2, "LeftWall": PI / 2},
	"RighWall": {"FrontWall": -PI / 2, "BackWall": PI / 2, "RightWall": PI, "LeftWall": 0},
	"LeftWall": {"FrontWall": PI / 2, "BackWall": -PI / 2, "RightWall": 0, "LeftWall": PI},
}

var csg_rooms_created: Array[CSGRoom] = []
var rooms_created: Array[RoomMesh] = []
var csg_rooms_output_node: Node3D
var room_meshes_output_node: Node3D

func create_csg_rooms() -> void:
	if _tool_can_be_used():
		
		if csg_rooms_output_node == null:
			csg_rooms_output_node = Node3D.new()
			csg_rooms_output_node.name = "CSGRoomsOutputNode"
			add_child(csg_rooms_output_node)
			NodeTraversal.set_owner_to_edited_scene_root(csg_rooms_output_node)
			
		var root_node = csg_rooms_output_node



func clear_rooms_in_scene_tree() -> void:
	if _tool_can_be_used():
		
		for child in get_children():
			child.free()
			
		csg_rooms_output_node = null
		room_meshes_output_node = null
		
		csg_rooms_created.clear()
		room_meshes_output_node.clear()


func clear_last_generated_rooms_in_scene_tree() -> void:
	if _tool_can_be_used() and not csg_rooms_created.is_empty():
		var rooms_to_remove_count = room_parameters.number_of_rooms_per_generation + (ceil(room_parameters.number_of_rooms_per_generation / 2) if room_parameters.use_bridge_connector_between_rooms else 0)
		
		var last_rooms_created = csg_rooms_created.slice(max(0, csg_rooms_created.size() - rooms_to_remove_count))
		csg_rooms_created = csg_rooms_created.slice(0, last_rooms_created.size())
		
		for room in last_rooms_created:
			room.free()



func _tool_can_be_used() -> bool:
	return room_parameters and (Engine.is_editor_hint() and is_inside_tree()) or (not Engine.is_editor_hint() and is_node_ready())

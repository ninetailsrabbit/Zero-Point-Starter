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
	"FrontWall": {"FrontWall": PI, "BackWall": 0.0, "RightWall": PI / 2, "LeftWall": -PI / 2},
	"BackWall": {"FrontWall": 0.0, "BackWall": PI, "RightWall": -PI / 2, "LeftWall": PI / 2},
	"RighWall": {"FrontWall": -PI / 2, "BackWall": PI / 2, "RightWall": PI, "LeftWall": 0.0},
	"LeftWall": {"FrontWall": PI / 2, "BackWall": -PI / 2, "RightWall": 0.0, "LeftWall": PI},
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
		
		if not generate_mesh_per_room:
			var csg_combiner_root: CSGCombiner3D = csg_rooms_output_node.get_node_or_null("CSGCombinerRoot")
			
			if csg_combiner_root == null:
				csg_combiner_root = CSGCombiner3D.new()
				csg_combiner_root.name = "CSGCombinerRoot"
				csg_combiner_root.use_collision = false
				
			if not csg_combiner_root.is_inside_tree():
				csg_rooms_output_node.add_child(csg_combiner_root)
				NodeTraversal.set_owner_to_edited_scene_root(csg_combiner_root)
				
			root_node = csg_combiner_root
		
		var number_of_rooms: int = calculate_number_of_rooms(room_parameters.use_bridge_connector_between_rooms)

		for room_number in number_of_rooms:
			var is_bridge_connector: bool = room_parameters.use_bridge_connector_between_rooms and csg_rooms_created.size() > 0 and not csg_rooms_created.back().is_bridge_room_connector
			
			var room: CSGRoom = CSGRoom.new()
			room.name = "Room%d" % csg_rooms_created.size()
			room.position = csg_rooms_created.back().position if csg_rooms_created.size() > 0 else Vector3.ZERO
			room.use_collision = false
			room.is_bridge_room_connector = is_bridge_connector
			room.room_size = generate_room_size_based_on_range(room_parameters.min_bridge_connector_size, room_parameters.max_bridge_connector_size) if is_bridge_connector else generate_room_size_based_on_range()
			room.door_size = room_parameters.door_size
			room.number_of_doors = 1 if csg_rooms_created.is_empty() else room_parameters.doors_per_room
			room.randomize_door_position_in_wall = room_parameters.randomize_door_position_in_wall
			room.include_floor = include_floor
			room.include_ceil = include_ceil
			room.include_front_wall = include_front_wall
			room.include_back_wall = include_back_wall
			room.include_left_wall = include_left_wall
			room.include_right_wall = include_right_wall
			room.generate_materials = generate_materials
			
			root_node.add_child(room)
			
			if csg_rooms_created.size() > 0 and room:
				connect_rooms(csg_rooms_created.back(), room)
				
			csg_rooms_created.append(room)
		
		created_csg_rooms.emit(csg_rooms_created)
			

func connect_rooms(room_a: CSGRoom, room_b: CSGRoom) -> void:
	var available_sockets_room_a: Array[Marker3D]= room_a.available_sockets()
	var available_sockets_room_b: Array[Marker3D]= room_b.available_sockets()
	
	if available_sockets_room_a.size() > 0 and available_sockets_room_b.size() > 0:
		var room_a_socket: Marker3D = available_sockets_room_a.front() as Marker3D
		var room_b_socket: Marker3D = available_sockets_room_b.front() as Marker3D
		
		var wall_room_a: CSGBox3D = room_a_socket.get_parent() as CSGBox3D
		var wall_room_b: CSGBox3D = room_b_socket.get_parent() as CSGBox3D
		
		var rotation_to_align_rooms: float = wall_rotations[wall_room_b.name][wall_room_a.name]
		
		# This -room calculation adapts the rotation relatively to last room
		room_b.rotate_y(rotation_to_align_rooms - (-room_a.rotation.y))
		room_b.global_translate(room_a_socket.global_position - room_b_socket.global_position)
		
		room_a_socket.set_meta("connected", true)
		room_b_socket.set_meta("connected", true)
	
	
func generate_room_size_based_on_range(min_room_size: Vector3 = room_parameters.min_room_size, max_room_size: Vector3 = room_parameters.max_room_size) -> Vector3:
	if min_room_size.is_equal_approx(max_room_size):
		return min_room_size
	else:
		return Vector3(
			randf_range(min_room_size.x, max_room_size.x),
			randf_range(min_room_size.y, max_room_size.y),
			randf_range(min_room_size.z, max_room_size.z),
		)
	
func calculate_number_of_rooms(use_bridge_connectors: bool = room_parameters.use_bridge_connector_between_rooms) -> int:
	var number_of_rooms = room_parameters.number_of_rooms_per_generation
	
	if use_bridge_connectors:
		number_of_rooms += ceil(number_of_rooms / 2.0)
		
		if number_of_rooms % 2 == 0:
			number_of_rooms += 1
	
	return number_of_rooms


func clear_rooms_in_scene_tree() -> void:
	if _tool_can_be_used():
		
		for child in get_children():
			child.free()
			
		csg_rooms_output_node = null
		room_meshes_output_node = null
		
		csg_rooms_created.clear()
		rooms_created.clear()


func clear_last_generated_rooms_in_scene_tree() -> void:
	if _tool_can_be_used() and not csg_rooms_created.is_empty():
		var rooms_to_remove_count = room_parameters.number_of_rooms_per_generation + (ceil(room_parameters.number_of_rooms_per_generation / 2) if room_parameters.use_bridge_connector_between_rooms else 0)
		
		var last_rooms_created = csg_rooms_created.slice(max(0, csg_rooms_created.size() - rooms_to_remove_count))
		csg_rooms_created = csg_rooms_created.slice(0, last_rooms_created.size())
		
		for room in last_rooms_created:
			room.free()
			
		if csg_rooms_created.is_empty() and csg_rooms_output_node:
			csg_rooms_output_node.free()
			csg_rooms_output_node = null


func _tool_can_be_used() -> bool:
	return room_parameters and (Engine.is_editor_hint() and is_inside_tree()) or (not Engine.is_editor_hint() and is_node_ready())

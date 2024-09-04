@tool
class_name RoomCreator extends Node3D

signal created_csg_rooms(csg_rooms: Array[CSGRoom])
signal created_rooms(rooms: Array[RoomMesh])

# Tool buttons parsed from the inspector plugin script
@export var button_Generate_Rooms: String
@export var button_Generate_Final_Mesh: String
@export var button_Clear_All: String
@export var button_Clear_Last_Generated_Rooms: String

@export_group("Generation")
@export var generate_mesh_mode: MeshGenerationMode = MeshGenerationMode.MeshPerRoom
@export var generate_materials: bool = true
@export var include_ceil : bool = true
@export var include_floor : bool = true
@export var include_right_wall : bool = true
@export var include_left_wall : bool = true
@export var include_front_wall : bool = true
@export var include_back_wall : bool = true
@export var include_ceil_columns : bool = true
@export_group("Collisions")
@export var generate_collisions: bool = true
@export var type_of_collision: AvailableCollisions = AvailableCollisions.Trimesh
@export var create_static_body: bool = true
@export var clean_collision: bool = true
@export var simplified_collision: bool = false

@export_group("Size Parameters")
@export var room_parameters: RoomParameters

enum MeshGenerationMode {
	MeshPerRoom,
	OneCombinedMesh
}

enum AvailableCollisions {
	Convex, # Basic shapes
	Trimesh, # More complex shapes that contains csg operations as substraction
}

static var wall_rotations: Dictionary = {
	"FrontWall": {"FrontWall": PI, "BackWall": 0, "RightWall": PI / 2, "LeftWall": -PI / 2},
	"BackWall": {"FrontWall": 0, "BackWall": PI, "RightWall": -PI / 2, "LeftWall": PI / 2},
	"RightWall": {"FrontWall": -PI / 2, "BackWall": PI / 2, "RightWall": PI, "LeftWall": 0},
	"LeftWall": {"FrontWall": PI / 2, "BackWall": -PI / 2, "RightWall": 0, "LeftWall": PI},
}

var csg_rooms_created: Array[CSGRoom] = []
var rooms_created: Array[RoomMesh] = []
var csg_rooms_output_node: Node3D
var room_meshes_output_node: Node3D


func _on_tool_button_pressed(text: String) -> void:
	match text:
		"Generate Rooms":
			create_csg_rooms()
		"Clear All":
			clear_rooms_in_scene_tree()
		"Clear Last Generated Rooms":
			clear_last_generated_rooms_in_scene_tree()
		"Generate Final Mesh":
			generate_room_meshes()


func create_csg_rooms() -> void:
	if _tool_can_be_used():
		var root_node = _prepare_csg_rooms_output_node()
		
		if generate_mesh_mode == MeshGenerationMode.OneCombinedMesh:
			root_node = _prepare_csg_combiner_root()
		
		var number_of_rooms: int = calculate_number_of_rooms(room_parameters.use_bridge_connector_between_rooms)

		for room_number in number_of_rooms:
			var csg_room = create_csg_room()
			root_node.add_child(csg_room)
			
			if csg_rooms_created.size() > 0 and csg_room:
				connect_rooms(csg_rooms_created.back(), csg_room)
				
			csg_rooms_created.append(csg_room)
		
		created_csg_rooms.emit(csg_rooms_created)


func create_csg_room() -> CSGRoom:
	var is_bridge_connector: bool = room_parameters.use_bridge_connector_between_rooms and csg_rooms_created.size() > 0 and not csg_rooms_created.back().is_bridge_room_connector
	var room: CSGRoom = CSGRoom.new()
	
	room.name = "Room%d" % csg_rooms_created.size()
	room.position = csg_rooms_created.back().position if csg_rooms_created.size() > 0 else Vector3.ZERO
	room.use_collision = false
	room.is_bridge_room_connector = is_bridge_connector
	room.room_size = generate_room_size_based_on_range(room_parameters.min_bridge_connector_size, room_parameters.max_bridge_connector_size) if is_bridge_connector else generate_room_size_based_on_range()
	room.door_size = room_parameters.door_size
	room.number_of_doors = 1 if csg_rooms_created.is_empty() and room_parameters.number_of_rooms_per_generation > 1 else room_parameters.doors_per_room
	room.randomize_door_position_in_wall = room_parameters.randomize_door_position_in_wall
	room.include_floor = include_floor
	room.include_ceil = include_ceil
	room.include_ceil_columns = include_ceil_columns
	room.include_front_wall = include_front_wall
	room.include_back_wall = include_back_wall
	room.include_left_wall = include_left_wall
	room.include_right_wall = include_right_wall
	room.generate_materials = generate_materials
	room.ceil_thickness = room_parameters.ceil_thickness
	room.floor_thickness = room_parameters.floor_thickness
	room.wall_thickness = room_parameters.wall_thickness
	room.ceil_column_thickness = room_parameters.ceil_column_thickness
	room.ceil_column_height = room_parameters.ceil_column_height
	
	return room


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
		
		room_a_socket.set_meta("connected", room_b_socket)
		room_b_socket.set_meta("connected", room_a_socket)
	
	
func generate_room_size_based_on_range(min_room_size: Vector3 = room_parameters.min_room_size, max_room_size: Vector3 = room_parameters.max_room_size) -> Vector3:
	if min_room_size.is_equal_approx(max_room_size):
		return min_room_size
	else:
		var room_size: Vector3 = Vector3(
				randf_range(min_room_size.x, max_room_size.x),
				randf_range(min_room_size.y, max_room_size.y),
				randf_range(min_room_size.z, max_room_size.z),
			) 
		
		if room_parameters.use_integer_values_size:
			room_size = round(room_size)
			
		return room_size


func calculate_number_of_rooms(use_bridge_connectors: bool = room_parameters.use_bridge_connector_between_rooms) -> int:
	var number_of_rooms = room_parameters.number_of_rooms_per_generation
	
	if use_bridge_connectors:
		number_of_rooms += ceili(number_of_rooms / 2.0)
		
		if number_of_rooms % 2 == 0:
			number_of_rooms += 1
	
	return number_of_rooms


func generate_collision_on_room_mesh(room_mesh_instance: RoomMesh) -> void:
	if generate_collisions:
		match type_of_collision:
			AvailableCollisions.Convex:
				var convex_collision = CollisionShape3D.new()
				convex_collision.name = "%sConvexCollision" % room_mesh_instance.name
				convex_collision.shape = room_mesh_instance.mesh.create_convex_shape(clean_collision, simplified_collision)
			
				if create_static_body:
					var body = StaticBody3D.new()
					body.name = "%sStaticBody3D" % room_mesh_instance.name
					room_mesh_instance.add_child(body)
					NodeTraversal.set_owner_to_edited_scene_root(body)
					body.add_child(convex_collision)
				else:
					room_mesh_instance.add_child(convex_collision)
					
				NodeTraversal.set_owner_to_edited_scene_root(convex_collision)
				
			AvailableCollisions.Trimesh:
				var trimesh_collision = CollisionShape3D.new()
				trimesh_collision.name = "%sTrimeshCollision" % room_mesh_instance.name
				trimesh_collision.shape = room_mesh_instance.mesh.create_trimesh_shape()
				
				if create_static_body:
					var body = StaticBody3D.new()
					body.name = "%sStaticBody3D" % room_mesh_instance.name
					room_mesh_instance.add_child(body)
					NodeTraversal.set_owner_to_edited_scene_root(body)
					body.add_child(trimesh_collision)
				else:
					room_mesh_instance.add_child(trimesh_collision)
			
				NodeTraversal.set_owner_to_edited_scene_root(trimesh_collision)
	

func generate_room_meshes() -> void:
	if _tool_can_be_used():
		
		if generate_mesh_mode == MeshGenerationMode.MeshPerRoom:
			if room_meshes_output_node == null:
				room_meshes_output_node = Node3D.new()
				room_meshes_output_node.name = "RoomMeshesOutputNode"
				add_child(room_meshes_output_node)
				NodeTraversal.set_owner_to_edited_scene_root(room_meshes_output_node)
				
			var room_created_names: Array = rooms_created.map(func(room: RoomMesh): return room.name)
			var new_rooms = csg_rooms_created.filter(func(csg_room): return not csg_room.name in room_created_names)
			
			for room: CSGRoom in new_rooms:
				var room_mesh_instance: RoomMesh = room.generate_mesh_instance() as RoomMesh
				
				if room_mesh_instance:
					room_meshes_output_node.add_child(room_mesh_instance)
					
					NodeTraversal.set_owner_to_edited_scene_root(room_mesh_instance)
					
					add_door_sockets_to_generated_room_mesh(room_mesh_instance)
					name_surfaces_on_room_mesh(room, room_mesh_instance)
					generate_collision_on_room_mesh(room_mesh_instance)
					rooms_created.append(room_mesh_instance)
					
					room_mesh_instance.set_script(null)
					
			created_rooms.emit(rooms_created)
			
		elif generate_mesh_mode == MeshGenerationMode.OneCombinedMesh:
			var csg_combiner_root: CSGCombiner3D = csg_rooms_output_node.get_node("CSGCombinerRoot") as CSGCombiner3D
			
			if room_meshes_output_node:
				room_meshes_output_node.free()
				
			room_meshes_output_node = Node3D.new()
			room_meshes_output_node.name = "RoomMeshesOutputNode"
			add_child(room_meshes_output_node)
			NodeTraversal.set_owner_to_edited_scene_root(room_meshes_output_node)
			
			var meshes = csg_combiner_root.get_meshes()
			
			if meshes.size() > 1:
				var room_mesh_instance = RoomMesh.new()
				room_mesh_instance.name = "GeneratedRoomMesh"
				room_mesh_instance.mesh = meshes[1] as ArrayMesh
				
				for socket: Marker3D in NodeTraversal.find_nodes_of_type(csg_combiner_root, Marker3D.new()):
					room_mesh_instance.sockets.append(socket)

				room_meshes_output_node.add_child(room_mesh_instance)
				
				NodeTraversal.set_owner_to_edited_scene_root(room_mesh_instance)
				
				add_door_sockets_to_generated_room_mesh(room_mesh_instance)
				name_surfaces_on_combined_mesh(csg_combiner_root, room_mesh_instance)
				generate_collision_on_room_mesh(room_mesh_instance)
				
				room_mesh_instance.set_script(null)


func add_door_sockets_to_generated_room_mesh(room_mesh_instance: RoomMesh) -> void:
	for socket: Marker3D in room_mesh_instance.sockets:
		## Duplicate does not work as expected so a new Marker3d needs to be created and assign the properties manually
		var door_socket = Marker3D.new()
		door_socket.name = socket.name
		door_socket.set_meta("wall", socket.get_meta("wall"))
		
		room_mesh_instance.add_child(door_socket)
		NodeTraversal.set_owner_to_edited_scene_root(door_socket)
		
		door_socket.global_position = socket.global_position
		door_socket.global_rotation = socket.global_rotation

	
func name_surfaces_on_combined_mesh(root_node_for_rooms: CSGCombiner3D, room_mesh_instance: MeshInstance3D) -> void:
	var index: int = 0
	
	for room: CSGRoom in root_node_for_rooms.get_children().filter(func(child): return child is CSGRoom):
		for shape: CSGBox3D in room.materials_by_room_part:
			room_mesh_instance.mesh.surface_set_name(index, shape.name)
			index += 1
	
	
func name_surfaces_on_room_mesh(room: CSGRoom, room_mesh_instance: MeshInstance3D) -> void:
	for shape: CSGBox3D in room.materials_by_room_part:
		room_mesh_instance.mesh.surface_set_name(room.materials_by_room_part[shape], shape.name)


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
		var rooms_to_remove_count = room_parameters.number_of_rooms_per_generation + (ceili(room_parameters.number_of_rooms_per_generation / 2) if room_parameters.use_bridge_connector_between_rooms else 0)

		var last_rooms_created = csg_rooms_created.slice(max(0, csg_rooms_created.size() - rooms_to_remove_count))
		csg_rooms_created = csg_rooms_created.slice(0, csg_rooms_created.size() - last_rooms_created.size())
		
		for room in last_rooms_created:
			room.free()
		
		if csg_rooms_created.is_empty() and csg_rooms_output_node:
				csg_rooms_output_node.free()
				csg_rooms_output_node = null
			

func _prepare_csg_rooms_output_node() -> Node3D:
	if csg_rooms_output_node == null:
		csg_rooms_output_node = Node3D.new()
		csg_rooms_output_node.name = "CSGRoomsOutputNode"
		add_child(csg_rooms_output_node)
		NodeTraversal.set_owner_to_edited_scene_root(csg_rooms_output_node)
		
	return csg_rooms_output_node
	
	
func _prepare_csg_combiner_root() -> CSGCombiner3D:
	var csg_combiner_root: CSGCombiner3D = csg_rooms_output_node.get_node_or_null("CSGCombinerRoot")
			
	if csg_combiner_root == null:
		csg_combiner_root = CSGCombiner3D.new()
		csg_combiner_root.name = "CSGCombinerRoot"
		csg_combiner_root.use_collision = false
		
	if not csg_combiner_root.is_inside_tree():
		csg_rooms_output_node.add_child(csg_combiner_root)
		NodeTraversal.set_owner_to_edited_scene_root(csg_combiner_root)
	
	return csg_combiner_root


func _tool_can_be_used() -> bool:
	return room_parameters and (Engine.is_editor_hint() and is_inside_tree()) or (not Engine.is_editor_hint() and is_node_ready())

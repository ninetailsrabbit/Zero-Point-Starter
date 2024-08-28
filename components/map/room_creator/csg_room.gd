@tool
class_name CSGRoom extends CSGCombiner3D

@export var room_size: Vector3 = Vector3.ZERO
## Defines whether it represents a room connector instead of a room itself
@export var is_bridge_room_connector : bool = false
## Generate the standard materials on new csg elements
@export var generate_materials : bool = true
@export_group("Doors")
@export var door_size: Vector3 = Vector3(1.5, 2.0, 0.25)
@export_range(1, 4, 1) var number_of_doors = 1
@export var randomize_door_position_in_wall: bool = false
@export_group("Thickness")
@export var wall_thickness: float = 0.15
@export var ceil_thickness: float = 0.1
@export var floor_thickness: float = 0.1
@export_group("Includes")
@export var include_ceil : bool= true;
@export var include_floor : bool= true;
@export var include_right_wall : bool= true;
@export var include_left_wall : bool= true;
@export var include_front_wall : bool= true;
@export var include_back_wall : bool= true;


var floor: CSGBox3D
var ceil: CSGBox3D
var front_wall: CSGBox3D
var back_wall: CSGBox3D
var left_wall: CSGBox3D
var right_wall: CSGBox3D

var materials_by_room_part: Dictionary ##  CSGShape and the surface related index


func _enter_tree() -> void:
	if get_child_count() == 0 and not room_size.is_zero_approx():
		build()


func build() -> void:
	NodeTraversal.set_owner_to_edited_scene_root(self)
	
	if is_bridge_room_connector:
		name = "BridgeConnector%s" % name
		
	if include_floor:
		create_floor(room_size)
		
	if include_ceil:
		create_ceil(room_size)
		
	if include_front_wall:
		create_front_wall(room_size)
	
	if include_back_wall:
		create_back_wall(room_size)
		
	if include_right_wall:
		create_right_wall(room_size)
		
	if include_left_wall:
		create_left_wall(room_size)
	
	if is_bridge_room_connector:
		create_door_slot_in_wall(front_wall, 1)
		create_door_slot_in_wall(back_wall, 2)
	else:
		for socket_number in number_of_doors:
			create_door_slot_in_random_wall(socket_number)
		
	create_materials_on_room()
		


func create_materials_on_room() -> void:
	if generate_materials:
		var shapes =  NodeTraversal.get_all_children(self).filter(func(child): return child is CSGBox3D)
		
		for index in shapes.size():
			shapes[index].material = StandardMaterial3D.new()
			materials_by_room_part[shapes[index]] = index


func generate_mesh_instance():
	var meshes = get_meshes()
	
	if meshes.size() > 1:
		var room_mesh: RoomMesh = RoomMesh.new()
		room_mesh.name = name
		room_mesh.mesh = meshes[1]
		room_mesh.position = position
		room_mesh.rotation = rotation
		
		return room_mesh
	
	return null

#region Getters
func walls() -> Array[CSGBox3D]:
	var result: Array[CSGBox3D] = []

	for wall: CSGBox3D in ArrayHelper.remove_falsy_values([front_wall, back_wall, right_wall, left_wall]):
		result.append(wall)
	
	return result


func available_sockets() -> Array[Marker3D]:
	var markers = find_children("*", type_string(typeof(Marker3D))).filter(func(socket: Node): return socket is Marker3D and not socket.get_meta("connected"))
	var sockets: Array[Marker3D] = []
	
	for socket: Marker3D in markers:
		sockets.append(socket)
	
	return sockets


func get_door_sloot_from_wall(wall: CSGBox3D):
	if wall:
		return wall.get_node_or_null("DoorSlot")
		
	return null
#endregion

#region Part creators
func create_door_slot_in_random_wall(socket_number: int = 1, size: Vector3 = room_size, _door_size: Vector3 = door_size) -> void:
	var available_walls = walls().filter(func(wall: CSGBox3D): return wall.name.containsn("wall") and wall.get_child_count() == 0)

	if available_walls.size() > 0:
		create_door_slot_in_wall(available_walls.pick_random(), socket_number, size, _door_size)


func create_door_slot_in_wall(wall: CSGBox3D, socket_number: int = 1, size: Vector3 = room_size, _door_size: Vector3 = door_size) -> void:
	if wall.get_child_count() == 0:
		var regex: RegEx = RegEx.new()
		regex.compile("(front|back)")
		
		var regex_result = regex.search(wall.name.to_lower()) # Front and back walls does not apply door rotation to fit in
		
		var door_position: Vector3 = Vector3(0, Vector3.DOWN.y * ( (room_size.y / 2) - (_door_size.y / 2) ), 0)
		var door_rotation: Vector3 = Vector3(0, 0 if regex_result else PI / 2, 0)
		
		if randomize_door_position_in_wall:
			if door_rotation.y != 0 and (wall.size.z - _door_size.x) > _door_size.x:
				door_position.z = (-1 if MathHelper.chance(0.5) else 1) * randf_range(_door_size.x, (wall.size.z - _door_size.x) / 2)
			
			if door_rotation.y == 0 and (wall.size.x - _door_size.x) > _door_size.x:
				door_position.x = (-1 if MathHelper.chance(0.5) else 1) * randf_range(_door_size.x, (wall.size.x - _door_size.x) / 2)
				
		var door_slot: CSGBox3D = CSGBox3D.new()
		door_slot.name = "DoorSlot"
		door_slot.operation = CSGBox3D.OPERATION_SUBTRACTION
		door_slot.size = _door_size
		door_slot.position = door_position
		door_slot.rotation = door_rotation
		
		wall.add_child(door_slot)
		
		NodeTraversal.set_owner_to_edited_scene_root(door_slot)
		
		var room_socket: Marker3D = Marker3D.new()
		room_socket.name = "RoomSocket %d" % socket_number
		room_socket.position = Vector3(door_slot.position.x, min( (door_slot.position.y + _door_size.y / 2) + 0.1, size.y), door_slot.position.z)
		room_socket.set_meta("connected", false)
		
		match wall.name.to_lower().strip_edges():
			"frontwall":
				room_socket.position += Vector3.FORWARD * (wall_thickness / 2)
			"backwall":
				room_socket.position += Vector3.BACK * (wall_thickness / 2)
			"rightwall":
				room_socket.position += Vector3.RIGHT * (wall_thickness / 2)
			"leftwall":
				room_socket.position += Vector3.LEFT * (wall_thickness / 2)
				
		wall.add_child(room_socket)
		NodeTraversal.set_owner_to_edited_scene_root(room_socket)
	
	
func create_floor(size: Vector3 = room_size) -> void:
	floor = CSGBox3D.new()
	floor.name = "Floor"
	floor.size = Vector3(size.x + floor_thickness * 2, floor_thickness, size.z + floor_thickness * 2)
	floor.position = Vector3.ZERO
	
	add_child(floor)
	NodeTraversal.set_owner_to_edited_scene_root(floor)


func create_ceil(size: Vector3 = room_size) -> void:
	ceil = CSGBox3D.new()
	ceil.name = "Ceil"
	ceil.size = Vector3(size.x + ceil_thickness * 2, ceil_thickness, size.z + ceil_thickness * 2)
	ceil.position = Vector3(0, max(size.y, (size.y + ceil_thickness) - size.y / 2.5), 0)
	
	add_child(ceil)
	NodeTraversal.set_owner_to_edited_scene_root(ceil)


func create_front_wall(size: Vector3 = room_size) -> void:
	front_wall = CSGBox3D.new()
	front_wall.name = "FrontWall"
	front_wall.size = Vector3(size.x, size.y, wall_thickness)
	front_wall.position = Vector3(0, size.y / 2, min(-size.z / 2, -(size.z + wall_thickness) / 2.5) )
	
	add_child(front_wall)
	NodeTraversal.set_owner_to_edited_scene_root(front_wall)


func create_back_wall(size: Vector3 = room_size) -> void:
	back_wall = CSGBox3D.new()
	back_wall.name = "BackWall"
	back_wall.size = Vector3(size.x, size.y, wall_thickness)
	back_wall.position = Vector3(0, size.y / 2, max(size.z / 2, (size.z + wall_thickness) / 2.5) )
	
	add_child(back_wall)
	NodeTraversal.set_owner_to_edited_scene_root(back_wall)


func create_right_wall(size: Vector3 = room_size) -> void:
	right_wall = CSGBox3D.new()
	right_wall.name = "RightWall"
	right_wall.size = Vector3(wall_thickness, size.y, size.z)
	right_wall.position = Vector3(max(size.x / 2, (size.x + wall_thickness) / 2.5) , size.y / 2, 0)
	
	add_child(right_wall)
	NodeTraversal.set_owner_to_edited_scene_root(right_wall)


func create_left_wall(size: Vector3 = room_size) -> void:
	left_wall = CSGBox3D.new()
	left_wall.name = "LeftWall"
	left_wall.size = Vector3(wall_thickness, size.y, size.z)
	left_wall.position = Vector3(min(-size.x / 2, (-size.x + wall_thickness) / 2.5) , size.y / 2, 0)
	
	add_child(left_wall)
	NodeTraversal.set_owner_to_edited_scene_root(left_wall)

#endregion

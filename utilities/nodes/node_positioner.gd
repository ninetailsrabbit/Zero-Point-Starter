class_name NodePositioner


static func global_direction_to_v2(a: Node2D, b: Node2D) -> Vector2:
	return a.global_position.direction_to(b.global_position)


static func local_direction_to_v2(a: Node2D, b: Node2D) -> Vector2:
	return a.position.direction_to(b.position)


static func global_distance_to_v2(a: Node2D, b: Node2D) -> float:
	return a.global_position.distance_to(b.global_position)


static func local_distance_to_v2(a: Node2D, b: Node2D) -> float:
	return a.position.distance_to(b.position)
	
	
static func global_direction_to_v3(a: Node3D, b: Node3D) -> Vector3:
	return a.global_position.direction_to(b.global_position)


static func local_direction_to_v3(a: Node3D, b: Node3D) -> Vector3:
	return a.position.direction_to(b.position)


static func global_distance_to_v3(a: Node3D, b: Node3D) -> float:
	return a.global_position.distance_to(b.global_position)


static func local_distance_to_v3(a: Node3D, b: Node3D) -> float:
	return a.position.distance_to(b.position)


static func a_is_facing_b(a: Node3D, b: Node3D) -> bool:
	return b.global_position.dot(a.basis.z) < 0


static func get_nearest_node_by_distance(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary:
	var result := {"target": null, "distance": null}
	
	for node in nodes.filter(func(node): return node is Node2D or node is Node3D): ## Only allows node that can use global_position in the world
		var distance_to_target: float = node.global_position.distance_to(from)
		
		if MathHelper.decimal_value_is_between(distance_to_target, min_distance, max_range) and (result.target == null or (distance_to_target < result.distance)):
			result.target = node
			result.distance = distance_to_target
		
		
	return result
	

static func get_nearest_nodes_sorted_by_distance(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Array:
	var nodes_copy = nodes.duplicate()\
		.filter(func(node): return (node is Node2D or node is Node3D) and MathHelper.decimal_value_is_between(node.global_position.distance_to(from), min_distance, max_range))
		
	nodes_copy.sort_custom(func(a, b): return a.global_position.distance_to(from) < b.global_position.distance_to(from))
	
	return nodes_copy


static func get_farthest_node_by_distance(from: Vector2, nodes: Array = [], min_distance: float = 0.0, max_range: float = 9999) -> Dictionary:
	var farthest := {"target": null, "distance": 0.0}
	
	for node in nodes.filter(func(node): return node is Node2D or node is Node3D): ## Only allows node that can use global_position in the world
		var distance_to_target: float = node.global_position.distance_to(from)
		
		if MathHelper.decimal_value_is_between(distance_to_target, min_distance, max_range) and (farthest.target == null or (distance_to_target > farthest.distance)):
			farthest.target = node
			farthest.distance = distance_to_target
		
		
	return farthest

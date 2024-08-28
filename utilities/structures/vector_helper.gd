class_name VectorHelper

static var directions_v2 = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
static var horizontal_directions_v2 = [Vector2.LEFT, Vector2.RIGHT]
static var vertical_directions_v2 = [Vector2.UP, Vector2.DOWN]

static var directions_v3 = [Vector3.UP, Vector3.DOWN, Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]

static var opposite_directions_v2 = {
	Vector2.UP: Vector2.DOWN,
	Vector2.DOWN: Vector2.UP,
	Vector2.RIGHT: Vector2.LEFT,
	Vector2.LEFT: Vector2.RIGHT
}

static var opposite_directions_v3 = {
  	Vector3.UP: Vector3.DOWN,
	Vector3.DOWN: Vector3.UP,
	Vector3.RIGHT: Vector3.LEFT, 
	Vector3.LEFT: Vector3.RIGHT, 
	Vector3.FORWARD: Vector3.BACK, 
	Vector3.BACK: Vector3.FORWARD
}

static func up_direction_opposite_vector2(up_direction: Vector2) -> Vector2:
	if opposite_directions_v2.has(up_direction):
		return opposite_directions_v2[up_direction]
	
	return Vector2.ZERO


static func up_direction_opposite_vector3(up_direction: Vector3) -> Vector3:
	if opposite_directions_v3.has(up_direction):
		return opposite_directions_v3[up_direction]
	
	return Vector3.ZERO

static func generate_2d_random_directions_using_degrees(num_directions: int = 10, origin: Vector2 = Vector2.UP, min_angle: float = 0.0, max_angle: float = 360.0) -> Array[Vector2]:
	var random_directions: Array[Vector2] = []

	for direction in range(num_directions):
		random_directions.append(origin.rotated(generate_random_angle_in_degrees(min_angle, max_angle)))

	return random_directions


static func generate_2d_random_directions_using_radians(num_directions: int = 10, origin: Vector2 = Vector2.UP, min_angle: float = 0.0, max_angle: float = 6.2831853072) -> Array[Vector2]:
	var random_directions: Array[Vector2] = []
	
	for direction in range(num_directions):
		random_directions.append(origin.rotated(generate_random_angle_in_radians(min_angle, max_angle)))

	return random_directions


static func generate_3d_random_directions_using_degrees(num_directions: int = 10, origin: Vector3 = Vector3.UP, min_angle: float = 0.0, max_angle: float = 360.0) -> Array[Vector3]:
	var random_directions: Array[Vector3] = []
	
	for direction in range(num_directions):
		random_directions.append(origin.rotated(Vector3.UP, generate_random_angle_in_degrees(min_angle, max_angle)))

	return random_directions


static func generate_3d_random_directions_using_radians(num_directions: int = 10, origin: Vector3 = Vector3.UP, min_angle: float = 0.0, max_angle: float = 6.2831853072) -> Array[Vector3]:
	var random_directions: Array[Vector3] = []
	
	for direction in range(num_directions):
		random_directions.append(origin.rotated(Vector3.UP, generate_random_angle_in_radians(min_angle, max_angle)))

	return random_directions


static func generate_random_angle_in_radians(min_angle: float = 0.0, max_angle: float = 6.2831853072) -> float:
	return min_angle + randf() * (max_angle - min_angle)


static func generate_random_angle_in_degrees(min_angle: float = 0.0, max_angle: float = 360.0) -> float:
	return min_angle + randf() * (max_angle - min_angle)


static func generate_2d_random_direction() -> Vector2:
	return Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()


static func generate_2d_random_fixed_direction() -> Vector2:
	return Vector2(randi_range(-1, 1), randi_range(-1, 1)).normalized()


static func generate_3d_random_direction() -> Vector3:
	return Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()


static func generate_3d_random_fixed_direction() -> Vector3:
	return Vector3(randi_range(-1, 1), randi_range(-1, 1), randi_range(-1, 1)).normalized()


static func translate_x_axis_to_vector(axis: float) -> Vector2:
	var horizontal_direction = Vector2.ZERO
	
	match axis:
		-1.0:
			horizontal_direction = Vector2.LEFT 
		1.0:
			horizontal_direction = Vector2.RIGHT
			
	return horizontal_direction


static func translate_y_axis_to_vector(axis: float) -> Vector2:
	var vertical_direction = Vector2.ZERO
	
	match axis:
		-1.0:
			vertical_direction = Vector2.UP 
		1.0:
			vertical_direction = Vector2.DOWN
			
	return vertical_direction


static func normalize_vector2(value: Vector2) -> Vector2:
		var direction := normalize_diagonal_vector2(value)
		
		if direction.is_equal_approx(value):
			return value if value.is_normalized() else value.normalized()
		
		return direction


static func normalize_diagonal_vector2(direction: Vector2) -> Vector2:
	if is_diagonal_direction_v2(direction):
		return direction * sqrt(2)
	
	return direction


static func is_diagonal_direction_v2(direction: Vector2) -> bool:
	return direction.x != 0 and direction.y != 0
	

static func normalize_vector3(value: Vector3) -> Vector3:
		var direction := normalize_diagonal_vector3(value)
		
		if direction.is_equal_approx(value):
			return value if value.is_normalized() else value.normalized()
		
		return direction


static func normalize_diagonal_vector3(direction: Vector3) -> Vector3:
	if is_diagonal_direction_v3(direction):
		return direction * sqrt(3)
	
	return direction


static func is_diagonal_direction_v3(direction: Vector3) -> bool:
	return direction.x != 0 and direction.y != 0 and direction.z != 0
	

static func is_withing_distance_squared_v2(vector: Vector2, second_vector: Vector2, distance: float) -> bool:
	return vector.distance_squared_to(second_vector) <= distance * distance
	

static func is_withing_distance_squared_v3(vector: Vector3, second_vector: Vector3, distance: float) -> bool:
	return vector.distance_squared_to(second_vector) <= distance * distance
	

static func direction_from_rotation_v2(rotation: float) -> Vector2:
	return Vector2(cos(rotation * PI / PI), sin(rotation * PI / PI))


static func direction_from_rotation_v3(rotation: float) -> Vector3:
	return Vector3(cos(rotation * PI / PI), sin(rotation * PI / PI), 0)


static func direction_from_rotation_degrees_v2(rotation_degrees: float) -> Vector2:
	rotation_degrees = deg_to_rad(rotation_degrees)
	var pi_degrees := deg_to_rad(PI)
	
	return Vector2(cos(rotation_degrees * pi_degrees / pi_degrees), sin(rotation_degrees * pi_degrees / pi_degrees))


static func direction_from_rotation_degrees_v3(rotation_degrees: float) -> Vector3:
	rotation_degrees = deg_to_rad(rotation_degrees)
	var pi_degrees := deg_to_rad(PI)
	
	return Vector3(cos(rotation_degrees * PI / pi_degrees), sin(rotation_degrees * PI / pi_degrees), 0)
	

static func rotate_horizontal_random(origin: Vector3 = Vector3.ONE) -> Vector3:
	var arc_direction: Vector3 = [Vector3.DOWN, Vector3.UP].pick_random()
	
	return origin.rotated(arc_direction, randf_range(-PI / 2, PI / 2))


static func rotate_vertical_random(origin: Vector3 = Vector3.ONE) -> Vector3:
	var arc_direction: Vector3 = [Vector3.RIGHT, Vector3.LEFT].pick_random()
	
	return origin.rotated(arc_direction, randf_range(-PI / 2, PI / 2))


static func color_from_vector(vec) -> Color:
	if vec is Vector3:
		return Color(vec.x, vec.y, vec.z)
	elif vec is Vector4:
		return Color(vec.x, vec.y, vec.z, vec.w)
	else:
		return Color.BLACK


static func vec3_from_color_rgb(color: Color) -> Vector3:
	return Vector3(color.r, color.g, color.b)
	
	
static func vec3_from_color_hsv(color: Color) -> Vector3:
	return Vector3(color.h, color.s, color.v)
	
	
static func get_position_by_polar_coordinates_v2(center_position: Vector2, angle_radians: float, radius: float) -> Vector2:
	var polar_coordinate := direction_from_rotation_v2(angle_radians) * radius

	return center_position + polar_coordinate
	
	
static func get_position_by_polar_coordinates_v3(center_position: Vector3, angle_radians: float, radius: float) -> Vector3:
	var polar_coordinate := direction_from_rotation_v3(angle_radians) * radius

	return center_position + polar_coordinate

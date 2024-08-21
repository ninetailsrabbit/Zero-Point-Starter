class_name VelocityHelper

const MS_TO_MPH_FACTOR := 2.23694
const MS_TO_KMH_FACTOR := 3.6

static func current_speed_v2_on_miles_per_hour(velocity: Vector2) -> float:
	return roundf(velocity.length() * MS_TO_MPH_FACTOR)
	
static func current_speed_v2_on_kilometers_per_hour(velocity: Vector2) -> float:
	return roundf(velocity.length() * MS_TO_KMH_FACTOR)
	
static func current_speed_v3_on_miles_per_hour(velocity: Vector3) -> float:
	return roundf(Vector3(velocity.x, 0, velocity.z).length() * MS_TO_MPH_FACTOR)
	
static func current_speed_v3_on_kilometers_per_hour(velocity: Vector3) -> float:
	return roundf(Vector3(velocity.x, 0, velocity.z).length() * MS_TO_KMH_FACTOR)
	

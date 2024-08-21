class_name VelocityHelper

const MetersPerSecondToMilePerHourFactor := 2.23694
const MetersPerSecondToKilometersPerHourFactor := 3.6

static func current_speed_v2_on_miles_per_hour(velocity: Vector2) -> float:
	return roundf(velocity.length() * MetersPerSecondToMilePerHourFactor)
	
static func current_speed_v2_on_kilometers_per_hour(velocity: Vector2) -> float:
	return roundf(velocity.length() * MetersPerSecondToMilePerHourFactor)
	
static func current_speed_v3_on_miles_per_hour(velocity: Vector3) -> float:
	return roundf(Vector3(velocity.x, 0, velocity.z).length() * MetersPerSecondToMilePerHourFactor)
	
static func current_speed_v3_on_kilometers_per_hour(velocity: Vector3) -> float:
	return roundf(Vector3(velocity.x, 0, velocity.z).length() * MetersPerSecondToMilePerHourFactor)
	

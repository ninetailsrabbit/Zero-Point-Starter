class_name VelocityHelper

const MetersPerSecondToMilePerHourFactor := 2.23694
const MetersPerSecondToKilometersPerHourFactor := 3.6

static func current_speed_on_miles_per_hour(velocity) -> float:
	if velocity is Vector2:
		return roundf(velocity.length() * MetersPerSecondToMilePerHourFactor)
	elif velocity is Vector3:
		return roundf(Vector3(velocity.x, 0, velocity.z).length() * MetersPerSecondToMilePerHourFactor)
	else:
		return 0.0

static func current_speed_on_kilometers_per_hour(velocity) -> float:
	if velocity is Vector2:
		return roundf(velocity.length() * MetersPerSecondToKilometersPerHourFactor)
	elif velocity is Vector3:
		return roundf(Vector3(velocity.x, 0, velocity.z).length() * MetersPerSecondToKilometersPerHourFactor)
	else:
		return 0.0
	
	

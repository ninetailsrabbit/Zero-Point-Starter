class_name TimeHelper

const meridians := ["AM", "PM"]
const months_abbreviation := {1:"JAN", 2:"FEB", 3:"MAR", 4:"APR", 5:"MAY", 6:"JUN", 7:"JUL", 8:"AUG", 9:"SEP", 10:"OCT", 11:"NOV", 12:"DEC"}
const month_names := {1:"january", 2:"february", 3:"march", 4:"april", 5:"may", 6:"june", 7:"july", 8:"august", 9:"september", 10:"october", 11:"november", 12:"december"}
const day_names := {1:"monday", 2:"tuesday", 3:"wednesday", 4:"thursday", 5:"friday", 6:"saturday", 7:"sunday"}


"""
Formats a time value into a string representation of minutes, seconds, and optionally milliseconds.

Args:
	time (float): The time value to format, in seconds.
	use_milliseconds (bool, optional): Whether to include milliseconds in the formatted string. Defaults to false.

Returns:
	str: A string representation of the formatted time in the format "MM:SS" or "MM:SS:mm", depending on the value of use_milliseconds.

Example:
	# Format 123.456 seconds without milliseconds
	var formatted_time = format_seconds(123.456)
	# Result: "02:03"

	# Format 123.456 seconds with milliseconds
	var formatted_time_with_ms = format_seconds(123.456, true)
	# Result: "02:03:45"
"""
static func format_seconds(time: float, use_milliseconds: bool = false) -> String:
	var minutes := floori(time / 60)
	var seconds := fmod(time, 60)
	
	if(not use_milliseconds):
		return "%02d:%02d" % [minutes, seconds]
		
	var milliseconds := fmod(time, 1) * 100
	
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

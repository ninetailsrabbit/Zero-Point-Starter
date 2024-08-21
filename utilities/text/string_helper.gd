class_name StringHelper

const ASCII_ALPHANUMERIC = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
const ASCII_LETTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const ASCII_LOWERCASE = "abcdefghijklmnopqrstuvwxyz"
const ASCII_UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const ASCII_DIGITS = "0123456789"
const ASCII_HEXDIGITS = "0123456789ABCDEF"
const ASCII_PUNCTUATION =  "!\"#$%&'()*+, -./:;<=>?@[\\]^_`{|}~"

static var random_number_generator := RandomNumberGenerator.new()

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


static func is_valid_url(url: String) -> bool:
	var regex = RegEx.new()
	var url_pattern = "/(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?\\/[a-zA-Z0-9]{2,}|((https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z]{2,}(\\.[a-zA-Z]{2,})(\\.[a-zA-Z]{2,})?)|(https:\\/\\/www\\.|http:\\/\\/www\\.|https:\\/\\/|http:\\/\\/)?[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}\\.[a-zA-Z0-9]{2,}(\\.[a-zA-Z0-9]{2,})?/g"
	regex.compile(url_pattern)
	
	return regex.search(url) != null
	
	
static func generate_random_string(length: int = 25, characters: String = ASCII_ALPHANUMERIC) -> String:
	var result := ""
	
	if(not characters.is_empty() && length > 0):
		for character in range(length):
			result += characters[random_number_generator.randi() % characters.length()]
			
	return result
	
## Converts PascalCaseString into pascal_case_string
static func camel_to_snake(camel_string: String) -> String:
	var snake_string := ""
	var previous_char := ""
	
	for c in camel_string:
		if c.to_upper() == c and previous_char != "" and previous_char.to_upper() != previous_char:
			snake_string += "_"
		snake_string += c.to_lower()
		previous_char = c
	
	return snake_string

## Converts pascal_case_string into PascalCaseString
static func snake_to_camel_case(screaming_snake_case: String) -> String:
	var words := screaming_snake_case.split("_")
	var camel_case := ""
	
	for i in range(words.size()):
		camel_case += words[i].capitalize()
	
	return camel_case

## Clean a string by removing characters that are not letters (uppercase or lowercase) or spaces, tabs or newlines.
static func clean(string: String) -> String:
	var regex = RegEx.new()
	regex.compile("[\\p{L} ]*")
	
	var result = ""
	var matches = regex.search_all(string)
	
	for m in matches:
		for s in m.strings:
			result += s
			
	return result

## This function wraps the provided text into multiple lines if it exceeds the specified max_line_length
static func wrap_text(text: String = "", max_line_length: int = 120):
	if text.is_empty() or text.length() <= max_line_length:
		return text
	else:
		var final_text := ""
		var words := text.split(" ")
		var current_line := ""
		
		for word: String in words:
			if current_line != "":
				if (current_line + word).length() + 1 > max_line_length:
					final_text += current_line + "\n"
					current_line = ""
				else:
					current_line += " "
					
			current_line += word
			
		final_text += current_line
		
		return final_text


static func integer_to_ordinal(number: int) -> String:
	var middle := number % 100
	var suffix := ""
	
	if middle >= 11 and middle <= 13:
		suffix = "th"
	else:
		suffix = {1: "st", 2: "nd", 3: "rd"}.get(number % 10, "th")
		
	return str(number) + suffix
	
	
static func pretty_number(number: float, suffixes: Array[String] = ["", "K", "M", "B", "T"]) -> String:
	var prefix_sign = "-" if sign(number) == -1 else ""
	
	number = absf(number)

	var exponent = 0

	while number >= 1000.0:
		number /= 1000.0  # Divide by 1000 for each exponent level
		exponent += 1

	# Round to one decimal place using snapped
	var formatted_number = str(snappedf(number, 0.001))

	return prefix_sign + formatted_number + suffixes[exponent]


static func to_binary_string(num: int) -> String:
	var binary_string := ""
	var number: = num
	
	while number > 0:
		binary_string = str(number & 1) + binary_string
		number = number >> 1
	
	return binary_string


static func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile("\\[.+?\\]")
	
	return regex.sub(source, "", true)


static func strip_filepaths(source: String) -> String:
	var regex = RegEx.new()
	regex.compile("res://([^ ])+")
	
	return regex.sub(source, "", true)

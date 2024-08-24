@tool
@icon("res://ui/narrative/text/label/auto_resize_label.svg")
class_name AutoResizeLabel extends Label


## If enabled, will resize the font until it matches the maximum font size or the size of the text container. 
@export var auto_size_enabled := true: set = set_autosize_enabled
## Specifies the minimum size auto-font is allowed to do.
@export var min_font_size := 16: set = set_min_font_size
## Specifies the maximum size auto-font is allowed to do.
@export var max_font_size := 64: set = set_max_font_size

var last_set_size := 0

func _ready():
	adjust_font_size()

# This function gets called whenever the size of the Label or its parent changes
func _notification(what: int):
	if what == NOTIFICATION_RESIZED:
		adjust_font_size()


func set_autosize_enabled(enabled: bool):
	if auto_size_enabled != enabled:
		auto_size_enabled = enabled
		adjust_font_size()


func set_min_font_size(new_value: int):
	if min_font_size != new_value:
		min_font_size = new_value
		adjust_font_size()


func set_max_font_size(new_value: int):
	if max_font_size != new_value:
		max_font_size = new_value
		adjust_font_size()


# This function gets called whenever a value is set.
func _set(property: StringName, value: Variant) -> bool:
	match property:
		"text":
			text = value
			adjust_font_size()
			return true
			
	return false


func set_font_size(size: int):
	if last_set_size == size:
		return
		
	last_set_size = size
	
	if label_settings:
		label_settings.set_font_size(size)
	else:
		add_theme_font_size_override("font_size", size)


func adjust_font_size():
	if not auto_size_enabled:
		return
		
	var font := get_theme_font("font") 

	var min_size := min_font_size
	var max_size := max_font_size
	
	while min_size <= max_size:
		var currentSize  := (min_size + max_size) / 2
		
		var textSize := font.get_multiline_string_size(text, 0, -1, currentSize)
		
		var max_horizontal = get_size().x
		var max_vertical = get_size().y - currentSize # subtract the currentSize to ensure the text vertically shrinks
		
		# Check if the text has exceeded the textbox box size
		if textSize.x > max_horizontal or textSize.y > max_vertical:
			max_size = currentSize - 1 	# If we exceed the size of the parent, reduce the max_size
		else:
			min_size = currentSize + 1
			
	# Set the font size to the last valid size
	set_font_size(max_size)	
	

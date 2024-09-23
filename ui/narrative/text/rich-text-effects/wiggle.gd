## A wiggle effect to achieve creepy effects on text or just waves as if underwater.
@tool
class_name RichTextWiggle extends RichTextEffect

var bbcode := "wiggle"

@export var rotate_angle := 0.1
@export var rotate_speed := 1.0
@export var gliph_rotate_offset := 0.1



func _process_custom_fx(char_fx: CharFXTransform):
	var angle = sin((char_fx.elapsed_time * rotate_speed) + float(gliph_rotate_offset * char_fx.relative_index)) * rotate_angle
	char_fx.transform = char_fx.transform.rotated_local(angle)
	
	return true

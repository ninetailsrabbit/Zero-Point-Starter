## Achieve a parallax effect when moving the mouse around the screen
## This was made to be a parent node and the rest of the nodes as a child to inherit this effect.
@icon("res://ui/effects/mouse_parallax.svg")
class_name MouseParallax extends Control


@export var max_offset := Vector2(12, 10)
@export var smoothing := 2.0


func _process(delta):
	var center: Vector2 = get_viewport_rect().size / 2.0
	var dist: Vector2 = get_global_mouse_position() - center
	var offset: Vector2 = dist / center
	
	var new_pos: Vector2
	
	new_pos.x = lerp(max_offset.x, -max_offset.x, offset.x)
	new_pos.y = lerp(max_offset.y, -max_offset.y, offset.y)
	
	position.x = lerp(position.x, new_pos.x, smoothing * delta)
	position.y = lerp(position.y, new_pos.y, smoothing * delta)

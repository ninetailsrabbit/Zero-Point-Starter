# This script it's to use on existing control nodes to debug them
@tool
@icon("res://ui/debug/control_visualizer.svg")
extends Control

@export_category("Visualize")
## This flag controls the view of the growth direction arrows.
@export var show_growth_direction := true:
	set(show):
		show_growth_direction = show
		_update_bounds()
## This flag controls the view of the anchor offsets for each edge.
@export var show_anchor_offsets := true:
	set(show):
		show_anchor_offsets = show
		_update_bounds()

## Class variable to track the full rect including the anchor's offsets.
var anchor_rect: Rect2

## We connect signals to track changes as a tool script on ready.
func _ready() -> void:
	minimum_size_changed.connect(_on_minimum_size_changed)
	resized.connect(_on_resized)
	size_flags_changed.connect(_on_size_flags_changed)
	item_rect_changed.connect(_on_item_rect_changed)
	
	
## The drawing behavior for the debug information.
func _draw() -> void:
	if show_anchor_offsets:
		var x1 = anchor_rect.position.x
		var x2 = anchor_rect.position.x + offset_left
		var y1 = anchor_rect.position.y + offset_top
		var y2 = anchor_rect.position.y + anchor_rect.size.y
		#Left Offset
		draw_line(Vector2(0, size.y / 2), Vector2(-offset_left, size.y / 2), Color.BLUE)
		draw_string(get_theme_default_font(),Vector2(-offset_left / 2, size.y / 2), \
		str(offset_left), HORIZONTAL_ALIGNMENT_FILL)
		#Right Offset
		draw_line(Vector2(size.x, size.y / 2), Vector2(size.x - offset_right, size.y / 2), Color.BLUE)
		draw_string(get_theme_default_font(),Vector2(size.x - (offset_right / 2), size.y / 2), \
		str(offset_right), HORIZONTAL_ALIGNMENT_FILL)
		#Top Offset
		draw_line(Vector2(size.x / 2, 0), Vector2(size.x / 2, -offset_top), Color.BLUE)
		draw_string(get_theme_default_font(),Vector2(size.x / 2, -offset_top / 2), \
		str(offset_top), HORIZONTAL_ALIGNMENT_FILL)
		#Bottom Offset
		draw_line(Vector2(size.x / 2, size.y), Vector2(size.x / 2, size.y -offset_bottom), Color.BLUE)
		draw_string(get_theme_default_font(),Vector2(size.x / 2, size.y -(offset_bottom / 2)), \
		str(offset_bottom), HORIZONTAL_ALIGNMENT_FILL)
	
	if show_growth_direction:
		#Draw Growth Directions
		match(grow_horizontal):
			GROW_DIRECTION_BEGIN:
				_draw_arrow(Vector2(0, 0), Vector2(-96, 0), Color.GREEN)
			GROW_DIRECTION_BOTH:
				_draw_arrow(Vector2(0, 0), Vector2(-96, 0), Color.GREEN)
				_draw_arrow(Vector2(size.x, 0), Vector2(size.x+96, 0), Color.GREEN)
			GROW_DIRECTION_END:
				_draw_arrow(Vector2(size.x, 0), Vector2(size.x+96, 0), Color.GREEN)
		match(grow_vertical):
			GROW_DIRECTION_BEGIN:
				_draw_arrow(Vector2(0, 0), Vector2(0, -96), Color.GREEN)
			GROW_DIRECTION_BOTH:
				_draw_arrow(Vector2(0, 0), Vector2(0, -96), Color.GREEN)
				_draw_arrow(Vector2(0, size.y), Vector2(0, size.y + 96), Color.GREEN)
			GROW_DIRECTION_END:
				_draw_arrow(Vector2(0, size.y), Vector2(0, size.y + 96), Color.GREEN)
		

## Updates changes to our full bounds, while also requesing to redraw.
func _update_bounds() -> void:
	anchor_rect = Rect2(\
	-offset_left, \
	-offset_top, \
	size.x - offset_right + offset_left, \
	size.y - offset_bottom + offset_top\
	)
	queue_redraw()


func _on_size_flags_changed() -> void:
	_update_bounds()


func _on_resized() -> void:
	_update_bounds()


func _on_minimum_size_changed() -> void:
	_update_bounds()


func _on_item_rect_changed() -> void:
	_update_bounds()


## Draws an arrow from the start and end position with a given color.
func _draw_arrow(start: Vector2, end: Vector2, color: Color = Color.BLACK) -> void:
	var tip_length = 16
	var angle = PI / 8
	var tip: Vector2 = start.direction_to(end) * tip_length
	#Draw Arrow Line
	draw_line(start, end, color)
	#Draw Tip Lines
	draw_line(end, end + tip.rotated(angle), color)
	draw_line(end, end + tip.rotated(-angle), color)

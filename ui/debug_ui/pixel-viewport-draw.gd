@tool
@icon("res://ui/debug/PixelViewportDrawing.svg")
class_name PixelViewportDrawing extends Node2D

@export var width := 640:
	set(value): 
		width = value 
		queue_redraw()
@export var height := 360:
	set(value): 
		height = value 
		queue_redraw()
@export var LineColor:Color = Color("00ffff64"):
	set(value): 
		LineColor = value 
		queue_redraw()
@export var LineWidth:float = 1.:
	set(value):
		LineWidth = value 
		queue_redraw()


func _ready() -> void:
	z_index = 100
	if !Engine.is_editor_hint(): queue_free()


func _draw() -> void:
	draw_rect(Rect2i(0,0, width, height), LineColor, false, LineWidth)

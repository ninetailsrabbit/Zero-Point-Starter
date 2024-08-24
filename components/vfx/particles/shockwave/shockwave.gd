@icon("res://components/vfx/particles/shockwave/shockwave.svg")
extends Node2D

## When autostart is true, once is instantiated into the scene tree it will be triggered
@export var autostart := true
## The shockwave color
@export var shockwave_color :=  Color.WHITE
## The outline color, only applies if outline parameter it's true
@export var outline_color :=  Color.BLACK
## Draw and outline on the shockwave
@export var outline := false
## The start radius of the shockwave circle
@export var start_radius := 10.0
## The end radius of the shockwave circle
@export var end_radius := 100.0
## The start circle width of the shockwave
@export var start_width := 6.0
## The end circle width of the shockwave when reachs the expansion
@export var end_width := 0.2
## The arc points to draw, more points more detailed arc circle
@export var arc_points := 24
## the speed at which the shockwave expands, higher values slow it down
@export var expand_time := 1.0


var timescale := 1.0
var timer := 0.0
var size := 1.0
var sizeT := 1.0 ## Intermediate value used in the code to control the animation of the shockwave's size 


func _ready():
	size = start_radius
	set_process(autostart)


func _process(delta):
	delta *= timescale
	timer += 1.0 / expand_time * delta
	
	if timer >= 1.0:
		queue_free()
		
	sizeT = TorCurve.run(timer, 1.5, 0.0, 1.0)
	size = lerp(start_radius, end_radius, sizeT)
	
	queue_redraw()
	

func spawn():
	set_process(true)
	
	
func _draw():
	var smoothness_factor = lerp(start_width, end_width, sizeT)
	
	if outline:
		draw_arc(Vector2.ZERO, size, 0.0, TAU, arc_points, outline_color * Color(0, 0, 0, 1.0 - pow(sizeT, 4.0) ), min(smoothness_factor + 8.0, smoothness_factor * 4.0), false)
	draw_arc(Vector2.ZERO, size, 0.0, TAU, arc_points, shockwave_color * Color(1.0, 1.0, 1.0, 1.0 - pow(sizeT, 4.0) ), smoothness_factor, false)

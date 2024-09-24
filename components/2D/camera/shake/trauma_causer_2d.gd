@icon("res://assets/node_icons/trauma_causer.svg")
class_name TraumaCauser2D extends Area2D

@export_range(0, 1, 0.01) var trauma_amount := 0.5

func _ready():
	monitoring = true
	monitorable = false
	collision_layer = 0
	collision_mask = GameGlobals.shakeables_collision_layer


func cause_trauma():
	for trauma_detector: TraumaDetector2D in get_overlapping_areas().filter(func(area): return area is TraumaDetector2D):
		trauma_detector.add_trauma(trauma_amount)

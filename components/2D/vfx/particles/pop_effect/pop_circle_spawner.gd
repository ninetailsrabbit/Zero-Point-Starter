@icon("res://assets/node_icons/pop-effect.svg")
class_name PopCircleSpawner extends Node2D

signal spawn_finished

const POP_CIRCLE = preload("res://components/2D/vfx/particles/pop_effect/pop.tscn")

@export var amount_of_circles := 25
@export var autostart := true


func _ready():
	if autostart:
		spawn()


func spawn():
	for i in range(amount_of_circles):
		add_child(POP_CIRCLE.instantiate() as PopCircleEffect)

	spawn_finished.emit()

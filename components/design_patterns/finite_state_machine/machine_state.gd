@icon("res://components/design_patterns/finite_state_machine/state_icon.png")
class_name MachineState extends Node

signal entered
signal finished(next_state: MachineState)

var FSM: FiniteStateMachine


func ready() -> void:
	pass


func enter() -> void:
	pass
	

func exit(_next_state: MachineState) -> void:
	pass
	

func handle_input(_event: InputEvent):
	pass


func physics_update(_delta):
	pass
	
	
func update(_delta):
	pass
	

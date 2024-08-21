extends Node


func _ready() -> void:
	GlobalEffects.fade_in()
	
	await GlobalEffects.fade_finished
	
	GlobalEffects.fade_out()
	

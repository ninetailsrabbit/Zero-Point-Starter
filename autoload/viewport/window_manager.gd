extends Node


func _enter_tree() -> void:
	get_tree().root.size_changed.connect(on_size_changed)
	
	
func on_size_changed() -> void:
	ViewportHelper.center_window_position(get_viewport())

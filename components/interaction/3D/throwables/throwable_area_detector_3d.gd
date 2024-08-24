class_name ThrowableAreaDetector3D extends Area3D


func _enter_tree() -> void:
	collision_layer = 0
	collision_mask = GameGlobals.throwables_collision_layer
	monitorable = false
	monitoring = true
	priority = 2

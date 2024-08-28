@icon("res://components/camera/3D/shake/shake_camera_3d.svg")
class_name CameraShake3D extends Camera3D

@export var shake_time: float = 1.3
@export var magnitude: float = 0.05


func trauma(_shake_time: float = shake_time, _magnitude: float = magnitude):
	var initial_transform = self.transform 
	var elapsed_time = 0.0

	while elapsed_time < _shake_time:
		var offset = Vector3(
			randf_range(-_magnitude, _magnitude),
			randf_range(-_magnitude, _magnitude),
			0.0
		)

		self.transform.origin = initial_transform.origin + offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame

		self.transform = initial_transform

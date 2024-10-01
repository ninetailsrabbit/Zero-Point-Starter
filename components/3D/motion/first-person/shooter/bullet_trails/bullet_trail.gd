class_name BulletTrail extends MeshInstance3D

@export var bullet_trail_max_distance: float = 0.0
@export var bullet_trail_life_time: float = 0.5
@export var bullet_trail_speed: float = 100.0

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = bullet_trail_life_time
	timer.one_shot = true
	timer.autostart = true
	
	if bullet_trail_max_distance == 0:
		timer.timeout.connect(on_timeout)
		
	top_level = true
		

func _process(delta: float) -> void:
	position += Camera3DHelper.forward_direction(get_viewport().get_camera_3d()) * bullet_trail_speed * delta

	if bullet_trail_max_distance > 0 and global_position.distance_to(global_position) >= (bullet_trail_max_distance - (mesh.height * 2)):
		queue_free()
	

func on_timeout() -> void:
	queue_free()

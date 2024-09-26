class_name MuzzleFlash extends GPUParticles3D

@export var particle_lifetime: float = 0.03
@export var min_size: Vector2 = Vector2(0.05, 0.05)
@export var max_size: Vector2 = Vector2(0.35, 0.35)
@export var emit_on_ready: bool = true

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = particle_lifetime
	timer.timeout.connect(on_timeout)
	
	if emit_on_ready:
		emit()
	
	
func emit(
	emission_lifetime: float = particle_lifetime, 
	min_particle_size: Vector2 = min_size,
 	max_particle_size: Vector2 = max_size
) -> void:
	lifetime = emission_lifetime
	draw_pass_1.size = Vector2(randf_range(min_particle_size.x, max_particle_size.x), randf_range(min_particle_size.y, max_particle_size.y))
	one_shot = true
	emitting = true
	
	timer.start(lifetime)


func on_timeout() -> void:
	queue_free()

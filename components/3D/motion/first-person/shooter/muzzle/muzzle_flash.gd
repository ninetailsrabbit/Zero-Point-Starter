### Recommended muzzle light colors
## Warm colors
# Bright orange: #FF8C00
# Golden yellow: #FFD700
# Fiery red: #FF5733
# Hot pink: #FF69B4

## Cold colors
# Electric blue: #00FFFF
# Icy blue: #87CEEB
#Lime green: #00FF00
# Purple haze: #800080

## Neutral colors
# Classic white: #FFFFFF
# Neutral gray: #808080
# Dark brown: #8B4513
# Olive green: #6B8E23
###
class_name MuzzleFlash extends GPUParticles3D

@export_group("Muzzle particle")
@export var particle_lifetime: float = 0.03
@export var min_size: Vector2 = Vector2(0.05, 0.05)
@export var max_size: Vector2 = Vector2(0.35, 0.35)
@export var emit_on_ready: bool = true
@export var texture: Texture2D = preload("res://assets/muzzle/muzzle_flash_texture.png")
@export_group("Muzzle light")
@export var spawn_light: bool = true
@export_range(0, 16, 0.1) var min_light_energy: float = 1.0
@export_range(0, 16, 0.1) var max_light_energy: float = 1.0
@export var use_integers: bool = false
@export var light_color: Color = Color("FFD700")

@onready var timer: Timer = $Timer
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

@onready var muzzle_material: StandardMaterial3D = (draw_pass_1 as QuadMesh).surface_get_material(0)


func _ready() -> void:
	timer.autostart = false
	timer.one_shot = true
	timer.wait_time = particle_lifetime
	timer.timeout.connect(on_timeout)
	
	if texture and muzzle_material:
		muzzle_material.albedo_texture = texture
	
	if omni_light_3d:
		if spawn_light:
			omni_light_3d.light_energy = randf_range(min_light_energy, max_light_energy)
			
			if use_integers:
				omni_light_3d.light_energy = ceil(omni_light_3d.light_energy)
				
			omni_light_3d.light_color = light_color
			omni_light_3d.show()
		else:
			omni_light_3d.hide()
			
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

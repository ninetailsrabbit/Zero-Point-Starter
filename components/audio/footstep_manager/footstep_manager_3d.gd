@icon("res://components/audio/footstep_manager/footstep_manager_3d.svg")
class_name FootstepManager3D extends Node3D

@export var floor_detector_raycast: RayCast3D
@export var default_interval_time: float = 0.6
@export var use_pitch: bool = true
@export var min_pitch_range : float = 0.9
@export var max_pitch_range: float = 1.3


var sounds_material := {}:
	set(value):
		if not value.is_empty():
			_prepare_sounds(value)
		
		sounds_material = value
		
var interval_timer: Timer
var sfx_playing := false


func _ready():
	assert(floor_detector_raycast is RayCast3D, "FoostepManager: This node needs a raycast to detect the ground material")
	
	if sounds_material.is_empty():
		push_error("FootstepManager: The sounds material dictionary does not have any key/value to map the material group to a sound")

	_create_interval_timer()
	_prepare_sounds(sounds_material)
	
	
func footstep_by_floor_material(interval: float = default_interval_time):
	if not sounds_material.is_empty() and not sfx_playing and is_instance_valid(interval_timer) and interval_timer.is_stopped() and floor_detector_raycast.is_colliding():
		var collider = floor_detector_raycast.get_collider()
		
		if collider is StaticBody3D or collider is Area3D:
			var groups = collider.get_groups()
			
			if groups.size() > 0:
				if sounds_material.has(groups[0]):
					var audio_stream_player = sounds_material[groups[0]]
					
					footstep(audio_stream_player)
					


func footstep(audio_stream_player, interval: float = default_interval_time):
	if audio_stream_player is SoundQueue:
		if use_pitch:
			audio_stream_player.play_sound_with_pitch_range(min_pitch_range, max_pitch_range)
		else:
			audio_stream_player.play_sound()
			
		interval_timer.start(interval)
		sfx_playing = true
		
	if audio_stream_player is AudioStreamPlayer or audio_stream_player is AudioStreamPlayer3D:
		if use_pitch:
			audio_stream_player.pitch_scale = randf_range(min_pitch_range, max_pitch_range)
		else:
			audio_stream_player.pitch_scale = 1.0
			
		audio_stream_player.play()
		interval_timer.start(interval)
		sfx_playing = true


func _prepare_sounds(data: Dictionary = sounds_material):
	for group in data.keys():
		if data[group] is AudioStream:
			var sound_queue = SoundQueue.new()
			var audio_stream_player = AudioStreamPlayer3D.new()
			audio_stream_player.stream = data[group]
			sound_queue.add_child(audio_stream_player)
			add_child(sound_queue)
			data[group] = sound_queue


func _create_interval_timer():
	if interval_timer == null:
		interval_timer = Timer.new()
		interval_timer.name = "FoostepIntervalTimer"
		interval_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		interval_timer.autostart = false
		interval_timer.one_shot = true
		
		add_child(interval_timer)
		interval_timer.timeout.connect(on_interval_timer_timeout)


func on_interval_timer_timeout():
	sfx_playing = false

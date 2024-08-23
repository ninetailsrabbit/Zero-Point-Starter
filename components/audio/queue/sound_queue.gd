@tool
@icon("res://components/audio/queue/sound_queue_icon.svg")
class_name SoundQueue extends Node

@export var queue_count := 2:
	set(value):
		queue_count = max(2, value)

var next := 0
var audiostream_players := []

func _get_configuration_warnings():
	if get_child_count() == 0:
		return ["No children found. Expected AudioStreamPlayer/2D/3D child."]
	
	var audio_stream_player_found := false
	
	for child in get_children():
		audio_stream_player_found = child is AudioStreamPlayer or child is AudioStreamPlayer2D or child is AudioStreamPlayer3D
		if audio_stream_player_found:
			break
	
	if not audio_stream_player_found:
		return ["Expected child to be an AudioStreamPlayer/2D/3D"]
	
	return []


func _ready():
	if(get_child_count() == 0):
		push_error("SoundQueue: No AudioStreamPlayer child found.")
		return
		
	var child = get_child(0)
	
	if(child is AudioStreamPlayer or child is AudioStreamPlayer2D or child is AudioStreamPlayer3D):
		audiostream_players.append(child)
		
		for index in range(queue_count):
			var duplicated_player = child.duplicate()
			add_child(duplicated_player)
			audiostream_players.append(duplicated_player)


func play_sound():
	if audiostream_players.is_empty():
		return
		
	if not audiostream_players[next].playing:
		next += 1
		audiostream_players[next].play()
		next %= audiostream_players.size() - 1
		

func play_sound_with_pitch_range(min_pitch_scale: float = 0.9, max_pitch_scale: float = 1.3):
	if audiostream_players.is_empty():
		return
		
	if not audiostream_players[next].playing:
		next += 1
		var next_audio_stream_player = audiostream_players[next]
		next_audio_stream_player.pitch_scale = randf_range(min_pitch_scale, max_pitch_scale)
		next_audio_stream_player.play()
		next %= audiostream_players.size() - 1


func play_sound_with_ease(duration: float = 1.0):
	if audiostream_players.is_empty():
		return
		
	if not audiostream_players[next].playing:
		next += 1
		var audio_player = audiostream_players[next]
		audio_player.volume_db = MusicManager.VolumeDBInaudible
		
		var tween = create_tween()
		tween.tween_property(audio_player,"volume_db", 0.0 , max(0.1, absf(duration)))\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(func(): audio_player.play())
		
		next %= audiostream_players.size() - 1


func play_sound_with_ease_and_pitch_range(duration: float = 1.0, min_pitch_scale: float = 0.9, max_pitch_scale: float = 1.3):
	if audiostream_players.is_empty():
		return
		
	if not audiostream_players[next].playing:
		next += 1
		var audio_player = audiostream_players[next]
		audio_player.volume_db = MusicManager.VolumeDBInaudible
		
		var tween = create_tween()
		tween.tween_property(audio_player,"volume_db", 0.0 , max(0.1, absf(duration)))\
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(
			func(): 
				audio_player.pitch_scale = randf_range(min_pitch_scale, max_pitch_scale)
				audio_player.play()
				)
		
		next %= audiostream_players.size() - 1

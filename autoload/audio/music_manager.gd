extends Node

signal added_music_to_bank(_name: String, stream: AudioStream)
signal removed_music_from_bank(_name: String)
signal changed_stream(from: AudioStream, to: AudioStream)
signal started_stream(audio_stream_player: AudioStreamPlayer, new_stream: AudioStream)
signal finished_stream(audio_stream_player: AudioStreamPlayer, old_stream: AudioStream)

const VolumeDBInaudible := -80.0

## Dictionary<string, AudioStream>
var music_bank := {}
var main_audio_stream_player: AudioStreamPlayer
var secondary_audio_stream_player: AudioStreamPlayer
var current_audio_stream_player: AudioStreamPlayer

var crossfade_time := 2.0


func _ready():
	_create_audio_stream_players()
	

func play_music(stream_name: String, crossfade: bool = true, crossfading_time: float = crossfade_time):
	if music_bank.has(stream_name):
		var stream := music_bank[stream_name] as AudioStream
		
		if current_audio_stream_player.is_playing():
			if current_audio_stream_player.stream == stream:
				return
				
			if crossfade:
				var next_audio_stream_player := secondary_audio_stream_player if current_audio_stream_player.name == "MainAudioStreamPlayer" else main_audio_stream_player
				next_audio_stream_player.volume_db = VolumeDBInaudible
				play_stream(next_audio_stream_player, stream)
				
				var volume := linear_to_db(AudioManager.get_actual_volume_db_from_bus_name(next_audio_stream_player.bus))
				
				var crossfade_tween = create_tween()
				crossfade_tween.set_parallel(true)
				crossfade_tween.tween_property(current_audio_stream_player, "volume_db", VolumeDBInaudible, crossfading_time).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_LINEAR)
				crossfade_tween.tween_property(next_audio_stream_player, "volume_db", volume, crossfading_time).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
				crossfade_tween.chain().tween_callback(func(): current_audio_stream_player = next_audio_stream_player)

				return
				
		changed_stream.emit(current_audio_stream_player.stream, stream)
		play_stream(current_audio_stream_player, stream)
		return
	
	push_warning("MusicManager: Expected music name %s to exists in the MusicBank but no stream was found" % stream_name)
		
	
func play_stream(player: AudioStreamPlayer, stream: AudioStream):
	player.stop()
	player.stream = stream
	player.play()
	
	started_stream.emit(player, stream)
	
	
func add_streams_to_music_bank(stream_names: Array[String], stream: AudioStream):
	for stream_name: String in stream_names:
		add_stream_to_music_bank(stream_name, stream)


func add_stream_to_music_bank(stream_name: String, stream: AudioStream):
	music_bank[stream_name] = stream
	added_music_to_bank.emit(stream_name, stream)
	

func remove_stream_from_music_bank(stream_name: String):
	if music_bank.has(stream_name):
		music_bank.erase(stream_name)
		removed_music_from_bank.emit(stream_name)


func remove_streams_from_music_bank(stream_names: Array[String]):
	for stream_name: String in stream_names:
		remove_stream_from_music_bank(stream_name)


func _create_audio_stream_players():
	main_audio_stream_player = AudioStreamPlayer.new()
	main_audio_stream_player.name = "MainAudioStreamPlayer"
	main_audio_stream_player.bus = "Music"
	main_audio_stream_player.autoplay = false
	
	secondary_audio_stream_player = AudioStreamPlayer.new()
	secondary_audio_stream_player.name = "SecondaryAudioStreamPlayer"
	secondary_audio_stream_player.bus = "Music"
	secondary_audio_stream_player.autoplay = false
	
	current_audio_stream_player = main_audio_stream_player
	
	add_child(main_audio_stream_player)
	add_child(secondary_audio_stream_player)
	
	main_audio_stream_player.finished.connect(on_finished_audio_stream_player.bind(main_audio_stream_player))
	secondary_audio_stream_player.finished.connect(on_finished_audio_stream_player.bind(secondary_audio_stream_player))


func on_finished_audio_stream_player(audio_stream_player: AudioStreamPlayer):
	finished_stream.emit(audio_stream_player, audio_stream_player.stream)

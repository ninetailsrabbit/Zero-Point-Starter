extends Node


var stream_players_pool: Array[AudioStreamPlayer] = []
var pool_players_number := 32:
	set(value):
		pool_players_number = max(1, value)
		setup_pool()


func _ready():
	setup_pool()


func setup_pool():
	stream_players_pool.clear()
	
	if is_inside_tree():
		NodeRemover.queue_free_children(self)
	
	for i in range(pool_players_number):
		var stream_player = AudioStreamPlayer.new()
		stream_player.name = "PoolAudioStreamPlayer%d" % (i + 1)
		stream_players_pool.append(stream_player)
		add_child(stream_player)


func play(stream: AudioStream, bus: String = "SFX", volume: float = 1.0):
	if AudioManager.is_muted(bus) or not AudioManager.bus_exists(bus):
		return
		
	var available_stream_player = _next_available_stream_player()
	
	if available_stream_player:
		available_stream_player.stream = stream
		available_stream_player.bus = bus
		available_stream_player.volume_db = linear_to_db(volume)
		available_stream_player.play()


func play_with_pitch(stream: AudioStream, bus: String = "SFX", volume: float = 1.0, min_pitch_scale: float = 0.9, max_pitch_scale: float = 1.3):
	if AudioManager.is_muted(bus) or not AudioManager.bus_exists(bus):
		return
		
	var available_stream_player = _next_available_stream_player()
	
	if available_stream_player:
		available_stream_player.stream = stream
		available_stream_player.bus = bus
		available_stream_player.volume_db = linear_to_db(volume)
		available_stream_player.pitch_scale = randf_range(min_pitch_scale, max_pitch_scale)
		available_stream_player.play()


func play_random_stream(streams: Array[AudioStream] = [], bus: String = "SFX", volume: float = 1.0):
	if streams.is_empty() or AudioManager.is_muted(bus) or not AudioManager.bus_exists(bus):
		return
		
	play(streams.pick_random(), bus, volume)


func play_random_stream_with_pitch(streams: Array[AudioStream] = [], bus: String = "SFX", volume: float = 1.0, min_pitch_scale: float = 0.9, max_pitch_scale: float = 1.3):
	if streams.is_empty() or AudioManager.is_muted(bus) or not AudioManager.bus_exists(bus):
		return
		
	play_with_pitch(streams.pick_random(), bus, volume, min_pitch_scale, max_pitch_scale)


func stop_streams_from_bus(bus: String = "SFX"):
	if not AudioManager.bus_exists(bus):
		return
		
	for player: AudioStreamPlayer in stream_players_pool:
		if player.bus.to_lower() == bus.to_lower():
			player.stop()


func stop_streams_from_buses(buses: Array[String] = ["SFX"]):
	for bus in buses:
		stop_streams_from_bus(bus)


func _next_available_stream_player() -> AudioStreamPlayer:
	var available_players = stream_players_pool.filter(
		func(player: AudioStreamPlayer): 
			return not player.playing and not player.stream_paused
	)
	
	return null if available_players.is_empty() else available_players.front()

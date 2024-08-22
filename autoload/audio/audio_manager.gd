extends Node

@onready var available_buses: Array = enumerate_available_buses()

const MASTER_BUS_INDEX = 0

static var default_audio_volumes := {
	"master": 0.9,
	"music": 0.8,
	"sfx": 0.9,
	"echosfx": 0.9,
	"voice": 0.8,
	"ui": 0.7,
	"ambient": 0.9
}

func reset_to_default_volumes() -> void:
	for bus: String in available_buses:
		change_volume(bus, default_audio_volumes[bus.to_lower()])
		
func get_default_volume_for_bus(bus) -> float:
	if typeof(bus) == TYPE_INT:
		bus = AudioServer.get_bus_name(bus)
		
	return default_audio_volumes[bus.to_lower()]
	
## Change the volume of selected bus_index if it exists
## Can receive the bus parameter as name or index
func change_volume(bus, volume_value: float) -> void:
	var bus_index = get_bus(bus)
	
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume_value))

## Get the actual linear value from the selected bus by name
func get_actual_volume_db_from_bus_name(bus_name: String) -> float:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	
	if bus_index == -1:
		push_error("AudioManager: Cannot retrieve volume for bus name {name}, it does not exists".format({"name": bus_name}))
		return 0.0
		
	return get_actual_volume_db_from_bus_index(bus_index)

## Get the actual linear value from the selected bus by its index
func get_actual_volume_db_from_bus_index(bus_index: int) -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(bus_index))

## Get a list of available buses by name
func enumerate_available_buses() -> Array:
	return range(AudioServer.bus_count).map(func(bus_index: int): return AudioServer.get_bus_name(bus_index))


func is_stream_looped(stream: AudioStream) -> bool:
	if stream is AudioStreamMP3 || stream is AudioStreamOggVorbis:
		return stream.loop
		
	if stream is AudioStreamWAV:
		return stream.loop_mode == AudioStreamWAV.LOOP_DISABLED
		
	return false


func is_muted(bus = MASTER_BUS_INDEX) -> bool:
	return AudioServer.is_bus_mute(get_bus(bus))
	
	
func mute_bus(bus, mute_flag: bool = true) -> void:
	AudioServer.set_bus_mute(get_bus(bus), mute_flag)


func mute_all_buses() -> void:
	for bus: String in enumerate_available_buses():
		mute_bus(bus)

func unmute_all_buses() -> void:
	for bus: String in enumerate_available_buses():
		mute_bus(bus, false)


func get_bus(bus) -> int:
	var bus_index = bus
	
	if typeof(bus_index) == TYPE_STRING:
		bus_index = AudioServer.get_bus_index(bus)
		
		if bus_index == -1:
			push_error("AudioManager mute_bus(): -> The bus with the name %s does not exists in this project" % bus)
			
	return bus_index
	

func bus_exists(bus_name: String) -> bool:
	return bus_name in available_buses

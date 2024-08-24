class_name DialogueDisplayer extends Control

signal dialogue_display_started(dialogue: DialogueBlock)
signal dialogue_display_finished(dialogue: DialogueBlock)
signal dialogue_blocks_started_to_display(dialogue_blocks: Array[DialogueBlock])
signal dialogue_blocks_finished_to_display()

@export var static_display: bool = false
@export var auto_type_can_be_skipped: bool = false
@export var manual_dialogue_transition: bool = false
@export var use_type_sounds: bool = false
@export var time_between_dialogue_blocks: float = 1.0
@export var input_actions_to_transition: Array[String] = ["ui_accept"]

@onready var auto_typed_text: AutoTypedText = %AutoTypedText
@onready var voice_stream_player: AudioStreamPlayer = $VoiceStreamPlayer
@onready var between_blocks_timer: Timer = $BetweenBlocksTimer

enum DialogueState {
	WaitingForInput,
	Displaying,
	Neutral
}

var dialogue_blocks: Array[DialogueBlock] = []
var current_dialogue_block: DialogueBlock
var current_dialogue_state: DialogueState =  DialogueState.Neutral
var is_displaying: bool = false:
	set(value):
		if value != is_displaying:
			is_displaying = value
			current_dialogue_state = DialogueState.Displaying if is_displaying else DialogueState.Neutral


func _input(event: InputEvent) -> void:
	if manual_dialogue_transition and current_dialogue_state == DialogueState.WaitingForInput \
		and InputHelper.is_any_action_just_pressed(event, input_actions_to_transition) and not auto_typed_text.is_skipped:
			display_next_dialogue_block()
			
	if auto_type_can_be_skipped and auto_typed_text.is_skipped:
		auto_typed_text.is_skipped = false


func _ready() -> void:
	voice_stream_player.bus = "Voice"
	
	between_blocks_timer.wait_time = time_between_dialogue_blocks
	between_blocks_timer.autostart = false
	between_blocks_timer.one_shot = true
	between_blocks_timer.timeout.connect(on_between_blocks_timer_timeout)
	
	auto_typed_text.use_type_sounds = use_type_sounds
	auto_typed_text.manual_start = false
	auto_typed_text.can_be_skipped = auto_type_can_be_skipped
	auto_typed_text.skipped.connect(on_dialogue_skipped)
	auto_typed_text.display_finished.connect(on_dialogue_finished)
	
	dialogue_blocks_finished_to_display.connect(on_dialogue_blocks_finished_to_display)
	GlobalGameEvents.dialogues_requested.connect(on_dialogues_requested)
	
	load_dialogue_blocks([
		DialogueBlock.new("1", "Captain", "TU PUTA MADRE EN BRAGAS"),
		DialogueBlock.new("2", "Captain", "TU PUTISIMA MADRE EN BRAGAS"),
	])


func load_dialogue_blocks(new_dialogue_blocks: Array[DialogueBlock] = []) -> void:
	var previous_dialogue_blocks_count = dialogue_blocks.size()
	
	dialogue_blocks.append_array(new_dialogue_blocks)
	dialogue_blocks.assign(ArrayHelper.remove_duplicates(dialogue_blocks))
	
	if previous_dialogue_blocks_count == 0 and dialogue_blocks.size() > 0:
		is_displaying = true
		
		dialogue_blocks_started_to_display.emit(dialogue_blocks)
		GlobalGameEvents.dialogue_blocks_started_to_display.emit(dialogue_blocks)
	
	if current_dialogue_block == null and dialogue_blocks.size() > 0:
		show()
		display_next_dialogue_block()
	
	
	
func display_next_dialogue_block() -> void:
	if dialogue_blocks.is_empty():
		
		if current_dialogue_block:
			dialogue_blocks_finished_to_display.emit()
			GlobalGameEvents.dialogue_blocks_finished_to_display.emit()
			
		return

	var next_dialogue: DialogueBlock = dialogue_blocks.pop_front() as DialogueBlock
	
	if current_dialogue_block:
		dialogue_display_finished.emit(current_dialogue_block)
		GlobalGameEvents.dialogue_display_finished.emit(current_dialogue_block)
	
	current_dialogue_state = DialogueState.Displaying
	current_dialogue_block = next_dialogue
	
	dialogue_display_started.emit(current_dialogue_block)
	GlobalGameEvents.dialogue_display_started.emit(current_dialogue_block)
	
	if next_dialogue.voice_stream:
		voice_stream_player.stream = next_dialogue.voice_stream
		voice_stream_player.play()
		
	if next_dialogue.auto_type:
		auto_typed_text.reload_text(tr(next_dialogue.text))
	else:
		auto_typed_text.text = tr(next_dialogue.text)
		auto_typed_text.display_finished.emit()
	

func on_dialogue_skipped() -> void:
		voice_stream_player.stop()
		
		if manual_dialogue_transition:
			current_dialogue_state = DialogueState.WaitingForInput
	
	
func on_dialogue_finished() -> void:
	if voice_stream_player.playing and not AudioManager.is_stream_looped(voice_stream_player.stream):
		await voice_stream_player.finished
		
	if manual_dialogue_transition:
		current_dialogue_state = DialogueState.WaitingForInput
	else:
		between_blocks_timer.start()
	

func on_dialogue_blocks_finished_to_display() -> void:
	current_dialogue_block = null
	between_blocks_timer.stop()
	is_displaying = false
	
	auto_typed_text.clear()
	hide()
	

func on_dialogues_requested(new_dialogue_blocks: Array[DialogueBlock]) -> void:
	load_dialogue_blocks(new_dialogue_blocks)


func on_between_blocks_timer_timeout() -> void:
	display_next_dialogue_block()
	
	
class DialogueBlock:
	var id: String
	var speaker: String
	var text: String
	var auto_type: bool
	var voice_stream: AudioStream
	
	func _init(_id: String, _speaker: String, _text:String, _auto_type:bool = true, _voice_stream: AudioStream = null ) -> void:
		id = _id
		speaker = _speaker
		text = _text
		auto_type = _auto_type
		voice_stream = _voice_stream

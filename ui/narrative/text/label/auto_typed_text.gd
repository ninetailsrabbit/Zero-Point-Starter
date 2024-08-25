class_name AutoTypedText extends RichTextLabel

signal skipped
signal display_finished

const bbcode_start_flag = '['
const bbcode_end_flag = ']'

@export var content_to_display: String
@export var manual_start := false
@export var can_be_skipped := true
@export var input_actions_to_start := ["ui_accept"]
@export var input_actions_to_skip := ["ui_accept"]
@export var letter_time := 0.03
@export var space_time := 0.06
@export var punctuation_time := 0.2
@export var use_type_sounds: bool = false

@onready var type_sound_queue: SoundQueue = $SoundQueue

var letter_index = -1
var typing_timer: Timer

var current_bbcode := ""
var bbcode_flag = false

var is_typing := false
var is_skipped := false
var typing_finished := false


func _input(event: InputEvent):
	if not typing_finished:
		if is_typing:
			if can_be_skipped and InputHelper.is_any_action_just_pressed(event, input_actions_to_start):
				skip()
		else:
			if manual_start and InputHelper.is_any_action_just_pressed(event, input_actions_to_start):
				display_letters()
			

func _ready():
	_create_typing_timer()
	
	bbcode_enabled = true
	fit_content = true

	display_finished.connect(on_finished_display)
	
	
				
func display_letters():
	if(typing_finished):
		return
	
	letter_index += 1
	
	if letter_index > content_to_display.length() - 1:
		display_finished.emit()
		return
		
	is_typing = true
	
	var next_character: String = content_to_display[letter_index]
		
	if not bbcode_flag && next_character == bbcode_start_flag:
		typing_timer.stop()
		bbcode_flag = true
	
	if bbcode_flag:
		current_bbcode += next_character
		bbcode_flag = next_character != bbcode_end_flag
		display_letters()
		return
	else:
		if current_bbcode.length() > 0:
			text += current_bbcode + next_character
			current_bbcode = ""
			display_letters()
			return
	
	play_typing_sound()
	
	text += next_character
	
	if letter_index <= content_to_display.length() - 1:
		var current_character: String = content_to_display[letter_index]
		
		if StringHelper.is_whitespace(current_character):
			typing_timer.start(space_time)
		elif StringHelper.AsciiPunctuation.contains(current_character):
			typing_timer.start(punctuation_time)
		else:
			typing_timer.start(letter_time)


func reload_text(new_text: String) -> void:
	if not is_typing:
		set_process_input(true)
		text = ""
		
		content_to_display = new_text
		typing_finished = false
		is_skipped = false
		display_letters()


func skip():
	if is_typing:
		text = ""
		content_to_display = ""
		letter_index = -1
		is_typing = false
		typing_finished = false
		is_skipped = true
		
		set_process_input(false)
		append_text(content_to_display)
		
		skipped.emit()


func play_typing_sound() -> void:
	if use_type_sounds and is_instance_valid(type_sound_queue):
		type_sound_queue.play_sound_with_pitch_range(1.0, 1.2)


func _create_typing_timer():
	if typing_timer:
		return
		
	typing_timer = Timer.new()
	typing_timer.name = "TypingTimer"
	typing_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	typing_timer.one_shot = true
	typing_timer.autostart = false
	
	add_child(typing_timer)
	typing_timer.timeout.connect(on_typing_timer_timeout)


func on_typing_timer_timeout():
	display_letters()


func on_finished_display():
	letter_index = -1
	content_to_display = ""
	is_typing = false
	typing_finished = true
	
	set_process_input(false)
	
	if is_instance_valid(typing_timer):
		typing_timer.stop()
		
	if is_instance_valid(type_sound_queue):
		type_sound_queue.stop_sounds()

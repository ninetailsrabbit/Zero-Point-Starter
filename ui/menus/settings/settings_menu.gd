@icon("res://ui/menus/settings/settings.svg")
extends Control


@onready var back_button: Button = %BackButton
@onready var mute_audio_buses_check_button: CheckButton = %MuteAudioBusesCheckButton


func _ready() -> void:
	back_button.pressed.connect(on_back_button_pressed)
	mute_audio_buses_check_button.toggled.connect(on_mute_audio_buses_pressed)
	
	audio_volumes_from_settings()


func audio_volumes_from_settings() -> void:
	for slider:AudioHorizontalSlider in NodeTraversal.get_all_children(self).filter(func(node): return node is AudioHorizontalSlider):
		slider.value = AudioManager.get_actual_volume_db_from_bus(slider.target_bus)


func on_mute_audio_buses_pressed(mute_pressed: bool) -> void:
	if(mute_pressed):
		AudioManager.mute_all_buses()
	else:
		AudioManager.unmute_all_buses()
		
	SettingsHandler.update_audio_section("muted", true)


func on_back_button_pressed() -> void:
	if owner:
		hide()

@icon("res://assets/node_icons/settings.svg")
extends Control


@onready var audio_tab_bar: TabBar = %Audio
@onready var screen_tab_bar: TabBar = %Screen
@onready var graphics_tab_bar: TabBar = %Graphics
@onready var general_tab_bar: TabBar = %General
@onready var controls_tab_bar: TabBar = %Controls
@onready var back_button: Button = %BackButton
@onready var mute_audio_buses_check_button: CheckButton = %MuteAudioBusesCheckButton


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		if is_node_ready():
			prepare_tab_bars()


func _ready() -> void:
	back_button.pressed.connect(on_back_button_pressed)
	mute_audio_buses_check_button.toggled.connect(on_mute_audio_buses_pressed)
	
	prepare_tab_bars()
	audio_volumes_from_settings()


func prepare_tab_bars() -> void:
	audio_tab_bar.name = tr(TranslationKeys.AudioTabTranslationKey)
	screen_tab_bar.name = tr(TranslationKeys.ScreenTabTranslationKey)
	graphics_tab_bar.name = tr(TranslationKeys.GraphicsQualityTranslationKey)
	general_tab_bar.name = tr(TranslationKeys.GeneralTabTranslationKey)
	controls_tab_bar.name = tr(TranslationKeys.ControlsTabTranslationKey)
	
	
func audio_volumes_from_settings() -> void:
	for slider:AudioHorizontalSlider in NodeTraversal.get_all_children(self).filter(func(node): return node is AudioHorizontalSlider):
		slider.value = AudioManager.get_actual_volume_db_from_bus(slider.target_bus)


func on_mute_audio_buses_pressed(mute_pressed: bool) -> void:
	if(mute_pressed):
		AudioManager.mute_all_buses()
	else:
		AudioManager.unmute_all_buses()
		
	SettingsManager.update_audio_section("muted", true)


func on_back_button_pressed() -> void:
	if owner:
		hide()

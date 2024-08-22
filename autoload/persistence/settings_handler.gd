extends Node

signal reset_to_default_settings
signal created_settings
signal loaded_settings

const KeybindingsSection := "keybindings"
const GraphicsSection := "graphics"
const AudioSection := "audio"
const ControlsSection := "controls"
const AccessibilitySection = "accessibility"
const LocalizationSection = "localization"
const AnalyticsSection = "analytics"

const KeybindingSeparator := "|"
const InputEventSeparator := ":"
const FileFormat := "ini" #  ini or cfg

var settings_file_path := OS.get_user_data_dir() + "/settings.%s" % FileFormat
var config_file_api := ConfigFile.new()
var include_ui_keybindings := false


func _ready() -> void:
	if(FileAccess.file_exists(settings_file_path)):
		load_settings()
	else:
		create_settings()


func load_settings(path: String = settings_file_path) -> void:
	var error = config_file_api.load(path)
	
	if error != OK:
		push_error("SettingsHandler: An error %d ocurred trying to load the settings from path %s " % [error, path])

	loaded_settings.emit()
	
	
func create_settings(path: String = settings_file_path) -> void:
	create_audio_section()
	create_graphics_section()
	create_accessibility_section()
	create_localization_section()
	create_analytics_section()
	create_keybindings_section()
	
	save_settings(path)
	
	created_settings.emit()


#region Creation
func create_audio_section() -> void:
	for bus: String in AudioManager.available_buses:
		update_audio_section(bus, AudioManager.get_default_volume_for_bus(bus))


func create_graphics_section() -> void:
	update_graphics_section("fps_counter", false)
	update_graphics_section("max_fps", 0)
	update_graphics_section("display", DisplayServer.window_get_mode())
	update_graphics_section("resolution", DisplayServer.window_get_size())
	update_graphics_section("vsync", DisplayServer.window_get_vsync_mode())
	update_graphics_section("antialiasing_2d", Viewport.MSAA_DISABLED)
	update_graphics_section("antialiasing_3d", Viewport.MSAA_DISABLED)
	update_graphics_section("quality_preset", HardwareDetector.auto_discover_graphics_quality())


func create_accessibility_section() -> void:
	update_accessibility_section("mouse_sensitivity", 3.0);
	update_accessibility_section("controller_vibration", true);
	update_accessibility_section("screen_brightness", 1.0);
	update_accessibility_section("photosensitive", false);
	update_accessibility_section("screenshake", true);
	update_accessibility_section("daltonism", ViewportHelper.DaltonismTypes.No);


func create_localization_section() -> void:
	update_localization_section("current_language", Localization.english().iso_code)
	update_localization_section("voices_language", Localization.english().iso_code)
	update_localization_section("subtitles", false)
	update_localization_section("subtitles_language", Localization.english().iso_code)


func create_analytics_section() -> void:
	update_analytics_section("allow_telemetry", false)

func create_keybindings_section() -> void:
	var keybindings: Dictionary = {}
	var whitespace_regex = RegEx.new()
	whitespace_regex.compile(r"\s+")
	
	for action: StringName in _get_input_map_actions():
		var keybindings_events: Array[String] = []
		
		for input_event: InputEvent in InputHelper.get_all_inputs_for_action(action):
			
			if input_event is InputEventKey:
				keybindings_events.append("InputEventKey:%s" %  StringHelper.remove_whitespaces(InputHelper.readable_key(input_event)))
				
			if input_event is InputEventMouseButton:
				var mouse_button_text: String = ""
				
				match(input_event.button_index):
					MOUSE_BUTTON_LEFT:
						mouse_button_text = "LMB"
					MOUSE_BUTTON_RIGHT:
						mouse_button_text = "RMB"
					MOUSE_BUTTON_MIDDLE:
						mouse_button_text = "MMB"
					MOUSE_BUTTON_WHEEL_DOWN:
						mouse_button_text = "WheelDown"
					MOUSE_BUTTON_WHEEL_UP:
						mouse_button_text = "WheelUp"
					MOUSE_BUTTON_WHEEL_RIGHT:
						mouse_button_text = "WheelRight"
					MOUSE_BUTTON_WHEEL_LEFT:
						mouse_button_text = "WheelLeft"
						
				keybindings_events.append("InputEventMouseButton%s%d%s%s" % [InputEventSeparator, input_event.button_index, InputEventSeparator, mouse_button_text])
			
			if input_event is InputEventJoypadMotion:
				var joypadAxis: String = ""
				
				match(input_event.axis):
					JOY_AXIS_LEFT_X:
						joypadAxis = "Left Stick %s" % "Left" if input_event.axis_value < 0 else "Right"
					JOY_AXIS_LEFT_Y:
						joypadAxis = "Left Stick %s" % "Up" if input_event.axis_value < 0 else "Down"
					JOY_AXIS_RIGHT_X:
						joypadAxis = "Right Stick %s" % "Left" if input_event.axis_value < 0 else "Right"
					JOY_AXIS_RIGHT_Y:
						joypadAxis = "Right Stick %s" % "Up" if input_event.axis_value < 0 else "Down"
					JOY_AXIS_TRIGGER_LEFT:
						joypadAxis = "Left Trigger"
					JOY_AXIS_TRIGGER_RIGHT:
						joypadAxis = "Right trigger"
				
				keybindings_events.append("InputEventJoypadMotion%s%d%s%d%s%s" % [InputEventSeparator, input_event.axis, InputEventSeparator, input_event.axis_value, InputEventSeparator, joypadAxis])
				
			if input_event is InputEventJoypadButton:
				var joypadButton: String = ""
				
				
		keybindings[action] = KeybindingSeparator.join(keybindings_events)
		update_keybindings_section(action, keybindings[action])
		
#endregion

func save_settings(path: String = settings_file_path) -> void:
	config_file_api.save(path)


#region Section updaters
func update_audio_section(key: String, value: Variant) -> void:
	config_file_api.set_value(AudioSection, key, value)


func update_keybindings_section(key: String, value: Variant) -> void:
	config_file_api.set_value(KeybindingsSection, key, value)


func update_graphics_section(key: String, value: Variant) -> void:
	config_file_api.set_value(GraphicsSection, key, value)


func update_accessibility_section(key: String, value: Variant) -> void:
	config_file_api.set_value(AccessibilitySection, key, value)


func update_controls_section(key: String, value: Variant) -> void:
	config_file_api.set_value(ControlsSection, key, value)


func update_analytics_section(key: String, value: Variant) -> void:
	config_file_api.set_value(AnalyticsSection, key, value)


func update_localization_section(key: String, value: Variant) -> void:
	config_file_api.set_value(LocalizationSection, key, value)
#endregion

func _get_input_map_actions() -> Array[StringName]:
	return InputMap.get_actions() if include_ui_keybindings else InputMap.get_actions().filter(func(action): return !action.contains("ui_"))

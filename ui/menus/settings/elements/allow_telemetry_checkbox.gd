class_name VsyncCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = int(DisplayServer.window_get_vsync_mode()) > 0
	toggled.connect(on_vsync_changed)


func on_vsync_changed(vsync_enabled: bool) -> void:
	DisplayServer.window_set_vsync_mode(int(vsync_enabled))
	
	
	SettingsHandler.update_graphics_section("vsync", DisplayServer.window_get_vsync_mode())
	SettingsHandler.save_settings()

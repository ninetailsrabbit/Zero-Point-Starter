class_name ScreenShakeCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = SettingsHandler.get_accessibility_section("screenshake")
	toggled.connect(on_screen_shake_changed)


func on_screen_shake_changed(enabled: bool) -> void:	
	SettingsHandler.update_accessibility_section("screenshake", enabled)
	SettingsHandler.save_settings()

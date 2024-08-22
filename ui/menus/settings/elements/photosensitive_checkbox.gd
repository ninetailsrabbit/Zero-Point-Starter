class_name PhotosensitiveCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = SettingsHandler.get_accessibility_section("photosensitive")
	toggled.connect(on_photosensitive_changed)


func on_photosensitive_changed(enabled: bool) -> void:	
	SettingsHandler.update_accessibility_section("photosensitive", enabled)
	SettingsHandler.save_settings()

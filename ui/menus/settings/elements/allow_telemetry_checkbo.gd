class_name AllowTelemetryCheckbox extends CheckBox


func _ready() -> void:
	button_pressed = SettingsManager.get_analytics_section("allow_telemetry")
	toggled.connect(on_allow_telemetry_changed)


func on_allow_telemetry_changed(enabled: bool) -> void:
	SettingsManager.update_analytics_section("allow_telemetry", enabled)
	SettingsManager.save_settings()

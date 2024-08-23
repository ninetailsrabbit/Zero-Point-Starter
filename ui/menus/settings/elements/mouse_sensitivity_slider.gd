class_name MouseSensitivitySlider extends HSlider


func _enter_tree() -> void:
	min_value = 0.5
	max_value = 20
	step = 0.5
	tick_count = ceil(max_value / min_value)
	ticks_on_borders = true
	
	drag_ended.connect(on_sensitivity_changed)


func _ready() -> void:
	value = SettingsHandler.get_accessibility_section("mouse_sensitivity")
		


func on_sensitivity_changed(sensitivity_changed: float) -> void:
	if sensitivity_changed:
		SettingsHandler.update_accessibility_section("mouse_sensitivity", value)
		SettingsHandler.save_settings()
		GlobalGameEvents.mouse_sensitivity_changed.emit(value)

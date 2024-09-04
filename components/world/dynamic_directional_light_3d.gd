class_name DynamicDirectionalLight3D extends DirectionalLight3D


func _ready() -> void:
	GlobalGameEvents.updated_graphic_settings.connect(on_updated_graphic_settings)
	
	update_world_graphic_settings()


func on_updated_graphic_settings() -> void:
	update_world_graphic_settings()


func update_world_graphic_settings() -> void:
	var quality_preset = SettingsHandler.get_graphics_section("quality_preset")
	
	for preset in HardwareDetector.graphics_quality_presets[quality_preset]:
		for quality in preset.quality:
			match quality.project_setting:
				"shadow_atlas":
					match quality_preset:
						HardwareDetector.QualityPreset.Low:
							shadow_bias = 0.03
						HardwareDetector.QualityPreset.Medium:
							shadow_bias = 0.02
						HardwareDetector.QualityPreset.High:
							shadow_bias = 0.01
						HardwareDetector.QualityPreset.Ultra:
							shadow_bias = 0.005

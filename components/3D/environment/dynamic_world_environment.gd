class_name DynamicWorldEnvironment extends WorldEnvironment


func _ready() -> void:
	GlobalGameEvents.updated_graphic_settings.connect(on_updated_graphic_settings)
	
	update_world_graphic_settings()
	

func on_updated_graphic_settings() -> void:
	update_world_graphic_settings()


func update_world_graphic_settings() -> void:
	var quality_preset = SettingsManager.get_graphics_section("quality_preset")
	var viewport: Viewport = get_viewport()
	var preset: HardwareDetector.GraphicQualityPreset = HardwareDetector.graphics_quality_presets[quality_preset]

	for quality: HardwareDetector.GraphicQualityDisplay in preset.quality:
		match quality.project_setting:
			"environment/glow_enabled":
				environment.glow_enabled = bool(quality.enabled)
			"environment/ssao_enabled":
				environment.ssao_enabled = bool(quality.enabled)
				
				if environment.ssao_enabled:
					match quality_preset:
						HardwareDetector.QualityPreset.Low:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_VERY_LOW, true, 0.5, 2, 50, 300)
						HardwareDetector.QualityPreset.Medium:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_LOW, true, 0.5, 2, 50, 300)
						HardwareDetector.QualityPreset.High:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_MEDIUM, true, 0.5, 2, 50, 300)
						HardwareDetector.QualityPreset.Ultra:
							RenderingServer.environment_set_ssao_quality(RenderingServer.ENV_SSAO_QUALITY_HIGH, true, 0.5, 2, 50, 300)
			"environment/ss_reflections_enabled":
				environment.ssr_enabled = bool(quality.enabled)
				
				if environment.ssr_enabled:
					match quality_preset:
						HardwareDetector.QualityPreset.Low:
							environment.ssr_max_steps = 8
						HardwareDetector.QualityPreset.Medium:
							environment.ssr_max_steps = 32
						HardwareDetector.QualityPreset.High:
							environment.ssr_max_steps = 56
						HardwareDetector.QualityPreset.Ultra:
							environment.ssr_max_steps = 56
			"environment/sdfgi_enabled":
				environment.sdfgi_enabled = bool(quality.enabled)
				
				if environment.sdfgi_enabled:
					match quality_preset:
						HardwareDetector.QualityPreset.Low:
							RenderingServer.gi_set_use_half_resolution(true)
						HardwareDetector.QualityPreset.Medium:
							RenderingServer.gi_set_use_half_resolution(true)
						HardwareDetector.QualityPreset.High:
							RenderingServer.gi_set_use_half_resolution(false)
						HardwareDetector.QualityPreset.Ultra:
							RenderingServer.gi_set_use_half_resolution(false)
			"rendering/anti_aliasing/quality/msaa_3d":
				viewport.msaa_3d = quality.enabled
			"shadow_atlas":
				RenderingServer.directional_shadow_atlas_set_size(quality.enabled, true)
				viewport.positional_shadow_atlas_size = quality.enabled
			"shadow_filter":
				RenderingServer.directional_soft_shadow_filter_set_quality(quality.enabled)
				RenderingServer.positional_soft_shadow_filter_set_quality(quality.enabled)
			"mesh_level_of_detail":
				viewport.mesh_lod_threshold = quality.enabled

class_name HardwareDetector

enum QualityPreset {
	Low,
	Medium,
	High,
	Ultra
}

static var engine_version: String = "Godot %s" % Engine.get_version_info().string
static var device := OS.get_model_name()
static var platform := OS.get_name()
static var distribution_name := OS.get_distribution_name()
static var video_adapter_name := RenderingServer.get_video_adapter_name()
static var processor_name := OS.get_processor_name()
static var processor_count := OS.get_processor_count()


static func is_steam_deck() -> bool:
	return StringHelper.case_insensitive_comparison(distribution_name, "SteamOS") \
		or video_adapter_name.containsn("radv vangogh") \
		or OS.get_processor_name().containsn("amd custom apu 0405")


func is_mobile() -> bool:
	if not OS.has_feature("web"):
		return false
	
	return OS.get_name() == "Android" or OS.get_name() == "iOS" \
		or (is_web() and OS.has_feature("web_android")) or (is_web() and OS.has_feature("web_ios")) \
		or JavaScriptBridge.eval("/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)", true)


func is_multithreading_enabled() -> bool:
	return ProjectSettings.get_setting("rendering/driver/threads/thread_model") == 2


static func is_exported_release() -> bool:
	return OS.has_feature("template")


static func is_windows() -> bool:
	return OS.get_name() == "Windows" or (is_web() and OS.has_feature("web_windows"))


static func is_linux() -> bool:
	return OS.get_name() in ["Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"] or (is_web() and OS.has_feature("web_linuxbsd"))
	
		
static func is_mac() -> bool:
	return OS.get_name() == "macOS" or (is_web() and OS.has_feature("web_macos"))


static func is_web() -> bool:
	return OS.has_feature("Web")


static func auto_discover_graphics_quality() -> QualityPreset:
	var current_hardware_device_name = RenderingServer.get_video_adapter_name()
	
	for preset in devices_by_quality:
		for adapter: String in devices_by_quality[preset]:
			if StringHelper.case_insensitive_comparison(current_hardware_device_name, adapter):
				return preset
				
	return QualityPreset.Medium
	

static var devices_by_quality: Dictionary = {
	QualityPreset.Low: [
	 	"M1", "M2", "M3", "MX", "Vega", "Radeon Graphics", "Radeon Pro", "FirePro", "Intel", "HD", "Iris",
		"GT 705", "GT 710", "710M", "GT 720", "GT 730", "GT 735", "GT 740", "GTX 740", "740M", "GTX 745",
		"745M", "GTX 750", "750M", "755M", "GTX 760", "760M", "765M", "GTX 770", "770M", "GTX 780", "780M",
		"810M", "820M", "825M", "830M", "840M", "845M", "850M", "860M", "870M", "880M", "GT 945", "GTX 945",
		"GTX 950", "GTX 950", "GTX 960", "GTX 960", "GTX 970", "GTX 980", "910M", "920M", "930M", "940M",
		"950M", "960M", "965M", "970M", "980M", "GT 1010", "GTX 1010", "GT 1030", "GTX 1030", "GTX 1050",
		"GTX 1630", "GTX 1650", "R5 220", "R5 230", "R5 235", "R5 235X", "R5 240", "R7 240", "R7 250",
		"R7 250E", "R7 250X", "R7 260", "R7 260X", "R7 265", "R9 270", "R9 270X", "R9 280", "R9 280X",
		"R9 285", "R9 285X", "R9 290", "R9 290X", "R9 295X2", "R5 M230", "R5 M255", "R7 M260", "R7 M260X",
		"R7 M265", "R9 M265X", "R9 M270X", "R9 M275X", "R9 M280X", "R9 M290X", "R9 M295X", "R5 330",
		"R5 340", "R7 340", "R5 340X", "R7 350", "R7 350", "R7 350X", "R7 360", "R9 360", "R7 370",
		"R9 370", "R9 370X", "R9 380", "R9 380", "R9 380X", "R9 390", "R9 390X", "R9 Fury", "R9 Nano",
		"R9 Fury X", "R5 M330", "R5 M335", "R7 M360", "R9 M365X", "R9 M370X", "R9 M375", "R9 M375X",
		"R9 M380", "R9 M385X", "R9 M390", "R9 M390X", "R9 M395", "R9 M395X", "R5 M420", "R5 430",
		"R5 M430", "R7 M435", "R5 435", "R7 430", "R7 435", "R7 M440", "R7 450", "RX 455", "RX 460",
		"R7 M460", "R7 M465"
	],
	QualityPreset.Medium: [
	 	"GTX 970", "GTX 980", "GTX 1060", "GTX 1650", "GTX 1660", "GTX 1660 Ti", "GTX 1050 Ti", "GTX 1070",
		"GTX 1070 Ti", "GTX 1080", "GTX 1080 Ti", "RX 470", "RX 480", "RX 570", "RX 580", "RX 590",
		"RX 5500 XT", "RX 5600 XT", "RX 5700", "RX 5700 XT", "R9 Fury", "R9 Fury X", "R9 Nano", "Vega 56",
		"Vega 64"
	],
	QualityPreset.High: [
		"RTX 2060", "RTX 2060 Super", "RTX 2070", "RTX 2070 Super", "RTX 2080", "RTX 2080 Super", "RTX 2080 Ti",
		"RTX 3060", "RTX 3060 Ti", "RTX 3070", "RTX 3070 Ti", "RTX 3080", "RTX 3080 Ti", "RTX 3090", "RX 6600",
		"RX 6600 XT", "RX 6700 XT", "RX 6800", "RX 6800 XT", "RX 6900 XT"
	],
	QualityPreset.Ultra: [
		"RTX 4070", "RTX 4080", "RTX 4090", "RTX 4090 Ti", "RX 7800 XT", "RX 7900 XT", "RX 7900 XTX",
		"Titan RTX", "Quadro RTX 8000"
	],
}

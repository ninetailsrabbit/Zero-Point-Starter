class_name ViewportHelper

const Resolution4_3: String = "4:3";
const Resolution16_9: String = "16:9";
const Resolution16_10: String = "16:10";
const Resolution21_9: String = "21:9";


var resolutions: Dictionary = {
	Resolution4_3: [
	   	Vector2i(512, 384),
		Vector2i(768, 576),
		Vector2i(1024, 768),
	],
	Resolution16_9: [
		Vector2i(320, 180),
	  	Vector2i(320, 180),
		Vector2i(400, 224),
		Vector2i(640, 360),
		Vector2i(960, 540),
		Vector2i(1280, 720), # 720p
		Vector2i(1280, 800), # SteamDeck
		Vector2i(1366, 768),
		Vector2i(1600, 900),
		Vector2i(1920, 1080), # 1080p
		Vector2i(2560, 1440),
		Vector2i(3840, 2160),
		Vector2i(5120, 2880),
		Vector2i(7680, 4320), # 8K
	],
	Resolution16_10: [
		Vector2i(960, 600),
		Vector2i(1280, 800),
		Vector2i(1680, 1050),
		Vector2i(1920, 1200),
		Vector2i(2560, 1600),
	],
	Resolution21_9: [
	 	Vector2i(1280, 540),
		Vector2i(1720, 720),
		Vector2i(2560, 1080),
		Vector2i(3440, 1440),
		Vector2i(3840, 2160), # 4K
		Vector2i(5120, 2880),
		Vector2i(7680, 4320), # 8K
	]
}

enum DaltonismTypes {
	No,
	Protanopia,
	Deuteranopia,
	Tritanopia,
	Achromatopsia
}

#region Resolution getters
func get_4_3_resolutions() -> Array[Vector2i]:
	return resolutions[Resolution4_3]

func get_16_9_resolutions() -> Array[Vector2i]:
	return resolutions[Resolution16_9]

func get_16_10_resolutions() -> Array[Vector2i]:
	return resolutions[Resolution16_10]

func get_21_9_resolutions() -> Array[Vector2i]:
	return resolutions[Resolution21_9]
#endregion


static func center_window_position(viewport: Viewport) -> void:
	var center_of_screen: Vector2i = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var windowSize: Vector2i = viewport.get_window().get_size_with_decorations()
	
	viewport.get_window().position = center_of_screen - windowSize / 2


static func get_camera2d_frame(viewport: Viewport) -> Rect2:
	var camera_frame: Rect2 = viewport.get_visible_rect()
	var camera: Camera2D = viewport.get_camera_2d()
	
	if camera:
		camera_frame.position = camera.get_screen_center_position() - camera_frame.size / 2.0
		
	return camera_frame

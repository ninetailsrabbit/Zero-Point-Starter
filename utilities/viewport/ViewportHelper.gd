class_name ViewportHelper


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

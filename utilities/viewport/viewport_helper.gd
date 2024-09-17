class_name ViewportHelper

const Resolution_Mobile: String = "mobile";
const Resolution4_3: String = "4:3";
const Resolution16_9: String = "16:9";
const Resolution16_10: String = "16:10";
const Resolution21_9: String = "21:9";

const AspectRatio4_3: Vector2i = Vector2i(4, 3)
const AspectRatio16_9: Vector2i = Vector2i(16,9)
const AspectRatio16_10: Vector2i = Vector2i(16, 10)
const AspectRatio21_9: Vector2i = Vector2i(21, 9)



static var resolutions: Dictionary = {
	Resolution_Mobile: [
		Vector2i(320, 480),  # Older smartphones
		Vector2i(320, 640),
		Vector2i(375, 667),  # Older smartphones
		Vector2i(375, 812),
		Vector2i(390, 844),  # Older smartphones
		Vector2i(414, 896),  # Some Iphone models
		Vector2i(480, 800),  # Older smartphones
		Vector2i(640, 960),  # Some Iphone models
		Vector2i(640, 1136), # Some Iphone models
		Vector2i(750, 1334), # Common tablet resolution
		Vector2i(768, 1024),
		Vector2i(768, 1334),
		Vector2i(768, 1280),
		Vector2i(1080, 1920), # Some Iphone models
		Vector2i(1242, 2208), # Mid-range tables
		Vector2i(1536, 2048), # High resolutions in larger tablets and some smartphones
		
	],
	Resolution4_3: [
	  	Vector2i(320, 180),
	   	Vector2i(512, 384),
		Vector2i(768, 576),
		Vector2i(1024, 768),
	],
	Resolution16_9: [
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
static func get_4_3_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	if use_computer_screen_limit:
		return resolutions[Resolution4_3].filter(_filter_by_screen_size_limit)
		
	return resolutions[Resolution4_3]

static func get_16_9_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	if use_computer_screen_limit:
		return resolutions[Resolution16_9].filter(_filter_by_screen_size_limit)

	return resolutions[Resolution16_9]

static func get_16_10_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	if use_computer_screen_limit:
		return resolutions[Resolution16_10].filter(_filter_by_screen_size_limit)

	return resolutions[Resolution16_10]

static func get_21_9_resolutions(use_computer_screen_limit: bool = false) -> Array[Vector2i]:
	if use_computer_screen_limit:
		return resolutions[Resolution21_9].filter(_filter_by_screen_size_limit)

	return resolutions[Resolution21_9]
	
static func _filter_by_screen_size_limit(screen_size: Vector2i):
	return screen_size <= HardwareDetector.computer_screen_size
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
	
	
func get_texture_dimensions(texture: Texture2D) -> Rect2i:
	return texture.get_image().get_used_rect()
	
	
func get_texture_rect_dimensions(texture_rect: TextureRect) -> Vector2:
	var texture: Texture2D = texture_rect.texture
	var used_rect := get_texture_dimensions(texture)
	var texture_dimensions := Vector2(used_rect.size) * texture_rect.scale

	return texture_dimensions


func get_sprite_dimensions(sprite: Sprite2D) -> Vector2:
	var texture: Texture2D = sprite.texture
	var used_rect := get_texture_dimensions(texture)
	var sprite_dimensions := Vector2(used_rect.size) * sprite.scale

	return sprite_dimensions


static func get_png_rect_from_texture(texture: Texture2D) -> Rect2i:
	var image = texture.get_image()
	
	assert(image is Image, "Utilities->get_png_rect_from_texture: The image from the texture is null, the texture it's invalid")
	
	var top_position := image.get_height()
	var bottom_position := 0
	
	var right_position := image.get_width()
	var left_position := 0
	
	for x in image.get_width():
		for y in image.get_height():
			var pixel_color: Color = image.get_pixel(x, y)
			
			if pixel_color.a:
				if top_position > y:
					top_position = y
					
				if bottom_position < y:
					bottom_position = y
				
				if right_position > x:
					right_position = x
					
				if left_position < x:
					left_position = x
	
	var position := Vector2i(left_position - right_position,  bottom_position - top_position)
	var size := Vector2i(right_position + roundi(position.x / 2.0),  top_position + roundi(position.y / 2.0))
	
	return Rect2i(position, size)
	
	

func screenshot(viewport: Viewport) -> Image:
	return viewport.get_texture().get_image()
	
	
func screenshot_to_texture_rect(viewport: Viewport, texture_rect: TextureRect = TextureRect.new()) -> TextureRect:
	var img = screenshot(viewport)
	
	assert(img is Image, "ViewportHelper::screenshot_to_texture_rect: The image output is null")
	
	#img.flip_y()
	texture_rect.texture = ImageTexture.create_from_image(img)
	
	return texture_rect
	

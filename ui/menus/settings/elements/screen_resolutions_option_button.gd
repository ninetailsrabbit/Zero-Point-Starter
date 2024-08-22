class_name ScreenResolutionsOptionButton extends OptionButton

@export var display4_3: bool = false
@export var display16_9: bool = true
@export var display16_10: bool = false
@export var display21_9: bool = false


func _ready() -> void:
	if (HardwareDetector.is_steam_deck()):
		display16_10 = true
		display16_9 = false
		display21_9 = false
		display4_3 = false
		
	_fill_available_resolutions()
	item_selected.connect(on_resolution_selected)


func _fill_available_resolutions() -> void:
	var current_window_size: Vector2i = DisplayServer.window_get_size()
		
	for display_resolution in ViewportHelper.resolutions:
		if _resolution_is_included(display_resolution):
			add_separator(display_resolution)
			
			for screen_size: Vector2i in ViewportHelper.resolutions[display_resolution]:
				add_item("%dx%d" % [screen_size.x, screen_size.y])
				
				if current_window_size == screen_size:
					select(item_count - 1)
			
	
func _resolution_is_included(resolution: String) -> bool:
	return resolution == ViewportHelper.Resolution4_3 && display4_3 \
		or resolution == ViewportHelper.Resolution16_9 && display16_9 \
		or resolution == ViewportHelper.Resolution16_10 && display16_10 \
		or resolution == ViewportHelper.Resolution21_9 && display21_9


func on_resolution_selected(idx) -> void:
	## We need to split the text to get the Vector2i as the options cannot be saved as Variants
	var resolution: PackedStringArray = get_item_text(idx).split("x")
	
	DisplayServer.window_set_size(Vector2i(int(resolution[0]), int(resolution[1])))
	SettingsHandler.update_graphics_section("resolution", DisplayServer.window_get_size())
	SettingsHandler.save_settings()

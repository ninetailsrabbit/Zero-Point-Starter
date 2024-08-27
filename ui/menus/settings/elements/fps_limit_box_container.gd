class_name FpsLimitHboxContainer extends HBoxContainer

@export var fps_limits: Array[int] =  [0, 30, 60, 90, 144, 240, 300]

var fps_limit_button_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	create_fps_limit_buttons()


func create_fps_limit_buttons() -> void:
	fps_limit_button_group.pressed.connect(on_fps_limit_button_pressed)
	
	for fps_limit in fps_limits:
		var button: Button = Button.new()
		button.text = str(fps_limit)
		button.name = str(fps_limit)
		button.button_group = fps_limit_button_group
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.button_pressed = Engine.max_fps == fps_limit
				
		add_child(button)
		

func on_fps_limit_button_pressed(fps_limit_button: BaseButton) -> void:
	var limit = fps_limit_button.name.to_int()
	Engine.max_fps = limit
	
	SettingsHandler.update_graphics_section("max_fps", limit)
	SettingsHandler.save_settings()

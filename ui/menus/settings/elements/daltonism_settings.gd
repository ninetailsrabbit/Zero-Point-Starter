class_name DaltonismSettings extends HBoxContainer

var daltonism_buttons: Dictionary = {}
var daltonism_button_group: ButtonGroup = ButtonGroup.new()


func _ready() -> void:
	
	create_daltonism_buttons()


func create_daltonism_buttons() -> void:
	var hbox_container: HBoxContainer = HBoxContainer.new()
	hbox_container.set_anchors_preset(PRESET_TOP_WIDE)
	hbox_container.size_flags_horizontal = Control.SIZE_FILL
	add_child(hbox_container)
	
	daltonism_button_group.pressed.connect(on_daltonism_button_pressed)
	
	for daltonism in TranslationKeys.DaltonismKeys:
		var button: Button = Button.new()
		button.set_meta("daltonism", daltonism)
		button.text = tr(TranslationKeys.DaltonismKeys[daltonism])
		button.name = button.text
		button.button_group = daltonism_button_group
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.button_pressed = int(daltonism) == int(SettingsManager.get_accessibility_section("daltonism"))
		
		daltonism_buttons[daltonism] = button
		
		hbox_container.add_child(button)
		

func on_daltonism_button_pressed(daltonism_button: BaseButton) -> void:
	SettingsManager.update_accessibility_section("daltonism", daltonism_button.get_meta("daltonism"))
	SettingsManager.save_settings()

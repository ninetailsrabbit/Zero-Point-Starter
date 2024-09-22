class_name NewGameSlot extends Panel

signal new_game_slot_requested

@onready var new_game_slot_button: TextureButton = $CenterContainer/VBoxContainer/NewGameSlotButton
@onready var new_game_label: Label = $CenterContainer/VBoxContainer/NewGameLabel

var hover_color: Color = Color("ffe188")


func _ready() -> void:
	custom_minimum_size = Vector2(500, 150)
	
	gui_input.connect(on_panel_gui_input)
	new_game_slot_button.pressed.connect(on_new_game_slot_button_pressed)
	
	mouse_entered.connect(on_focus)
	mouse_exited.connect(on_focus_exited)
	new_game_slot_button.mouse_entered.connect(on_focus)
	new_game_slot_button.mouse_exited.connect(on_focus_exited)
	new_game_label.mouse_entered.connect(on_focus)
	new_game_label.mouse_exited.connect(on_focus_exited)
	focus_entered.connect(on_focus)
	focus_exited.connect(on_focus_exited)
	

func on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		new_game_slot_requested.emit()


func on_new_game_slot_button_pressed() -> void:
	new_game_slot_requested.emit()
	

func on_focus() -> void:
	new_game_label.add_theme_color_override("font_color", hover_color)
	new_game_slot_button.self_modulate = hover_color


func on_focus_exited() -> void:
	new_game_label.remove_theme_color_override("font_color")
	new_game_slot_button.self_modulate = Color.WHITE
	

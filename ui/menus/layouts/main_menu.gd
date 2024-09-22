extends CanvasLayer


@onready var version_label: Label = %VersionLabel
@onready var title_label: Label = %TitleLabel

@onready var start_game_button: Button = %StartGameButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var exit_game_button: Button = %ExitGameButton

@onready var main_menu_buttons: CenterContainer = $MainMenu/MainMenuButtons
@onready var main_menu_content: MarginContainer = $MainMenu/MainMenuContent

@onready var game_settings_ui: Control = $GameSettingsUI
@onready var new_game_menu: Control = $NewGameMenu


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if game_settings_ui.visible:
			game_settings_ui.hide()

	
func _ready() -> void:
	version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	
	game_settings_ui.hide()
	new_game_menu.hide()
	
	start_game_button.focus_neighbor_top = exit_game_button.get_path()
	exit_game_button.focus_neighbor_bottom = start_game_button.get_path()
	start_game_button.grab_focus()
	
	game_settings_ui.visibility_changed.connect(on_secondary_menus_visibility_changed)
	new_game_menu.visibility_changed.connect(on_secondary_menus_visibility_changed)
	
	start_game_button.pressed.connect(on_start_game_button_pressed)
	settings_button.pressed.connect(on_settings_button_pressed)
	exit_game_button.pressed.connect(on_exit_game_button_pressed)


#region Signal callbacks
func on_start_game_button_pressed() -> void:
	new_game_menu.show()
	

func on_settings_button_pressed() -> void:
	game_settings_ui.show()


func on_exit_game_button_pressed() -> void:
	get_tree().quit()


func on_secondary_menus_visibility_changed() -> void:
	if game_settings_ui.visible or new_game_menu.visible:
		main_menu_buttons.hide()
		main_menu_content.hide()
	else:
		game_settings_ui.hide()
		new_game_menu.hide()
		main_menu_buttons.show()
		main_menu_content.show()
	
#endregion

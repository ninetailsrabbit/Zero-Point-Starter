extends Control

const NewGameSlotScene: PackedScene = preload("res://ui/menus/layouts/components/new_game_slot.tscn")
const LoadedGameSlotScene: PackedScene = preload("res://ui/menus/layouts/components/loaded_game_slot.tscn")

@onready var background: ColorRect = $Background
@onready var saved_games_displayer: VBoxContainer = %SavedGamesDisplayer
@onready var back_to_menu_button: Button = $MarginContainer/BackToMenuButton
@onready var enter_save_name_dialog: ConfirmationDialog = $EnterSaveNameDialog
@onready var line_edit_name: LineEdit = $EnterSaveNameDialog/LineEditName


func _ready() -> void:
	enter_save_name_dialog.hide()
	
	NodeRemover.queue_free_children(saved_games_displayer)
	create_new_game_slot()
	update_list_of_saved_games_slots()
	
	back_to_menu_button.pressed.connect(on_back_button_pressed)
	
	# The buttons signals are flipped because I want the cancel button on the left
	enter_save_name_dialog.confirmed.connect(on_canceled_save_filename)
	enter_save_name_dialog.canceled.connect(on_entered_save_filename)
	line_edit_name.text_changed.connect(on_save_name_text_changed)
	line_edit_name.text_submitted.connect(on_save_name_text_submitted)
	
	SaveManager.loaded_savegame.connect(on_loaded_savegame)
	SaveManager.removed_saved_game.connect(on_removed_saved_game)


func create_new_game_slot() -> void:
	var new_save_game_slot_panel: NewGameSlot = NewGameSlotScene.instantiate()
	saved_games_displayer.add_child(new_save_game_slot_panel)
	new_save_game_slot_panel.new_game_slot_requested.connect(on_new_game_slot_requested)


func update_list_of_saved_games_slots() -> void:
	for slot: LoadedGameSlot in NodeTraversal.find_nodes_of_custom_class(saved_games_displayer, LoadedGameSlot):
		NodeRemover.remove(slot)
		
	var index: int = 0
	
	for save_filename: String in SaveManager.list_of_saved_games:
		index += 1
		
		var loaded_game_slot: LoadedGameSlot = LoadedGameSlotScene.instantiate() as LoadedGameSlot
		loaded_game_slot.display_save(SaveManager.list_of_saved_games[save_filename], index)
		saved_games_displayer.add_child(loaded_game_slot)
		loaded_game_slot.gui_input.connect(on_loaded_game_slot_gui_input.bind(loaded_game_slot))
	
	
func transition_to_gameplay_menu() -> void:
	pass

#region Signal callbacks
func on_new_game_slot_requested() -> void:
	enter_save_name_dialog.show()
	line_edit_name.grab_focus()


func on_save_name_text_changed(new_text: String) -> void:
	var is_valid: bool = true
	
	for character: String in new_text:
		if character in StringHelper.AsciiPunctuation:
			is_valid = false
			break
	
	if not is_valid:
		line_edit_name.text = new_text.left(new_text.length() - 1)
		line_edit_name.caret_column = line_edit_name.text.length()
		
		
func on_save_name_text_submitted(text: String) -> void:
	if not SaveManager.save_filename_exists(text):
		on_entered_save_filename()


func on_entered_save_filename() -> void:
	if not line_edit_name.text.is_empty():
		SaveManager.create_new_save(line_edit_name.text, true)
		enter_save_name_dialog.hide()
		#update_list_of_saved_games_slots()


func on_canceled_save_filename() -> void:
	line_edit_name.clear()
	line_edit_name.release_focus()


func on_loaded_savegame(_filename: String) -> void:
	transition_to_gameplay_menu()
	
	
func on_removed_saved_game(_filename: String) -> void:
	update_list_of_saved_games_slots()
	
	
func on_loaded_game_slot_gui_input(event: InputEvent, loaded_game_slot: LoadedGameSlot) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		SaveManager.current_saved_game = loaded_game_slot.saved_game


func on_back_button_pressed() -> void:
	hide()
#endregion

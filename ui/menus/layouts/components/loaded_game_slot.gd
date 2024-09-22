class_name LoadedGameSlot extends Panel

signal removed

@onready var remove_confirmation: AcceptDialog = $RemoveConfirmation
@onready var slot_number_texture: TextureRect = %SlotNumberTexture
@onready var slot_number_label: Label = %SlotNumberLabel
@onready var saved_time_label: Label = %SavedTimeLabel
@onready var save_name_label: Label = %SaveNameLabel
@onready var remove_button: Button = %RemoveButton


var saved_game: SavedGame
var slot_number: int

	
func _ready() -> void:
	remove_confirmation.hide()
	slot_number_texture.custom_minimum_size = Vector2(36, 36) if slot_number > 9 else Vector2(32, 32)
	slot_number_label.text = str(slot_number)
	
	save_name_label.text = saved_game.display_name
	saved_time_label.text = saved_game.last_datetime
	
	mouse_entered.connect(on_hovered)
	mouse_exited.connect(on_hover_finish)
	remove_confirmation.confirmed.connect(on_remove_save_game_confirmation)
	remove_button.pressed.connect(on_remove_button_pressed)


func display_save(_saved_game: SavedGame, _slot_number: int) -> void:
	saved_game = _saved_game
	slot_number = _slot_number
	
	assert(saved_game is SavedGame, "LoadedGameSlot: The saved game %s to load in this information slot is not valid" % saved_game.filename)
	
	
func on_hovered() -> void:
	pass

	
func on_hover_finish() -> void:
	pass
	

func on_remove_button_pressed() -> void:
	remove_confirmation.show()


func on_remove_save_game_confirmation() -> void:
	removed.emit()
	SaveManager.remove(saved_game.filename)

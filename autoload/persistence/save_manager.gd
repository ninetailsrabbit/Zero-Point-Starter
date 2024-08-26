extends Node

signal created_savegame(filename: String)
signal loaded_savegame(filename: String)
signal writed_savegame(filename: String)
signal removed_saved_game(filename: String)
signal error_creating_savegame(filename: String, error: Error)
signal error_loading_savegame(filename: String, error: Error)
signal error_writing_current_savegame(filename: String, error: Error)
signal error_removing_savegame(filename: String, error: Error)

## Dictionary<string, SavedGame>
@export var list_of_saved_games := {}
@export var current_saved_game: SavedGame


func _ready() -> void:
	list_of_saved_games.merge(read_user_saved_games(), true)


func create_new_save(filename: String):
	if SavedGame.save_exists(filename):
		error_creating_savegame.emit(filename, ERR_ALREADY_EXISTS)
		return

	var new_saved_game = SavedGame.new()
	var error: Error = new_saved_game.write_savegame(filename)
	
	if error == Error.OK:
		created_savegame.emit(filename)
	else:
		error_creating_savegame.emit(filename, error)


func load_savegame(filename: String) -> SavedGame:
	if SavedGame.save_exists(filename):
		current_saved_game = ResourceLoader.load(SavedGame.get_save_path(filename), "", ResourceLoader.CACHE_MODE_IGNORE) as SavedGame
		
		loaded_savegame.emit(current_saved_game)
		
		return current_saved_game
		
	error_loading_savegame.emit(filename, ERR_DOES_NOT_EXIST)
	
	return null


func remove(filename: String):
	if list_of_saved_games.is_empty():
		return
		
	if (list_of_saved_games.has(filename)):
		var saved_game: SavedGame = list_of_saved_games[filename] as SavedGame
		saved_game.delete()
		
		list_of_saved_games.erase(filename)
		removed_saved_game.emit(filename)
		
		return
	
	push_error("SaveManager: Trying to remove a saved game with name %s that does not exists in the list of saved games" % filename)
	
	error_removing_savegame.emit(filename, ERR_DOES_NOT_EXIST)


func read_user_saved_games() -> Dictionary:
	var saved_games := {}
	var dir = DirAccess.open(SavedGame.default_path)

	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() in [SavedGame.get_save_extension()]:
				var saved_game = load_savegame(file_name.get_basename())
				
				if saved_game: 
					saved_games[saved_game.filename] = saved_game
		
			file_name = dir.get_next()
					
		dir.list_dir_end()
		
	return saved_games

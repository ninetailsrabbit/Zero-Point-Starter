## In this singleton you can load your game resources on the background while displaying loading information to the final user.
extends Node

signal content_requested(path: String)
signal content_loaded


var paths_to_load: Array[String] = []
var err_size := 0
var progress := []


func _ready():
	content_loaded.connect(on_content_loaded)


@warning_ignore("unused_variable")
func _process(_delta):
	if paths_to_load.is_empty():
		content_loaded.emit()
	else:
		var path_to_load = paths_to_load.front()
		var resource_name := _get_resource_name_from_path(path_to_load)
		var load_status := ResourceLoader.load_threaded_get_status(path_to_load, progress)
		
		match load_status:
			ResourceLoader.THREAD_LOAD_LOADED:
				var loaded_resource: Resource = ResourceLoader.load_threaded_get(path_to_load)
				## HERE IS WHERE you check loaded resource and add to your desired data structures...
				
				err_size = 0
				progress.clear()
				paths_to_load.pop_front()
				_process(_delta)
				
			ResourceLoader.THREAD_LOAD_FAILED:
				progress.clear()
				paths_to_load.pop_front()
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				ResourceLoader.load_threaded_request(path_to_load)
				err_size += 1
				
				if err_size > 5:
					print("ContentManager: Invalid resource attempted to load %s" % path_to_load)
					progress.clear()
					paths_to_load.pop_front()
					
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				pass
				

func request_load_resources_from(path: String):
	if FileHelper.dirpath_is_valid(path):
		content_requested.emit(path)
		
		for file_path in FileHelper.get_files_recursive(path):
			
			if '.tres.remap' in file_path or '.res.remap' in file_path:
				file_path = file_path.trim_suffix('.remap')
			
			paths_to_load.push_back(file_path)
		
		set_process(true)
	else:
		push_error("ContentManager: The path requested to load %s is invalid or corrupt, process aborted" % path)


func _get_resource_name_from_path(path: String) -> String:
	var split = path.split("/")
	var resource_name := split[split.size() - 1].trim_suffix(".tres")
	resource_name = resource_name.trim_suffix(".res")
	
	return resource_name
	
	
func on_content_loaded() -> void:
	set_process(false)

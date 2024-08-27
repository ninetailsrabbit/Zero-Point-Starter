@icon("res://components/interaction/3D/interactable.svg")
class_name Interactable3D extends Area3D

signal interacted(interactor)
signal canceled_interaction(interactor)
signal focused(interactor)
signal unfocused(interactor)
signal interaction_limit_reached(interactable: Interactable3D)

## The number of times this interactable can be interacted with, 0 means no limit.
@export var number_of_times_can_be_interacted: int = 0
@export var change_cursor: bool = true
@export var change_screen_pointer: bool = true
@export var lock_player_on_interact: bool = false
@export_group("Information")
@export var title: String = ""
@export var description: String = ""
@export var title_translation_key: String = ""
@export var description_translation_key: String = ""
@export_group("Scan")
@export var scannable: bool = false
@export var can_be_rotated_on_scan: bool = true
@export var target_scannable_object: Node3D
@export_group("Pointers and cursors")
@export var focus_screen_pointer: CompressedTexture2D
@export var interact_screen_pointer: CompressedTexture2D
@export var focus_cursor: CompressedTexture2D
@export var interact_cursor: CompressedTexture2D
@export var scan_rotate_cursor: CompressedTexture2D


var times_interacted := 0:
	get:
		return times_interacted
	set(value):
		var previous_value = times_interacted
		times_interacted = value
		
		if previous_value != times_interacted && times_interacted == number_of_times_can_be_interacted:
			interaction_limit_reached.emit(self)
			GlobalGameEvents.interactable_interaction_limit_reached.emit(self)
			deactivate()

func _ready():
	activate()
	
	interacted.connect(on_interacted)
	canceled_interaction.connect(on_canceled_interaction)
	focused.connect(on_focused)
	unfocused.connect(on_unfocused)


func activate() -> void:
	priority = 3
	collision_layer = GameGlobals.interactables_collision_layer
	collision_mask = 0
	monitorable = true
	monitoring = false
	
	times_interacted = 0


func deactivate() -> void:
	priority = 0
	collision_layer = 0
	monitorable = false

	
func on_interacted(interactor):
	if _is_valid_interactor(interactor):
		
		if change_cursor and interactor is MouseRayCastInterator3D:
			CursorManager.change_cursor_to(interact_cursor)
		
		GlobalGameEvents.interactable_interacted.emit(interactor)
		
		
func on_canceled_interaction(interactor):
	if _is_valid_interactor(interactor):
		
		if change_cursor and interactor is MouseRayCastInterator3D:
			CursorManager.return_cursor_to_default()
			
		GlobalGameEvents.interactable_canceled_interaction.emit(interactor)
		
		
func on_focused(interactor):
	if _is_valid_interactor(interactor):
		
		if change_cursor and interactor is MouseRayCastInterator3D:
			CursorManager.change_cursor_to(focus_cursor)
			
		GlobalGameEvents.interactable_focused.emit(interactor)


func on_unfocused(interactor):
	if _is_valid_interactor(interactor):
		
		if change_cursor and interactor is MouseRayCastInterator3D:
			CursorManager.return_cursor_to_default()
			
		GlobalGameEvents.interactable_unfocused.emit(interactor)


func _is_valid_interactor(interactor) -> bool:
	return interactor is RayCastInteractor3D or interactor is MouseRayCastInterator3D
	

class_name InteractionPointer extends Control


@export var minimum_size := Vector2(64, 64)
@export var default_pointer_texture: Texture2D

@onready var current_pointer: TextureRect = %Pointer


func _ready():
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	current_pointer.texture = default_pointer_texture
	current_pointer.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	current_pointer.custom_minimum_size = minimum_size
	
	GlobalGameEvents.interactable_focused.connect(on_interactable_focused)
	GlobalGameEvents.interactable_unfocused.connect(on_interactable_unfocused)
	
	GlobalGameEvents.grabbable_focused.connect(on_grabbable_focused)
	GlobalGameEvents.grabbable_unfocused.connect(on_grabbable_unfocused)


func on_interactable_focused(interactable: Interactable3D) -> void:
	if interactable.focus_screen_pointer:
		current_pointer.texture = interactable.focus_screen_pointer


func on_interactable_unfocused(interactable: Interactable3D) -> void:
	if interactable.focus_screen_pointer:
		current_pointer.texture = default_pointer_texture


func on_grabbable_focused(grabbable: Grabbable3D) -> void:
	if grabbable.focus_screen_pointer:
		current_pointer.texture = grabbable.focus_screen_pointer
		
		
func on_grabbable_unfocused(grabbable: Grabbable3D) -> void:
	if grabbable.focus_screen_pointer:
		current_pointer.texture = default_pointer_texture
		

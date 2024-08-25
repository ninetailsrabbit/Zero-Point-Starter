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


func on_interactable_focused(interactor) -> void:
	if interactor is RayCastInteractor3D or interactor is MouseRayCastInterator3D:
		current_pointer.texture = interactor.current_interactable.focus_screen_pointer
		
	elif interactor is ThrowableRayCastInteractor:
		current_pointer.texture = interactor.current_throwable.focus_screen_pointer
		
	
func on_interactable_unfocused(_interactor) -> void:
	current_pointer.texture = default_pointer_texture

@icon("res://components/interaction/3D/interactor_3d.svg")
class_name RayCastInteractor3D extends RayCast3D

@export var input_action := "interact"
@export var input_action_to_cancel := "cancel_interact"

var current_interactable: Interactable3D
var focused := false
var interacting := false


func _enter_tree():
	enabled = true
	exclude_parent = true
	collision_mask = GameGlobals.interactables_collision_layer
	collide_with_areas = true
	collide_with_bodies = false


func _unhandled_input(_event: InputEvent):
	if InputMap.has_action(input_action) && Input.is_action_just_pressed(input_action) and current_interactable and not interacting:
		interact(current_interactable);
	

func _physics_process(_delta):
	var detected_interactable: Interactable3D = get_collider() as Interactable3D if is_colliding() else null
	
	if detected_interactable:
		if current_interactable == null and not focused:
			focus(detected_interactable)
	else:
		if focused and not interacting and current_interactable:
			unfocus(current_interactable)


func interact(interactable: Interactable3D):
	if interactable:
		interacting = true
		enabled = false
		
		interactable.interacted.emit(self)
	
	
func cancel_interact(interactable: Interactable3D = current_interactable):
	if interactable:
		interacting = false
		focused = false
		enabled = true
				
		interactable.canceled_interaction.emit(self)


func focus(interactable: Interactable3D):
	current_interactable = interactable
	focused = true
	
	interactable.focused.emit(self)
	
	
func unfocus(interactable: Interactable3D = current_interactable):
	if interactable and focused:
		current_interactable = null
		focused = false
		interacting = false
		enabled = true
		
		interactable.unfocused.emit(self)

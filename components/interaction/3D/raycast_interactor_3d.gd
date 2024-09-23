@icon("res://components/interaction/3D/interactor_3d.svg")
class_name RayCastInteractor3D extends RayCast3D

@export var interact_input_action := "interact"
@export var input_action_to_cancel := "cancel_interact"

var current_interactable: Interactable3D
var focused: bool = false
var interacting: bool = false


func _enter_tree():
	enabled = true
	exclude_parent = true
	collision_mask = GameGlobals.world_collision_layer | GameGlobals.enemies_collision_layer | GameGlobals.interactables_collision_layer
	collide_with_areas = true
	collide_with_bodies = true

	
func _unhandled_input(_event: InputEvent):
	if InputMap.has_action(interact_input_action) && Input.is_action_just_pressed(interact_input_action) and current_interactable and not interacting:
		interact(current_interactable)
	
	
func _ready() -> void:
	GlobalGameEvents.canceled_interactable_scan.connect(on_canceled_interaction)
	GlobalGameEvents.interactable_canceled_interaction.connect(on_canceled_interaction)


func _physics_process(_delta):
	var detected_interactable = get_collider() if is_colliding() else null

	if detected_interactable is Interactable3D:
		if current_interactable == null and not focused:
			focus(detected_interactable)
	else:
		if focused and not interacting and current_interactable:
			unfocus(current_interactable)


func interact(interactable: Interactable3D):
	if interactable:
		interacting = interactable.interaction_is_constant
		enabled = false
		
		interactable.interacted.emit()
	
	
func cancel_interact(interactable: Interactable3D = current_interactable):
	if interactable:
		interacting = false
		focused = false
		enabled = true
				
		interactable.canceled_interaction.emit()


func focus(interactable: Interactable3D):
	current_interactable = interactable
	focused = true
	
	interactable.focused.emit()
	
	
func unfocus(interactable: Interactable3D = current_interactable):
	if interactable and focused:
		current_interactable = null
		focused = false
		interacting = false
		enabled = true
		
		interactable.unfocused.emit()
		

func on_canceled_interaction(_interactable: Interactable3D) -> void:
	current_interactable = null
	focused = false
	interacting = false
	enabled = true

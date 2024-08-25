class_name ThrowableRayCastInteractor extends RayCast3D

@export var interact_action := "interact"
@export var input_action_to_cancel := "cancel_interaact"

var current_interactable: Interactable3D
var focused := false
var interacting := false
	
var current_throwable: Throwable3D


func _enter_tree() -> void:
	enabled = true
	exclude_parent = true
	collision_mask = GameGlobals.throwables_collision_layer
	collide_with_areas = false
	collide_with_bodies = true


func _unhandled_input(_event: InputEvent):
	if InputMap.has_action(interact_action) && Input.is_action_just_pressed(interact_action) and current_throwable and not interacting:
		interact(current_throwable);
	

func _physics_process(_delta):
	var detected_throwable: Throwable3D = get_collider() as Throwable3D if is_colliding() else null
	
	if detected_throwable:
		if current_throwable == null and not focused:
			focus(detected_throwable)
	else:
		if focused and not interacting and current_throwable:
			unfocus(current_throwable)


func interact(throwable: Throwable3D):
	if throwable:
		interacting = true
		enabled = false
		
		throwable.interacted.emit(self)
	
	
func cancel_interact(throwable: Throwable3D = current_throwable):
	if throwable:
		interacting = false
		focused = false
		enabled = true
				
		throwable.canceled_interaction.emit(self)


func focus(throwable: Throwable3D):
	current_throwable = throwable
	focused = true
	
	throwable.focused.emit(self)
	
	
func unfocus(throwable: Throwable3D = current_throwable):
	if throwable and focused:
		current_throwable = null
		focused = false
		interacting = false
		enabled = true
		
		throwable.unfocused.emit(self)

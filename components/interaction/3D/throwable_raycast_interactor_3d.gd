class_name ThrowableRayCastInteractor extends RayCast3D


@export var interact_action := "interact"
@export var input_action_to_cancel := "cancel_interaact"

var focused := false
var interacting := false
var current_throwable: Throwable3D

## This interactor only detects the throwables in the world as the Telekinesis3D is the one that make the actions

func _enter_tree() -> void:
	enabled = true
	exclude_parent = true
	collision_mask = GameGlobals.world_collision_layer | GameGlobals.enemies_collision_layer | GameGlobals.throwables_collision_layer
	collide_with_areas = false
	collide_with_bodies = true


func _physics_process(_delta):
	var detected_throwable = get_collider() if is_colliding() else null
	
	if detected_throwable is Throwable3D:
		if current_throwable == null and not focused:
			focus(detected_throwable)
	else:
		if focused and not interacting and current_throwable:
			unfocus(current_throwable)


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

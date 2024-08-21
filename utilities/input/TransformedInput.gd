class_name TransformedInput

var move_right_action := "move_right"
var move_left_action := "move_left"
var move_forward_action := "move_forward"
var move_back_action := "move_back"

var actor: Node
var deadzone := 0.5:
	set(value):
		deadzone = clamp(value, 0.0, 1.0)

#region Current input
var input_direction: Vector2
var input_direction_deadzone_square_shape: Vector2
var input_direction_horizontal_axis: float
var input_direction_vertical_axis: float
var input_direction_horizontal_axis_applied_deadzone: float
var input_direction_vertical_axis_applied_deadzone: float
var world_coordinate_space_direction: Vector3
#endregion

#region Previous input
var previous_input_direction: Vector2
var previous_input_direction_deadzone_square_shape: Vector2
var previous_input_direction_horizontal_axis: float
var previous_input_direction_vertical_axis: float
var previous_input_direction_horizontal_axis_applied_deadzone: float
var previous_input_direction_vertical_axis_applied_deadzone: float
var previous_world_coordinate_space_direction: Vector3
#endregion

func _init(_actor: Node, _deadzone: float = deadzone):
	assert(_actor is Node2D or _actor is Node3D, "TransformedInputDirection: The actor needs to inherit from Node2D or Node3D to retrieve the input correctly")
	
	actor = _actor
	deadzone = _deadzone


func update_input_direction():
	_update_previous_directions()
	# This handles deadzone in a correct way for most use cases. The resulting deadzone will have a circular shape as it generally should.
	input_direction = Input.get_vector(move_left_action, move_right_action, move_forward_action, move_back_action)
	
	if actor is Node3D:
		world_coordinate_space_direction = actor.transform.basis * Vector3(input_direction.x, 0, input_direction.y).normalized()
	
	input_direction_deadzone_square_shape = Vector2(
		Input.get_action_strength(move_right_action) - Input.get_action_strength(move_left_action),
		Input.get_action_strength(move_back_action) - Input.get_action_strength(move_forward_action)
	).limit_length(deadzone)	
	
	input_direction_horizontal_axis = Input.get_axis(move_left_action, move_right_action)
	input_direction_vertical_axis = Input.get_axis(move_forward_action, move_back_action)
	
	input_direction_horizontal_axis_applied_deadzone = input_direction_horizontal_axis * (1.0 - deadzone)
	input_direction_vertical_axis_applied_deadzone = input_direction_vertical_axis * (1.0 - deadzone)


func _update_previous_directions():
	previous_input_direction = input_direction
	previous_world_coordinate_space_direction = world_coordinate_space_direction
		
	previous_input_direction_deadzone_square_shape = input_direction_deadzone_square_shape
		
	previous_input_direction_horizontal_axis = input_direction_horizontal_axis
	previous_input_direction_vertical_axis = input_direction_vertical_axis
		
	previous_input_direction_horizontal_axis_applied_deadzone = input_direction_horizontal_axis_applied_deadzone
	previous_input_direction_vertical_axis_applied_deadzone = input_direction_vertical_axis_applied_deadzone


#region Action setters
func change_move_right_action(new_action: String) -> TransformedInput:
	move_right_action = new_action
	
	return self


func change_move_left_action(new_action: String) -> TransformedInput:
	move_left_action = new_action
	
	return self


func change_move_forward_action(new_action: String) -> TransformedInput:
	move_forward_action = new_action
	
	return self


func change_move_back_action(new_action: String) -> TransformedInput:
	move_back_action = new_action
	
	return self
#endregion

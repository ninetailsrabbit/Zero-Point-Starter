@icon("res://components/motion/2D/follow/follow_component.svg")
class_name FollowComponent2D extends Node2D

signal enabled
signal disabled

@export var actor: Node2D
@export var target: Node2D:
	set(value):
		target = value
		active = target is Node2D and speed > 0
@export var distance_to_target := 25.0
@export var mode := FollowModes.Normal
@export var speed := 5.0:
	set(value):
		speed = max(0.0, absf(value))
		set_process(active and speed > 0)
		
@export var rotation_speed := 1.0
@export var angle_offset := 0.0


enum FollowModes {
	Snake,
	ConstantSpeed,
	Normal
}

var offset := Vector2.ZERO
var target_rotation := 0.0
var target_position := Vector2.ZERO
var active := false:
	set(value):
		if value != active:
			if value:
				enabled.emit()
			else:
				disabled.emit()
		
		active = value
		set_process(active and speed > 0)
				

func _ready():
	if actor == null:
		actor = get_parent()
		
	assert(actor is Node2D, "FollowComponent2D: This component needs a valid Node2D actor to apply the follow behaviour")
	assert(target is Node2D, "FollowComponent2D: This component needs a valid Node2D to follow")
	
	set_process(active and speed > 0)
	

func _process(delta):
	update_target_parameters()
	
	if NodePositioner.global_distance_to_v2(actor, target) >= distance_to_target:
		if is_snake_mode():
			target_rotation = lerp(actor.global_rotation, target_rotation, delta * rotation_speed)
			target_position = lerp(global_position, target_position, delta * speed)

			actor.global_rotation = target_rotation
			actor.global_position = target_position

		elif is_constant_mode():
			offset = global_position.direction_to(target.global_position) * delta * speed
			actor.global_position += offset
			
		elif is_normal_mode():
			offset = Vector2.RIGHT.rotated(deg_to_rad(angle_offset)) * distance_to_target
			actor.global_position = lerp(global_position, target.global_position + offset, delta * speed)
		


func update_target_parameters():
	offset = -target.transform.x * distance_to_target
	target_rotation = global_position.direction_to(target.global_position).angle()
	target_position = target.global_position + offset


func is_snake_mode() -> bool:
	return mode == FollowModes.Snake
	
	
func is_constant_mode() -> bool:
	return mode == FollowModes.ConstantSpeed
	

func is_normal_mode() -> bool:
	return mode == FollowModes.Normal
	

func enable():
	active = true
	

func disable():
	active = false

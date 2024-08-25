@icon("res://components/motion/3D/movement/dungeon_grid_movement.svg")
class_name DungeonGridMovement3D extends Node

@export var target: Node3D
@export var cell_travel_size := 2
@export var movement_animation_time := 0.3

var tween_movement: Tween

const direction_mapper := {
	Vector2.UP: Vector3.FORWARD,
	Vector2.DOWN: Vector3.BACK,
	Vector2.RIGHT: Vector3.RIGHT,
	Vector2.LEFT: Vector3.LEFT,
}

func _ready():
	if target == null:
		target = get_parent() as Node3D
	
	assert(target is Node3D, "DungeonGridMovement3D: This component needs a Node3D target to apply the dungeon crawler movement")
	

func move(direction: Vector2):
	if _can_move(direction):
		var local_vector: Vector3 = direction_mapper[direction.normalized()]
		
		tween_movement = create_tween()
		tween_movement.tween_property(target, "transform", target.transform.translated_local(local_vector * cell_travel_size), movement_animation_time)\
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			

func rotate(direction: Vector2):
	if _can_rotate(direction):
		tween_movement = create_tween()
		tween_movement.tween_property(target, "transform:basis", target.transform.basis.rotated(Vector3.UP, -sign(direction.x) * PI / 2), movement_animation_time)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func _can_move(direction: Vector2) -> bool:
	return target and _tween_can_run()


func _can_rotate(direction: Vector2) -> bool:
	return target and _tween_can_run() and direction in [Vector2.LEFT, Vector2.RIGHT]
	

func _tween_can_run() -> bool:
	return (tween_movement == null or (tween_movement and not tween_movement.is_running()))

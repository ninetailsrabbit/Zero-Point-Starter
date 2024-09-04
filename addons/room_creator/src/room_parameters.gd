@tool
class_name RoomParameters extends Resource

@export_range(1, 1000, 1) var number_of_rooms_per_generation: int = 5
@export_range(1, 4, 1) var doors_per_room: int = 2
@export var use_bridge_connector_between_rooms : bool = false
@export var randomize_door_position_in_wall: bool = false
## Decimal values are rounded when generate betwen a min-max size range
@export var use_integer_values_size: bool = true
@export_group("Size")
@export var door_size: Vector3 = Vector3(1.5, 2.0, 0.25)
@export var min_bridge_connector_size: Vector3 = Vector3(2.0, 3.0, 4.0)
@export var max_bridge_connector_size: Vector3 = Vector3(2.0, 3.0, 10.0)
@export var min_room_size: Vector3 = Vector3(6.0, 3.5, 5.0)
@export var max_room_size: Vector3 = Vector3(10.0, 5.0, 6.0)
@export_group("Thickness")
@export var wall_thickness: float = 0.15
@export var ceil_thickness: float = 0.1
@export var floor_thickness: float = 0.1
@export_group("Ceil columns")
@export var include_ceil_columns: bool = false
@export var ceil_column_height: float = 0.30
@export var ceil_column_thickness: float = 0.30

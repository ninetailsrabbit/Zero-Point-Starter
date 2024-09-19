class_name NewTelekinesis extends Node3D

class ActiveGrabbable extends RefCounted:
	func _init(_grabbable: Grabbable3D, _slot: Node3D):
		body = _grabbable
		slot = _slot
		
	var body: Grabbable3D
	var slot: Node3D
	
	
signal pulled_grabbable(body: Grabbable3D)
signal throwed_grabbable(body: Grabbable3D)
signal dropped_grabbable(body: Grabbable3D)

## The available slots to put the grabbables when pulled
@export var available_slots: Array[Marker3D] = []
@export var mass_lift_force: float= 10.0
@export_group("Input Actions")
@export var pull_input_action: String = "pull"
@export var pull_area_input_action: String = "pull_area"
@export var drop_input_action: String = "drop"
@export var throw_input_action: String = "throw"
@export_group("Abilities")
@export var pull_individual_ability: bool = true
@export var pull_area_ability: bool = true
@export var push_wave_ability: bool = true
@export_group("Interactor")
## The raycast that interacts with grabbables to detect them
@export var grabbable_interactor: GrabbableRayCastInteractor
## The current distance applied to the interactor instead of manually change it on raycast properties
@export_range(0.1, 100.0, 0.01) var grabbable_interactor_distance = 6.0:
	set(value):
		if grabbable_interactor is GrabbableRayCastInteractor and grabbable_interactor_distance != value:
			_prepare_grabbable_interactor(value)
			
		grabbable_interactor_distance = clamp(value, 0.1, 100.0)
@export_group("Area detector")
@export var grabbable_area_detector: Area3D:
	set(value):
		if value is Area3D:
			grabbable_area_detector = value
			_prepare_grabbable_area_detector()
			
@export var max_number_of_grabbables: int = 2

var active_grabbables: Array[ActiveGrabbable] = []


func _input(_event: InputEvent) -> void:
	if pull_individual_ability and InputHelper.action_just_pressed_and_exists(pull_input_action):
		if slots_available():
			if grabbable_interactor and grabbable_interactor.is_colliding():
				var body = grabbable_interactor.get_collider() as Grabbable3D
				
				if body and body.state_is_neutral():
					pull_body(body)
	
	if pull_area_ability and InputHelper.action_just_pressed_and_exists(pull_area_input_action) and slots_available():
		var grabbables := get_near_grabbables()

		for body: Grabbable3D in grabbables:
			pull_body(body)
			
		grabbable_area_detector.monitoring = grabbables.is_empty()
		
				
	## TODO - SEE A WAY TO DROP A SELECTED GRABBABLE
	if InputHelper.action_just_pressed_and_exists(drop_input_action):
		for active_grabbable: ActiveGrabbable in active_grabbables:
			drop_body(active_grabbable.body)
			
	elif InputHelper.action_just_pressed_and_exists(throw_input_action):
		for active_grabbable: ActiveGrabbable in active_grabbables:
			throw_body(active_grabbable.body)
	

func _enter_tree() -> void:
	throwed_grabbable.connect(on_throwed_grabbable)
	dropped_grabbable.connect(on_dropped_grabbable)


func _ready() -> void:
	_prepare_available_slots()
	set_physics_process(false)
	

func _physics_process(_delta: float):
	for active_grabbable: ActiveGrabbable in active_grabbables:
		pull_force(active_grabbable.body)
		
		
func pull_body(body: Grabbable3D, grabber: Node3D = get_random_free_slot()):
	if body_can_be_lifted(body) and slots_available():
		body.pull(grabber)
		active_grabbables.append(ActiveGrabbable.new(body, grabber))
		pulled_grabbable.emit(body)
		set_physics_process(true)
	else:
		set_physics_process(false)

	
func pull_force(body: Grabbable3D):
	body.update_linear_velocity()
	body.update_angular_velocity()


func throw_body(body: Grabbable3D) -> void:
	active_grabbables = active_grabbables.filter(func(active_grabbable: ActiveGrabbable): return active_grabbable.body != body)
	body.throw()
	throwed_grabbable.emit(body)
	
	set_physics_process(active_grabbables.size() > 0)
	
	
func drop_body(body: Grabbable3D) -> void:
	active_grabbables = active_grabbables.filter(func(active_grabbable: ActiveGrabbable): return active_grabbable.body != body)
	body.drop()
	dropped_grabbable.emit(body)
	
	set_physics_process(active_grabbables.size() > 0)
	

func get_near_grabbables() -> Array:
	if grabbable_area_detector and grabbable_area_detector.monitoring:
		var bodies := grabbable_area_detector.get_overlapping_bodies().filter(func(body): return body is Grabbable3D)
		bodies.sort_custom(func(a: Grabbable3D, b: Grabbable3D): return NodePositioner.global_distance_to_v3(a, self) <= NodePositioner.global_distance_to_v3(b, self))
		return bodies.slice(0, max_number_of_grabbables)
		
	return []


func body_can_be_lifted(body: Grabbable3D) -> bool:
	return body.mass <= mass_lift_force


#region Slot related
func slots_available() -> bool:
	return available_slots.size() > 0 and active_grabbables.size() != available_slots.size()
	

func get_random_free_slot() -> Marker3D:
	if not slots_available():
		return null
	
	var busy_slots := active_grabbables.map(
			func(active_grabbable: ActiveGrabbable): return active_grabbable.slot
		)
	
	return available_slots.filter(func(slot: Marker3D): return not slot in busy_slots ).pick_random()


func _prepare_available_slots():
	if available_slots.is_empty():
		for child in get_children():
			if child is Marker3D:
				available_slots.append(child)

#endregion	

func _prepare_grabbable_interactor(distance: float = grabbable_interactor_distance):
	if grabbable_interactor and distance >= 0.1:
		grabbable_interactor.target_position = Vector3.FORWARD * distance


func _prepare_grabbable_area_detector():
	if grabbable_area_detector:
		grabbable_area_detector.monitorable = false
		grabbable_area_detector.monitoring = true
		grabbable_area_detector.priority = 2
		grabbable_area_detector.collision_layer = 0
		grabbable_area_detector.collision_mask = GameGlobals.throwables_collision_layer


#region Signal callbacks
func on_dropped_grabbable(_grabbable: Grabbable3D) -> void:
	if grabbable_area_detector:
		grabbable_area_detector.monitoring = true


func on_throwed_grabbable(_grabbable: Grabbable3D) -> void:
	if grabbable_area_detector:
		grabbable_area_detector.monitoring = true
#endregion

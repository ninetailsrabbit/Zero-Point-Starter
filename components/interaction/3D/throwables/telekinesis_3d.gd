@icon("res://components/interaction/3D/throwables/telekinesis.svg")
class_name Telekinesis3D extends Node3D

signal pulled_throwable(body: Throwable3D)
signal throwed_throwable(body: Throwable3D)

@export var actor: CharacterBody3D
@export var pull_input_action := "pull"
@export var throw_input_action := "throw"
@export var pull_area_input_action := "pull_area"
@export var push_wave_input_action := "push_wave"
@export var pull_individual_ability := true
@export var pull_area_ability := true
@export var push_wave_ability := true
## The raycast that interacts with throwables to detect them
@export var throwable_interactor: RayCast3D
## The current distance applied to the interactor instead of manually change it on raycast properties
@export_range(0.1, 100.0, 0.01) var throwable_interactor_distance = 5.0:
	set(value):
		if throwable_interactor is RayCast3D and throwable_interactor_distance != value:
			_prepare_throwable_interactor(value)
			
		throwable_interactor_distance = clamp(value, 0.1, 100.0)
## The area that can detect multiple throwables in a sphere around the actor
@export var throwable_area_detector: Area3D:
	set(value):
		if value is Area3D:
			_prepare_throwable_area_detector()
			
		throwable_area_detector = value
## The initial pull power to attract and manipulate throwables
@export var pull_power := 15.0
## The initial throw power to apply force impulses to throwables
@export var throw_power := 10.0
## The limit mass that this telekinesis can grab or throw
@export var mass_lift_force := 1.5
## Rotation force to apply
@export var angular_power = 1.5
## The available slots to put the throwables when pulled
@export var available_slots: Array[Marker3D] = []


class ActiveThrowable extends RefCounted:
	func _init(_throwable: Throwable3D, _slot: Marker3D):
		body = _throwable
		slot = _slot
		
	var body: Throwable3D
	var slot: Marker3D
	
	
var active_throwables: Array[ActiveThrowable] = []


func _unhandled_input(_event: InputEvent):
	if push_wave_ability and active_throwables.is_empty() and InputHelper.action_just_pressed_and_exists(push_wave_input_action):
		push_wave()
		
	elif InputHelper.action_just_pressed_and_exists(throw_input_action):		
		for active_throwable: ActiveThrowable in active_throwables:
			if active_throwable and body_can_be_lifted(active_throwable.body):
				throw_body(active_throwable.body)
		
	elif pull_individual_ability and InputHelper.action_just_pressed_and_exists(pull_input_action):
		if active_throwables.is_empty():
			if throwable_interactor and throwable_interactor.is_colliding():
				var body = throwable_interactor.get_collider() as Throwable3D
				
				if body and body_can_be_lifted(body):
					pull_body(body)
		else:
			for active_throwable: ActiveThrowable in active_throwables:
				active_throwable.body.drop()
				
			active_throwables.clear()
		
	elif pull_area_ability and InputHelper.action_just_pressed_and_exists(pull_area_input_action):
		for body: Throwable3D in get_near_throwables():
			if body and body_can_be_lifted(body):
				pull_body(body)
		

func _ready():
	_prepare_throwable_interactor()
	_prepare_throwable_area_detector()
	_prepare_available_slots()
	

func _physics_process(delta):
	for active_throwable: ActiveThrowable in active_throwables:
		pull_force_based_on_throwable_mode(active_throwable.body, delta)


func push_wave():
	if push_wave_ability:
		var wave = PushWaveArea.new(self, Camera3DHelper.forward_direction(get_viewport().get_camera_3d()))
		add_child(wave)
		wave.activate()
	
	
func pull_body(body: Throwable3D):
	if slots_available():
		if not body.locked:
			set_physics_process(true)
			var free_slot = get_random_free_slot()
			
			if free_slot:
				body.pull(free_slot)
				active_throwables.append(ActiveThrowable.new(body, free_slot))
				pulled_throwable.emit(body)
	else:
		set_physics_process(false)
		
		if throwable_interactor:
			throwable_interactor.enabled = false
			
		if throwable_area_detector:
			throwable_area_detector.monitoring = false
	
		
func throw_body(body: Throwable3D):
	active_throwables = active_throwables.filter(func(active_throwable: ActiveThrowable): return active_throwable.body != body)
	
	var impulse := Camera3DHelper.forward_direction(get_viewport().get_camera_3d()) * throw_power
	
	body.throw(impulse)
	body.angular_velocity = Vector3.ONE * angular_power
	
	if throwable_interactor:
		throwable_interactor.enabled = active_throwables.size() < available_slots.size()
		
	if throwable_area_detector:
		throwable_area_detector.monitoring = active_throwables.size() < available_slots.size()
	
	throwed_throwable.emit(body)


func pull_force_based_on_throwable_mode(body: Throwable3D, delta: float = get_physics_process_delta_time()):
	if body is Throwable3D:
		if body.grab_mode_is_dynamic():
			body.update_linear_velocity((body.grabber.global_position - body.global_position) * pull_power)
		else:
			body.global_position = body.global_position.move_toward(body.grabber.global_position, delta * pull_power)


func get_random_free_slot() -> Marker3D:
	if not slots_available():
		return null
	
	var busy_slots := active_throwables.map(
			func(active_throwable: ActiveThrowable): return active_throwable.slot
		)
	
	return available_slots.filter(func(slot: Marker3D): return not slot in busy_slots ).pick_random()


func get_near_throwables() -> Array:
	if throwable_area_detector:
		var bodies := throwable_area_detector.get_overlapping_bodies().filter(func(body): return body is Throwable3D)
		bodies.sort_custom(func(a: Throwable3D, b: Throwable3D): return NodePositioner.global_distance_to_v3(a, actor) <= NodePositioner.global_distance_to_v3(b, actor))	
		return bodies
		
	return []


func body_can_be_lifted(body: Throwable3D) -> bool:
	return body.mass <= mass_lift_force


func slots_available() -> bool:
	return available_slots.size() > 0 and active_throwables.size() != available_slots.size()
	
	
func _prepare_available_slots():
	if available_slots.is_empty():
		for child in get_children():
			if child is Marker3D:
				available_slots.append(child)
		

func _prepare_throwable_interactor(distance: float = throwable_interactor_distance):
	if throwable_interactor and distance >= 0.1:
		throwable_interactor.collide_with_bodies = true
		throwable_interactor.collide_with_areas = false
		throwable_interactor.collision_mask = GameGlobals.throwables_collision_layer
		throwable_interactor.target_position = Vector3.FORWARD * distance
	
	
func _prepare_throwable_area_detector():
	if throwable_area_detector:
		throwable_area_detector.monitorable = false
		throwable_area_detector.monitoring = true
		throwable_area_detector.priority = 2
		throwable_area_detector.collision_layer = 0
		throwable_area_detector.collision_mask = GameGlobals.throwables_collision_layer

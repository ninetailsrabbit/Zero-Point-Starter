class_name PushWaveArea extends Area3D

signal activated

@export var telekinesis: Telekinesis3D
@export var pushable_bodies := 7
@export var min_push_force = 5.0
@export var max_push_force = 20.0
@export var min_upward_force := 0.1
@export var max_upward_force := 1.0
@export var wave_speed := 2.0
@export var wave_radius := 5.0
@export var time_alive := 1.0

var active := false:
	set(value):
		monitoring = value
		set_physics_process(value)
		
	
var direction := Vector3.FORWARD
var bodies_pushed := {}
var rng = RandomNumberGenerator.new()
var alive_timer: Timer


func _init(_telekinesis: Telekinesis3D, _direction: Vector3):
	telekinesis = _telekinesis
	direction = _direction
	
	
func _ready():
	monitorable = false
	monitoring = active
	collision_layer = 0
	collision_mask = GameGlobals.world_collision_layer | GameGlobals.enemies_collision_layer | GameGlobals.throwables_collision_layer
	
	linear_damp_space_override = Area3D.SPACE_OVERRIDE_COMBINE
	linear_damp = 0.5
	angular_damp_space_override = Area3D.SPACE_OVERRIDE_COMBINE
	angular_damp = 0.5

	var collision = CollisionShape3D.new()
	collision.shape = SphereShape3D.new()
	collision.shape.radius = wave_radius
	
	add_child(collision)
	_create_alive_timer()
	set_physics_process(active)


func _physics_process(_delta):
	global_position += wave_speed * direction;
	push_bodies_on_range();
	
	
func activate():
	if is_instance_valid(alive_timer):
		alive_timer.start()
		
	if not active:
		activated.emit()
		
	active = true
	
	
func push_bodies_on_range():
	for body: RigidBody3D in get_overlapping_bodies().filter(func(detected_body): return detected_body is RigidBody3D and not bodies_pushed.has(detected_body.name)):
		var upward_offset = Vector3.ZERO if max_upward_force == 0 else (Vector3.UP if telekinesis.actor == null else telekinesis.actor.up_direction) * rng.randf_range(min_upward_force, max_upward_force)
		bodies_pushed[body.name] = body
		body.angular_velocity = VectorHelper.generate_3d_random_fixed_direction() * rng.randf_range(0.5, 1.0)
		body.apply_impulse(VectorHelper.rotate_horizontal_random(direction) * rng.randf_range(min_push_force, max_push_force), -body.position.normalized() + upward_offset)

	
	active = bodies_pushed.size() < pushable_bodies
	
	
func _create_alive_timer():
	if alive_timer == null:
		alive_timer = Timer.new()
		alive_timer.name = "PushWaveAliveTimer"
		alive_timer.wait_time = max(0.05, time_alive)
		alive_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS
		alive_timer.autostart = false
		alive_timer.one_shot = true
		
		add_child(alive_timer)
		alive_timer.timeout.connect(on_alive_timer_timeout)
		
		
func on_alive_timer_timeout():
	queue_free()

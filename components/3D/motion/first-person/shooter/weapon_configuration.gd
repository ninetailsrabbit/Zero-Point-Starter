class_name WeaponConfiguration extends Resource

enum BurstTypes {
	Single, # One round per trigger pull.
	Automatic, # Continuous fire as long as the trigger is held down.
	SemiAutomatic, # One round per trigger pull, but the trigger must be released and pulled again for each shot.
	BurstFire, # A fixed number of rounds fired in a single trigger pull.
	ThreeRoundBurst, # A specific type of burst-fire that fires three rounds per trigger pull.
	FiveRoundBurst, # A specific type of burst-fire that fires five rounds per trigger pull.
}

@export_group("Ammo")
## The initial ammunition when this weapon is pickup
@export var initial_ammunition: int = 0
## Max ammunition that this weapon can carry
@export var max_ammunition: int = 0
## when reach zero reloads automatically until this amount with this quantity with the remaining ammunition available
@export var ammunition_per_round: int = 0
@export_range(0, 100, 0.1) var accuracy: float = 80.0
@export var reload_time: float = 2.0
@export var time_between_shoots: float = 0.2
@export var fire_range: float = 250
@export var burst_type: BurstTypes = BurstTypes.Single
## Only applies on BurstTypes.BurstFire selected type
@export var number_of_shoots: int = 1
@export var rounds_fired_per_shoot: int = 1
@export_group("Features")
@export var camera_shake_enabled: bool = true
@export var camera_shake_magnitude: float = 0.01
@export var camera_shake_time: float = 0.1
@export_range(0, 179, 0.1) var zoom_level_on_aim: float = 65
@export_range(0, 100, 0.1) var durability: float = 95.0
@export_category("Recoil")
@export var recoil_enabled: bool = true
@export var recoil_amount: Vector3 = Vector3.ZERO
@export var recoil_lerp_speed: float = 8.0
@export var recoil_snap_amount: float = 6.0
@export_group("Sway")
@export var weapon_sway_amount: float = 0.25
@export var weapon_rotation_amount: float = 5.0
@export var weapon_sway_lerp_speed: float = 8.0
@export var invert_weapon_sway : bool = true
@export_group("Bob")
@export var enable_bob: bool = true
@export var bob_amount: float = 0.02
@export var bob_freq : float = 0.01
@export var bob_lerp_speed: float = 12.0

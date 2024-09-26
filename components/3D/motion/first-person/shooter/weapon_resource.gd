class_name WeaponResource extends Resource

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
@export_group("Fire")
@export_range(0, 100, 0.1) var accuracy: float = 80.0
@export var reload_speed: float = 1.0
@export var fire_range: float = 250
@export var burst_type: BurstTypes = BurstTypes.Single
## Only applies on BurstTypes.BurstFire selected type
@export var rounds_fired: int = 2
@export_group("Features")
@export_range(0, 179, 0.1) var zoom_level: float = 65
@export_range(0, 100, 0.1) var durability: float = 95.0
@export_category("Recoil")
@export var recoil_enabled: bool = true
@export var recoil_rotation_x : Curve
@export var recoil_rotation_z : Curve
@export var recoil_position_z : Curve
@export var recoil_amplitude := Vector3(1, 1, 1)
@export var camera_shake_magnitude: float = 0.01
@export var camera_shake_time: float = 0.1
@export var recoil_lerp_speed : float = 8
@export var recoil_speed : float = 1

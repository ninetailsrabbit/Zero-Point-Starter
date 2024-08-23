extends Control

@export var show_hardware_specs_input_action = "show_hardware_specs"

@onready var fps_label: Label = %FPSLabel
@onready var vsync_label: Label = %VsyncLabel
@onready var memory_label: Label = %MemoryLabel
@onready var os_label: Label = %OSLabel
@onready var distro_label: Label = %DistroLabel
@onready var cpu_label: Label = %CPULabel
@onready var gpu_label: Label = %GPULabel


func _input(event: InputEvent) -> void:
	if InputMap.has_action(show_hardware_specs_input_action) and Input.is_action_just_pressed(show_hardware_specs_input_action):
		visible = !visible


func _ready() -> void:
	hide()
	
	vsync_label.text = "Vsync: %s" % ("Yes" if DisplayServer.window_get_vsync_mode() > 0 else "No")
	os_label.text = "OS: %s" % HardwareDetector.platform
	distro_label.text = "Distro: %s" % HardwareDetector.distribution_name
	cpu_label.text = "CPU: %s" % HardwareDetector.processor_name
	gpu_label.text = "GPU: %s" % HardwareDetector.video_adapter_name
	
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	memory_label.text = "Memory: %d MiB" % (OS.get_static_memory_usage() / 1048576.0)
	
	

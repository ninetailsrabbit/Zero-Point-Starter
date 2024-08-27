extends Control

@export var input_actions_to_cancel_scan: Array[String] = ["cancel_interaction"]
@export var scan_viewport_3d_scene: PackedScene = Preloader.ScanViewport3DScene

@onready var scan_subviewport: SubViewport = %ScanSubViewport
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_label: Label = %DescriptionLabel

var current_interactable: Interactable3D
var from_camera: Camera3D


func _input(event: InputEvent) -> void:
	if InputHelper.is_any_action_just_pressed(event, input_actions_to_cancel_scan) and current_interactable:
		cancel_scan(current_interactable)


func _ready() -> void:
	hide()
	
	title_label.text = ""
	description_label.text = ""
	
	GlobalGameEvents.interactable_interacted.connect(on_scan_requested)


func display_scan_information(interactable: Interactable3D = current_interactable) -> void:
	if interactable:
		title_label.text = tr(interactable.title_translation_key)
		description_label.text = tr(interactable.description_translation_key)
		LabelHelper.adjust_text(description_label)


func enable_blur_on_active_camera() -> void:
	from_camera =  get_viewport().get_camera_3d()
	
	var camera_attributes = from_camera.attributes as CameraAttributesPractical
	
	if camera_attributes == null:
		camera_attributes = from_camera.attributes as CameraAttributesPhysical
		
		if camera_attributes == null:
			camera_attributes = CameraAttributesPractical.new()
		
	camera_attributes.dof_blur_far_enabled = true
	camera_attributes.dof_blur_far_distance = 5.0

	from_camera.attributes = camera_attributes
		

func disable_blur_on_from_camera() -> void:
	if from_camera and from_camera.attributes:
		from_camera.attributes.dof_blur_far_enabled = false


func cancel_scan(interactable: Interactable3D = current_interactable) -> void:
	if interactable and scan_subviewport.get_child_count() > 0:
		disable_blur_on_from_camera()
		CursorManager.return_cursor_to_default()
		
		NodeRemover.remove_and_queue_free_children(scan_subviewport)
		
		title_label.text = ""
		description_label.text = ""
		
		current_interactable.canceled_interaction.emit()
		GlobalGameEvents.canceled_interactable_scan.emit(current_interactable)
		current_interactable = null
		
		hide()
		set_process_input(false)


func on_scan_requested(interactable: Interactable3D) -> void:	
	if interactable.scannable:
		current_interactable = interactable
		enable_blur_on_active_camera()
		show()
		set_process_input(true)
		InputHelper.show_mouse_cursor()
		
		var target_to_scan = interactable.target_scannable_object.duplicate()
		
		var scan_viewport_3d: ScanViewport3D = scan_viewport_3d_scene.instantiate() as ScanViewport3D
		scan_subviewport.add_child(scan_viewport_3d)
		scan_viewport_3d.marker_3d.add_child(target_to_scan)
		target_to_scan.position = Vector3.ZERO
		
		scan_viewport_3d.mouse_rotator_component_3d.target = target_to_scan
		
		if interactable.can_be_rotated_on_scan:
			scan_viewport_3d.mouse_rotator_component_3d.enable()
		
		if interactable.interact_cursor:
			scan_viewport_3d.set_current_mouse_cursor(interactable.interact_cursor)
			scan_viewport_3d.change_mouse_cursor(interactable.interact_cursor)
			
		if interactable.scan_rotate_cursor:
			scan_viewport_3d.change_rotate_cursor(interactable.scan_rotate_cursor)
		
		display_scan_information(interactable)

		

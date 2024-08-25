extends Control

@export var input_actions_to_cancel_scan: Array[String] = ["cancel_interaction"]
@export var scan_viewport_3d_scene: PackedScene = Preloader.ScanViewport3DScene
@onready var scan_sub_viewport: SubViewport = %ScanSubViewport
@onready var title_label: RichTextLabel = %TitleLabel
@onready var description_label: Label = %DescriptionLabel


var current_interactable: Interactable3D

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
		

func cancel_scan(interactable: Interactable3D = current_interactable) -> void:
	if interactable and scan_sub_viewport.get_child_count() > 0:
		var scan_viewport: ScanViewport3D = scan_sub_viewport.get_child(0) as ScanViewport3D
		scan_viewport.mouse_rotator_component_3d.reset_to_default_cursors()
		NodeRemover.remove_and_queue_free_children(scan_sub_viewport)
		
		title_label.text = ""
		description_label.text = ""
		
		GlobalGameEvents.canceled_interactable_scan.emit(current_interactable)
		
		current_interactable = null
		hide()
		set_process_input(false)


func on_scan_requested(interactor) -> void:
	if interactor and interactor.current_interactable and interactor.current_interactable.scannable:
		print("jaja")
		show()
		set_process_input(true)

		current_interactable = interactor.current_interactable
		
		var target_to_scan = current_interactable.target_scannable_object
		
		var scan_viewport_3d: ScanViewport3D = scan_viewport_3d_scene.instantiate() as ScanViewport3D
		scan_sub_viewport.add_child(scan_viewport_3d)
		scan_viewport_3d.marker_3d.add_child(target_to_scan.duplicate())
		
		scan_viewport_3d.mouse_rotator_component_3d.target = target_to_scan
		
		if current_interactable.can_be_rotated_on_scan:
			scan_viewport_3d.mouse_rotator_component_3d.enable()
		
		if current_interactable.interact_cursor:
			scan_viewport_3d.set_current_mouse_cursor(current_interactable.interact_cursor)
			scan_viewport_3d.change_mouse_cursor(current_interactable.interact_cursor)
			
		if current_interactable.scan_rotate_cursor:
			scan_viewport_3d.change_rotate_cursor(current_interactable.scan_rotate_cursor)
		
		display_scan_information(current_interactable)

		

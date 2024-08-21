class_name ContentWarning extends Resource

@export var can_be_skipped := false;
@export_group("Time")
@export var time_on_screen := 5.0;
@export var time_to_display_content_warning = 2.0;
@export var time_to_hide_content_warning = 2.0;
@export_group("Original text")
@export var title := ""
@export var subtitle := ""
@export var description := ""
@export var secondary_description := ""
@export_group("Translation keys")
@export var title_translation_key := ""
@export var subtitle_translation_key := ""
@export var description_translation_key := ""
@export var secondary_description_translation_key := ""

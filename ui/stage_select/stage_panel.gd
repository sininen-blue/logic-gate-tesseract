extends Panel

const LEVEL_SCENE: String = "uid://yrih2e5sant0"
const CUSTOM_LEVEL_SCENE: String = "uid://bwlvlfljyekts"

@export var level_dict: Dictionary
@export var completed_levels: int
@export var total_levels: int

var dir : DirAccess

@onready var title_label: Label = $TitleLabel
@onready var description_label: Label = $ScrollContainer/DescriptionLabel
@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	title_label.text = level_dict["title"]
	description_label.text = level_dict["description"]
	progress_bar.value = completed_levels
	progress_bar.max_value = total_levels


func _on_play_button_pressed() -> void:
	DataManager.current_stage = dir
	if level_dict["title"] == "Custom Levels":
		get_tree().change_scene_to_file(CUSTOM_LEVEL_SCENE)
	else:
		get_tree().change_scene_to_file(LEVEL_SCENE)

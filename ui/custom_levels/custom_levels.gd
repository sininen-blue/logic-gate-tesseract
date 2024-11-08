extends Control

const CREATE_CUSTOM_SCENE: String = "uid://c20nqruvjtxah"
const CUSTOM_STAGE_PANEL: PackedScene = preload("uid://le7ov2wv1ds0")

var stage_dir : DirAccess = DataManager.current_stage

@onready var create_custom_button: Button = $ScrollContainer/LevelsContainer/CreateCustomButton
@onready var back_button: Button = $BackButton
@onready var levels_container: VBoxContainer = $ScrollContainer/LevelsContainer

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://b1xu7c0fhg4at")


func _ready() -> void:
	create_custom_button.pressed.connect(get_tree().change_scene_to_file.bind(CREATE_CUSTOM_SCENE))
	
	if stage_dir.get_files().is_empty():
		return
	
	var all_levels: Array[Dictionary] = []
	for level in stage_dir.get_files():
		## NOTE: no checking for whether or not it's a valid level
		## should check it in level file
		var level_file : FileAccess = FileAccess.open("user://levels/custom_levels/"+level, FileAccess.READ)
		var level_data : Dictionary = JSON.parse_string(level_file.get_as_text())
		all_levels.append(level_data)
	
	if all_levels.is_empty():
		return
	
	all_levels.sort_custom(sort_time_descending)
	for level in all_levels:
		var new_panel : Panel = CUSTOM_STAGE_PANEL.instantiate()
		new_panel.level_data = level
		levels_container.add_child(new_panel)

func sort_time_descending(a: Dictionary, b: Dictionary) -> bool:
	return int(a["create_date"]) > int(b["create_date"])

extends Control


var stage_dir : DirAccess = DataManager.current_stage

@onready var create_custom: PackedScene = preload("uid://c20nqruvjtxah")
@onready var custom_stage_panel: PackedScene = preload("uid://le7ov2wv1ds0")

@onready var create_custom_button: Button = $ScrollContainer/LevelsContainer/CreateCustomButton
@onready var back_button: Button = $BackButton
@onready var levels_container: VBoxContainer = $ScrollContainer/LevelsContainer

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://b1xu7c0fhg4at")


func _ready() -> void:
	create_custom_button.pressed.connect(get_tree().change_scene_to_packed.bind(create_custom))
	
	for level in stage_dir.get_files():
		var new_panel : Panel = custom_stage_panel.instantiate()
		
		var pwd : String = stage_dir.get_current_dir() + "/"
		var level_file : FileAccess = FileAccess.open(pwd+level, FileAccess.READ)
		var level_data : Dictionary = JSON.parse_string(level_file.get_as_text())
		
		new_panel.level_data = level_data
		levels_container.add_child(new_panel)

extends Control

@export var stage_select: PackedScene
@export var create_custom : PackedScene
@export var custom_stage_panel : PackedScene

var stage_dir : DirAccess = DataManager.current_stage

@onready var create_custom_button: Button = $LevelsContainer/CreateCustomButton
@onready var back_button: Button = $BackButton
@onready var levels_container: VFlowContainer = $LevelsContainer

func _ready() -> void:
	create_custom_button.pressed.connect(get_tree().change_scene_to_packed.bind(create_custom))
	back_button.pressed.connect(get_tree().change_scene_to_packed.bind(stage_select))
	
	for level in stage_dir.get_files():
		var new_panel : Panel = custom_stage_panel.instantiate()
		
		var pwd : String = stage_dir.get_current_dir() + "/"
		var level_file : FileAccess = FileAccess.open(pwd+level, FileAccess.READ)
		var level_data : Dictionary = JSON.parse_string(level_file.get_as_text())
		
		new_panel.level_data = level_data
		levels_container.add_child(new_panel)

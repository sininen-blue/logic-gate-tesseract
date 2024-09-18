extends Control

@export var STAGE_PANEL : PackedScene
var stage_directory : DirAccess = DirAccess.open("res://levels")

@onready var stages_container: VBoxContainer = $Main/Stages

@onready var title_label: Label = $Main/InfoPanel/TitleLabel
@onready var description_label: Label = $Main/InfoPanel/DescriptionLabel
@onready var play_button: Button = $Main/InfoPanel/PlayButton

func _ready() -> void:
	make_panel("custom_levels")
	for stage in stage_directory.get_directories():
		if stage == "custom_levels":
			return
		make_panel(stage)


func make_panel(stage : String) -> void:
	var new_stage_panel : Button = STAGE_PANEL.instantiate()
	new_stage_panel.title = stage
	#new_stage_panel.current_level ## TODO: player local save
	
	## NOTE: messy but works well enough for now
	stage_directory.change_dir(stage)
	new_stage_panel.max_level = len(stage_directory.get_files())
	stage_directory.change_dir("..")
	
	new_stage_panel.dir = DirAccess.open("res://levels/"+stage)
	
	stages_container.add_child(new_stage_panel)
	new_stage_panel.pressed.connect(show_info.bind(stage))


func show_info(stage : String) -> void:
	var stage_file : FileAccess = FileAccess.open("res://levels/"+stage+".json", FileAccess.READ)
	var content : Dictionary = JSON.parse_string(stage_file.get_as_text())
	
	title_label.text = content["title"]
	description_label.text = content["description"]
	# TODO: custom level exception here
	play_button.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/level_select.tscn"))

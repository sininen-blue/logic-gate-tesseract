extends Control

@export var STAGE_PANEL : PackedScene
var stage_directory : DirAccess = DirAccess.open("res://levels")

func _ready() -> void:
	for stage in stage_directory.get_directories():
		var new_stage_panel : Panel = STAGE_PANEL.instantiate()
		new_stage_panel.title = stage
		#new_stage_panel.current_level ## TODO: player local save
		
		## NOTE: messy but works well enough for now
		stage_directory.change_dir(stage) 
		new_stage_panel.max_level = len(stage_directory.get_files())
		stage_directory.change_dir("..")
		$VBoxContainer.add_child(new_stage_panel)

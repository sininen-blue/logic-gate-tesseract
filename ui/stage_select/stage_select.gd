extends Control

const STAGE_PANEL: PackedScene = preload("uid://cj2adegb284b8")

var stages_directory : DirAccess = DirAccess.open("user://levels/")

@onready var stages_container: HBoxContainer = %Main


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://bitv0k63w6aiq")


func _ready() -> void:
	# ensure custom levels is at the top
	make_panel("custom_levels")
	for stage in stages_directory.get_directories():
		if stage == "custom_levels":
			continue
		make_panel(stage)


func make_panel(stage : String) -> void:
	var stage_file : FileAccess = FileAccess.open("user://"+stage+".json", FileAccess.READ)
	
	var new_stage_panel : Panel = STAGE_PANEL.instantiate()
	
	new_stage_panel.level_dict = JSON.parse_string(stage_file.get_as_text())
	
	var stage_dir: DirAccess = DirAccess.open("user://levels/"+stage)
	var stage_levels: Array = stage_dir.get_files()
	
	new_stage_panel.total_levels = len(stage_levels)
	
	var count: int = 0
	for level: String in stage_levels:
		var level_file: FileAccess = FileAccess.open("user://levels/"+stage+"/"+level, FileAccess.READ)
		var level_title: String = JSON.parse_string(level_file.get_as_text())["title"]
		if level_title in DataManager.player_save["completed_levels"]:
			count += 1
	new_stage_panel.completed_levels = count
	
	new_stage_panel.dir = DirAccess.open("user://levels/"+stage)
	stages_container.add_child(new_stage_panel)

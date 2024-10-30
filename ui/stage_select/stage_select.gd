extends Control

var stages_directory : DirAccess = DirAccess.open("user://levels/")

@onready var stage_panel: PackedScene = preload("uid://cj2adegb284b8")

@onready var stages_container: VBoxContainer = $Main/Stages
@onready var title_label: Label = $Main/InfoPanel/TitleLabel
@onready var description_label: Label = $Main/InfoPanel/DescriptionLabel


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
	var content : Dictionary = JSON.parse_string(stage_file.get_as_text())
	
	var new_stage_panel : Panel = stage_panel.instantiate()
	new_stage_panel.title = content["title"]
	
	## TODO: player local save
	var stage_dir: DirAccess = DirAccess.open("user://levels/"+stage)
	var stage_levels: Array = stage_dir.get_files()
	new_stage_panel.max_level = len(stage_levels)
	
	var count: int = 0
	for level: String in stage_levels:
		var level_file: FileAccess = FileAccess.open("user://levels/"+stage+"/"+level, FileAccess.READ)
		var level_title: String = JSON.parse_string(level_file.get_as_text())["title"]
		if level_title in DataManager.player_save["completed_levels"]:
			count += 1
	new_stage_panel.completed_levels = count
	
	new_stage_panel.dir = DirAccess.open("user://levels/"+stage)
	stages_container.add_child(new_stage_panel)
	new_stage_panel.pressed.connect(show_info.bind(content))


func show_info(content : Dictionary) -> void:
	title_label.text = content["title"]
	description_label.text = content["description"]

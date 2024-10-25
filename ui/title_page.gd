extends Control

@onready var play_button: Button = $PlayButton
@onready var settings_button: Button = $SettingsButton

func _ready() -> void:
	generate_files()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://b1xu7c0fhg4at")

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://1deothsca8o8")

func generate_files() -> void:
	var exists: bool = DirAccess.dir_exists_absolute("user://levels/")
	if exists == false:
		DirAccess.make_dir_absolute("user://levels/")
	
	var levels_directory: DirAccess = DirAccess.open("res://levels")
	var stages: PackedStringArray = levels_directory.get_directories()
	var stage_infos: PackedStringArray = levels_directory.get_files()
	
	for stage in stages:
		# create stage dir
		exists = DirAccess.dir_exists_absolute("user://levels"+stage)
		if exists == false:
			DirAccess.make_dir_absolute("user://levels/"+stage)
		
		var res_stage_path: String = "res://levels/" + stage + "/"
		var user_stage_path: String = "user://levels/" + stage + "/"
		var res_stage_folder: DirAccess = DirAccess.open(res_stage_path)
		
		for level in res_stage_folder.get_files():
			# read level
			var level_file: FileAccess = FileAccess.open(res_stage_path + level, FileAccess.READ)
			var level_content: String = level_file.get_as_text()
			
			# duplicate file to user
			var user_level_file: FileAccess = FileAccess.open(user_stage_path + level, FileAccess.WRITE)
			user_level_file.store_string(level_content)
	
	for stage_info in stage_infos:
		var stage_info_file: FileAccess = FileAccess.open("res://levels/"+stage_info, FileAccess.READ)
		var stage_info_content: String = stage_info_file.get_as_text()
		
		var user_stage_info_file: FileAccess = FileAccess.open("user://"+stage_info, FileAccess.WRITE)
		user_stage_info_file.store_string(stage_info_content)

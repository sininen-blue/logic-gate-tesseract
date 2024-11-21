extends Node

## TODO NOTE: this is a debug default value
var current_stage : DirAccess
var current_level : JSON
var is_custom : bool = false

## NOTE: used to edit levels
# called in custom_stage_panel.gd
# recieved, reset in create_custom_level.gd
var is_level_edit: bool = false
var edit_level_data: Dictionary

## NOTE: for the demos in some stages
# set in stage_panel.gd
# recieved, reset in level_select.gd
var demo_file_location: String = ""

var level_clear_speed: int = 0

var settings: Dictionary = {
	"use_path": true,
	"tesseract_path": ""
}

func _ready() -> void:
	read_settings()
	read_save()


func read_settings() -> void:
	var settings_file: FileAccess = FileAccess.open("user://settings.json", FileAccess.READ)
	if settings_file == null:
		return
	
	var json_string: String = settings_file.get_as_text()
	settings = JSON.parse_string(json_string)


func save_settings() -> void:
	var file: FileAccess = FileAccess.open("user://settings.json", FileAccess.WRITE)
	var json_string: String = JSON.stringify(settings)
	file.store_string(json_string)


var player_save: Dictionary = {
	"completed_levels": [],
}

func read_save() -> void:
	var save_file: FileAccess = FileAccess.open("user://user_save.json", FileAccess.READ)
	if save_file == null:
		player_save["completed_levels"] = []
		return
	
	var json_string: String = save_file.get_as_text()
	player_save = JSON.parse_string(json_string)


func save_user_save(level_title: String) -> void:
	if level_title not in player_save["completed_levels"]:
		player_save["completed_levels"].append(level_title)
	
	var file: FileAccess = FileAccess.open("user://user_save.json", FileAccess.WRITE)
	var json_string: String = JSON.stringify(player_save)
	file.store_string(json_string)

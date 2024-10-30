extends Node

## TODO NOTE: this is a debug default value
var current_stage : DirAccess
var current_level : JSON
var is_custom : bool = false

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
		return
	
	var json_string: String = save_file.get_as_text()
	player_save = JSON.parse_string(json_string)


func save_user_save(level_title: String) -> void:
	player_save["completed_levels"].append(level_title)
	
	var file: FileAccess = FileAccess.open("user://user_save.json", FileAccess.WRITE)
	var json_string: String = JSON.stringify(player_save)
	file.store_string(json_string)

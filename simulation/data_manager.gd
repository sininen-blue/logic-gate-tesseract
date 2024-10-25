extends Node

## TODO NOTE: this is a debug default value
var current_stage : DirAccess = DirAccess.open("res://levels/basic_concepts")
var current_level : JSON
var is_custom : bool = false


var user_data : FileAccess = FileAccess.open("user://save_data.json", FileAccess.READ_WRITE)

var settings: Dictionary = {
	"use_path": true,
	"tesseract_path": ""
}

func _ready() -> void:
	read_settings()


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

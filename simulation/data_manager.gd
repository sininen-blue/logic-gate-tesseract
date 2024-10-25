extends Node

## TODO NOTE: this is a debug default value
var current_stage : DirAccess = DirAccess.open("res://levels/basic_concepts")
var current_level : JSON
var is_custom : bool = false


var user_data : FileAccess = FileAccess.open("user://save_data.json", FileAccess.READ_WRITE)

var settings = {
	"use_path": true,
	"tesseract_path": ""
}

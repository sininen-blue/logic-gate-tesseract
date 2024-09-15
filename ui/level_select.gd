extends Control

@export var LEVEL_BUTTON : PackedScene
var stage_dir : DirAccess = DataManager.current_stage

# NOTE: arbitrary number, might replace
var start_position : Vector2 = Vector2(250, 250)
var distance : Vector2 = Vector2(300, 0)

func _ready() -> void:
	var count : int = 0
	for level in stage_dir.get_files():
		var new_level_button : Button = LEVEL_BUTTON.instantiate()
		new_level_button.global_position = start_position + (distance * count)
		new_level_button.level_title = level
		
		## NOTE: this should open the info popup not the actual level
		## TODO: goes directly to level for testing
		## TODO: messy as fuck json conversion
		var pwd : String = stage_dir.get_current_dir() + "/"
		var level_file : FileAccess = FileAccess.open(pwd+level, FileAccess.READ)
		var level_json : JSON = JSON.new()
		level_json.data = level_json.parse_string(level_file.get_as_text())
		new_level_button.level = level_json
		
		add_child(new_level_button)
		count += 1

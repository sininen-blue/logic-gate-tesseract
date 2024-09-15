extends Control

var stage_dir : DirAccess = DataManager.current_stage


func _ready() -> void:
	for level in stage_dir.get_files():
		print(level)

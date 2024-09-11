extends Control

func _ready() -> void:
	$VBoxContainer/CreateCustomButton.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/create_custom_level.tscn"))
	$Back.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/stage_select.tscn"))

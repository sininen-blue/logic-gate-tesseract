extends Control

func _ready() -> void:
	$Back.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/custom_levels.tscn"))
	$Create.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/custom_levels.tscn"))

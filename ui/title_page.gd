extends Control

func _ready() -> void:
	$Button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/stage_select.tscn")

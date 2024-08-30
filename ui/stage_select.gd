extends Control


func _ready() -> void:
	$VBoxContainer/StagePanel/PlayButton.pressed.connect(_on_button_pressed)
	$VBoxContainer/StagePanel6/PlayButton.pressed.connect(_on_button_pressed)
	$InfoPanel/PlayButton.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/level_select.tscn")

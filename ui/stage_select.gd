extends Control

## TODO: these are all temporary and should be deleted
func _ready() -> void:
	$VBoxContainer/StagePanel/PlayButton.pressed.connect(_on_button_pressed_custom)
	
	$VBoxContainer/StagePanel6/PlayButton.pressed.connect(_on_button_pressed)
	$VBoxContainer/StagePanel7/PlayButton.pressed.connect(_on_button_pressed)
	
	$Back.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/title_page.tscn"))
	$InfoPanel/PlayButton.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/level_select.tscn")

func _on_button_pressed_custom() -> void:
	get_tree().change_scene_to_file("res://ui/custom_levels.tscn")

extends Control


func _ready() -> void:
	$LevelButton.pressed.connect(_on_button_pressed)
	$LevelButton2.pressed.connect(_on_button_pressed)
	$LevelButton3.pressed.connect(_on_button_pressed)
	$LevelButton4.pressed.connect(_on_button_pressed)
	$LevelButton5.pressed.connect(_on_button_pressed)
	
	$LevelInfo/Button.pressed.connect(_on_button_pressed2)
	
	$Back.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/stage_select.tscn"))

func _on_button_pressed() -> void:
	$LevelInfo.visible = !$LevelInfo.visible

func _on_button_pressed2() -> void:
	get_tree().change_scene_to_file("res://simulation/simulation.tscn")

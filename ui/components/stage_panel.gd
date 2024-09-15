extends Panel

@export var title : String
@export var current_level : int
@export var max_level : int

func _ready() -> void:
	$StageLabel.text = title
	$ProgressLabel.text = str(current_level, "/", max_level)
	$PlayButton.pressed.connect(play_level)


func play_level() -> void:
	get_tree().change_scene_to_file("res://ui/level_select.tscn")

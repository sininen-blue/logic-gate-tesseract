extends Panel

@export var level_scene : PackedScene
@export var title : String
@export var current_level : int
@export var max_level : int
var dir : DirAccess

func _ready() -> void:
	$StageLabel.text = title
	$ProgressLabel.text = str(current_level, "/", max_level)
	$PlayButton.pressed.connect(play_level)


func play_level() -> void:
	DataManager.current_stage = dir
	get_tree().change_scene_to_packed(level_scene)

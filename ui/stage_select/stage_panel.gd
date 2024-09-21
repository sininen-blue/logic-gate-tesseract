extends Button

@export var level_scene : PackedScene
@export var custom_level_scene : PackedScene
@export var title : String
@export var current_level : int
@export var max_level : int

var dir : DirAccess

@onready var stage_label: Label = $StageLabel
@onready var progress_label: Label = $ProgressLabel
@onready var play_button: Button = $PlayButton

func _ready() -> void:
	stage_label.text = title
	progress_label.text = str(current_level, "/", max_level)
	play_button.pressed.connect(play_level)


func play_level() -> void:
	DataManager.current_stage = dir
	if title == "Custom Levels":
		get_tree().change_scene_to_packed(custom_level_scene)
		return
	get_tree().change_scene_to_packed(level_scene)

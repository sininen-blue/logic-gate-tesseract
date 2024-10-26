extends Panel

signal pressed()

@export var level_scene : PackedScene
@export var custom_level_scene : PackedScene
@export var title : String
@export var current_level : int
@export var max_level : int

var dir : DirAccess


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		pressed.emit()


func _ready() -> void:
	$StageLabel.text = title
	$ProgressLabel.text = str(current_level, "/", max_level)
	$PlayButton.pressed.connect(play_level)


func play_level() -> void:
	DataManager.current_stage = dir
	if title == "Custom Levels":
		get_tree().change_scene_to_packed(custom_level_scene)
	else:
		get_tree().change_scene_to_packed(level_scene)

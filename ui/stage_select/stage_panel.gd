extends Panel

signal pressed()

@export var title: String
@export var current_level: int
@export var max_level: int

const level_scene: String = "uid://yrih2e5sant0"
var custom_level_scene: String = "uid://bwlvlfljyekts"

var dir : DirAccess


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		pressed.emit()

func _on_mouse_entered() -> void:
	self.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

func _on_mouse_exited() -> void:
	self.mouse_default_cursor_shape = Control.CURSOR_ARROW


func _ready() -> void:
	$StageLabel.text = title
	$ProgressLabel.text = str(current_level, "/", max_level)
	$PlayButton.pressed.connect(play_level)


func play_level() -> void:
	DataManager.current_stage = dir
	if title == "Custom Levels":
		get_tree().change_scene_to_file(custom_level_scene)
	else:
		get_tree().change_scene_to_file(level_scene)

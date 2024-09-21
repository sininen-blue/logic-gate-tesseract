extends Control

@export var stage_select: PackedScene
@onready var play_button: Button = $PlayButton
@onready var settings_button: Button = $SettingsButton

func _ready() -> void:
	play_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(stage_select)

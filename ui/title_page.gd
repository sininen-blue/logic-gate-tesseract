extends Control


@onready var play_button: Button = $PlayButton
@onready var settings_button: Button = $SettingsButton

func _ready() -> void:
	generate_files()
	play_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/stage_select.tscn")

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/settings/settings.tscn")

func generate_files() -> void:
	## TODO: this should be where i turn all the res:// files into user:// files
	var exists: bool = DirAccess.dir_exists_absolute("user://custom_levels/")
	if exists == false:
		DirAccess.make_dir_absolute("user://custom_levels/")

extends Panel

@export var simulation_scene: PackedScene
@onready var stage_label: Label = $StageLabel
@onready var author_label: Label = $AuthorLabel
@onready var share_button: Button = $ShareButton
@onready var play_button: Button = $PlayButton
@onready var delete_button: Button = $DeleteButton

var level_data : Dictionary

func _ready() -> void:
	play_button.pressed.connect(play_custom)
	
	stage_label.text = level_data["title"]
	author_label.text = level_data["author"]

func play_custom() -> void:
	var level_json : JSON = JSON.new()
	level_json.data = level_data
	DataManager.current_level = level_json
	DataManager.is_custom = true
	
	get_tree().change_scene_to_packed(simulation_scene)

extends Panel

@export var simulation_scene: PackedScene
@onready var stage_label: Label = $StageLabel
@onready var author_label: Label = $AuthorLabel
@onready var share_button: Button = $ShareButton
@onready var play_button: Button = $PlayButton
@onready var delete_button: Button = $DeleteButton

var level_data : Dictionary

func _ready() -> void:
	var level_json : JSON = JSON.new()
	level_json.data = level_data
	DataManager.current_level = level_json
	
	play_button.pressed.connect(get_tree().change_scene_to_packed.bind(simulation_scene))
	
	stage_label.text = level_data["title"]
	author_label.text = level_data["author"]

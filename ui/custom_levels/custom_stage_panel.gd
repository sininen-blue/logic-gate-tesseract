extends Panel

const simulation_scene: String = "uid://swjkfmyam37c"

@onready var stage_label: Label = $StageLabel
@onready var author_label: Label = $AuthorLabel
@onready var share_button: Button = $ShareButton
@onready var play_button: Button = $PlayButton
@onready var delete_button: Button = $DeleteButton

var level_data : Dictionary

func _ready() -> void:
	play_button.pressed.connect(play_custom)
	delete_button.pressed.connect(delete_level)
	
	stage_label.text = level_data["title"]
	author_label.text = level_data["author"]

func play_custom() -> void:
	var level_json : JSON = JSON.new()
	level_json.data = level_data
	DataManager.current_level = level_json
	DataManager.is_custom = true
	
	get_tree().change_scene_to_file(simulation_scene)

func delete_level() -> void:
	var level_path : String = ""
	
	var dir_access: DirAccess = DirAccess.open("res://levels/custom_levels/")
	var pwd : String = dir_access.get_current_dir()+"/"
	for file in dir_access.get_files():
		var file_access: FileAccess = FileAccess.open(pwd+file, FileAccess.READ)
		var file_content : String = file_access.get_as_text()
		var file_data : Dictionary = JSON.parse_string(file_content)
		
		if file_data == level_data:
			level_path = pwd+file
			break
	
	if level_path != "":
		var err : Error = DirAccess.remove_absolute(level_path)
		print(err)
		
		self.call_deferred("queue_free")

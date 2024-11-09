extends Panel

const simulation_scene: String = "uid://swjkfmyam37c"

var level_data : Dictionary
var level_path : String = ""

@onready var stage_label: Label = $StageLabel
@onready var author_label: Label = $AuthorLabel
@onready var share_button: Button = $ShareButton
@onready var play_button: Button = $PlayButton
@onready var delete_button: Button = $DeleteButton
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog


func _ready() -> void:
	confirmation_dialog.dialog_text = "Are you sure you want to delete " + level_data["title"] + "?"
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
	var dir_access: DirAccess = DirAccess.open("user://levels/custom_levels/")
	var custom_levels_path: String = "user://levels/custom_levels/"
	for file in dir_access.get_files():
		var file_access: FileAccess = FileAccess.open(custom_levels_path+file, FileAccess.READ)
		var file_content : String = file_access.get_as_text()
		var file_data : Dictionary = JSON.parse_string(file_content)
		
		if file_data == level_data:
			level_path = custom_levels_path+file
			break
	
	if level_path != "":
		confirmation_dialog.visible = true


func _on_confirmation_dialog_confirmed() -> void:
	var err : Error = DirAccess.remove_absolute(level_path)
	print(err)
	
	self.call_deferred("queue_free")


func _on_confirmation_dialog_canceled() -> void:
	level_path = ""

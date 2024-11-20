extends Panel

const simulation_scene: String = "uid://swjkfmyam37c"
const CREATE_LEVEL_SCENE: String = "uid://c20nqruvjtxah"

var level_data : Dictionary
var level_path : String = ""

@onready var stage_label: Label = $StageLabel
@onready var author_label: Label = $AuthorLabel
@onready var create_date_label: Label = $CreateDateLabel
@onready var share_button: Button = $ShareButton
@onready var play_button: Button = $PlayButton
@onready var delete_button: Button = $DeleteButton
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog


func _ready() -> void:
	confirmation_dialog.dialog_text = "Are you sure you want to delete " + level_data["title"] + "?"
	play_button.pressed.connect(play_custom)
	delete_button.pressed.connect(delete_level)
	
	stage_label.text = level_data["title"]
	author_label.text = "by " + level_data["author"]
	var time_string: String = ""
	var time_dict: Dictionary = Time.get_datetime_dict_from_unix_time(level_data["create_date"])
	time_string += str(time_dict["year"], "/")
	time_string += str(time_dict["month"], "/")
	time_string += str(time_dict["day"], " ")
	time_string += str(time_dict["hour"], ":")
	time_string += str(time_dict["minute"])
	
	create_date_label.text = time_string

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


func _on_edit_button_pressed() -> void:
	DataManager.is_level_edit = true
	DataManager.edit_level_data = level_data
	get_tree().change_scene_to_file(CREATE_LEVEL_SCENE)

extends Control

const CREATE_CUSTOM_SCENE: String = "uid://c20nqruvjtxah"
const CUSTOM_STAGE_PANEL: PackedScene = preload("uid://le7ov2wv1ds0")

var stage_dir : DirAccess = DataManager.current_stage

@onready var levels_container: VBoxContainer = $ScrollContainer/LevelsContainer
@onready var file_dialog: FileDialog = $FileDialog
@onready var accept_dialog: AcceptDialog = $AcceptDialog


func _ready() -> void:
	if stage_dir.get_files().is_empty():
		return
	
	var all_levels: Array[Dictionary] = []
	for level in stage_dir.get_files():
		## NOTE: no checking for whether or not it's a valid level
		## should check it in level file
		var level_file : FileAccess = FileAccess.open("user://levels/custom_levels/"+level, FileAccess.READ)
		var level_data : Dictionary = JSON.parse_string(level_file.get_as_text())
		all_levels.append(level_data)
	
	if all_levels.is_empty():
		return
	
	all_levels.sort_custom(sort_time_descending)
	for level in all_levels:
		var new_panel : Panel = CUSTOM_STAGE_PANEL.instantiate()
		new_panel.level_data = level
		levels_container.add_child(new_panel)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("uid://b1xu7c0fhg4at")


func _on_create_custom_button_pressed() -> void:
	get_tree().change_scene_to_file(CREATE_CUSTOM_SCENE)


func _on_import_level_button_pressed() -> void:
	file_dialog.visible = true


func _on_file_dialog_file_selected(path: String) -> void:
	var import_level_file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var level_string: String = import_level_file.get_as_text()
	var level_data: Dictionary = JSON.parse_string(level_string)
	
	var level_title: String = level_data["title"]
	var user_level_path: String = "user://levels/custom_levels/"+level_title+".json"
	
	if FileAccess.file_exists(user_level_path):
		# show error about overwriting
		# and leave
		print("fuck")
		return
	
	var user_level_file: FileAccess = FileAccess.open(user_level_path, FileAccess.WRITE)
	user_level_file.store_string(level_string)
	
	accept_dialog.visible = true


func _on_accept_dialog_confirmed() -> void:
	get_tree().reload_current_scene()


func sort_time_descending(a: Dictionary, b: Dictionary) -> bool:
	return int(a["create_date"]) > int(b["create_date"])

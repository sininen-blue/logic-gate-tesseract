extends Control

signal settings_changed

@onready var path_check_box: CheckBox = $VBoxContainer/PathSetting/CheckBox

@onready var tess_file_dialog: FileDialog = $VBoxContainer/TesseractPathSetting/FileDialog
@onready var tess_path_text_edit: TextEdit = $VBoxContainer/TesseractPathSetting/PathTextEdit
@onready var tess_path_button: Button = $VBoxContainer/TesseractPathSetting/BrowseButton
@onready var tess_confirm: Button = $VBoxContainer/TesseractPathSetting/ConfirmButton

@onready var error_panel: Panel = $ErrorPanel
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/title_page.tscn")


func _ready() -> void:
	self.settings_changed.connect(DataManager.save_settings)
	
	path_check_box.button_pressed = DataManager.settings["use_path"]
	tess_path_text_edit.text = DataManager.settings["tesseract_path"]

func _on_path_setting_check_box_toggled(toggled_on: bool) -> void:
	DataManager.settings["use_path"] = toggled_on
	
	if toggled_on:
		tess_path_text_edit.editable = false
		tess_path_button.disabled = true
		tess_confirm.disabled = true
	else:
		tess_path_text_edit.editable = true
		tess_path_button.disabled = false
		tess_confirm.disabled = false
	
	settings_changed.emit()


func _on_tess_browse_button_pressed() -> void:
	tess_file_dialog.visible = true

func _on_tess_file_dialog_file_selected(path: String) -> void:
	tess_path_text_edit.text = path

func _on_tess_confirm_button_pressed() -> void:
	DataManager.settings["tesseract_path"] = tess_path_text_edit.text
	settings_changed.emit()


func _on_unlock_button_pressed() -> void:
	var all_stages_dir: DirAccess = DirAccess.open("user://levels/")
	for stage in all_stages_dir.get_directories():
		var stage_dir: DirAccess = DirAccess.open("user://levels/"+stage)
		var levels: PackedStringArray = stage_dir.get_files()
		
		for level in levels:
			var level_file: FileAccess = FileAccess.open("user://levels/"+stage+"/"+level, FileAccess.READ)
			var level_title: String = JSON.parse_string(level_file.get_as_text())["title"]
			
			DataManager.save_user_save(level_title)
	
	error_panel.show_error("All levels are now unlocked")


func _on_reset_button_pressed() -> void:
	confirmation_dialog.title = "Confirm Progress Reset"
	confirmation_dialog.dialog_text = "are you sure you want to reset your progress?"
	confirmation_dialog.show()


func _on_confirmation_dialog_confirmed() -> void:
	if confirmation_dialog.title == "Confirm Progress Reset":
		var err: Error = DirAccess.remove_absolute("user://user_save.json")
		if err == 0:
			DataManager.read_save()
			error_panel.show_error("save file deleted")
		elif err == 1:
			error_panel.show_error("could not delete save, save file may not exist")

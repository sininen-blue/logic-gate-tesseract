extends Control

signal settings_changed

@onready var path_check_box: CheckBox = $VBoxContainer/PathSetting/CheckBox

@onready var tess_file_dialog: FileDialog = $VBoxContainer/TesseractPathSetting/FileDialog
@onready var tess_path_text_edit: TextEdit = $VBoxContainer/TesseractPathSetting/PathTextEdit
@onready var tess_path_button: Button = $VBoxContainer/TesseractPathSetting/BrowseButton
@onready var tess_confirm: Button = $VBoxContainer/TesseractPathSetting/ConfirmButton


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

extends Control

const simulation_scene: String = "uid://swjkfmyam37c"
const custom_level_scene: String = "uid://bwlvlfljyekts"
const level_select_scene: String = "uid://yrih2e5sant0"

@onready var title: Label = $HBoxContainer/LevelPass/Title
@onready var accuracy: Label = $HBoxContainer/LevelPass/Accuracy

@onready var truth_table_container: VBoxContainer = $HBoxContainer/TruthTable/TruthTable/TruthTableContainer

func _ready() -> void:
	truth_table_container.start()


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file(simulation_scene)


func _on_continue_button_pressed() -> void:
	if DataManager.is_custom == true:
		get_tree().change_scene_to_file(custom_level_scene)
	else:
		get_tree().change_scene_to_file(level_select_scene)


func _on_truth_table_container_done(correct: Variant, full: Variant) -> void:
	var title_text: String = ""
	if correct == full:
		title_text = "Level Passed"
		save_data()
	else:
		title_text = "Level Failed"
	
	title.text = title_text
	accuracy.text = str(correct, "/", full)

func save_data() -> void:
	var level_data : Dictionary = DataManager.current_level.data
	var level_title : String = level_data["title"]
	
	DataManager.save_user_save(level_title)

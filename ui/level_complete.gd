extends Control

const simulation_scene: String = "uid://swjkfmyam37c"
const custom_level_scene: String = "uid://bwlvlfljyekts"
const level_select_scene: String = "uid://yrih2e5sant0"
const RED_BUTTON = preload("res://ui/themes/redButton.tres")
const RED_BOLDER = preload("res://ui/themes/RedBolder.tres")

@onready var title: Label = $TitleLabel
@onready var accuracy_value_label: Label = $"%AccuracyValueLabel"
@onready var speed_value_label: Label = %SpeedValueLabel
@onready var continue_button: Button = $LevelPass/ContinueButton

@onready var truth_table_container: VBoxContainer =$"%TruthTableContainer"

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
		title_text = "Level Passed !"
		continue_button.text = "Continue"
		save_data()
	else:
		title_text = "Level Failed"
		continue_button.text = "Back"
		continue_button.theme = RED_BUTTON
		title.theme = RED_BOLDER
	
	title.text = title_text
	accuracy_value_label.text = str(correct, "/", full)
	speed_value_label.text = str(DataManager.level_clear_speed,"s")
	
	# cleanup
	DataManager.level_clear_speed = 0

func save_data() -> void:
	var level_data : Dictionary = DataManager.current_level.data
	var level_title : String = level_data["title"]
	
	DataManager.save_user_save(level_title)

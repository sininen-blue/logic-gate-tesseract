extends Control

@onready var title: Label = $HBoxContainer/LevelPass/Title
@onready var accuracy: Label = $HBoxContainer/LevelPass/Accuracy

@onready var truth_table_container: VBoxContainer = $HBoxContainer/TruthTable/TruthTable/TruthTableContainer

func _ready() -> void:
	truth_table_container.start()


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://simulation/simulation.tscn")


func _on_continue_button_pressed() -> void:
	if DataManager.is_custom == true:
		get_tree().change_scene_to_file("res://ui/custom_levels.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/level_select.tscn")


func _on_truth_table_container_done(correct: Variant, full: Variant) -> void:
	var title_text: String = ""
	if correct == full:
		title_text = "Level Passed"
	else:
		title_text = "Level Failed"
	
	title.text = title_text
	accuracy.text = str(correct, "/", full)

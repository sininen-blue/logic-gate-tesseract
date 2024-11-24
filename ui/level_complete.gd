extends Control

const TRUTH_TABLE_ROW = preload("res://ui/components/truth_table_row.tscn")
const DARK_PANEL = preload("res://ui/themes/darkPanel.tres")
const LIGHT_PANEL = preload("res://ui/themes/lightPanel.tres")
const simulation_scene: String = "uid://swjkfmyam37c"
const custom_level_scene: String = "uid://bwlvlfljyekts"
const level_select_scene: String = "uid://yrih2e5sant0"
const RED_BUTTON = preload("res://ui/themes/redButton.tres")
const RED_BOLDER = preload("res://ui/themes/RedBolder.tres")

var output_count: int
var input_count: int

@onready var title: Label = $TitleLabel
@onready var accuracy_value_label: Label = $"%AccuracyValueLabel"
@onready var speed_value_label: Label = %SpeedValueLabel
@onready var continue_button: Button = $LevelPass/ContinueButton

@onready var truth_table_heading: Panel = $LevelPass/TruthTableHeading
@onready var truth_table: VBoxContainer = $LevelPass/TruthTableScroll/TruthTable


func _ready() -> void:
	var level_data : Dictionary = DataManager.current_level.data
	
	output_count = int(level_data["end_count"])
	input_count = len(level_data["truth_table"][0]) - output_count
	
	truth_table_heading.clear()
	var heading_count: int = 0
	for input in input_count:
		truth_table_heading.variables += String.chr(65  + heading_count)
		heading_count += 1
	for output in output_count:
		truth_table_heading.outputs += String.chr(65  + heading_count)
		heading_count += 1
	truth_table_heading.set_data()
	
	# remove current data
	var truth_table_rows: Array[Node] = truth_table.get_children()
	for row in truth_table_rows:
		truth_table.remove_child(row)
	
	var row_count: int = 0
	for row : String in level_data["truth_table"]:
		var new_row: Panel = TRUTH_TABLE_ROW.instantiate()
		new_row.variables = row.left(input_count)
		new_row.outputs = row.right(output_count)
		
		if row_count % 2 == 0:
			new_row.theme = DARK_PANEL
		else:
			new_row.theme = LIGHT_PANEL
		row_count += 1
		truth_table.add_child(new_row)
	
	var file : FileAccess = FileAccess.open("user://temp.dat", FileAccess.READ)
	var content : String = file.get_as_text()
	var results : Array = JSON.parse_string(content)
	
	set_row_checks(results)


func set_row_checks(results_table: Array) -> void:
	var target_table: Array[Node] = truth_table.get_children()
	
	for index in len(results_table):
		var target_outputs: String = target_table[index].outputs.right(output_count)
		var results_outputs: String = results_table[index].right(output_count)
		if target_outputs == results_outputs:
			target_table[index].checked = true
	
	
	var title_text: String = ""
	var accuracy: int = 0
	for row in target_table:
		if row.checked:
			accuracy += 1
	
	if accuracy == len(target_table):
		title_text = "Level Passed !"
		continue_button.text = "Continue"
		save_data()
	else:
		title_text = "Level Failed"
		continue_button.text = "Back"
		continue_button.theme = RED_BUTTON
		title.theme = RED_BOLDER
	
	title.text = title_text
	accuracy_value_label.text = str(accuracy, "/", len(target_table))
	speed_value_label.text = str(DataManager.level_clear_speed,"s")
	DataManager.level_clear_speed = 0


func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file(simulation_scene)


func _on_continue_button_pressed() -> void:
	if DataManager.is_custom == true:
		get_tree().change_scene_to_file(custom_level_scene)
	else:
		get_tree().change_scene_to_file(level_select_scene)


func save_data() -> void:
	var level_data : Dictionary = DataManager.current_level.data
	var level_title : String = level_data["title"]
	
	DataManager.save_user_save(level_title)

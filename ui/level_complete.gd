extends Control

@export var LEVEL : JSON

var correct_count : int = 0

func _ready():
	var level_data : Dictionary = LEVEL.data
	var truth_table : Array = level_data["truth_table"]
	var end_count : int = int(level_data["end_count"])
	var start_count : int = truth_table[0].length() - end_count
	
	var file = FileAccess.open("user://temp.dat", FileAccess.READ)
	var content = file.get_as_text()
	var results = JSON.parse_string(content)
	
	
	var table : String
	for x in range(len(truth_table)):
		table += str(results[x])
		for end_index in range(end_count):
			if str(results[x][start_count+end_index]) == truth_table[x][start_count+end_index]:
				table += "correct\n"
			else:
				table += "incorrect\n"
		
	
	$TruthTable/Label2.text = str(table)
	
	
	$LevelPass/Accuracy.text = str(correct_count," / ", len(results))


func _on_retry_button_pressed() -> void:
	## TODO: load the simulation level with the appropriate json file info
	get_tree().change_scene_to_file("res://simulation/simulation.tscn")


func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/level_select.tscn")

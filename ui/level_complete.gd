extends Control


var correct : Array = [0, 0, 0, 1, 1, 1, 1, 1]
var correct_count : int = 0

func _ready():
	var file = FileAccess.open("user://temp.dat", FileAccess.READ)
	var content = file.get_as_text()
	print(content)
	var results = JSON.parse_string(content)
	
	## TODO: proper formatting
	## TODO: make it work with multiple end outputs
	var table : String
	for x in range(len(results)):
		table += str(results[x]) 
		if results[x][3] == correct[x]:
			correct_count += 1
			table += " O"
		else:
			table += " X"
		table += " " + str(correct[x])
		table += "\n"
	
	$TruthTable/Label2.text = str(table)
	
	
	$LevelPass/Accuracy.text = str(correct_count," / ", len(results))


func _on_retry_button_pressed() -> void:
	## TODO: load the simulation level with the appropriate json file info
	get_tree().change_scene_to_file("res://simulation/simulation.tscn")


func _on_continue_button_pressed() -> void:
	get_tree().change_scene_to_file("res://ui/level_select.tscn")

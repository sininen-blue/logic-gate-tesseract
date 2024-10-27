extends VBoxContainer

signal done(correct: int, full: int)

var correct: int
var full_points: int

var truth_table_row: PackedScene = preload("uid://57o5uax0nrfc")

func start() -> void:
	var level_data : Dictionary = DataManager.current_level.data
	var truth_table : Array = level_data["truth_table"]
	var end_count : int = int(level_data["end_count"])
	var start_count : int = truth_table[0].length() - end_count
	
	var file : FileAccess = FileAccess.open("user://temp.dat", FileAccess.READ)
	var content : String = file.get_as_text()
	var results : Array = JSON.parse_string(content)
	
	var output_count : int = int(level_data["end_count"])
	var input_count : int = len(level_data["truth_table"][0]) - output_count
	
	for row_index in range(len(truth_table)):
		for end_index in range(end_count):
			var target: String = truth_table[row_index][start_count+end_index]
			var answer: String = results[row_index][start_count+end_index]
			
			var row_string: String = truth_table[row_index]
			if target == answer:
				create_row(row_string.left(input_count), row_string.right(output_count), true)
				correct += 1
			else:
				create_row(row_string.left(input_count), row_string.right(output_count), false)
	
	done.emit(correct, len(truth_table))


func create_row(vars: String, outputs: String, is_correct: bool) -> void:
	var new_row: Panel = truth_table_row.instantiate()
	new_row.variables = vars
	new_row.correct = is_correct
	add_child(new_row)

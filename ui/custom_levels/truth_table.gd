extends ScrollContainer

var table_row: PackedScene = preload("res://ui/custom_levels/table_row.tscn")

@onready var table_heading: HBoxContainer = $TruthTable/TableHeading
@onready var truth_table: VBoxContainer = $TruthTable


func make_table(input_count: int, output_count: int) -> void:
	clear_table()
	var row_count: int = int(pow(2, input_count))
	
	table_heading.input_count = input_count
	table_heading.output_count = output_count
	table_heading.set_heading()
	
	var truth_table_inputs: Array[String] = generate_truth_table(input_count)
	for row_index in row_count:
		var new_table_row: HBoxContainer = table_row.instantiate()
		new_table_row.input_string = truth_table_inputs[row_index]
		new_table_row.output_count = output_count
		truth_table.add_child(new_table_row)


func clear_table() -> void:
	for child in table_heading.get_children():
		child.queue_free()
	for child in truth_table.get_children():
		if child.name != "TableHeading":
			truth_table.remove_child(child)
			child.queue_free()


func get_outputs() -> Array[String]:
	var output: Array[String]
	for child in truth_table.get_children():
		if child.name != "TableHeading":
			output.append(child.get_output())
	
	return output


func set_outputs(output_count: int, target: Array) -> void:
	var index: int = 0
	
	for row in truth_table.get_children():
		if row.name == "TableHeading":
			continue
		row.set_output(target[index].right(output_count))
		index += 1


func generate_truth_table(start_count : int) -> Array[String]:
	var num_rows : int = int(pow(2, start_count))
	var output : Array[String]
	
	for i in range(num_rows):
		var row : Array
		for j in range(start_count):
			var bit_value : int = (i >> j) & 1
			row.append(bit_value)
		row.reverse()
		var string_row : String = ""
		for character: int in row:
			string_row += str(character)
		output.append(string_row)
	
	return output

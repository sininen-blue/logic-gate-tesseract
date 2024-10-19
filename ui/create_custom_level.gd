extends Control


@onready var title_edit: TextEdit = $ScrollContainer/Main/TitleLabel/TitleEdit
@onready var author_edit: TextEdit = $ScrollContainer/Main/AuthorLabel/AuthorEdit
@onready var description_edit: TextEdit = $ScrollContainer/Main/DescriptionLabel/DescriptionEdit
@onready var input_num_edit: TextEdit = $ScrollContainer/Main/ButtonLabel/InputNumEdit
@onready var output_num_edit: TextEdit = $ScrollContainer/Main/ButtonLabel/OutputNumEdit
@onready var truth_table_edit: TextEdit = $ScrollContainer/Main/ButtonLabel/TruthTableEdit

@onready var file_dialog: FileDialog = $FileDialog
@onready var photo_button: Button = $ScrollContainer/Main/ButtonLabel/PhotoButton

@onready var create_button: Button = $ScrollContainer/Main/Create

var input_count: int
var output_count: int

func _ready() -> void:
	$Back.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/custom_levels.tscn"))
	create_button.pressed.connect(create_level)

## TODO: replace all print statements with proper error handling
func create_level() -> void:
	if (title_edit.text == "" or
		author_edit.text == "" or
		description_edit.text == "" or
		input_num_edit.text == "" or
		output_num_edit.text == "" or
		truth_table_edit.text == ""):
		print("not all inputs are filled")
		return
	
	var level_data : Dictionary
	level_data["title"] = title_edit.text
	level_data["author"] = author_edit.text
	level_data["create_date"] = Time.get_time_dict_from_system() # TODO: this isn't the proper format
	level_data["description"] = description_edit.text
	level_data["end_count"] = output_num_edit.text
	
	# TODO:
	# maybe make the table dynamic basedo on number of inputs
	# error checking
	input_count = int(input_num_edit.text)
	output_count = int(output_num_edit.text)
	var truth_table : Array[String] = generate_truth_table(input_count)
	var output_array : PackedStringArray = truth_table_edit.text.split("\n", false)
	if len(output_array[0]) != int(output_num_edit.text):
		print("not the correct amount of output values")
		return
	if len(output_array) != pow(2, input_count):
		print("not the correct amount of rows")
		return
	for i in range(len(truth_table)):
		truth_table[i] += output_array[i]
	level_data["truth_table"] = truth_table
	
	var json_string : String = JSON.stringify(level_data, "\t")
	var filename : String = title_edit.text.replace(" ", "")
	var level_file : FileAccess = FileAccess.open("user://"+filename+".json", FileAccess.WRITE)
	level_file.store_string(json_string)
	
	print("saved")

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
		for character : String in row:
			string_row += str(character)
		output.append(string_row)
	
	return output


func _on_photo_button_pressed() -> void:
	## TODO: disallow pressing withotu putthing input and output
	file_dialog.visible = true
	file_dialog.add_filter("*.jpg, *.jpeg, *.png", "Images")


func _on_file_dialog_file_selected(image_path: String) -> void:
	var output: Array = []
	
	input_count = int(input_num_edit.text)
	output_count = int(output_num_edit.text)
	
	const program_path: String = "ocr/dist/ocr.exe"
	var column_count: int = input_count+output_count 
	var row_count: int = int(pow(2, input_count))
	
	var args: Array = [image_path, "-c", column_count, "-r", row_count]
	OS.execute(program_path, args, output, false, false)
	
	var json_string: String = output[0].get_slice("\n", 0)
	var truth_table: Dictionary = JSON.parse_string(json_string)
	
	for row: String in truth_table["truth_table"]:
		truth_table_edit.text += row.right(output_count)+"\n"

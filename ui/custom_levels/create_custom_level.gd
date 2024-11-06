extends Control

@onready var title_edit: TextEdit = %TitleEdit
@onready var author_edit: TextEdit = %AuthorEdit
@onready var description_edit: TextEdit = %DescriptionEdit

@onready var file_dialog: FileDialog = %FileDialog
@onready var photo_button: Button = %PhotoButton

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spinner_sprite: Sprite2D = %SpinnerSprite

@onready var error_panel: Panel = %ErrorPanel
@onready var create_button: Button = %CreateButton
@onready var confirmation_dialog: ConfirmationDialog = $ConfirmationDialog

@onready var manual_button: Button = $ScrollContainer/Panel/Main/TruthTableInputs/ManualButton

@onready var input_edit: IncrementEdit = $ScrollContainer/Panel/Main/TruthTableInputs/InputEdit
@onready var output_edit: IncrementEdit = $ScrollContainer/Panel/Main/TruthTableInputs/OutputEdit
@onready var truth_table: ScrollContainer = $ScrollContainer/Panel/Main/TruthTable

var exec_thread: Thread = Thread.new()

const custom_levels_scene: String = "uid://bwlvlfljyekts"

var input_count: int
var output_count: int


func _on_back_button_pressed() -> void:
	if exec_thread.is_alive():
		error_panel.show_error("Force stopping OCR system, please wait")
		
		await get_tree().create_timer(.5).timeout
		
		exec_thread.wait_to_finish()
	get_tree().change_scene_to_file(custom_levels_scene)


func _ready() -> void:
	create_button.pressed.connect(create_level)
	
	input_count = input_edit.count
	output_count = output_edit.count

## TODO: replace all print statements with proper error handling
func create_level() -> void:
	if (title_edit.text == "" or
		author_edit.text == "" or
		description_edit.text == ""):
		error_panel.show_error("not all input boxes were filled")
		return
	
	var level_data : Dictionary
	level_data["title"] = title_edit.text
	level_data["author"] = author_edit.text
	level_data["create_date"] = Time.get_time_dict_from_system() # TODO: this isn't the proper format
	level_data["description"] = description_edit.text
	# level_data["end_count"] = output_num_edit.text
	

	# input_count = int(input_num_edit.text)
	# output_count = int(output_num_edit.text)
	#var truth_table : Array[String] = generate_truth_table(input_count)
	#var output_array : PackedStringArray = truth_table_edit.text.split("\n", false)
	#if len(output_array[0]) != int(output_num_edit.text):
	#	error_panel.show_error("not the correct amount of output values")
	#	return
	#if len(output_array) != pow(2, input_count):
		#error_panel.show_error("not the correct amount of rows")
		#return
	#for i in range(len(truth_table)):
		#truth_table[i] += output_array[i]
	level_data["truth_table"] = truth_table
	
	var json_string : String = JSON.stringify(level_data, "\t")
	var filename : String = title_edit.text.replace(" ", "")
	var level_file : FileAccess = FileAccess.open("user://levels/custom_levels/"+filename+".json", FileAccess.WRITE)
	error_panel.show_error(str(FileAccess.get_open_error()))
	level_file.store_string(json_string)
	
	error_panel.show_error("Created Level")

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


func _on_photo_button_pressed() -> void:
	manual_button.disabled = true
	#if (input_num_edit.text == "" or
		#output_num_edit.text == ""):
		#error_panel.show_error("input, output, and row numbers are required")
		#return
	#
	#if input_num_edit.text.is_valid_int() == false:
		#error_panel.show_error("number of inputs isn't a number")
		#return
	#if output_num_edit.text.is_valid_int() == false:
		#error_panel.show_error("number of outputs isn't a number")
		#return
	#
	#if int(input_num_edit.text) > 6:
		#error_panel.show_error("Game does not support more than 6 input variables")
		#return
	#
	#if int(output_num_edit.text) > 6:
		#error_panel.show_error("Game does not support more than 6 outputs variables")
		#return
		#confirmation_dialog.visible = true
	#else:
		#file_dialog.visible = true
		#file_dialog.add_filter("*.jpg, *.jpeg, *.png", "Images")


func _on_confirmation_dialog_confirmed() -> void:
	file_dialog.visible = true
	file_dialog.add_filter("*.jpg, *.jpeg, *.png", "Images")


func _on_file_dialog_file_selected(image_path: String) -> void:
	var err: Error = exec_thread.start(download.bind(image_path))
	if err != 0:
		print(err)


func _process(_delta: float) -> void:
	if exec_thread.is_started() == false:
		return
	
	if exec_thread.is_alive():
		animation_player.play("loading")
		spinner_sprite.visible = true
		#truth_table_edit.editable = false
		create_button.disabled = true
	else:
		spinner_sprite.visible = false
		#truth_table_edit.editable = true
		create_button.disabled = false
		
		var truth_table: Array = exec_thread.wait_to_finish()
		#for row: String in truth_table.slice(1, truth_table.size()):
			#truth_table_edit.text += row.right(output_count)+"\n"


func download(image_path: String) -> Array:
	var output: Array = []
	
	#input_count = int(input_num_edit.text)
	#output_count = int(output_num_edit.text)
	
	var program_path: String = "ocr/dist/ocr.exe"
	#var column_count: int = input_count+output_count 
	
	#var args: Array = [image_path, "-c", column_count, "-i", input_count]
	#if DataManager.settings["use_path"] == false:
		#args.append("-a")
		#args.append(DataManager.settings["tesseract_path"])
	#
	#OS.execute(program_path, args, output, false, false)
	
	var json_string: String = output[0].get_slice("\n", 0)
	var truth_table: Array = JSON.parse_string(json_string)["truth_table"]
	
	return truth_table


func _on_manual_button_pressed() -> void:
	truth_table.visible = true
	truth_table.make_table(input_count, output_count)


func _on_input_edit_count_changed(new_count: int) -> void:
	input_count = new_count
	if truth_table.visible:
		truth_table.make_table(input_count, output_count)


func _on_output_edit_count_changed(new_count: int) -> void:
	output_count = new_count
	if truth_table.visible:
		truth_table.make_table(input_count, output_count)

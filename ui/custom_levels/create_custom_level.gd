extends Control

@onready var title_edit: TextEdit = %TitleEdit
@onready var author_edit: TextEdit = %AuthorEdit
@onready var description_edit: TextEdit = %DescriptionEdit

@onready var file_dialog: FileDialog = %FileDialog
@onready var photo_button: Button = %PhotoButton
@onready var handwrite_check_box: CheckBox = $ScrollContainer/Panel/Main/TruthTableInputs/HandwriteCheckBox

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var spinner_sprite: Sprite2D = %SpinnerSprite

@onready var error_panel: Panel = %ErrorPanel
@onready var create_button: Button = %CreateButton
@onready var accept_dialog: AcceptDialog = $AcceptDialog

@onready var manual_button: Button = $ScrollContainer/Panel/Main/TruthTableInputs/ManualButton

@onready var input_edit: IncrementEdit = $ScrollContainer/Panel/Main/TruthTableInputs/InputEdit
@onready var output_edit: IncrementEdit = $ScrollContainer/Panel/Main/TruthTableInputs/OutputEdit
@onready var truth_table_container: ScrollContainer = $ScrollContainer/Panel/Main/TruthTable

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
		description_edit.text == "" or
		input_count == 0 or
		output_count == 0):
		error_panel.show_error("not all required input boxes were filled")
		return
	
	var level_data : Dictionary
	level_data["title"] = title_edit.text
	
	if author_edit.text.is_empty():
		level_data["author"] = "Anonymous"
	
	level_data["author"] = author_edit.text
	level_data["create_date"] = Time.get_unix_time_from_system()
	level_data["description"] = description_edit.text
	level_data["end_count"] = output_count
	
	var truth_table : Array[String] = generate_truth_table(input_count)
	var outputs: Array[String] = truth_table_container.get_outputs()
	
	var row_count: int = int(pow(2, input_count))
	for row_index in row_count:
		truth_table[row_index] += outputs[row_index]
	
	level_data["truth_table"] = truth_table
	
	var json_string : String = JSON.stringify(level_data, "\t")
	var filename : String = title_edit.text.replace(" ", "")
	var level_file : FileAccess = FileAccess.open("user://levels/custom_levels/"+filename+".json", FileAccess.WRITE)
	if FileAccess.get_open_error() != 0:
		error_panel.show_error(str(FileAccess.get_open_error()))
	level_file.store_string(json_string)
	
	accept_dialog.visible = true


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
	if input_edit.count < 1 and output_edit.count < 1:
		error_panel.show_error("input and outputs are required")
		return
	
	file_dialog.visible = true
	file_dialog.add_filter("*.jpg, *.jpeg, *.png", "Images")

func _on_file_dialog_file_selected(image_path: String) -> void:
	manual_button.disabled = true
	var err: Error = exec_thread.start(download.bind(image_path))
	if err != 0:
		print(err)


func _process(_delta: float) -> void:
	if exec_thread.is_started() == false:
		return
	
	if exec_thread.is_alive():
		animation_player.play("loading")
		spinner_sprite.visible = true
	else:
		spinner_sprite.visible = false
		create_button.disabled = false
		
		var truth_table: Array = exec_thread.wait_to_finish()
		truth_table = truth_table.slice(1, truth_table.size())
		truth_table_container.visible = true
		truth_table_container.make_table(input_count, output_count)
		truth_table_container.set_outputs(output_count, truth_table)


func download(image_path: String) -> Array:
	var output: Array = []
	
	var program_path: String = "ocr/dist/ocr.exe"
	var column_count: int = input_count+output_count 
	
	var args: Array = ["-o", ProjectSettings.globalize_path("user://temp.json"), image_path, "-c", column_count, "-i", input_count]
	if handwrite_check_box.button_pressed:
		args.append("-hm")
	
	if DataManager.settings["use_path"] == false:
		args.append("-a")
		args.append(DataManager.settings["tesseract_path"])
	
	var exit_code: int = OS.execute(program_path, args, output, false, false)
	print(exit_code)
	
	var json_string: String = output[0].get_slice("\n", 0)
	var truth_table: Array = JSON.parse_string(json_string)["truth_table"]
	
	return truth_table


func _on_manual_button_pressed() -> void:
	create_button.disabled = false
	truth_table_container.visible = true
	truth_table_container.make_table(input_count, output_count)


func _on_input_edit_count_changed(new_count: int) -> void:
	input_count = new_count
	if truth_table_container.visible:
		truth_table_container.make_table(input_count, output_count)


func _on_output_edit_count_changed(new_count: int) -> void:
	output_count = new_count
	if truth_table_container.visible:
		truth_table_container.make_table(input_count, output_count)


func _on_accept_dialog_confirmed() -> void:
	get_tree().change_scene_to_file(custom_levels_scene)


func _on_accept_dialog_canceled() -> void:
	get_tree().change_scene_to_file(custom_levels_scene)

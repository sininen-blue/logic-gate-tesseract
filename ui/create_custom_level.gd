extends Control


@onready var title_edit: TextEdit = $ScrollContainer/Main/TitleLabel/TitleEdit
@onready var author_edit: TextEdit = $ScrollContainer/Main/AuthorLabel/AuthorEdit
@onready var description_edit: TextEdit = $ScrollContainer/Main/DescriptionLabel/DescriptionEdit
@onready var output_num_edit: TextEdit = $ScrollContainer/Main/ButtonLabel/OutputNumEdit
@onready var truth_table_edit: TextEdit = $ScrollContainer/Main/ButtonLabel/TruthTableEdit

@onready var create_button: Button = $ScrollContainer/Main/Create

func _ready() -> void:
	$Back.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/custom_levels.tscn"))
	create_button.pressed.connect(create_level)

func create_level() -> void:
	if (title_edit.text == "" or
		author_edit.text == "" or
		description_edit.text == "" or
		output_num_edit.text == "" or
		truth_table_edit.text == ""):
		print("error")
		return
	
	var level_data : Dictionary
	level_data["title"] = title_edit.text
	level_data["author"] = author_edit.text
	level_data["create_date"] = Time.get_time_dict_from_system()
	level_data["description"] = description_edit.text
	level_data["end_count"] = output_num_edit.text
	
	# TODO: need a check to make sure you have the proper truth table and the output
	# maybe even make it so that you only need to specificy the output and the number of starts
	# could just generate the numbers on my own
	# and input a specificend amount of starts and ends
	# and have the desired outputs be added onto that
	var truth_table : PackedStringArray = truth_table_edit.text.split("\n", false)
	level_data["truth_table"] = truth_table
	
	var json_string : String = JSON.stringify(level_data)
	var filename : String = title_edit.text.replace(" ", "")
	var level_file : FileAccess = FileAccess.open("user://"+filename+".json", FileAccess.WRITE)
	level_file.store_string(json_string)
	
	print("saved")

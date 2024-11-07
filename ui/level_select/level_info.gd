extends Panel

@export var in_game: bool = false

var simulation_scene: String = "uid://swjkfmyam37c"
var input_node: PackedScene = preload("uid://bbinj3e4ms0sl")
var output_node: PackedScene = preload("uid://dumop2qw31tk5")
var table_row: PackedScene = preload("uid://0im5s06d6220")

@onready var level_title: Label = $LevelTitle
@onready var level_description: Label = $DescriptionScroll/LevelDescription
@onready var truth_table: VBoxContainer = $TruthTableScroll/TruthTable
@onready var play_button: Button = $PlayButton
@onready var input_variables: VBoxContainer = $VariablesScroll/Container/InputVariables
@onready var output_variables: VBoxContainer = $VariablesScroll/Container/OutputVariables

func _ready() -> void:
	$CloseButton.pressed.connect(change_visibility)
	
	if in_game:
		play_button.queue_free()
	else:
		play_button.pressed.connect(get_tree().change_scene_to_file.bind(simulation_scene))

func change_visibility() -> void:
	self.visible = false

func _on_visibility_changed() -> void:
	if DataManager.current_level == null:
		return
	if level_title == null:
		return
	
	var level_data : Dictionary = DataManager.current_level.data
	level_title.text = level_data["title"]
	level_description.text = level_data["description"]
	
	var output_count : int = int(level_data["end_count"])
	var input_count : int = len(level_data["truth_table"][0]) - output_count
	
	var truth_table_rows: Array[Node] = truth_table.get_children()
	for row in truth_table_rows:
		truth_table.remove_child(row)
	for row : String in level_data["truth_table"]:
		var new_row: Panel = table_row.instantiate()
		new_row.variables = row.left(input_count)
		new_row.outputs = row.right(output_count)
		
		truth_table.add_child(new_row)
	
	if input_variables.get_child_count() < input_count:
		for i in range(input_count):
			var new_input_node : Control = input_node.instantiate()
			input_variables.add_child(new_input_node)
	if output_variables.get_child_count() < output_count:
		for i in range(output_count):
			var new_output_node : Control = output_node.instantiate()
			output_variables.add_child(new_output_node)
	
	while input_variables.get_child_count() > input_count:
		input_variables.remove_child(input_variables.get_children()[0])
	while output_variables.get_child_count() > output_count:
		output_variables.remove_child(output_variables.get_children()[0])

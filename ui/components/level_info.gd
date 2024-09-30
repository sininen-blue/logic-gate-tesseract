extends Panel

@export var simulation_scene : PackedScene
@export var input_node : PackedScene
@export var output_node : PackedScene

@onready var level_title: Label = $LevelTitle
@onready var level_description: Label = $LevelDescription
@onready var desired_table: Label = $DesiredTable
@onready var play_button: Button = $PlayButton
@onready var input_variables: VBoxContainer = $InputVariables
@onready var output_variables: VBoxContainer = $OutputVariables

func _ready() -> void:
	$CloseButton.pressed.connect(change_visibility)
	play_button.pressed.connect(get_tree().change_scene_to_packed.bind(simulation_scene))

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
	
	desired_table.text = ""
	for row : String in level_data["truth_table"]:
		desired_table.text += row + "\n"
	
	
	var output_count : int = int(level_data["end_count"])
	var input_count : int = len(level_data["truth_table"][0]) - output_count
	
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

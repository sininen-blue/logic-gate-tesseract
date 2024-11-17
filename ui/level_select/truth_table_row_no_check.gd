extends Panel

var variables: String = ""
var outputs: String = ""

@onready var data_container: HBoxContainer = $DataContainer

func _ready() -> void:
	set_data()


func set_data() -> void:
	for variable in variables:
		var new_label: Label = Label.new()
		new_label.text = variable
		data_container.add_child(new_label)
	
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND
	data_container.add_child(spacer)
	
	for output in outputs:
		var new_label: Label = Label.new()
		new_label.text = output
		data_container.add_child(new_label)

func clear() -> void:
	variables = ""
	outputs = ""
	var children: Array[Node] = data_container.get_children()
	for child in children:
		data_container.remove_child(child)
		child.queue_free()

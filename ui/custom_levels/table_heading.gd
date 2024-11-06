extends HBoxContainer

@export var input_count: int = 3
@export var output_count: int = 2


func set_heading() -> void:
	for input in input_count:
		var new_label: Label = Label.new()
		new_label.text = String.chr(65 + input)
		add_child(new_label)
	
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(spacer)
	
	for output in output_count:
		var new_label: Label = Label.new()
		new_label.text = "O" + str(output)
		add_child(new_label)

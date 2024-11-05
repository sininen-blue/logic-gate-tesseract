extends HBoxContainer

@export var input_string: String = "000"
@export var output_count: int = 2


func _ready() -> void:
	for input in input_string:
		var new_label: Label = Label.new()
		new_label.text = input
		add_child(new_label)
	
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(spacer)
	
	for output in output_count:
		var new_check: CheckButton = CheckButton.new()
		add_child(new_check)

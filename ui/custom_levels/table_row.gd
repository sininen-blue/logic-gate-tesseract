extends HBoxContainer

const BINARY_BUTTON: PackedScene = preload("res://ui/components/binary_button.tscn")

@export var input_string: String = "000"
@export var output_count: int = 2

var line_margin: float = 2

@onready var under_border: Line2D = $UnderBorder


func _ready() -> void:
	for input in input_string:
		var new_label: Label = Label.new()
		new_label.text = input
		add_child(new_label)
	
	var spacer: Control = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	add_child(spacer)
	
	for output in output_count:
		var new_bin_button: TextureButton = BINARY_BUTTON.instantiate()
		add_child(new_bin_button)
	
	await get_tree().process_frame
	
	under_border.points[0] = Vector2(0, self.size.y + line_margin)
	under_border.points[1] = Vector2(self.size.x, self.size.y + line_margin)


func get_output() -> String:
	var output: String = ""
	
	var children: Array[Node] = get_children()
	var buttons: Array = children.filter(is_binary_button)
	
	for button: TextureButton in buttons:
		output += str(int(button.value))
	
	return output


func set_output(output_string: String) -> void:
	var children: Array[Node] = get_children()
	var buttons: Array = children.filter(is_binary_button)
	
	if len(output_string) == len(buttons):
		print("nice")
	
	var index: int = 0
	for button: TextureButton in buttons:
		var convBool: bool = bool(int(output_string[index]))
		index += 1
		button.value = convBool
		button.disabled = true

func is_binary_button(node: Node) -> bool:
	return node is TextureButton

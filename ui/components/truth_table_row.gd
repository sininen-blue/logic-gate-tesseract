extends Panel

const CHECK = preload("res://assets/UI/icons/check.png")
const WRONG = preload("res://assets/UI/icons/wrong.png")

@export var checked: bool = true:
	set(new_value):
		checked = new_value
		if checked:
			sprite_rect.texture = CHECK
		else:
			sprite_rect.texture = WRONG

var variables: String = ""
var outputs: String = ""

@onready var data_container: HBoxContainer = $DataContainer
@onready var sprite_rect: TextureRect = TextureRect.new()

func _ready() -> void:
	checked = false
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
	
	sprite_rect.size = Vector2(30, 30)
	data_container.add_child(sprite_rect)


func clear() -> void:
	variables = ""
	outputs = ""
	var children: Array[Node] = data_container.get_children()
	for child in children:
		data_container.remove_child(child)
		child.queue_free()

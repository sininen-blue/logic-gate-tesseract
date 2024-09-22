extends Area2D
class_name Gate

@export_enum("and", "or", "xor", "nand", "nor", "xnor", "not", "start", "end") var gate_type : String = "and"
var value : int = 2:
	set(new_value):
		value = new_value
		handle_textures(gate_type)
var connections : Array[Connection]
var input_connections : Array[Connection]
var input_max : int = 2
var gate_name : String

@onready var start_label: Label = $StartLabel
@onready var sprite: Sprite2D = $Sprite2D

@onready var input_area: Area2D = $InputArea
@onready var output_area: Area2D = $OutputArea

func _ready() -> void:
	if self.gate_type == 'start' or self.gate_type == 'end':
		value = 0
	else:
		value = 2
	
	if self.gate_type == "not" or self.gate_type == "end":
		input_max = 1
	
	start_label.text = gate_name

func _process(_delta: float) -> void:
	# $TestingLabel.text = str(connections, input_connections, value)

	# value handling
	if self.gate_type == "start":
		return
	
	if len(input_connections) < input_max:
		self.value = 2
		return
	
	var input_one : int = input_connections[0].output.value
	if input_max == 1:
		match gate_type:
			"not":
				self.value = !input_one
			"end":
				self.value = input_one
	if input_max == 2:
		var input_two : int = input_connections[1].output.value
		match gate_type:
			"and":
				self.value = input_one and input_two
			"or":
				self.value = input_one or input_two
			"xor":
				self.value = input_one ^ input_two
			"nand":
				self.value = !(input_one and input_two)
			"nor":
				self.value = !(input_one or input_two)
			"xnor":
				self.value = !(input_one ^ input_two)


func handle_textures(type : String) -> void:
	if value == 0: # false
		sprite.texture = load("res://assets/simulation/"+type+"-false.png")
	elif value == 1: # true
		sprite.texture = load("res://assets/simulation/"+type+".png")
	elif value == 2: # inactive
		sprite.texture = load("res://assets/simulation/"+type+"-inactive.png")

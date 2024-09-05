extends Area2D
class_name Gate

@export_enum("and", "or", "xor", "nand", "nor", "xnor", "not", "start", "end") var gate_type : String = "and"
var value : int = 2:
	set(new_value):
		value = new_value
		handle_textures(gate_type)
var connections : Array[Connection]
var gate_name : String

@onready var start_label: Label = $StartLabel
@onready var sprite: Sprite2D = $Sprite2D

@onready var input_area: Area2D = $InputArea
@onready var output_area: Area2D = $OutputArea

func _ready() -> void:
	value = 0
	start_label.text = gate_name

func _process(delta: float) -> void:
	$TestingLabel.text = str(connections)

func handle_textures(type : String) -> void:
	if value == 0: # false
		sprite.texture = load("res://assets/simulation/"+type+"-false.png")
	elif value == 1: # true
		sprite.texture = load("res://assets/simulation/"+type+".png")
	elif value == 2: # inactive
		sprite.texture = load("res://assets/simulation/"+type+"-inactive.png")

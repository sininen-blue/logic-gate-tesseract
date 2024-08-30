extends Area2D
class_name GateNode

signal dragging_start(source)
signal dragging_stop(source)

@export_enum("And", "Or", "Xor", "Nand", "Nor", "Xnor", "Not", "Start", "End") var gate_type : String = "And"

var value : int
var draggable : bool = false
var dragging : bool = false

var offset : Vector2

@onready var main : Node2D = get_parent()
@onready var input_area: Area2D = $InputArea
@onready var output_area: Area2D = $OutputArea
@onready var testing_label: Label = $TestingLabel
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	
	self.dragging_start.connect(main._on_gate_dragging_start)
	self.dragging_stop.connect(main._on_gate_dragging_stop)


func _process(_delta: float) -> void:
	handle_textures()
	if draggable:
		if Input.is_action_just_pressed("left_click") and main.state == 0:
			dragging_start.emit(self)
			
			offset = get_global_mouse_position() - self.global_position
			dragging = true
	
	if dragging:
		self.global_position = get_global_mouse_position() - offset
		
		if Input.is_action_just_released("left_click"):
			dragging_stop.emit(self)
			dragging = false

func _on_mouse_entered() -> void:
	draggable = true

func _on_mouse_exited() -> void:
	draggable = false

func handle_textures() -> void:
	## TODO: figure out a way to change this so it only runs
	## when the value changes instead of per frame
	if value == 1:
		match gate_type:
			"And":
				sprite.texture = load("res://assets/simulation/and.png")
			"Or":
				sprite.texture = load("res://assets/simulation/or.png")
			"Xor":
				sprite.texture = load("res://assets/simulation/xor.png")
			"Nand": 
				sprite.texture = load("res://assets/simulation/nand.png")
			"Nor":
				sprite.texture = load("res://assets/simulation/nor.png")
			"Xnor":
				sprite.texture = load("res://assets/simulation/xnor.png")
			"Not":
				sprite.texture = load("res://assets/simulation/not.png")
			"Start": 
				sprite.texture = load("res://assets/simulation/start.png")
			"End":
				sprite.texture = load("res://assets/simulation/end.png")
	elif value == 0:
		match gate_type:
			"And":
				sprite.texture = load("res://assets/simulation/and-false.png")
			"Or":
				sprite.texture = load("res://assets/simulation/or-false.png")
			"Xor":
				sprite.texture = load("res://assets/simulation/xor-false.png")
			"Nand": 
				sprite.texture = load("res://assets/simulation/nand-false.png")
			"Nor":
				sprite.texture = load("res://assets/simulation/nor-false.png")
			"Xnor":
				sprite.texture = load("res://assets/simulation/xnor-false.png")
			"Not":
				sprite.texture = load("res://assets/simulation/not-false.png")
			"Start": 
				sprite.texture = load("res://assets/simulation/start-false.png")
			"End":
				sprite.texture = load("res://assets/simulation/end-false.png")
	elif value == 2:
		match gate_type:
			"And":
				sprite.texture = load("res://assets/simulation/and-inactive.png")
			"Or":
				sprite.texture = load("res://assets/simulation/or-inactive.png")
			"Xor":
				sprite.texture = load("res://assets/simulation/xor-inactive.png")
			"Nand": 
				sprite.texture = load("res://assets/simulation/nand-inactive.png")
			"Nor":
				sprite.texture = load("res://assets/simulation/nor-inactive.png")
			"Xnor":
				sprite.texture = load("res://assets/simulation/xnor-inactive.png")
			"Not":
				sprite.texture = load("res://assets/simulation/not-inactive.png")
			"End":
				sprite.texture = load("res://assets/simulation/end-false.png")

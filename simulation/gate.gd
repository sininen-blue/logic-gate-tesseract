extends Area2D
class_name GateNode

signal dragging_start(source)
signal dragging_stop(source)

@export_enum("And", "Or", "Xor", "Nand", "Nor", "Xnor", "Not", "Start", "End") var gate_type : String = "And"

var value : bool
var draggable : bool = false
var dragging : bool = false

var offset : Vector2

@onready var main : Node2D = get_parent()
@onready var input_area: Area2D = $InputArea
@onready var output_area: Area2D = $OutputArea
@onready var testing_label: Label = $TestingLabel

func _ready() -> void:
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	
	self.dragging_start.connect(main._on_gate_dragging_start)
	self.dragging_stop.connect(main._on_gate_dragging_stop)


func _process(_delta: float) -> void:
	## NOTE: these are testing textures
	if value == true:
		$Sprite2D.texture = load("res://assets/simulation/var on.png")
	if value == false:
		$Sprite2D.texture = load("res://assets/simulation/var off.png")
		
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

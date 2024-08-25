extends Area2D

signal connection_start(source, type)
signal connection_stop(source)

var hovering : bool = false
var connecting : bool = false

@export_enum("input", "output") var type : String = "input"

@onready var parent : Area2D = get_parent()
@onready var main : Node2D = get_parent().get_parent()

func _ready() -> void:
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	
	self.connection_start.connect(main._on_connection_start)
	self.connection_stop.connect(main._on_connection_stop)


func _process(_delta: float) -> void:
	if hovering:
		if Input.is_action_just_pressed("left_click") and main.state == 0:
			connection_start.emit(parent, type)
			connecting = true
	
	if connecting:
		# generate temp line here
		
		if Input.is_action_just_released("left_click"):
			connection_stop.emit(parent)
			connecting = false

func _on_mouse_entered() -> void:
	hovering = true

func _on_mouse_exited() -> void:
	hovering = false

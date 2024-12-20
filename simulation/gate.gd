extends Area2D
class_name Gate

signal mouse_near(gate: Gate)

const BLUE_DOT = preload("res://assets/simulation/dots/blueDot.png")
const RED_DOT = preload("res://assets/simulation/dots/redDot.png")
const GRAY_DOT = preload("res://assets/simulation/dots/grayDot.png")

@export_enum("and", "or", "xor", "nand", "nor", "xnor", "not", "start", "end") var gate_type : String = "and"
@export var demo_mode: bool = false
@export var value : int = 2:
	set(new_value):
		if new_value != value:
			bump()
		value = new_value
		handle_textures(gate_type)
var connections : Array[Connection]
var input_connections : Array[Connection]
var input_max : int = 2
var gate_name : String

@onready var start_label: Label = $StartLabel
@onready var sprite: Sprite2D = $Sprite2D
@onready var right_dot_sprite: Sprite2D = $RightDotSprite
@onready var left_dot_sprite: Sprite2D = $LeftDotSprite
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var input_area: Area2D = $InputArea
@onready var output_area: Area2D = $OutputArea

@onready var mouse_area: Area2D = $MouseArea
@onready var input_animation_player: AnimationPlayer = $InputAnimationPlayer
@onready var input_indicator: Sprite2D = $InputIndicator
@onready var output_animation_player: AnimationPlayer = $OutputAnimationPlayer
@onready var output_indicator: Sprite2D = $OutputIndicator
@onready var rotate_animation_player: AnimationPlayer = $RotateAnimationPlayer

@onready var tooltip_animation_player: AnimationPlayer = $TooltipAnimationPlayer
@onready var tooltip_timer: Timer = $TooltipTimer
@onready var tooltip: Panel = $Tooltip
@onready var tooltip_label: Label = $Tooltip/Label

func _ready() -> void:
	input_indicator.visible = false
	output_indicator.visible = false
	rotate_animation_player.play("rotate")
	if self.gate_type == 'start' or self.gate_type == 'end':
		value = 0
	else:
		value = 2
	
	if self.gate_type == "not" or self.gate_type == "end":
		input_max = 1
	
	if self.gate_type == "start":
		left_dot_sprite.visible = false
		input_max = 0
	if self.gate_type == "end":
		right_dot_sprite.visible = false
		output_area.monitorable = false
		output_area.monitoring = false
		output_indicator.modulate = Color("#ffffff00")
	
	start_label.text = gate_name
	
	bump()


func bump() -> void:
	animation_player.play("bump")

func shake() -> void:
	animation_player.play("shake")


func _process(_delta: float) -> void:
	# $TestingLabel.text = str(connections, input_connections, value)
	if demo_mode:
		return
	
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
		right_dot_sprite.texture = RED_DOT
		left_dot_sprite.texture = RED_DOT
	elif value == 1: # true
		sprite.texture = load("res://assets/simulation/"+type+".png")
		right_dot_sprite.texture = BLUE_DOT
		left_dot_sprite.texture = BLUE_DOT
	elif value == 2: # inactive
		sprite.texture = load("res://assets/simulation/"+type+"-inactive.png")
		right_dot_sprite.texture = GRAY_DOT
		left_dot_sprite.texture = GRAY_DOT


func _on_mouse_area_mouse_entered() -> void:
	mouse_near.emit(self)

func _on_mouse_area_mouse_exited() -> void:
	if input_indicator.visible == true:
		input_animation_player.play_backwards("pop-in")
	
	if output_indicator.visible == true:
		output_animation_player.play_backwards("pop-in")


func show_both_indicators() -> void:
	input_animation_player.play("pop-in")
	output_animation_player.play("pop-in")

func show_input_indictor() -> void:
	input_animation_player.play("pop-in")

func show_output_indicator() -> void:
	output_animation_player.play("pop-in")


func _on_mouse_entered() -> void:
	animation_player.play("hover-up")
	tooltip_timer.start()

func _on_mouse_exited() -> void:
	animation_player.play_backwards("hover-up")
	if tooltip_timer.is_stopped() == false:
		tooltip_timer.stop()
	else:
		tooltip_animation_player.play_backwards("pop-in")

func _on_tooltip_timer_timeout() -> void:
	tooltip_animation_player.play("pop-in")
	
	var text: String = ""
	match gate_type:
		"and":
			text = "A gate which outputs a 1 if both inputs are true"
		"or":
			text = "A gate which outputs a 1 if either inputs are true"
		"xor":
			text = "A gate which outputs a 1 if either inputs are true but not both"
		"nand":
			text = "A gate which outputs a 1 if both gates aren't true"
		"nor":
			text = "A gate which outputs a 1 if both gates are false"
		"xnor":
			text = "A gate which outputs a 1 if both gates are false or if both gates are true"
		"not":
			text = "A gate which outputs the opposite of the input"
		"start":
			text = "An input for the circuit"
		"end":
			text = "The output of the circuit"
	
	tooltip_label.text = text

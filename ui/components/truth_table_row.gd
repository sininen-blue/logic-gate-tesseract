extends Panel

var variables: String = ""
var outputs: String = ""
var correct: bool = false

@onready var variables_label: Label = $VariablesLabel
@onready var output_label: Label = $OutputLabel
@onready var icon: Sprite2D = $SpriteControl/Icon

func _ready() -> void:
	variables_label.text = variables
	output_label.text = outputs
	
	if correct:
		icon.texture = preload("res://assets/UI/icons/check.png")
	else:
		icon.texture = preload("res://assets/UI/icons/wrong.png")

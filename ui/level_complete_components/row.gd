extends Panel

var variables: String = ""
var correct: bool = false

@onready var assessment: Label = $Assessment
@onready var variables_label: Label = $VariablesLabel

func _ready() -> void:
	variables_label.text = variables
	assessment.text = str(correct)

extends Panel

var variables: String = ""
var outputs: String = ""

@onready var variables_label: Label = $VariablesLabel
@onready var output_label: Label = $OutputLabel

func _ready() -> void:
	variables_label.text = variables
	output_label.text = outputs

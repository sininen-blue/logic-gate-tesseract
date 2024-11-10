extends Control

@export var var_name: String

@onready var label: Label = $Label


func _ready() -> void:
	label.text = var_name

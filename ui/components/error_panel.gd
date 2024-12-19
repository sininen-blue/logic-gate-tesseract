extends Panel

signal cleared

@onready var error_label: Label = $ErrorLabel

func _ready() -> void:
	self.set_anchors_preset(Control.PRESET_CENTER)
	self.visible = false

func show_error(error_text: String) -> void:
	error_label.text = error_text
	self.visible = true

func _on_error_confirm_pressed() -> void:
	self.visible = false
	cleared.emit()

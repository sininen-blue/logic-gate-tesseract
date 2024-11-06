extends TextureButton

const BINARY_BUTTON_ONE = preload("res://assets/UI/theme/binaryButton/binaryButtonOne.png")
const BINARY_BUTTON_ZERO = preload("res://assets/UI/theme/binaryButton/binaryButtonZero.png")

@export var value: bool = false:
	set(new_value):
		value = new_value
		if value == true:
			texture_normal = BINARY_BUTTON_ONE
		else:
			texture_normal = BINARY_BUTTON_ZERO

func _on_pressed() -> void:
	value = !value

extends TextureButton

const BINARY_BUTTON_ZERO_DISABLED = preload("res://assets/UI/theme/binaryButton/zero/binaryButtonZero-disabled.png")
const BINARY_BUTTON_ZERO_HOVER = preload("res://assets/UI/theme/binaryButton/zero/binaryButtonZero-hover.png")
const BINARY_BUTTON_ZERO_NORMAL = preload("res://assets/UI/theme/binaryButton/zero/binaryButtonZero-normal.png")
const BINARY_BUTTON_ZERO_PRESSED = preload("res://assets/UI/theme/binaryButton/zero/binaryButtonZero-pressed.png")

const BINARY_BUTTON_ONE_DISABLED = preload("res://assets/UI/theme/binaryButton/one/binaryButtonOne-disabled.png")
const BINARY_BUTTON_ONE_HOVER = preload("res://assets/UI/theme/binaryButton/one/binaryButtonOne-hover.png")
const BINARY_BUTTON_ONE_NORMAL = preload("res://assets/UI/theme/binaryButton/one/binaryButtonOne-normal.png")
const BINARY_BUTTON_ONE_PRESSED = preload("res://assets/UI/theme/binaryButton/one/binaryButtonOne-pressed.png")

@export var value: bool = false:
	set(new_value):
		value = new_value
		if value == true:
			texture_normal = BINARY_BUTTON_ONE_NORMAL
			texture_pressed = BINARY_BUTTON_ONE_PRESSED
			texture_hover = BINARY_BUTTON_ONE_HOVER
			texture_disabled = BINARY_BUTTON_ONE_DISABLED
		else:
			texture_normal = BINARY_BUTTON_ZERO_NORMAL
			texture_pressed = BINARY_BUTTON_ZERO_PRESSED
			texture_hover = BINARY_BUTTON_ZERO_HOVER
			texture_disabled = BINARY_BUTTON_ZERO_DISABLED

func _on_pressed() -> void:
	value = !value

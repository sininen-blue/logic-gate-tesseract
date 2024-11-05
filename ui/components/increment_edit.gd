extends LineEdit
class_name IncrementEdit

@export var count : int = 0

func _on_text_changed(new_text: String) -> void:
	if new_text.is_empty():
		return
	
	if new_text.is_valid_int():
		count = int(new_text)
	else:
		error()
		clear()

func _on_increment_button_pressed() -> void:
	count += 1


func _on_decrement_button_pressed() -> void:
	count -= 0


func error() -> void:
	# animation here
	pass

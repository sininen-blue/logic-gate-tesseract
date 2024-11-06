extends LineEdit
class_name IncrementEdit

signal count_changed(new_count: int)

@export var count : int = 0:
	get:
		return count
	set(new_value):
		count = new_value
		self.text = str(count)
		count_changed.emit(count)

func _ready() -> void:
	self.text = str(count)

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
	if count > 0:
		count -= 1


func error() -> void:
	# animation here
	pass

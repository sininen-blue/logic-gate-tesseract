extends Panel

var close_pos: Vector2 = Vector2(1141, 135)
var open_pos: Vector2 = Vector2(867, 135)
var opened: bool = false

@onready var debounce_timer: Timer = $DebounceTimer

func _ready() -> void:
	self.position = close_pos


func _on_handle_button_pressed() -> void:
	if debounce_timer.is_stopped():
		if opened:
			opened = false
			tween_position(close_pos)
		else:
			opened = true
			tween_position(open_pos)
	
	debounce_timer.start()


func tween_position(to: Vector2) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", to, 1.5)

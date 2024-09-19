extends Button

var level_title : String
var level : JSON

func _ready() -> void:
	self.text = level_title
	self.pressed.connect(play_level)

func play_level() -> void:
	DataManager.current_level = level

extends Button

var level_title : String
var level : JSON

func _ready() -> void:
	self.text = level_title
	self.pressed.connect(play_level)
	

func play_level() -> void:
	DataManager.current_level = level
	DataManager.is_custom = false

func is_completed() -> bool:
	var full_level_title : String = level.data["title"]
	if full_level_title in DataManager.player_save["completed_levels"]:
		return true
	else:
		return false

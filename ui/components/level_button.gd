extends Button

@export var simulation_scene : PackedScene

var level_title : String
var level : JSON
#var is_completed NOTE: might not be needed

# when pressed go to level
func _ready() -> void:
	self.text = level_title
	self.pressed.connect(play_level)

func play_level() -> void:
	DataManager.current_level = level
	get_tree().change_scene_to_packed(simulation_scene)

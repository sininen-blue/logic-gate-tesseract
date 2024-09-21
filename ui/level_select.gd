extends Control

@export var LEVEL_BUTTON : PackedScene
var stage_dir : DirAccess = DataManager.current_stage

# NOTE: arbitrary number, might replace
var cam_start_position : Vector2
var start_position : Vector2 = Vector2(25, 250)
var distance : Vector2 = Vector2(300, 0)
var prev_button : Button
var moving_camera : bool = false

@onready var level_info: Panel = $LevelInfo
@onready var main: Control = $Main
@onready var back_button: Button = $BackButton
@onready var camera: Camera2D = $Camera2D


## TODO: still need to make challenge levels have a different thing
func _ready() -> void:
	back_button.pressed.connect(get_tree().change_scene_to_file.bind("res://ui/stage_select.tscn"))
	
	var count : int = 0
	for level in stage_dir.get_files():
		var new_level_button : Button = LEVEL_BUTTON.instantiate()
		new_level_button.position = start_position + (distance * count)
		new_level_button.level_title = level.get_slice("-", 0)
		
		var pwd : String = stage_dir.get_current_dir() + "/"
		var level_file : FileAccess = FileAccess.open(pwd+level, FileAccess.READ)
		var level_json : JSON = JSON.new()
		level_json.data = JSON.parse_string(level_file.get_as_text())
		new_level_button.level = level_json
		
		if count != 0:
			var new_line : Line2D = Line2D.new()
			var left_offset : Vector2 = Vector2(10, -new_level_button.size.y/2)
			var right_offset : Vector2 = Vector2(prev_button.size.x + 10, prev_button.size.y/2)
			new_line.add_point(new_level_button.position - left_offset)
			new_line.add_point(prev_button.position + right_offset)
			main.add_child(new_line)
		
		# cleanup
		main.add_child(new_level_button)
		new_level_button.pressed.connect(show_panel)
		count += 1
		prev_button = new_level_button

func show_panel() -> void:
	level_info.visible = !level_info.visible


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		cam_start_position = get_global_mouse_position()
		moving_camera = true
	
	if event.is_action_released("left_click"):
		moving_camera = false
	
	if event.is_action_pressed("mouse_wheel_up"):
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", camera.zoom + Vector2(0.2, 0.2), 0.1)
	if event.is_action_pressed("mouse_whee_down") and camera.zoom >= Vector2(0.5, 0.5):
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", camera.zoom - Vector2(0.2, 0.2), 0.1)


func _process(_delta: float) -> void:
	level_info.position = camera.position - level_info.size/2
	if moving_camera == false:
		return
	
	var mouse_vector : Vector2 = cam_start_position - get_global_mouse_position()
	var tween : Tween = get_tree().create_tween()

	tween.set_trans(Tween.TRANS_QUART)
	tween.tween_property(
		camera, "global_position", camera.global_position + mouse_vector, 0.05
	)

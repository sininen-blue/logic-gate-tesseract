extends Node2D

enum {
	IDLE,
	MOVING_CAMERA,
	MOVING_GATE,
	CREATING_CONNECTION,
}
var state : int = IDLE

@export var GATE_SCENE : PackedScene

@onready var temp_line: Line2D = $TempLine
@onready var mouse_area: Area2D = $MouseArea
@onready var camera : Camera2D = $Camera2D

@onready var and_button: Button = $CanvasLayer/UI/FlowContainer/AndButton
@onready var or_button: Button = $CanvasLayer/UI/FlowContainer/OrButton
@onready var xor_button: Button = $CanvasLayer/UI/FlowContainer/XorButton
@onready var nand_button: Button = $CanvasLayer/UI/FlowContainer/NandButton
@onready var nor_button: Button = $CanvasLayer/UI/FlowContainer/NorButton
@onready var xnor_button: Button = $CanvasLayer/UI/FlowContainer/XnorButton
@onready var not_button: Button = $CanvasLayer/UI/FlowContainer/NotButton

func _ready() -> void:
	and_button.pressed.connect(create_gate.bind("and"))
	or_button.pressed.connect(create_gate.bind("or"))
	xor_button.pressed.connect(create_gate.bind("xor"))
	nand_button.pressed.connect(create_gate.bind("nand"))
	nor_button.pressed.connect(create_gate.bind("nor"))
	xnor_button.pressed.connect(create_gate.bind("xnor"))
	not_button.pressed.connect(create_gate.bind("not"))
	
	## NOTE: these are temporary testing nodes
	## this should be replaced by a json reader
	## that reads level data and places all the parts
	create_gate("nor")
	create_gate("and")


func create_gate(type : String) -> void:
	var gate_scene : Gate = GATE_SCENE.instantiate()
	gate_scene.gate_type = type
	gate_scene.global_position = Vector2(500, 500) # NOTE: temp start location
	
	add_child(gate_scene)

## Deletion
## TODO: make sure that outputs and inputs can't be deleted
## TODO: make right clicks change the state of inputs
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click") and mouse_area.has_overlapping_areas():
		remove_item()
	
	## TODO: tween this
	if event.is_action_pressed("mouse_wheel_up"):
		camera.zoom += Vector2(0.2, 0.2)
	if event.is_action_pressed("mouse_whee_down") and camera.zoom >= Vector2(0.5, 0.5):
		camera.zoom -= Vector2(0.2, 0.2)
	
	
func remove_item() -> void:
	var areas : Array[Area2D] = mouse_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("connections"):
			var connection : Connection = area.get_parent()
			connection.input.connections.erase(connection)
			connection.output.connections.erase(connection)
			remove_child(connection)
			return
		if area.is_in_group("gates"):
			remove_connections(area)
			remove_child(area)
			return

func remove_connections(gate : Gate) -> void:
	for connection in gate.connections:
		remove_child(connection)
		
		if connection.input == gate: # left side of gate 
			connection.output.connections.erase(connection)
		if connection.output == gate:
			connection.input.connections.erase(connection)
	

## Processes
var start_position : Vector2
var gate_held : Gate
var temp_connection : Connection
func _process(_delta: float) -> void:
	mouse_area.global_position = get_global_mouse_position()
	
	match state:
		IDLE:
			if Input.is_action_just_pressed("left_click"):
				if mouse_area.has_overlapping_areas() == false:
					start_position = get_global_mouse_position()
					state = MOVING_CAMERA
				
				var areas : Array[Area2D] = mouse_area.get_overlapping_areas()
				for area in areas:
					if area.is_in_group("gates"):
						gate_held = area
						state = MOVING_GATE
						break
					
					if area.is_in_group("outputs") or area.is_in_group("inputs"):
						temp_connection = Connection.new()
						
						var gate : Gate = area.get_parent()
						if area.is_in_group("outputs"):
							temp_connection.output = gate
							temp_line.points[0] = gate.output_area.global_position
						elif area.is_in_group("inputs"):
							temp_connection.input = gate
							temp_line.points[0] = gate.input_area.global_position
						
						temp_line.points[-1] = get_global_mouse_position()
						temp_line.visible = true
						state = CREATING_CONNECTION
						break
		MOVING_CAMERA:
			## TODO: tween this
			var mouse_vector : Vector2 = start_position - get_global_mouse_position()
			camera.global_position += mouse_vector
			
			if Input.is_action_just_released("left_click"):
				state = IDLE
		
		MOVING_GATE:
			## TODO: handle offsets
			gate_held.global_position = get_global_mouse_position()
			
			if Input.is_action_just_released("left_click"):
				state = IDLE
		
		CREATING_CONNECTION:
			temp_line.points[-1] = get_global_mouse_position()
			
			if Input.is_action_just_released("left_click"):
				temp_line.visible = false
				
				for area in mouse_area.get_overlapping_areas():
					if temp_connection.input == null and area.is_in_group("inputs"):
						temp_connection.input = area.get_parent()
					if temp_connection.output == null and area.is_in_group("outputs"):
						temp_connection.output = area.get_parent()
					
					if (temp_connection.input != temp_connection.output and
							temp_connection.input != null and 
							temp_connection.output != null):
						complete_connection()
						break
				
				state = IDLE


func complete_connection() -> void:
	temp_connection.input.connections.append(temp_connection)
	temp_connection.output.connections.append(temp_connection)
	add_child(temp_connection)
	temp_connection = null


func run_simulation() -> void:
	pass
	### TODO: label start nodes
	### TODO: make a recursive function that allows for multiple depths
	#var end_values : Array[Array]
	#
	#for x in range(2):
		#for y in range(2):
			#for z in range(2):
				#start_nodes[0].value = x
				#start_nodes[1].value = y
				#start_nodes[2].value = z
				#
				#await get_tree().create_timer(.2).timeout
				#
				#var row = [x, y, z, end_node.value]
				#end_values.append(row)
				#
				#await get_tree().create_timer(.2).timeout
	#
	#var json_string = JSON.stringify(end_values)
	#var file = FileAccess.open("user://temp.dat", FileAccess.WRITE)
	#file.store_string(json_string)
	#
	#get_tree().change_scene_to_file("res://ui/level_complete.tscn")


func _on_info_button_pressed() -> void:
	$CanvasLayer/UI/LevelInfo.visible = !$CanvasLayer/UI/LevelInfo.visible

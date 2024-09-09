extends Node2D

enum {
	IDLE,
	MOVING_CAMERA,
	MOVING_GATE,
	CREATING_CONNECTION,
}
var state : int = IDLE

var all_gates : Array[Gate]
var active_gates : Array[Gate]

@export var GATE_SCENE : PackedScene
@export var LEVEL : JSON

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


func _on_child_order_changed() -> void:
	var children : Array[Node] = get_children()
	for child in children:
		if child.is_in_group("gates") and child not in all_gates:
			all_gates.append(child)
	
	for gate in all_gates:
		if gate not in children:
			all_gates.erase(gate)
			active_gates.erase(gate)
	
	for gate in all_gates:
		if len(gate.input_connections) == gate.input_max and gate not in active_gates:
			active_gates.append(gate)
		if len(gate.input_connections) < gate.input_max and gate in active_gates:
			active_gates.erase(gate)
	
	#print(active_gates)
	### BUG: tokens should be removed if gate is deleted
	#
	### NOTE: so this system will collect all the connections from a gate
	### that has the right amount of connections
	### like an and gate that has two connections
	### then it'll generate connection[0].output self.gate_name connection[1].output
	### will need TODO: value generation for each gate
	#
	### BUG: isn't run when connections are made
	#var tokens : Array[Gate]
	#for gate in all_gates:
		#if (is_instance_valid(gate) and 
			#gate.gate_type != "start" and
			#gate.value != 2 and
			#gate.connections.is_empty() != true):
			#
			### BUG: doesn't work with outputs/ other 1 input gates
			### a sentence shoudl have the main gate, it's connections
			### so basically a sentence is a gates lmao
			#
			#tokens.append(gate)
	#
	#for gate in tokens:
		#print(gate.connections)
		#if len(gate.connections) == 2:
			#print(gate.connections[0].output.gate_name, 
				#gate.gate_type, ## THIS WORKS, now to put it in a datatype
				#gate.connections[1].output.gate_name)
		#elif len(gate.connections) == 1:
			#print(gate.gate_type, ## THIS WORKS, now to put it in a datatype
				#gate.connections[0].output.gate_name)
	#


func _ready() -> void:
	randomize()
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
	create_level()


func create_level() -> void:
	var level_data : Dictionary = LEVEL.data
	var truth_table : Array = level_data["truth_table"]
	var end_count : int = int(level_data["end_count"])
	var start_count : int = truth_table[0].length() - end_count
	
	for start in range(start_count):
		create_gate("start", "left")
	for end in range(end_count):
		create_gate("end", "right")


func create_gate(type : String, location : String = "") -> void:
	var gate_scene : Gate = GATE_SCENE.instantiate()
	gate_scene.gate_type = type
	gate_scene.gate_name = String.chr(97 + len(all_gates)) # NOTE: will die after Z
	
	var start_location : Vector2
	if location == "left":
		start_location = Vector2(200, randi_range(50, 600))
	elif location == "right":
		start_location = Vector2(700, randi_range(50, 600))
	else:
		start_location = Vector2(500, 500)
	gate_scene.global_position = start_location
	
	add_child(gate_scene)


## Deletion
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	
	if event.is_action_pressed("right_click") and mouse_area.has_overlapping_areas():
		remove_item()
	
	if event.is_action_pressed("mouse_wheel_up"):
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", camera.zoom + Vector2(0.2, 0.2), 0.1)
	if event.is_action_pressed("mouse_whee_down") and camera.zoom >= Vector2(0.5, 0.5):
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(camera, "zoom", camera.zoom - Vector2(0.2, 0.2), 0.1)
	
	
func remove_item() -> void:
	var areas : Array[Area2D] = mouse_area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("connections"):
			var connection : Connection = area.get_parent()
			connection.input.connections.erase(connection)
			connection.input.handle_value()
			connection.output.connections.erase(connection)
			connection.output.handle_value()
			remove_child(connection)
			return
		if area.is_in_group("gates"):
			if !(area.gate_type == "start" or area.gate_type == "end"):
				remove_connections(area)
				remove_child(area)
				return

func remove_connections(gate : Gate) -> void:
	for connection in gate.connections:
		remove_child(connection)
		
		if connection.input == gate: # left side of gate
			connection.output.connections.erase(connection)
			connection.output.handle_value()
		if connection.output == gate:
			connection.input.connections.erase(connection)
			connection.input.handle_value()
	

## Processes
var start_position : Vector2
var gate_offset : Vector2
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
						gate_offset = area.global_position - get_global_mouse_position()
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
			var mouse_vector : Vector2 = start_position - get_global_mouse_position()
			
			var tween : Tween = get_tree().create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_QUART)
			tween.tween_property(
				camera, "global_position", camera.global_position + mouse_vector, 0.05
			)
			
			if Input.is_action_just_released("left_click"):
				state = IDLE
		
		MOVING_GATE:
			gate_held.global_position = get_global_mouse_position() + gate_offset
			
			if Input.is_action_just_released("left_click"):
				state = IDLE
		
		## TODO: never implemented connection limits
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
	# limits connection inputs
	if len(temp_connection.input.input_connections) >= temp_connection.input.input_max:
		return
	
	temp_connection.output.connections.append(temp_connection)
	temp_connection.input.connections.append(temp_connection)
	temp_connection.output.handle_value()
	temp_connection.input.handle_value()
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

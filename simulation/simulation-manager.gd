extends Node2D

var gates : Array[Gate]
class Gate:
	var node : GateNode
	# contains connections where the end is equal to the node
	var connections : Array[Connection] 
	var type : String


var connections : Array[Connection]
class Connection:
	var line : Line2D
	var start : Gate
	var end : Gate
	var value : int

enum {
	IDLE,
	MOVING_CAMERA,
	MOVING_GATE,
	CREATING_CONNECTION,
}
var state : int = IDLE

@export var GATE_SCENE : PackedScene

@onready var mouse_area: Area2D = $MouseArea

var start_nodes : Array[GateNode]
var end_node : GateNode

func _ready() -> void:
	## NOTE: these are temporary testing nodes
	## this should be replaced by a json reader
	## that reads level data and places all the parts
	
	var gate_scene : GateNode = GATE_SCENE.instantiate()
	gate_scene.gate_type = "Start"
	gate_scene.var_name = "x"
	gate_scene.value = false
	gate_scene.global_position = Vector2(200, 200) # NOTE: temp start location
	
	var new_gate : Gate = Gate.new()
	new_gate.node = gate_scene
	new_gate.type = gate_scene.gate_type
	
	start_nodes.append(new_gate.node)
	gates.append(new_gate)
	add_child(gate_scene)

	gate_scene = GATE_SCENE.instantiate()
	gate_scene.gate_type = "Start"
	gate_scene.var_name = "y"
	gate_scene.value = true
	gate_scene.global_position = Vector2(200, 400) # NOTE: temp start location
	
	new_gate = Gate.new()
	new_gate.node = gate_scene
	new_gate.type = gate_scene.gate_type
	
	start_nodes.append(new_gate.node)
	gates.append(new_gate)
	add_child(gate_scene)
	
	gate_scene = GATE_SCENE.instantiate()
	gate_scene.gate_type = "Start"
	gate_scene.var_name = "z"
	gate_scene.value = true
	gate_scene.global_position = Vector2(200, 600) # NOTE: temp start location
	
	new_gate = Gate.new()
	new_gate.node = gate_scene
	new_gate.type = gate_scene.gate_type
	
	start_nodes.append(new_gate.node)
	gates.append(new_gate)
	add_child(gate_scene)
	
	
	gate_scene = GATE_SCENE.instantiate()
	gate_scene.gate_type = "End"
	gate_scene.value = false
	gate_scene.global_position = Vector2(700, 300) # NOTE: temp start location
	
	new_gate = Gate.new()
	new_gate.node = gate_scene
	new_gate.type = gate_scene.gate_type
	
	end_node = new_gate.node
	gates.append(new_gate)
	add_child(gate_scene)


## Gate Creation
func _on_and_pressed() -> void:
	create_gate("And")

func _on_or_pressed() -> void:
	create_gate("Or")

func _on_xor_pressed() -> void:
	create_gate("Xor")

func _on_nand_pressed() -> void:
	create_gate("Nand")

func _on_nor_pressed() -> void:
	create_gate("Nor")

func _on_xnor_pressed() -> void:
	create_gate("Xnor")

func _on_not_pressed() -> void:
	create_gate("Not")


func create_gate(type : String):
	var gate_scene : GateNode = GATE_SCENE.instantiate()
	gate_scene.gate_type = type
	gate_scene.global_position = Vector2(500, 500) # NOTE: temp start location
	
	var new_gate : Gate = Gate.new()
	new_gate.node = gate_scene
	new_gate.type = gate_scene.gate_type
	
	gates.append(new_gate)
	add_child(gate_scene)



## Gate Moving Signals
func _on_gate_dragging_start(_source : Area2D):
	state = MOVING_GATE

func _on_gate_dragging_stop(_source : Area2D):
	state = IDLE


## Connection Creation
var new_connection : Connection
func _on_connection_start(source : Area2D, type : String):
	state = CREATING_CONNECTION
	
	new_connection = Connection.new()
	var source_gate : Gate
	for gate in gates:
		if gate.node == source:
			source_gate = gate
	
	if type == "output":
		new_connection.start = source_gate
	if type == "input":
		new_connection.end = source_gate

## TODO: clean this up at some point
## TODO make sure that you can't make a connection with the output
func _on_connection_stop(source : Area2D):
	state = IDLE
	
	if mouse_area.has_overlapping_areas() == false:
		new_connection = null
	
	# check if the area under the mouse position is an input
	var areas = mouse_area.get_overlapping_areas()
	for area in areas:
		# if connection started with an output
		if new_connection.end == null:
			# check if input area and not the same as the start of the connection
			if area.is_in_group("inputs") and area.parent != source:
				for gate in gates:
					if gate.node == area.parent:
						new_connection.end = gate
				
				create_line()
				break
			
		# if connection started with an input
		if new_connection.start == null:
			if area.is_in_group("outputs") and area.parent != source:
				for gate in gates:
					if gate.node == area.parent:
						new_connection.start = gate
				
				create_line()
				break

func create_line():
	# checks for duplicates
	for connection in connections:
		if (connection.start == new_connection.start and
			connection.end == new_connection.end):
			new_connection = null
			return
	
	# connection limits for specific types
	match new_connection.end.type:
		"Start":
			if len(new_connection.end.connections) >= 0:
				new_connection = null
				return
		"End":
			if len(new_connection.end.connections) >= 1:
				new_connection = null
				return
		"Not":
			if len(new_connection.end.connections) >= 1:
				new_connection = null
				return
		_:
			if len(new_connection.end.connections) >= 2:
				new_connection = null
				return
		
	
	new_connection.line = ConnectionLine.new()
	new_connection.line.add_point(Vector2.ZERO)
	new_connection.line.add_point(Vector2.ZERO)
	add_child(new_connection.line)
				
	new_connection.end.connections.append(new_connection)
	connections.append(new_connection)
	new_connection = null


## Deletion
## TODO: make sure that outputs and inputs can't be deleted
## TODO: make right clicks change the state of inputs
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		remove_item()
	
func remove_item():
	var areas = mouse_area.get_overlapping_areas()
	for area in areas:
		if in_connections(area):
			remove_connection(area)
			return
		if in_gates(area):
			remove_gate(area)
			return

func remove_gate(source : Area2D):
	var gate_item : Gate
	
	# grabs corresponding gate class the source is in
	for gate in gates:
		if gate.node == source:
			gate_item = gate
	
	if gate_item.type == "Start" or gate_item.type == "End":
		return
	
	# deletes all related connections
	var connection_items : Array[Connection]
	for connection in connections:
		if connection.start == gate_item or connection.end == gate_item:
			connection_items.append(connection)
	
	
	remove_child(gate_item.node)
	gates.erase(gate_item)
	
	for to_delete in connection_items:
		to_delete.end.connections.erase(to_delete)
		remove_child(to_delete.line)
		connections.erase(to_delete)

func remove_connection(target : Area2D):
	var connection_item : Connection
	for connection in connections:
		if connection.line == target.get_parent():
			remove_child(connection.line)
			connection_item = connection
	
	for gate in gates:
		if connection_item in gate.connections:
			gate.connections.erase(connection_item)
	
	connections.erase(connection_item)

func in_gates(node : Area2D) -> bool:
	for gate in gates:
		if gate.node == node:
			return true
	return false

func in_connections(line : Area2D) -> bool:
	for connection in connections:
		if connection.line == line.get_parent():
			return true
	return false


## Processes
var start_position : Vector2
func _process(_delta: float) -> void:
	# TODO: this label is for testing, remove later
	$MouseArea/Label.text = str(get_global_mouse_position())
	for gate in gates:
		# TODO: this is for testing, remove later
		gate.node.testing_label.text = str(gate.node.value, gate.type, "->", gate.connections)
		
		## TODO: put this somewhere in a setget function for connections
		handle_gate_values(gate)
	
	for connection in connections:
		connection.value = connection.start.node.value
	
	mouse_area.global_position = get_global_mouse_position()
	
	if connections.is_empty() == false:
		for connection in connections:
			var last_point_index : int = connection.line.get_point_count() -1
			connection.line.set_point_position(0, connection.start.node.output_area.global_position)
			connection.line.set_point_position(last_point_index, connection.end.node.input_area.global_position)
	
	match state:
		IDLE:
			## TODO: put this in a state transition instead to save compute time
			for connection in connections:
				connection.line.distribute_areas()
			
			if Input.is_action_just_pressed("left_click"):
				if mouse_area.has_overlapping_areas() == false:
					start_position = get_global_mouse_position()
					state = MOVING_CAMERA
		MOVING_CAMERA:
			## TODO: Tween this position change at some point
			var mouse_vector : Vector2 = start_position - get_global_mouse_position()
			$Camera2D.global_position += mouse_vector
			
			if Input.is_action_just_released("left_click"):
				state = IDLE
		MOVING_GATE:
			pass
		CREATING_CONNECTION:
			pass

## TODO: fix this to be less ugly
func handle_gate_values(gate):
	match gate.type:
			"And":
				if len(gate.connections) == 2:
					gate.node.value = gate.connections[0].value and gate.connections[1].value
				else:
					gate.node.value = 2
			"Or":
				if len(gate.connections) == 2:
					gate.node.value = gate.connections[0].value or gate.connections[1].value
				else:
					gate.node.value = 2
			"Xor":
				if len(gate.connections) == 2:
					gate.node.value = int(gate.connections[0].value) ^ int(gate.connections[1].value)
				else:
					gate.node.value = 2
			"Nand": 
				if len(gate.connections) == 2:
					gate.node.value = !(gate.connections[0].value and gate.connections[1].value)
				else:
					gate.node.value = 2
			"Nor":
				if len(gate.connections) == 2:
					gate.node.value = !(gate.connections[0].value or gate.connections[1].value)
				else:
					gate.node.value = 2
			"Xnor":
				if len(gate.connections) == 2:
					gate.node.value = !(int(gate.connections[0].value) ^ int(gate.connections[1].value))
				else:
					gate.node.value = 2
			"Not":
				if len(gate.connections) == 1:
					gate.node.value = !gate.connections[0].value
				else:
					gate.node.value = 2
			"End":
				if len(gate.connections) == 1:
					gate.node.value = gate.connections[0].value
				else:
					gate.node.value = 2


func _on_run_button_pressed() -> void:
	run_simulation()

func run_simulation():
	## TODO: label start nodes
	var end_values : Array[Array]
	
	for x in range(2):
		for y in range(2):
			for z in range(2):
				start_nodes[0].value = x
				start_nodes[1].value = y
				start_nodes[2].value = z
				
				await get_tree().create_timer(.2).timeout
				
				var row = [x, y, z, end_node.value]
				end_values.append(row)
				
				await get_tree().create_timer(.2).timeout
	
	var json_string = JSON.stringify(end_values)
	var file = FileAccess.open("user://temp.dat", FileAccess.WRITE)
	file.store_string(json_string)
	
	get_tree().change_scene_to_file("res://ui/level_complete.tscn")

extends Node2D

var gates : Array[Gate]
class Gate:
	var node : GateNode
	var type : String

var connections : Array[Connection]
class Connection:
	var line : Line2D
	var start : Gate
	var end : Gate
	var value : bool

enum {
	IDLE,
	MOVING_GATE,
	CREATING_CONNECTION,
}
var state : int = IDLE

@export var GATE_SCENE : PackedScene

@onready var mouse_area: Area2D = $MouseArea



func _ready() -> void:
	var gate_scene : GateNode = GATE_SCENE.instantiate()
	gate_scene.gate_type = "Input"
	gate_scene.value = true
	gate_scene.global_position = Vector2(200, 200) # NOTE: temp start location
	
	var new_gate : Gate = Gate.new()
	new_gate.node = gate_scene
	new_gate.type = gate_scene.gate_type
	
	gates.append(new_gate)
	add_child(gate_scene)

	gate_scene = GATE_SCENE.instantiate()
	gate_scene.gate_type = "Input"
	gate_scene.value = false
	gate_scene.global_position = Vector2(200, 400) # NOTE: temp start location
	
	new_gate = Gate.new()
	new_gate.node = gate_scene
	new_gate.type = gate_scene.gate_type
	
	gates.append(new_gate)
	add_child(gate_scene)


## Gate Creation
func _on_and_pressed() -> void:
	var gate_scene : GateNode = GATE_SCENE.instantiate()
	gate_scene.gate_type = "And"
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

func _on_connection_stop(source : Area2D):
	state = IDLE
	
	if mouse_area.has_overlapping_areas() == false:
		new_connection = null
	
	# check if the area under the mouse position is an input
	var areas = mouse_area.get_overlapping_areas()
	for area in areas:
		# if connection started with an output
		if new_connection.end == null:
			if area.is_in_group("inputs") and area.parent != source:
				for gate in gates:
					if gate.node == area.parent:
						new_connection.end = gate
				
				new_connection.line = ConnectionLine.new()
				new_connection.line.add_point(Vector2.ZERO)
				new_connection.line.add_point(Vector2.ZERO)
				add_child(new_connection.line)
				
				connections.append(new_connection)
				new_connection = null
				break
			
		# if connection started with an input
		if new_connection.start == null:
			if area.is_in_group("outputs") and area.parent != source:
				for gate in gates:
					if gate.node == area.parent:
						new_connection.start = gate
				
				# probably change this line2d at some point
				new_connection.line = ConnectionLine.new()
				new_connection.line.add_point(Vector2.ZERO)
				new_connection.line.add_point(Vector2.ZERO)
				add_child(new_connection.line)
				
				connections.append(new_connection)
				new_connection = null
				break


## Deletion
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
	for gate in gates:
		if gate.node == source:
			gate_item = gate
	
	var connection_items : Array[Connection]
	for connection in connections:
		if connection.start == gate_item or connection.end == gate_item:
			connection_items.append(connection)
	
	remove_child(gate_item.node)
	gates.erase(gate_item)
	
	for to_delete in connection_items:
		remove_child(to_delete.line)
		connections.erase(to_delete)

func remove_connection(target : Area2D):
	for connection in connections:
		if connection.line == target.get_parent():
			remove_child(connection.line)
			connections.erase(connection)

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
func _process(_delta: float) -> void:
	for gate in gates:
		pass
		# go through each gate
		# figure out how many connections are connected to it
		# if there are more than 2 (or 1 in the case of a not gate)
		# figure out what value the gate should output
	
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
		MOVING_GATE:
			pass
		CREATING_CONNECTION:
			pass

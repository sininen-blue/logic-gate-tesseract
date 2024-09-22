extends VBoxContainer

@export var formula_label: PackedScene

var roots: Array[logic_node]
class logic_node:
	var gate: Gate
	var left: logic_node = null
	var right: logic_node = null

func new_node(gate: Gate) -> logic_node:
	var node: logic_node = logic_node.new()
	node.gate = gate
	
	# this seems dumb
	## TODO: new plan, walk from start gates only
	for connection in node.gate.input_connections:
		if connection.output.gate_type == "start":
			if node.left == null:
				node.left = new_node(connection.output)
				continue
			node.right = new_node(connection.output)
	
	add_root(node)
	return node

func add_root(node: logic_node) -> void:
	for root in roots:
		var tree: Array[logic_node] = walk(root, [])
	roots.append(node)

func walk(curr: logic_node, path: Array[logic_node]) -> Array[logic_node]:
	if curr == null:
		return path
	
	path.append(curr)
	
	# NOTE: doesn't work with not and end gates
	walk(curr.left, path)
	walk(curr.right, path)
	
	return path

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for root in roots:
			print(root.gate.gate_name)

# what do I want to happen
# when a connection is made
# check if the input of that connection has the maximum amount of connections
# that means that it's a "working" gate
# then make a logic_node out of that, and then add that to an array
# then check if that gates children is a start gate
# if so add that to the children of the child node

# if a new logic_node is made, check to see if the children of that node, include
# the gate of one of the root nodes, if so, combine

# also if a connection is deleted
# remove the logic_node associated with the input of that connection
# also move the root around

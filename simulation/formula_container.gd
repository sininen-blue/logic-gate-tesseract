extends VBoxContainer

@export var formula_label: PackedScene

var roots: Array[logic_node]
class logic_node:
	var gate: Gate
	var left: logic_node = null
	var right: logic_node = null

func new_node(gate: Gate) -> void:
	var node: logic_node = logic_node.new()
	node.gate = gate
	
	for connection in node.gate.input_connections:
		var child_node: logic_node = logic_node.new()
		child_node.gate = connection.output
		if node.left == null:
			node.left = child_node
			continue
		node.right = child_node
	
	roots.append(node)
	trim_roots()

func delete_node(gate: Gate) -> void:
	# if the child isn't a start node
	# and those children aren't already roots (can't happen)
	# turn those children into roots
	var to_delete: logic_node
	for root in roots:
		if root.gate == gate:
			to_delete = root
			break
	
	if to_delete == null:
		return
		
	roots.erase(to_delete)
	if to_delete.left.gate.gate_type != "start":
		new_node(to_delete.left.gate)
		trim_roots()
	if to_delete.right.gate.gate_type != "start":
		new_node(to_delete.right.gate)
		trim_roots()


## NOTE: because I made a new logic_node, I can just remove it from the roots without
## needing to combine
func trim_roots() -> void:
	var bin: Array[logic_node]
	for x in roots:
		for y in roots:
			if x.left.gate == y.gate or x.right.gate == y.gate:
				bin.append(y)
	
	for item in bin:
		roots.erase(item)

func _ready() -> void:
	var new_label: Label = formula_label.instantiate()
	add_child(new_label)


func _process(_delta: float) -> void:
	for label in get_children():
		var output: String = ""
		for root in roots:
			output += root.gate.gate_name
		
		label.text = output

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
